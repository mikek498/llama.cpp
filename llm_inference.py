
import torch
import time
import argparse
from transformers import AutoModelForCausalLM, AutoTokenizer

def load_model(model_id, device="cpu", precision="fp32"):
    """
    Load a model and tokenizer.
    
    Args:
        model_id: HuggingFace model ID
        device: Device to load the model on ("cpu", "mps", "cuda")
        precision: Precision to use ("fp32", "fp16", "int8")
    """
    print(f"Loading model {model_id} on {device} with precision {precision}")
    
    tokenizer = AutoTokenizer.from_pretrained(model_id)
    
    # Configure model loading based on precision
    if precision == "fp16":
        torch_dtype = torch.float16
    elif precision == "int8":
        torch_dtype = torch.int8
    else:  # fp32
        torch_dtype = torch.float32
    
    # Load the model with the specified configuration
    model = AutoModelForCausalLM.from_pretrained(
        model_id,
        torch_dtype=torch_dtype,
        low_cpu_mem_usage=True,
    )
    
    # Move model to specified device
    model = model.to(device)
    
    return model, tokenizer

def generate_text(model, tokenizer, prompt, max_new_tokens=100, device="cpu"):
    """
    Generate text using the model.
    
    Args:
        model: The language model
        tokenizer: The tokenizer
        prompt: The input prompt
        max_new_tokens: Maximum number of new tokens to generate
        device: Device to run inference on
    """
    inputs = tokenizer(prompt, return_tensors="pt").to(device)
    
    # Measure inference time
    start_time = time.time()
    
    with torch.no_grad():
        outputs = model.generate(
            inputs.input_ids,
            max_new_tokens=max_new_tokens,
            do_sample=True,
            temperature=0.7,
            top_p=0.9,
        )
    
    end_time = time.time()
    inference_time = end_time - start_time
    
    generated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    return generated_text, inference_time

def benchmark_inference(model, tokenizer, prompt, num_runs=5, max_new_tokens=100, device="cpu"):
    """
    Benchmark inference performance.
    
    Args:
        model: The language model
        tokenizer: The tokenizer
        prompt: The input prompt
        num_runs: Number of inference runs for benchmarking
        max_new_tokens: Maximum number of new tokens to generate
        device: Device to run inference on
    """
    total_time = 0
    
    for i in range(num_runs):
        print(f"Run {i+1}/{num_runs}")
        _, inference_time = generate_text(model, tokenizer, prompt, max_new_tokens, device)
        total_time += inference_time
        print(f"Inference time: {inference_time:.4f} seconds")
    
    avg_time = total_time / num_runs
    print(f"\nAverage inference time over {num_runs} runs: {avg_time:.4f} seconds")
    print(f"Tokens per second: {max_new_tokens / avg_time:.2f}")

def main():
    parser = argparse.ArgumentParser(description="LLM Inference Benchmark")
    parser.add_argument("--model", type=str, default="gpt2", help="Model ID from HuggingFace")
    parser.add_argument("--device", type=str, default="cpu", choices=["cpu", "mps", "cuda"], help="Device to run inference on")
    parser.add_argument("--precision", type=str, default="fp32", choices=["fp32", "fp16", "int8"], help="Model precision")
    parser.add_argument("--prompt", type=str, default="Once upon a time", help="Input prompt")
    parser.add_argument("--max_tokens", type=int, default=100, help="Maximum tokens to generate")
    parser.add_argument("--num_runs", type=int, default=5, help="Number of inference runs for benchmarking")
    
    args = parser.parse_args()
    
    # Load model and tokenizer
    model, tokenizer = load_model(args.model, args.device, args.precision)
    
    # Run benchmark
    benchmark_inference(model, tokenizer, args.prompt, args.num_runs, args.max_tokens, args.device)
    
    # Generate a sample text
    print("\nSample generation:")
    generated_text, _ = generate_text(model, tokenizer, args.prompt, args.max_tokens, args.device)
    print(f"Prompt: {args.prompt}")
    print(f"Generated text: {generated_text}")

if __name__ == "__main__":
    main()
