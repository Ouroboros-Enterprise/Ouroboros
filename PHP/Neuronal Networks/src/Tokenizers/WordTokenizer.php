<?php

namespace NeuralNet\Tokenizers;

class WordTokenizer implements TokenizerInterface
{
    private array $wordToId = [];
    private array $idToWord = [];
    private int $nextId = 0;

    /**
     * Train the tokenizer on a corpus (an array of texts) to build the vocabulary.
     */
    public function fit(array $corpus): void
    {
        foreach ($corpus as $text) {
            $words = $this->tokenizeText($text);
            foreach ($words as $word) {
                if (!isset($this->wordToId[$word])) {
                    $this->wordToId[$word] = $this->nextId;
                    $this->idToWord[$this->nextId] = $word;
                    $this->nextId++;
                }
            }
        }
    }

    public function getVocabSize(): int
    {
        return $this->nextId;
    }

    public function encode(string $text): array
    {
        $words = $this->tokenizeText($text);
        $encoded = [];
        foreach ($words as $word) {
            if (isset($this->wordToId[$word])) {
                $encoded[] = $this->wordToId[$word];
            } else {
                // Ignore unknown words for this simple implementation
                // Alternatively, an <UNK> token could be added.
            }
        }
        return $encoded;
    }

    public function decode(array $tokens): string
    {
        $words = [];
        foreach ($tokens as $id) {
            if (isset($this->idToWord[$id])) {
                $words[] = $this->idToWord[$id];
            }
        }
        return implode(' ', $words);
    }

    private function tokenizeText(string $text): array
    {
        // Simple regex to split by whitespace and punctuation, keeping words lowercase
        $text = strtolower(trim($text));
        $text = preg_replace('/[^\w\s]/u', '', $text); // Remove punctuation
        $words = preg_split('/\s+/', $text, -1, PREG_SPLIT_NO_EMPTY);
        return $words ?: [];
    }
}
