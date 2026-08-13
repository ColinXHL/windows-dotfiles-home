$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()

# Keep the existing Amap location (adcode 350211 / Xiamen Jimei).
$locationName = "厦门市集美区"
$city = "350211"
$apiKey = [Environment]::GetEnvironmentVariable("AMAP_WEATHER_API_KEY", "User")
$latitude = "24.575"
$longitude = "118.097"
$proxyUri = "http://127.0.0.1:7890"
$cachePath = Join-Path $env:LOCALAPPDATA "YASB\weather_cache.json"
$utf8 = [Text.UTF8Encoding]::new($false)

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

function Invoke-WeatherRequest {
    $url = "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,wind_direction_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=Asia%2FShanghai&forecast_days=4"
    $arguments = @("--silent", "--show-error", "--fail", "--max-time", "15")
    if (Test-LocalProxy) {
        $arguments += @("--proxy", $proxyUri)
    }
    $arguments += $url

    $output = & curl.exe @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Open-Meteo request failed."
    }
    return ($output -join "") | ConvertFrom-Json
}

function Invoke-AmapWeather([string]$extension) {
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        throw "AMAP_WEATHER_API_KEY is not configured."
    }

    $escapedKey = [Uri]::EscapeDataString($apiKey)
    $url = "https://restapi.amap.com/v3/weather/weatherInfo?city=$city&key=$escapedKey&extensions=$extension&output=JSON"
    $arguments = @("--silent", "--show-error", "--fail", "--max-time", "15")
    if (Test-LocalProxy) {
        $arguments += @("--proxy", $proxyUri)
    }
    $arguments += $url

    $output = & curl.exe @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Amap weather request failed."
    }
    $response = ($output -join "") | ConvertFrom-Json
    if ($response.status -ne "1") {
        throw "Amap weather API error: $($response.info)"
    }
    return $response
}

function Get-WeatherInfo([int]$code) {
    if ($code -eq 0) {
        return [pscustomobject]@{ Text = "晴"; Icon = [char]::ConvertFromUtf32(0xF0599); Color = "#F9E2AF" }
    }
    if ($code -in @(1, 2)) {
        return [pscustomobject]@{ Text = "多云"; Icon = [char]::ConvertFromUtf32(0xF0590); Color = "#A6ADC8" }
    }
    if ($code -eq 3) {
        return [pscustomobject]@{ Text = "阴"; Icon = [char]::ConvertFromUtf32(0xF0590); Color = "#9399B2" }
    }
    if ($code -in @(45, 48)) {
        return [pscustomobject]@{ Text = "雾"; Icon = [char]::ConvertFromUtf32(0xF0591); Color = "#9399B2" }
    }
    if ($code -in @(51, 53, 55, 56, 57)) {
        return [pscustomobject]@{ Text = "毛毛雨"; Icon = [char]::ConvertFromUtf32(0xF0597); Color = "#89B4FA" }
    }
    if ($code -in @(61, 63, 65, 66, 67, 80, 81, 82)) {
        $text = if ($code -in @(65, 82)) { "大雨" } elseif ($code -in @(63, 81)) { "中雨" } else { "小雨" }
        return [pscustomobject]@{ Text = $text; Icon = [char]::ConvertFromUtf32(0xF0597); Color = "#89B4FA" }
    }
    if ($code -in @(71, 73, 75, 77, 85, 86)) {
        return [pscustomobject]@{ Text = "雪"; Icon = [char]::ConvertFromUtf32(0xF0598); Color = "#CDD6F4" }
    }
    if ($code -in @(95, 96, 99)) {
        return [pscustomobject]@{ Text = "雷雨"; Icon = [char]::ConvertFromUtf32(0xF067E); Color = "#F38BA8" }
    }
    return [pscustomobject]@{ Text = "未知"; Icon = [char]::ConvertFromUtf32(0xF0595); Color = "#CBA6F7" }
}

function Get-AmapWeatherInfo([string]$weather) {
    if ($weather.Contains([string][char]0x96F7)) {
        return [pscustomobject]@{ Text = $weather; Icon = [char]::ConvertFromUtf32(0xF067E); Color = "#F38BA8" }
    }
    if ($weather.Contains([string][char]0x96E8)) {
        return [pscustomobject]@{ Text = $weather; Icon = [char]::ConvertFromUtf32(0xF0597); Color = "#89B4FA" }
    }
    if ($weather.Contains([string][char]0x96EA)) {
        return [pscustomobject]@{ Text = $weather; Icon = [char]::ConvertFromUtf32(0xF0598); Color = "#CDD6F4" }
    }
    if ($weather.Contains([string][char]0x96FE) -or $weather.Contains([string][char]0x973E)) {
        return [pscustomobject]@{ Text = $weather; Icon = [char]::ConvertFromUtf32(0xF0591); Color = "#9399B2" }
    }
    if ($weather.Contains([string][char]0x4E91) -or $weather.Contains([string][char]0x9634)) {
        return [pscustomobject]@{ Text = $weather; Icon = [char]::ConvertFromUtf32(0xF0590); Color = "#A6ADC8" }
    }
    if ($weather.Contains([string][char]0x6674)) {
        return [pscustomobject]@{ Text = $weather; Icon = [char]::ConvertFromUtf32(0xF0599); Color = "#F9E2AF" }
    }
    return [pscustomobject]@{ Text = $weather; Icon = [char]::ConvertFromUtf32(0xF0595); Color = "#CBA6F7" }
}

