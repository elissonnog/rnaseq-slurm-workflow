#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($RealBin);
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Copy qw(copy);
use File::Path qw(make_path);
use File::Spec;
use Getopt::Long qw(GetOptions);

my %opt = (
    repo_root => dirname($RealBin),
);

GetOptions(
    'project-dir|analysis-dir=s' => \$opt{project_dir},
    'sample-file=s' => \$opt{sample_file},
    'experiment=s'  => \$opt{experiment},
    'mail-user=s'   => \$opt{mail_user},
    'output-dir=s'  => \$opt{output_dir},
    'repo-root=s'   => \$opt{repo_root},
    'help'          => \$opt{help},
) or die usage();

if ($opt{help}) {
    print usage();
    exit 0;
}

$opt{project_dir} ||= prompt('Enter the analysis directory (project-dir): ');
$opt{sample_file} ||= prompt('Enter the sample file path: ');
$opt{experiment}  ||= prompt('Enter the experiment name: ');
if (!defined $opt{mail_user}) {
    $opt{mail_user} = (-t STDIN) ? prompt('Enter the email for Slurm notifications (optional): ', 1) : '';
}

$opt{output_dir} ||= $opt{experiment};

for my $required (qw(project_dir sample_file experiment output_dir repo_root)) {
    die "Missing required option: $required\n" if !defined $opt{$required} || $opt{$required} eq '';
}

die "Sample file not found: $opt{sample_file}\n" if !-f $opt{sample_file};
$opt{project_dir} = File::Spec->rel2abs($opt{project_dir});

my $template_dir = "$opt{repo_root}/templates/slurm";
my $config_dir   = "$opt{repo_root}/config";
my $scripts_dir  = "$opt{repo_root}/scripts";

for my $dir ($template_dir, $config_dir, $scripts_dir) {
    die "Required directory not found: $dir\n" if !-d $dir;
}

my @samples = read_samples($opt{sample_file});
die "No sample IDs found in $opt{sample_file}\n" if !@samples;

make_path($opt{output_dir}) unless -d $opt{output_dir};
my $output_dir_abs = abs_path($opt{output_dir})
    or die "Cannot resolve output directory: $opt{output_dir}\n";
my $rendered_sample_file = "$output_dir_abs/samples.txt";
write_samples($rendered_sample_file, @samples);
my $rendered_common_sh = "$output_dir_abs/common.sh";

my @templates = (
    [ "$template_dir/common.sh", 'common.sh', 'single' ],
    [ "$template_dir/00_star_index.sh", '00_star_index.sh', 'single' ],
    [ "$template_dir/01_fastqc_raw.sh", '01_fastqc_raw.sh', 'array' ],
    [ "$template_dir/02_trim_galore.sh", '02_trim_galore.sh', 'array' ],
    [ "$template_dir/03_star_align.sh", '03_star_align.sh', 'array' ],
    [ "$template_dir/04_samtools_index.sh", '04_samtools_index.sh', 'array' ],
    [ "$template_dir/05_featurecounts.sh", '05_featurecounts.sh', 'single' ],
    [ "$template_dir/06_multiqc.sh", '06_multiqc.sh', 'single' ],
);

for my $template (@templates) {
    my ($input_file, $output_name, $template_type) = @$template;
    render_template(
        input_file   => $input_file,
        output_file  => "$output_dir_abs/$output_name",
        sample_count => scalar @samples,
        project_dir  => $opt{project_dir},
        sample_file  => $rendered_sample_file,
        common_sh    => $rendered_common_sh,
        mail_user    => $opt{mail_user},
        template_type => $template_type,
    );
}

copy_if_missing("$config_dir/pipeline.env.example", "$output_dir_abs/pipeline.env");
copy("$scripts_dir/submit_chain.pl", "$output_dir_abs/submit_chain.pl")
    or die "Failed to copy submit_chain.pl: $!\n";
chmod 0755, "$output_dir_abs/submit_chain.pl"
    or die "Cannot chmod $output_dir_abs/submit_chain.pl: $!\n";

