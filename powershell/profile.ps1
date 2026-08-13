# Keep fnm's writable state outside Scoop's version directory. Prefer the
# existing per-user store so installed Node versions remain available.
$userFnmStore = Join-Path $env:APPDATA "fnm"
$scoopFnmStore = Join-Path $env:USERPROFILE "scoop\persist\fnm"
if (Test-Path -LiteralPath (Join-Path $userFnmStore "node-versions")) {
    $env:FNM_DIR = $userFnmStore
} elseif (Test-Path -LiteralPath $scoopFnmStore) {
    $env:FNM_DIR = $scoopFnmStore
} else {
    $userFnmDir = [Environment]::GetEnvironmentVariable("FNM_DIR", "User")
    if ($userFnmDir -and (Test-Path -LiteralPath $userFnmDir)) {
        $env:FNM_DIR = $userFnmDir
    }
}

$fnmExecutable = (Get-Command fnm -CommandType Application -ErrorAction SilentlyContinue).Source
if ($fnmExecutable -and (Test-Path -LiteralPath $fnmExecutable)) {
    $fnmInit = & $fnmExecutable env --use-on-cd --corepack-enabled --shell powershell |
        Out-String

    if (-not [string]::IsNullOrWhiteSpace($fnmInit)) {
        Invoke-Expression $fnmInit
    }

    # Protected app terminals can reject fnm's per-shell junction. In that
    # case, expose the same default installation through its real directory.
    if (-not (Get-Command node -CommandType Application -ErrorAction SilentlyContinue)) {
        $defaultAlias = Join-Path $env:FNM_DIR "aliases\default"
        $defaultAliasItem = Get-Item -LiteralPath $defaultAlias -Force -ErrorAction SilentlyContinue
        $defaultNodeDirectory = @($defaultAliasItem.Target) | Select-Object -First 1
        if ($defaultNodeDirectory -and (Test-Path -LiteralPath (Join-Path $defaultNodeDirectory "node.exe"))) {
            $env:PATH = "$defaultNodeDirectory;$env:PATH"
        }
    }
}
