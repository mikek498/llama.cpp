import subprocess
import re
import csv
import os
import time
import json
import urllib.request
import signal # For terminating server process

# --- Configuration ---
WORKSPACE_ROOT = "/Users/mk/dev/2025/llama.cpp" # Should be robustly determined if possible
# LLAMA_CLI_PATH = os.path.join(WORKSPACE_ROOT, "build", "bin", "llama-cli") # No longer needed
LLAMA_SERVER_PATH = os.path.join(WORKSPACE_ROOT, "build", "bin", "llama-server")
MODEL_PATH = os.path.join(WORKSPACE_ROOT, "models", "Phi-3-mini-4k-instruct-q4.gguf")
OUTPUT_CSV_PATH = os.path.join(WORKSPACE_ROOT, "phi3_server_accelerate_test.csv") # New CSV for this specific test
PROMPT = "Write a detailed step-by-step guide on how to bake a sourdough bread, including starter care."
TOKENS_TO_PREDICT = 256 # This will be n_predict in the API call
CONTEXT_SIZE = 2048
# BATCH_SIZE for llama-cli is not directly equivalent to server-side batching,
# server handles its own batching via --cont-batching (enabled by default)
# We might add server-side --batch-size or --ubatch-size to server_cmd if needed for tuning.
CPU_CORES = 10 # Determined from sysctl -n hw.ncpu

SERVER_HOST = "127.0.0.1"
SERVER_PORT = 8080
SERVER_URL = f"http://{SERVER_HOST}:{SERVER_PORT}"
COMPLETION_ENDPOINT = f"{SERVER_URL}/completion"

# --- Test Configurations (Focus on ubatch with optimal settings + QoS) ---
# Best base config from previous tests: ngl=35, threads=1, mmap=enabled, flash_attn=True
NGL_VALUE = 35
THREADS_VALUE = 1 
NO_MMAP_VALUE = False
FLASH_ATTN_VALUE = True
UBATCH_VALUES = [512, 256, 128] # Test ubatch sizes again with QoS change
PROCESS_PRIO_VALUE = 1 # 0:normal, 1:medium, 2:high, 3:realtime (for POSIX nice values)

def get_generated_token_count(response_content, requested_tokens):
    # Attempt to parse actual tokens generated if server provides it,
    # otherwise assume it generated the requested number if successful.
    # This depends on the exact response structure from /completion.
    # A common field is "tokens_completed" or similar in the stats.
    # For now, let's assume if no specific count is found, it generated what was asked.
    try:
        # Example: if response_content has a 'usage': {'completion_tokens': N}
        if 'usage' in response_content and 'completion_tokens' in response_content['usage']:
            return response_content['usage']['completion_tokens']
        # llama.cpp /completion often returns "tokens_evaluated" for prompt and "tokens_predicted" for generation
        if 'tokens_predicted' in response_content:
             return response_content['tokens_predicted']
        # Fallback if the exact key is not found or structure is different
        # We could also count tokens in response_content['content'] using a tokenizer,
        # but that's more complex for this script.
        # Assuming it tried to generate n_predict tokens.
        return requested_tokens
    except Exception:
        return requested_tokens # Fallback

