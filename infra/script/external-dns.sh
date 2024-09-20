# Create Azure DNS Zone, or use an existing one
# You can create a new Azure DNS Zone with or without delegated domain name. Without delegated domain name means it will not be able to publicly resolve the domain name. 
# But you will still see the created DNS records.

export DNS_ZONE_NAME="keycloak.full-coral.cc"
export DNS_ZONE_RG="tech-challenge"

# Create a service principal for ExternalDNS
# ExternalDNS will connect to Azure DNS to change its configuration. So, it needs to be authenticated. As mentioned before, You will be using a Service Principal.
 

export EXTERNALDNS_SPN_NAME="spn-external-dns-aks"

# Create the service principal
export DNS_SPN=$(az ad sp create-for-rbac --name $EXTERNALDNS_SPN_NAME)
export EXTERNALDNS_SPN_APP_ID=$(echo $DNS_SPN | jq -r '.appId')
export EXTERNALDNS_SPN_PASSWORD=$(echo $DNS_SPN | jq -r '.password')


# Assign the RBAC for the service principal
# Grant access to Azure DNS zone for the service principal.

# fetch DNS id and RG used to grant access to the service principal
export DNS_ZONE_ID=$(az network dns zone show -n $DNS_ZONE_NAME -g $DNS_ZONE_RG --query "id" -o tsv)
export  DNS_ZONE_RG_ID=$(az group show -g $DNS_ZONE_RG --query "id" -o tsv)

# assign reader to the resource group
az role assignment create --role "Reader" --assignee $EXTERNALDNS_SPN_APP_ID --scope $DNS_ZONE_RG_ID
# assign contributor to DNS Zone itself
az role assignment create --role "DNS Zone Contributor" --assignee $EXTERNALDNS_SPN_APP_ID --scope $DNS_ZONE_ID

# Verify role assignments.
az role assignment list --all --assignee $EXTERNALDNS_SPN_APP_ID -o table

# Create a Kubernetes secret for the service principal
# ExternalDNS expects to find the Service Principal credentials in a JSON file called azure.json saved as a Kubernetes secret. Let's create the file.

@"
{
  "tenantId": "$(az account show --query tenantId -o tsv)",
  "subscriptionId": "$(az account show --query id -o tsv)",
  "resourceGroup": "$DNS_ZONE_RG",
  "aadClientId": "$EXTERNALDNS_SPN_APP_ID",
  "aadClientSecret": "$EXTERNALDNS_SPN_PASSWORD"
}
"@ > azure.json

cat azure.json
 
# Deploy the credentials as a Kubernetes secret.

kubectl create namespace external-dns
kubectl create secret generic azure-config-file -n external-dns --from-file azure.json

# Deploy External DNS
kubectl apply -f external-dns.yaml -n external-dns

