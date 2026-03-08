<?php

namespace NeuralNet\Activations;

use NeuralNet\Math\Matrix;

class Sigmoid implements ActivationInterface
{
    public function forward(Matrix $input): Matrix
    {
        return $input->map(function ($val) {
            return 1 / (1 + exp(-$val));
        });
    }

    public function derivative(Matrix $input): Matrix
    {
        // Derivative of sigmoid is s * (1 - s), where s is the output of the sigmoid function.
        // Assuming $input is the OUTPUT of the forward pass!
        return $input->map(function ($val) {
            return $val * (1 - $val);
        });
    }
}
