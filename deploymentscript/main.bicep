param forceUpdateTag string = utcNow()
param location string = resourceGroup().location

var message = 'Hello World!'
var scriptContent = '$DeploymentScriptOutputs["Message"] = "${message}"'

resource deploymentScriptsResource 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
    name: 'executePowerShell'
    location: location
    kind: 'AzurePowerShell'
    properties: {
        azPowerShellVersion: '3.0'
        scriptContent: scriptContent
        forceUpdateTag: forceUpdateTag
        retentionInterval: 'PT4H'
        cleanupPreference: 'OnSuccess'
    }
}

output deploymentScripts object = deploymentScriptsResource