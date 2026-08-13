#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Set-FileLink {
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $Target
    )

    if (-not (Test-Path -LiteralPath $Target)) {
        throw "Link target does not exist: $Target"
    }

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $backup = $null

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue

    if ($null -ne $item) {
        $currentTarget = @($item.Target) | Select-Object -First 1

        if ($item.LinkType -eq "SymbolicLink" -and $currentTarget -eq $Target) {
            Write-Host "Already linked: $Path"
            return
        }

        $backup = "$Path.pre-link-$stamp.bak"
        Move-Item -LiteralPath $Path -Destination $backup
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Path -Target $Target | Out-Null
        Write-Host "Linked: $Path -> $Target"
    } catch {
        if ($backup -and (Test-Path -LiteralPath $backup) -and -not (Test-Path -LiteralPath $Path)) {
            Move-Item -LiteralPath $backup -Destination $Path
        }

        throw
    }
}

Set-FileLink `
    -Path (Join-Path $env:APPDATA "nushell\config.nu") `
    -Target (Join-Path $repoRoot "config.nu")

Set-FileLink `
    -Path (Join-Path $HOME ".config\starship.toml") `
    -Target (Join-Path $repoRoot "starship.toml")
