<?php

require_once __DIR__ . '/../../autoload.php';
ini_set('memory_limit', '512M'); 

use NeuralNet\Network;
use NeuralNet\Layers\Dense;
use NeuralNet\Activations\ReLU;
use NeuralNet\Activations\Softmax;
use NeuralNet\Losses\MSE;

/**
 * Custom Iterator to expand token IDs to one-hot vectors on-the-fly.
 * Prevents memory exhaustion for large vocabularies.
 */
class OnTheFlyDataset implements Iterator, Countable {
    private array $dataset;
    private int $N;
    private int $vocabSize;
    private int $position = 0;

    public function __construct(array $dataset, int $N, int $vocabSize) {
        $this->dataset = $dataset;
        $this->N = $N;
        $this->vocabSize = $vocabSize;
    }

    public function count(): int { return count($this->dataset); }
    public function rewind(): void { $this->position = 0; }
    public function key(): int { return $this->position; }
    public function next(): void { $this->position++; }
    public function valid(): bool { return isset($this->dataset[$this->position]); }

    public function current(): array {
        $sample = $this->dataset[$this->position];
        
        $inputVector = array_fill(0, $this->N * $this->vocabSize, 0.0);
        foreach ($sample['input_ids'] as $pos => $id) {
            $inputVector[($pos * $this->vocabSize) + $id] = 1.0;
        }

        $targetVector = array_fill(0, $this->vocabSize, 0.0);
        $targetVector[$sample['target_id']] = 1.0;

        return ['input' => $inputVector, 'target' => $targetVector];
    }
}

echo "--- Chat LLM Trainer (Memory Optimized) ---\n";

$dataFile = __DIR__ . '/llm_data.json';
if (!file_exists($dataFile)) {
    die("Please run llm_dataset.php first.\n");
}

$data = json_decode(file_get_contents($dataFile), true);
$vocabSize = $data['vocabSize'];
$N = $data['contextWindow'];
// Subset the dataset for faster demo training in PHP
$datasetIds = array_slice($data['dataset'], 0, 100); 


// Neural Network Architecture
// Scaled for performance with large vocabulary
$inputSize = $N * $vocabSize;
$hiddenSize = 64; 

$nn = new Network();
$nn->addLayer(new Dense($inputSize, $hiddenSize, new ReLU()));
$nn->addLayer(new Dense($hiddenSize, $vocabSize, new Softmax()));
$nn->setLossFunction(new MSE());

$epochs = 500; 
$learningRate = 0.5;
$lrDecay = 3.0;

$trainingData = new OnTheFlyDataset($datasetIds, $N, $vocabSize);

echo "Network built:\n";
echo "  Vocabulary Size: $vocabSize\n";
echo "  Context Window: $N\n";
echo "  Input Layer: $inputSize\n";
echo "  Hidden Layer: $hiddenSize\n";
echo "  Training Samples: " . count($trainingData) . "\n";
echo "  Epochs: $epochs  LR: $learningRate  Decay: $lrDecay\n\n";

$nn->train($trainingData, $epochs, $learningRate, $lrDecay);

$modelPath = __DIR__ . '/llm_model.dat';
$nn->save($modelPath);
echo "\nTraining finished. Model saved to $modelPath\n";
