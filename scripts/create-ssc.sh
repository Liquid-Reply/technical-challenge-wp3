#!/usr/bin/env bash

CN="$1.full-coral.cc"
O="Full Coral"
C="DE"

openssl req -nodes \
            -x509 \
            -days 365 \
            -newkey rsa:2048 \
            -addext keyUsage=digitalSignature,keyEncipherment \
            -addext "subjectAltName = DNS:$CN" \
            -out "${1}_cert.pem" \
            -keyout "${1}_key.pem" \
            -subj "/CN=$CN/O=$O/C=$C"
openssl x509 -noout -subject -in "${1}_cert.pem"