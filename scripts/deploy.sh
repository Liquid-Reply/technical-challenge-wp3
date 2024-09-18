#!/usr/bin/env bash

kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.5/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.5/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml

CN="keycloak.full-coral.cc"
O="Full Coral"
C="DE"
openssl req -subj "/CN=$CN/O=$O/C=$C" -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem
kubectl create ns keycloak-system
kubectl -n keycloak-system apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.5/kubernetes/kubernetes.yml
kubectl -n keycloak-system create secret tls keycloak.full-coral.cc --cert cert.pem --key key.pem
kubectl -n keycloak-system create secret generic keycloak-db-secret --from-literal=username=testuser --from-literal=password=testpassword
