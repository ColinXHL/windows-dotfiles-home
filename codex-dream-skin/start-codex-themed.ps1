[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$startScript = Join-Path $env:LOCALAPPDATA "CodexDreamSkin\engine\scripts\start-dream-skin.ps1"
if (-not (Test-Path -LiteralPath $startScript -PathType Leaf)) {
    throw "Codex Dream Skin is not installed: $startScript"
}

& $startScript `
    -Port 9335 `
    -PromptRestart `
    -OperationLockTimeoutMilliseconds 60000
