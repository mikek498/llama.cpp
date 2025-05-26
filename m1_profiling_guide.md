# Profiling and Benchmarking llama.cpp on Apple M1

This guide provides detailed steps for profiling and benchmarking llama.cpp performance on Apple M1 processors to identify bottlenecks and verify optimizations.

## Tools for Profiling

### 1. Instruments (Apple's Official Profiling Tool)

Instruments provides comprehensive profiling for Metal applications:

1. Open Instruments from Xcode: Xcode → Open Developer Tool → Instruments
2. Select "Metal System Trace" template
3. Choose your llama.cpp executable
4. Run your inference workload
5. Analyze the results, focusing on:
   - GPU utilization
   - Memory bandwidth
   - Kernel execution time
   - CPU/GPU synchronization points

### 2. Command-Line Performance Metrics

```bash
# Basic benchmarking
time ./main -m model.gguf -p "Your prompt" -n 128 --metal

# Using Apple's performance tools
sudo powermetrics --samplers gpu_stats --sample-rate=1000 | grep "GPU active" &
./main -m model.gguf -p "Your prompt" -n 128 --metal
```

### 3. Built-in Benchmark Mode

The `-bench` parameter allows for standardized benchmarking:

```bash
./main -m model.gguf -bench
```

## Key Performance Metrics to Monitor

1. **Tokens per second**: The primary metric for inference speed
2. **GPU utilization**: Should be consistently high (>80%)
3. **Memory transfer time**: Should be minimized
4. **Kernel execution time**: Look for bottlenecks in specific operations
5. **CPU utilization**: Should be optimized for prompt processing and post-processing

## Common Bottlenecks on M1

1. **Memory transfers**: The unified memory architecture should minimize these, but inefficient implementations can still cause problems
2. **Inefficient shader code**: Shaders not optimized for M1's GPU architecture
3. **Thread organization**: Suboptimal thread grouping for M1's GPU cores
4. **Batch size**: Too small or too large batch sizes can impact performance
5. **Synchronization points**: Excessive synchronization between CPU and GPU

## Optimization Verification

After applying optimizations, verify improvements using:

```bash
# Before optimization
./main_original -m model.gguf -p "Your benchmark prompt" -n 1000 --metal > results_before.txt

# After optimization
./main_optimized -m model.gguf -p "Your benchmark prompt" -n 1000 --metal > results_after.txt

# Compare the tokens per second
grep "eval time" results_*.txt
```

## Advanced: Metal Shader Debugging

For deep optimization of Metal shaders:

1. Enable GPU Frame Capture in Xcode
2. Use the Metal Shader Debugger to analyze shader performance
3. Identify hotspots in shader execution
4. Optimize memory access patterns and arithmetic operations

## Memory Usage Optimization

To monitor and optimize memory usage:

```bash
# Monitor memory usage
vmmap <pid_of_llama_process> | grep "Metal"

# Optimize with lower memory settings
./main -m model.gguf -c 2048 --metal --memory-f16
```
