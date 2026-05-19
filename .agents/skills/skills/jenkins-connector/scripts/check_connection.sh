#!/bin/bash
set -e

# Validate Environment
if [ -z "$JENKINS_USER" ] || [ -z "$JENKINS_TOKEN" ]; then
  echo "Error: JENKINS_USER and JENKINS_TOKEN must be set."
  exit 1
fi


JENKINS_URL="${JENKINS_URL:-https://dese-jenkins.umov.me}"

# Check dependencies
if ! command -v curl &> /dev/null; then
    echo "❌ Error: 'curl' is required but not installed."
    exit 1
fi

echo "Testing connection to Jenkins API ($JENKINS_URL)..."

# Execute Request (Get User Info or Master Info)
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  "${JENKINS_URL}/user/${JENKINS_USER}/api/json")

# Check Result
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | awk -F: '{print $2}')
BODY=$(echo "$RESPONSE" | sed 's/HTTP_CODE:.*//')

if [ "$HTTP_CODE" -eq 200 ]; then
  # JSON extraction without jq
  FULL_NAME=$(echo "$BODY" | grep -o '"fullName":\s*"[^"]*"' | cut -d'"' -f4)
  ID=$(echo "$BODY" | grep -o '"id":\s*"[^"]*"' | cut -d'"' -f4)
  echo "✅ Connection Successful!"
  echo "Authenticated as: $FULL_NAME ($ID)"
else
  # Try fallback to root API if user API fails (permissions vary)
  RESPONSE_ROOT=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
    --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
    "${JENKINS_URL}/api/json")

  HTTP_CODE_ROOT=$(echo "$RESPONSE_ROOT" | grep "HTTP_CODE" | awk -F: '{print $2}')

  if [ "$HTTP_CODE_ROOT" -eq 200 ]; then
     echo "✅ Connection Successful (Root API)!"
     echo "User: $JENKINS_USER"
  else
    echo "❌ Connection Failed (HTTP $HTTP_CODE)"
    echo "$BODY"
    exit 1
  fi
fi
