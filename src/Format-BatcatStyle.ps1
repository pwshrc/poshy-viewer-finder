#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function Format-BatcatStyle {
    [CmdletBinding(DefaultParameterSetName = 'OnlyParseAndSimplifyGiven')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'OnlyParseAndSimplifyGiven')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Set_Auto')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Set_Full')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Set_Plain')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Add_Changes')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Remove_Changes')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Add_Header')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Remove_Header')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Add_Grid')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Remove_Grid')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Add_Numbers')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Remove_Numbers')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Add_Snip')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Remove_Snip')]
        [object] $InputObject,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Set_Auto')]
        [switch] $Set_Auto,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Set_Full')]
        [switch] $Set_Full,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Set_Plain')]
        [switch] $Set_Plain,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Add_Changes')]
        [switch] $Add_Changes,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Remove_Changes')]
        [switch] $Remove_Changes,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Add_Header')]
        [switch] $Add_Header,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Remove_Header')]
        [switch] $Remove_Header,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Add_Grid')]
        [switch] $Add_Grid,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Remove_Grid')]
        [switch] $Remove_Grid,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Add_Numbers')]
        [switch] $Add_Numbers,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Remove_Numbers')]
        [switch] $Remove_Numbers,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Add_Snip')]
        [switch] $Add_Snip,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Remove_Snip')]
        [switch] $Remove_Snip
    )

    [Nullable[bool]] $auto = $null
    [Nullable[bool]] $full = $null
    [Nullable[bool]] $plain = $null
    [Nullable[bool]] $changes = $null
    [Nullable[bool]] $header = $null
    [Nullable[bool]] $grid = $null
    [Nullable[bool]] $numbers = $null
    [Nullable[bool]] $snip = $null

    if (-not $InputObject) {
        $InputObject = [string[]]@()
    } elseif ($InputObject -is [string]) {
        $InputObject = [string[]]@($InputObject)
    } else {
        $InputObject = [string[]]@($InputObject -as [string])
    }

    if (($InputObject.Count -eq 1) -and ($InputObject[0] -like ",")) {
        $InputObject = $InputObject[0] -split ","
    }

    if (-not $InputObject) {
        $auto = $true
        $full = $false
        $plain = $true
        $changes = $false
        $header = $false
        $grid = $false
        $numbers = $false
        $snip = $true
    } else {
        $InputObject | ForEach-Object {
            if ($_ -match '^auto$') {
                $auto = $true
                $full = $false
                $plain = $true
                $changes = $false
                $header = $false
                $grid = $false
                $numbers = $false
                $snip = $true
            }
            elseif ($_ -match '^full$') {
                $auto = $false
                $full = $true
                $plain = $false
                $changes = $true
                $header = $true
                $grid = $true
                $numbers = $true
                $snip = $true
            }
            elseif ($_ -match '^plain$') {
                $auto = $false
                $full = $false
                $plain = $true
                $changes = $false
                $header = $false
                $grid = $false
                $numbers = $false
                $snip = $false
            }
            elseif ($_ -match '^changes$') {
                $auto = $false
                $plain = $false
                $changes = $true
            }
            elseif ($_ -match '^header$') {
                $auto = $false
                $plain = $false
                $header = $true
            }
            elseif ($_ -match '^grid$') {
                $auto = $false
                $plain = $false
                $grid = $true
            }
            elseif ($_ -match '^numbers$') {
                $auto = $false
                $plain = $false
                $numbers = $true
            }
            elseif ($_ -match '^snip$') {
                $auto = $false
                $plain = $false
                $snip = $true
            }
            else {
                throw "Invalid argument: $_"
            }
        }
    }

    if ($Set_Auto) {
        $auto = $true
        $full = $false
        $plain = $true
        $changes = $false
        $header = $false
        $grid = $false
        $numbers = $false
        $snip = $true
    } elseif ($Set_Full) {
        $auto = $false
        $full = $true
        $plain = $false
        $changes = $true
        $header = $true
        $grid = $true
        $numbers = $true
        $snip = $true
    } elseif ($Set_Plain) {
        $auto = $false
        $full = $false
        $plain = $true
        $changes = $false
        $header = $false
        $grid = $false
        $numbers = $false
        $snip = $false
    } elseif ($Add_Changes) {
        $auto = $false
        $changes = $true

        $full = ($header -and $grid -and $numbers -and $snip)
        $plain = $false
    } elseif ($Remove_Changes) {
        $auto = $false
        $changes = $false

        $full = $false
        $plain = -not ($header -or $grid -or $numbers -or $snip)
    } elseif ($Add_Header) {
        $auto = $false
        $header = $true

        $full = ($changes -and $grid -and $numbers -and $snip)
        $plain = $false
    } elseif ($Remove_Header) {
        $auto = $false
        $header = $false

        $full = $false
        $plain = -not ($changes -or $grid -or $numbers -or $snip)
    } elseif ($Add_Grid) {
        $auto = $false
        $grid = $true

        $full = ($changes -and $header -and $numbers -and $snip)
        $plain = $false
    } elseif ($Remove_Grid) {
        $auto = $false
        $grid = $false

        $full = $false
        $plain = -not ($changes -or $header -or $numbers -or $snip)
    } elseif ($Add_Numbers) {
        $auto = $false
        $numbers = $true

        $full = ($changes -and $header -and $grid -and $snip)
        $plain = $false
    } elseif ($Remove_Numbers) {
        $auto = $false
        $numbers = $false

        $full = $false
        $plain = -not ($changes -or $header -or $grid -or $snip)
    } elseif ($Add_Snip) {
        $auto = $false
        $snip = $true

        $full = ($changes -and $header -and $grid -and $numbers)
        $plain = $false
    } elseif ($Remove_Snip) {
        $auto = $false
        $snip = $false

        $full = $false
        $plain = -not ($changes -or $header -or $grid -or $numbers)
    }

    if ($auto) {
        return "auto"
    } elseif ($full) {
        return "full"
    } elseif ($plain) {
        return "plain"
    } else {
        $result = @()
        if ($changes) { $result += "changes" }
        if ($header) { $result += "header" }
        if ($grid) { $result += "grid" }
        if ($numbers) { $result += "numbers" }
        if ($snip) { $result += "snip" }
        return ($result -join ",")
    }
}
