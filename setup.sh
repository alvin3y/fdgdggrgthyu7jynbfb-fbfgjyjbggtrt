#!/bin/bash

echo "=============================================="
echo "  TESTING OPENAI API VIA CORPORATE PROXY"
echo "=============================================="

# We provide a completely fake key. If the proxy works, it will replace this.
DUMMY_KEY="sk-fake-key-for-proxy-testing"

echo "-> Sending request to https://api.openai.com:18080..."
echo "-> Using Proxy: http://proxy:8080"
echo "-> Waiting for response..."

# Capture the response body and the HTTP status code
response=$(curl -s -w "\n%{http_code}" \
  -x "http://proxy:8080" \
  --cacert "/usr/local/share/ca-certificates/envoy-mitmproxy-ca-cert.crt" \
  -X POST "https://api.openai.com:18080/v1/chat/completions" \
  -H "Authorization: Bearer $DUMMY_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages":[
      {"role": "user", "content": "Reply with exactly: Proxy connection is working!"}
    ],
    "max_tokens": 20
  }')

# Separate body and status code
body=$(echo "$response" | head -n -1)
status=$(echo "$response" | tail -n 1)

echo ""
echo "----------------------------------------------"
echo "HTTP Status Code: $status"
echo "Raw Response Body:"
echo "$body"
echo "----------------------------------------------"

# Check if the request was successful
if[ "$status" -eq 200 ]; then
    echo -e "✅ SUCCESS! The proxy intercepted the request, authenticated it with the real key, and returned a valid response."
else
    echo -e "❌ FAILED. The request did not return a 200 OK status."
    echo "If it says 'model not found', change 'gpt-3.5-turbo' in this script to whatever model your cluster supports (e.g., 'gpt-4')."
fi
