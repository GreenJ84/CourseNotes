# Introduction

Azure Container Registry is a managed Docker registry service based on the open source Docker Registry 2.0. Container Registry is private, hosted in Azure, and allows you to build, store, and manage images for container deployments.

You can push and pull container images with Azure Container Registry using the Docker CLI or the Azure CLI. Azure portal integration allows you to visually inspect the container images in your container registry. In distributed environments, you can use the container registry geo-replication feature to distribute container images to multiple Azure data centers for localized distribution.

You can use Azure Container Registry tasks to store and build container images in Azure. Tasks use a standard Dockerfile to create and store the container images in Azure Container Registry without the need for local Docker tooling. With Azure Container Registry tasks, you can build on-demand or fully automate container image builds using DevOps processes and tooling.

## Learning objectives

By the end of this module, you're able to:

Deploy an Azure container registry.
Build and deploy a container image to an Azure container instance using Azure Container Registry tasks.
Replicate a container image to multiple Azure regions.

### Prerequisites

An active Azure subscription.
Ability to use the Azure CLI.

## Use Azure Container Registry to store a container

Azure Container Registry is a registry-hosting service provided by Azure. Each Azure Container Registry resource you create is a separate registry with a unique URL. These registries are private, meaning they require authentication to push or pull images. Azure Container Registry runs in the cloud and provides similar levels of scalability and availability to other Azure services.

### ACR Creation

You can create a registry using the Azure portal or the Azure Command Line Interface (CLI). You can use the Cloud Shell in the Azure portal or a local install of the Azure CLI.

> Note
> If using Cloud Shell, the classic version is needed later in this module to use Docker commands. You must select Settings, then select Go to Classic version.
> if using Azure CLI, the first step to using Azure services is to login using `az login`.

Keep in mind that you need to create a resource group before you can create the registry. When creating a resource group, we recommend choosing the nearest region. In this example, our resource group's name is mygroup, and the location is US West.

> Note
> You need a unique name for your container and must check to see if a name is already in use.

```bash
# Resource Group
az group create --name mygroup --location westus
```

> Note
> Defining an environment variable to hold your container registry name using `ACR_NAME=<unique_name>`. Replace <unique_name> with your container environment name to make commands easier.

```bash
# Container image creation
az acr create --name <unique_name> --resource-group mygroup --sku standard --admin-enabled true
```

Different SKUs provide varying scalability and storage levels.

Azure Container Registry repositories are private, meaning they don't support unauthenticated access. To pull images from an Azure Container Registry repository, use the `docker login` command and specify the URL of the login server for the registry. The login server URL for a registry in Azure Container Registry has the form `<registry_name>.azurecr.io`.

```bash
docker login myregistry.azurecr.io
```

Docker login will prompt you for a username and password. To find this information, go to the Azure portal and look up the access keys for the registry or run the following command.

```bash
az acr credential show --name myregistry --resource-group mygroup
```

You can push an image from your local computer to a Docker registry by using the `docker push` command. Before you push an image, you must create an alias for the image that specifies the repository and tag that the Docker registry creates. The repository name must be of the form `*<login_server>/<image_name>:<tag/>`. Use the `docker tag` command to perform this operation. The following example creates an alias for the reservationsystem image.

```bash
docker tag reservationsystem myregistry.azurecr.io/reservationsystem:v2
```

If you run `docker image ls`, you'll get two entries for the image: one with the original name and the second with the new alias.

After you run the tag command, you can upload the image to the registry in Azure Container Registry using the following command.

```bash
docker push myregistry.azurecr.io/reservationsystem:v2
```

Verify that the image has been uploaded correctly by listing the repositories in the registry with the following command.

```bash
az acr repository list --name myregistry --resource-group mygroup
```

You can also list the images in the registry with the `acr repository show` command.

```bash
az acr repository show --repository reservationsystem --name myregistry --resource-group mygroup
```

> Note
> You'll have at least two tags for each image in a repository. One tag will be the value you specified in the acr build command (v1 in the previous example). The other will be latest. Every time you rebuild an image, Azure Container Registry automatically creates the latest tag as an alias for the most recent version of the image.

## Create a container image using Azure Container Registry Tasks

You use a Dockerfile to provide build instructions. Azure Container Registry Tasks enables you to reuse any Dockerfile currently in your environment, including multi-staged builds. For this example, you create a new Dockerfile that builds a Node.js application.

1. From the Cloud Shell toolbar, select `{}` to open the Cloud Shell editor.

2. The editor opens in a new window above the Bash prompt named Untitled.

On the Bash command line, paste the following command to create a new file in the editor named Dockerfile.

```bash
code Dockerfile
```

3. Copy the following Dockerfile contents into the file. Use keyboard shortcut `Ctrl + V` to paste the contents into the editor.

This Dockerfile uses the `node:25-alpine` image as its base image. It then adds the Node.js application files to the image and installs the application dependencies. Finally, it configures the container to serve the application on port 80 via the EXPOSE instruction.

```Dockerfile
FROM    node:25-alpine
ADD     https://raw.githubusercontent.com/Azure-Samples/acr-build-helloworld-node/master/package.json /
ADD     https://raw.githubusercontent.com/Azure-Samples/acr-build-helloworld-node/master/server.js /
RUN     npm install
EXPOSE  80
CMD     ["node", "server.js"]
```

4. Use `Ctrl + S` to save the updated Dockerfile and then `Ctrl + Q` to close the editor.

5. Build the container image from the Dockerfile using the `az acr build` command.

