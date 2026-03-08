<?php

require_once __DIR__ . '/../../autoload.php';
ini_set('memory_limit', '512M'); // 512MB is plenty for IDs

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

// Context Window: reduced for performance with large vocabulary
$N = 4;
$dataset = [];
$padId = $tokenizer->getPadId();

echo "2. Generating Token ID Sequences (Sliding Window N=$N)...\n";
foreach ($corpus as $entry) {
    $tokens = $tokenizer->encode($entry);

    if (count($tokens) < 2) {
        continue;
    }

    for ($i = 0; $i < count($tokens) - 1; $i++) {
        $targetToken = $tokens[$i + 1];

        // Grab up to N previous tokens
        $startIdx = max(0, $i + 1 - $N);
        $length = min($i + 1, $N);
        $contextTokens = array_slice($tokens, $startIdx, $length);

        // Left-pad if shorter than N
        $paddedContextIds = array_fill(0, $N, $padId);
        array_splice($paddedContextIds, $N - count($contextTokens), count($contextTokens), $contextTokens);

        // Optimization: Store hanya IDs, expand to one-hot during training
        $dataset[] = [
            'input_ids' => $paddedContextIds,
            'target_id' => $targetToken
        ];
    }
}

echo "Generated " . count($dataset) . " training samples.\n";

// Save
file_put_contents(__DIR__ . '/llm_data.json', json_encode([
    'vocabSize' => $vocabSize,
    'contextWindow' => $N,
    'dataset' => $dataset
]));

file_put_contents(__DIR__ . '/tokenizer.dat', serialize($tokenizer));
echo "\nSaved dataset to llm_data.json and Tokenizer to tokenizer.dat\n";
