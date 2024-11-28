#!/usr/bin/perl
use strict;
use warnings;

use lib './modules'; # Add the modules directory to @INC
use AI::Tokenizer;
use AI::Dataset;
use AI::Trainer;
use Getopt::Long;
use Encode qw(decode encode);
use Time::HiRes qw(gettimeofday tv_interval);
use Term::ProgressBar; # For progress bar
use open ':std', ':encoding(utf8)'; # Set UTF-8 as default for input/output

# Command-line arguments
my ($csv_file, $batch_size, $model_name) = ("", 2, "mock-tokenizer");

GetOptions(
    "csv_file=s"   => \$csv_file,
    "batch_size=i" => \$batch_size,
    "model_name=s" => \$model_name,
);

die "Usage: perl train_model.pl --csv_file=<path_to_csv_file> [--batch_size=<batch_size>] [--model_name=<model_name>]\n"
    unless $csv_file;

print "Starting script with file '$csv_file', batch size '$batch_size', and model '$model_name'.\n";

# Initialize tokenizer
print "Initializing tokenizer...\n";
my $tokenizer = AI::Tokenizer->new(model_name => $model_name);

# Load dataset
print "Loading dataset...\n";
my $dataset = AI::Dataset->new();
$dataset->load_csv($csv_file);

# Decode and preprocess the dataset
print "Preprocessing dataset...\n";
my $previous_msg;
$dataset->preprocess(sub {
    my ($sample) = @_;

    unless (defined $sample->{msg} && $sample->{msg} ne '') {
        warn "Skipping invalid row with missing or empty message.\n";
        return;
    }

    eval {
        $sample->{msg} = decode('UTF-8', $sample->{msg});
    };
    if ($@) {
        warn "Failed to decode message: $@\n";
        $sample->{msg} = "INVALID MESSAGE";
    }

    if (defined $previous_msg) {
        $sample->{prompt} = $previous_msg->{msg};
        $sample->{response} = $sample->{msg};
    }

    $previous_msg = $sample;
});

# Initialize trainer
print "Initializing trainer...\n";
my $trainer = AI::Trainer->new(
    model         => undef,
    tokenizer     => $tokenizer,
    train_dataset => $dataset,
    batch_size    => $batch_size,
);

# Training process
print "Starting training...\n";
my $data = $dataset->get_data();
my $total_samples = scalar(@$data);
my $progress = Term::ProgressBar->new({ count => $total_samples, name => 'Training Progress' });
my $start_time = [gettimeofday];

for my $i (0 .. $#$data) {
    my $sample = $data->[$i];
    unless (defined $sample->{prompt} && defined $sample->{response}) {
        warn "Skipping sample with undefined prompt or response at index $i.\n";
        next;
    }

    $trainer->train(sub {
        return 0.1; # Simulated loss
    });

    $progress->update($i + 1);

    if (($i + 1) % 10 == 0 || $i == $total_samples - 1) {
        print "\nIteration ", $i + 1, "/", $total_samples, " completed.\n";
        print "Current Sample:\n";
        print "Prompt: ", encode('UTF-8', $sample->{prompt}), "\n";
        print "Response: ", encode('UTF-8', $sample->{response}), "\n";
    }
}

my $elapsed = tv_interval($start_time);
print "\nTraining complete! Total time: ${elapsed}s.\n";
