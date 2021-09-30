<#  
    .DESCRIPTION
        This script is to be used with Azure Custom Scrpt Extentions to deploy PAD to a Windows 10 WVD host.
        
        Steps....
        1. Download the required applications to c:\temp\
        2. Install PAD using command line
        3. Register Machine using params from the runbook
    
#>

#TODO: Add error handling

[CmdletBinding(DefaultParametersetName = 'None')]
param(

    [Parameter(Mandatory = $true)]
    [string] $AzureAppId,

    [Parameter(Mandatory = $true)]
    [string] $AzureAppSecret,

    [Parameter(Mandatory = $true)]
    [string] $TenantId,

    [Parameter(Mandatory = $true)]
    [string] $EnvironmentId,
    
    [Parameter(Mandatory = $true)]
    [string] $GroupId,

    [Parameter(Mandatory = $true)]
    [string] $GroupPassword
)

$padInstallerLocation =  "$env:temp\Setup.Microsoft.PowerAutomateDesktop.exe"
$padSilentRegistrationExe = "C:\Program Files (x86)\Power Automate Desktop\PAD.MachineRegistration.Silent.exe"

if (-not(Test-Path -Path $padInstallerLocation -PathType Leaf)) {
    #Download PAD installer
    invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=2164365 -OutFile $padInstallerLocation
}

#Install PAD
Start-Process -FilePath $padInstallerLocation -ArgumentList '-Silent', '-Install', '-ACCEPTEULA' -Wait

#Register machine
Invoke-Expression "echo $AzureAppSecret | &'$padSilentRegistrationExe' -register -force -applicationid $AzureAppId -tenantid $TenantId -environmentid $EnvironmentId -clientsecret | Out-Null"  

#Join group
Invoke-Expression "echo `"$AzureAppSecret`n$GroupPassword`" | &'$padSilentRegistrationExe' -joinmachinegroup -groupid $groupid -applicationid $AzureAppId -tenantid $TenantId -environmentid $EnvironmentId -clientsecret -grouppassword | Out-Null"

