#!/bin/bash

# List of potential configuration files based on your directory tree
FILES_TO_CHECK=(
    "/workspace/coinlynk-private/.env"
    "/workspace/coinlynk-private/.env.production"
    "/workspace/coinlynk-private/auth_config.json"
    "/opt/codex/config.toml"
)

echo "=========================================================="
echo "          EXTRACTING ALL CONFIGURATION DATA               "
echo "=========================================================="

for FILE in "${FILES_TO_CHECK[@]}"; do
    echo ""
    echo "----------------------------------------------------------"
    echo "▶ DUMPING FILE: $FILE"
    echo "----------------------------------------------------------"
    
    if [ -f "$FILE" ]; then
        # Print the entire file content
        cat "$FILE"
    else
        echo "[!] File not found or inaccessible."
    fi
done
echo ""
echo "======================== END ========================"
