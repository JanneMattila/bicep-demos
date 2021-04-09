# Bicep demos

Contains examples about [bicep](https://github.com/Azure/bicep).

To test examples execute following command:

```powershell
bicep build storage\main.bicep
```

Or to build all

```powershell
Get-ChildItem -Directory | % {
 bicep build "$_\main.bicep"
}
```

It outputs ARM template and you can deploy it using:

```powershell
.\deploy.ps1 -Template storage\main.json -ResourceGroupName "rg-bicep-demo"
```
