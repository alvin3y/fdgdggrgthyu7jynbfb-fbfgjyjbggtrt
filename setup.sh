#!/bin/bash

echo "--- Searching for OpenAI API Key in configuration files ---"

# Check the main workspace .env files
echo ">> Checking .env files in /workspace/coinlynk-private:"
grep -i -E "openai|api_key|token" /workspace/coinlynk-private/.env /workspace/coinlynk-private/.env.production /workspace/coinlynk-private/.env.example 2>/dev/null

echo -e "\n>> Checking Codex system config:"
grep -i -E "openai|api_key|token|bearer" /opt/codex/config.toml 2>/dev/null
