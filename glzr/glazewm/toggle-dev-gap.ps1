$ErrorActionPreference = "Stop"

$glazeWmCommand = Get-Command glazewm.exe -ErrorAction SilentlyContinue
$glazeWm = if ($null -ne $glazeWmCommand) {
    $glazeWmCommand.Source
} else {
    Join-Path $env:ProgramFiles "glzr.io\GlazeWM\glazewm.exe"
}
if (-not (Test-Path -LiteralPath $glazeWm)) {
    throw "GlazeWM executable not found: $glazeWm"
}

function Invoke-GlazeWm {
    param([Parameter(Mandatory)][string[]] $Arguments)

    $response = & $script:glazeWm @Arguments | ConvertFrom-Json
    if (-not $response.success) {
        throw $response.error
    }
    return $response.data
}

function Get-WorkspaceWindows {
    param([Parameter(Mandatory)] $Container)

    if ($Container.type -eq "window") {
        return ,$Container
    }

    $windows = @()
    foreach ($child in @($Container.children)) {
        $windows += Get-WorkspaceWindows -Container $child
    }
    return $windows
}

$focused = (Invoke-GlazeWm -Arguments @("query", "focused")).focused
if ($focused.type -ne "window" -or $focused.state.type -ne "tiling") {
    return
}

$processName = $focused.processName.ToLowerInvariant()
if ($processName -notin @("neovide", "wezterm-gui")) {
    return
}

$workspace = $null
$workspaceWindows = @()
foreach ($candidate in (Invoke-GlazeWm -Arguments @("query", "workspaces")).workspaces) {
    $candidateWindows = @(Get-WorkspaceWindows -Container $candidate)
    if ($candidateWindows.id -contains $focused.id) {
        $workspace = $candidate
        $workspaceWindows = $candidateWindows
        break
    }
}
if ($null -eq $workspace) {
    return
}

$neovideWindows = @($workspaceWindows | Where-Object {
    $_.state.type -eq "tiling" -and $_.processName -ieq "neovide"
})
$weztermWindows = @($workspaceWindows | Where-Object {
    $_.state.type -eq "tiling" -and $_.processName -ieq "wezterm-gui"
})

$pairs = foreach ($neovide in $neovideWindows) {
    foreach ($wezterm in $weztermWindows) {
        $verticalOverlap = [Math]::Min($neovide.y + $neovide.height, $wezterm.y + $wezterm.height) -
            [Math]::Max($neovide.y, $wezterm.y)
        if ($verticalOverlap -le 0) {
            continue
        }

        $gap = $wezterm.x - ($neovide.x + $neovide.width)
        if ($gap -ge 0 -and $gap -le 32) {
            [PSCustomObject]@{
                Neovide = $neovide
                WezTerm = $wezterm
                Gap = $gap
                Side = "left"
            }
        }

        $gap = $neovide.x - ($wezterm.x + $wezterm.width)
        if ($gap -ge 0 -and $gap -le 32) {
            [PSCustomObject]@{
                Neovide = $neovide
                WezTerm = $wezterm
                Gap = $gap
                Side = "right"
            }
        }
    }
}

$pair = $pairs | Where-Object {
    $_.Neovide.id -eq $focused.id -or $_.WezTerm.id -eq $focused.id
} | Sort-Object Gap | Select-Object -First 1
if ($null -eq $pair) {
    return
}

$compactDelta = [Math]::Max(0, $pair.Gap - 2)
$currentDelta = [double]$pair.WezTerm.borderDelta.PSObject.Properties[$pair.Side].Value.amount
$newDelta = if ([Math]::Abs($currentDelta - $compactDelta) -lt 0.1) { 0 } else { $compactDelta }

Invoke-GlazeWm -Arguments @(
    "command",
    "--id",
    $pair.WezTerm.id,
    "adjust-borders",
    "--$($pair.Side)=$($newDelta)px"
) | Out-Null
