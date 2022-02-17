param name string

// After restore, actual module file can be found in:
// %USERPROFILE%\.bicep\br\myacrbicepdemo00010.azurecr.io\bicep$modules$storage\v1$
// Note: Template will be in ARM and not in Bicep format!
module storageTemplate 'br:myacrbicepdemo00010.azurecr.io/bicep/modules/storage:v1' = {
    name: 'deployment-${name}'
    params: {
        storageAccountName: name
    }
}