print "Experiment directory created: $output_dir_abs\n";
print "Samples detected: " . scalar(@samples) . "\n";
print "Normalized sample manifest written to: $rendered_sample_file\n";
print "Next steps:\n";
print "  1. Edit $output_dir_abs/pipeline.env\n";
print "  2. Dry-run submission with: perl $output_dir_abs/submit_chain.pl --experiment-dir $output_dir_abs --dry-run\n";

sub usage {
    return <<"USAGE";
Usage:
  perl scripts/generate_experiment.pl --project-dir PATH --sample-file FILE --experiment NAME [options]

Options:
  --project-dir PATH   Analysis directory where workflow outputs will be written
  --analysis-dir PATH  Alias for --project-dir
  --sample-file FILE   Plain-text file with one sample ID per line
  --experiment NAME    Name of the generated experiment directory
  --mail-user EMAIL    Email for Slurm END/FAIL notifications
  --output-dir PATH    Output directory for the generated scripts (defaults to experiment name)
  --repo-root PATH     Override repo root discovery
  --help               Show this message
USAGE
}

sub prompt {
    my ($message, $allow_empty) = @_;
    while (1) {
        print $message;
        my $value = <STDIN>;
        if (!defined $value) {
            return '' if $allow_empty;
            next;
        }
        chomp($value);
        return $value if $allow_empty || $value ne '';
    }
}

sub read_samples {
    my ($sample_file) = @_;
    open my $fh, '<', $sample_file or die "Cannot open $sample_file: $!\n";

    my @samples;
    my %seen;
    my $line_number = 0;
    while (my $line = <$fh>) {
        $line_number++;
        chomp $line;
        $line =~ s/\r$//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        next if $line =~ /^\s*$/;
        next if $line =~ /^\s*#/;
        die "Unsafe sample ID at $sample_file line $line_number: $line\n"
            if $line !~ /\A[A-Za-z0-9][A-Za-z0-9._-]*\z/;
        die "Duplicate sample ID at $sample_file line $line_number: $line\n"
            if $seen{$line}++;
        push @samples, $line;
    }

    close $fh;
    return @samples;
}

sub write_samples {
    my ($path, @samples) = @_;
    open my $fh, '>', $path or die "Cannot write $path: $!\n";
    print {$fh} "$_\n" for @samples;
    close $fh or die "Cannot close $path: $!\n";
}

sub shell_single_quote {
    my ($text) = @_;
    $text =~ s/'/'"'"'/g;
    return "'$text'";
}

sub render_template {
    my (%args) = @_;

    open my $in, '<', $args{input_file} or die "Cannot open $args{input_file}: $!\n";
    my @content = <$in>;
    close $in;

    my $project_q = shell_single_quote($args{project_dir});
    my $sample_q  = shell_single_quote($args{sample_file});
    my $common_q  = shell_single_quote($args{common_sh});

    my @replacement;

    if (defined $args{mail_user} && $args{mail_user} ne '') {
        push @replacement,
            "#SBATCH --mail-type=END,FAIL\n",
            "#SBATCH --mail-user=$args{mail_user}\n";
    }

    if ($args{template_type} eq 'array') {
        push @replacement, "#SBATCH --array=1-$args{sample_count}%$args{sample_count}\n";
    }

    push @replacement,
        "projPath=$project_q\n",
        "sample_file=$sample_q\n",
        "common_sh=$common_q\n";

    if ($args{template_type} eq 'array') {
        push @replacement,
            'sample="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$sample_file")"' . "\n",
            'sample="$(printf "%s" "$sample" | tr -d "\r")"' . "\n",
            '[[ -n "$sample" ]] || { echo "No sample found for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}" >&2; exit 1; }' . "\n";
    }

    my @rendered;
    for my $line (@content) {
        if ($line =~ /#__RNASEQ_GENERATED_CONFIG__/) {
            push @rendered, @replacement;
        } else {
            push @rendered, $line;
        }
    }

    open my $out, '>', $args{output_file} or die "Cannot write $args{output_file}: $!\n";
    print {$out} @rendered;
    close $out;
    chmod 0755, $args{output_file} or die "Cannot chmod $args{output_file}: $!\n";
}

sub copy_if_missing {
    my ($source, $dest) = @_;
    return if -e $dest;
    copy($source, $dest) or die "Failed to copy $source to $dest: $!\n";
}
