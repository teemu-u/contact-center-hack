#!/bin/bash
#
# This script will retrieve necessary keys and properties from Azure Resources 
# deployed using "Deploy to Azure" button and will store them in a file named
# "config.env" in the current directory.

# Login to Azure
if [ -z "$(az account show)" ]; then
  echo "User not signed in Azure. Signin to Azure using 'az login' command."
  az login --use-device-code
fi

# Install ml extension if needed
if [ -z "$(az extension show --name ml)" ]; then
	echo "Installing Azure ML extension..."
	az extension add --name ml --upgrade -y
	pip3 install azure-core==1.31.0
fi

# Get the resource group name from the script parameter named resource-group
resourceGroupName=""
aiStudioProject=""

# Parse named parameters
while [[ "$#" -gt 0 ]]; do
		case $1 in
				--resource-group) resourceGroupName="$2"; shift ;;
				--aistudio-project) aiStudioProject="$2"; shift ;;
				*) echo "Unknown parameter passed: $1"; exit 1 ;;
		esac
		shift
done

# Check if resourceGroupName is provided
if [ -z "$resourceGroupName" ]; then
    echo "Enter the resource group name where the resources are deployed:"
    read resourceGroupName
fi

# Get resource group deployments, find deployments starting with 'Microsoft.Template' and sort them by timestamp
echo "Getting the deployments in '$resourceGroupName'..."
deploymentName=$(az deployment group list --resource-group $resourceGroupName --query "[?contains(name, 'Microsoft.Template') || contains(name, 'azuredeploy')].{name:name}[0].name" --output tsv)
if [ $? -ne 0 ]; then
	echo "Error occurred while fetching deployments. Exiting..."
	exit 1
fi

# Get output parameters from last deployment to the resource group and store them as variables
echo "Getting the output parameters from the last deployment '$deploymentName' in '$resourceGroupName'..."
az deployment group show --resource-group $resourceGroupName --name $deploymentName --query properties.outputs > tmp_outputs.json
if [ $? -ne 0 ]; then
	echo "Error occurred while fetching the output parameters. Exiting..."
	exit 1
fi

# Extract the resource names from the output parameters
echo "Extracting the resource names from the output parameters..."
cosmosdbAccountName=$(jq -r '.cosmosdbAccountName.value' tmp_outputs.json)
cosmosdbDatabaseName=$(jq -r '.cosmosdbDatabaseName.value' tmp_outputs.json)
cosmosdbContainerName=$(jq -r '.cosmosdbContainerName.value' tmp_outputs.json)
aiCognitiveServicesName=$(jq -r '.aiCognitiveServicesName.value' tmp_outputs.json)
aiHubName=$(jq -r '.aiHubName.value' tmp_outputs.json)
aiHubProjectName=$aiStudioProject
# Get the AI Studio project name, if not provided
if [ -z "$aiHubProjectName" ]; then
	echo "AI Studio project name is not provided, reading default project name..."
	aiHubProjectName=$(jq -r '.aiHubProjectName.value' tmp_outputs.json)
fi

# Delete the temporary file
rm tmp_outputs.json

# Get the keys from the resources
echo "Getting the keys from the resources..."
cosmosdbAccountKey=$(az cosmosdb keys list --name $cosmosdbAccountName --resource-group $resourceGroupName --query primaryMasterKey -o tsv)
cosmosdbConnectionUrl=$(az cosmosdb show --name $cosmosdbAccountName --resource-group $resourceGroupName --query "documentEndpoint" -o tsv)
aiCognitiveServicesKey=$(az cognitiveservices account keys list --name $aiCognitiveServicesName --resource-group $resourceGroupName --query key1 -o tsv)
aiCognitiveServicesRegion=$(az cognitiveservices account show --name $aiCognitiveServicesName --resource-group $resourceGroupName --query location -o tsv)
endpointname=$(az ml online-endpoint list --resource-group $resourceGroupName --workspace-name $aistudioproject --query "[0].{key:name}" -o tsv)
aiEndpoint=$(az ml online-endpoint show --name $endpointname  --resource-group $resourceGroupName --workspace-name $aistudioproject --query "scoring_uri" -o tsv)
aiEndpointKey=$(az ml online-endpoint get-credentials --name $endpointname --resource-group $resourceGroupName --workspace-name $aistudioproject --query "primaryKey" -o tsv)

# Overwrite the existing config.env file
if [ -f config.env ]; then
	rm config.env
fi

# Store the keys and properties in a file
echo "Storing the keys and properties in 'config.env' file..."
echo "COSMOSDB_DATABASE_NAME=\"$cosmosdbDatabaseName\"" >> config.env
echo "COSMOSDB_CONTAINER_NAME=\"$cosmosdbContainerName\"" >> config.env
echo "COSMOSDB_CONNECTION_KEY=\"$cosmosdbAccountKey\"" >> config.env
echo "COSMOSDB_CONNECTION_URL=\"$cosmosdbConnectionUrl\"" >> config.env
echo "SPEECH_KEY=\"$aiCognitiveServicesKey\"" >> config.env
echo "SPEECH_REGION=\"$aiCognitiveServicesRegion\"" >> config.env
echo "PROMPTFLOW_DEPLOYMENT_URL=\"$aiEndpoint\"" >> config.env
echo "PROMPTFLOW_DEPLOYMENT_KEY=\"$aiEndpointKey\"" >> config.env

echo "Keys and properties are stored in 'config.env' file successfully."