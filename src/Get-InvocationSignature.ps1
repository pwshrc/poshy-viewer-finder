#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


<#
.SYNOPSIS
    Outputs the unique invocation signature for a given binary and arguments.
.DESCRIPTION
    Outputs the unique invocation signature for a given binary and arguments - which is a base36-encoded MD5 hash of the binary and arguments.
.OUTPUTS

#>
function Get-InvocationSignature {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $bin,

        [Parameter(Mandatory = $false, Position = 1, ValueFromRemainingArguments = $true)]
        [string[]] $arguments
    )
    function EncodeAsBase36 {
        param(
            [Parameter(Mandatory = $true)]
            [byte[]] $inputData
        )
        [string] $base36 = '0123456789abcdefghijklmnopqrstuvwxyz'
        [string] $result = ''
        [int] $inputLength = $inputData.Length
        [int] $i = 0
        while ($i -lt $inputLength) {
            [int] $value = $inputData[$i]
            $result += $base36[$value % 36]
            $i++
        }
        return $result
    }

    [string] $packed = (@($bin, $arguments) | ConvertTo-Json)
    [byte[]] $signatureHashBytes = [System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($packed))
    return (EncodeAsBase36 $signatureHashBytes)
}
