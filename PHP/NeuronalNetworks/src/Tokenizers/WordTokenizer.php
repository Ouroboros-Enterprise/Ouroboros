<?php

namespace NeuralNet\Tokenizers;

class WordTokenizer implements TokenizerInterface
{
    private array $wordToId = [];
    private array $idToWord = [];
    private int $nextId = 0;
    
    public const PAD_TOKEN = '<PAD>';

    public function __construct() {
        // Reserve ID 0 for Padding
        $this->wordToId[self::PAD_TOKEN] = 0;
        $this->idToWord[0] = self::PAD_TOKEN;
        $this->nextId = 1;
    }

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

    public function getPadId(): int
    {
        return $this->wordToId[self::PAD_TOKEN];
    }

    public function encode(string $text): array
    {
        // Check if the text is a special token (like <PAD>) - handle directly
        if (isset($this->wordToId[$text])) {
            return [$this->wordToId[$text]];
        }
        
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

    public const REQUEST_START = '[REQUEST]';
    public const REQUEST_END = '[/REQUEST]';
    public const RESPONSE_START = '[RESPONSE]';
    public const RESPONSE_END = '[/RESPONSE]';

    private function tokenizeText(string $text): array
    {
        $text = trim($text);
        $tokens = [];

        // Extract special bracket tokens [TOKEN] and regular words in order
        // Pattern: match [ANYTHING] or sequences of non-whitespace non-bracket chars
        preg_match_all('/\[[^\]]+\]|[^\s\[\]]+/u', $text, $matches);

        foreach ($matches[0] as $part) {
            // If it's a special token in brackets, keep it as-is
            if (preg_match('/^\[.+\]$/', $part)) {
                $tokens[] = $part;
            } else {
                // Normal word: lowercase, strip punctuation
                $word = strtolower($part);
                $word = preg_replace('/[^\w]/u', '', $word);
                if ($word !== '') {
                    $tokens[] = $word;
                }
            }
        }

        return $tokens;
    }
}
