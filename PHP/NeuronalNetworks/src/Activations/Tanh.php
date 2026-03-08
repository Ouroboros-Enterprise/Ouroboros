<?php

namespace NeuralNet\Activations;

use NeuralNet\Math\Matrix;

class Tanh implements ActivationInterface
{
    public function forward(Matrix $input): Matrix
    {
        return $input->map(function ($val) {
            return tanh($val);
        });
    }

    public function derivative(Matrix $output): Matrix
    {
        // d/dx tanh(x) = 1 - tanh(x)^2
        // Since $output is already tanh(x), we do 1 - output^2
        return $output->map(function ($val) {
            return 1.0 - $val * $val;
        });
    }
}
