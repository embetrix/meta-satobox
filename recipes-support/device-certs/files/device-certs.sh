#!/bin/sh
# generate self-signed device certificates
#
# Note: This is not production ready, just for testing purposes
#       the device keys and certs are stored in plain filesystem 
#       so malicious attacked can easily extract them  and implement a MITM attack.
#
#  ToDo: Implement secure storage using a TPM or secure element and a 
#        certificate management for renewal using PKI system such as ECJBCA or smallsteps 
# 

# Get device IP
DEVICE_IP=$(networkctl status | grep Address | awk '{print $2}')
if ! echo "$DEVICE_IP" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
    echo "Invalid device IP: $DEVICE_IP"
    exit 1
fi

HOSTNAME=$(hostname)
# Generate self signed RSA device certificate
if [ ! -f ca-cert.pem ] || [ ! -f ca-key.pem ]; then
    echo "Please generate CA keys first"
    exit 1
fi

if [ ! -f device-key.pem ] || [ ! -f device-cert.pem ]; then
    openssl req -new -newkey rsa:4096 -keyout device-key.pem \
            -out device-csr.pem -nodes \
            -subj "/C=DE/ST=BW/O=Embetrix/OU=DeviceCert/CN=$HOSTNAME" \
            -addext "subjectAltName=DNS:$HOSTNAME, DNS:localhost,IP:$DEVICE_IP,IP:127.0.0.1" || exit 1

    openssl x509 -req -in device-csr.pem -CA ca-cert.pem -CAkey ca-key.pem \
            -CAcreateserial -days 3600 \
            -out device-cert.pem \
            -copy_extensions copy  || exit 1
fi
