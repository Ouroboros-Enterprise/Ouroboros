<?php

namespace NeuralNet\Losses;

use NeuralNet\Math\Matrix;

class CategoricalCrossEntropy implements LossInterface
{
    public function calculate(Matrix $predicted, Matrix $true): float
    {
        $loss = 0;
        $epsilon = 1e-9; // Avoid log(0)
        
        for ($i = 0; $i < $predicted->rows; $i++) {
            for ($j = 0; $j < $predicted->cols; $j++) {
                $loss -= $true->data[$i][$j] * log($predicted->data[$i][$j] + $epsilon);
            }
        }
        
        return $loss / $predicted->cols; // Batch average, though we use cols=1 often
    }

    public function derivative(Matrix $predicted, Matrix $true): Matrix
    {
        // The combined derivative of Softmax + Categorical Cross Entropy is remarkably simple:
        // dL/dz = predicted - true
        
        $result = new Matrix($predicted->rows, $predicted->cols);
        for ($i = 0; $i < $predicted->rows; $i++) {
            for ($j = 0; $j < $predicted->cols; $j++) {
                $result->data[$i][$j] = $predicted->data[$i][$j] - $true->data[$i][$j];
            }
        }
        
        return $result;
    }
}
