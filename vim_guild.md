# Vim Configuration Guide

A guide to the `~/.vimrc` setup for C, C++, Python, Rust and Go development.
It gives you IDE-style navigation (go to definition, find references, symbol
outline), autocompletion, diagnostics, fuzzy file search and Git integration,
all inside plain Vim 9.

---

## Table of contents

1. [Installation](#1-installation)
2. [Core concepts](#2-core-concepts)
3. [Code navigation (LSP)](#3-code-navigation-lsp)
4. [Jumping between functions](#4-jumping-between-functions)
5. [Autocompletion](#5-autocompletion)
6. [Diagnostics, refactoring and formatting](#6-diagnostics-refactoring-and-formatting)
7. [Fuzzy finding (fzf)](#7-fuzzy-finding-fzf)
8. [Symbol outline (Vista)](#8-symbol-outline-vista)
9. [Git integration](#9-git-integration)
10. [Windows, buffers and files](#10-windows-buffers-and-files)
11. [Editing helpers](#11-editing-helpers)
12. [Language notes](#12-language-notes)
13. [Troubleshooting](#13-troubleshooting)
14. [Customising](#14-customising)
15. [Quick reference card](#15-quick-reference-card)

---

## 1. Installation

### 1.1 System requirements

Vim 9.x compiled with `+job`, `+channel`, `+timers`, `+textprop` and `+popupwin`
(the standard Ubuntu `vim` package has all of these). Check with:

```bash
vim --version | grep -oE '[+-](job|channel|timers|textprop|popupwin)'
```

### 1.2 Install system packages

```bash
# Ubuntu / Debian
sudo apt install vim git curl python3-venv build-essential golang-go ripgrep

# Rust toolchain (optional, only if you write Rust)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

| Package           | Why it is needed                                  |
|-------------------|---------------------------------------------------|
| `git`             | vim-plug downloads plugins with git               |
| `curl`            | downloads vim-plug and language servers           |
| `python3-venv`    | the Python language server installs into a venv   |
| `build-essential` | a C/C++ compiler for clangd to understand headers |
| `golang-go`       | required to install and run gopls                 |
| `ripgrep`         | powers project-wide text search (`Space f r`)     |

### 1.3 Install vim-plug and the plugins

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall
```

### 1.4 Install language servers

Language servers are installed on demand, per language, with no root access.
Open any file of the target language and run:

```vim
:LspInstallServer
```

| Language | Server          | Installed into                          |
|----------|-----------------|-----------------------------------------|
| C / C++  | `clangd`        | `~/.local/share/vim-lsp-settings/servers` |
| Python   | `pylsp`         | same                                    |
| Rust     | `rust-analyzer` | same                                    |
| Go       | `gopls`         | same                                    |

Restart Vim after installing. Run `:LspStatus` to confirm the server is
`running`.

---

## 2. Core concepts

### The leader key is Space

Many shortcuts start with the **leader** key, which is set to `Space`.
When you see `Space f f` in this guide, press Space, then `f`, then `f`
in sequence (not at the same time).

### Modes

- **Normal mode**: the default. Press `Esc` to get back to it from anywhere.
- **Insert mode**: `i` to enter. Type text. Completion popup appears here.
- **Visual mode**: `v` (characters), `V` (lines), `Ctrl-v` (block).

Most shortcuts in this guide are Normal-mode shortcuts.

### The jump list

Every time you jump (go to definition, search, etc.) Vim records where you
were. Use these constantly:

| Key      | Action                                 |
|----------|----------------------------------------|
| `Ctrl-o` | go **back** to where you jumped from    |
| `Ctrl-i` | go **forward** again                    |
| `Ctrl-t` | pop the tag stack (back from `Ctrl-]`)  |

### The quickfix list

Commands that return many results (references, grep, diagnostics) put them in
the **quickfix list**, a window at the bottom of the screen.

| Key         | Action                          |
|-------------|---------------------------------|
| `]q`        | next result                     |
| `[q`        | previous result                 |
| `Space c o` | open the quickfix window        |
| `Space c c` | close the quickfix window       |
| `Enter`     | (in quickfix) jump to the entry |
| `q`         | (in quickfix) close the window  |

---

## 3. Code navigation (LSP)

These shortcuts work in any buffer where a language server is attached.
They are the heart of the setup.

| Key         | Action                                                   |
|-------------|----------------------------------------------------------|
| `gd`        | **Go to definition** of the symbol under the cursor      |
| `gD`        | Go to declaration (C/C++: the prototype in the header)   |
| `gi`        | Go to implementation (Go interfaces, Rust traits)        |
| `gy`        | Go to the **type** definition of a variable              |
| `gr`        | Find all **references** (opens the quickfix list)        |
| `gs`        | Search **symbols in the current file** (fuzzy)           |
| `gS`        | Search symbols across the **whole workspace**            |
| `K`         | Show **hover documentation** in a popup                  |
| `Ctrl-]`    | Go to definition (classic Vim tag jump, now LSP-backed)  |
| `Ctrl-t`    | Jump back after `Ctrl-]`                                 |
| `Space c h` | **Call hierarchy**: who calls this function?             |
| `Space s h` | Signature help for the function call under the cursor   |
| `Ctrl-f` / `Ctrl-b` | Scroll a hover popup down / up                  |

### Typical workflow

1. Put the cursor on a function call and press `gd` to jump to its body.
2. Read it, press `Ctrl-o` to return.
3. Press `gr` to see every caller, then `]q` / `[q` to step through them.
4. Press `Space c h` to see the call tree of a function.
5. Press `K` any time you need the docs or a type signature.

### Splits

To open a definition in a split instead of replacing the current window:

```vim
:vsplit | LspDefinition
```

---

## 4. Jumping between functions

Move the cursor to the **next / previous function** in the file without
knowing its name:

| Key  | Action                            |
|------|-----------------------------------|
| `]]` | jump to the next function start    |
| `[[` | jump to the previous function start|

What counts as a "function start" per language:

| Language | Matches                                              |
|----------|------------------------------------------------------|
| C / C++  | a `{` in column 0 (Vim's native behaviour)            |
| Python   | `def`, `async def`, `class`                           |
| Rust     | `fn`, `pub fn`, `async fn`, `unsafe fn`, `impl`, `struct`, `enum`, `trait` |
| Go       | `func`, `type`                                        |

For a **visual overview** of every function, use the outline sidebar
(`Space o`, see section 8) or the symbol search (`gs`).

---

## 5. Autocompletion

Completion pops up automatically as you type in Insert mode.

| Key         | Action                                        |
|-------------|-----------------------------------------------|
| `Tab`       | select the next item in the popup             |
| `Shift-Tab` | select the previous item                      |
| `Enter`     | accept the highlighted item                   |
| `Ctrl-e`    | dismiss the popup                             |
| `Ctrl-x Ctrl-o` | manually trigger LSP completion (omnifunc) |

The popup does not pre-select an item, so pressing `Enter` with nothing
highlighted just inserts a newline as usual.

---

## 6. Diagnostics, refactoring and formatting

Errors and warnings are shown as signs in the left gutter (`E`, `W`, `H`, `I`)
and echoed in the command line when the cursor is on the offending line.

| Key         | Action                                                 |
|-------------|--------------------------------------------------------|
| `]d`        | jump to the next diagnostic                            |
| `[d`        | jump to the previous diagnostic                        |
| `Space d`   | list all diagnostics in the file (quickfix)            |
| `Space r n` | **Rename** the symbol across the project               |
| `Space c a` | **Code action** (auto-import, fix, extract, etc.)      |
| `Space f`   | **Format** the whole file                              |
| `Space f` (Visual) | format only the selected lines                  |

Rust and Go files are **formatted automatically on save**. C, C++ and Python
are not, to avoid reformatting other people's code; use `Space f` manually.

---

## 7. Fuzzy finding (fzf)

fzf opens a floating window. Type a few characters of what you want, use
`Ctrl-j` / `Ctrl-k` (or arrow keys) to move, `Enter` to open.
Inside fzf: `Ctrl-x` opens in a horizontal split, `Ctrl-v` in a vertical
split, `Ctrl-/` toggles the preview pane, `Esc` cancels.

| Key         | Action                                              |
|-------------|-----------------------------------------------------|
| `Space f f` | find a **file** in the project                      |
| `Space f g` | find a file tracked by **git**                      |
| `Space f b` | switch **buffer** (open files)                      |
| `Space f r` | **grep** the whole project with ripgrep             |
| `Space f w` | grep the **word under the cursor**                  |
| `Space f l` | search **lines** in the current file                |
| `Space f h` | recently opened files (**history**)                 |
| `Space f t` | tags in the current buffer (needs ctags)            |
| `Space f s` | fuzzy-search **LSP symbols** in the current file    |

Tip: in `Space f r`, type your pattern and then press `Alt-a` to select all
results and `Enter` to send them to the quickfix list.

---

## 8. Symbol outline (Vista)

| Key         | Action                                              |
|-------------|-----------------------------------------------------|
| `Space o`   | toggle the **outline sidebar** (functions, types, …) |
| `Space f s` | fuzzy finder over the same symbols                  |

Inside the sidebar: move with `j` / `k`, press `Enter` to jump to a symbol,
`p` to preview, `q` to close. The sidebar follows the cursor as you move
through the source file.

---

## 9. Git integration

Changed lines are marked in the gutter: `+` added, `~` modified, `_` removed.

| Key         | Action                              |
|-------------|-------------------------------------|
| `]h`        | next changed hunk                   |
| `[h`        | previous changed hunk               |
| `Space h p` | **preview** the diff of this hunk   |
| `Space h u` | **undo** this hunk (revert to HEAD) |

---

## 10. Windows, buffers and files

### Windows (splits)

| Key                 | Action                        |
|---------------------|-------------------------------|
| `:vsplit` / `:split`| open a vertical / horizontal split |
| `Ctrl-h/j/k/l`      | move to the window left/down/up/right |
| `Ctrl-Up/Down`      | make the window taller / shorter |
| `Ctrl-Left/Right`   | make the window narrower / wider |
| `Ctrl-w o`          | close all other windows        |
| `Ctrl-w =`          | equalise window sizes          |

New splits open **below** and **to the right**.

### Buffers

| Key          | Action                        |
|--------------|-------------------------------|
| `Space f b`  | pick a buffer with fzf        |
| `Space b n`  | next buffer                   |
| `Space b p`  | previous buffer               |
| `Space b d`  | close (delete) current buffer |
| `Space w`    | save                          |
| `Space q`    | quit window                   |

### Files

| Key         | Action                                        |
|-------------|-----------------------------------------------|
| `Space e`   | open netrw, the built-in tree file browser    |
| `Space f f` | fuzzy-find a file (usually faster)            |
| `Space e v` | edit `~/.vimrc`                               |
| `Space s v` | reload `~/.vimrc` without restarting          |

Files reopen at the **last cursor position**. Undo history is **persistent**
across sessions (stored in `~/.vim/undo`).

---

## 11. Editing helpers

### Commenting (vim-commentary)

| Key            | Action                         |
|----------------|--------------------------------|
| `gcc`          | toggle comment on this line    |
| `gc` + motion  | e.g. `gcap` comments a paragraph, `gc3j` three lines down |
| `gc` (Visual)  | toggle comment on the selection|

### Surround (vim-surround)

| Key        | Action                                    | Example                    |
|------------|-------------------------------------------|----------------------------|
| `cs"'`     | change surrounding `"` to `'`             | `"hi"` becomes `'hi'`      |
| `ds(`      | delete surrounding parentheses            | `(x)` becomes `x`          |
| `ysiw)`    | surround the word with `()`               | `x` becomes `(x)`          |
| `yss{`     | surround the line with `{ }`              |                            |
| `S)` (Visual) | surround the selection with `()`       |                            |

### Moving and indenting

| Key                | Action                                    |
|--------------------|-------------------------------------------|
| `J` / `K` (Visual) | move the selected lines down / up         |
| `>` / `<` (Visual) | indent / dedent and keep the selection    |
| `Space p` (Visual) | paste over a selection without clobbering the register |

### Search

| Key        | Action                                            |
|------------|---------------------------------------------------|
| `/text`    | search forward; case-insensitive unless you type a capital |
| `n` / `N`  | next / previous match, kept centred on screen     |
| `Esc Esc`  | clear the search highlight                        |
| `*`        | search for the word under the cursor              |

### Toggles

| Key  | Action                                           |
|------|--------------------------------------------------|
| `F2` | toggle paste mode (for pasting from the terminal without auto-indent) |
| `F3` | toggle line numbers                              |
| `F4` | toggle visible whitespace characters             |

Auto-pairs inserts the closing `)`, `]`, `}`, `"` and `'` for you.
Trailing whitespace is stripped on save (except in Markdown and diff files).

---

## 12. Language notes

### C / C++ (clangd)

clangd needs to know your compile flags. Provide **one** of:

- `compile_commands.json` in the project root. CMake:
  `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..` then symlink or copy the file
  to the root. Make: `bear -- make` (`sudo apt install bear`).
- A `compile_flags.txt` with one flag per line, e.g.
  ```
  -std=c++20
  -Iinclude
  -Wall
  ```

Without either, clangd still works for single files but may miss includes.
`clang-tidy` checks are enabled and appear as diagnostics.

### Python (pylsp)

Works out of the box. If your project uses a virtualenv, start Vim with it
activated so pylsp resolves imports correctly. Line-length warnings are set
to 120.

### Rust (rust-analyzer)

Requires a `Cargo.toml`. All cargo features are enabled for analysis.
Format on save runs `rustfmt` through the server.

### Go (gopls)

Requires a `go.mod`. `staticcheck` is enabled. Format on save runs
`gofmt` and fixes imports through the server. Indentation uses real tabs, as
Go requires.

---

## 13. Troubleshooting

**Nothing happens on `gd` / no completion**
Run `:LspStatus`. If the server is `not running`, run `:LspInstallServer`
in that filetype, then restart Vim. Check `:LspLog` for errors.

**"git executable not found" at startup**
Install git (`sudo apt install git`), then run `:PlugInstall`.

**Colors look wrong / garbled**
Your terminal may not support true color. Comment out `set termguicolors`
in `~/.vimrc`.

**clangd cannot find headers**
See the C/C++ note in section 12 about `compile_commands.json`.

**pylsp install fails**
Install `python3-venv` (`sudo apt install python3-venv`), delete
`~/.local/share/vim-lsp-settings/servers/pylsp` and retry
`:LspInstallServer`.

**`Space f f` says fzf is not found**
Run `:PlugInstall` again; the fzf binary is downloaded as a post-install step.

**Too slow on a huge repo**
Ripgrep and fzf respect `.gitignore`. Add build directories to it, or set
`g:lsp_diagnostics_enabled = 0` for that session.

Useful commands:

```vim
:LspStatus             " which servers are running
:LspLog                " server log
:LspInstallServer      " install server for current filetype
:LspUninstallServer    " remove it
:PlugStatus            " plugin health
:PlugUpdate            " update all plugins
```

---

## 14. Customising

Edit `~/.vimrc` (`Space e v`) and reload (`Space s v`).

- **Indent width**: change `tabstop`, `shiftwidth`, `softtabstop` in the
  *Indentation* section, or add a filetype to the `indent_overrides` group.
- **Inline error text**: set `g:lsp_diagnostics_virtual_text_enabled = 1`.
- **Format C/C++/Python on save**: add `'c'`, `'cpp'` or `'python'` to the
  list in `s:on_lsp_buffer_enabled` next to `'rust', 'go'`.
- **Colour scheme**: replace `colorscheme habamax` with `retrobox`, `sorbet`,
  `wildcharm`, `desert` or `slate` (all built in).
- **Add a plugin**: add a `Plug 'user/repo'` line between `plug#begin` and
  `plug#end`, then run `:PlugInstall`.
- **Change a server setting**: edit the `g:lsp_settings` dictionary. Server
  option names are the same as in the server's own documentation.

---

## 15. Quick reference card

```
NAVIGATE                         FIND
  gd   definition                 Space f f  files
  gD   declaration                Space f r  grep project
  gi   implementation             Space f w  grep word under cursor
  gy   type definition            Space f b  buffers
  gr   references -> quickfix     Space f l  lines in file
  gs   symbols in file            Space f s  symbols in file (LSP)
  gS   symbols in workspace       Space o    outline sidebar
  K    hover docs                 gS         symbols in workspace
  ]]  [[   next/prev function
  ]d  [d   next/prev error       QUICKFIX
  ]h  [h   next/prev git hunk     ]q  [q     next/prev result
  ]q  [q   next/prev quickfix     Space c o  open    Space c c  close
  Ctrl-o   jump back
  Ctrl-i   jump forward          WINDOWS
                                  Ctrl-h/j/k/l   move between splits
REFACTOR                          Ctrl-arrows    resize
  Space r n  rename
  Space c a  code action         EDIT
  Space f    format               gcc        toggle comment
  Space c h  call hierarchy       cs"' ds( ysiw)   surround
  Space d    all diagnostics      J / K (visual)   move lines
                                  Esc Esc    clear search highlight
COMPLETE (insert mode)           FILE
  Tab / Shift-Tab  next / prev    Space w  save     Space q  quit
  Enter            accept         Space e  file tree
  Ctrl-e           dismiss        Space e v / s v  edit / reload vimrc
```
