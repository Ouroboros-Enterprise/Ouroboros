<?php

require_once __DIR__ . '/../../autoload.php';

use NeuralNet\Network;
use NeuralNet\Layers\Dense;
use NeuralNet\Activations\ReLU;
use NeuralNet\Activations\Softmax;
use NeuralNet\Losses\CategoricalCrossEntropy;

echo "--- Simple LLM Trainer ---\n";

$dataFile = __DIR__ . '/llm_data.json';
if (!file_exists($dataFile)) {
    die("Please run llm_dataset.php first.\n");
}

$data = json_decode(file_get_contents($dataFile), true);
$vocabSize = $data['vocabSize'];
$dataset = $data['dataset'];

// Neural Network Architecture
// Input size: N words * Vocabulary Size
$N = 2; 
$inputSize = $N * $vocabSize;
$hiddenSize = 32; // A bit more capacity for text

$nn = new Network();
$nn->addLayer(new Dense($inputSize, $hiddenSize, new ReLU()));
$nn->addLayer(new Dense($hiddenSize, $vocabSize, new Softmax()));

// Add MSE loss to test if backprop still works correctly in LLM
use NeuralNet\Losses\MSE;
$nn->setLossFunction(new MSE());

$epochs = 1500; // Memorize
$learningRate = 0.5;

echo "Network built:\n";
echo "  Input Layer Size: $inputSize\n";
echo "  Hidden Layer Size: $hiddenSize\n";
echo "  Output / Vocab Size: $vocabSize\n";
echo "Training on " . count($dataset) . " samples for $epochs epochs...\n\n";

// Ensure dataset format matches what Network::train expects (associative arrays)
// llm_dataset already outputs 'input' and 'target' keys
$nn->train($dataset, $epochs, $learningRate);

$modelPath = __DIR__ . '/llm_model.dat';
$nn->save($modelPath);
echo "\nTraining finished. Model saved to $modelPath\n";
