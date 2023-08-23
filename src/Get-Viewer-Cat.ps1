#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-Viewer-Cat {
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
            $TerminalWaitsUntilExit,
            $GuiNoWait,
            # $ShowLineNumbers,
            # $NoLineNumbers,
            # $TextContentPlain,
            # $TextContentSpecialCharHighlight,
            $TextContentSyntaxHighlight,
            $BinaryContentBlob,
            $OnlyIfHosting,
            # $ShortPageEarlyExit
            $AlwaysPages,
            # $NeverPages
            $MayUseExternalPager
            # $NeverUseExternalPager,
            # $AcceptsInputPiped
        )
        if ($alwaysDisqualifyingModifiers -contains $true) {
            if ($DebugPreference -eq "Continue") {
                Write-Debug "Get-Viewer-Cat: Always-disqualifying modifiers used. Args: $($PSBoundParameters | ConvertTo-Json)"
            }
            return
        }

        [string[]] $argsToUse = @()
        if ($ShowLineNumbers) {
            $argsToUse += "--number"
        }
        [bool] $willAnsiPassThru = $true
        if ($AnsiPassThru -and $TextContentSpecialCharHighlight) {
            Write-Debug "Get-Viewer-Batcat: Cannot specify both -AnsiPassThru and -TextContentSpecialCharHighlight, they are mutually exclusive."
            return
        } elseif ($TextContentSpecialCharHighlight) {
            $argsToUse += "--show-all"
            $willAnsiPassThru = $false
        }

        [System.Collections.Immutable.ImmutableDictionary[string,string]] $binEnv = [System.Collections.Immutable.ImmutableDictionary[string,string]]::Empty
        [string] $cat_bin = (Search-CommandPathMemoized "cat")
        if ($cat_bin) {
            [string] $invocationSignature = (Get-InvocationSignature $cat_bin @argsToUse)
            $argsToUse = [System.Collections.Immutable.ImmutableList]::Create($argsToUse)
            [PSCustomObject]@{
                Id = "cat#${invocationSignature}"; Name = "cat"; Bin = $cat_bin; BinArgs = $argsToUse; AcceptsInputPiped = $true;
                AlwaysPages = $false; NeverPages = $true; ShortPageEarlyExit = $true; MayPage = $false;
                MayUseExternalPager = $false; NeverUsesExternalPager = $true; TerminalWaitsUntilExit = $false;
                AnsiPassThru = $willAnsiPassThru; ShowLineNumbers = [bool]$ShowLineNumbers;
                BinEnv = $binEnv;
            } | Write-Output
        } else {
            Write-Debug "Get-Viewer-Cat: No 'cat' binary found."
        }
    }
}
