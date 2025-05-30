#!/bin/bash

# Usage: ./get-sa-token.sh <namespace> <service-account> <api-server> <user-token> <ca-cert-path>
# Example: ./get-sa-token.sh my-namespace my-sa https://api.openshift.example.com:6443 $(oc whoami -t) /path/to/ca.crt

set -euo pipefail

NAMESPACE="$1"
SERVICE_ACCOUNT="$2"
API_SERVER="$3"
USER_TOKEN="$4"
CA_CERT="$5"

echo "Getting token secret for service account: $SERVICE_ACCOUNT in namespace: $NAMESPACE"

# Get the token secret name
SECRET_NAME=$(curl -s \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Accept: application/json" \
  --cacert "$CA_CERT" \
  "$API_SERVER/api/v1/namespaces/$NAMESPACE/serviceaccounts/$SERVICE_ACCOUNT" \
  | jq -r '.secrets[] | select(.name | contains("token")) | .name')

if [ -z "$SECRET_NAME" ]; then
  echo " Failed to find token secret for service account: $SERVICE_ACCOUNT"
  exit 1
fi

echo "Found secret: $SECRET_NAME"

# Get the token value from the secret
TOKEN=$(curl -s \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Accept: application/json" \
  --cacert "$CA_CERT" \
  "$API_SERVER/api/v1/namespaces/$NAMESPACE/secrets/$SECRET_NAME" \
  | jq -r '.data.token' | base64 --decode)

if [ -z "$TOKEN" ]; then
  echo " Failed to decode token from secret: $SECRET_NAME"
  exit 1
fi

echo "Retrieved Token:"
echo "$TOKEN"