function Get-WindDirection([double]$degrees) {
    $directions = @("北", "东北", "东", "东南", "南", "西南", "西", "西北")
    return $directions[([int][Math]::Round($degrees / 45)) % 8]
}

function New-FallbackData {
    return [ordered]@{
        bar = "<span style=`"font-size:12px;color:#F38BA8`">天气不可用</span>"
        icon = ""
        color = "#F38BA8"
        city = $locationName
        weather = "不可用"
        temp = "--"
        humidity = "--"
        wind = "--"
        report = "网络或天气服务不可用"
        day0Date = "--"; day1Date = "--"; day2Date = "--"; day3Date = "--"
        day0Icon = ""; day1Icon = ""; day2Icon = ""; day3Icon = ""
        day0Color = "#9399B2"; day1Color = "#9399B2"; day2Color = "#9399B2"; day3Color = "#9399B2"
        day0Weather = "--"; day1Weather = "--"; day2Weather = "--"; day3Weather = "--"
        day0High = "--"; day1High = "--"; day2High = "--"; day3High = "--"
        day0Low = "--"; day1Low = "--"; day2Low = "--"; day3Low = "--"
    }
}

function New-OpenMeteoData {
    $response = Invoke-WeatherRequest
    $currentInfo = Get-WeatherInfo ([int]$response.current.weather_code)
    $degree = [char]0x00B0
    $data = [ordered]@{
        bar = "<span style=`"font-family:'JetBrainsMono NFP';font-size:16px;vertical-align:middle;color:$($currentInfo.Color)`">$($currentInfo.Icon)</span> <span style=`"font-size:12px;vertical-align:middle`">$($currentInfo.Text) $([Math]::Round([double]$response.current.temperature_2m))$degree" + "C</span>"
        icon = $currentInfo.Icon
        color = $currentInfo.Color
        city = $locationName
        weather = $currentInfo.Text
        temp = [Math]::Round([double]$response.current.temperature_2m)
        humidity = [Math]::Round([double]$response.current.relative_humidity_2m)
        wind = "$(Get-WindDirection ([double]$response.current.wind_direction_10m)) $([Math]::Round([double]$response.current.wind_speed_10m)) km/h"
        report = ([string]$response.current.time).Replace("T", " ")
    }

    for ($i = 0; $i -lt 4; $i++) {
        $forecastInfo = Get-WeatherInfo ([int]$response.daily.weather_code[$i])
        $data["day${i}Date"] = ([string]$response.daily.time[$i]).Substring(5).Replace("-", "/")
        $data["day${i}Icon"] = $forecastInfo.Icon
        $data["day${i}Color"] = $forecastInfo.Color
        $data["day${i}Weather"] = $forecastInfo.Text
        $data["day${i}High"] = [Math]::Round([double]$response.daily.temperature_2m_max[$i])
        $data["day${i}Low"] = [Math]::Round([double]$response.daily.temperature_2m_min[$i])
    }

    return $data
}

function New-AmapData {
    $current = Invoke-AmapWeather "base"
    $forecast = Invoke-AmapWeather "all"
    $live = $current.lives[0]
    $days = $forecast.forecasts[0].casts
    if ($null -eq $live -or $days.Count -lt 4) {
        throw "Amap returned incomplete weather data."
    }

    $currentInfo = Get-AmapWeatherInfo ([string]$live.weather)
    $degree = [char]0x00B0
    $data = [ordered]@{
        bar = "<span style=`"font-family:'JetBrainsMono NFP';font-size:16px;vertical-align:middle;color:$($currentInfo.Color)`">$($currentInfo.Icon)</span> <span style=`"font-size:12px;vertical-align:middle`">$($currentInfo.Text) $($live.temperature)$degree" + "C</span>"
        icon = $currentInfo.Icon
        color = $currentInfo.Color
        city = $live.city
        weather = $live.weather
        temp = $live.temperature
        humidity = $live.humidity
        wind = "$($live.winddirection) $($live.windpower)级"
        report = $live.reporttime
    }

    for ($i = 0; $i -lt 4; $i++) {
        $forecastInfo = Get-AmapWeatherInfo ([string]$days[$i].dayweather)
        $data["day${i}Date"] = ([string]$days[$i].date).Substring(5).Replace("-", "/")
        $data["day${i}Icon"] = $forecastInfo.Icon
        $data["day${i}Color"] = $forecastInfo.Color
        $data["day${i}Weather"] = $forecastInfo.Text
        $data["day${i}High"] = $days[$i].daytemp
        $data["day${i}Low"] = $days[$i].nighttemp
    }
    return $data
}

try {
    try {
        $data = New-AmapData
    }
    catch {
        $data = New-OpenMeteoData
    }

    $json = $data | ConvertTo-Json -Compress
    $cacheDirectory = Split-Path -Parent $cachePath
    if (-not (Test-Path -LiteralPath $cacheDirectory)) {
        New-Item -ItemType Directory -Path $cacheDirectory -Force | Out-Null
    }
    [IO.File]::WriteAllText($cachePath, $json, $utf8)
    $json
}
catch {
    if (Test-Path -LiteralPath $cachePath) {
        [IO.File]::ReadAllText($cachePath, $utf8)
    }
    else {
        (New-FallbackData) | ConvertTo-Json -Compress
    }
}
