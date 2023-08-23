#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-Viewer-Less {
    param(
        [switch] $EditingAllowed,
        [switch] $ReadOnly,

        [switch] $StayInTerminal,
        [switch] $TerminalWaitsUntilExit,
        [switch] $GuiNoWait,

        [switch] $AnsiPassThru,

        [switch] $ShowLineNumbers,
        [switch] $NoLineNumbers,

        [switch] $TextContentPlain,
        [switch] $TextContentSpecialCharHighlight,
        [switch] $TextContentSyntaxHighlight,

        [switch] $BinaryContentBlob,

        [switch] $OnlyIfHosting,

        [switch] $ShortPageEarlyExit,
        [switch] $AlwaysPages,
        [switch] $NeverPages,
        [switch] $MayUseExternalPager,
        [switch] $NeverUseExternalPager,

        [switch] $AcceptsInputPiped
    )
    Process {
        if ($TerminalWaitsUntilExit -and $GuiNoWait) {
            throw "Cannot specify both -TerminalWaitsUntilExit and -GuiNoWait, they are mutually exclusive."
        }
        if ($ShortPageEarlyExit -and $AlwaysPages) {
            throw "Cannot specify both -ShortPageEarlyExit and -AlwaysPages, they are mutually exclusive."
        }
        if ($AlwaysPages -and $NeverPages) {
            throw "Cannot specify both -AlwaysPages and -NeverPages, they are mutually exclusive."
        }
        if ($MayUseExternalPager -and $NeverUseExternalPager) {
            throw "Cannot specify both -MayUseExternalPager and -NeverUseExternalPager, they are mutually exclusive."
        }
        if ($ShowLineNumbers -and $NoLineNumbers) {
            throw "Cannot specify both -ShowLineNumbers and -NoLineNumbers, they are mutually exclusive."
        }

        [switch[]] $alwaysDisqualifyingModifiers = @(
            $EditingAllowed,
            # $ReadOnly,
            # $StayInTerminal,
            # $TerminalWaitsUntilExit,
            $GuiNoWait,
            # $AnsiPassThru,
            # $ShowLineNumbers,
            # $NoLineNumbers,
            # $TextContentPlain,
            # $TextContentSpecialCharHighlight,
            $TextContentSyntaxHighlight,
            $BinaryContentBlob,
            $OnlyIfHosting,
            # $ShortPageEarlyExit
            # $AlwaysPages
            $NeverPages,
            $MayUseExternalPager
            # $NeverUseExternalPager,
            # $AcceptsInputPiped
        )
        if ($alwaysDisqualifyingModifiers -contains $true) {
            if ($DebugPreference -eq "Continue") {
                Write-Debug "Get-Viewer-Less: Always-disqualifying modifiers used. Args: $($PSBoundParameters | ConvertTo-Json)"
            }
            return
        }

        [string[]] $argsToUse = @()

        [bool] $willAnsiPassThru = $false
        if ($AnsiPassThru -and $TextContentSpecialCharHighlight) {
            Write-Debug "Get-Viewer-Less: Cannot specify both -AnsiPassThru and -TextContentSpecialCharHighlight, they are mutually exclusive."
            return
        } elseif ($TextContentSpecialCharHighlight) {
            $willAnsiPassThru = $false
        } elseif ($AnsiPassThru) {
            $argsToUse += @("-R")
            $willAnsiPassThru = $true
        } elseif (Test-Path Env:\CLICOLOR -ErrorAction SilentlyContinue) {
            if ($Env:CLICOLOR) {
                $argsToUse += @("-R")
                $willAnsiPassThru = $true
            }
        } elseif ($Env:TERM_ITALICS) {
            $argsToUse += @("-R")
            $willAnsiPassThru = $true
        }

        if ($ShowLineNumbers) {
            $argsToUse += "--LINE-NUMBERS"
        } elseif ($NoLineNumbers) {
            $argsToUse += "--line-numbers"
        }
        if ($ShortPageEarlyExit -and $TerminalWaitsUntilExit) {
            Write-Debug "Get-Viewer-Less: Cannot specify both -ShortPageEarlyExit and -TerminalWaitsUntilExit, they are mutually exclusive."
            return
        } elseif ($ShortPageEarlyExit) {
            $argsToUse += "--quit-if-one-screen"
        }
        $argsToUse += "--mouse"

        [System.Collections.Immutable.ImmutableDictionary[string,string]] $binEnv = [System.Collections.Immutable.ImmutableDictionary[string,string]]::Empty
        [string] $less_bin = (Search-CommandPathMemoized "less")
        if ($less_bin) {
            [string] $invocationSignature = (Get-InvocationSignature $less_bin @argsToUse)
            $argsToUse = [System.Collections.Immutable.ImmutableList]::Create($argsToUse)
            [PSCustomObject]@{
                Id = "less#${invocationSignature}"; Name = "less"; Bin = $less_bin; BinArgs = $argsToUse; AcceptsInputPiped = $true;
                AlwaysPages = (-not $ShortPageEarlyExit); NeverPages = $false; ShortPageEarlyExit = [bool]$ShortPageEarlyExit; MayPage = $true;
                MayUseExternalPager = $false; NeverUsesExternalPager = $true; TerminalWaitsUntilExit = (-not $ShortPageEarlyExit)
                AnsiPassThru = $willAnsiPassThru; ShowLineNumbers = ([bool]$ShowLineNumbers -or (-not $NoLineNumbers));
                BinEnv = $binEnv;
            } | Write-Output
        } else {
            Write-Debug "Get-Viewer-Less: No 'less' binary found."
        }
    }
}
