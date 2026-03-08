<?php

namespace NeuralNet\Tokenizers;

interface TokenizerInterface
{
    /**
     * Encode a string into an array of generic tokens/IDs or floating point values.
     * @param string $text
     * @return array
     */
    public function encode(string $text): array;

    /**
     * Decode an array of tokens/IDs back into a string.
     * @param array $tokens
     * @return string
     */
    public function decode(array $tokens): string;
}
