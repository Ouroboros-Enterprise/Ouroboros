<?php

namespace NeuralNet\Losses;

use NeuralNet\Math\Matrix;

class MSE implements LossInterface
{
    public function calculate(Matrix $predicted, Matrix $true): float
    {
        $loss = 0;
        for ($i = 0; $i < $predicted->rows; $i++) {
            for ($j = 0; $j < $predicted->cols; $j++) {
                $diff = $true->data[$i][$j] - $predicted->data[$i][$j];
                $loss += pow($diff, 2);
            }
        }
        return $loss / ($predicted->rows * $predicted->cols);
    }

    public function derivative(Matrix $predicted, Matrix $true): Matrix
    {
        // For backprop: 2 * (predicted - true) / N
        $n = $predicted->rows * $predicted->cols;
        return $predicted->map(function($val, $i, $j) use ($true, $n) {
            return 2 * ($val - $true->data[$i][$j]) / $n;
        });
    }
}
