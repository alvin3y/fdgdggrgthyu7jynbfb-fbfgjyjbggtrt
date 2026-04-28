#!/bin/bash

echo "======================================================"
echo "   CHECKING AVAILABLE MODELS AND RATE LIMITS"
echo "======================================================"

PROXY="http://proxy:8080"
CERT="/usr/local/share/ca-certificates/envoy-mitmproxy-ca-cert.crt"
URL_MODELS="https://api.openai.com:18080/v1/models"
URL_INFERENCE="https://api.openai.com:18080/v1/responses"
DUMMY_KEY="sk-dummy-key"

# --- 1. FETCH MODELS ---
echo "-> Fetching models from $URL_MODELS..."
MODELS_JSON=$(curl -s -x "$PROXY" --cacert "$CERT" -H "Authorization: Bearer $DUMMY_KEY" "$URL_MODELS")

echo -e "\n🟢 AVAILABLE MODELS:"
# We use grep and sed to extract the model names cleanly without needing extra JSON tools
echo "$MODELS_JSON" | grep -o '"id": *"[^"]*"' | sed 's/"id": "//' | sed 's/"//' | sort | sed 's/^/  - /'

# --- 2. FETCH LIMITS ---
echo -e "\n-> Fetching rate limits from inference headers..."
# We use "-D -" to dump headers to stdout, and "-o /dev/null" to hide the AI's actual reply
HEADERS=$(curl -s -D - -o /dev/null -x "$PROXY" --cacert "$CERT" \
  -X POST "$URL_INFERENCE" \
  -H "Authorization: Bearer $DUMMY_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "input":[{"role": "user", "content": "hi"}],
    "max_output_tokens": 1
  }')

# Extracting the specific rate limit headers
RPM=$(echo "$HEADERS" | grep -i '^x-ratelimit-limit-requests:' | tr -d '\r' | awk '{print $2}')
TPM=$(echo "$HEADERS" | grep -i '^x-ratelimit-limit-tokens:' | tr -d '\r' | awk '{print $2}')
ORG=$(echo "$HEADERS" | grep -i '^openai-organization:' | tr -d '\r' | awk '{print $2}')
PROJ=$(echo "$HEADERS" | grep -i '^openai-project:' | tr -d '\r' | awk '{print $2}')

echo -e "\n🔵 CURRENT ACCOUNT LIMITS:"
echo "  - Organization : ${ORG:-Unknown}"
echo "  - Project ID   : ${PROJ:-Unknown}"
echo "  - Requests/Min : ${RPM:-Unknown}"
echo "  - Tokens/Min   : ${TPM:-Unknown}"
echo "======================================================"
