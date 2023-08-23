#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Search-CommandPathMemoized {
    param(
        [string] $BinaryName,
        [string] $GlobalBinVariableNameInfix = $BinaryName
    )
    [string] $GlobalBinVariableName="EDITOR_bin_${GlobalBinVariableNameInfix}"
    if (Get-Variable -Name $GlobalBinVariableName -ErrorAction SilentlyContinue) {
        return (Get-Variable -Name $GlobalBinVariableName -ValueOnly)
    } else {
        $bin=(Search-CommandPath $BinaryName)
        Set-Variable -Name $GlobalBinVariableName -Value $bin -Option ReadOnly -Scope Global
        return $bin
    }
}
