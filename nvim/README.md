# Neovim configuration

A single-file, startup-conscious Neovim setup built around the **built-in
`vim.pack` plugin manager** and Neovim's **native LSP client** — no `lazy.nvim`,
no `packer`, no plugin-manager bootstrap code. Primary focus: **Go**, with
Python and Lua supported as first-class secondary languages.

## Requirements

- Neovim **0.12+** (developed on `v0.13.0-dev`) — `vim.pack`, `vim.lsp.enable()`
  and the `lsp/` runtime directory are required
- `git`, `fd`, `fzf` (for `fzf-lua`)
- Language servers are installed automatically via Mason: `gopls`, `pyright`,
  `lua_ls`
- Optional external tools used by keymaps/formatters: `gofumpt`, `stylua`,
  `black`, `prettier`, `jq`, `rustfmt`, `zig`, `dlv`, `golangci-lint`,
  `revive`, `gocritic`, `gpg`

## Layout

```
.
├── init.lua              # everything: options, plugins, lazy loading, keymaps
├── lua/
│   ├── dapconf.lua       # debugger setup, loaded on first DAP keymap
│   └── py.lua            # Python: venv detection, pytest, formatting
├── lsp/                  # per-server configs picked up by vim.lsp.enable()
│   ├── gopls.lua
│   └── lua_ls.lua
└── nvim-pack-lock.json   # vim.pack lockfile — 31 plugins pinned by revision
```

`lsp/<name>.lua` returns a plain config table. Neovim reads it automatically
when `vim.lsp.enable("<name>")` is called — no `lspconfig` setup calls needed.

## Startup strategy

The config is deliberately structured around *what has to happen before the
first screen draw* and what does not.

**1. Deferred setup queue.** `lazy(fn)` pushes a setup function onto a queue
drained on `VimEnter`. Each step runs in its own `vim.defer_fn` timer, so the
UI stays responsive between them, and a failing step is reported through
`vim.notify` instead of aborting the rest.

**2. On-demand setup.** `on_demand(fn)` returns a memoized `ensure()` function.
The plugin is configured the first time a keymap for it is pressed, and at the
latest when the lazy queue reaches it. Used for `oil.nvim` and `fzf-lua`.

**3. Completion stack is kept off `runtimepath`.** `nvim-cmp`, its sources,
`LuaSnip` and `copilot-cmp` are registered with `vim.pack.add(..., { load = function() end })`
so their `plugin/` and `after/plugin/` files never run at startup (~30 ms saved).
The lazy block later `:packadd`s them and manually sources each plugin's
`after/plugin/**` files — `:packadd` alone would skip those, and that is exactly
where the cmp sources register themselves.

**4. Mason is split.** Only `mason/bin` is prepended to `$PATH` at startup;
the registry, `:Mason` and `ensure_installed` are initialized from the lazy queue.

**5. Treesitter is loaded on first matching `FileType`.** Parsers for `go`,
`gomod`, `gowork`, `gosum` and `python` are registered lazily via
`vim.treesitter.language.add()`; `nvim-treesitter` is `:packadd`ed only for its
query files. Buffers larger than **100 KB** skip highlighting entirely.

**6. `oil.nvim` hijacks netrw eagerly** only when Neovim is started on a
directory (`nvim .`); otherwise it waits for `-`.

## Plugins

| Plugin | Role |
| --- | --- |
| `vague.nvim` | colorscheme (transparent, dark) |
| `oil.nvim` | file explorer as an editable buffer, replaces netrw |
| `fzf-lua` | files, buffers, grep, marks, diagnostics, LSP references |
| `neogit` + `diffview.nvim` | git UI and diffs |
| `gitsigns.nvim` | signs, hunks, line blame |
| `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim` | LSP servers |
| `nvim-cmp` (+ `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `LuaSnip`, `lspkind.nvim`) | completion |
| `copilot.lua` + `copilot-cmp` | Copilot as a cmp source (inline suggestions and panel disabled) |
| `formatter.nvim` | format on save |
| `nvim-autopairs` | bracket pairs |
| `nvim-dap` (+ `dap-ui`, `dap-go`, `dap-virtual-text`, `nvim-nio`) | debugging |
| `asyncrun.vim` | run Go linters into the quickfix list |
| `nvim-web-devicons`, `plenary.nvim` | shared dependencies |

Revisions are pinned in `nvim-pack-lock.json`; update with `:h vim.pack.update()`.

## Editor behaviour

- Leader and local leader are both `<Space>`
- Relative + absolute line numbers, `scrolloff` 8, no wrap, global statusline
  (`laststatus=3`), rounded floating-window borders
- 4-space indentation, smart indent, `smartcase` search
- No swapfile, no backup, no writebackup; `confirm` on unsaved quit
- Block cursor in normal/visual, blinking block in insert
- Yanked text flashes for 400 ms (`YankHighlight`)
- Minimal custom statusline: just the file path, in green
- Python and Perl providers disabled

## LSP

Servers are enabled directly with `vim.lsp.enable()`; config lives in `lsp/`.

- **gopls** — unimported completion, full-documentation hover, `staticcheck`,
  inlay hints for parameter names/variable and composite-literal types,
  `unreachable` / `unusedparams` / `unusedwrite` analyses, codelenses for
  generate/tidy/upgrade/vendor, build tags `prod,local,dev,stage`
- **pyright** — basic type checking, workspace diagnostic mode, auto-import
- **lua_ls** — LuaJIT runtime, `vim` global, `$VIMRUNTIME` in the library

Diagnostics use **virtual lines** (not virtual text), signs, severity sorting,
no underline, and no updates while in insert mode.

On `LspAttach`, if the server supports completion, native LSP completion is
wired to `<C-Space>` alongside cmp.

## Formatting

`:FormatWrite` runs on every `BufWritePost`. Trailing whitespace is stripped in
all filetypes; per-filetype formatters: `gofumpt`, `rustfmt`, `black`,
`stylua`, `prettier` (js/ts/svelte/html/css), `jq --indent 4` (json),
`zig fmt`.

Go buffers additionally run a synchronous `source.organizeImports` code action
on `BufWritePre`.

## Keymaps

Leader is `<Space>`. The full list of keymaps (together with Ghostty, tmux
and zsh) lives in the [root README](../README.md#neovim).

## Debugging

`lua/dapconf.lua` is loaded lazily, on the first DAP keymap.

It wires up `nvim-dap` with `dap-ui` (opens on session start, closes on
terminate/exit), virtual text for variable values, and `dap-go` using `dlv`
with a 20 s init timeout and verbose test output.

Keymaps: see the [root README](../README.md#debugger-dap).

## Notes

- Comments inside `init.lua` are in Czech.
