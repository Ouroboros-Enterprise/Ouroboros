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
        
        // Return token IDs directly - the Embedding layer handles the lookup
        $inputIds = $sample['input_ids'];

        $targetVector = array_fill(0, $this->vocabSize, 0.0);
        $targetVector[$sample['target_id']] = 1.0;

        return ['input' => $inputIds, 'target' => $targetVector];
    }
}

echo "--- Chat SLM Trainer (Embedding + RNN + Adam) ---\n";

$dataFile = __DIR__ . '/llm_data.json';
if (!file_exists($dataFile)) {
    die("Please run llm_dataset.php first.\n");
}

$data = json_decode(file_get_contents($dataFile), true);
$vocabSize = $data['vocabSize'];
$N = $data['contextWindow'];
$datasetIds = $data['dataset']; // Use full dataset for RNN training


// Neural Network Architecture: Embedding -> RNN -> Dense
$embeddingDim = 32;
$hiddenSize = 64; 

$nn = new Network();
$nn->addLayer(new \NeuralNet\Layers\Embedding($vocabSize, $embeddingDim));
$nn->addLayer(new \NeuralNet\Layers\SimpleRNN($embeddingDim, $hiddenSize, new \NeuralNet\Activations\Tanh()));
$nn->addLayer(new \NeuralNet\Layers\Dense($hiddenSize, $vocabSize, new \NeuralNet\Activations\Softmax()));

// Use Adam Optimizer for significantly faster/stable convergence
$nn->setOptimizer(new \NeuralNet\Optimizers\Adam(0.9, 0.999, 1e-8));
$nn->setLossFunction(new \NeuralNet\Losses\CategoricalCrossEntropy());

$epochs = 100; // Adam converges MUCH faster
$learningRate = 0.001; // Adam usually works better with smaller base LR

$trainingData = new OnTheFlyDataset($datasetIds, $N, $vocabSize);

echo "Network built (RNN Upgrade):\n";
echo "  Vocabulary Size: $vocabSize\n";
echo "  Context Window: $N\n";
echo "  Hidden State Size: $hiddenSize\n";
echo "  Optimizer: Adam\n";
echo "  Training Samples: " . count($trainingData) . "\n";
echo "  Epochs: $epochs  Base LR: $learningRate\n\n";

$nn->train($trainingData, $epochs, $learningRate);

$modelPath = __DIR__ . '/llm_model.dat';
$nn->save($modelPath);
echo "\nTraining finished. Model saved to $modelPath\n";
