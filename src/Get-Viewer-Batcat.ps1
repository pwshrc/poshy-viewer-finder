#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-Viewer-Batcat {
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
            # $TextContentSyntaxHighlight,
            $BinaryContentBlob,
            $OnlyIfHosting
            # $ShortPageEarlyExit
            # $AlwaysPages
            # $NeverPages
            # $MayUseExternalPager,
            $NeverUseExternalPager
            # $AcceptsInputPiped
        )
        if ($alwaysDisqualifyingModifiers -contains $true) {
            if ($DebugPreference -eq "Continue") {
                Write-Debug "Get-Viewer-Batcat: Always-disqualifying modifiers used. Args: $($PSBoundParameters | ConvertTo-Json)"
            }
            return
        }
        if ($NeverUseExternalPager -and $AlwaysPages) {
            Write-Debug "Get-Viewer-Batcat: -NeverUseExternalPager and -AlwaysPages are mutually exclusive."
            return
        }
        if ($TerminalWaitsUntilExit -and $NeverPages) {
            Write-Debug "Get-Viewer-Batcat: -TerminalWaitsUntilExit and -NeverPages are mutually exclusive."
            return
        }
        if ($TerminalWaitsUntilExit -and (-not $AlwaysPages)) {
            Write-Debug "Get-Viewer-Batcat: -TerminalWaitsUntilExit requires -AlwaysPages."
            return
        }

        [string] $batcat_style = (($Env:BAT_STYLE ?? "") | Format-BatcatStyle)

        [string[]] $argsToUse = @()
        if ($TextContentPlain -and (-not ($TextContentSyntaxHighlight))) {
            $batcat_style = $batcat_style | Format-BatcatStyle -Set_Plain
            $argsToUse += @('--decorations=never')
        } elseif ($TextContentPlain -or $TextContentSyntaxHighlight) {
            $argsToUse += @('--decorations=auto')
        }
        if ($ShowLineNumbers) {
            $batcat_style = $batcat_style | Format-BatcatStyle -Add_Numbers
        } elseif ($NoLineNumbers) {
            $batcat_style = $batcat_style | Format-BatcatStyle -Remove_Numbers
        }
        $argsToUse += @("--style=$batcat_style")

        [bool] $willAnsiPassThru = $true
        if ($AnsiPassThru -and $TextContentSpecialCharHighlight) {
            Write-Debug "Get-Viewer-Batcat: Cannot specify both -AnsiPassThru and -TextContentSpecialCharHighlight, they are mutually exclusive."
            return
        } elseif ($TextContentSpecialCharHighlight) {
            $argsToUse += "--show-all"
            $willAnsiPassThru = $false
        }

        [bool] $mayPage = (-not [bool]$NeverPages)
        if (($ShortPageEarlyExit) -and (-not $AlwaysPages) -and $mayPage) {
            $argsToUse += @("--paging=auto")
        } elseif ($ShortPageEarlyExit -and $AlwaysPages) {
            Write-Debug "Get-Viewer-Batcat: Cannot specify -ShortPageEarlyExit when -AlwaysPages is specified."
            return
        } elseif ($AlwaysPages -and $mayPage) {
            $argsToUse += @("--paging=always")
        } elseif ($NeverPages) {
            $argsToUse += @("--paging=never")
        }
        [bool] $mayShortPageEarlyExit = ([bool]$NeverPages -or (-not $AlwaysPages))

        if (Test-Path Env:\CLICOLOR -ErrorAction SilentlyContinue) {
            if ($Env:CLICOLOR) {
                $argsToUse += @("--color=always")
            } else {
                $argsToUse += @("--color=never")
            }
        } elseif (Test-Path Env:\NO_COLOR -ErrorAction SilentlyContinue) {
            if ($Env:NO_COLOR) {
                $argsToUse += @("--color=never")
            }
        } else {
            $argsToUse += @("--color=auto")
        }

        if ($Env:TERM_ITALICS) {
            $argsToUse += @("--italic-text=always")
        }

        [System.Collections.Immutable.ImmutableDictionary[string,string]] $binEnv = [System.Collections.Immutable.ImmutableDictionary[string,string]]::Empty
        [string] $batcat_bin = (Search-CommandPathMemoized "batcat")
        if ($batcat_bin) {
            [string] $invocationSignature = (Get-InvocationSignature $batcat_bin @argsToUse)
            $argsToUse = [System.Collections.Immutable.ImmutableList]::Create($argsToUse)
            [PSCustomObject]@{
                Id = "batcat#${invocationSignature}"; Name = "batcat"; Bin = $batcat_bin; BinArgs = $argsToUse; AcceptsInputPiped = $true;
                AlwaysPages = [bool]$AlwaysPages; NeverPages = [bool]$NeverPages; ShortPageEarlyExit = $mayShortPageEarlyExit; MayPage = $mayPage;
                MayUseExternalPager = $mayPage; NeverUsesExternalPager = $false; TerminalWaitsUntilExit = [bool]$AlwaysPages;
                AnsiPassThru = $willAnsiPassThru; ShowLineNumbers = ([bool]$ShowLineNumbers -or (-not $NoLineNumbers));
                BinEnv = $binEnv;
            } | Write-Output
        } elseif(Search-CommandPathMemoized "bat") {
            Write-Debug "Get-Viewer-Batcat: No 'batcat' binary found, but 'bat' binary found. Using 'bat' instead."
            [string] $bat_bin = (Search-CommandPathMemoized "bat")
            [string] $invocationSignature = (Get-InvocationSignature $bat_bin @argsToUse)
            $argsToUse = [System.Collections.Immutable.ImmutableList]::Create($argsToUse)
            [PSCustomObject]@{
                Id = "bat#${invocationSignature}"; Name = "bat"; Bin = $bat_bin; BinArgs = $argsToUse; AcceptsInputPiped = $true;
                AlwaysPages = [bool]$AlwaysPages; NeverPages = [bool]$NeverPages; ShortPageEarlyExit = $mayShortPageEarlyExit; MayPage = $mayPage;
                MayUseExternalPager = $mayPage; NeverUsesExternalPager = $false; TerminalWaitsUntilExit = [bool]$AlwaysPages;
                AnsiPassThru = $willAnsiPassThru; ShowLineNumbers = ([bool]$ShowLineNumbers -or (-not $NoLineNumbers));
                BinEnv = $binEnv;
            } | Write-Output
        } else {
            Write-Debug "Get-Viewer-Batcat: No 'batcat' binary found."
        }
    }
}
