#!/bin/bash

echo "=========================================================="
echo "          DEEP PROXY NETWORK DIAGNOSTICS"
echo "=========================================================="

PROXY_HOSTNAME="proxy"
PROXY_IP="172.30.4.163"
PROXY_PORT="8080"
CERT_PATH="/usr/local/share/ca-certificates/envoy-mitmproxy-ca-cert.crt"
DUMMY_KEY="sk-dummy-key"

echo -e "\n--- 1. DNS RESOLUTION (How do we know who 'proxy' is?) ---"
# Check /etc/hosts to see if it's hardcoded locally
echo ">> Looking in /etc/hosts:"
grep -i "proxy" /etc/hosts || echo "Not found in /etc/hosts"

echo ">> Looking up via DNS/getent:"
getent hosts $PROXY_HOSTNAME || echo "DNS Lookup failed"

echo -e "\n--- 2. ROUTING (How do packets reach 172.30.4.163?) ---"
# Check the routing table to see if it's a Docker network or internal VLAN
if command -v ip >/dev/null 2>&1; then
    ip route get $PROXY_IP || echo "ip route failed"
else
    echo "ip command not available in this environment."
fi

echo -e "\n--- 3. PORT CONNECTIVITY (Is the proxy actually listening?) ---"
# Check if port 8080 is actually open using bash sockets (works even if ping is blocked)
timeout 3 bash -c "</dev/tcp/$PROXY_IP/$PROXY_PORT" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ PORT 8080 IS OPEN AND ACCEPTING CONNECTIONS ON $PROXY_IP!"
else
    echo "❌ PORT 8080 IS CLOSED OR BLOCKED BY FIREWALL."
fi

echo -e "\n--- 4. CERTIFICATE INSPECTION ---"
if [ -f "$CERT_PATH" ]; then
    echo ">> Certificate Issuer details:"
    openssl x509 -in "$CERT_PATH" -noout -issuer -subject -dates
else
    echo "Certificate not found."
fi

echo -e "\n--- 5. RAW HTTP/TLS CONNECTION TRACE ---"
echo "Performing a verbose trace of the proxy connection..."

# We use --trace-ascii to dump the absolute raw text of the HTTP connection.
# We pipe it into grep to filter out giant binary blocks, so we just see the headers.
curl -s --trace-ascii - -x "http://$PROXY_HOSTNAME:$PROXY_PORT" \
  --cacert "$CERT_PATH" \
  -X POST "https://api.openai.com:18080/v1/responses" \
  -H "Authorization: Bearer $DUMMY_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "gpt-4o", "input":[{"role": "user", "content": "hi"}], "max_output_tokens": 1}' | \
  grep -E -A 2 -B 2 "=> Send header|<= Recv header|CONNECT|HTTP/|Authorization"

echo -e "\n=========================================================="
echo "                   DIAGNOSTICS COMPLETE"
echo "=========================================================="
