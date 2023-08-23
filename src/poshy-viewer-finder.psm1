#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


Get-ChildItem -Path "$PSScriptRoot/*.ps1" | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function Get-Viewer, Format-ViewerInvocationSh, New-ViewerInvocationFunction, Format-BatcatStyle, Format-LessTermcapEnv
