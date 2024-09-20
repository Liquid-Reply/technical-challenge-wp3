##### Workload Identity for Keycloak-system ##########
export CLUSTER_NAME="cluster-integral-frog"
export RESOURCE_GROUP="tech-challenge"

export AKS_OIDC_ISSUER="$(az aks show --name "${CLUSTER_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --query "oidcIssuerProfile.issuerUrl" \
    --output tsv)"

export USER_ASSIGNED_IDENTITY_NAME="tech-challenge-aks-user-id"
export LOCATION="germanywestcentral"
export SUBSCRIPTION="7b3d4e1a-f9d3-4450-b88e-759cff82af4d"

az identity create \
    --name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --subscription "${SUBSCRIPTION}"

export USER_ASSIGNED_CLIENT_ID="$(az identity show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --query 'clientId' \
    --output tsv)"

export SERVICE_ACCOUNT_NAME="tech-challenge-aks-sa"
export SERVICE_ACCOUNT_NAMESPACE="keycloak-system"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${USER_ASSIGNED_CLIENT_ID}"
  name: "${SERVICE_ACCOUNT_NAME}"
  namespace: "${SERVICE_ACCOUNT_NAMESPACE}"
EOF


export FEDERATED_IDENTITY_CREDENTIAL_NAME="tech-challenge-aks-federated-identity-creds"
az identity federated-credential create \
    --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} \
    --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --issuer "${AKS_OIDC_ISSUER}" \
    --subject system:serviceaccount:"${SERVICE_ACCOUNT_NAMESPACE}":"${SERVICE_ACCOUNT_NAME}" \
    --audience api://AzureADTokenExchange


####################################################################################################################################
##### Workload Identity for cert manager ##########
export CLUSTER_NAME="cluster-integral-frog"
export RESOURCE_GROUP="tech-challenge"

export USER_ASSIGNED_IDENTITY_NAME="tech-challenge-aks-cert-manager-user-id"
export LOCATION="germanywestcentral"
export SUBSCRIPTION="7b3d4e1a-f9d3-4450-b88e-759cff82af4d"

az identity create \
    --name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --subscription "${SUBSCRIPTION}"

export USER_ASSIGNED_CLIENT_ID="$(az identity show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --query 'clientId' \
    --output tsv)"

export DOMAIN_NAME="keycloak.full-coral.cc"
export DNS_ZONE_ID=$(az network dns zone show --name $DOMAIN_NAME --resource-group "${RESOURCE_GROUP}" -o tsv --query id)

az role assignment create \
    --role "DNS Zone Contributor" \
    --assignee $USER_ASSIGNED_CLIENT_ID \
    --scope $DNS_ZONE_ID

export SERVICE_ACCOUNT_NAME="tech-challenge-cert-manager-sa"
export SERVICE_ACCOUNT_NAMESPACE="cert-manager"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${USER_ASSIGNED_CLIENT_ID}"
  name: "${SERVICE_ACCOUNT_NAME}"
  namespace: "${SERVICE_ACCOUNT_NAMESPACE}"
EOF


export FEDERATED_IDENTITY_CREDENTIAL_NAME="tech-challenge-cert-manager-federated-identity-creds"
az identity federated-credential create \
    --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} \
    --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --issuer "${AKS_OIDC_ISSUER}" \
    --subject "system:serviceaccount:cert-manager:cert-manager" \
    --audience api://AzureADTokenExchange


####################################################################################################################################
##### Workload Identity for external dnss ##########


# Create a managed identity
export CLUSTER_NAME="cluster-integral-frog"
export RESOURCE_GROUP="tech-challenge"

export USER_ASSIGNED_IDENTITY_NAME="tech-challenge-aks-external-dns-user-id"
export LOCATION="germanywestcentral"
export SUBSCRIPTION="7b3d4e1a-f9d3-4450-b88e-759cff82af4d"

az identity create \
    --name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --subscription "${SUBSCRIPTION}"

export USER_ASSIGNED_CLIENT_ID="$(az identity show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --query 'clientId' \
    --output tsv)"
export AZURE_DNS_ZONE="keycloak.full-coral.cc"

export DNS_ID=$(az network dns zone show --name "${AZURE_DNS_ZONE}" --resource-group "${RESOURCE_GROUP}" --query "id" --output tsv)
export RESOURCE_GROUP_ID=$(az group show --name "${RESOURCE_GROUP}" --query "id" --output tsv)

az role assignment create --role "DNS Zone Contributor" --assignee "${USER_ASSIGNED_CLIENT_ID}" --scope "${DNS_ID}" 
az role assignment create --role "Reader" --assignee "${USER_ASSIGNED_CLIENT_ID}" --scope "${RESOURCE_GROUP_ID}"

export AKS_OIDC_ISSUER="$(az aks show --name "${CLUSTER_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --query "oidcIssuerProfile.issuerUrl" \
    --output tsv)"

export FEDERATED_IDENTITY_CREDENTIAL_NAME="tech-challenge-external-dns-federated-identity-creds"
az identity federated-credential create \
    --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} \
    --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --issuer "${AKS_OIDC_ISSUER}" \
    --subject "system:serviceaccount:external-dns:external-dns"


export SERVICE_ACCOUNT_NAME="external-dns"
export SERVICE_ACCOUNT_NAMESPACE="external-dns"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${USER_ASSIGNED_CLIENT_ID}"
  name: "${SERVICE_ACCOUNT_NAME}"
  namespace: "${SERVICE_ACCOUNT_NAMESPACE}"
EOF


# {
#   "audiences": [
#     "api://AzureADTokenExchange"
#   ],
#   "id": "/subscriptions/7b3d4e1a-f9d3-4450-b88e-759cff82af4d/resourcegroups/tech-challenge/providers/Microsoft.ManagedIdentity/userAssignedIdentities/tech-challenge-aks-external-dns-user-id/federatedIdentityCredentials/tech-challenge-external-dns-federated-identity-creds",
#   "issuer": "https://germanywestcentral.oic.prod-aks.azure.com/b00367e2-193a-4f48-94de-7245d45c0947/b4e54de3-aa37-4c8b-bb26-363f5508e7a4/",
#   "name": "tech-challenge-external-dns-federated-identity-creds",
#   "resourceGroup": "tech-challenge",
#   "subject": "system:serviceaccount:external-dns:external-dns",
#   "systemData": null,
#   "type": "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials"
# }