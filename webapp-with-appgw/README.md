# App Gateway with two backend app services

## Create certificate

Based on instructions from [here](https://docs.microsoft.com/en-us/azure/application-gateway/create-ssl-portal):

```powershell
$password = "<your-password-here>"
$domain = "contoso00000000001.northeurope.cloudapp.azure.com"
$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $domain

$pwd = ConvertTo-SecureString -String $password -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath cert.pfx -Password $pwd
```

## Deploy

```powershell
.\deploy.ps1 -Template webapp-with-appgw\main.json -ResourceGroupName "rg-bicep-appgw-demo"
```

## Test

```powershell
curl "http://contoso00000000001.northeurope.cloudapp.azure.com" --verbose
curl "http://contoso00000000001.northeurope.cloudapp.azure.com/app1/" --verbose

curl "https://contoso00000000001.northeurope.cloudapp.azure.com" --verbose --insecure

curl "https://contoso00000000001.northeurope.cloudapp.azure.com/app1" --verbose --insecure
curl "https://contoso00000000001.northeurope.cloudapp.azure.com/app1/sales" --verbose --insecure

curl "https://contoso00000000001.northeurope.cloudapp.azure.com/app2" --verbose --insecure
curl "https://contoso00000000001.northeurope.cloudapp.azure.com/app2/sales" --verbose --insecure
```

## Clean up

```powershell
Remove-AzResourceGroup -Name "rg-bicep-appgw-demo" -Force
```
