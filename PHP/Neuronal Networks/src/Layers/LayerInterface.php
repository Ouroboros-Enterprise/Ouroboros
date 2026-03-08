<?php

namespace NeuralNet\Layers;

use NeuralNet\Math\Matrix;

interface LayerInterface
{
    /**
     * Perform the forward pass.
     * @param Matrix $input Inputs to the layer
     * @return Matrix Outputs of the layer
     */
    public function forward(Matrix $input): Matrix;

    /**
     * Perform the backward pass (backpropagation).
     * @param Matrix $outputGradient Gradient of the loss with respect to the output of this layer
     * @param float $learningRate The learning rate for optimization
     * @return Matrix Gradient of the loss with respect to the input of this layer
     */
    public function backward(Matrix $outputGradient, float $learningRate): Matrix;
    /**
     * Set an optimizer for this layer
     */
    public function setOptimizer(string $id, \NeuralNet\Optimizers\OptimizerInterface $optimizer): void;

    /**
     * Get the number of trainable parameters in this layer
     */
    public function getParameterCount(): int;
}
