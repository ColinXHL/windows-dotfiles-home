# YASB configuration

## Weather widget

The custom weather widget uses Amap for the existing Xiamen Jimei location and
reads `AMAP_WEATHER_API_KEY` from the current-user environment. It uses
`127.0.0.1:7890` when FlClash is listening, falls back to the keyless Open-Meteo
API when Amap is unavailable, and finally falls back to a complete cached
response if both services are temporarily unavailable.

## Package update widget

The update widget requires PowerShell 7 (`pwsh.exe`), Windows Package Manager
(`winget.exe`), and Scoop. It refreshes Scoop buckets and reports the combined
WinGet and Scoop upgrade count. Both package managers receive proxy settings
only in the update script process; Scoop's Git subprocess also receives an
equivalent process-scoped Git configuration.
Nothing is written to user/system proxy variables or global Git configuration.
When `127.0.0.1:7890` is not listening, the widget shows a clear warning instead
of silently connecting directly. Left-click upgrades both package managers;
right-click refreshes the list immediately.
