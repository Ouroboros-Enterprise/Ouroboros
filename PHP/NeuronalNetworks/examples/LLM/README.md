# Simple LLM Example

This folder contains the complete script pipeline to train a simple Language Model (Next-Word-Prediction) using the Custom PHP Neural Network framework.

## Files
- `llm_dataset.php`: Generates training sequences using `WordTokenizer` and writes to `llm_data.json` and `tokenizer.dat`.
- `llm_train.php`: Reads the dataset and trains a Neural Network (Input -> Dense/ReLU -> Dense/Softmax -> MSE Loss) with a Sliding-Window of 2 words (Bigram). Saves the learned weights to `llm_model.dat`.
- `llm_generate.php`: Takes a Seed text (e.g. `php llm_generate.php "Ich trinke"`) and queries the network iteratively to build sentences word by word.

## Usage

1. **Re-Generate Tokenizer and Data**
```bash
php llm_dataset.php
```

2. **Train the Model**
```bash
php llm_train.php
```

3. **Generate Text**
```bash
php llm_generate.php "Das Wetter"
```
