<?php

require_once __DIR__ . '/../../autoload.php';

use NeuralNet\Network;
use NeuralNet\Layers\Dense;
use NeuralNet\Activations\ReLU;
use NeuralNet\Activations\Softmax;
use NeuralNet\Losses\MSE;

echo "--- Chat LLM Trainer ---\n";

$dataFile = __DIR__ . '/llm_data.json';
if (!file_exists($dataFile)) {
    die("Please run llm_dataset.php first.\n");
}

$data = json_decode(file_get_contents($dataFile), true);
$vocabSize = $data['vocabSize'];
$N = $data['contextWindow'];
$dataset = $data['dataset'];

// Neural Network Architecture
$inputSize = $N * $vocabSize;
$hiddenSize = 64;

$nn = new Network();
$nn->addLayer(new Dense($inputSize, $hiddenSize, new ReLU()));
$nn->addLayer(new Dense($hiddenSize, $vocabSize, new Softmax()));
$nn->setLossFunction(new MSE());

$epochs = 3000;
$learningRate = 0.5;
$lrDecay = 3.0;

echo "Network built:\n";
echo "  Context Window (N): $N\n";
echo "  Input Layer Size: $inputSize\n";
echo "  Hidden Layer Size: $hiddenSize\n";
echo "  Output / Vocab Size: $vocabSize\n";
echo "  Initial LR: $learningRate  Decay: $lrDecay\n";
echo "Training on " . count($dataset) . " samples for $epochs epochs...\n\n";

$nn->train($dataset, $epochs, $learningRate, $lrDecay);

$modelPath = __DIR__ . '/llm_model.dat';
$nn->save($modelPath);
echo "\nTraining finished. Model saved to $modelPath\n";
