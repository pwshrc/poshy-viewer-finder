#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-NanoOptionList {
    if (Get-Variable -Name "NanoOptions" -Scope Global -ErrorAction Ignore) {
        return $global:NanoOptions
    }

    [string] $nano_bin=(Search-CommandPathMemoized "nano")
    if (-not $nano_bin) {
        throw "nano not found"
    }
    [string[]] $nano_help = (& $nano_bin --help 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "nano --help failed"
    }
    [object[]] $results = (
        $nano_help `
        | Where-Object { $_.Trim().StartsWith("-") } `
        | ForEach-Object { $_.Trim() -replace "\s\s+","`t" } `
        | ConvertFrom-Csv -Delimiter "`t" -Header SyntaxShort,SyntaxLong,Description
    )
    Set-Variable -Name "NanoOptions" -Value $results -Scope Global -Option ReadOnly
    return $results
}
