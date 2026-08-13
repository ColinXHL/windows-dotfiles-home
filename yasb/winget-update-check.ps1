$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()

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
    [ordered]@{
        count = "!"
        details = "FlClash 代理 127.0.0.1:7890 未监听。`n请先启动 FlClash，再检查或安装更新。"
    } | ConvertTo-Json -Compress
    exit 0
}

$wingetOutput = @(Invoke-WithLocalProxy {
    & winget.exe upgrade --include-unknown --accept-source-agreements --disable-interactivity 2>&1
})
$wingetUpdates = [Collections.Generic.List[object]]::new()
$separatorIndex = -1
for ($i = 0; $i -lt $wingetOutput.Count; $i++) {
    if ([string]$wingetOutput[$i] -match "^-{3,}") {
        $separatorIndex = $i
        break
    }
}
if ($separatorIndex -ge 0) {
    for ($i = $separatorIndex + 1; $i -lt $wingetOutput.Count; $i++) {
        $line = ([string]$wingetOutput[$i]).Trim()
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($wingetUpdates.Count -gt 0) { break }
            continue
        }
        if ($line -match "^(?<name>.+)\s+(?<id>\S+)\s+(?<current>\S+)\s+(?<available>\S+)\s+(?<source>\S+)$") {
            $wingetUpdates.Add([pscustomobject]@{
                Name = $Matches.name.Trim()
                CurrentVersion = $Matches.current
                AvailableVersion = $Matches.available
            })
        }
    }
}

$scoopOutput = @(Invoke-WithLocalProxy {
    & scoop update *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Scoop/bucket refresh failed."
    }
    & scoop status --local *>&1
})
$scoopUpdates = [Collections.Generic.List[object]]::new()
$scoopSeparator = -1
for ($i = 0; $i -lt $scoopOutput.Count; $i++) {
    if ([string]$scoopOutput[$i] -match "^-{3,}") {
        $scoopSeparator = $i
        break
    }
}
if ($scoopSeparator -ge 0) {
    for ($i = $scoopSeparator + 1; $i -lt $scoopOutput.Count; $i++) {
        $line = ([string]$scoopOutput[$i]).Trim()
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match "^(?<name>\S+)\s+(?<current>\S+)\s+(?<available>\S+)") {
            $scoopUpdates.Add([pscustomobject]@{
                Name = $Matches.name
                CurrentVersion = $Matches.current
                AvailableVersion = $Matches.available
            })
        }
    }
}

$total = $wingetUpdates.Count + $scoopUpdates.Count
if ($total -eq 0) {
    exit 0
}

$details = @("可用更新：WinGet $($wingetUpdates.Count)，Scoop $($scoopUpdates.Count)")
if ($wingetUpdates.Count -gt 0) {
    $details += ""
    $details += "WinGet:"
    $details += $wingetUpdates | ForEach-Object { "- $($_.Name)  $($_.CurrentVersion) -> $($_.AvailableVersion)" }
}
if ($scoopUpdates.Count -gt 0) {
    $details += ""
    $details += "Scoop:"
    $details += $scoopUpdates | ForEach-Object { "- $($_.Name)  $($_.CurrentVersion) -> $($_.AvailableVersion)" }
}
$details += ""
$details += "检查时间：$(Get-Date -Format 'HH:mm:ss')（已使用 127.0.0.1:7890）"

[ordered]@{
    count = $total
    details = $details -join "`n"
} | ConvertTo-Json -Compress
