# Core shell behavior

$env.config.show_banner = false

if ($env.SHLVL? | default 1) == 1 {
    ^fastfetch --config ~/.config/nushell/fastfetch.jsonc
}

$env.config.buffer_editor = "nvim"
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

let yazi_file = 'C:\Program Files\Git\usr\bin\file.exe'
if ($yazi_file | path exists) {
    $env.YAZI_FILE_ONE = $yazi_file
}

$env.config.shell_integration.osc7 = true

# History data remains outside this repository.
$env.config.history.file_format = "sqlite"

# File removal and table display
$env.config.rm.always_trash = true
$env.config.table.index_mode = "auto"
