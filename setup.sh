#!/bin/bash

PROXY="http://proxy:8080"
CERT="/usr/local/share/ca-certificates/envoy-mitmproxy-ca-cert.crt"
DUMMY_KEY="sk-dummy-key"

echo "=========================================="
echo "    1. RAW DUMP OF /v1/models ENDPOINT"
echo "=========================================="
# Using -i to see the HTTP status code (e.g., 404 or 403)
curl -i -s -x "$PROXY" --cacert "$CERT" \
  -H "Authorization: Bearer $DUMMY_KEY" \
  "https://api.openai.com:18080/v1/models"

echo -e "\n\n=========================================="
echo "    2. RAW HEADERS FROM A SUCCESSFUL REQUEST"
echo "=========================================="
# Using exactly the payload we know works, capturing only the headers (head -n 25)
curl -i -s -x "$PROXY" --cacert "$CERT" \
  -X POST "https://api.openai.com:18080/v1/responses" \
  -H "Authorization: Bearer $DUMMY_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "input": [{"role": "user", "content": "Hi"}]
  }' | head -n 25
