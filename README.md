# Home Windows and Linux Development Dotfiles

Personal Windows desktop and Linux SSH development configuration managed from
one repository.

## Contents

| Directory | Configuration |
| --- | --- |
| `wezterm/` | WezTerm appearance, key bindings, and runtime behavior |
| `nushell/` | Nushell, Starship, and Fastfetch configuration |
| `powershell/` | PowerShell 7 profile and interactive shell helpers |
| `nvim/` | Neovim and LazyVim configuration |
| `neovide/` | Neovide font and renderer configuration |
| `codex-dream-skin/` | Local Dream Skin theme source and reproducible ZIP build |
| `startup/` | Ordered Windows logon startup |
| `tmux/` | Minimal remote tmux configuration with true color and OSC 52 |
| `yazi/` | Yazi file manager configuration |
| `flow-launcher/` | Flow Launcher settings and Catppuccin theme |
| `opencode/` | OpenCode application and TUI configuration |
| `glzr/` | GlazeWM and Zebar configuration |
| `yasb/` | YASB widgets, styling, and local helper sources |
| `nilesoft-shell/` | Nilesoft Shell context menu configuration |
| `mremoteng/` | mRemoteNG community-fork provenance and migration notes |

The WezTerm, Nushell, Nilesoft Shell, Neovim, Yazi, and `glzr` histories were
imported from their original repositories with Git subtree. Additional
application-specific documentation is available in `wezterm/`, `nushell/`,
`nvim/`, `yasb/`, and `nilesoft-shell/`.

## Windows Install

Clone the repository and run the installer from PowerShell 7:

```powershell
git clone https://github.com/ColinXHL/windows-dotfiles-home.git "$HOME\windows-dotfiles-home"
pwsh -NoProfile -File "$HOME\windows-dotfiles-home\install.ps1"
```

The installer links configuration but does not install the applications it
configures. Install the applications needed by the selected configurations
first. WezTerm starts `nu.exe`; Nushell runs Fastfetch and requires the generated
`~/.zoxide.nu` described in `nushell/README.md`; and the PowerShell profile
requires Zoxide and Starship. Both shell configurations use the linked
`~/.config/starship.toml` prompt configuration and provide manual local HTTP/HTTPS
proxy commands for `127.0.0.1:7890`; the proxy is not enabled at shell startup.

The YASB configuration contains user-profile paths. Replace them in
`yasb/config.yaml` before installing under another Windows account.

The installer creates these symbolic links:

```text
~/.config/wezterm/wezterm.lua     -> <repo>/wezterm/wezterm.lua
~/.config/wezterm/modules/*.lua   -> <repo>/wezterm/modules/*.lua
~/.config/wezterm/assets/**       -> <repo>/wezterm/assets/**
%APPDATA%/neovide/config.toml     -> <repo>/neovide/config.toml
~/.config/nushell/config.nu       -> <repo>/nushell/config.nu
~/.config/nushell/modules/*.nu    -> <repo>/nushell/modules/*.nu
~/.config/nushell/fastfetch.jsonc -> <repo>/nushell/fastfetch.jsonc
~/.config/starship.toml           -> <repo>/nushell/starship.toml
%APPDATA%/nushell/config.nu       -> <repo>/nushell/config.nu
<Windows Documents known folder>/PowerShell/Microsoft.PowerShell_profile.ps1
                                    -> <repo>/powershell/Microsoft.PowerShell_profile.ps1
%LOCALAPPDATA%/nvim/**            -> <repo>/nvim/**, one link per file
%APPDATA%/yazi/config/**          -> <repo>/yazi/**, one link per file
%APPDATA%/FlowLauncher/Settings/Settings.json
                                    -> <repo>/flow-launcher/Settings.json
%APPDATA%/FlowLauncher/Themes/Tokyo Mocha.xaml
                                    -> <repo>/flow-launcher/themes/Tokyo Mocha.xaml
%APPDATA%/FlowLauncher/Settings/Plugins/Flow.Launcher.Plugin.Explorer/Settings.json
                                    -> <repo>/flow-launcher/plugins/explorer/Settings.json
%APPDATA%/FlowLauncher/Settings/Plugins/Flow.Launcher.Plugin.WebSearch/Settings.json
                                    -> <repo>/flow-launcher/plugins/web-search/Settings.json
~/.config/opencode/opencode.jsonc -> <repo>/opencode/opencode.jsonc
~/.config/opencode/tui.json       -> <repo>/opencode/tui.json
~/.config/opencode/plugins/**     -> <repo>/opencode/plugins/**
~/.glzr/glazewm/config.yaml       -> <repo>/glzr/glazewm/config.yaml
~/.glzr/zebar/settings.json       -> <repo>/glzr/zebar/settings.json
~/.config/yasb/**                 -> <repo>/yasb/**, one link per file

Unless -SkipNilesoft is passed, when Nilesoft Shell is installed:
%ProgramFiles%/Nilesoft Shell/shell.nss
                                    -> <repo>/nilesoft-shell/shell.nss
%ProgramFiles%/Nilesoft Shell/imports/*
                                    -> <repo>/nilesoft-shell/imports/*
```

Already-correct symbolic links are left unchanged. Conflicting destinations are
moved to timestamped `.bak` paths before replacement; tree installations do
this per file. Legacy `.git` directories in the WezTerm, Nushell, and YASB
destinations are archived separately.