def run_test_iteration(ngl, threads, use_no_mmap_flag, use_flash_attn_flag, ubatch_size):
    server_cmd = [
        LLAMA_SERVER_PATH,
        "-m", MODEL_PATH,
        "-c", str(CONTEXT_SIZE),
        "-ngl", str(ngl),
        "-t", str(threads),
        "-ub", str(ubatch_size), 
        "--host", SERVER_HOST,
        "--port", str(SERVER_PORT),
        "--no-warmup",
        "--prio", str(PROCESS_PRIO_VALUE) # Corrected argument name
    ]
    if use_no_mmap_flag:
        server_cmd.append("--no-mmap")
    if use_flash_attn_flag:
        server_cmd.append("--flash-attn") # Add flash attention flag

    print(f"Starting server: {' '.join(server_cmd)}")
    server_process = None
    try:
        # Start the server
        # Redirect stdout/stderr to DEVNULL if they are too noisy for the test script output
        server_process = subprocess.Popen(server_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        # For debugging, let server output to console:
        # server_process = subprocess.Popen(server_cmd)

        # --- Health Check Loop ---
        server_ready = False
        max_retries = 20  # Max attempts to check server readiness
        retry_delay = 2  # Seconds to wait between retries
        health_url = SERVER_URL + "/health" # Standard health endpoint

        print(f"Waiting for server to be ready at {SERVER_URL}...")
        for attempt in range(max_retries):
            try:
                # First try /health endpoint
                with urllib.request.urlopen(health_url, timeout=2) as response:
                    if response.status == 200:
                        health_data = json.loads(response.read().decode('utf-8'))
                        if health_data.get("status") == "ok" or health_data.get("status") == "ready": # llama.cpp uses "ok" or "ready"
                            print("Server reported healthy.")
                            server_ready = True
                            break
                        else:
                            print(f"Health check attempt {attempt+1}/{max_retries}: Status '{health_data.get('status')}', waiting...")
            except urllib.error.URLError as e:
                # /health might not exist or server not up, try to connect to /completion as a basic check
                # print(f"Health check (attempt {attempt+1}) failed with URLError: {e}. Trying /completion as fallback check.")
                try:
                    # Minimal request to see if the port is open and server is responding at all
                    # This doesn't send a full prompt, just checks connection.
                    with urllib.request.urlopen(SERVER_URL, timeout=2) as simple_response: # Check base URL
                         if simple_response.status == 200: # Check for a 200 on base URL (often serves Web UI)
                            print(f"Server base URL responded on attempt {attempt+1}/{max_retries}. Assuming server is starting.")
                            # Give it a bit more time after this basic check before trying the actual completion
                            time.sleep(5) # Additional grace period
                            server_ready = True
                            break
                except urllib.error.URLError:
                    # print(f"Fallback check to {SERVER_URL} also failed on attempt {attempt+1}")
                    pass # Continue to next attempt
                except Exception as e_fallback:
                    # print(f"Fallback check to {SERVER_URL} failed with other error: {e_fallback}")
                    pass # Continue to next attempt

            except json.JSONDecodeError:
                print(f"Health check attempt {attempt+1}/{max_retries}: Received non-JSON response from /health, assuming not ready.")
            except Exception as e:
                print(f"Health check attempt {attempt+1}/{max_retries} failed with unexpected error: {e}")
            
            if attempt < max_retries -1 :
                 print(f"    Server not ready yet (attempt {attempt+1}/{max_retries}). Retrying in {retry_delay}s...")
                 time.sleep(retry_delay)
            else:
                print("Server did not become ready after max retries.")
                raise ConnectionError("Server failed to start or become healthy.")
        
        if not server_ready:
            raise ConnectionError("Server did not become ready after max retries.")
        # --- End Health Check Loop ---

        # Prepare API request
        payload = {
            "prompt": PROMPT,
            "n_predict": TOKENS_TO_PREDICT,
            "stream": False,
            "temperature": 0.1 # Keep it deterministic
            # Add other sampling params if needed, but keep simple for perf test
        }
        data = json.dumps(payload).encode('utf-8')
        req = urllib.request.Request(COMPLETION_ENDPOINT, data=data, headers={'Content-Type': 'application/json'})

        api_start_time = time.perf_counter()
        with urllib.request.urlopen(req, timeout=180) as response: # Increased timeout
            response_body = response.read().decode('utf-8')
            response_json = json.loads(response_body)
        api_end_time = time.perf_counter()

        api_time_ms = (api_end_time - api_start_time) * 1000
        
        # Assuming TOKENS_TO_PREDICT were generated if successful
        # More robust: parse actual token count from response_json if available
        generated_tokens = get_generated_token_count(response_json, TOKENS_TO_PREDICT)

        if api_time_ms > 0 and generated_tokens > 0:
            client_tps = (generated_tokens / api_time_ms) * 1000
        else:
            client_tps = 0

        return {
            "api_time_ms": api_time_ms,
            "generated_tokens": generated_tokens,
            "client_tps": client_tps,
            "error_info": None
        }

    except urllib.error.URLError as e:
        print(f"API request failed: {e}")
        return {"api_time_ms": None, "generated_tokens": None, "client_tps": None, "error_info": str(e)}
    except Exception as e:
        print(f"An error occurred during test: {e}")
        return {"api_time_ms": None, "generated_tokens": None, "client_tps": None, "error_info": str(e)}
    finally:
        if server_process:
            print("Terminating server...")
            # Try to terminate gracefully, then kill if necessary
            server_process.terminate()
            try:
                server_process.wait(timeout=5) # Wait for graceful termination
            except subprocess.TimeoutExpired:
                print("Server did not terminate gracefully, killing...")
                server_process.kill()
            print("Server terminated.")


def main():
    if not os.path.exists(MODEL_PATH):
        print(f"Error: Model file not found at {MODEL_PATH}")
        return
    if not os.path.exists(LLAMA_SERVER_PATH):
        print(f"Error: llama-server not found at {LLAMA_SERVER_PATH}")
        return

    fieldnames = [
        "ngl", "threads", "no_mmap", "flash_attn", "ubatch_size", "process_prio",
        "api_time_ms", "generated_tokens", "client_tps", "error_info"
    ]
    results_data = []

    for ubatch_val in UBATCH_VALUES:
        print(f"--- Testing with Server: NGL={NGL_VALUE}, Threads={THREADS_VALUE}, NoMmap={NO_MMAP_VALUE}, FlashAttn={FLASH_ATTN_VALUE}, Ubatch={ubatch_val}, Prio={PROCESS_PRIO_VALUE} ---")
        metrics = run_test_iteration(NGL_VALUE, THREADS_VALUE, NO_MMAP_VALUE, FLASH_ATTN_VALUE, ubatch_val)
        
        row = {
            "ngl": NGL_VALUE,
            "threads": THREADS_VALUE,
            "no_mmap": NO_MMAP_VALUE,
            "flash_attn": FLASH_ATTN_VALUE,
            "ubatch_size": ubatch_val,
            "process_prio": PROCESS_PRIO_VALUE,
            "api_time_ms": metrics.get("api_time_ms"),
            "generated_tokens": metrics.get("generated_tokens"),
            "client_tps": metrics.get("client_tps"),
            "error_info": metrics.get("error_info"),
        }
        results_data.append(row)

        client_tps_val = metrics.get("client_tps", "N/A")
        if isinstance(client_tps_val, float): client_tps_val = f"{client_tps_val:.2f}"
        api_time_val = metrics.get("api_time_ms", "N/A")
        if isinstance(api_time_val, float): api_time_val = f"{api_time_val:.2f}"

        print(f"    Ubatch Size: {ubatch_val}")
        print(f"    Process Priority: {PROCESS_PRIO_VALUE}")
        print(f"    API Time (ms): {api_time_val}")
        print(f"    Client Tokens/Sec: {client_tps_val}")
        if metrics.get("error_info"):
            print(f"    Error: {metrics.get("error_info")}")

    with open(OUTPUT_CSV_PATH, 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results_data)

    print(f"--- Ubatch tests with Accelerate build complete. Results saved to {OUTPUT_CSV_PATH} ---")

if __name__ == "__main__":
    main() 