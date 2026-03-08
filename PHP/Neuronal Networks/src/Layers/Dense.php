<?php

namespace NeuralNet\Layers;

use NeuralNet\Math\Matrix;
use NeuralNet\Activations\ActivationInterface;

class Dense implements LayerInterface
{
    public Matrix $weights;
    public Matrix $biases;
    public ?ActivationInterface $activation;

    // Cache for backpropagation
    protected Matrix $inputCache;
    protected Matrix $outputCache;
    protected Matrix $activationCache;

    public function __construct(int $inputSize, int $outputSize, ?ActivationInterface $activation = null)
    {
        $this->weights = new Matrix($outputSize, $inputSize);
        // Initialize weights with values between -1 and 1
        $this->weights->randomize(-1.0, 1.0);

        $this->biases = new Matrix($outputSize, 1);
        $this->biases->randomize(-1.0, 1.0);

        $this->activation = $activation;
    }

    public function forward(Matrix $input): Matrix
    {
        $this->inputCache = $input;

        // Output = Weights * Input + Biases
        $this->outputCache = $this->weights->multiply($input)->add($this->biases);

        if ($this->activation) {
            $this->activationCache = $this->activation->forward($this->outputCache);
            return $this->activationCache;
        }

        return $this->outputCache;
    }

    public function backward(Matrix $outputGradient, float $learningRate): Matrix
    {
        // 1. If we have an activation, apply the derivative of the activation function
        if ($this->activation) {
             // We need to multiply the output gradient by the derivative of the activation function applied to the layer's output
             $activationDerivative = $this->activation->derivative($this->activationCache);
             $outputGradient = $outputGradient->multiplyElementWise($activationDerivative);
        }

        // 2. Calculate weight gradients
        // dW = outputGradient * input^T
        $inputTranspose = $this->inputCache->transpose();
        $weightGradients = $outputGradient->multiply($inputTranspose);

        // 3. Calculate input gradient (to pass to previous layer)
        // dInput = weights^T * outputGradient
        $weightsTranspose = $this->weights->transpose();
        $inputGradient = $weightsTranspose->multiply($outputGradient);

        // 4. Update the layer parameters (weights and biases)
        // W = W - learningRate * dW
        // B = B - learningRate * dB (dB is just outputGradient)
        $learningRateMatrix = $weightGradients->multiplyScalar($learningRate);
        $this->weights = $this->weights->subtract($learningRateMatrix);

        $learningRateBiasMatrix = $outputGradient->multiplyScalar($learningRate);
        $this->biases = $this->biases->subtract($learningRateBiasMatrix);

        return $inputGradient;
    }
}
