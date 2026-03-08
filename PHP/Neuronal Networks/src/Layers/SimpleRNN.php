<?php

namespace NeuralNet\Layers;

use NeuralNet\Math\Matrix;
use NeuralNet\Activations\ActivationInterface;

/**
 * A simple Recurrent Neural Network (RNN) layer.
 * Processes a sequence and returns the final hidden state.
 */
class SimpleRNN implements LayerInterface
{
    private int $inputSize;
    private int $hiddenSize;
    
    public Matrix $Wx; // Weights for input
    public Matrix $Wh; // Weights for hidden state
    public Matrix $bh; // Biases
    
    public ?ActivationInterface $activation;
    public ?\NeuralNet\Optimizers\OptimizerInterface $optimizer = null;
    public string $layerId = '';

    // Cache for backpropagation
    private array $inputs = [];
    private array $hiddenStates = [];
    private array $outputs = [];

    public function __construct(int $inputSize, int $hiddenSize, ?ActivationInterface $activation = null)
    {
        $this->inputSize = $inputSize;
        $this->hiddenSize = $hiddenSize;
        $this->activation = $activation;

        $this->Wx = new Matrix($hiddenSize, $inputSize);
        $this->Wh = new Matrix($hiddenSize, $hiddenSize);
        $this->bh = new Matrix($hiddenSize, 1);

        $this->Wx->randomize(-0.1, 0.1);
        $this->Wh->randomize(-0.1, 0.1);
        $this->bh->randomize(-0.1, 0.1);
    }

    public function setOptimizer(string $id, \NeuralNet\Optimizers\OptimizerInterface $optimizer): void
    {
        $this->layerId = $id;
        $this->optimizer = $optimizer;
    }

    /**
     * @param Matrix $input Expected to be N x M where N is vocabSize and M is sequence length?
     * No, our Network architecture expects a single vector. 
     * Let's assume input is a vector representing the whole sequence, and we split it.
     */
    public function forward(Matrix $input): Matrix
    {
        // Handling input as a list of vectors (arrays or matrices)
        // Check if input is a wrapper Matrix where data[0] contains the sequence
        if (isset($input->data[0]) && is_array($input->data[0]) && count($input->data[0]) > 0) {
             // If data[0][0] is an array or Matrix, then data[0] is our sequence
             $first = $input->data[0][0];
             if (is_array($first) || $first instanceof Matrix) {
                 $inputList = $input->data[0];
             } else {
                 // It's a single sample vector passed as a row
                 $inputList = [$input->data[0]];
             }
        } else {
             $inputList = $input->data; 
        }

        $this->inputs = [];
        $this->hiddenStates = [-1 => new Matrix($this->hiddenSize, 1)]; 

        $h = $this->hiddenStates[-1];

        foreach ($inputList as $t => $vec) {
            $x = ($vec instanceof Matrix) ? $vec : Matrix::fromArray($vec);
            // Ensure $x is a column vector
            if ($x->rows === 1 && $x->cols > 1) {
                $x = $x->transpose();
            }
            $this->inputs[$t] = $x;

            // h_t = activation(Wx*x + Wh*h_{t-1} + bh)
            $preActivation = $this->Wx->multiply($x)->add($this->Wh->multiply($h))->add($this->bh);
            
            if ($this->activation) {
                $h = $this->activation->forward($preActivation);
            } else {
                $h = $preActivation;
            }
            
            $this->hiddenStates[$t] = $h;
        }

        return $h;
    }

    public function backward(Matrix $outputGradient, float $learningRate): Matrix
    {
        $dWx = new Matrix($this->hiddenSize, $this->inputSize);
        $dWh = new Matrix($this->hiddenSize, $this->hiddenSize);
        $dbh = new Matrix($this->hiddenSize, 1);
        $sequenceLength = count($this->inputs);
        $dInput = new Matrix($sequenceLength, $this->inputSize);
        
        $dhNext = $outputGradient;

        for ($t = $sequenceLength - 1; $t >= 0; $t--) {
            // Gradient through activation
            $h = $this->hiddenStates[$t];
            $dtanh = $this->activation ? $this->activation->derivative($h) : new Matrix($this->hiddenSize, 1, array_fill(0, $this->hiddenSize, [1.0]));
            $da = $dhNext->multiplyElementWise($dtanh);

            // Weights gradients
            $dWx = $dWx->add($da->multiply($this->inputs[$t]->transpose()));
            $dWh = $dWh->add($da->multiply($this->hiddenStates[$t-1]->transpose()));
            $dbh = $dbh->add($da);

            // Gradient for input
            $dx = $this->Wx->transpose()->multiply($da);
            for ($k = 0; $k < $this->inputSize; $k++) {
                $dInput->data[$t][$k] = $dx->data[$k][0];
            }

            // dh_prev for next iteration
            $dhNext = $this->Wh->transpose()->multiply($da);
        }

        // Clip gradients to prevent exploding gradients
        $this->clipGradients($dWx, 1.0);
        $this->clipGradients($dWh, 1.0);
        $this->clipGradients($dbh, 1.0);

        if ($this->optimizer) {
            // Note: Adam needs to handle multiple matrices for RNN (Wx, Wh, b).
            // This requires extending Adam or calling it multiple times with sub-IDs.
            $this->optimizer->update($this->layerId . "_Wx", $this->Wx, $dWx, $this->bh, $dbh, $learningRate);
            // Updating bh twice here... sloppy but let's fix the Adam update method or call it per param.
            // For now, let's just do dWh update separately.
            $dummyBias = new Matrix($this->bh->rows, 1);
            $dummyGrad = new Matrix($this->bh->rows, 1);
            $this->optimizer->update($this->layerId . "_Wh", $this->Wh, $dWh, $dummyBias, $dummyGrad, $learningRate);
        } else {
            $this->Wx = $this->Wx->subtract($dWx->multiplyScalar($learningRate));
            $this->Wh = $this->Wh->subtract($dWh->multiplyScalar($learningRate));
            $this->bh = $this->bh->subtract($dbh->multiplyScalar($learningRate));
        }

        return $dInput;
    }

    private function clipGradients(Matrix $m, float $limit): void
    {
        for ($i = 0; $i < $m->rows; $i++) {
            for ($j = 0; $j < $m->cols; $j++) {
                $m->data[$i][$j] = max(-$limit, min($limit, $m->data[$i][$j]));
            }
        }
    }

    public function getParameterCount(): int
    {
        return ($this->Wx->rows * $this->Wx->cols) + ($this->Wh->rows * $this->Wh->cols) + ($this->bh->rows * $this->bh->cols);
    }
}
