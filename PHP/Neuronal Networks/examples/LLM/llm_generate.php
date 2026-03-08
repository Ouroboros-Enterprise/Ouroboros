<?php

require_once __DIR__ . '/../../autoload.php';

use NeuralNet\Network;
use NeuralNet\Math\Matrix;
use NeuralNet\Tokenizers\WordTokenizer;

echo "--- Simple LLM Generator ---\n";

$modelPath = __DIR__ . '/llm_model.dat';
$tokenizerPath = __DIR__ . '/tokenizer.dat';

if (!file_exists($modelPath) || !file_exists($tokenizerPath)) {
    die("Please run llm_train.php first to build the model and tokenizer.\n");
}

$nn = Network::load($modelPath);
$tokenizer = unserialize(file_get_contents($tokenizerPath));
$vocabSize = $tokenizer->getVocabSize();
$N = 2; // Fixed window size matching training

// Ask user for a seed sentence (simulated here for demonstration)
$seedSentence = "das wetter"; // Can be modified or passed as arg
if (isset($argv[1])) {
    $seedSentence = implode(" ", array_slice($argv, 1));
}

echo "Seed: \"$seedSentence\"\n";

// Encode
$tokens = $tokenizer->encode($seedSentence);
if (count($tokens) < $N) {
    die("Error: Seed sentence must have at least $N words to start the window.\n");
}

// Generate X words
$wordsToGenerate = 8;
$generatedContext = $tokens;

echo "Generating $wordsToGenerate words...\n\n";

for ($step = 0; $step < $wordsToGenerate; $step++) {
    // Take the last N words from our context
    $window = array_slice($generatedContext, -$N);
    
    // Convert to one-hot concatenation
    $inputVector = [];
    foreach ($window as $token) {
        $oneHot = array_fill(0, $vocabSize, 0.0);
        $oneHot[$token] = 1.0;
        $inputVector = array_merge($inputVector, $oneHot);
    }
    
    // Predict
    $prediction = $nn->predict($inputVector);
    
    // Convert 2D column vector [[p1], [p2], ...] to 1D flat array [p1, p2, ...]
    $probs = [];
    foreach ($prediction as $row) {
        $probs[] = $row[0];
    }
    
    // Probabilistic selection instead of argmax
    $cumulativeProb = 0.0;
    $randomValue = mt_rand() / mt_getrandmax(); // 0.0 to 1.0
    $predictedToken = array_key_last($probs);
    
    foreach ($probs as $tokenId => $prob) {
        $cumulativeProb += $prob;
        if ($randomValue <= $cumulativeProb) {
            $predictedToken = $tokenId;
            break;
        }
    }
    
    echo "   [Step $step] Selected Token ID: $predictedToken -> '{$tokenizer->decode([$predictedToken])}'\n";
    
    // Append to context
    $generatedContext[] = $predictedToken;
}

echo "Final Output: \n";
echo '"' . $tokenizer->decode($generatedContext) . "\"\n";
