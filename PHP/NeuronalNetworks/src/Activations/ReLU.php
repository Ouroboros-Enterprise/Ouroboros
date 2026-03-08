<?php

namespace NeuralNet\Activations;

use NeuralNet\Math\Matrix;

class ReLU implements ActivationInterface
{
    public function forward(Matrix $input): Matrix
    {
        return $input->map(function ($val) {
            return max(0, $val);
        });
    }

    public function derivative(Matrix $input): Matrix
    {
        return $input->map(function ($val) {
            return $val > 0 ? 1 : 0;
        });
    }
}
