#!/usr/bin/env pwsh
#Requires -Version 7.3
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function New-ViewerInvocationFunction {
    param(
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The name of the function to create.")]
        [ValidateNotNullOrEmpty()]
        [string] $FunctionName,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Bin,

        [Parameter(Mandatory = $false, Position = 2, ValueFromPipelineByPropertyName = $true)]
        [bool] $AcceptsInputPiped = $false,

        [Parameter(Mandatory = $false, Position = 3)]
        [switch] $Force,

        [Parameter(Mandatory = $false, Position = 4)]
        [switch] $PassThru,

        [Parameter(Mandatory = $false, Position = 5, ValueFromPipelineByPropertyName = $true)]
        [string[]] $BinArgs = @()
    )
    if ($AcceptsInputPiped) {
        $result = New-Item -Path Function:\ -Name "Global:$FunctionName" -Value {
            [CmdletBinding(DefaultParameterSetName = "Path")]
            param(
                [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $false, ValueFromPipelineByPropertyName=$true, ParameterSetName = "Path")]
                [ValidateNotNullOrEmpty()]
                [string[]] $Path,

                [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $false, ValueFromPipelineByPropertyName=$true, ParameterSetName = "LiteralPath")]
                [ValidateNotNullOrEmpty()]
                [string[]] $LiteralPath,

                [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = "InputObject")]
                $InputObject
            )
            Begin {
                Write-Debug "${FunctionName}[AcceptsInputPiped=true]: `$MyInvocation.ExpectingInput: $($MyInvocation.ExpectingInput)"
                Write-Debug "${FunctionName}[AcceptsInputPiped=true]: `$PSCmdlet.ParameterSetName: $($PSCmdlet.ParameterSetName)"
                Write-Debug "${FunctionName}[AcceptsInputPiped=true]: `$Path: $($Path)"
                Write-Debug "${FunctionName}[AcceptsInputPiped=true]: `$LiteralPath: $($LiteralPath)"
                Write-Debug "${FunctionName}[AcceptsInputPiped=true]: `$Bin: $($Bin)"
                if ($DebugPreference -eq "Continue") {
                    Write-Debug "${FunctionName}[AcceptsInputPiped=true]: `$BinArgs: $($BinArgs | ConvertTo-Json)"
                }
                if ($MyInvocation.ExpectingInput -or $PSCmdlet.ParameterSetName -eq "InputObject") {
                    $scriptCmd = {
                        &$Bin @BinArgs
                    }
                } elseif ($PSCmdlet.ParameterSetName -eq "Path") {
                    $scriptCmd = {
                        Get-Item -Path $Path -Force | ForEach-Object {
                            &$Bin @BinArgs $_.FullName
                        }
                    }
                } elseif ($PSCmdlet.ParameterSetName -eq "LiteralPath") {
                    $scriptCmd = {
                        Get-Item -LiteralPath $LiteralPath -Force | ForEach-Object {
                            &$Bin @BinArgs $_.FullName
                        }
                    }
                } else {
                    Write-Error "No input provided."
                    return
                }
                $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
                $steppablePipeline.Begin($PSCmdlet)
            }
            Process {
                if ($MyInvocation.ExpectingInput -or $PSCmdlet.ParameterSetName -eq "InputObject") {
                    $steppablePipeline.Process($_)
                } else {
                    $steppablePipeline.Process()
                }
            }
            End {
                $steppablePipeline.End()
            }
            Clean {
                if ($null -ne $steppablePipeline) {
                    $steppablePipeline.Clean()
                }
            }
        }.GetNewClosure() -Options AllScope -Force:$Force
        if ($PassThru) {
            $result
        }
    } else {
        $result = New-Item -Path Function:\ -Name "Global:$FunctionName" -Value {
            [CmdletBinding(DefaultParameterSetName = "Path")]
            param(
                [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $false, ValueFromPipelineByPropertyName=$true, ParameterSetName = "Path")]
                [ValidateNotNullOrEmpty()]
                [string[]] $Path,

                [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $false, ValueFromPipelineByPropertyName=$true, ParameterSetName = "LiteralPath")]
                [ValidateNotNullOrEmpty()]
                [string[]] $LiteralPath
            )
            Write-Debug "${FunctionName}[AcceptsInputPiped=false]: `$MyInvocation.ExpectingInput: $($MyInvocation.ExpectingInput)"
            Write-Debug "${FunctionName}[AcceptsInputPiped=false]: `$PSCmdlet.ParameterSetName: $($PSCmdlet.ParameterSetName)"
            Write-Debug "${FunctionName}[AcceptsInputPiped=false]: `$Path: $($Path)"
            Write-Debug "${FunctionName}[AcceptsInputPiped=false]: `$LiteralPath: $($LiteralPath)"
            Write-Debug "${FunctionName}[AcceptsInputPiped=false]: `$Bin: $($Bin)"
            if ($DebugPreference -eq "Continue") {
                Write-Debug "${FunctionName}[AcceptsInputPiped=false]: `$BinArgs: $($BinArgs | ConvertTo-Json)"
            }
            if ($PSCmdlet.ParameterSetName -eq "Path") {
                Get-Item -Path $Path -Force | ForEach-Object {
                    &$Bin @BinArgs $_.FullName
                }
            } elseif ($PSCmdlet.ParameterSetName -eq "LiteralPath") {
                Get-Item -LiteralPath $LiteralPath -Force | ForEach-Object {
                    &$Bin @BinArgs $_.FullName
                }
            } else {
                Write-Error "No input provided."
            }
        }.GetNewClosure() -Options AllScope -Force:$Force
        if ($PassThru) {
            $result
        }
    }
}
