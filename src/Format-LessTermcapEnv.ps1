#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Format-LessTermcapEnv {
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "NaiveDefaults")]
        [switch] $NaiveDefaults,

        [Parameter(Mandatory = $true, ParameterSetName = "BlankDefaults")]
        [switch] $BlankDefaults,

        [Parameter(Mandatory = $true, ParameterSetName = "NullDefaults")]
        [switch] $NullDefaults,

        [Parameter(Mandatory = $false)]
        [string] $BlinkOn = $null,

        [Parameter(Mandatory = $false)]
        [string] $BoldOn = $null,

        [Parameter(Mandatory = $false)]
        [string] $BoldOffBlinkOffUnderlineOff = $null,

        [Parameter(Mandatory = $false)]
        [string] $StandoutOn = $null,

        [Parameter(Mandatory = $false)]
        [string] $StandoutOff = $null,

        [Parameter(Mandatory = $false)]
        [string] $UnderlineOn = $null,

        [Parameter(Mandatory = $false)]
        [string] $UnderlineOff = $null,

        [Parameter(Mandatory = $false)]
        [string] $VisualBell = $null,

        [Parameter(Mandatory = $false)]
        [string] $KeypadModeCommands = $null,

        [Parameter(Mandatory = $false)]
        [string] $KeypadModeDigits = $null,

        [Parameter(Mandatory = $false)]
        [string] $ReverseVideoOn = $null,

        [Parameter(Mandatory = $false)]
        [string] $HalfBrightOn = $null,

        [Parameter(Mandatory = $false)]
        [string] $SubscriptOn = $null,

        [Parameter(Mandatory = $false)]
        [string] $SubscriptOff = $null,

        [Parameter(Mandatory = $false)]
        [string] $SuperscriptOn = $null,

        [Parameter(Mandatory = $false)]
        [string] $SuperscriptOff = $null
    )
    if ($NaiveDefaults) {
        $BlinkOn ??= (fmtBlink (fgBrightGreen))
        $BoldOn ??= (fmtBold (fgGreen))
        $BoldOffBlinkOffUnderlineOff ??= (fmtReset)
        $StandoutOn ??= (fmtReverse)
        $StandoutOff ??= (fmtReverseOff)
        $UnderlineOn ??= (fmtUnderline)
        $UnderlineOff ??= (fmtUnderlineOff)
        $VisualBell = $null
        $KeypadModeCommands = $null
        $KeypadModeDigits = $null
        $ReverseVideoOn = $null
        $HalfBrightOn = $null
        $SubscriptOn = $null
        $SubscriptOff = $null
        $SuperscriptOn = $null
        $SuperscriptOff = $null
    } elseif ($BlankDefaults) {
        $BlinkOn ??= ""
        $BoldOn ??= ""
        $BoldOffBlinkOffUnderlineOff ??= ""
        $StandoutOn ??= ""
        $StandoutOff ??= ""
        $UnderlineOn ??= ""
        $UnderlineOff ??= ""
        $VisualBell ??= ""
        $KeypadModeCommands ??= ""
        $KeypadModeDigits ??= ""
        $ReverseVideoOn ??= ""
        $HalfBrightOn ??= ""
        $SubscriptOn ??= ""
        $SubscriptOff ??= ""
        $SuperscriptOn ??= ""
        $SuperscriptOff ??= ""
    }

    #
    # termcap code descriptions
    #
    # ks      make the keypad send commands
    # ke      make the keypad send digits
    # vb      emit visual bell
    # mb      start blink
    # md      start bold
    # me      turn off all attributes
    # so      start standout (reverse video)
    # se      stop standout
    # us      start underline
    # ue      stop underline
    # mr      start reverse video
    # mh      start half-bright mode
    # ZN      start subscript mode
    # ZV      stop subscript mode
    # ZO      start superscript mode
    # ZW      stop superscript mode
    #
    # See:
    #    https://www.man7.org/linux/man-pages/man5/termcap.5.html
    #    https://unix.stackexchange.com/a/147
    #    https://gist.github.com/izabera/9903f9d942e2667ef2cb
    #

    [hashtable] $results = @{}
    if ($null -ne $KeypadModeCommands) {
        $results["LESS_TERMCAP_ks"] = $KeypadModeCommands
    }

    if ($null -ne $KeypadModeDigits) {
        $results["LESS_TERMCAP_ke"] = $KeypadModeDigits
    }

    if ($null -ne $VisualBell) {
        $results["LESS_TERMCAP_vb"] = $VisualBell
    }

    if ($null -ne $BlinkOn) {
        $results["LESS_TERMCAP_mb"] = $BlinkOn
    }

    if ($null -ne $BoldOn) {
        $results["LESS_TERMCAP_md"] = $BoldOn
    }

    if ($null -ne $BoldOffBlinkOffUnderlineOff) {
        $results["LESS_TERMCAP_me"] = $BoldOffBlinkOffUnderlineOff
    }

    if ($null -ne $StandoutOn) {
        $results["LESS_TERMCAP_so"] = $StandoutOn
    }

    if ($null -ne $StandoutOff) {
        $results["LESS_TERMCAP_se"] = $StandoutOff
    }

    if ($null -ne $UnderlineOn) {
        $results["LESS_TERMCAP_us"] = $UnderlineOn
    }

    if ($null -ne $UnderlineOff) {
        $results["LESS_TERMCAP_ue"] = $UnderlineOff
    }

    if ($null -ne $ReverseVideoOn) {
        $results["LESS_TERMCAP_mr"] = $ReverseVideoOn
    }

    if ($null -ne $HalfBrightOn) {
        $results["LESS_TERMCAP_mh"] = $HalfBrightOn
    }

    if ($null -ne $null) {
        $results["LESS_TERMCAP_ZN"] = $SubscriptOn
    }

    if ($null -ne $null) {
        $results["LESS_TERMCAP_ZV"] = $SubscriptOff

    }

    if ($null -ne $null) {
        $results["LESS_TERMCAP_ZO"] = $SuperscriptOn
    }

    if ($null -ne $null) {
        $results["LESS_TERMCAP_ZW"] = $SuperscriptOff
    }

    return $results
}
