#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Format-ViewerInvocationSh {
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Bin,

        [Parameter(Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string[]] $BinArgs = @()
    )
    Write-Debug "Format-ViewerInvocationSh: `$Bin: $($Bin)"
    Write-Debug "Format-ViewerInvocationSh: `$BinArgs: $($BinArgs)"
    [System.Text.StringBuilder] $result = [System.Text.StringBuilder]::new()
    if ($Bin -like "* *") {
        $result.Append("'") | Out-Null
        $result.Append($Bin) | Out-Null
        $result.Append("'") | Out-Null
    } else {
        $result.Append($Bin) | Out-Null
    }
    foreach ($arg in $BinArgs) {
        $result.Append(" ") | Out-Null
        if ($arg -like "* *") {
            $result.Append("'") | Out-Null
            $result.Append($arg) | Out-Null
            $result.Append("'") | Out-Null
        } else {
            $result.Append($arg) | Out-Null
        }
    }
    $result.ToString()
    Write-Debug "Format-ViewerInvocationSh: Result: $($result.ToString())"
    $result.Clear() | Out-Null
}
