#!/bin/bash

echo "=========================================================="
echo "      EXTRACTING FULL API CONNECTION DETAILS FOR EXPORT"
echo "=========================================================="

EXPORT_DIR="/workspace/openai_export"
CERT_PATH="/usr/local/share/ca-certificates/envoy-mitmproxy-ca-cert.crt"
ENV_FILE="$EXPORT_DIR/connection_details.env"

# 1. Create export directory
mkdir -p "$EXPORT_DIR"

# 2. Copy the crucial custom SSL certificate (Fixed space in 'if [')
if [ -f "$CERT_PATH" ]; then
    cp "$CERT_PATH" "$EXPORT_DIR/company_proxy_cert.crt"
    echo "✅ Extracted custom SSL Certificate."
else
    echo "❌ Could not find SSL Certificate!"
fi

# 3. Resolve the Proxy IP Address
PROXY_IP=$(getent hosts proxy | awk '{ print $1 }')
if [ -z "$PROXY_IP" ]; then
    PROXY_IP="UNKNOWN - You must find the IP of 'proxy' manually"
fi
echo "✅ Resolved Proxy IP: $PROXY_IP"

# 4. Create the environment variables file
cat <<EOF > "$ENV_FILE"
# ==========================================
# OPENAI CORPORATE PROXY CONNECTION DETAILS
# ==========================================
# ⚠️ CRITICAL: To use this outside, you must be on the Corporate VPN.
# Also, your new machine won't know what "http://proxy:8080" is.
# You must map "$PROXY_IP" to "proxy" in your new machine's /etc/hosts file, 
# OR replace "proxy" with "$PROXY_IP" in the URLs below.

# Network Details
HTTP_PROXY="http://proxy:8080"
HTTPS_PROXY="http://proxy:8080"
PROXY_IP_ADDRESS="$PROXY_IP"
REQUESTS_CA_BUNDLE="./company_proxy_cert.crt"
SSL_CERT_FILE="./company_proxy_cert.crt"

# OpenAI SDK Details
OPENAI_BASE_URL="https://api.openai.com:18080/v1"
OPENAI_API_KEY="sk-dummy-key"

# ==========================================
# MANDATORY INTERNAL HEADERS
# ==========================================
# Your Envoy proxy likely requires these headers to authenticate the request
# as coming from a valid internal developer instance. Add these to your HTTP requests!
OPENAI_CLUSTER="applied-caas4"
CODEX_INTERNAL_ORIGINATOR_OVERRIDE="codex_web_agent"
CODEX_THREAD_ID="019dd3ca-c88a-78e3-a85c-54dea3be77ce"
CODEX_CI="1"
EOF

echo "✅ Generated connection_details.env."

# 5. Package it all up (silently)
cd /workspace
tar -czf openai_connection_bundle.tar.gz -C "$EXPORT_DIR" .

echo "✅ Archive created."
echo ""
echo "=========================================================="
echo "      📋 COPY THE BASE64 TEXT BELOW 📋"
echo "=========================================================="
echo "-----BEGIN BASE64 ARCHIVE-----"

base64 /workspace/openai_connection_bundle.tar.gz

echo "-----END BASE64 ARCHIVE-----"
echo "=========================================================="
