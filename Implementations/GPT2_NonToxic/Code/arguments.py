from modules import * 

@dataclass
class Args():
    dataset_name: str = "pt-sk/toxic_classification"
    input_min_text_length: int = 8
    input_max_text_length: int = 16
    model_name: str = "pt-sk/GPT2"
    dataset_filter_upper_bound: int = 250
    dataset_filter_lower_bound: int = 200
    dataset_format: str = "torch"
    seed: int = 42
    learning_rate: float = 1.41e-5
    classfication_model_name: str = "pt-sk/bert-toxic-classification"
    output_min_length: int = 20
    output_max_length: int = 30
    batch_size: int = 16
    
    
args = Args()
