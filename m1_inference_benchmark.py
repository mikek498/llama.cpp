#!/usr/bin/env python3
"""
Benchmark script for comparing llama.cpp inference performance on Apple M1 processors.
This script automates testing with different parameters to find optimal settings.
"""

import argparse
import subprocess
import time
import json
import os
import re
import platform
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

def check_environment():
    """Check if running on Apple Silicon M1/M2/M3."""
    if platform.system() != "Darwin" or platform.machine() != "arm64":
        print("Warning: This benchmark is designed for Apple Silicon Macs (M1/M2/M3)")
        return False
    return True

def run_benchmark(model_path, prompt, n_predict=100, n_threads=None, batch_size=512, 
                  n_gpu_layers=100, use_mlock=True, verbose=False):
    """Run llama.cpp with specified parameters and capture performance metrics."""
    
    if not n_threads:
        # Use available performance cores by default
        result = subprocess.run(["sysctl", "-n", "hw.perflevel0.physicalcpu"], 
                                capture_output=True, text=True)
        n_threads = int(result.stdout.strip())
    
    cmd = [
        "./main",
        "-m", model_path,
        "-p", prompt,
        "-n", str(n_predict),
        "-t", str(n_threads),
        "-b", str(batch_size),
        "--metal",  # Ensure Metal is enabled
        "-ngl", str(n_gpu_layers)
    ]
    
    if use_mlock:
        cmd.append("--mlock")
    
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

def benchmark_batch_sizes(model_path, prompt, batch_sizes=[32, 64, 128, 256, 512, 1024, 2048]):
    """Benchmark different batch sizes to find optimal value."""
    results = []
    
    for batch_size in batch_sizes:
        print(f"Testing batch size: {batch_size}")
        metrics = run_benchmark(model_path, prompt, batch_size=batch_size)
        metrics["batch_size"] = batch_size
        results.append(metrics)
        print(f"  Tokens per second: {metrics.get('tokens_per_second', 'N/A')}")
    
    return results

def benchmark_thread_counts(model_path, prompt, thread_counts=None):
    """Benchmark different CPU thread counts."""
    if thread_counts is None:
        # Get total core count
        result = subprocess.run(["sysctl", "-n", "hw.ncpu"], 
                                capture_output=True, text=True)
        total_cores = int(result.stdout.strip())
        thread_counts = list(range(1, total_cores + 1))
    
    results = []
    
    for n_threads in thread_counts:
        print(f"Testing thread count: {n_threads}")
        metrics = run_benchmark(model_path, prompt, n_threads=n_threads)
        metrics["n_threads"] = n_threads
        results.append(metrics)
        print(f"  Tokens per second: {metrics.get('tokens_per_second', 'N/A')}")
    
    return results

def benchmark_gpu_layers(model_path, prompt, layer_options=[0, 25, 50, 75, 100]):
    """Benchmark different GPU layer counts."""
    results = []
    
    for n_gpu_layers in layer_options:
        print(f"Testing GPU layers: {n_gpu_layers}%")
        metrics = run_benchmark(model_path, prompt, n_gpu_layers=n_gpu_layers)
        metrics["n_gpu_layers"] = n_gpu_layers
        results.append(metrics)
        print(f"  Tokens per second: {metrics.get('tokens_per_second', 'N/A')}")
    
    return results

def plot_results(results, x_key, title, xlabel, output_file=None):
    """Generate a plot from benchmark results."""
    plt.figure(figsize=(10, 6))
    
    x_values = [r[x_key] for r in results]
    y_values = [r.get('tokens_per_second', 0) for r in results]
    
    plt.plot(x_values, y_values, 'o-', linewidth=2)
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel('Tokens per second')
    plt.grid(True)
    
    if output_file:
        plt.savefig(output_file)
    else:
        plt.show()

