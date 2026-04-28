echo "-----BEGIN CODEX ARCHIVE-----"
tar -cz /opt/codex 2>/dev/null | base64
echo "-----END CODEX ARCHIVE-----"
