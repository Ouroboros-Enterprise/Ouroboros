<?php
require_once __DIR__ . '/autoload.php';

use NeuralNet\Math\Matrix;

echo "Testing Matrix Operations...\n";

// Test fromArray and toArray
$m1 = Matrix::fromArray([[1, 2], [3, 4]]);
$m2 = Matrix::fromArray([[5, 6], [7, 8]]);

// Test Add
$add = $m1->add($m2);
if ($add->toArray() === [[6, 8], [10, 12]]) {
    echo "Add: OK\n";
} else {
    echo "Add: FAIL\n";
}

// Test Subtract
$sub = $m2->subtract($m1);
if ($sub->toArray() === [[4, 4], [4, 4]]) {
    echo "Subtract: OK\n";
} else {
    echo "Subtract: FAIL\n";
}

// Test Dot Product (Multiply)
// [1 2] * [5 6] = [1*5+2*7, 1*6+2*8] = [19, 22]
// [3 4]   [7 8]   [3*5+4*7, 3*6+4*8]   [43, 50]
$dot = $m1->multiply($m2);
if ($dot->toArray() === [[19, 22], [43, 50]]) {
    echo "Dot Product: OK\n";
} else {
    echo "Dot Product: FAIL\n";
}

// Test Transpose
$trans = $m1->transpose();
if ($trans->toArray() === [[1, 3], [2, 4]]) {
    echo "Transpose: OK\n";
} else {
    echo "Transpose: FAIL\n";
}

// Test Map
$mapped = $m1->map(fn($val) => $val * 2);
if ($mapped->toArray() === [[2, 4], [6, 8]]) {
    echo "Map: OK\n";
} else {
    echo "Map: FAIL\n";
}

echo "All tests finished.\n";
