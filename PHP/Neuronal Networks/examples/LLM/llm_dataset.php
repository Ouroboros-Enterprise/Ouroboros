<?php

require_once __DIR__ . '/../../autoload.php';

use NeuralNet\Tokenizers\WordTokenizer;

$corpusFile = __DIR__ . '/corpus.json';
if (!file_exists($corpusFile)) {
    die("Error: corpus.json not found in " . __DIR__ . "\n");
}
$corpus = json_decode(file_get_contents($corpusFile), true);

if (!is_array($corpus) || empty($corpus)) {
    die("Error: corpus.json must contain a valid JSON array of strings.\n");
}

echo "1. Training Tokenizer...\n";
$tokenizer = new WordTokenizer();
$tokenizer->fit($corpus);

$vocabSize = $tokenizer->getVocabSize();
echo "Vocabulary Size: $vocabSize\n\n";

// Context Window: how many previous tokens the model sees
$N = 8;
$dataset = [];
$padId = $tokenizer->getPadId();

echo "2. Generating Sequence Data (Sliding Window N=$N with Padding)...\n";
foreach ($corpus as $entry) {
    // Tokenize the full entry (including [REQUEST], [/REQUEST], [RESPONSE], [/RESPONSE])
    $tokens = $tokenizer->encode($entry);

    if (count($tokens) < 2) {
        continue; // skip entries too short
    }

    // Generate sliding windows across the full sequence
    for ($i = 0; $i < count($tokens) - 1; $i++) {
        $targetToken = $tokens[$i + 1];

        // Grab up to N previous tokens
        $startIdx = max(0, $i + 1 - $N);
        $length = min($i + 1, $N);
        $contextTokens = array_slice($tokens, $startIdx, $length);

        // Left-pad if shorter than N
        $paddedContext = array_fill(0, $N, $padId);
        array_splice($paddedContext, $N - count($contextTokens), count($contextTokens), $contextTokens);

        // One-hot encode input (concat N one-hot vectors)
        $inputVector = [];
        foreach ($paddedContext as $token) {
            $oneHot = array_fill(0, $vocabSize, 0.0);
            $oneHot[$token] = 1.0;
            $inputVector = array_merge($inputVector, $oneHot);
        }

        // One-hot encode target
        $targetVector = array_fill(0, $vocabSize, 0.0);
        $targetVector[$targetToken] = 1.0;

        $dataset[] = [
            'input' => $inputVector,
            'target' => $targetVector,
            'input_words' => $tokenizer->decode($paddedContext),
            'target_word' => $tokenizer->decode([$targetToken])
        ];
    }
}

echo "Generated " . count($dataset) . " training samples.\n";

// Show a few examples
for ($i = 0; $i < min(5, count($dataset)); $i++) {
    echo "  Sample $i: '{$dataset[$i]['input_words']}' -> '{$dataset[$i]['target_word']}'\n";
}

// Save
$cleanDataset = array_map(fn($d) => ['input' => $d['input'], 'target' => $d['target']], $dataset);
file_put_contents(__DIR__ . '/llm_data.json', json_encode([
    'vocabSize' => $vocabSize,
    'contextWindow' => $N,
    'dataset' => $cleanDataset
]));

file_put_contents(__DIR__ . '/tokenizer.dat', serialize($tokenizer));
echo "\nSaved dataset to llm_data.json and Tokenizer to tokenizer.dat\n";
