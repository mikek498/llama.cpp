#!/usr/bin/env python3
"""
Simple benchmark script for comparing original vs optimized llama.cpp
performance on Apple M1 processors.
"""

import argparse
import subprocess
import time
import json
import os
import re
import platform
from datetime import datetime

def run_benchmark(binary_path, model_path, prompt, n_predict=100, 
                  n_threads=4, batch_size=512, n_gpu_layers=100, verbose=False):
    """Run llama.cpp with specified parameters and capture performance metrics."""
    
    cmd = [
        binary_path,
        "-m", model_path,
        "-p", prompt,
        "-n", str(n_predict),
        "-t", str(n_threads),
        "-b", str(batch_size),
        "--metal",
        "-ngl", str(n_gpu_layers)
    ]
    
    if verbose:
        print(f"Running: {' '.join(cmd)}")
    
    start_time = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True)
    total_time = time.time() - start_time
    
    output = result.stdout + result.stderr
    
    # Extract performance metrics
    metrics = {}
    metrics["total_time"] = total_time
    
    # Extract tokens per second
    tps_match = re.search(r"eval time = ([0-9.]+) ms / ([0-9.]+) tokens", output)
    if tps_match:
        eval_ms = float(tps_match.group(1))
        tokens = float(tps_match.group(2))
        metrics["tokens_per_second"] = 1000 * tokens / eval_ms
    
    # Extract memory usage
    mem_match = re.search(r"mem per token = ([0-9.]+) MB", output)
    if mem_match:
        metrics["memory_per_token_mb"] = float(mem_match.group(1))
    
    return metrics

def compare_performance(original_binary, optimized_binary, model_path, prompt, 
                        n_runs=3, verbose=False):
    """Compare performance between original and optimized binaries."""
    
    original_results = []
    optimized_results = []
    
    print(f"Running benchmark {n_runs} times for each version...")
    
    for i in range(n_runs):
        print(f"Run {i+1}/{n_runs}")
        
        print("  Testing original version...")
        original_metrics = run_benchmark(original_binary, model_path, prompt, verbose=verbose)
        original_results.append(original_metrics)
        
        print("  Testing optimized version...")
        optimized_metrics = run_benchmark(optimized_binary, model_path, prompt, verbose=verbose)
        optimized_results.append(optimized_metrics)
    
    # Calculate averages
    avg_original_tps = sum(r.get('tokens_per_second', 0) for r in original_results) / n_runs
    avg_optimized_tps = sum(r.get('tokens_per_second', 0) for r in optimized_results) / n_runs
    
    improvement = ((avg_optimized_tps - avg_original_tps) / avg_original_tps) * 100
    
    results = {
        "system": {
            "platform": platform.platform(),
            "processor": platform.processor(),
            "machine": platform.machine(),
            "timestamp": datetime.now().isoformat()
        },
        "original": {
            "binary": original_binary,
            "avg_tokens_per_second": avg_original_tps,
            "runs": original_results
        },
        "optimized": {
            "binary": optimized_binary,
            "avg_tokens_per_second": avg_optimized_tps,
            "runs": optimized_results
        },
        "improvement_percentage": improvement
    }
    
    return results

def main():
    parser = argparse.ArgumentParser(description="Compare llama.cpp performance on Apple M1")
    parser.add_argument("--original", required=True, help="Path to original llama.cpp main binary")
    parser.add_argument("--optimized", required=True, help="Path to optimized llama.cpp main binary")
    parser.add_argument("--model", required=True, help="Path to the GGUF model file")
    parser.add_argument("--prompt", default="Once upon a time, there was a", help="Text prompt for inference")
    parser.add_argument("--runs", type=int, default=3, help="Number of benchmark runs to average")
    parser.add_argument("--output", default="comparison_results.json", help="Output file for results")
    parser.add_argument("--verbose", action="store_true", help="Show verbose output")
    
    args = parser.parse_args()
    
    # Check if files exist
    if not os.path.isfile(args.original):
        print(f"Error: Original binary not found at {args.original}")
        return
    
    if not os.path.isfile(args.optimized):
        print(f"Error: Optimized binary not found at {args.optimized}")
        return
    
    if not os.path.isfile(args.model):
        print(f"Error: Model file not found at {args.model}")
        return
    
    # Run comparison
    results = compare_performance(
        args.original, 
        args.optimized, 
        args.model, 
        args.prompt, 
        n_runs=args.runs,
        verbose=args.verbose
    )
    
    # Save results
    with open(args.output, 'w') as f:
        json.dump(results, f, indent=2)
    
    # Print summary
    print("\n=== Performance Comparison ===")
    print(f"Original version: {results['original']['avg_tokens_per_second']:.2f} tokens/second")
    print(f"Optimized version: {results['optimized']['avg_tokens_per_second']:.2f} tokens/second")
    print(f"Improvement: {results['improvement_percentage']:.2f}%")
    print(f"\nDetailed results saved to {args.output}")

if __name__ == "__main__":
    main()
