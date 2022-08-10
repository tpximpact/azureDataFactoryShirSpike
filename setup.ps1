param(
    [Parameter(Mandatory=$true)]
    [string]
    $key
)
Invoke-WebRequest -Uri 'https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.20.8235.2.msi' -OutFile ShirInstall.msi
.\InstallGatewayOnLocalMachine.ps1 -path ShirInstall.msi -authKey $key