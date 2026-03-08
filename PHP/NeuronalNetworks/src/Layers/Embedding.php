<?php

namespace NeuralNet\Layers;

use NeuralNet\Math\Matrix;

/**
 * Embedding Layer
 * Converts a sequence of token IDs into a sequence of dense vectors.
 * Optimization: Instead of multiplying a Huge One-Hot vector by a Weight Matrix (SGD dot product),
 * we directly look up the column in the embedding matrix.
 */
class Embedding implements LayerInterface
{
    public Matrix $weights;
    public ?\NeuralNet\Optimizers\OptimizerInterface $optimizer = null;
    public string $layerId = '';
    
    private int $vocabSize;
    private int $embeddingDim;
    
    // Cache for backpropagation
    private array $inputIds = [];

    public function __construct(int $vocabSize, int $embeddingDim)
    {
        $this->vocabSize = $vocabSize;
        $this->embeddingDim = $embeddingDim;
        
        // Rows = Dimension of embedding, Cols = Vocabulary Size
        $this->weights = new Matrix($embeddingDim, $vocabSize);
        $this->weights->randomize(-1.0, 1.0);
    }

    public function setOptimizer(string $id, \NeuralNet\Optimizers\OptimizerInterface $optimizer): void
    {
        $this->layerId = $id;
        $this->optimizer = $optimizer;
    }

    /**
     * @param Matrix $input Excepted to be a 1x1 Matrix containing an array of IDs in $data[0][0]
     * or a Matrix where each row is a sample if we support batches. 
     * For now, $input->data is [ [ [id1, id2, id3, ...] ] ]
     */
    public function forward($input): Matrix
    {
        // Extract sequence of IDs
        if ($input instanceof Matrix) {
            $this->inputIds = is_array($input->data[0][0]) ? $input->data[0][0] : [$input->data[0][0]];
        } else {
            $this->inputIds = $input;
        }

        $outputSequence = [];
        foreach ($this->inputIds as $id) {
            $embedding = new Matrix($this->embeddingDim, 1);
            for ($i = 0; $i < $this->embeddingDim; $i++) {
                $embedding->data[$i][0] = $this->weights->data[$i][$id];
            }
            // Store the Matrix objects
            $outputSequence[] = $embedding;
        }

        // Return a "wrapper" Matrix where data[0] is our sequence
        return new Matrix(count($outputSequence), 1, [$outputSequence]);
    }

    public function backward(Matrix $outputGradient, float $learningRate): Matrix
    {
        // outputGradient is a Matrix [SeqLength x EmbeddingDim]
        $gradData = $outputGradient->data;
        $dW = new Matrix($this->embeddingDim, $this->vocabSize);
        
        foreach ($this->inputIds as $t => $id) {
            for ($i = 0; $i < $this->embeddingDim; $i++) {
                // Gradient for specific embedding vector at time t
                $dW->data[$i][$id] += $gradData[$t][$i];
            }
        }

        if ($this->optimizer) {
            // Biases are effectively not used or zero for embedding
            $dummyBiases = new Matrix($this->embeddingDim, 1);
            $dummyBiasGradients = new Matrix($this->embeddingDim, 1);
            $this->optimizer->update($this->layerId, $this->weights, $dW, $dummyBiases, $dummyBiasGradients, $learningRate);
        } else {
            $this->weights = $this->weights->subtract($dW->multiplyScalar($learningRate));
        }

        // Embedding layer is usually the first layer, returning zero gradient for input
        return new Matrix(1, 1); 
    }

    public function getParameterCount(): int
    {
        return $this->weights->rows * $this->weights->cols;
    }
}
