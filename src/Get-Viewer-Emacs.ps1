#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-Viewer-Emacs {
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
            # $OnlyIfHosting,
            $ShortPageEarlyExit,
            # $AlwaysPages
            $NeverPages,
            $MayUseExternalPager,
            # $NeverUseExternalPager,
            $AcceptsInputPiped
        )
        if ($alwaysDisqualifyingModifiers -contains $true) {
            if ($DebugPreference -eq "Continue") {
                Write-Debug "Get-Viewer-Emacs: Always-disqualifying modifiers used. Args: $($PSBoundParameters | ConvertTo-Json)"
            }
            return
        }
        if ($OnlyIfHosting -and (-not $Env:EMACS)) {
            Write-Debug "Get-Viewer-Emacs: OnlyIfHosting is set, but Emacs is not running in a terminal."
            return
        }

        [string[]] $argsToUse = @()
        [System.Collections.Immutable.ImmutableDictionary[string,string]] $binEnv = [System.Collections.Immutable.ImmutableDictionary[string,string]]::Empty
        [string] $emacs_bin = (Search-CommandPathMemoized "emacs")
        if ($emacs_bin) {
            [string] $invocationSignature = (Get-InvocationSignature $emacs_bin @argsToUse)
            $argsToUse = [System.Collections.Immutable.ImmutableList]::Create($argsToUse)
            [PSCustomObject]@{
                Id = "emacs#${invocationSignature}"; Name = "emacs"; Bin = $emacs_bin; BinArgs = $argsToUse; AcceptsInputPiped = $false;
                AlwaysPages = $true; NeverPages = $false; ShortPageEarlyExit = $false; MayPage = $true;
                MayUseExternalPager = $false; NeverUsesExternalPager = $true; TerminalWaitsUntilExit = $true;
                AnsiPassThru = $false; ShowLineNumbers = $false;
                BinEnv = $binEnv;
            } | Write-Output
        } else {
            Write-Debug "Get-Viewer-Emacs: No 'emacs' binary found."
        }
    }
}
