<?php

namespace NeuralNet\Optimizers;

use NeuralNet\Math\Matrix;

interface OptimizerInterface
{
    /**
     * Update weights and biases of a layer
     */
    public function update(string $id, Matrix &$weights, Matrix &$weightGradients, Matrix &$biases, Matrix &$biasGradients, float $learningRate): void;
}
