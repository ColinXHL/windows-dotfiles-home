#Requires -Version 7.0

param(
    [switch] $SkipNilesoft
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Set-ConfigLink {
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

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -ne $item) {
        $currentTarget = @($item.Target) | Select-Object -First 1
        if (
            $item.LinkType -eq "SymbolicLink" -and
            $null -ne $currentTarget -and
            [IO.Path]::GetFullPath([string] $currentTarget) -ieq [IO.Path]::GetFullPath($Target)
        ) {
            Write-Host "Already linked: $Path"
            return
        }

        $backup = "$Path.pre-dotfiles-$stamp.bak"
        Move-Item -LiteralPath $Path -Destination $backup
        Write-Host "Backed up: $Path -> $backup"
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Path -Target $Target | Out-Null
        Write-Host "Linked: $Path -> $Target"
    } catch {
        if ($null -ne $item -and (Test-Path -LiteralPath $backup) -and -not (Test-Path -LiteralPath $Path)) {
            Move-Item -LiteralPath $backup -Destination $Path
        }

        throw
    }
}

function Set-ConfigTree {
    param(
        [Parameter(Mandatory)]
        [string] $Source,

        [Parameter(Mandatory)]
        [string] $Destination
    )

    Get-ChildItem -LiteralPath $Source -Recurse -File | ForEach-Object {
        $relativePath = [IO.Path]::GetRelativePath($Source, $_.FullName)
        Set-ConfigLink `
            -Path (Join-Path $Destination $relativePath) `
            -Target $_.FullName
    }
}

