# Nushell configuration

Windows-first configuration for Nushell running in WezTerm. Validated with Nushell 0.114.1 and Starship 1.26.0.

## Files

- `config.nu`: entrypoint and deterministic module load order
- `zed.nu`: lightweight Zed terminal entrypoint without Starship or Fastfetch
- `modules/core.nu`: editor, terminal integration, history, file and table behavior
- `modules/prompt.nu`: status-aware transient prompt
- `modules/completions.nu`: fuzzy IDE-style completion menu and Tab behavior
- `modules/proxy.nu`: manual local proxy commands `proxy-on`/`proxy-off`
- `modules/commands.nu`: aliases, Git abbreviations, `mkcd`, and Yazi wrapper
- `starship.toml`: customized Tokyo Night preset with home-relative Git repository paths
- `fastfetch.jsonc`: Windows desktop module selection without unsupported probes
- `install.ps1`: legacy standalone linker; use the unified repository installer

History databases, plugin registries, backups, and generated vendor scripts are intentionally excluded.

## Requirements

- Nushell 0.114.1 or newer compatible release
- A terminal capable of running Nushell; WezTerm is the intended terminal
- Starship
- Fastfetch
- Neovim
- Git
- Yazi
- Zoxide
- fzf, required by `zi`
- A Nerd Font for prompt symbols

## Generated integrations

Generate Starship's Nushell autoload file:

```nu
mkdir ($nu.data-dir | path join "vendor" "autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor" "autoload" "starship.nu")
```

Generate Zoxide's Nushell source file:

```nu
zoxide init nushell | save -f ~/.zoxide.nu
```

These files are generated for the local installation and should not be committed.

## Windows links

The unified repository is the source of truth. Its installer creates these
symbolic links:

```text
~/.config/nushell/config.nu       -> ~/windows-dotfiles/nushell/config.nu
~/.config/nushell/zed.nu          -> ~/windows-dotfiles/nushell/zed.nu
~/.config/nushell/modules/*.nu    -> ~/windows-dotfiles/nushell/modules/*.nu
~/.config/nushell/fastfetch.jsonc -> ~/windows-dotfiles/nushell/fastfetch.jsonc
%APPDATA%\nushell\config.nu       -> ~/windows-dotfiles/nushell/config.nu
~/.config/starship.toml           -> ~/windows-dotfiles/nushell/starship.toml
```

Creating symbolic links requires Windows Developer Mode or an elevated terminal.

Clone the unified repository and run:

```powershell
git clone https://github.com/ColinXHL/windows-dotfiles.git "$HOME\windows-dotfiles"
pwsh -NoProfile -File "$HOME\windows-dotfiles\install.ps1"
```

The installer leaves correct existing links unchanged. Conflicting destination
files or links are moved to timestamped `.bak` files before replacement.

## Behavior

- Fastfetch runs only in a top-level shell (`SHLVL == 1`) and skips unsupported desktop probes.
- Starship keeps the active prompt complete, shows commands taking at least two seconds, collapses completed prompts to a status-colored arrow, and keeps Git repository paths home-relative.
- Zed starts Nushell with `--no-config-file`, then sources `zed.nu`; this skips
  Starship's vendor autoload and Fastfetch while retaining completions, aliases,
  proxy commands, Yazi, and Zoxide.
- Tab opens the IDE completion menu; arrows select; a second Tab accepts without executing.
- `rm` uses the Recycle Bin by default. Use `rm --permanent` for permanent deletion.
- `proxy-on` uses `http://127.0.0.1:7890`; `proxy-off` restores the inherited proxy variables.
- `ff` runs Fastfetch.
- `gs`, `ga`, `gc`, `gp`, and `gl` expand to editable full Git commands.
- `y` starts Yazi and returns to its final directory.
- `z` and `zi` are provided by Zoxide.

## Multiline paste on Windows

Nushell 0.114.1 disables Reedline bracketed paste on Windows because Crossterm does not yet produce paste events there. Multiline terminal paste may therefore execute one complete line at a time.

Use `Ctrl+O` at the Nushell prompt to open the command buffer in Neovim. Paste and edit there, save with `:wq`, review the returned command buffer, and press Enter explicitly.

Upstream references:

- https://github.com/crossterm-rs/crossterm/issues/737
- https://github.com/crossterm-rs/crossterm/pull/1030

## Validation

```nu
nu --ide-check 100 ~/.config/nushell/config.nu
starship timings
```
