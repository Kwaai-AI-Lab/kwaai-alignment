# GPT-2 IMDB Sentiment Fine-Tuning with PPO

This repository contains code for fine-tuning a GPT-2 model on the IMDB dataset using Proximal Policy Optimization (PPO). The goal is to train the model to generate positive sentiment reviews. The training process utilizes the `trl` library for reinforcement learning, the `transformers` library for model handling, and `datasets` for dataset management.

## Table of Contents

* Installation
* Usage
* Code Overview
* Saving the Model
* Hugging Face Model
* Reference Papers

### Installation
To run the code, you need to install the required packages. You can do this using `pip`:
```bash
pip install requirements.txt
```

### Usage
To start the training process, simply run the script:
```bash
python train.py
```

### Code Overview
1. The `build_dataset` function constructs the dataset for training. It tokenizes the IMDB reviews, filters out reviews with less than 200 tokens, and truncates the reviews to a random length for input.
2. The `collator` function formats the data into batches.
3. The main training loop fine-tunes the model using PPO. It involves generating responses, calculating rewards using a sentiment analysis model, and updating the model.

### Saving the Model
The model and tokenizer are saved after training to the specified directory.

### Hugging Face Model
The fine-tuned model is available on Hugging Face. You can use the inference API to test the model and generate responses with custom input.
you can test the model using Hugging Face Inference API: [Hugging Face](https://huggingface.co/pt-sk/GPT2-IMDB-Sentiment-FineTuning-with-PPO)
The model and tokenizer files can be accessed in the files section of the above link

### Reference Papers
This repository includes a collection of reference papers that provide additional context and background on the methods and techniques used. You can find these papers in the `reference_papers` folder.
