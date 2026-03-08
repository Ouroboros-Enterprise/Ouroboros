<?php

require_once __DIR__ . '/../../autoload.php';

use NeuralNet\Network;
use NeuralNet\Math\Matrix;
use NeuralNet\Tokenizers\WordTokenizer;

echo "=== PHP Neural Chat ===\n";
echo "Type your message and press Enter. Type 'quit' to exit.\n\n";

$modelPath = __DIR__ . '/llm_model.dat';
$tokenizerPath = __DIR__ . '/tokenizer.dat';
$dataFile = __DIR__ . '/llm_data.json';

if (!file_exists($modelPath) || !file_exists($tokenizerPath) || !file_exists($dataFile)) {
    die("Please run llm_dataset.php and llm_train.php first.\n");
}

$nn = Network::load($modelPath);
$tokenizer = unserialize(file_get_contents($tokenizerPath));
$data = json_decode(file_get_contents($dataFile), true);
$vocabSize = $tokenizer->getVocabSize();
$N = $data['contextWindow'];

$padId = $tokenizer->getPadId();
$responseStartId = $tokenizer->encode(WordTokenizer::RESPONSE_START)[0];
$responseEndId = $tokenizer->encode(WordTokenizer::RESPONSE_END)[0];

$maxResponseLength = 50; // Safety limit

while (true) {
    echo "Du: ";
    $userInput = trim(fgets(STDIN));

    if ($userInput === '' || strtolower($userInput) === 'quit') {
        echo "Bye!\n";
        break;
    }

    // Build the prompt: [REQUEST] user words [/REQUEST] [RESPONSE]
    $prompt = WordTokenizer::REQUEST_START . ' ' . $userInput . ' ' . WordTokenizer::REQUEST_END . ' ' . WordTokenizer::RESPONSE_START;
    $tokens = $tokenizer->encode($prompt);

    $responseWords = [];

    for ($step = 0; $step < $maxResponseLength; $step++) {
        // Build padded context of last N tokens
        $startIdx = max(0, count($tokens) - $N);
        $length = min(count($tokens), $N);
        $contextTokens = array_slice($tokens, $startIdx, $length);

        $paddedContext = array_fill(0, $N, $padId);
        array_splice($paddedContext, $N - count($contextTokens), count($contextTokens), $contextTokens);

        // One-hot encode as a sequence of vectors for RNN
        $inputSequence = [];
        foreach ($paddedContext as $tokenId) {
            $oneHot = array_fill(0, $vocabSize, 0.0);
            $oneHot[$tokenId] = 1.0;
            $inputSequence[] = $oneHot;
        }

        // Predict using the RNN-compatible sequence
        $prediction = $nn->predict($inputSequence);

        // Convert column vector to flat array
        $probs = [];
        foreach ($prediction as $row) {
            $probs[] = $row[0];
        }

        // Probabilistic sampling
        $cumulativeProb = 0.0;
        $randomValue = mt_rand() / mt_getrandmax();
        $predictedToken = array_key_last($probs);

        foreach ($probs as $tokenId => $prob) {
            $cumulativeProb += $prob;
            if ($randomValue <= $cumulativeProb) {
                $predictedToken = $tokenId;
                break;
            }
        }

        // Stop if we predicted [/RESPONSE]
        if ($predictedToken === $responseEndId) {
            break;
        }

        // Skip [RESPONSE] token itself from output
        if ($predictedToken !== $responseStartId) {
            $word = $tokenizer->decode([$predictedToken]);
            $responseWords[] = $word;
        }

        // Append to context for next prediction
        $tokens[] = $predictedToken;
    }

    $response = implode(' ', $responseWords);
    if (empty($response)) {
        $response = '(keine Antwort)';
    }

    echo "AI: $response\n\n";
}
