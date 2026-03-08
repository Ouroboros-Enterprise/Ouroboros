<?php

namespace NeuralNet\Losses;

use NeuralNet\Math\Matrix;

interface LossInterface
{
    /**
     * Calculate the loss (error) between predicted and true values.
     * @param Matrix $predicted
     * @param Matrix $true
     * @return float
     */
    public function calculate(Matrix $predicted, Matrix $true): float;

    /**
     * Calculate the derivative of the loss with respect to the predictions.
     * @param Matrix $predicted
     * @param Matrix $true
     * @return Matrix
     */
    public function derivative(Matrix $predicted, Matrix $true): Matrix;
}
