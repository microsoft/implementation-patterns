<#
    Integration RunTime Install Sctipt. 
    This script would run post Provisioning of the Integration runtime Virtual Machine. The script only input is the Integration runtime instrumentation Key.
     The integration runtime Key passed as Parameter to the script through ARM custom extension.

     the script will retun exit code to custom extension indicating failure or success

#>
Param(
 [string] $irKey
)



$ErrorActionPreference = "Stop"
$scriptName = $MyInvocation.MyCommand.Name


function Get-Time{
    return (Get-Date -Format "MM-dd-yyyy HH:mm:ss")
}


function Wrtie-EventToLog{
    Param(
    [string] $event
    )

    $now =Get-Time
    try
    {
        "${now} $event`n" | Out-File $installLogs -Append
    }
    catch
    {
        #Logging no exception to catch
    }
}


function Download-IntegrationRuntime{

    param(
    [string] $url,
    [string] $dgwPath
    )

  try
    {
        
        $client = New-Object System.Net.WebClient
        $client.DownloadFile($url, $dgwPath)
        Wrtie-EventToLog "Information | Download Integration runtime successfully. Integration runtime location $($dgwPath)"
    }
    catch
    {
        Wrtie-EventToLog "Error | Failed to download Integration Runtime msi"
        Wrtie-EventToLog "Error | $_.Exception.ToString()"
        throw "Error | $_"
    }
}

function Install-Gateway([string] $dgwPath)
{
	if ([string]::IsNullOrEmpty($dgwPath))
    {
		Throw "Error | Gateway path is not specified"
    }

	if (!(Test-Path -Path $dgwPath))
	{
		Throw "Error | Invalid Integration Runtime install path: $dgwPath"
	}
    
    try{
	
	    Wrtie-EventToLog "Information | Start Gateway installation"
	    start-Process "msiexec.exe" "/i gateway.msi INSTALLTYPE=AzureTemplate /quiet /norestart" -Wait	
	
	    Start-Sleep -Seconds 30	

	    Wrtie-EventToLog "Information | Installation of gateway is successful"
    }
    catch{
        Wrtie-EventToLog "Error | $_.Exception.ToString()"
        throw "Error | $_"
    }
}


function Get-InstalledFilePath()
{
    try{
	    $filePath = Get-ItemPropertyValue "hklm:\Software\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager" "DiacmdPath"
	    if ([string]::IsNullOrEmpty($filePath))
	    {
		    Throw "Error | Get-InstalledFilePath: Cannot find installed File Path"
	    }
        Wrtie-EventToLog "Information | Integration Runtime installation file: $filePath"
    }
    catch{
        throw "Error | $_"
    }
	return $filePath
}


try{

    # init log setting
    $installDir = "$env:SystemDrive\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\"
    $url = "https://go.microsoft.com/fwlink/?linkid=839822"
    $dgwPath= "$installDir\IntegrationRuntime.msi"

    if (! (Test-Path($installDir)))
    {
        New-Item -path $installDir -type directory -Force
    }

    $installLogs = [string]::Concat($installDir,"irtracelog", (Get-time).replace(' ','_').replace(":",""),".log")
    if (! (Test-Path($installLogs)))
    {
        New-Item -path $installLogs -type File -Force
    }

    Wrtie-EventToLog $irKey
    Wrtie-EventToLog "Information | Start to excute $($scriptName)" 
    Wrtie-EventToLog "Information | Log file: $($installLogs)"

    Download-IntegrationRuntime -url $url -dgwPath $dgwPath
	
    Wrtie-EventToLog "Information | Start Integration runtime installation"
    $proc = Start-Process "msiexec.exe" "/i $($dgwPath) INSTALLTYPE=AzureTemplate /quiet /norestart" -Wait -Passthru -NoNewWindow -ErrorVariable errVariable
	
    Start-Sleep -Seconds 30	
    if($proc.ExitCode -ne 0 -or $errVariable -ne "")
    {		
	    Wrtie-EventToLog  "Error | Failed to run process: exitCode=$($proc.ExitCode), errVariable=$errVariable,"
        throw
    }

    Wrtie-EventToLog "Information | Installation of Integration runtime is successful"
    Wrtie-EventToLog "Information | Integration Runtime Agent Registration"

    $ircmd = Get-InstalledFilePath
    $proc = start-Process -FilePath $ircmd -ArgumentList "-k $irKey" -Wait -Passthru -NoNewWindow -ErrorVariable errVariable

    if($proc.ExitCode -ne 0 -or $errVariable -ne "")
    {		
	    Wrtie-EventToLog  "Error | Failed to run process: exitCode=$($proc.ExitCode), errVariable=$errVariable."
        throw
    }

}
catch{
    throw "Error | $_"
}
Wrtie-EventToLog "Information | Integration Runtime Agent registration is successful! ExitCode=$($proc.ExitCode)"

