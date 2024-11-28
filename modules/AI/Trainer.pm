package AI::Trainer;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    return bless \%args, $class;
}

sub train {
    my ($self, $callback) = @_;
    return $callback->();
}

sub evaluate {
    my ($self, $callback) = @_;
    return $callback->();
}

1;
