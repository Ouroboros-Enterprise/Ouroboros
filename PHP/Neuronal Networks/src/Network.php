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

    public function train(array $trainingData, int $epochs, float $learningRate, float $lrDecay = 0.0): void
    {
        if (!$this->lossFunction) {
            throw new \Exception("Loss function not set.");
        }

        $startTime = microtime(true);

        for ($epoch = 0; $epoch < $epochs; $epoch++) {
            $totalLoss = 0;
            $correct = 0;

            // Exponential learning rate decay: lr = lr0 * e^(-lrDecay * epoch/epochs)
            $currentLr = $lrDecay > 0
                ? $learningRate * exp(-$lrDecay * ($epoch / $epochs))
                : $learningRate;

            // Simple SGD (iterating through each example)
            foreach ($trainingData as $data) {
                $input = Matrix::fromArray($data['input']);
                $target = Matrix::fromArray($data['target']);

                // Forward pass
                $output = $this->forward($input);

                // Calculate Loss
                $totalLoss += $this->lossFunction->calculate($output, $target);

                // Check accuracy: does argmax(output) == argmax(target)?
                $predMax = 0; $trueMax = 0;
                $predProb = PHP_FLOAT_MIN; $trueProb = PHP_FLOAT_MIN;
                foreach ($output->data as $i => $row) {
                    if ($row[0] > $predProb) { $predProb = $row[0]; $predMax = $i; }
                }
                foreach ($target->data as $i => $row) {
                    if ($row[0] > $trueProb) { $trueProb = $row[0]; $trueMax = $i; }
                }
                if ($predMax === $trueMax) $correct++;

                // Backward pass
                $errorGradient = $this->lossFunction->derivative($output, $target);
                $this->backward($errorGradient, $currentLr);
            }

            // Print progress every 100 epochs
            if (($epoch + 1) % 100 === 0 || $epoch === 0) {
                $avgLoss = $totalLoss / count($trainingData);
                $accuracy = round(($correct / count($trainingData)) * 100, 1);
                $elapsed = microtime(true) - $startTime;
                $pct = (int)(($epoch + 1) / $epochs * 30);
                $bar = str_repeat('█', $pct) . str_repeat('░', 30 - $pct);

                // Safe time formatting: cap floats to avoid int overflow warning
                $toTime = static function (float $secs): string {
                    $s = min($secs, 86399.0); // cap at 24h
                    return sprintf('%dm %02ds', (int)($s / 60), (int)fmod($s, 60.0));
                };

                $elapsedStr = $toTime($elapsed);
                if ($elapsed > 0 && $epoch > 0) {
                    $remaining = ($epochs - ($epoch + 1)) * ($elapsed / ($epoch + 1));
                    $etaStr = $remaining > 0 ? $toTime($remaining) : 'done';
                } else {
                    $etaStr = '?';
                }

                echo "\r[{$bar}] Epoch " . ($epoch + 1) . "/{$epochs}"
                    . "  Loss: " . number_format($avgLoss, 6)
                    . "  Acc: {$accuracy}%"
                    . "  LR: " . number_format($currentLr, 5)
                    . "  Elapsed: {$elapsedStr}  ETA: {$etaStr}  ";
                flush();
            }
        }
        echo "\n";
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
