#!/bin/bash

# Create the CA key and certificate without a passphrase
openssl genpkey -algorithm RSA -out ca-key.pem
openssl req -x509 -new -nodes -key ca-key.pem -sha256 -days 365 -out ca-cert.pem -config openssl.cnf

# Create the server key and CSR without passphrase
openssl genpkey -algorithm RSA -out server-key.pem
openssl req -new -key server-key.pem -out server.csr -config openssl.cnf

# Sign the server certificate with the CA
openssl x509 -req -in server.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 365 -sha256

# Create the client key and CSR without passphrase
openssl genpkey -algorithm RSA -out client-key.pem
openssl req -new -key client-key.pem -out client.csr -config openssl.cnf

# Sign the client certificate with the CA
openssl x509 -req -in client.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -days 365 -sha256
