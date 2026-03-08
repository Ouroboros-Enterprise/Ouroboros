<?php

namespace NeuralNet\Activations;

use NeuralNet\Math\Matrix;

class Softmax implements ActivationInterface
{
    public function forward(Matrix $input): Matrix
    {
        // Subtract max for numerical stability (prevent exponential overflow)
        $max = PHP_FLOAT_MIN;
        for ($i = 0; $i < $input->rows; $i++) {
            for ($j = 0; $j < $input->cols; $j++) {
                if ($input->data[$i][$j] > $max) {
                    $max = $input->data[$i][$j];
                }
            }
        }

        $sum = 0;
        $expMatrix = new Matrix($input->rows, $input->cols);

        for ($i = 0; $i < $input->rows; $i++) {
            for ($j = 0; $j < $input->cols; $j++) {
                $val = exp($input->data[$i][$j] - $max);
                $expMatrix->data[$i][$j] = $val;
                $sum += $val;
            }
        }

        // Divide by sum
        return $expMatrix->map(function ($val) use ($sum) {
            return $val / $sum;
        });
    }

    public function derivative(Matrix $input): Matrix
    {
        // Note: When used together with Categorical Cross Entropy Loss, 
        // the explicit derivative calculation for Softmax is complex and often unnecessary.
        // We typically handle the gradient combining Softmax + CCE directly in the loss function.
        // For interface compliance, we return the gradient assuming it's used independently (which is rare).
        
        // As a quick workaround for this simple framework:
        // We assume the true gradient handling happens at the Loss+Softmax combination.
        // If backward passes here individually, we return 1s so it doesn't break the chain. 
        // We will implement `CategoricalCrossEntropy` to feed the *already computed* gradient back.
        $result = new Matrix($input->rows, $input->cols);
        for ($i = 0; $i < $input->rows; $i++) {
            for ($j = 0; $j < $input->cols; $j++) {
                $result->data[$i][$j] = 1.0;
            }
        }
        return $result;
    }
}
