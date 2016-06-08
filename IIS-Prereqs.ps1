# Import the ServerManager module which we will need to use the Add-WindowsFeature cmdlet
Import-Module ServerManager

# Add the required IIS features with the Add-WindowsFeature cmdletw 
$Features = Add-WindowsFeature –Name Web-Server,Web-Windows-Auth,Web-Mgmt-Tools,Web-ISAPI-Ext,Web-ISAPI-Filter,NET-Framework-45-ASPNET,Web-Asp-Net45,Web-Net-Ext45

# Report the results of adding the features
If ($Features.Success -eq $True) {
    If ($Features.RestartNeeded -eq $True) { 
        Write-Host -ForegroundColor Green "IIS features added successfully and reboot required."
    } Else {
        Write-Host -ForegroundColor Green "IIS features added successfully."
    }
} Else {
    Write-Error "Adding IIS features failed with error: $Features.ExitCode"
}

# Import the WebAdministration module required for managing IIS
Import-Module WebAdministration

# Find whether any web sites are bound to port 80
$port80 = $false
Get-WebSite | ForEach-Object { If ($_.Bindings.Collection.bindingInformation -like "*:80:*") { $port80 = $True } }
If ( $port80 ) {

    # Find all bindings and add 1 to the highest binding to create a new port to bind the web site to
    $binds = @()
    Get-WebBinding | ForEach-Object { $binds += $_.bindingInformation.Split(":") }
    $binds = $binds | Sort-Object
    $port = ($binds[($binds.Count-1)] -as [int]) + 1

    # Change the web bindings for the site bound to port 80 to the new calculated port number
    Get-WebSite | ForEach-Object { If ($_.Bindings.Collection.bindingInformation -like "*:80:*") { Set-WebBinding -Name $_.Name -BindingInformation "*:80:" -PropertyName Port -Value $port } }
}