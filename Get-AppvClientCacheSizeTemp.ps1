Function Get-AppvClientCacheSize {
$PackageInstallationRoot = Get-AppvClientConfiguration -Name PackageInstallationRoot
$Path = [System.Environment]::ExpandEnvironmentVariables($PackageInstallationRoot.Value)
$colItems = (Get-ChildItem $Path -recurse | Measure-Object -property length -sum)
"Folder size: " + $colItems.sum / 1GB + " GB"

$Packages = Get-AppvClientPackage
$TotalPackageSize = $Packages | Measure-Object -Property PackageSize -Sum
$StreamedPackageSize = 0
foreach ( $package in $Packages) {
    $StreamedPackageSize = $StreamedPackageSize + ($package.PackageSize * ($package.PercentLoaded / 100))
}

"Total package size: " + $TotalPackageSize.Sum / 1GB + " GB"
"Streamed package size: " + $StreamedPackageSize / 1GB + " GB"

}

Get-AppvClientCacheSize
