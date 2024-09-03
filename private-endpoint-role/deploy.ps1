$inputObject = @{
    DeploymentName    = 'PrivateEndpointDnsContributor-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
    Location          = "swedencentral"
    ManagementGroupId = "production"
    TemplateFile      = "./PrivateEndpointDnsContributor.bicep"
}
 
New-AzManagementGroupDeployment @inputObject