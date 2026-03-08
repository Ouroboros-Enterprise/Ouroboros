<?php

namespace NeuralNet\Math;

use Exception;

class Matrix
{
    public int $rows;
    public int $cols;
    public array $data;

    public function __construct(int $rows, int $cols, ?array $data = null)
    {
        $this->rows = $rows;
        $this->cols = $cols;

        if ($data !== null) {
            $this->data = $data;
        } else {
            $this->data = array_fill(0, $this->rows, array_fill(0, $this->cols, 0.0));
        }
    }

    /**
     * Create a 2D Matrix from a 1D or 2D array
     */
    public static function fromArray(array $arr): self
    {
        if (!isset($arr[0]) || !is_array($arr[0])) {
            // Assume 1D array, make it an N x 1 matrix
            $rows = count($arr);
            $matrix = new self($rows, 1);
            for ($i = 0; $i < $rows; $i++) {
                $matrix->data[$i][0] = $arr[$i];
            }
            return $matrix;
        }

        // 2D Array
        $rows = count($arr);
        $cols = count($arr[0]);
        $matrix = new self($rows, $cols);
        for ($i = 0; $i < $rows; $i++) {
            for ($j = 0; $j < $cols; $j++) {
                $matrix->data[$i][$j] = $arr[$i][$j];
            }
        }
        return $matrix;
    }

    /**
     * Convert Matrix to array
     */
    public function toArray(): array
    {
        $arr = [];
        for ($i = 0; $i < $this->rows; $i++) {
            for ($j = 0; $j < $this->cols; $j++) {
                $arr[$i][$j] = $this->data[$i][$j];
            }
        }
        return $arr;
    }

    /**
     * Element-wise addition
     */
    public function add(Matrix $m): self
    {
        if ($this->rows !== $m->rows || $this->cols !== $m->cols) {
            throw new Exception("Matrix dimensions must match for addition");
        }

        $result = new self($this->rows, $this->cols);
        for ($i = 0; $i < $this->rows; $i++) {
            for ($j = 0; $j < $this->cols; $j++) {
                $result->data[$i][$j] = $this->data[$i][$j] + $m->data[$i][$j];
            }
        }
        return $result;
    }

    /**
     * Element-wise subtraction
     */
    public function subtract(Matrix $m): self
    {
        if ($this->rows !== $m->rows || $this->cols !== $m->cols) {
            throw new Exception("Matrix dimensions must match for subtraction.");
        }

        $result = new self($this->rows, $this->cols);
        for ($i = 0; $i < $this->rows; $i++) {
            for ($j = 0; $j < $this->cols; $j++) {
                $result->data[$i][$j] = $this->data[$i][$j] - $m->data[$i][$j];
            }
        }
        return $result;
    }

    /**
     * Matrix multiplication (Dot product)
     */
    public function multiply(Matrix $m): self
    {
        if ($this->cols !== $m->rows) {
            throw new Exception("Columns of A ({$this->cols}) must match rows of B ({$m->rows}).");
        }

        $result = new self($this->rows, $m->cols);
        for ($i = 0; $i < $result->rows; $i++) {
            for ($j = 0; $j < $result->cols; $j++) {
                $sum = 0;
                for ($k = 0; $k < $this->cols; $k++) {
                    $sum += $this->data[$i][$k] * $m->data[$k][$j];
                }
                $result->data[$i][$j] = $sum;
            }
        }
        return $result;
    }

    /**
     * Element-wise scale multiplication (Hadamard product / scalar)
     */
    public function multiplyElementWise(Matrix $m): self
    {
        if ($this->rows !== $m->rows || $this->cols !== $m->cols) {
             throw new Exception("Matrix dimensions must match for element-wise multiplication.");
        }
        $result = new self($this->rows, $this->cols);
        for ($i = 0; $i < $this->rows; $i++) {
            for ($j = 0; $j < $this->cols; $j++) {
                $result->data[$i][$j] = $this->data[$i][$j] * $m->data[$i][$j];
            }
        }
        return $result;
    }
    
    /**
     * Multiply by a scalar
     */
    public function multiplyScalar(float $n): self
    {
        $result = new self($this->rows, $this->cols);
        for ($i = 0; $i < $this->rows; $i++) {
            for ($j = 0; $j < $this->cols; $j++) {
                $result->data[$i][$j] = $this->data[$i][$j] * $n;
            }
        }
        return $result;
    }

    /**
     * Transpose Matrix
     */
    public function transpose(): self
    {
        $result = new self($this->cols, $this->rows);
        for ($i = 0; $i < $this->rows; $i++) {
            for ($j = 0; $j < $this->cols; $j++) {
                $result->data[$j][$i] = $this->data[$i][$j];
            }
        }
        return $result;
    }

    /**
     * Apply a function to every element
     */
    public function map(callable $fn): self
    {
        $result = new self($this->rows, $this->cols);
        for ($i = 0; $i < $this->rows; $i++) {
            for ($j = 0; $j < $this->cols; $j++) {
                $result->data[$i][$j] = $fn($this->data[$i][$j], $i, $j);
            }
        }
        return $result;
    }

    /**
     * Fill matrix with random normalized values between -1 and 1
     */
    public function randomize(float $min = -1.0, float $max = 1.0): void
    {
        for ($i = 0; $i < $this->rows; $i++) {
            for ($j = 0; $j < $this->cols; $j++) {
                $this->data[$i][$j] = $min + mt_rand() / mt_getrandmax() * ($max - $min);
            }
        }
    }
}
