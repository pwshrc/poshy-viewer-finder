#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-Viewer-VisualStudio {
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
            $TerminalWaitsUntilExit,
            # $GuiNoWait,
            $AnsiPassThru,
            # $ShowLineNumbers,
            $NoLineNumbers,
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
                Write-Debug "Get-Viewer-VisualStudio: Always-disqualifying modifiers used. Args: $($PSBoundParameters | ConvertTo-Json)"
            }
            return
        }

        [string[]] $argsToUse = @()
        $argsToUse += @('/Edit')

        [System.Collections.Immutable.ImmutableDictionary[string,string]] $binEnv = [System.Collections.Immutable.ImmutableDictionary[string,string]]::Empty
        [string] $programfiles_visual_studio="$Env:ProgramFiles\Microsoft Visual Studio\"
        if (Test-Path $programfiles_visual_studio -ErrorAction SilentlyContinue) {
            [hashtable[]] $visual_studio_yearskus=@(
                @{year=2022;sku="Enterprise"}
                @{year=2022;sku="Professional"}
                @{year=2022;sku="Community"}

                @{year=2019;sku="Enterprise"}
                @{year=2019;sku="Professional"}
                @{year=2019;sku="Community"}
            )
            foreach ($vs in $visual_studio_yearskus) {
                $vs_year = $vs.year
                $vs_sku = $vs.sku
                [string] $vs_bin = (Search-VisualStudioYearEditionDevEnvPathMemoized -Year $vs_year -Edition $vs_sku)

                if ($vs_bin) {
                    [string] $invocationSignature = (Get-InvocationSignature $vs_bin @argsToUse)
                    $argsToUse = [System.Collections.Immutable.ImmutableList]::Create($argsToUse)
                    [PSCustomObject]@{
                        Id = "visualstudio_${vs_year}_${vs_sku}#${invocationSignature}"; Name = "Visual Studio $vs_year $vs_sku"; Bin = $vs_bin; BinArgs = $argsToUse; AcceptsInputPiped = $false;
                        AlwaysPages = $true; NeverPages = $false; ShortPageEarlyExit = $false; MayPage = $true;
                        MayUseExternalPager = $false; NeverUsesExternalPager = $true; TerminalWaitsUntilExit = $false;
                        AnsiPassThru = $false; ShowLineNumbers = $true;
                        BinEnv = $binEnv;
                    } | Write-Output
                } else {
                    Write-Debug "Get-Viewer-VisualStudio: No Visual Studio $vs_year $vs_sku binary ('devenv.exe') found."
                }
            }
        }
    }
}
