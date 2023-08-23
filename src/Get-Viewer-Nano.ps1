#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-Viewer-Nano {
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
            $TextContentSpecialCharHighlight,
            # $TextContentSyntaxHighlight,
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
                Write-Debug "Get-Viewer-Nano: Always-disqualifying modifiers used. Args: $($PSBoundParameters | ConvertTo-Json)"
            }
            return
        }

        [string] $nano_bin = (Search-CommandPathMemoized "nano")
        if (-not $nano_bin) {
            Write-Debug "Get-Viewer-Nano: No 'nano' binary found."
            return
        }

        [string[]] $nanoSupports = (Get-NanoOptionList | Select-Object -ExpandProperty SyntaxLong)
        Write-Debug "Get-Viewer-Nano: Nano supports: $nanoSupports."

        [string[]] $argsToUse = @()
        if ($nanoSupports -contains "--mouse") {
            $argsToUse += @("--mouse")
        }
        if ($nanoSupports -contains "--positionlog") {
            $argsToUse += @("--positionlog")
        }
        if ($nanoSupports -contains "--stateflags") {
            $argsToUse += @("--stateflags")
        }
        if ($nanoSupports -contains "--indicator") {
            $argsToUse += @("--indicator")
        }
        if ($nanoSupports -contains "--wordbounds") {
            $argsToUse += @("--wordbounds")
        }
        if ($nanoSupports -contains "--smooth") {
            $argsToUse += @("--smooth")
        }
        if ($IsWindows -and ($nanoSupports -contains "--noconvert")) {
            $argsToUse += @("--noconvert")
        }
        if ($ReadOnly -and ($nanoSupports -contains "--view")) {
            $argsToUse += @("--view")
        } elseif ($ReadOnly) {
            Write-Debug "Get-Viewer-Nano: --view not supported."
            return
        }

        if ($ShowLineNumbers -and ($nanoSupports -contains "--linenumbers")) {
            $argsToUse += @("--linenumbers")
        } elseif ($ShowLineNumbers) {
            Write-Debug "Get-Viewer-Nano: --linenumbers not supported."
            return
        }

        if ($TextContentSyntaxHighlight -and ($nanoSupports -contains "--magic")) {
            $argsToUse += @("--magic")
        } elseif ($TextContentSyntaxHighlight -and ($nanoSupports -contains "--syntax")) {
            # TODO.
        } elseif ($TextContentSyntaxHighlight) {
            Write-Debug "Get-Viewer-Nano: --magic and --syntax not supported."
            return
        }

        if ($Env:TERM_ITALICS -and ($nanoSupports -contains "--boldtext")) {
            $argsToUse += @("--boldtext")
        }

        [System.Collections.Immutable.ImmutableDictionary[string,string]] $binEnv = [System.Collections.Immutable.ImmutableDictionary[string,string]]::Empty

        if ($nano_bin) {
            [string] $invocationSignature = (Get-InvocationSignature $nano_bin @argsToUse)
            $argsToUse = [System.Collections.Immutable.ImmutableList]::Create($argsToUse)
            [PSCustomObject]@{
                Id = "nano#${invocationSignature}"; Name = "nano"; Bin = $nano_bin; BinArgs = $argsToUse; AcceptsInputPiped = $false;
                AlwaysPages = $true; NeverPages = $false; ShortPageEarlyExit = $false; MayPage = $true;
                MayUseExternalPager = $false; NeverUsesExternalPager = $true; TerminalWaitsUntilExit = $true;
                AnsiPassThru = $false; ShowLineNumbers = ([bool]$ShowLineNumbers -or (-not $NoLineNumbers));
                BinEnv = $binEnv;
            } | Write-Output
        } else {
            Write-Debug "Get-Viewer-Nano: No 'nano' binary found."
        }
    }
}
