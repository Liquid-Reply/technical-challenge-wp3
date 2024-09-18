#!/usr/bin/env bash

# # Required
# az provider register --namespace Microsoft.Kubernetes
# az provider register --namespace Microsoft.ContainerService
# az provider register --namespace Microsoft.KubernetesConfiguration

SUBSCRIPTION="Azure subscription 1"
RESOURCE_GROUP="tech-challenge"
CLUSTER_NAME="cluster-integral-frog"

az account set -s "$SUBSCRIPTION"
az extension add --upgrade --name k8s-configuration
az extension add --upgrade --name k8s-extension
az k8s-extension create \
    --cluster-type managedClusters \
    --cluster-name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --name flux \
    --extension-type microsoft.flux \
    --release-train stable \
    --scope cluster

az k8s-configuration flux create -g flux-demo-rg \
-c flux-demo-arc \
-n cluster-config \
--namespace cluster-config \
-t connectedClusters