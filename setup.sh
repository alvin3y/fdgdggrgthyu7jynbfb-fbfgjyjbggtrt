curl -i -x "http://proxy:8080" \
  --cacert "/usr/local/share/ca-certificates/envoy-mitmproxy-ca-cert.crt" \
  -X POST "https://api.openai.com:18080/v1/responses" \
  -H "Authorization: Bearer sk-dummy-key-not-real" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "input":[
      {
        "role": "user",
        "content": "Reply with exactly: Proxy connection is working!"
      }
    ]
  }'
