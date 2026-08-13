$ErrorActionPreference = "Stop"

$source = Join-Path $PSScriptRoot "csharp-injections.scm"
$target = Join-Path $env:LOCALAPPDATA "Zed\extensions\installed\csharp\languages\csharp\injections.scm"

if (-not (Test-Path -LiteralPath $target)) {
    Write-Host "Zed C# extension is not installed; skipping XML doc-comment highlighting patch."
    return
}

Copy-Item -LiteralPath $source -Destination $target -Force
Write-Host "Patched Zed C# XML documentation-comment highlighting."
