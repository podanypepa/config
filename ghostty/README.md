# ghostty config

Copy `config` file to `~/.config/ghostty/config`

[config](./config)

## font

Sauce Code Pro is recommended, but you can use any font that supports ligatures.

- [preview](https://www.programmingfonts.org/#source-code-pro)
- [download](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip)

## transparency

| shortcut | action |
| --- | --- |
| `cmd+shift+o` | toggle transparency on/off |
| `cmd+shift+=` | less transparent (step 0.05) |
| `cmd+shift+-` | more transparent (step 0.05) |
| `cmd+shift+0` | reset to 0.4 |

The intensity shortcuts work only inside tmux: Ghostty sends `prefix + / _ / |`,
tmux runs [opacity.sh](./opacity.sh), which writes `~/.config/ghostty/opacity`
(loaded via `config-file`) and triggers `reload_config` over AppleScript.
The change applies live. On first use macOS asks to allow tmux to control Ghostty.
