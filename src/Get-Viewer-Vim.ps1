#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-Viewer-Vim {
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
            # $EditingAllowed,
            $ReadOnly,
            # $StayInTerminal,
            # $TerminalWaitsUntilExit,
            $GuiNoWait,
            $AnsiPassThru,
            $ShowLineNumbers,
            # $NoLineNumbers,
            # $TextContentPlain,
            $TextContentSpecialCharHighlight,
            $TextContentSyntaxHighlight,
            $BinaryContentBlob,
            $OnlyIfHosting,
            $ShortPageEarlyExit,
            # $AlwaysPages
            $NeverPages,
            $MayUseExternalPager,
            # $NeverUseExternalPager,
            $AcceptsInputPiped
        )
        if ($alwaysDisqualifyingModifiers -contains $true) {
            if ($DebugPreference -eq "Continue") {
                Write-Debug "Get-Viewer-Vim: Always-disqualifying modifiers used. Args: $($PSBoundParameters | ConvertTo-Json)"
            }
            return
        }
        if ($ReadOnly) {
            $argsToUse += @('-R')
        }

        [string[]] $argsToUse = @()
        [System.Collections.Immutable.ImmutableDictionary[string,string]] $binEnv = [System.Collections.Immutable.ImmutableDictionary[string,string]]::Empty
        [string] $vim_bin = (Search-CommandPathMemoized "vim")
        if ($vim_bin) {
            [string] $invocationSignature = (Get-InvocationSignature $vim_bin @argsToUse)
            $argsToUse = [System.Collections.Immutable.ImmutableList]::Create($argsToUse)
            [PSCustomObject]@{
                Id = "vim#${invocationSignature}"; Name = "vim"; Bin = $vim_bin; BinArgs = $argsToUse; AcceptsInputPiped = $false;
                AlwaysPages = $true; NeverPages = $false; ShortPageEarlyExit = $false; MayPage = $true;
                MayUseExternalPager = $false; NeverUsesExternalPager = $true; TerminalWaitsUntilExit = $true;
                AnsiPassThru = $false; ShowLineNumbers = $false;
                BinEnv = $binEnv;
            } | Write-Output
        } else {
            Write-Debug "Get-Viewer-Vim: No 'vim' binary found."
        }
    }
}
