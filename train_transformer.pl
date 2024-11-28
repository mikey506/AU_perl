#!/usr/bin/perl
use strict;
use warnings;

use lib './modules'; # Add the modules directory to @INC
use AI::Transformer;

# Initialize transformer model
my $model = AI::Transformer->new(model_name => "mock-transformer");

# Training loop
for my $step (1..5) {
    my $input = [1, 2, 3];  # Mock input
    my $target = 100;       # Mock target output
    my $loss = $model->train_step(input => $input, target => $target);
    print "Training Step $step, Loss: $loss\n";
}

# Save model
$model->save("mock_model.dat");

# Load model
my $loaded_model = AI::Transformer->load("mock_model.dat");

# Print training history
$loaded_model->print_training_history();