def main():
    parser = argparse.ArgumentParser(description="Benchmark llama.cpp on Apple M1")
    parser.add_argument("--model", required=True, help="Path to the GGUF model file")
    parser.add_argument("--prompt", default="Once upon a time, there was a", help="Text prompt for inference")
    parser.add_argument("--output", default="benchmark_results.json", help="Output file for results")
    parser.add_argument("--batch", action="store_true", help="Benchmark batch sizes")
    parser.add_argument("--threads", action="store_true", help="Benchmark thread counts")
    parser.add_argument("--layers", action="store_true", help="Benchmark GPU layer counts")
    parser.add_argument("--all", action="store_true", help="Run all benchmarks")
    parser.add_argument("--plot", action="store_true", help="Generate plots")
    
    args = parser.parse_args()
    
    if not check_environment():
        print("Continuing anyway...")
    
    results = {
        "model": args.model,
        "prompt": args.prompt,
        "system": {
            "platform": platform.platform(),
            "processor": platform.processor(),
            "machine": platform.machine(),
            "timestamp": datetime.now().isoformat()
        },
        "benchmarks": {}
    }
    
    if args.all or args.batch:
        print("\n=== Benchmarking Batch Sizes ===")
        batch_results = benchmark_batch_sizes(args.model, args.prompt)
        results["benchmarks"]["batch_sizes"] = batch_results
        if args.plot:
            plot_results(batch_results, "batch_size", "Effect of Batch Size on Inference Speed", 
                         "Batch Size", "batch_size_benchmark.png")
    
    if args.all or args.threads:
        print("\n=== Benchmarking Thread Counts ===")
        thread_results = benchmark_thread_counts(args.model, args.prompt)
        results["benchmarks"]["thread_counts"] = thread_results
        if args.plot:
            plot_results(thread_results, "n_threads", "Effect of Thread Count on Inference Speed", 
                         "Number of Threads", "thread_count_benchmark.png")
    
    if args.all or args.layers:
        print("\n=== Benchmarking GPU Layer Counts ===")
        layer_results = benchmark_gpu_layers(args.model, args.prompt)
        results["benchmarks"]["gpu_layers"] = layer_results
        if args.plot:
            plot_results(layer_results, "n_gpu_layers", "Effect of GPU Layer Count on Inference Speed", 
                         "GPU Layer Percentage", "gpu_layer_benchmark.png")
    
    # Save results
    with open(args.output, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"\nResults saved to {args.output}")
    
    # Determine optimal settings
    optimal = {"message": "Optimal settings based on benchmarks:"}
    
    if "batch_sizes" in results["benchmarks"]:
        best_batch = max(results["benchmarks"]["batch_sizes"], 
                         key=lambda x: x.get('tokens_per_second', 0))
        optimal["batch_size"] = best_batch["batch_size"]
    
    if "thread_counts" in results["benchmarks"]:
        best_threads = max(results["benchmarks"]["thread_counts"], 
                           key=lambda x: x.get('tokens_per_second', 0))
        optimal["n_threads"] = best_threads["n_threads"]
    
    if "gpu_layers" in results["benchmarks"]:
        best_layers = max(results["benchmarks"]["gpu_layers"], 
                          key=lambda x: x.get('tokens_per_second', 0))
        optimal["n_gpu_layers"] = best_layers["n_gpu_layers"]
    
    results["optimal_settings"] = optimal
    
    # Display optimal settings
    print("\n=== Optimal Settings ===")
    for key, value in optimal.items():
        if key != "message":
            print(f"{key}: {value}")
    
    # Create optimal command
    if len(optimal) > 1:  # If we have at least one optimal setting
        cmd = ["./main", "-m", args.model, "--metal"]
        
        if "batch_size" in optimal:
            cmd.extend(["-b", str(optimal["batch_size"])])
        
        if "n_threads" in optimal:
            cmd.extend(["-t", str(optimal["n_threads"])])
        
        if "n_gpu_layers" in optimal:
            cmd.extend(["-ngl", str(optimal["n_gpu_layers"])])
        
        print("\nOptimal command:")
        print(" ".join(cmd))

if __name__ == "__main__":
    main()
