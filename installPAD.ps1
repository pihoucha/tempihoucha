<#  
    .DESCRIPTION
        TODO
    
#>

#TODO: Add error handling

[CmdletBinding(DefaultParametersetName = 'None')]
param(

    [Parameter(Mandatory = $true)]
    [string] $AzureAppId,

    [Parameter(Mandatory = $true)]
    [string] $AzureAppSecret,

    [Parameter(Mandatory = $true)]
    [string] $tenantid,

    [Parameter(Mandatory = $true)]
    [string] $envid,
    
    [Parameter(Mandatory = $true)]
    [string] $groupid,

    [Parameter(Mandatory = $true)]
    [string] $grouppassword,

    $p = "",    
    [Hashtable] [Parameter(Mandatory = $false)]
    $DynParameters
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
Invoke-Expression "echo $AzureAppSecret | &'$padSilentRegistrationExe' -register -force -applicationid $AzureAppId -tenantid $tenantid -environmentid $envid -clientsecret | Out-Null"  

#Join group
Invoke-Expression "echo `"$AzureAppSecret`n$grouppassword`" | &'$padSilentRegistrationExe' -joinmachinegroup -groupid $groupid -applicationid $AzureAppId -tenantid $tenantid -environmentid $envid -clientsecret -grouppassword | Out-Null"

