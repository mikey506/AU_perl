#!/usr/bin/perl
use strict;
use warnings;
use Encode qw(decode encode FB_CROAK);

my $input_file  = "messages.csv";
my $output_file = "cleaned_messages.csv";
my $log_file    = "decode_errors.log";

# Open files
open my $in,  "<:raw", $input_file  or die "Cannot open $input_file: $!";
open my $out, ">:utf8", $output_file or die "Cannot write to $output_file: $!";
open my $log, ">:utf8", $log_file    or die "Cannot write to $log_file: $!";

while (my $line = <$in>) {
    chomp $line;
    my $decoded_line;

    # Attempt to decode
    eval {
        $decoded_line = decode("UTF-8", $line, FB_CROAK); # Strict UTF-8 decoding
    };

    if ($@) {
        print $log "Failed to decode line: $line\nError: $@\n";
        # Fallback to ISO-8859-1 or ASCII-safe replacement
        $decoded_line = eval { decode("ISO-8859-1", $line) } || $line;
        $decoded_line =~ s/[^\x00-\x7F]/?/g; # Replace non-ASCII with '?'
        print $log "Cleaned line: $decoded_line\n";
    }

    print $out encode("UTF-8", $decoded_line), "\n";
}

close $in;
close $out;
close $log;
print "Processing complete. Cleaned data written to $output_file\n";
