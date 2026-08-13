# Flow Launcher

Flow Launcher uses `Ctrl+Space` because GlazeWM already owns `Alt+Space`. The
tracked settings enable Pinyin search, start Flow at logon, and select the
custom `Tokyo Mocha` theme.

The theme follows the Catppuccin Mocha palette used by WezTerm and YASB. It
uses an unblurred 85%-opaque `#323047` background, a restrained mauve selection
marker, sky search accents, and subtle text-colored borders.

The official Explorer plugin uses Everything for fast filename and path
searches while keeping Windows Index for `doc:` content searches. File edit
actions open Neovide; folder edit actions open VS Code. Everything still needs
to run in the background, so the installer registers its `-startup` mode at
logon without showing its search window.

Normal queries include Everything results. Use `f <name>` for files only,
`d <name>` for folders only, and `doc: <text>` for indexed file contents. The
home page is enabled, and built-in web search is reduced to `g` for Google.
The installed GitHub plugin owns `gh` without a duplicate web-search result.

Only intentional configuration is tracked:

```text
%APPDATA%/FlowLauncher/Settings/Settings.json
    -> <repo>/flow-launcher/Settings.json
%APPDATA%/FlowLauncher/Themes/Tokyo Mocha.xaml
    -> <repo>/flow-launcher/themes/Tokyo Mocha.xaml
%APPDATA%/FlowLauncher/Settings/Plugins/Flow.Launcher.Plugin.Explorer/Settings.json
    -> <repo>/flow-launcher/plugins/explorer/Settings.json
%APPDATA%/FlowLauncher/Settings/Plugins/Flow.Launcher.Plugin.WebSearch/Settings.json
    -> <repo>/flow-launcher/plugins/web-search/Settings.json
```

History, selection frequency, caches, logs, installed plugins, unlisted plugin
settings, and credentials remain local. Flow must be restarted after changing
the XAML theme directly.
