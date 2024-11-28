package AI::Dataset;

use strict;
use warnings;
use Text::CSV;
use Carp qw(croak);

# Constructor
sub new {
    my ($class) = @_;
    my $self = {
        data => [],         # Stores the dataset as an array of hashes
        column_names => [], # Stores column names from the CSV
    };
    bless $self, $class;
    return $self;
}

# Load data from a CSV file
sub load_csv {
    my ($self, $file_path) = @_;

    croak "CSV file path must be provided" unless $file_path;

    # Initialize CSV parser
    my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });

    open my $fh, "<:encoding(utf8)", $file_path or croak "Failed to open '$file_path': $!";

    # Read header row
    my $header = $csv->getline($fh);
    croak "Failed to read header row from '$file_path'" unless $header;
    $self->{column_names} = $header;

    # Read the remaining rows into the dataset
    while (my $row = $csv->getline($fh)) {
        my %record;
        @record{@{$self->{column_names}}} = @$row; # Map header to row values
        push @{$self->{data}}, \%record;
    }
    close $fh;

    return $self;
}

# Get the number of records in the dataset
sub count {
    my ($self) = @_;
    return scalar @{$self->{data}};
}

# Get all data
sub get_data {
    my ($self) = @_;
    return $self->{data};
}

# Get column names
sub get_columns {
    my ($self) = @_;
    return @{$self->{column_names}};
}

# Preprocess the dataset
sub preprocess {
    my ($self, $callback) = @_;
    croak "Preprocessing callback must be provided" unless ref $callback eq 'CODE';

    foreach my $record (@{$self->{data}}) {
        eval {
            $callback->($record);
        };
        if ($@) {
            warn "Error during preprocessing: $@";
        }
    }
    return $self;
}

1;

__END__

=head1 NAME

AI::Dataset - A module for loading and processing datasets.

=head1 SYNOPSIS

  use AI::Dataset;

  # Create a new dataset object
  my $dataset = AI::Dataset->new();

  # Load a dataset from a CSV file
  $dataset->load_csv('data.csv');

  # Get the number of records
  my $num_records = $dataset->count();

  # Get column names
  my @columns = $dataset->get_columns();

  # Preprocess the data
  $dataset->preprocess(sub {
      my ($record) = @_;
      $record->{column_name} = uc($record->{column_name}) if exists $record->{column_name};
  });

=head1 METHODS

=over 4

=item * C<new> - Create a new dataset object.

=item * C<load_csv($file_path)> - Load a dataset from a CSV file.

=item * C<count> - Get the number of records in the dataset.

=item * C<get_data> - Retrieve all records as an array reference.

=item * C<get_columns> - Retrieve the column names from the dataset.

=item * C<preprocess($callback)> - Apply a callback to each record in the dataset.

=back

=head1 AUTHOR

Your Name

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
