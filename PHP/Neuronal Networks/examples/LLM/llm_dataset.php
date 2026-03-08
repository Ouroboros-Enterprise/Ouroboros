<?php

require_once __DIR__ . '/../../autoload.php';

use NeuralNet\Tokenizers\WordTokenizer;

$corpus = [
    "Das Wetter ist heute sehr schön.",
    "Ich trinke gerne heißen Kaffee am Morgen.",
    "Der Hund bellt laut im Garten.",
    "Wir programmieren ein neuronales Netz in PHP.",
    "Das Wetter ist schlecht und es regnet.",
    "Ich trinke gerne kalten Saft.",
    "Der Hund schläft friedlich auf dem Sofa."
];

echo "1. Training Tokenizer...\n";
$tokenizer = new WordTokenizer();
$tokenizer->fit($corpus);

$vocabSize = $tokenizer->getVocabSize();
echo "Vocabulary Size: $vocabSize\n\n";

// N-Gram size: Looking at the previous N words to predict the next
$N = 2; // Bi-gram (predict 3rd word from 2 words)
$dataset = [];

echo "2. Generating Sequence Data (Sliding Window N=$N)...\n";
foreach ($corpus as $sentence) {
    $tokens = $tokenizer->encode($sentence);
    
    // Slide window over tokens
    for ($i = 0; $i < count($tokens) - $N; $i++) {
        $inputTokens = array_slice($tokens, $i, $N);
        $targetToken = $tokens[$i + $N];
        
        // One-hot encode input (concat N one-hot vectors)
        $inputVector = [];
        foreach ($inputTokens as $token) {
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
            // For debugging:
            'input_words' => $tokenizer->decode($inputTokens),
            'target_word' => $tokenizer->decode([$targetToken])
        ];
    }
}

echo "Generated " . count($dataset) . " training samples.\n";

// Display a few samples
for ($i = 0; $i < min(3, count($dataset)); $i++) {
    echo "Sample $i: '" . $dataset[$i]['input_words'] . "' -> '" . $dataset[$i]['target_word'] . "'\n";
}

// Save dataset and tokenizer for training and generation scripts
file_put_contents(__DIR__ . '/llm_data.json', json_encode([
    'vocabSize' => $vocabSize,
    'dataset' => ArraysToSerializable($dataset) // we don't need all keys, but json_encode works directly
]));

file_put_contents(__DIR__ . '/tokenizer.dat', serialize($tokenizer));
echo "\nSaved dataset to llm_data.json and Tokenizer to tokenizer.dat\n";

function ArraysToSerializable(array $dataset): array {
    $clean = [];
    foreach($dataset as $d) {
        $clean[] = ['input' => $d['input'], 'target' => $d['target']];
    }
    return $clean;
}
