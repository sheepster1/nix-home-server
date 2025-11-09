#!/usr/bin/env bash

# Variables
CERT_DIR="/tmp/homeassistant-tls"
CERT_FILE="$CERT_DIR/tls.crt"
KEY_FILE="$CERT_DIR/tls.key"
SECRET_NAME="homeassistant-tls-secret"
DOMAIN="homeassistant.smart.local"
NAMESPACE="apps"

# Create directory for certificates
mkdir -p $CERT_DIR

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout $KEY_FILE -out $CERT_FILE \
  -subj "/CN=$DOMAIN/O=homeassistant-tls"

# Create Kubernetes secret
kubectl create secret tls $SECRET_NAME \
  --cert=$CERT_FILE --key=$KEY_FILE -n $NAMESPACE

# Clean up
rm -rf $CERT_DIR