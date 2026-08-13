$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "WinGet + Scoop Upgrade"

$proxyUri = "http://127.0.0.1:7890"

function Test-LocalProxy {
    $client = [Net.Sockets.TcpClient]::new()
    try {
        $task = $client.ConnectAsync("127.0.0.1", 7890)
        return $task.Wait(500) -and $client.Connected
    }
    catch {
        return $false
    }
    finally {
        $client.Dispose()
    }
}

function Invoke-WithLocalProxy([scriptblock]$Action) {
    $values = [ordered]@{
        HTTP_PROXY = $proxyUri
        HTTPS_PROXY = $proxyUri
        GIT_CONFIG_COUNT = "1"
        GIT_CONFIG_KEY_0 = "http.proxy"
        GIT_CONFIG_VALUE_0 = $proxyUri
    }
    $saved = @{}
    foreach ($name in $values.Keys) {
        $saved[$name] = [Environment]::GetEnvironmentVariable($name, "Process")
        [Environment]::SetEnvironmentVariable($name, $values[$name], "Process")
    }
    try {
        & $Action
    }
    finally {
        foreach ($name in $values.Keys) {
            [Environment]::SetEnvironmentVariable($name, $saved[$name], "Process")
        }
    }
}

if (-not (Test-LocalProxy)) {
    Write-Error "FlClash 代理 127.0.0.1:7890 未监听。请先启动 FlClash，再执行更新。"
    exit 1
}

Write-Host "Updating WinGet packages through $proxyUri ..." -ForegroundColor Cyan
$wingetExit = 0
Invoke-WithLocalProxy {
    & winget.exe upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements --disable-interactivity
    $script:wingetExit = $LASTEXITCODE
}

Write-Host ""
Write-Host "Refreshing Scoop and updating Scoop packages through the temporary process proxy ..." -ForegroundColor Cyan
Invoke-WithLocalProxy {
    & scoop update
    if ($LASTEXITCODE -ne 0) { throw "Scoop/bucket refresh failed." }
    & scoop update --all
    if ($LASTEXITCODE -ne 0) { throw "Scoop package upgrade failed." }
}

Write-Host ""
if ($wingetExit -eq 0) {
    Write-Host "WinGet and Scoop upgrades finished. Right-click the YASB update icon to refresh." -ForegroundColor Green
}
else {
    Write-Warning "Scoop finished, but WinGet returned exit code $wingetExit."
    exit $wingetExit
}
