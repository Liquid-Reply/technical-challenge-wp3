# Implement Keycloak HA Setup with External DB

## Architecture

### Current state
![Keycloak Architecture](/assets/Architecture.png)

The architecture is based on Azure Kubernetes Service (AKS) where the compute nodes are spread across availability zones. This allows Keycloak to be deployed in a high availability setup.
Access to Keycloak is facilitated via a load balancer.

Azure Database for PostgreSQL Flexible Server is used as external database for Keycloak.

### Further architecture improvements

>[!IMPORTANT]
>For a production grade setup at least the following aspects have to be considered and implemented form an infrastructure point of view:
* Do not use default virtual network and subnets.
* Ensure traffic is private and use e.g. a bastion host to connect to the network.
* Use Azure NAT Gateway for internet access (ipv4).
* Use Azure Keyvault to store secrets and use Azure Private Link to connect to it from AKS.
* Use Azure Container Registry and a pull-through cache to store and retrieve OCI artifacts like container images or helm charts to reduce external dependencies.
* Ensure encryption at rest and encryption in transit. This includes managing encryption keys and certificates.
* Use AKS system/agent node pool only for critical workload. Use dedicated user node pools for further workload. Node pools should be deployed to all availability zones.
* Use e.g. Kubernetes RBAC with Azure RBAC integration to manage cluster access.
* Automate the deployment of infrastructure and workload to ensure consistency (use e.g. GitOps approach).
* Use Azure Private Link or VNet Integration to facilitate private access between AKS and Azure Database for PostgreSQL Flexible Server.
* Consider deploying Azure Database for PostgreSQL Flexible Server in `ZoneRedundant` mode and add read replicas which can be promoted in case of failures.
* Use Azure Public and/or Private DNS zones.
* Consider using a web application firewall (either within Kubernetes or as part of the loadbalancer).
* Consider FinOps best practices to ensure reasonable cloud spending. This includes aspects like rightsizing and autoscaling of e.g. compute and storage resources.

## Operations
### Maintenance
#### Deployment
Flux?

#### Connect to cluster
Prerequisites:
* Azure CLI (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli), kubectl (https://kubernetes.io/docs/tasks/tools/) and kubelogin (https://azure.github.io/kubelogin/install.html) are installed (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) on the machine that has access to the cluster. This can be a local machine if cluster has public access enabled or e.g. a bastion host if the cluster is private. To connect to the bastion host you can use the Azure portal (https://portal.azure.com/) to identify the VM and check the connection possibilities.

To connect run the following commands (you can also find them in the Azure Portal via the "Connect" option in the overview tab of the respective Kubernetes cluster):
1. Login on the cli: `az login` (use the flag `--tenant <tenant_id>` if you have access to multiple tenants)
2. Set subscription where the cluster is deployed: `az account set --subscription <subscription_id>`
3. Retrieve access credentials: `az aks get-credentials --resource-group <cluster_resource_group> --name <cluster_name> --overwrite-existing`
4. Use kubelogin plugin for authentication: `kubelogin convert-kubeconfig -l azurecli`
5. Now you can use commands like `kubectl get nodes` to interact with the Kubernetes cluster.

#### Backup
#### Scaling
Kubernetes
DB
Keycloak

#### Change configuration
GitOps

#### Update version
GitOps; rolling update

#### Add/remove users

### Troubleshooting

#### Useful commands for e.g. Logs
ideas:
* kubectl get all pods
* kubectl get keycloak namespace resources
* kubectl describe keycloak resources
* kubectl logs for keycloak pods
* check Flux

#### Check network path
ideas
Pods up and running?
Pods are defined as endpoints in Service?
Ingress points to correct Service?
Ingress controller up and running and no error logs?
Azure LB has healthy targets?
DNS records point to correct service?

### Monitoring
#### Logs
#### Metrics
#### Traces
Is Keycloak exposing metrics?


Notes:

keycloak prod guide: https://www.keycloak.org/server/configuration-production