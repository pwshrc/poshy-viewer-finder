#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-Viewer-Neovim {
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
            # $ReadOnly,
            # $StayInTerminal,
            # $TerminalWaitsUntilExit,
            $GuiNoWait,
            $AnsiPassThru,
            # $ShowLineNumbers,
            # $NoLineNumbers,
            # $TextContentPlain,
            # $TextContentSpecialCharHighlight,
            $TextContentSyntaxHighlight, # TODO.
            # $BinaryContentBlob,
            $OnlyIfHosting,
            $ShortPageEarlyExit,
            # $AlwaysPages
            $NeverPages,
            $MayUseExternalPager
            # $NeverUseExternalPager,
            # $AcceptsInputPiped
        )
        if ($alwaysDisqualifyingModifiers -contains $true) {
            if ($DebugPreference -eq "Continue") {
                Write-Debug "Get-Viewer-Neovim: Always-disqualifying modifiers used. Args: $($PSBoundParameters | ConvertTo-Json)"
            }
            return
        }

        [string[]] $argsToUse = @()
        $argsToUse += @(
            '-c', 'set mouse=ar'
        )
        if ($ReadOnly) {
            $argsToUse += @('-R')
        }
        if ($ShowLineNumbers) {
            $argsToUse += @('-c', 'set number')
        } elseif ($NoLineNumbers) {
            $argsToUse += @('-c', 'set nonumber')
        }
        if ($TextContentSyntaxHighlight) {
            # TODO.
            # $argsToUse += @('-c', 'set syntax')
        } elseif ($TextContentPlain) {
            $argsToUse += @('-c', 'set nosyntax')
        }

        if ($BinaryContentBlob) {
            $argsToUse += @('-c', 'set binary')
            $argsToUse += @('-c', 'set display=uhex')
            $argsToUse += @('-c', 'set nospell')
        }
        if ($TextContentSpecialCharHighlight) {
            $argsToUse += @('-c', 'set list')
            $argsToUse += @('-c', 'set nospell')
        }
        if ((-not $BinaryContentBlob) -and (-not $TextContentSpecialCharHighlight)) {
            $argsToUse += @('-c', 'set spell')
        }


        [System.Collections.Immutable.ImmutableDictionary[string,string]] $binEnv = [System.Collections.Immutable.ImmutableDictionary[string,string]]::Empty
        [string] $neovim_bin = (Search-CommandPathMemoized "nvim" "neovim")
        if ($neovim_bin) {
            [string] $invocationSignature = (Get-InvocationSignature $neovim_bin @argsToUse)
            $argsToUse = [System.Collections.Immutable.ImmutableList]::Create($argsToUse)
            [PSCustomObject]@{
                Id = "neovim#${invocationSignature}"; Name = "neovim"; Bin = $neovim_bin; BinArgs = $argsToUse; AcceptsInputPiped = $true;
                AlwaysPages = $true; NeverPages = $false; ShortPageEarlyExit = $false; MayPage = $true;
                MayUseExternalPager = $false; NeverUsesExternalPager = $true; TerminalWaitsUntilExit = $true;
                AnsiPassThru = $false; ShowLineNumbers = ([bool]$ShowLineNumbers -or (-not $NoLineNumbers));
                BinEnv = $binEnv;
            } | Write-Output
        } else {
            Write-Debug "Get-Viewer-Neovim: No neovim binary ('nvim') found."
        }
    }
}
