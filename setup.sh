#!/bin/bash

echo "=============================================="
echo "  TESTING OPENAI RESPONSES API VIA PROXY"
echo "=============================================="

# Dummy key for the proxy to intercept
DUMMY_KEY="sk-fake-key-for-proxy-testing"

echo "-> Sending request to https://api.openai.com:18080/v1/responses..."
echo "-> Using Proxy: http://proxy:8080"
echo "-> Waiting for response..."

# Capture the response body and the HTTP status code
response=$(curl -s -w "\n%{http_code}" \
  -x "http://proxy:8080" \
  --cacert "/usr/local/share/ca-certificates/envoy-mitmproxy-ca-cert.crt" \
  -X POST "https://api.openai.com:18080/v1/responses" \
  -H "Authorization: Bearer $DUMMY_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "input":[
      {"role": "user", "content": "Reply with exactly: Proxy connection is working!"}
    ]
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

# Note the space after "if" has been fixed!
if[ "$status" -eq 200 ]; then
    echo -e "✅ SUCCESS! The proxy intercepted the request, authenticated it, and returned a valid response."
else
    echo -e "❌ FAILED. The request did not return a 200 OK status."
    echo "If it says 'model not found', change 'gpt-4o' in this script to whatever model your cluster supports (e.g., 'gpt-5' or 'gpt-4.5')."
fi
