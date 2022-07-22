az group create --location uksouth --resource-group rg-lg-shirdfspike-tf
az storage account create -n stlgshirdfspiketfstate -g rg-lg-shirdfspike-tf -l uksouth --sku Standard_LRS 
az storage container create -n tfstate --account-name stlgshirdfspiketfstate