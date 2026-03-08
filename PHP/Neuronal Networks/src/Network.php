<?php

namespace NeuralNet;

use NeuralNet\Layers\LayerInterface;
use NeuralNet\Losses\LossInterface;
use NeuralNet\Math\Matrix;

class Network
{
    /** @var LayerInterface[] */
    protected array $layers = [];
    protected ?LossInterface $lossFunction = null;

    public function addLayer(LayerInterface $layer): void
    {
        $this->layers[] = $layer;
    }

    public function setLossFunction(LossInterface $loss): void
    {
        $this->lossFunction = $loss;
    }

    public function forward(Matrix $input): Matrix
    {
        $output = $input;
        foreach ($this->layers as $layer) {
            $output = $layer->forward($output);
        }
        return $output;
    }

    public function backward(Matrix $outputGradient, float $learningRate): void
    {
        $gradient = $outputGradient;
        // Backprop: iterate backwards through layers
        for ($i = count($this->layers) - 1; $i >= 0; $i--) {
            $gradient = $this->layers[$i]->backward($gradient, $learningRate);
        }
    }

    public function predict(array $inputArray): array
    {
        $input = Matrix::fromArray($inputArray);
        $output = $this->forward($input);
        return $output->toArray();
    }

    public function train(array $trainingData, int $epochs, float $learningRate): void
    {
        if (!$this->lossFunction) {
            throw new \Exception("Loss function not set.");
        }

        for ($epoch = 0; $epoch < $epochs; $epoch++) {
            $totalLoss = 0;

            // Simple SGD (iterating through each example)
            foreach ($trainingData as $data) {
                // Determine structure (e.g., associative array with 'input' and 'target')
                $input = Matrix::fromArray($data['input']);
                $target = Matrix::fromArray($data['target']);

                // Forward pass
                $output = $this->forward($input);

                // Calculate Loss
                $totalLoss += $this->lossFunction->calculate($output, $target);

                // Backward pass
                $errorGradient = $this->lossFunction->derivative($output, $target);
                $this->backward($errorGradient, $learningRate);
            }

            // Print progress
            if (($epoch + 1) % 1000 === 0) {
                echo "Epoch " . ($epoch + 1) . " / $epochs - Loss: " . ($totalLoss / count($trainingData)) . "\n";
            }
        }
    }

    public function save(string $filepath): void
    {
        file_put_contents($filepath, serialize($this));
    }

    public static function load(string $filepath): self
    {
        if (!file_exists($filepath)) {
            throw new \Exception("Model file not found.");
        }
        return unserialize(file_get_contents($filepath));
    }
}
