# config

my macos app configs

| Adresář | Aplikace | Symlink |
| --- | --- | --- |
| `ghostty/` | [Ghostty](https://ghostty.org) | `~/.config/ghostty/config` → `ghostty/config` |
| `tmux/` | tmux 3.8 | `~/.tmux.conf` → `tmux/tmux.conf` |
| `nvim/` | Neovim 0.12+ ([detail](nvim/README.md)) | `~/.config/nvim` → `nvim/` |
| `starship/` | Starship prompt | |

```sh
ln -s ~/src/config/ghostty/config ~/.config/ghostty/config
ln -s ~/src/config/tmux/tmux.conf ~/.tmux.conf
ln -s ~/src/config/nvim ~/.config/nvim
```

---

# Klávesové zkratky

Jen vlastní zkratky a pár důležitých výchozích.

**Značení:**
- `⌥` = **levý** Option, funguje jako Alt/Meta. Pravý Option dál píše speciální znaky.
- `prefix` = `Ctrl+a`
- `leader` (nvim) = `Space`

## Jak do sebe zapadají

Klávesa jde přes tři vrstvy: **Ghostty → tmux → aplikace v pane** (shell, nvim). Co si vezme vyšší vrstva, níž už nedorazí.

| Klávesa | Kdo ji bere | Poznámka |
| --- | --- | --- |
| `⌘…` | Ghostty | do tmuxu nikdy nedojde |
| `⌥1`–`⌥9`, `⌥t`, `⌥←↑↓→` | tmux | okna a panes bez prefixu |
| `⌥b` / `⌥f` | shell | slovo zpět / vpřed, tmux je schválně nechává projít |
| `Ctrl+h/j/k/l` | tmux **nebo** nvim/fzf | v nvim a fzf jde klávesa dovnitř, jinak tmux přepne pane |
| `Ctrl+l` (clear) v shellu | — | tmux ho bere pro navigaci, clear je `prefix Ctrl+l` |
| `Ctrl+k` (smaž do konce řádku) v shellu | — | tmux ho bere pro navigaci, v shellu nefunguje |
| `Ctrl+a` (začátek řádku) v shellu | — | je to prefix, do shellu pošleš `prefix Ctrl+a` |
| `Shift+←/→` | tmux | předchozí / další okno |

## Ghostty

| Klávesa | Akce |
| --- | --- |
| `⌘↵` | fullscreen zapnout / vypnout (ne-nativní, bez animace) |
| ``⌘` `` | quick terminal, rozbalí se shora odkudkoli (globální, potřebuje Zpřístupnění) |
| `⌘⇧O` | průhledné / neprůhledné pozadí (okno startuje průhledné, 40 %) |
| `⌘+` / `⌘-` / `⌘0` | větší / menší / výchozí písmo |
| `⌘,` | otevřít config |
| `⌘⇧,` | znovu načíst config |
| `⌘N` | nové okno |
| `⌘C` / `⌘V` | kopírovat / vložit |
| `Shift` + tažení myší | výběr přes Ghostty místo tmuxu a aplikace (třeba v nvim) |

Taby Ghostty se nepoužívají, jejich roli mají tmux okna. Zkratky jako u tabů proto ovládají tmux: Ghostty pošle prefix + klávesu. Mimo tmux (quick terminal) nefungují.

| Klávesa | Akce v tmuxu |
| --- | --- |
| `⌘T` | nové okno ve stejném adresáři |
| `⌘1` … `⌘9` | okno 1–9 |
| `⌘⇧[` / `⌘⇧]` | předchozí / další okno |
| `⌘D` / `⌘⇧D` | split vedle sebe / pod sebe |
| `⌘⇧↵` | zoom pane a zpět |
| `⌘W` | zavřít pane (s potvrzením) |
| `⌘K` | přepínač sessions a projektů |

## tmux

### Bez prefixu

| Klávesa | Akce |
| --- | --- |
| `⌥1` … `⌥9` | přepnout na okno 1–9 |
| `⌥t` | nové okno ve stejném adresáři |
| `Shift+←` / `Shift+→` | předchozí / další okno |
| `⌥←↑↓→` | přepnout pane |
| `Ctrl+h/j/k/l` | přepnout pane, plynule navazuje na nvim splity |

### S prefixem (`Ctrl+a` a pak klávesa)

| Klávesa | Akce |
| --- | --- |
| `f` | **přepínač sessions a projektů** (fzf popup: sessions, git repa v `~/src` a `~/switchly.ai`, zoxide); nový projekt dostane okna viz níže |
| `v` / `s` | split vedle sebe / pod sebe, ve stejném adresáři |
| `h/j/k/l` | přepnout pane |
| `⌥←↑↓→` | změnit velikost pane o 5 (opakovatelné bez nového prefixu) |
| `z` | zoom pane (celá obrazovka) a zpět |
| `x` / `&` | zavřít pane / okno |
| `!` | vytáhnout pane do vlastního okna |
| `Space` | další rozložení panes |
| `c` | nové okno |
| `,` | přejmenovat okno |
| `w` | strom sessions a oken |
| `(` / `)` | předchozí / další session |
| `L` | poslední session (tam a zpět) |
| `$` | přejmenovat session |
| `d` | odpojit se (sessions běží dál, zpět `tmux a`) |
| `[` | copy mode |
| `]` | vložit tmux buffer |
| `r` | znovu načíst config |
| `Ctrl+s` / `Ctrl+r` | uložit / obnovit všechny sessions (automaticky se ukládá každých 15 min a obnovuje po startu tmuxu) |
| `Ctrl+l` | vyčistit obrazovku v shellu |
| `Ctrl+a` | poslat `Ctrl+a` aplikaci |

### Nový projekt

`prefix f` / `⌘K` / `tmc` otevřou pro projekt (git repo, `go.mod`, `package.json`, `pyproject.toml`) session s okny:

| Okno | Obsah |
| --- | --- |
| `1 edit` | nvim |
| `2 shell` | shell |
| `3 run` | připravený příkaz, spustí se až Enterem: Go `go test ./...`, JS/TS `<pm> run dev` (nebo `<pm> test`; pm podle lockfile: npm/pnpm/yarn/bun), Python `uv run pytest` / `pytest` |

Jiný adresář dostane jednu obyčejnou session. Script: `tmux/project-session.sh`.

### Copy mode (vi)

| Klávesa | Akce |
| --- | --- |
| `Space` | začít výběr |
| `V` | vybrat řádek |
| `v` / `Ctrl+v` | obdélníkový výběr |
| `y` / `Enter` | zkopírovat do schránky macOS a ukončit |
| `Y` | zkopírovat a rovnou vložit do příkazové řádky |
| `O` | otevřít výběr (URL, soubor) přes `open` |
| `Ctrl+o` | otevřít výběr v nvim |
| `/` / `?` | hledat dolů / nahoru |
| `q` / `Esc` | ukončit / zrušit výběr |

### Myš

| Akce | Výsledek |
| --- | --- |
| tažení | zkopíruje do schránky a výběr zůstane vidět; **další klávesa** ukončí copy mode a pošle se do shellu |
| dvojklik / trojklik | zkopíruje slovo / řádek |
| kolečko | scroll historie (50 000 řádků) |

## Neovim

Kompletní popis configu je v [nvim/README.md](nvim/README.md).

### Soubory, hledání

| Klávesa | Akce |
| --- | --- |
| `-` | oil: nadřazený adresář (v oil: `Enter` otevřít, `-` výš, `g?` nápověda) |
| `leader Space` | najít soubor |
| `leader Tab` | buffery |
| `leader fw` | grep |
| `leader fu` | grep slova pod kurzorem |
| `leader fm` | značky |
| `leader td` | diagnostika celého workspace |
| `Esc Esc` | zrušit zvýraznění hledání |

### LSP

| Klávesa | Akce |
| --- | --- |
| `Ctrl+]` | definice |
| `gt` | definice typu |
| `gT` | náhled definice typu v plovoucím okně |
| `R` | reference (fzf) |
| `K` | dokumentace (výchozí) |
| `leader do` | diagnostika pod kurzorem |
| `[e` / `]e` | předchozí / další **chyba** |
| `leader oi` | organize imports |
| `Ctrl+Space` (insert) | nativní LSP doplňování |

### Okna, buffery

| Klávesa | Akce |
| --- | --- |
| `Ctrl+h/j/k/l` | přepnout okno, na okraji pokračuje do tmux pane |
| `Tab` / `Shift+Tab` | další / předchozí buffer |
| `leader q` | zavřít buffer |

### Editace

| Klávesa | Akce |
| --- | --- |
| `J` / `K` (visual) | posunout výběr dolů / nahoru |
| `J` | spojit řádky, kurzor zůstane |
| `n` / `N` | další / předchozí shoda, vycentrovaná |
| `<` / `>` (visual) | odsadit, výběr zůstane |
| `p` (visual) | vložit bez přepsání registru |
| `leader s` | nahradit slovo pod kurzorem v celém souboru |
| `F` | formátovat (v Pythonu ruff format + importy) |
| `leader so` | `:source` aktuálního souboru |

Při uložení se automaticky smaže trailing whitespace. Go formátuje gopls (gofumpt + importy), ostatní jazyky formatter.nvim.

### Schránka

| Klávesa | Akce |
| --- | --- |
| `leader y` / `leader Y` | kopírovat výběr / řádek do schránky macOS |
| `leader p` | vložit ze schránky |
| `leader D` | smazat bez přepsání registru |
| `leader cp` | zkopírovat cestu souboru |

### Terminál

| Klávesa | Akce |
| --- | --- |
| `leader tt` | terminál v aktuálním okně |
| `leader st` | terminál dole (10 řádků) |
| `leader vt` | terminál vpravo (třetina šířky) |
| `Esc Esc` (terminál) | zpět do normal módu |

### Quickfix, lintery (Go)

| Klávesa | Akce |
| --- | --- |
| `leader h` / `leader ;` | další / předchozí položka quickfixu |
| `leader la` | `make lintall` |
| `leader ll` | `golangci-lint run ./...` |
| `leader lr` | `revive ./...` |
| `leader lc` | `gocritic check ./...` |

### Python (jen v `.py` bufferech)

| Klávesa | Akce |
| --- | --- |
| `leader pr` | spustit soubor |
| `leader pn` / `pf` / `pa` / `pl` | pytest: nejbližší test / soubor / vše / poslední |
| `leader pv` | ukázat použitý interpreter |

### Debugger (DAP)

| Klávesa | Akce |
| --- | --- |
| `leader db` / `leader dB` | breakpoint / podmíněný breakpoint |
| `leader dc` | spustit / pokračovat |
| `leader dC` | běž ke kurzoru |
| `leader dsi` / `dso` / `dsO` | step into / over / out |
| `leader de` | vyhodnotit výraz pod kurzorem |
| `leader du` | DAP UI zapnout / vypnout |
| `leader dt` | debug testu pod kurzorem (Go i Python) |
| `leader dT` | debug třídy testů (Python) |
| `leader dq` | ukončit |

### Git

| Klávesa | Akce |
| --- | --- |
| `leader ne` | Neogit |

### Doplňování (nvim-cmp)

| Klávesa | Akce |
| --- | --- |
| `Ctrl+n` / `Ctrl+p` | další / předchozí položka, nebo otevřít menu |
| `↑` / `↓` | vybrat položku |
| `Enter` / `Ctrl+y` | potvrdit |
| `Ctrl+e` | zavřít |
| `Ctrl+d` / `Ctrl+u` | scroll dokumentace |

## Shell (zsh)

`~/.zshrc` v repu není, je tu jen přehled zkratek.

| Klávesa / příkaz | Akce |
| --- | --- |
| `Ctrl+r` | historie přes fzf |
| `Ctrl+t` | vložit cestu k souboru přes fzf |
| `⌥c` | `cd` do adresáře přes fzf |
| `z <kus názvu>` | skok do často používaného adresáře (zoxide) |
| `zi` | výběr adresáře přes fzf (zoxide) |
| `→` | přijmout našeptávaný příkaz (zsh-autosuggestions) |
| `⌥b` / `⌥f` | slovo zpět / vpřed |
| `t` | `tmux` (`t a` = připojit se) |
| `tmc` | tmux session pro aktuální adresář s okny podle typu projektu (viz tmux → Nový projekt); funguje uvnitř i mimo tmux |
