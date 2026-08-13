# Zed

This configuration carries the Neovim workflow into Zed while keeping Zed's
native project, diagnostics, task, terminal, and remote-development models.

## Appearance

- `YASB Teal Glass` keeps the former Catppuccin Mocha code palette and the
  Neovide-like 75% `#1e1e2e` window mask. Editor, gutter, panel, toolbar, tab
  bar, and terminal backgrounds remain transparent instead of stacking extra
  opaque layers. YASB teal is limited to focused borders, selections, active
  line details, Vim modes, and status colors.
- The editor uses `0xProto Nerd Font Mono` at 16 px. The terminal uses the same
  Nerd Font at 12 pt so icons and terminal applications render correctly in Zed.
- JetBrainsMono Nerd Icons, Maple Mono CN, Noto Sans SC, and Segoe UI Emoji
  are fallbacks. The non-NF Maple build supplies the Neovide-like Chinese
  glyphs; Noto remains a safety fallback. Maple Mono NF CN is intentionally
  skipped because Zed 1.15 misrenders that build's CJK glyph mapping here.
- Editor text uses weight 500 with subpixel rendering and a 1.35 line height.
  Comments are deliberately non-italic in the theme itself.
- Gutter line numbers use opaque Catppuccin `Overlay 1` (`#7f849c`); the active
  line uses YASB bright teal (`#80c3c6`) so both remain legible over the wallpaper.
- The minimap, editor scrollbars, navigation buttons, and toolbar extras are
  hidden; relative line numbers, compact 1.2 line height, and an eight-line
  scroll margin match Neovim.

The settings auto-install Catppuccin Icons, XML, and Doxygen extensions (the
older Catppuccin themes may remain installed). `.xaml` files are associated with XML so they
receive Tree-sitter highlighting. Restart Zed once after the first install if a
theme, icon theme, or newly installed language extension is not applied
immediately.

Zed's C# extension normally parses every documentation line as a plain comment.
`Patch-CSharpDocHighlight.ps1` replaces that injection query: all `/// <...>`
tag lines are combined and parsed as XML without hard-coded tag names, while
`//!`, `/** ... */`, `/*! ... */`, `/// @command`, and `/// \\command` forms use
the Doxygen grammar. `install.ps1` reapplies this small patch because a C#
extension update can replace files in Zed's extension cache.

## Workflow mappings

The high-frequency mappings retain the Neovim leader groups:

| Keys | Zed action |
| --- | --- |
| `Space ff/fg/fs/fS` | Files, text, document symbols, project symbols |
| `Space e`, `Space fe` | Toggle only the Project Panel (never the Agent Panel) |
| `Space aa`, `Ctrl-Shift-a` | Toggle the Agent Panel; the Ctrl binding also works in its input box |
| Project panel `l`/`Enter` | Open a file permanently or expand a directory |
| `Space fr` | Project search with replacement enabled |
| `Space bb/ba/bd/bo` | Tab picker, close all/current/other tabs and panes |
| `Ctrl-h/j/k/l` | Move between editor panes, terminal, and dock panels |
| `Space w\|`, `Space w-`, `Space wd` | Vertical split, horizontal split, close |
| `Space ca/cf/ch/cm/cr` | Code action, format, source/header, LSP tools, rename |
| `gd`, `gD`, `gy`, `gI` | Definition, declaration, type definition, implementation |
| `gr`, `K`, `gK` | References, hover, signature help |
| `[d`/`]d`, `[h`/`]h` | Previous/next diagnostic or Git hunk |
| `Space pp/pb/pd` | Project/current-file/current-line problems |
| `Space jj/jl/jt` | Labeled word jump, go to line, syntax-node selection |
| `Space gg`, `Space fy` | Lazygit or Yazi in a center terminal |
| `Space tt/tf`, `Ctrl-q` | Bottom/center terminal, terminal Vi mode |
| `Space rr/rs` | Task picker, including ad-hoc shell commands |
| `Space cp` | Markdown preview beside the source |
| `Space uh` | Inlay hints |
| `Space ?` | Zed keymap editor |

Zed's native Vim mode also provides the familiar `z` commands without custom
bindings:

| Keys | Action |
| --- | --- |
| `za` / `zA` | Toggle the current fold / toggle it recursively |
| `zc` / `zC` | Close the current fold / close it recursively |
| `zo` / `zO` | Open the current fold / open it recursively |
| `zM` / `zR` | Close all folds / open all folds |
| `zf` | Fold the selected range |
| `zz` / `zt` / `zb` | Place the cursor line at center / top / bottom |

Zed already provides the normal Vim motions, folds, `gd`, `gD`, `gy`, and `gI`,
so they are not duplicated here.

## Deliberate differences

- Flash Treesitter is approximated by syntax-node selection. Zed has no
  labeled Tree-sitter-node jump.
- Yazi can run in a center terminal, but its selection does not update Zed's
  current project or open the selected file.
- Zed restores workspaces itself; `Space qs` opens recent projects rather than
  loading a Persistence session.
- Project Search, diagnostics, and references produce multibuffers instead of a
  Vim quickfix list. There are no `[q`/`]q` mappings.
- Call hierarchy, todo-comments navigation, render-markdown, Overseer task
  filtering/actions, zoxide project switching, Lazy, and Mason have no exact
  one-to-one Zed action. `Space cm` opens Zed's LSP tool menu, and `Space rl`
  focuses the terminal output panel.
- Current Zed releases do not expose the `which_key` setting described in the
  reference notes. `Space ?` opens the searchable keymap editor instead.
- New integrated terminals start Nushell with `--no-config-file` and source the
  dedicated `zed.nu`. This suppresses Starship's vendor autoload and Fastfetch,
  but keeps completions, aliases, proxy commands, Yazi, and zoxide's `z`/`zi`.
  They use a blinking bar cursor; existing tabs keep their original shell until reopened.

Global tasks run on the active host, so Lazygit and Yazi must also be installed
on SSH remotes where those mappings are used.
