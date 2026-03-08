<?php

namespace NeuralNet\Activations;

use NeuralNet\Math\Matrix;

interface ActivationInterface
{
    /**
     * Apply the activation function.
     * @param Matrix $input
     * @return Matrix
     */
    public function forward(Matrix $input): Matrix;

    /**
     * Calculate the derivative of the activation function.
     * @param Matrix $input The output of the activation function from the forward pass
     * @return Matrix
     */
    public function derivative(Matrix $input): Matrix;
}
