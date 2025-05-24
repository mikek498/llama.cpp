#!/bin/bash

# Path to the CMakeLists.txt file that contains the ggml_add_cpu_backend_variant_impl function
# This usually is within the ggml submodule.
# Adjust if the function is defined in a different file in your "ASM-fun" branch.
CMAKE_FILE_PATH="/Users/mk/dev/2025/tmp/llama.cpp/ggml/src/CMakeLists.txt"

# The content to insert
# It assumes this CMakeLists.txt is in ggml/src/ and ggml-cpu-optimized.s is in ggml/
# So the relative path to the .s file from ggml/src/ is ../ggml-cpu-optimized.s
INSERT_CONTENT='
    # <<< ADDED BY PATCH SCRIPT TO INCLUDE ggml-cpu-optimized.s >>>
    if (APPLE AND (CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm.*|ARM64)$" OR CMAKE_OSX_ARCHITECTURES MATCHES "arm64"))
        message(STATUS "Patch: Adding ggml-cpu-optimized.s for ARM64 Apple to GGML_CPU_SOURCES")
        # Path relative to the current CMakeLists.txt file (assumed to be ggml/src/)
        # to ggml-cpu-optimized.s (assumed to be in ggml/)
        list(APPEND GGML_CPU_SOURCES ${CMAKE_CURRENT_LIST_DIR}/../ggml-cpu-optimized.s)
    endif()
    # <<< END OF ADDED SECTION >>>
'

# Anchor line before which the content should be inserted
# This is the line where GGML_CPU_SOURCES is initially populated.
# If your file structure is different, this anchor may need adjustment.
# For robustness, it's better to insert before target_sources if this is problematic.
ANCHOR_LINE_PATTERN='list (APPEND GGML_CPU_SOURCES'
# More robust anchor:
# ANCHOR_LINE_PATTERN='target_sources(${GGML_CPU_NAME} PRIVATE ${GGML_CPU_SOURCES})'


# Check if the CMake file exists
if [ ! -f "$CMAKE_FILE_PATH" ]; then
    echo "ERROR: CMake file not found at $CMAKE_FILE_PATH"
    exit 1
fi

# Check if the content (or a marker from it) is already in the file to prevent duplicate additions
if grep -q "ADDED BY PATCH SCRIPT TO INCLUDE ggml-cpu-optimized.s" "$CMAKE_FILE_PATH"; then
    echo "INFO: Patch content seems to be already applied. Skipping."
    exit 0
fi

# Create a temporary file
TMP_FILE=$(mktemp)

# Use awk to insert the content
# This awk script looks for the function definition, then for the anchor line within that function's scope.
gawk -v content="$INSERT_CONTENT" -v anchor_pattern="$ANCHOR_LINE_PATTERN" '
/function\(ggml_add_cpu_backend_variant_impl/ {
    in_function = 1
}
in_function && $0 ~ anchor_pattern {
    if (!inserted) {
        print content
        inserted = 1
    }
}
{ print }
in_function && /endfunction\(\)/ {
    in_function = 0
    # Reset inserted if you have multiple such functions and want to patch all,
    # but for this specific case, it should only be one.
    # inserted = 0
}
' "$CMAKE_FILE_PATH" > "$TMP_FILE"

# Check if awk did something (basic check)
if [ ! -s "$TMP_FILE" ]; then
    echo "ERROR: awk processing failed, temporary file is empty."
    rm "$TMP_FILE"
    exit 1
fi

# Replace the original file with the modified one
mv "$TMP_FILE" "$CMAKE_FILE_PATH"

if [ $? -eq 0 ]; then
    echo "SUCCESS: CMake file '$CMAKE_FILE_PATH' patched."
    echo "Please review the changes manually."
else
    echo "ERROR: Failed to move temporary file to $CMAKE_FILE_PATH."
    # Attempt to clean up tmp file if mv failed but tmp file still exists
    if [ -f "$TMP_FILE" ]; then
        rm "$TMP_FILE"
    fi
    exit 1
fi

exit 0
