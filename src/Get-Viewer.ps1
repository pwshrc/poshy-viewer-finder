#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Get-Viewer {
    [CmdletBinding(DefaultParameterSetName="AllApps")]
    param(
        [Parameter(Mandatory=$false, Position = 0, ParameterSetName="AllApps")]
        [switch] $AllAvailable,

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Batcat", HelpMessage="Any app returned MUST be Batcat.")]
        [switch] ${App_Is_Batcat},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Cat", HelpMessage="Any app returned MUST be Cat.")]
        [switch] ${App_Is_Cat},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Edit", HelpMessage="Any app returned MUST be Edit.")]
        [switch] ${App_Is_Edit},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Emacs", HelpMessage="Any app returned MUST be Emacs.")]
        [switch] ${App_Is_Emacs},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Gedit", HelpMessage="Any app returned MUST be Gedit.")]
        [switch] ${App_Is_Gedit},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Hexdump", HelpMessage="Any app returned MUST be Hexdump.")]
        [switch] ${App_Is_Hexdump},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Less", HelpMessage="Any app returned MUST be Less.")]
        [switch] ${App_Is_Less},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_More", HelpMessage="Any app returned MUST be More.")]
        [switch] ${App_Is_More},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Nano", HelpMessage="Any app returned MUST be Nano.")]
        [switch] ${App_Is_Nano},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Neovim", HelpMessage="Any app returned MUST be Neovim.")]
        [switch] ${App_Is_Neovim},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Notepad", HelpMessage="Any app returned MUST be Notepad.")]
        [switch] ${App_Is_Notepad},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Notepad2", HelpMessage="Any app returned MUST be Notepad2.")]
        [switch] ${App_Is_Notepad2},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Pygmentize", HelpMessage="Any app returned MUST be Pygmentize.")]
        [switch] ${App_Is_Pygmentize},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_Vim", HelpMessage="Any app returned MUST be Vim.")]
        [switch] ${App_Is_Vim},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_VisualStudio", HelpMessage="Any app returned MUST be Visual Studio.")]
        [switch] ${App_Is_VisualStudio},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_VSCode", HelpMessage="Any app returned MUST be VS Code.")]
        [switch] ${App_Is_VSCode},

        [Parameter(Mandatory=$false, ParameterSetName="OnlyApp_VSCodeInsiders", HelpMessage="Any app returned MUST be VS Code Insiders.")]
        [switch] ${App_Is_VSCodeInsiders},

        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST allow editing of the opened file.")]
        [switch] $EditingAllowed,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST NOT allow editing of the opened file. ")]
        [switch] $ReadOnly,

        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST operate from inside the current terminal.")]
        [switch] $StayInTerminal,

        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST block execution until it terminates.")]
        [switch] $TerminalWaitsUntilExit,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST NOT block execution while it is running.")]
        [switch] $GuiNoWait,

        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST correctly render ANSI output when ANSI is present in the input.")]
        [switch] $AnsiPassThru,

        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST show line numbers.")]
        [switch] $ShowLineNumbers,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST NOT show line numbers.")]
        [switch] $NoLineNumbers,

        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST open text files.")]
        [switch] $TextContentPlain,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST highlight non-printable characters in text files.")]
        [switch] $TextContentSpecialCharHighlight,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST perform automatic syntax highlighting in text files.")]
        [switch] $TextContentSyntaxHighlight,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST open binary blobs intelligbly.")]
        [switch] $BinaryContentBlob,

        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST be the application hosting the current terminal.")]
        [switch] $OnlyIfHosting,

        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST exit immediately after opening the file when the file can fit on one screen.")]
        [switch] $ShortPageEarlyExit,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST present an interface for paging through the file.")]
        [switch] $AlwaysPages,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST always dump output directly to the terminal instead of presenting an interface for paging through the file.")]
        [switch] $NeverPages,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MAY use an external pager (e.g. `$Env:PAGER) when/if it pages output.")]
        [switch] $MayUseExternalPager,
        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST NOT use an external pager (e.g. `$Env:PAGER) if/when it pages output.")]
        [switch] $NeverUseExternalPager,

        [Parameter(Mandatory=$false, HelpMessage="Any app returned MUST be able to receive its input via the pipeline.")]
        [switch] $AcceptsInputPiped
    )
    Process {
        [hashtable] $argsToPass = @{
            "EditingAllowed" = $EditingAllowed
            "ReadOnly" = $ReadOnly

            "StayInTerminal" = $StayInTerminal

            "TerminalWaitsUntilExit" = $TerminalWaitsUntilExit
            "GuiNoWait" = $GuiNoWait

            "AnsiPassThru" = $AnsiPassThru

            "ShowLineNumbers" = $ShowLineNumbers
            "NoLineNumbers" = $NoLineNumbers

            "TextContentPlain" = $TextContentPlain
            "TextContentSpecialCharHighlight" = $TextContentSpecialCharHighlight
            "TextContentSyntaxHighlight" = $TextContentSyntaxHighlight
            "BinaryContentBlob" = $BinaryContentBlob

            "OnlyIfHosting" = $OnlyIfHosting

            "ShortPageEarlyExit" = $ShortPageEarlyExit
            "AlwaysPages" = $AlwaysPages
            "NeverPages" = $NeverPages
            "MayUseExternalPager" = $MayUseExternalPager
            "NeverUseExternalPager" = $NeverUseExternalPager

            "AcceptsInputPiped" = $AcceptsInputPiped
        }

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

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Batcat})) {
            Get-Viewer-Batcat @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Cat})) {
            Get-Viewer-Cat @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Edit})) {
            Get-Viewer-Edit @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Emacs})) {
            Get-Viewer-Emacs @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Gedit})) {
            Get-Viewer-Gedit @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Hexdump})) {
            Get-Viewer-Hexdump @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Less})) {
            Get-Viewer-Less @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_More})) {
            Get-Viewer-More @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Nano})) {
            Get-Viewer-Nano @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Neovim})) {
            Get-Viewer-Neovim @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Notepad})) {
            Get-Viewer-Notepad @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Notepad2})) {
            Get-Viewer-Notepad2 @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Pygmentize})) {
            Get-Viewer-Pygmentize @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_Vim})) {
            Get-Viewer-Vim @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_VisualStudio})) {
            Get-Viewer-VisualStudio @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_VSCode})) {
            Get-Viewer-VSCode @argsToPass
        }

        if (($PSCmdlet.ParameterSetName -eq "AllApps") -or (${App_Is_VSCodeInsiders})) {
            Get-Viewer-VSCodeInsiders @argsToPass
        }
    }
}
