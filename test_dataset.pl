#!/usr/bin/perl
use strict;
use warnings;

use lib './modules';    # Add the modules directory to @INC
use AI::Dataset;
use Getopt::Long;
use Time::HiRes qw(time); # Import `time` for precise time measurement

# Command-line arguments
my $csv_file = "";

GetOptions(
    "csv_file=s" => \$csv_file,
);

# Ensure the CSV file is provided
if (!$csv_file) {
    die "Usage: perl test_dataset.pl --csv_file=<path_to_csv_file>\n";
}

# Check if the specified file exists
unless (-e $csv_file) {
    die "Error: File '$csv_file' does not exist.\n";
}

print "Loading dataset from '$csv_file'...\n";
my $start_time = time();

# Initialize dataset
my $dataset = AI::Dataset->new();

# Load CSV
eval {
    $dataset->load_csv($csv_file);
};
if ($@) {
    die "Error loading CSV file: $@\n";
}

# Display dataset details
print "\nDataset successfully loaded!\n";

# Get the number of samples in the dataset
my $num_records = $dataset->count(); # Use the `count` method in AI::Dataset
print "Dataset contains $num_records records.\n";

# Get and display column names
my @columns = $dataset->get_columns(); # Use `get_columns` method in AI::Dataset
print "Columns: ", join(", ", @columns), "\n";

# Display a preview of the dataset (manual implementation)
if ($num_records > 0) {
    print "\nPreviewing the first few rows of the dataset:\n";
    my $data = $dataset->get_data();
    for my $i (0 .. 4) {    # Show the first 5 rows (if available)
        last if $i >= @$data; # Break if there are fewer than 5 rows
        my $row = $data->[$i];
        print join(", ", map { defined $row->{$_} ? $row->{$_} : "NULL" } @columns), "\n";
    }
} else {
    print "The dataset is empty.\n";
}

# Preprocessing function
print "\nStarting preprocessing...\n";
eval {
    $dataset->preprocess(sub {
        my ($row) = @_;

        # Add message length or handle empty messages
        if (!$row->{msg} || $row->{msg} eq '') {
            $row->{msg} = "EMPTY MESSAGE";
        } else {
            $row->{msg} =~ s/^\s+|\s+$//g;    # Trim leading/trailing spaces
            $row->{length} = length($row->{msg});
        }
        return $row;
    });
};
if ($@) {
    die "Error during preprocessing: $@\n";
}

print "Preprocessing completed!\n";

# Display preprocessed data (manual implementation)
if ($num_records > 0) {
    print "\nPreview of preprocessed data:\n";
    my $data = $dataset->get_data();
    for my $i (0 .. 4) {    # Show the first 5 rows (if available)
        last if $i >= @$data; # Break if there are fewer than 5 rows
        my $row = $data->[$i];
        print join(", ", map { defined $row->{$_} ? $row->{$_} : "NULL" } (@columns, 'length')), "\n";
    }
} else {
    print "No data to preview after preprocessing.\n";
}

my $elapsed_time = time() - $start_time;
printf("\nTotal time taken: %.2f seconds\n", $elapsed_time);
