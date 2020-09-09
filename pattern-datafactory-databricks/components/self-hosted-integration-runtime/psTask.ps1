
param(
[string] $scriptName,
[string] $irKey
)





$ErrorActionPreference = "Stop"
$path = $PSScriptRoot

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


# init log setting
try{

    $installDir = "$env:SystemDrive\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\"

    if (! (Test-Path($installDir)))
    {
        New-Item -path $installDir -type directory -Force
    }

    $installLogs = [string]::Concat($installDir,"psTasklog", (Get-time).replace(' ','_').replace(":",""),".log")
    if (! (Test-Path($installLogs)))
    {
        New-Item -path $installLogs -type File -Force
    }
    Wrtie-EventToLog "Information | Log file: $($installLogs)"
    Wrtie-EventToLog "Information | Starting Integration runtime 'Execute IR Setup' scheduled task configuration" 

    $installScript = "$path\$scriptName"
    $scriptToRun = "C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe "
    $arguments = "-ExecutionPolicy Unrestricted -File $installScript $irKey"

    Wrtie-EventToLog "Information | Scheduled task powershell script path '$($installScript)'" 

    $taskToRun = New-ScheduledTaskAction -Execute $scriptToRun -Argument $arguments  
    $setTimer = New-ScheduledTaskTrigger -Once -At (Get-Date -DisplayHint Time).AddMinutes(5) 
    $registerTask = Register-ScheduledTask -User "NT AUTHORITY\SYSTEM" -TaskName "Execute IR Setup" -Action $taskToRun -Trigger $setTimer -Force 

    Wrtie-EventToLog "Information | Integration runtime scheduled task configuration Completed." 
}
catch{ 

    Wrtie-EventToLog "Information | Integration runtime scheculed task configuration Failed.`n$_" 
    throw
}