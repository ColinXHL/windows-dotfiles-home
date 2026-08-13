[CmdletBinding(SupportsShouldProcess)]
param(
    [switch] $SkipDreamSkin
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$stateRoot = Join-Path $env:LOCALAPPDATA "windows-dotfiles"
$logPath = Join-Path $stateRoot "startup.log"

if (-not (Test-Path -LiteralPath $stateRoot)) {
    New-Item -ItemType Directory -Path $stateRoot -Force | Out-Null
}

if ((Test-Path -LiteralPath $logPath) -and (Get-Item -LiteralPath $logPath).Length -gt 1MB) {
    Move-Item -LiteralPath $logPath -Destination "$logPath.previous" -Force
}

function Write-StartupLog {
    param([Parameter(Mandatory)][string] $Message)

    $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"), $Message
    Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
    Write-Verbose $line
}

function Test-ProcessRunning {
    param([Parameter(Mandatory)][string[]] $ProcessName)

    foreach ($name in $ProcessName) {
        if (Get-Process -Name $name -ErrorAction SilentlyContinue) {
            return $true
        }
    }

    return $false
}

function Test-CommandLineProcess {
    param(
        [Parameter(Mandatory)][string] $ExecutableName,
        [Parameter(Mandatory)][string] $ArgumentFragment
    )

    return $null -ne (Get-CimInstance Win32_Process -Filter "Name = '$ExecutableName'" |
        Where-Object { $_.CommandLine -like "*$ArgumentFragment*" } |
        Select-Object -First 1)
}

function Start-ManagedApplication {
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string[]] $ProcessName,
        [string] $Arguments = ""
    )

    try {
        if (Test-ProcessRunning -ProcessName $ProcessName) {
            Write-StartupLog "$Name is already running."
            return
        }

        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
            Write-StartupLog "$Name was skipped because its executable is missing: $Path"
            return
        }

        if ($PSCmdlet.ShouldProcess($Path, "Start $Name")) {
            $parameters = @{ FilePath = $Path }
            if ($Arguments) {
                $parameters.ArgumentList = $Arguments
            }
            Start-Process @parameters | Out-Null
            Write-StartupLog "Started $Name."
        } else {
            Write-StartupLog "Would start $Name."
        }
    } catch {
        Write-StartupLog "$Name failed to start: $($_.Exception.Message)"
    }
}

function Start-AutoHotkeyConfig {
    $configPath = Join-Path $HOME ".config\autohotkey\hotkeys.ahk"
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey64.exe"),
        (Join-Path $env:ProgramFiles "AutoHotkey\v2\AutoHotkey64.exe")
    )
    $executable = $candidates |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
        Select-Object -First 1

    try {
        if (Test-CommandLineProcess -ExecutableName "AutoHotkey64.exe" -ArgumentFragment $configPath) {
            Write-StartupLog "AutoHotkey Hotkeys is already running."
            return
        }
        if (-not $executable) {
            Write-StartupLog "AutoHotkey Hotkeys was skipped because AutoHotkey v2 is missing."
            return
        }
        if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
            Write-StartupLog "AutoHotkey Hotkeys was skipped because its config is missing: $configPath"
            return
        }

        if ($PSCmdlet.ShouldProcess($executable, "Start AutoHotkey Hotkeys")) {
            Start-Process -FilePath $executable -ArgumentList ('"{0}"' -f $configPath) | Out-Null
            Write-StartupLog "Started AutoHotkey Hotkeys."
        } else {
            Write-StartupLog "Would start AutoHotkey Hotkeys."
        }
    } catch {
        Write-StartupLog "AutoHotkey Hotkeys failed to start: $($_.Exception.Message)"
    }
}

function Start-CodexDreamSkinTray {
    $dreamSkinRoot = Join-Path $env:LOCALAPPDATA "CodexDreamSkin"
    $scriptRoot = Join-Path $dreamSkinRoot "engine\scripts"
    $trayScript = Join-Path $scriptRoot "tray-dream-skin.ps1"
    $powershell = (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source

    try {
        if (-not $powershell -or -not (Test-Path -LiteralPath $trayScript -PathType Leaf)) {
            Write-StartupLog "Codex Dream Skin was skipped because its installed engine is missing."
            return
        }

        $trayRunning = Test-CommandLineProcess `
            -ExecutableName "powershell.exe" `
            -ArgumentFragment "tray-dream-skin.ps1"
        if (-not $trayRunning -and (Test-Path -LiteralPath $trayScript -PathType Leaf)) {
            if ($PSCmdlet.ShouldProcess($trayScript, "Start Codex Dream Skin tray")) {
                $trayArguments = '-NoProfile -STA -WindowStyle Hidden -ExecutionPolicy RemoteSigned -File "{0}"' -f $trayScript
                Start-Process -FilePath $powershell -ArgumentList $trayArguments -WindowStyle Hidden | Out-Null
                Write-StartupLog "Started Codex Dream Skin tray."
            } else {
                Write-StartupLog "Would start Codex Dream Skin tray."
            }
        } else {
            Write-StartupLog "Codex Dream Skin tray is already running."
        }
    } catch {
        Write-StartupLog "Codex Dream Skin failed to start: $($_.Exception.Message)"
    }
}

Write-StartupLog "Windows dotfiles startup began."

Start-ManagedApplication `
    -Name "GlazeWM" `
    -Path (Join-Path $env:ProgramFiles "glzr.io\GlazeWM\glazewm.exe") `
    -ProcessName @("glazewm")

# Give GlazeWM time to create its IPC endpoint before YASB connects to it.
if (-not $WhatIfPreference) {
    Start-Sleep -Seconds 3
}

Start-ManagedApplication `
    -Name "YASB" `
    -Path (Join-Path $env:ProgramFiles "YASB\yasb.exe") `
    -ProcessName @("yasb")

Start-ManagedApplication `
    -Name "Tacky Borders" `
    -Path (Join-Path $env:LOCALAPPDATA "Programs\tacky-borders\tacky-borders.exe") `
    -ProcessName @("tacky-borders")

Start-ManagedApplication `
    -Name "Flow Launcher" `
    -Path (Join-Path $env:LOCALAPPDATA "FlowLauncher\Flow.Launcher.exe") `
    -ProcessName @("Flow.Launcher")

Start-AutoHotkeyConfig

if (-not $SkipDreamSkin) {
    Start-CodexDreamSkinTray
}

Write-StartupLog "Windows dotfiles startup dispatch completed."
