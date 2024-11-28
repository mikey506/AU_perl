package AI::Tokenizer;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    return bless { model_name => $args{model_name} }, $class;
}

sub tokenize {
    my ($self, $text) = @_;
    return [split /\s+/, $text];
}

1;
