from modules import *

def build_dataset(dataset_name=args.dataset_name, input_min_text_length=args.input_min_text_length, input_max_text_length=args.input_max_text_length):
    # loading the tokenizer
    tokenizer = AutoTokenizer.from_pretrained(args.model_name)
    tokenizer.pad_token = tokenizer.eos_token
    # loading the dataset
    ds = load_dataset(dataset_name)
    ds = ds.filter(lambda x: len(x["text"]) > args.dataset_filter_lower_bound and len(x["text"]) < args.dataset_filter_upper_bound, batched=False)
    
    input_size = LengthSampler(input_min_text_length, input_max_text_length)
    
    def tokenize(sample):
        sample["input_ids"] = tokenizer.encode(sample["text"])[: input_size()]
        sample["query"] = tokenizer.decode(sample["input_ids"])
        return sample
    
    ds = ds.map(tokenize, batched=False)
    ds.set_format(type=args.dataset_format)
    return ds["train"]


def collator(data):
    return dict((key, [d[key] for d in data]) for key in data[0])
