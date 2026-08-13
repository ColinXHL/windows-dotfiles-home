#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$themeRoot = Join-Path $PSScriptRoot "themes\clear-teal-glass"
$outputDirectory = Join-Path $PSScriptRoot "dist"
$outputPath = Join-Path $outputDirectory "astral-teal.zip"
$requiredFiles = @("theme.json", "theme.css", "background.png")

foreach ($name in $requiredFiles) {
    $path = Join-Path $themeRoot $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing Dream Skin theme file: $path"
    }
}

$null = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $themeRoot "theme.json") |
    ConvertFrom-Json

if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

if (Test-Path -LiteralPath $outputPath) {
    Remove-Item -LiteralPath $outputPath -Force
}

Compress-Archive `
    -LiteralPath ($requiredFiles | ForEach-Object { Join-Path $themeRoot $_ }) `
    -DestinationPath $outputPath `
    -CompressionLevel Optimal

$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $outputPath).Hash
Write-Host "Built: $outputPath"
Write-Host "SHA256: $hash"
