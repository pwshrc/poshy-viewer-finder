#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Search-VisualStudioYearEditionDevEnvPathMemoized {
    param(
        [int] $Year,
        [string] $Edition
    )
    [string] $GlobalBinVariableName="EDITOR_bin_visualstudio_${Year}_${Edition}"
    if (Get-Variable -Name $GlobalBinVariableName -ErrorAction SilentlyContinue) {
        return (Get-Variable -Name $GlobalBinVariableName -ValueOnly)
    } else {
        [string] $programfiles_visual_studio="$Env:ProgramFiles\Microsoft Visual Studio\"
        [string] $vs_bin=(Join-Path -Path $programfiles_visual_studio -ChildPath "Visual Studio ${vs_year}\${vs_sku}\Common7\IDE\devenv.exe")
        if (Test-Path $vs_bin) {
            Set-Variable -Name $GlobalBinVariableName -Value $vs_bin -Option ReadOnly -Scope Global
        } else {
            Set-Variable -Name $GlobalBinVariableName -Value $null -Option ReadOnly -Scope Global
        }
        return $vs_bin
    }
}
