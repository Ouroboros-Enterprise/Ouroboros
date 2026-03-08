<?php

namespace NeuralNet\Optimizers;

use NeuralNet\Math\Matrix;

class Adam implements OptimizerInterface
{
    private float $beta1;
    private float $beta2;
    private float $epsilon;
    private int $t = 0;

    // State for each layer: [ 'layerId' => [ 'm_w' => Matrix, 'v_w' => Matrix, ... ] ]
    private array $state = [];

    public function __construct(float $beta1 = 0.9, float $beta2 = 0.999, float $epsilon = 1e-8)
    {
        $this->beta1 = $beta1;
        $this->beta2 = $beta2;
        $this->epsilon = $epsilon;
    }

    public function update(string $id, Matrix &$weights, Matrix &$weightGradients, Matrix &$biases, Matrix &$biasGradients, float $learningRate): void
    {
        if ($this->t === 0) {
            $this->t = 1;
        }

        if (!isset($this->state[$id])) {
            $this->state[$id] = [
                'm_w' => new Matrix($weights->rows, $weights->cols),
                'v_w' => new Matrix($weights->rows, $weights->cols),
                'm_b' => new Matrix($biases->rows, $biases->cols),
                'v_b' => new Matrix($biases->rows, $biases->cols),
            ];
        }

        $s = &$this->state[$id];

        // Update time step (logic: t should be shared across all updates in an iteration,
        // but for simplicity in this specific architecture where layers are updated sequentially,
        // we can increment once per layer update if we adjust the bias correction accordingly.
        // Usually, t increments once per full backward pass. 
        // We'll manage t externally or handle it carefully here.)
        
        $this->updateParams($weights, $weightGradients, $s['m_w'], $s['v_w'], $learningRate);
        $this->updateParams($biases, $biasGradients, $s['m_b'], $s['v_b'], $learningRate);
    }

    private function updateParams(Matrix &$params, Matrix $gradients, Matrix &$m, Matrix &$v, float $lr): void
    {
        // m = beta1 * m + (1 - beta1) * g
        // v = beta2 * v + (1 - beta2) * g^2
        
        for ($i = 0; $i < $params->rows; $i++) {
            for ($j = 0; $j < $params->cols; $j++) {
                $g = $gradients->data[$i][$j];
                
                $m->data[$i][$j] = $this->beta1 * $m->data[$i][$j] + (1 - $this->beta1) * $g;
                $v->data[$i][$j] = $this->beta2 * $v->data[$i][$j] + (1 - $this->beta2) * ($g * $g);
                
                // Bias correction
                $m_hat = $m->data[$i][$j] / (1 - pow($this->beta1, $this->t));
                $v_hat = $v->data[$i][$j] / (1 - pow($this->beta2, $this->t));
                
                // Update
                $params->data[$i][$j] -= $lr * $m_hat / (sqrt($v_hat) + $this->epsilon);
            }
        }
    }

    public function incrementStep(): void
    {
        $this->t++;
    }
}