function Remove-StaleTreeLinks {
    param(
        [Parameter(Mandatory)]
        [string] $Source,

        [Parameter(Mandatory)]
        [string] $Destination
    )

    if (-not (Test-Path -LiteralPath $Destination)) {
        return
    }

    $sourceRoot = [IO.Path]::GetFullPath($Source).TrimEnd('\') + '\'
    Get-ChildItem -LiteralPath $Destination -Recurse -Force | ForEach-Object {
        if ($_.LinkType -ne "SymbolicLink") {
            return
        }

        $target = @($_.Target) | Select-Object -First 1
        if ($null -eq $target) {
            return
        }

        $targetPath = [IO.Path]::GetFullPath([string] $target)
        if ($targetPath.StartsWith($sourceRoot, [StringComparison]::OrdinalIgnoreCase) -and -not (Test-Path -LiteralPath $targetPath)) {
            Remove-Item -LiteralPath $_.FullName -Force
            Write-Host "Removed stale link: $($_.FullName) -> $targetPath"
        }
    }
}

function Move-LegacyGitMetadata {
    param(
        [Parameter(Mandatory)]
        [string] $ConfigPath
    )

    $gitPath = Join-Path $ConfigPath ".git"
    if (-not (Test-Path -LiteralPath $gitPath)) {
        return
    }

    $backup = "$ConfigPath.pre-dotfiles-$stamp.git"
    Move-Item -LiteralPath $gitPath -Destination $backup
    Write-Host "Archived legacy Git metadata: $gitPath -> $backup"
}

$weztermConfig = Join-Path $HOME ".config\wezterm"
$weztermSource = Join-Path $repoRoot "wezterm"

Set-ConfigLink `
    -Path (Join-Path $weztermConfig "wezterm.lua") `
    -Target (Join-Path $weztermSource "wezterm.lua")

Get-ChildItem -LiteralPath (Join-Path $weztermSource "modules") -Filter "*.lua" -File | ForEach-Object {
    Set-ConfigLink `
        -Path (Join-Path $weztermConfig "modules\$($_.Name)") `
        -Target $_.FullName
}

Set-ConfigTree `
    -Source (Join-Path $weztermSource "assets") `
    -Destination (Join-Path $weztermConfig "assets")

Set-ConfigLink `
    -Path (Join-Path $env:APPDATA "neovide\config.toml") `
    -Target (Join-Path $repoRoot "neovide\config.toml")

$nushellConfig = Join-Path $HOME ".config\nushell"
$nushellSource = Join-Path $repoRoot "nushell"

Set-ConfigLink `
    -Path (Join-Path $nushellConfig "config.nu") `
    -Target (Join-Path $nushellSource "config.nu")

Set-ConfigLink `
    -Path (Join-Path $nushellConfig "fastfetch.jsonc") `
    -Target (Join-Path $nushellSource "fastfetch.jsonc")

Get-ChildItem -LiteralPath (Join-Path $nushellSource "modules") -Filter "*.nu" -File | ForEach-Object {
    Set-ConfigLink `
        -Path (Join-Path $nushellConfig "modules\$($_.Name)") `
        -Target $_.FullName
}

Set-ConfigLink `
    -Path (Join-Path $HOME ".config\starship.toml") `
    -Target (Join-Path $repoRoot "nushell\starship.toml")

Set-ConfigLink `
    -Path (Join-Path $env:APPDATA "nushell\config.nu") `
    -Target (Join-Path $repoRoot "nushell\config.nu")

$powershellDirectory = Join-Path `
    ([Environment]::GetFolderPath("MyDocuments")) `
    "PowerShell"

Set-ConfigLink `
    -Path (Join-Path $powershellDirectory "profile.ps1") `
    -Target (Join-Path $repoRoot "powershell\profile.ps1")

Set-ConfigLink `
    -Path (Join-Path $powershellDirectory "Microsoft.PowerShell_profile.ps1") `
    -Target (Join-Path $repoRoot "powershell\Microsoft.PowerShell_profile.ps1")

Set-ConfigTree `
    -Source (Join-Path $repoRoot "nvim") `
    -Destination (Join-Path $env:LOCALAPPDATA "nvim")

Remove-StaleTreeLinks `
    -Source (Join-Path $repoRoot "nvim") `
    -Destination (Join-Path $env:LOCALAPPDATA "nvim")

$gitFile = Join-Path $env:ProgramFiles "Git\usr\bin\file.exe"
if (Test-Path -LiteralPath $gitFile) {
    $env:YAZI_FILE_ONE = $gitFile
    [Environment]::SetEnvironmentVariable("YAZI_FILE_ONE", $gitFile, "User")
    Write-Host "Configured YAZI_FILE_ONE: $gitFile"
} else {
    Write-Warning "Git for Windows file.exe was not found at: $gitFile"
}

Set-ConfigTree `
    -Source (Join-Path $repoRoot "yazi") `
    -Destination (Join-Path $env:APPDATA "yazi\config")

$flowLauncherSource = Join-Path $repoRoot "flow-launcher"
$flowLauncherData = Join-Path $env:APPDATA "FlowLauncher"

Set-ConfigLink `
    -Path (Join-Path $flowLauncherData "Settings\Settings.json") `
    -Target (Join-Path $flowLauncherSource "Settings.json")

Set-ConfigLink `
    -Path (Join-Path $flowLauncherData "Themes\Tokyo Mocha.xaml") `
    -Target (Join-Path $flowLauncherSource "themes\Tokyo Mocha.xaml")

Set-ConfigLink `
    -Path (Join-Path $flowLauncherData "Settings\Plugins\Flow.Launcher.Plugin.Explorer\Settings.json") `
    -Target (Join-Path $flowLauncherSource "plugins\explorer\Settings.json")

Set-ConfigLink `
    -Path (Join-Path $flowLauncherData "Settings\Plugins\Flow.Launcher.Plugin.WebSearch\Settings.json") `
    -Target (Join-Path $flowLauncherSource "plugins\web-search\Settings.json")

Set-ConfigLink `
    -Path (Join-Path $HOME ".config\opencode\opencode.jsonc") `
    -Target (Join-Path $repoRoot "opencode\opencode.jsonc")

Set-ConfigLink `
    -Path (Join-Path $HOME ".config\opencode\tui.json") `
    -Target (Join-Path $repoRoot "opencode\tui.json")

Set-ConfigTree `
    -Source (Join-Path $repoRoot "opencode\plugins") `
    -Destination (Join-Path $HOME ".config\opencode\plugins")

Set-ConfigLink `
    -Path (Join-Path $HOME ".glzr\glazewm\config.yaml") `
    -Target (Join-Path $repoRoot "glzr\glazewm\config.yaml")

Set-ConfigLink `
    -Path (Join-Path $HOME ".glzr\zebar\settings.json") `
    -Target (Join-Path $repoRoot "glzr\zebar\settings.json")

Set-ConfigLink `
    -Path (Join-Path $HOME ".config\tacky-borders\config.yaml") `
    -Target (Join-Path $repoRoot "tacky-borders\config.yaml")

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

$autoHotkeyConfigDirectory = Join-Path $HOME ".config\autohotkey"
Set-ConfigTree `
    -Source (Join-Path $repoRoot "autohotkey") `
    -Destination $autoHotkeyConfigDirectory

$startupScript = Join-Path $repoRoot "startup\windows-startup.ps1"
$startupPowerShell = (Get-Command "powershell.exe" -ErrorAction Stop).Source
$startupCommand = "`"$startupPowerShell`" -NoProfile -WindowStyle Hidden -ExecutionPolicy RemoteSigned -File `"$startupScript`""
Set-ItemProperty `
    -LiteralPath $runKey `
    -Name "Windows Dotfiles" `
    -Value $startupCommand
Write-Host "Configured ordered startup: Windows Dotfiles -> $startupScript"

$codexDreamSkinLauncher = Join-Path $repoRoot "codex-dream-skin\start-codex-themed.ps1"
$codexDreamSkinShortcut = Join-Path `
    ([Environment]::GetFolderPath("Programs")) `
    "Codex (Dream Skin).lnk"
$shortcutShell = New-Object -ComObject WScript.Shell
$shortcut = $shortcutShell.CreateShortcut($codexDreamSkinShortcut)
$shortcut.TargetPath = $startupPowerShell
$shortcut.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy RemoteSigned -File `"$codexDreamSkinLauncher`""
$shortcut.WorkingDirectory = $repoRoot
$dreamSkinIcon = Join-Path $env:LOCALAPPDATA "CodexDreamSkin\engine\assets\codex-dream-skin.ico"
if (Test-Path -LiteralPath $dreamSkinIcon -PathType Leaf) {
    $shortcut.IconLocation = $dreamSkinIcon
}
$shortcut.Description = "Start Codex and apply the active Dream Skin theme"
$shortcut.Save()
Write-Host "Configured on-demand launcher: $codexDreamSkinShortcut"

foreach ($legacyStartupName in @(
    "AutoHotkey Hotkeys",
    "GlazeWM",
    "YASB",
    "Flow.Launcher",
    "Tacky Borders",
    "tacky-borders"
)) {
    if ($null -ne (Get-ItemPropertyValue -LiteralPath $runKey -Name $legacyStartupName -ErrorAction SilentlyContinue)) {
        Remove-ItemProperty -LiteralPath $runKey -Name $legacyStartupName
        Write-Host "Removed superseded startup entry: $legacyStartupName"
    }
}

$everythingPath = Join-Path $env:ProgramFiles "Everything\Everything.exe"
if (Test-Path -LiteralPath $everythingPath) {
    Set-ItemProperty `
        -LiteralPath $runKey `
        -Name "Everything" `
        -Value "`"$everythingPath`" -startup"
    Write-Host "Configured background startup: Everything -> $everythingPath"
}

$yasbConfig = Join-Path $HOME ".config\yasb"
$yasbSource = Join-Path $repoRoot "yasb"

Set-ConfigTree `
    -Source $yasbSource `
    -Destination $yasbConfig

Move-LegacyGitMetadata -ConfigPath $weztermConfig
Move-LegacyGitMetadata -ConfigPath $nushellConfig
Move-LegacyGitMetadata -ConfigPath $yasbConfig

if (Get-Command "ya" -ErrorAction SilentlyContinue) {
    & ya pkg install
}

if (-not $SkipNilesoft) {
    $nilesoftTarget = Join-Path $env:ProgramFiles "Nilesoft Shell"
    $nilesoftSource = Join-Path $repoRoot "nilesoft-shell"

    if (-not (Test-Path -LiteralPath $nilesoftTarget)) {
        Write-Warning "Nilesoft Shell is not installed at: $nilesoftTarget"
    } else {
        Set-ConfigLink `
            -Path (Join-Path $nilesoftTarget "shell.nss") `
            -Target (Join-Path $nilesoftSource "shell.nss")

        Get-ChildItem -LiteralPath (Join-Path $nilesoftSource "imports") -File | ForEach-Object {
            Set-ConfigLink `
                -Path (Join-Path $nilesoftTarget "imports\$($_.Name)") `
                -Target $_.FullName
        }

        & (Join-Path $nilesoftTarget "shell.exe") -restart -silent
        Write-Host "Linked and reloaded Nilesoft Shell configuration."
    }
}
