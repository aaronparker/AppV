#---------------------------------------------------------------------------
# Author: Aaron Parker
# Desc:   Function that uses the App-V 5.0 client to create Connection
#         Group description (XML) files for use with stand alone clients or
#         test scenarios
# Date:   Jan 06, 2013
# Site:   http://blog.stealthpuppy.com
#---------------------------------------------------------------------------

Function New-AppvConnectionGroupFile {
    <#
        .SYNOPSIS
            Creates an App-V 5.0 Connection Group definition file.
 
        .DESCRIPTION
            Creates an XML-based Connection Group definition file from packages added to the current system.

            Packages can be filtered before being passed to the function to control which packages are included in the Connection Group.
 
        .PARAMETER DisplayName
            Specifies the display name of the Connection Group.
 
        .PARAMETER Priority
            Specifies the priority of the Connection Group.

        .PARAMETER Path
            Specifies the App-V connection group definition file to output.

        .PARAMETER Packages
            The packages to include in the Connection Group.
 
        .EXAMPLE
            PS C:\> New-AppvConnectionGroupFile -DisplayName "Internet Explorer Plugins" -Priority 0 -FilePath InternetExplorerPlugins.xml -Packages $Packages

            Creates a Connection Group file named 'InternetExplorerPlugins.xml' with a display name of 'Internet Explorer Plugins' from packages contained within the array $Packages.

        .EXAMPLE
            PS C:\> Get-AppvClientPackage -Name Adobe* | New-AppvConnectionGroupFile -DisplayName "Adobe Apps" -Priority 10 -FilePath AdobeApps.xml

            Creates a Connection Group file named 'AdobeApps.xml' with a display name of 'Adobe Apps' from packages passed via the pipeline from Get-AppvClientPackage.
 
        .NOTES
            See http://blog.stealthpuppy.com/ for support information.
 
        .LINK
 			http://blog.stealthpuppy.com/
     #>
 
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param(
        [Parameter(Mandatory=$True, HelpMessage="Connection Group descriptor XML file path")]
        [string]$Path,
        [Parameter(Mandatory=$True, HelpMessage="Display name of the Connection Group")]
        [string]$DisplayName,
        [Parameter(Mandatory=$False, HelpMessage="Connection Group priority")]
        [int]$Priority,
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, HelpMessage="Packages to include in the Connection Group")]
        [System.Array]$Packages
        )

    BEGIN {

# Template XML for an App-V Connection Group description file. Easier than building from an XML object
$templateXML = @' 
<?xml version="1.0" encoding="UTF-8" ?>
<appv:AppConnectionGroup
xmlns="http://schemas.microsoft.com/appv/2010/virtualapplicationconnectiongroup"
xmlns:appv="http://schemas.microsoft.com/appv/2010/virtualapplicationconnectiongroup"
AppConnectionGroupId="GUID"
VersionId="GUID"
Priority="0"
DisplayName="Display Name">
<appv:Packages>
<appv:Package DisplayName="Package1" PackageId="GUID" VersionId="GUID" />
</appv:Packages>
</appv:AppConnectionGroup>
'@

        # Write out the template XML to a file in the current directory
        $templateXMLFile = $pwd.Path + "\ConnectionGroupTemplate.XML"
        $templateXML | Out-File -FilePath $templateXMLFile -Encoding utf8 -Force

        # Create a new XML object and read the template XML file into this object
        $xml = New-Object XML
        If ((Test-Path $templateXMLFile) -eq $True ) { $xml.Load($templateXMLFile) } Else { Write-Warning -Message "Unable to read template XML file." }

        # Apply the display name and GUIDs to the XML object
        $xml.AppConnectionGroup.DisplayName = $DisplayName
        $xml.AppConnectionGroup.AppConnectionGroupId = ([guid]::NewGuid()).ToString()
        $xml.AppConnectionGroup.VersionId = ([guid]::NewGuid()).ToString()
        $xml.AppConnectionGroup.Priority = $Priority.ToString()

        # Clone the existing package entry to use for new entries
        $newPackage = (@($xml.AppConnectionGroup.Packages.Package)[0]).Clone()
    }

    # Process each supplied App-V package into the XML object
    PROCESS {
        ForEach ( $Package in $Packages ) {
            Write-Progress "Adding packages"
            
            $newPackage = $newPackage.Clone()
            $newPackage.DisplayName = $Package.Name
            $newPackage.PackageId = ($Package.PackageId).ToString()
            $newPackage.VersionId = ($Package.VersionId).ToString()

            # Output appending the child XML entry to null to prevent displaying on screen
            $xml.AppConnectionGroup.Packages.AppendChild($newPackage) > $null
        }
    }

    END {

        # Remove the template package entry from the XML
        $xml.AppConnectionGroup.Packages.ChildNodes | Where-Object { $_.DisplayName -eq "Package1" } | ForEach-Object  { [void]$xml.AppConnectionGroup.Packages.RemoveChild($_) }

        # Save the completed XML to disk
        $xml.Save($Path)

        # Delete the template XML file from disk
        If (Test-Path $templateXMLFile) { Remove-Item $templateXMLFile -Force -ErrorAction SilentlyContinue }

        # Return the new Connection Group description XML file so that it might be processed by other functions
        If (Test-Path $Path ) { Return Get-Item $Path } Else { Write-Warning "Failed to save Connection Group definition file." }
    }
}