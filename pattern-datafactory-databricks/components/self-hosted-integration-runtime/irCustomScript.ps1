
<#
     Custom Extension
    A POWERSHELL script to install and setup Self Hosted Integration Runtime on an existing Virtual Machine in Azure

    Script requires input parameters 

    dataFactoryName,         : Data factory Name
    dataFactoryresourceGroup : Data factory resource group
    integrationRuntimeName   : Data Factory Integration runtime to associate VM with
    integrationRuntimeVmRG   : Integration Run time Virtual machines Resource group 
    location                 : Integration Runtime virtual machine Azure region.
    irScript                 : Integration Runtime POWERSHELL Install script.
    integramRunTimeNodes     : an Array formatted List of virtual machine to setup as integration runtime data gateways
    storageAccountName       : Storage Account Name for customer script
    containerName            : Storage Account Blob container 

#>

function Get-ADFAuthenticationKey{
    param(
    [string] $dataFactoryName,
    [string] $dataFactoryresourceGroup,
    [string] $integrationRuntimeName
    )

    try{

        $irKey= (Get-AzDataFactoryV2IntegrationRuntimeKey -Name $irName -ResourceGroupName $dataFactoryresourceGroup -DataFactoryName $dataFactoryName -ErrorAction SilentlyContinue).AuthKey1
        if (-not ($irKey)){
             $irKey = " Error | failed toget Integration Runtime Authentication Key."
        }

    }
    catch{
        
        $irKey = " Error | failed toget Integration Runtime Authentication Key $_"
    }

    return $irKey
}
function Install-InegrationRuntimeExtension{
    param(
    [string] $integrationRuntimeVmRG,
    [string] $location,
    [string] $irScript,
    [array]  $integramRunTimeNodes,
    [string] $irKey,
    [string] $storageAccountName,
    [string] $containerName
    )



    foreach ($irVm in $integramRunTimeNodes){
        try{
            $status = Set-AzVMCustomScriptExtension -ResourceGroupName $integrationRuntimeVmRG -VMName $irVm `
                        -StorageAccountName $storageAccountName -ContainerName $containerName -StorageAccountKey $storageKey `
                        -Location $location -fileName $irScript -Run $irScript `
                        -Name "IntegrationRuntimeExtension" `
                        -SecureExecution -Argument $irKey `
                        -verbose 
            $irstatus += "Information | $irVm failed to add Integration runtime extension $status"
        }
        catch{
            $irstatus += "Error | $irVm failed to add Integration runtime extension $status"
        }

    
        
    }
    Return $irstatus
}



#Main Starts

$irKey =  Get-ADFAuthenticationKey -dataFactoryresourceGroup $integrationRuntimeVmRG -integrationRuntimeName $irName -DataFactoryName $dataFactoryName
if ( -not ($irKey | Select-String "Error")){

    $irStatus = Install-InegrationRuntimeExtension -integrationRuntimeVmRG $integrationRuntimeVmRG -location $location `
                -irScript $irScript -integramRunTimeNodes $integramRunTimeNodes -irKey $irKey `
                -storageAccountName $storageAccountName -containerName $containerName
}