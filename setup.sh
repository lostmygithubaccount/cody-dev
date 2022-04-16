echo "Setting variables..."

# set variables
GROUP="cody-dev"
LOCATION="eastus"
WORKSPACE="main-dev"

# additional variables
SUBSCRIPTION=$(az account show --query id -o tsv)
SECRET_NAME="AZ_CREDS"

echo "Creating resource group..."
az group create -n $GROUP -l $LOCATION

echo "Creating service principal and setting repository secret..."
az ad sp create-for-rbac --name $GROUP --role contributor --scopes /subscriptions/$SUBSCRIPTION/resourceGroups/$GROUP --sdk-auth | gh secret set $SECRET_NAME

echo "Creating Azure Machine Learning workspace..."
az ml workspace create -n $WORKSPACE -g $GROUP -l $LOCATION

echo "Configuring Azure CLI defaults..."
az configure --defaults group=$GROUP workspace=$WORKSPACE location=$LOCATION

echo "Creating compute..."
az ml compute create -n cpu-cluster --type amlcompute --min-instances 1 --max-instances 8 --size STANDARD_DS3_v2
az ml compute create -n cody-dev --type computeinstance --size STANDARD_DS3_v2
