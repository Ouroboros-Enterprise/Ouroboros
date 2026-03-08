<?php

require_once __DIR__ . '/autoload.php';

use NeuralNet\Network;
use NeuralNet\Layers\Dense;
use NeuralNet\Activations\Sigmoid;
use NeuralNet\Losses\MSE;

echo "--- Neural Network Framework Test ---\n";
echo "1. Creating Neural Network for XOR problem.\n";

$nn = new Network();

// Input layer implicitly defined by Dense layer input dimension (2)
// Hidden layer: 4 nodes, Sigmoid activation
$nn->addLayer(new Dense(2, 4, new Sigmoid()));
// Output layer: 1 node, Sigmoid activation
$nn->addLayer(new Dense(4, 1, new Sigmoid()));

$nn->setLossFunction(new MSE());

$trainingData = [
    ['input' => [0, 0], 'target' => [0]],
    ['input' => [0, 1], 'target' => [1]],
    ['input' => [1, 0], 'target' => [1]],
    ['input' => [1, 1], 'target' => [0]],
];

echo "   Training started... (10000 epochs)\n";
$nn->train($trainingData, 10000, 0.5); // Using 0.5 learning rate for faster convergence
echo "   Training completed.\n\n";

echo "2. Testing predictions after training:\n";
foreach ($trainingData as $data) {
    $prediction = $nn->predict($data['input']);
    echo sprintf(
        "   Input: [%d, %d] => Predicted: %.4f (Expected: %d)\n",
        $data['input'][0],
        $data['input'][1],
        $prediction[0][0], // Output is 1x1 matrix -> array
        $data['target'][0]
    );
}
echo "\n";

echo "3. Testing Save / Load capability.\n";
$modelPath = __DIR__ . '/xor_model.dat';
$nn->save($modelPath);
echo "   Model saved to $modelPath\n";

$loadedNet = Network::load($modelPath);
echo "   Model loaded successfully.\n";
echo "   Testing loaded model predictions:\n";

foreach ($trainingData as $data) {
    $prediction = $loadedNet->predict($data['input']);
    echo sprintf(
        "   Input: [%d, %d] => Predicted: %.4f (Expected: %d)\n",
        $data['input'][0],
        $data['input'][1],
        $prediction[0][0],
        $data['target'][0]
    );
}

echo "\nTests completed!\n";