> Note
> Make sure you add the period (.) to the end of the command. It represents the source directory containing the Dockerfile. Because we didn't specify the name of the file using the --file parameter, the command looks for a file called Dockerfile in our current directory.

```bash
az acr build --registry $ACR_NAME --image helloacrtasks:v1 .
```

6. Verify the image was created and stored in the registry using the `az acr repository list` command.

```bash
az acr repository list --name $ACR_NAME --output table
```

Your output should look similar to the following example output:

```bash
Result
-------------
helloacrtasks
```

## Deploy images from Azure Container Registry

You can pull container images from Azure Container Registry using various container management platforms, like Azure Container Instances, Azure Kubernetes Service, or Docker for Windows or Mac. In this module, you deploy the image to an Azure Container Instance.

### Registry authentication

Azure Container Registry doesn't support unauthenticated access and requires authentication for all operations. Registries support two types of identities:

*Microsoft Entra identities*, including both user and service principals. Access to a registry with a Microsoft Entra identity is role-based, and you can assign identities using one of three roles: Reader (pull access only), Contributor (push and pull access), or Owner (pull, push, and assign roles to other users).
The *admin account* included with each registry. The admin account is disabled by default.

> Important
> The admin account provides a quick option to try a new registry. You can enable the account and use the username and password in workflows and apps that need access. After you confirmed the registry works as expected, you should disable the admin account and use Microsoft Entra identities to ensure the security of your registry. Don't share the admin account credentials with others.

### Enable the registry admin account

1. Enable the admin account on your registry using the `az acr update` command.

```bash
az acr update --name $ACR_NAME --admin-enabled true
```

2. Retrieve the username and password for the admin account using the `az acr credential show` command. The values are stored in the `ACR_USERNAME` and `ACR_PASSWORD` variables for use in the next section.

```bash
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)
```

### Deploy a container with Azure CLI

1. Deploy a container instance using the `az container create` command. The command uses the `ACR_USERNAME` and `ACR_PASSWORD` variables for registry authentication.

```bash
az container create \
  --resource-group learn-acr-rg \
  --name acr-tasks \
  --image $ACR_NAME.azurecr.io/helloacrtasks:v1 \
  --registry-login-server $ACR_NAME.azurecr.io \
  --ip-address Public \
  --location eastus \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --os-type Linux \
  --cpu 1 \
  --memory 1
```

2. Get the IP address of the Azure container instance using the `az container show` command.

```bash
az container show \
  --resource-group learn-acr-rg \
  --name acr-tasks \
  --query ipAddress.ip \
  --output table
```

3. In a separate browser tab, navigate to the container's IP address. If everything is configured correctly, you should see the following web page:

```bash
Hello World
Version: 25.8.1
```

Port 80 is used so the web page address is `http://<IP_ADDRESS>`.

### Disable the registry admin account

After you verify the container instance works as expected, disable the registry admin account to secure your registry.

```bash
az acr update --name $ACR_NAME --admin-enabled false
```

You should also clear the `ACR_USERNAME` and `ACR_PASSWORD` variables to remove their values from your Bash session.

```bash
ACR_USERNAME=""
ACR_PASSWORD=""
```

## Replicate a container image to different Azure regions

Let's say you have compute workloads deployed to several regions. You can use Azure Container Registry to place a container registry in each region where images run. This strategy allows for network-close operations and enables fast and reliable image layer transfers.

Geo-replication enables a container registry to function as a single registry that serves several regions with multi-master regional registries.

A geo-replicated registry provides the following benefits:

Use single `registry/image/tag` names across multiple regions.
Network-close registry access from regional deployments.
No extra egress fees, as images are pulled from a local, replicated registry in the same region as the container host.
Single management of a registry across multiple regions.

### Create a replicated region for an Azure Container Registry

1. Replicate your registry to another region using the `az acr replication create` command. In this example, we replicate to the `japaneast` region.

```bash
az acr replication create --registry $ACR_NAME --location japaneast
```

Your output should look similar to the following condensed example output:

```json
{
  ...
  resourceGroups/learn-acr-rg/providers/Microsoft.ContainerRegistry/registries/myuniqueacrname/replications/japaneast",
  "location": "japaneast",
  "name": "japaneast",
  "provisioningState": "Succeeded",
   "regionEndpointEnabled": true,
   "resourceGroup": "learn-acr-rg",
  ...
}
```

2. View all the container image replicas using the `az acr replication list` command.

```bash
az acr replication list --registry $ACR_NAME --output table
```

Your output should look similar to the following example output:

```bash
NAME       LOCATION    PROVISIONING STATE    STATUS    REGION ENDPOINT ENABLED
---------  ----------  -------------------   -------   ------------------------
japaneast  japaneast   Succeeded             Ready     True
eastus     eastus      Succeeded             Ready     True
```

You can also use the Azure portal to view your container images by navigating to your container registry and selecting Geo-replications:

[Screenshot of Azure container registry world map showing replicated and available locations.](acr_world_map.png)

### Clean up resources

To avoid incurring charges, remove the resources you created in this module. When you delete the resource group, all resources in the resource group are deleted.

Delete the resource group using the `az group delete` command.

```bash
az group delete --name learn-acr-rg --yes --no-wait
```

### Learn more

Learn more about Azure Container Registry and Docker on Azure with the following resources:

[Azure Container Registry (ACR) documentation](https://learn.microsoft.com/en-us/azure/container-registry/)
[What is Docker?](https://learn.microsoft.com/en-us/azure/docker/)

## Summary 

(Not provided, must create)