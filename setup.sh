#!/bin/bash

# The two main directories from your environment variables
TARGET_DIRS=("/workspace/coinlynk-private" "/opt/codex")

echo "========================================="
echo "       PRINTING DIRECTORY STRUCTURE      "
echo "========================================="

for DIR in "${TARGET_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo -e "\n\n---> Directory tree for: $DIR\n"
        
        # Check if the 'tree' command is installed
        if command -v tree &> /dev/null; then
            # Print structure, hiding noisy dependency folders
            tree -a -I 'node_modules|.git|__pycache__|.venv|venv|.mypy_cache' "$DIR"
        else
            # Fallback to 'find' formatted as a tree if 'tree' is not installed
            find "$DIR" \
                -name "node_modules" -prune -o \
                -name ".git" -prune -o \
                -name "__pycache__" -prune -o \
                -name "venv" -prune -o \
                -name ".venv" -prune -o \
                -name ".mix" -prune -o \
                -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
        fi
    else
        echo "[!] Directory $DIR does not exist or is inaccessible."
    fi
done
