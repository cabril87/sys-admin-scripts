#!/bin/bash
# system_info.sh
# Collects system information on Windows and saves it to a timestamped file in Documents\SysAdminReports

# Default output directory (Windows Documents folder)
DEFAULT_OUTPUT_DIR="$HOME/Documents/SysAdminReports"
OUTPUT_DIR="${1:-$DEFAULT_OUTPUT_DIR}"

# Generate timestamp for unique filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/system_info_$TIMESTAMP.txt"

# Ensure output directory exists
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR" || {
        echo "Error: Failed to create directory '$OUTPUT_DIR'. Check permissions." >&2
        exit 1
    }
fi

# Collect system information using wmic (available in Git Bash or WSL)
OS_NAME=$(wmic os get Caption | sed -n '2p' | tr -d '\r')
OS_VERSION=$(wmic os get Version | sed -n '2p' | tr -d '\r')
CPU_NAME=$(wmic cpu get Name | sed -n '2p' | tr -d '\r')
TOTAL_MEMORY=$(wmic os get TotalVisibleMemorySize | sed -n '2p' | tr -d '\r')
TOTAL_MEMORY_GB=$(echo "scale=2; $TOTAL_MEMORY / 1024 / 1024" | bc)

# Write to file with error handling
{
    echo "System Information Report"
    echo "Generated: $(date)"
    echo "------------------------"
    echo "OS Name: $OS_NAME"
    echo "OS Version: $OS_VERSION"
    echo "CPU: $CPU_NAME"
    echo "Total Memory: $TOTAL_MEMORY_GB GB"
} > "$OUTPUT_FILE" 2>/dev/null || {
    echo "Error: Failed to write to '$OUTPUT_FILE'. Check permissions." >&2
    exit 1
}

# Success message
echo "System information saved to: $OUTPUT_FILE"