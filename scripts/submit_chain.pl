#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(basename);
use Getopt::Long qw(GetOptions);

my %opt = (
    experiment_dir => '.',
    sbatch_cmd     => 'sbatch',
    sbatch_args    => [],
    dry_run        => 0,
);

GetOptions(
    'experiment-dir=s' => \$opt{experiment_dir},
    'sbatch-cmd=s'     => \$opt{sbatch_cmd},
    'sbatch-arg=s@'    => \$opt{sbatch_args},
    'dry-run'          => \$opt{dry_run},
    'help'             => \$opt{help},
) or die usage();

if ($opt{help}) {
    print usage();
    exit 0;
}

my $dir = abs_path($opt{experiment_dir})
    or die "Experiment directory not found: $opt{experiment_dir}\n";

opendir my $dh, $dir or die "Cannot open directory $dir: $!\n";
my @candidates = sort {
    step_number($a) <=> step_number($b) || basename($a) cmp basename($b)
} map {
    "$dir/$_"
} grep {
    /^\d+_.*\.sh$/
} readdir $dh;
closedir $dh;

die "No numbered step scripts found in $dir\n" if !@candidates;

my $previous_job_id = '';
my $dry_run_job_id = 0;

for my $script (@candidates) {
    my @cmd = ($opt{sbatch_cmd}, @{$opt{sbatch_args}});
    push @cmd, "--dependency=afterok:$previous_job_id" if $previous_job_id ne '';
    push @cmd, $script;

    if ($opt{dry_run}) {
        print join(' ', @cmd), "\n";
        $dry_run_job_id++;
        $previous_job_id = "DRYRUN$dry_run_job_id";
        next;
    }

    print "Submitting:";
    print " $_" for @cmd;
    print "\n";
    my ($output, $exit_code) = capture_command(@cmd);
    die "Failed to submit $script\n$output" if $exit_code != 0;

    if ($output =~ /Submitted batch job (\d+)/) {
        my $current_job_id = $1;
        if ($previous_job_id eq '') {
            print "Submitted $script as job $current_job_id\n";
        } else {
            print "Submitted $script as job $current_job_id after $previous_job_id\n";
        }
        $previous_job_id = $current_job_id;
    } else {
        die "Could not parse sbatch output for $script\n$output";
    }
}

print "Done.\n" if !$opt{dry_run};

sub usage {
    return <<"USAGE";
Usage:
  perl submit_chain.pl [--experiment-dir PATH] [--dry-run] [--sbatch-cmd CMD]

Options:
  --experiment-dir PATH  Directory that contains generated numbered step scripts
  --dry-run              Print commands without submitting
  --sbatch-cmd CMD       Override the sbatch executable name
  --sbatch-arg ARG       Extra argument to pass to sbatch (repeatable)
  --help                 Show this message
USAGE
}

sub step_number {
    my ($path) = @_;
    my $name = basename($path);
    $name =~ /^(\d+)_/ or return 10_000;
    return $1;
}

sub capture_command {
    my @cmd = @_;

    open my $fh, '-|', @cmd or die "Failed to execute @cmd: $!\n";
    local $/;
    my $output = <$fh>;
    my $closed = close $fh;
    my $exit_code = $closed ? 0 : ($? >> 8);
    return ($output // '', $exit_code);
}
