## File System to Azure File Share Copy Pipeline with ADF

### To Deploy
`terraform init`
`terraform apply --var 'vm-lg-shirdfspike-filesource-admin-password=PasswordForAzureVM' -auto-approve`

### Configure VM
1. Remote Desktop into Azure VM at IP address given above
2. Copy setup.ps1 to VM to install MS Edge
3. Install integration runtime https://www.microsoft.com/en-gb/download/details.aspx?id=39717
4. Configure integration runtime to connect to SHIR using key in data factory page
5. Create a folder on the VM like C:\\ExampleSharingFolder\inputFolder1
6. Put some dummy files in the folder

Run the pipeline, observe file copied from Azure VM folder to Azure File Share