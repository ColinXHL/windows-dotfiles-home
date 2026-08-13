function Enable-LocalProxy {
    $env:http_proxy = "http://127.0.0.1:7890"
    $env:https_proxy = "http://127.0.0.1:7890"
}

function Disable-LocalProxy {
    Remove-Item Env:http_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:https_proxy -ErrorAction SilentlyContinue
}

$zoxidePath = (Get-Command zoxide -CommandType Application -ErrorAction SilentlyContinue).Source
if ($zoxidePath -and (Test-Path -LiteralPath $zoxidePath)) {
    $zoxideInit = & $zoxidePath init powershell | Out-String
    if (-not [string]::IsNullOrWhiteSpace($zoxideInit)) {
        Invoke-Expression $zoxideInit
    }
}

$starshipPath = (Get-Command starship -CommandType Application -ErrorAction SilentlyContinue).Source
if (-not $starshipPath) {
    $starshipRoot = Join-Path $env:USERPROFILE "scoop\apps\starship"
    $starshipPath = Get-ChildItem -LiteralPath $starshipRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "current" } |
        Sort-Object LastWriteTimeUtc -Descending |
        ForEach-Object { Join-Path $_.FullName "starship.exe" } |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1
}

if ($starshipPath -and (Test-Path -LiteralPath $starshipPath)) {
    $starshipDirectory = Split-Path -Parent $starshipPath
    $processPathEntries = $env:PATH -split ";"
    if ($starshipDirectory -notin $processPathEntries) {
        $env:PATH = "$starshipDirectory;$env:PATH"
    }

    $env:STARSHIP_CONFIG = Join-Path $env:USERPROFILE ".config\starship.toml"
    $starshipInit = & $starshipPath init powershell | Out-String
    if (-not [string]::IsNullOrWhiteSpace($starshipInit)) {
        Invoke-Expression $starshipInit
    }
}

function y {
    $tmp = New-TemporaryFile

    yazi $args --cwd-file="$tmp"

    if (Get-Content $tmp) {
        Set-Location (Get-Content $tmp)
    }

    Remove-Item $tmp
}

$env:VISUAL="nvim"
$env:EDITOR="nvim"
