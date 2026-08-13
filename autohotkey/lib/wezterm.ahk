OpenWezTerm() {
    weztermPath := ResolveWezTerm()
    if !weztermPath {
        TrayTip "WezTerm executable was not found.", "AutoHotkey"
        return
    }

    command := Format('explorer.exe "{1}"', weztermPath)
    Run command, EnvGet("USERPROFILE")
}

ResolveWezTerm() {
    candidates := [
        "C:\Program Files\WezTerm\wezterm-gui.exe",
        EnvGet("LOCALAPPDATA") "\Programs\WezTerm\wezterm-gui.exe"
    ]

    for candidate in candidates {
        if FileExist(candidate) {
            return candidate
        }
    }

    try {
        registeredPath := RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\wezterm-gui.exe")
        if FileExist(registeredPath) {
            return registeredPath
        }
    }

    return ""
}