Windows Developer Mode or an elevated terminal is required to create symbolic
links, and Nilesoft requires elevation for its `Program Files` destination.
File-level links allow the installer to run while WezTerm is open. The installer
also removes stale Neovim links, sets `YAZI_FILE_ONE` when
`%ProgramFiles%\Git\usr\bin\file.exe` is found, runs `ya pkg install` when
available, and restarts Nilesoft after updating it. When installed in their
standard locations, GlazeWM, YASB, Flow Launcher, Tacky Borders, and the
AutoHotkey hotkeys are started by one ordered current-user logon script.
GlazeWM starts before YASB so its IPC endpoint is ready when the bar connects.
The script also starts the Codex Dream Skin tray, but does not launch Codex at
login. The installer creates a Start menu `Codex (Dream Skin)` shortcut that
starts Codex on demand and applies the active skin with the required local
debugging endpoint. Startup diagnostics are written to
`%LOCALAPPDATA%\windows-dotfiles\startup.log`. Tacky Borders uses the tracked
Deep Teal gradient/glow configuration under
`tacky-borders/config.yaml`; GlazeWM's native one-pixel border is disabled to
avoid drawing two borders. An installed Everything client
is registered with `-startup` to provide background search IPC without opening
its search window.

## Linux SSH Install

Clone this repository inside the Linux VM or server and run:

```bash
git clone https://github.com/ColinXHL/windows-dotfiles-home.git ~/windows-dotfiles-home
bash ~/windows-dotfiles-home/install-linux.sh --packages
```

`--packages` is optional and invokes the detected `apt-get`, `dnf`, `pacman`, or
`zypper` package manager. Commands run directly as root; otherwise the script
uses `sudo`, falling back to `doas`. Without `--packages`, no system packages are
changed, but setup requires an existing usable Neovim or `curl`, `tar`, and
`sha256sum`/`shasum`; Git is also required to restore plugins. The installer:

- uses the first `nvim` on `PATH` when it runs and is at least 0.11.2, otherwise
  installs the checksum-verified official Neovim 0.12.4 build under `~/.local`
  on x86-64 or ARM64 glibc systems;
- links `nvim/` to `${XDG_CONFIG_HOME:-$HOME/.config}/nvim` and links
  `tmux/tmux.conf` to `~/.tmux.conf`;
- preserves existing files as timestamped backups;
- handles Debian's `fdfind` executable name; and
- restores LazyVim plugins from `lazy-lock.json` when Git is available, unless
  `--no-sync` is passed.

The optional package step installs a C/C++ compiler and Clang tools, CA
certificates, Git, CMake, curl, gzip, Ninja, tmux, ripgrep, fd/fd-find, Node/npm,
Python/pip, tar, and unzip; apt systems also receive `python3-venv`. The Arch
branch runs `pacman -Syu`, including a full system upgrade. Other architectures,
musl systems, and hosts with glibc too old for the official Neovim build are not
supported by the bundled Neovim installer.

The Linux installer deliberately does not link Windows-specific WezTerm,
GlazeWM, YASB, Nushell, or OpenCode settings. It does not select the local SSH
client; when the session runs inside the configured WezTerm, WezTerm supplies
the Nerd Font rendering, Catppuccin palette, and local background image.

Start a project with:

```bash
cd /path/to/project
tmux
nvim .
```

Use `"+y` in Neovim when text should be copied through tmux/OSC 52 to the
Windows clipboard. Normal `y` stays in Neovim's unnamed register. The included
tmux configuration enables application OSC 52 writes for trusted development
VMs; change `set-clipboard` from `on` to `external` on untrusted hosts. Ordinary
tmux option changes can be reloaded without destroying sessions using
`tmux source-file ~/.tmux.conf`; after changing terminal capability settings,
start a new client or restart the server before validating `Ms`.

See `nvim/README.md` for the intentionally small keymap and C++ workflow.

The AutoHotkey v2 configuration is linked to
`~/.config/autohotkey/hotkeys.ahk` and launched by the ordered current-user
startup script. `Ctrl+Alt+T` starts a new WezTerm GUI process with the user
profile as its working directory. The installer supports both the WinGet per-user path under
`%LOCALAPPDATA%\Programs\AutoHotkey` and the system-wide `%ProgramFiles%` path.

Nilesoft Shell is installed with file-level symbolic links for `shell.nss` and
every custom `imports/*.nss` tracked by this repository. Its untracked built-in
modules remain in place. Because the destination is under `Program Files`, run
the installer from an elevated PowerShell session. Use `-SkipNilesoft` when
only user-level configurations should be linked. If a Nilesoft update replaces
the links, rerun the installer to restore them.

## Local State

Runtime caches, installed package dependencies, histories, credentials, API
keys, and other machine-local state remain outside this repository. Intentional
configuration and lock metadata, including `nvim/lazy-lock.json`,
`nvim/lazyvim.json`, and `yazi/package.toml`, is tracked. OpenCode's
`node_modules` and runtime package metadata stay in `~/.config/opencode`; Yazi
flavors and state stay in `%APPDATA%/yazi`; and GlazeWM/Zebar logs, downloads,
and caches stay in their application directories. Flow Launcher history,
selection records, caches, logs, installed plugins, unlisted plugin settings,
and credentials remain under `%APPDATA%/FlowLauncher`. YASB logs, weather
credentials, DingTalk reminder state, and generated helper executables stay
outside the repository.

mRemoteNG connection files and application settings also stay outside this
repository because they can contain hostnames, usernames, and encrypted
credentials. See `mremoteng/README.md` for the exact non-upstream build source
and local-state policy.
