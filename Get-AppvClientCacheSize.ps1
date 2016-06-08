#---------------------------------------------------------------------------
# Author: Aaron Parker
# Desc:   Function that returns the App-V 5.0 client current cache size
# Date:   Feb 24, 2013
# Site:   http://blog.stealthpuppy.com
#---------------------------------------------------------------------------
 
Function Get-AppvClientCacheSize {
    <#
        .SYNOPSIS
            Returns the current size of the App-V 5 client cache.
  
        .DESCRIPTION
            Returns the size of the App-V client cache by calculating the total size of packages, the percentage of packages streamed to disk as well as returning the size of the Package Installation Root folder.

            Returning all three values is useful to determine what has been streamed to disk, what can potentially be streamed to disk and savings gained by the use of the Shared Content Store.
  
        .PARAMETER DisplaySize
            Specifies the display of the cache size to be returned in MB or GB. If ommited, sizes are returned in MB.
  
        .EXAMPLE
            PS C:\> New-AppvConnectionGroupFile -DisplayName "Internet Explorer Plugins" -Priority 0 -FilePath InternetExplorerPlugins.xml -Packages $Packages
 
            Creates a Connection Group file named 'InternetExplorerPlugins.xml' with a display name of 'Internet Explorer Plugins' from packages contained within the array $Packages.
 
        .EXAMPLE
            PS C:\> Get-AppvClientPackage -Name Adobe* | New-AppvConnectionGroupFile -DisplayName "Adobe Apps" -Priority 10 -FilePath AdobeApps.xml
 
            Creates a Connection Group file named 'AdobeApps.xml' with a display name of 'Adobe Apps' from packages passed via the pipeline from Get-AppvClientPackage.
  
        .NOTES
            See http://blog.stealthpuppy.com/ for support information.
  
        .LINK
 
http://blog.stealthpuppy.com/code/creating-app-v-5-0-connection-groups-with-powershell/
 
     #>
  
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param(
        [ValidateSet("MB","GB")]
        [Parameter(Mandatory=$False, HelpMessage="Return the cache size in MB or GB")]
        [string]$DisplaySize
        )
 
    BEGIN {
 
    }
 
    # Process each supplied App-V package into the XML object
    PROCESS {

        }
    }
 
    END {
 
        # Return the new Connection Group description XML file so that it might be processed by other functions
        If (Test-Path $Path ) { Return Get-Item $Path } Else { Write-Warning "Failed to save Connection Group definition file." }
    }
}