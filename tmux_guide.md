# tmux Configuration Guide

A guide to the `~/.tmux.conf` setup. The prefix key is **`C-a`** (Ctrl + a),
and the key bindings are Vim-style so they feel natural alongside the
companion `~/.vimrc`.

---

## Table of contents

1. [What tmux is and why use it](#1-what-tmux-is-and-why-use-it)
2. [Installation](#2-installation)
3. [Core concepts](#3-core-concepts)
4. [The prefix key](#4-the-prefix-key)
5. [Sessions](#5-sessions)
6. [Windows](#6-windows)
7. [Panes](#7-panes)
8. [Copy mode and the clipboard](#8-copy-mode-and-the-clipboard)
9. [Mouse support](#9-mouse-support)
10. [The status bar](#10-the-status-bar)
11. [Working with Vim inside tmux](#11-working-with-vim-inside-tmux)
12. [Useful commands](#12-useful-commands)
13. [Troubleshooting](#13-troubleshooting)
14. [Customising](#14-customising)
15. [Quick reference card](#15-quick-reference-card)

---

## 1. What tmux is and why use it

tmux is a **terminal multiplexer**. It lets you:

- Run several shells in one terminal window, split into **panes** and grouped
  into **windows**.
- **Detach** from a session and come back later. Everything keeps running,
  even if you close the terminal or your SSH connection drops.
- Scroll back through output, search it, and copy text with the keyboard.

If you work over SSH, tmux is the difference between losing a long build when
the network hiccups and simply reconnecting to find it still running.

---

## 2. Installation

```bash
sudo apt install tmux            # Ubuntu / Debian, provides tmux 3.4
```

Copy `.tmux.conf` to your home directory, then start tmux:

```bash
tmux
```

If tmux is already running, reload the configuration with `C-a r`.

Optional, for clipboard integration with the desktop:

```bash
sudo apt install xclip           # X11
sudo apt install wl-clipboard    # Wayland
```

The config detects whichever is installed automatically.

---

## 3. Core concepts

```
Server
 └── Session  "work"            ← a collection of windows; you attach to a session
      ├── Window 1  "vim"        ← like a tab; fills the whole screen
      │    ├── Pane              ← a split region running one shell
      │    └── Pane
      ├── Window 2  "build"
      └── Window 3  "logs"
```

- **Session**: a workspace. Typically one per project. Survives detaching.
- **Window**: a full-screen tab within a session. Shown in the status bar.
- **Pane**: a split within a window. Each pane is its own shell.

Windows and panes are numbered **from 1**, matching the number row on the
keyboard. When you close a window, the others renumber so there are no gaps.

---

## 4. The prefix key

tmux commands are typed as **prefix, then a key**. The prefix is `C-a`
(hold Ctrl, press `a`, release both, then press the next key).

In this guide `C-a x` means: press Ctrl+a, release, then press `x`.

| Keys      | Action                                                           |
|-----------|------------------------------------------------------------------|
| `C-a`     | the prefix                                                       |
| `C-a C-a` | send a literal Ctrl+a to the program (jump to line start in bash)|
| `C-a a`   | switch to the previously active window                           |
| `C-a r`   | reload `~/.tmux.conf`                                            |
| `C-a ?`   | list every key binding                                           |
| `C-a :`   | open the tmux command prompt                                     |

While the prefix is active, an orange **`C-a`** badge appears at the left of
the status bar so you can see that tmux is waiting for the next key.

Some bindings marked *repeatable* below let you hold the prefix idea in your
head: press `C-a` once, then tap the key several times within half a second.

---

## 5. Sessions

Sessions are managed mostly from the shell.

```bash
tmux                          # start a new session
tmux new -s work              # start a session named "work"
tmux ls                       # list sessions
tmux attach -t work           # attach to "work"
tmux a                        # attach to the most recent session
tmux kill-session -t work     # destroy a session
```

Inside tmux:

| Keys      | Action                                                 |
|-----------|--------------------------------------------------------|
| `C-a d`   | **detach** (leave everything running, return to shell) |
| `C-a S`   | interactive **session and window picker** (tree view)  |
| `C-a $`   | rename the current session                             |
| `C-a (` / `C-a )` | switch to previous / next session              |

The picker (`C-a S`) is the easiest way to move around: navigate with `j`/`k`,
expand a session with `Enter` or `Right`, jump with `Enter`, quit with `q`.

### Typical daily flow

```bash
tmux new -s proj        # morning: create the workspace
# ... work, then close the terminal or lose SSH ...
tmux attach -t proj     # later: everything is still there
```

---

## 6. Windows

| Keys              | Action                                             |
|-------------------|----------------------------------------------------|
| `C-a c`           | **new window**, opens in the current directory     |
| `Alt-1` … `Alt-9` | jump straight to window 1–9 (**no prefix needed**) |
| `C-a 1` … `C-a 9` | same, with the prefix                              |
| `C-a C-n`         | next window (repeatable)                           |
| `C-a C-p`         | previous window (repeatable)                       |
| `C-a Tab`         | last active window (repeatable)                    |
| `C-a a`           | last active window                                 |
| `C-a ,`           | **rename** the window                              |
| `C-a <` / `C-a >` | move the window left / right in the bar (repeatable)|
| `C-a X`           | kill the window                                    |
| `C-a w`           | choose a window from a list                        |
| `C-a f`           | find a window by name                              |

Windows are renamed automatically after the running command until you rename
one yourself. A window with new output while you are elsewhere is highlighted
in orange in the status bar.

Some terminals capture `Alt-number` for their own tabs. If `Alt-1` does not
work, use `C-a 1` instead or disable the shortcut in your terminal.

---

## 7. Panes

### Creating panes

| Keys      | Action                                         |
|-----------|------------------------------------------------|
| `C-a \|`  | split **right** (vertical divider)             |
| `C-a -`   | split **below** (horizontal divider)           |
| `C-a \`   | split right using the **full height** of the window |
| `C-a _`   | split below using the **full width** of the window  |

New panes always open in the **same directory** as the pane you split from.

### Moving between panes

| Keys                  | Action                                       |
|-----------------------|----------------------------------------------|
| `C-a h` `j` `k` `l`   | move left / down / up / right                |
| `Alt-h` `j` `k` `l`   | same, **without the prefix**                 |
| `C-a q`               | show pane numbers; press a number to jump    |
| `C-a o`               | cycle to the next pane                       |
| `C-a ;`               | toggle to the last active pane               |

### Resizing and arranging

| Keys                  | Action                                        |
|-----------------------|-----------------------------------------------|
| `C-a H` `J` `K` `L`   | resize by 5 cells in that direction (repeatable) |
| `C-a m`               | **zoom**: maximise the pane, press again to restore |
| `C-a Space`           | cycle through preset layouts (repeatable)     |
| `C-a =`               | tiled layout: all panes equal size            |
| `C-a {` / `C-a }`     | swap pane with the previous / next one        |
| `C-a b`               | **break** the pane out into its own window    |
| `C-a s`               | **join** a pane from another window (prompts for the window number) |

The status bar shows `[ZOOM]` while a pane is zoomed, so you do not forget
that other panes are hidden.

### Closing panes

| Keys      | Action                                  |
|-----------|-----------------------------------------|
| `C-a x`   | kill the pane immediately (no prompt)   |
| `exit` or `Ctrl-d` | close the shell, which closes the pane |

### Other

| Keys      | Action                                     |
|-----------|--------------------------------------------|
| `C-a /`   | open a **man page** in a split (prompts for the name) |
| `C-a C-l` | clear the screen (`Ctrl-l` alone is left free for pane navigation in Vim) |

---

## 8. Copy mode and the clipboard

Copy mode lets you scroll back, search, and select text using **Vim keys**.

### Entering and leaving

| Keys            | Action                         |
|-----------------|--------------------------------|
| `C-a Enter` or `C-a Esc` or `C-a [` | enter copy mode |
| `q` or `Esc`    | leave copy mode                |
| Mouse scroll up | also enters copy mode          |

### Moving (inside copy mode)

| Keys            | Action                                    |
|-----------------|-------------------------------------------|
| `h` `j` `k` `l` | move the cursor                           |
| `w` `b` `e`     | word forward / back / end                 |
| `H` / `L`       | start / end of line                       |
| `g` / `G`       | top / bottom of the scrollback            |
| `Ctrl-u` / `Ctrl-d` | half page up / down                   |
| `Ctrl-b` / `Ctrl-f` | full page up / down                   |
| `/text` `?text` | search forward / backward                 |
| `n` / `N`       | next / previous match                     |

### Selecting and copying

| Keys      | Action                                                |
|-----------|-------------------------------------------------------|
| `v`       | start selecting characters                            |
| `V`       | start selecting whole lines                           |
| `C-v`     | toggle **rectangle** (block) selection                |
| `y`       | **yank** the selection and leave copy mode            |
| `Y`       | yank the whole current line                           |
| `Enter`   | yank (tmux default, also works)                       |

### Pasting

| Keys      | Action                                                |
|-----------|-------------------------------------------------------|
| `C-a p`   | paste the most recent buffer                          |
| `C-a P`   | choose from all saved buffers                         |
| `C-a #`   | list buffers                                          |

### Where does the text go?

1. Always into tmux's own paste buffer (`C-a p`).
2. Into your **terminal's clipboard** through OSC 52 if the terminal supports
   it (most modern terminals do, and it works over SSH).
3. Into the **system clipboard** if `xclip` or `wl-copy` is installed.

To paste from the system clipboard into tmux, use your terminal's normal paste
shortcut (usually `Ctrl-Shift-v`).

---

## 9. Mouse support

The mouse is enabled. You can:

- **Click** a pane or window name to select it.
- **Drag** the divider between panes to resize.
- **Scroll** to move through the scrollback (enters copy mode automatically).
- **Drag** to select text. The selection is copied when you release, and you
  stay in copy mode so you can keep working with the text; press `q` to leave.
- **Double-click** a word or **triple-click** a line to select it.

Hold **Shift** while selecting to bypass tmux and use the terminal's native
selection instead.

---

## 10. The status bar

```
┌───────────────────────────────────────────────────────────────────────┐
│ work  C-a   1:vim*  2:build  3:logs           [ZOOM] user@host  2026-09-14 22:50 │
└───────────────────────────────────────────────────────────────────────┘
  ^      ^      ^                                  ^        ^
  │      │      │                                  │        └ user, hostname, clock
  │      │      └ windows; the blue one is current; * = current, - = last
  │      └ orange badge shown only while the prefix is active
  └ session name
```

Flags after a window name:

| Flag | Meaning                                  |
|------|------------------------------------------|
| `*`  | current window                           |
| `-`  | last window                              |
| `#`  | activity (new output) in that window     |
| `Z`  | a pane in that window is zoomed          |

---

## 11. Working with Vim inside tmux

The two configs are designed to work together.

- **Esc is instant.** `escape-time` is 10 ms, so leaving Insert mode in Vim
  has no lag.
- **Colours work.** `tmux-256color` plus true-colour passthrough means Vim's
  `termguicolors` renders correctly.
- **Auto-reload works.** Focus events are forwarded, so Vim's `autoread`
  notices when a file changes on disk while you were in another pane.
- **No key conflicts.** Vim uses `Ctrl-h/j/k/l` to move between *Vim splits*.
  tmux uses `Alt-h/j/k/l` (or `C-a h/j/k/l`) to move between *tmux panes*.
  `Ctrl-l` is therefore never stolen by tmux; use `C-a C-l` to clear the screen.
- **Same copy keys.** Copy mode uses `v`, `V`, `C-v`, `y`, exactly like Vim.

Suggested layout for a coding window:

```
C-a |        → editor on the left, shell on the right
C-a l, C-a - → split the right side: shell above, tests/logs below
C-a h        → back to the editor
C-a m        → zoom the editor when you need the full screen
```

Handy shortcuts:

| Keys      | Action                                  |
|-----------|-----------------------------------------|
| `C-a e`   | open `~/.vimrc` in a new window         |
| `C-a E`   | open `~/.tmux.conf` in a new window     |

---

## 12. Useful commands

Type these after `C-a :` (the tmux command prompt), or from a shell prefixed
with `tmux`.

```
:source ~/.tmux.conf          reload config (same as C-a r)
:list-keys                    all bindings (same as C-a ?)
:show -g prefix               confirm the prefix
:rename-session name          rename session
:rename-window name           rename window
:swap-window -t 2             move current window to position 2
:move-window -t 5             renumber current window to 5
:join-pane -s 3               pull pane from window 3 into this window
:kill-server                  stop tmux entirely (all sessions)
:setw synchronize-panes       type into all panes at once (toggle again to stop)
:clear-history                clear the scrollback of the current pane
:capture-pane -p > file.txt   save the visible pane to a file
```

From the shell:

```bash
tmux ls                                   # list sessions
tmux new -s name -d                       # create a detached session
tmux send-keys -t name 'make' Enter       # type a command into a session
tmux kill-server                          # stop everything
```

---

## 13. Troubleshooting

**`C-a` does nothing / `C-b` still works**
The config was not loaded. Check the file is at `~/.tmux.conf`, then run
`tmux kill-server` and start tmux again. Inside tmux, `C-b :source ~/.tmux.conf`
loads it into the running server.

**Colours are wrong or Vim looks washed out**
Make sure your terminal reports `TERM=xterm-256color` *outside* tmux. Inside
tmux `TERM` should be `tmux-256color`. If `tmux-256color` is missing on a
remote machine, change `default-terminal` to `screen-256color`.

**`Alt-1` or `Alt-h` do not work**
Your terminal emulator or desktop is intercepting Alt combinations. Either
disable those shortcuts in the terminal, or use the prefixed versions
(`C-a 1`, `C-a h`).

**`Ctrl-a` no longer jumps to the start of the line in bash**
Press `C-a C-a` instead. The prefix consumes the first `Ctrl-a`.

**Yank does not reach the system clipboard**
Install `xclip` (X11) or `wl-clipboard` (Wayland) and reload with `C-a r`.
Over SSH, clipboard depends on your local terminal supporting OSC 52.

**Mouse selection copies but I cannot paste with Ctrl-Shift-v**
Same cause as above. Alternatively hold Shift while dragging to use the
terminal's own selection.

**Text is garbled after resizing**
Press `C-a r` to reload, or `C-a :` then `refresh-client`.

**Nested tmux (tmux inside an SSH session inside tmux)**
Press `C-a C-a` to send the prefix to the inner tmux. Or give the inner one a
different prefix.

---

## 14. Customising

Edit `~/.tmux.conf` (`C-a E`) and reload (`C-a r`).

- **Change the prefix**: edit the `set -g prefix C-a` line and the
  `bind C-a send-prefix` line together.
- **Colours**: the status bar uses hex colours (`#5f87af` blue, `#d7af5f`
  orange, `#1c1c1c` background). Change them in the *Status bar* section.
- **Status bar on top**: `set -g status-position top`.
- **Bigger scrollback**: `set -g history-limit 100000`.
- **Turn off the mouse**: `set -g mouse off`.
- **Confirm before killing a pane**: change `bind x kill-pane` to
  `bind x confirm-before -p "kill pane? (y/n)" kill-pane`.
- **Add a plugin manager**: install
  [tpm](https://github.com/tmux-plugins/tpm) with git and add the
  `run '~/.tmux/plugins/tpm/tpm'` line at the very end of the file.

---

## 15. Quick reference card

```
PREFIX  C-a        C-a C-a  literal Ctrl-a     C-a r  reload    C-a ?  all keys

SESSIONS                            WINDOWS
  tmux new -s name   create           C-a c        new window (same dir)
  tmux ls            list             Alt-1..9     jump to window (no prefix)
  tmux a -t name     attach           C-a C-n/C-p  next / previous
  C-a d              detach           C-a Tab, C-a a   last window
  C-a S              tree picker      C-a ,        rename
  C-a $              rename           C-a < / >    move left / right
                                      C-a X        kill window

PANES                               COPY MODE (vi)
  C-a |  split right                  C-a Enter    enter copy mode
  C-a -  split below                  v / V / C-v  select chars / lines / block
  C-a \  full-height split            y            yank and exit
  C-a _  full-width split             Y            yank line
  Alt-h/j/k/l   move (no prefix)      / ?          search
  C-a h/j/k/l   move                  q / Esc      leave
  C-a H/J/K/L   resize                C-a p        paste
  C-a m  zoom toggle                  C-a P        choose buffer
  C-a Space  next layout
  C-a =  tiled layout               MISC
  C-a b  break out to window          C-a /        man page in split
  C-a s  join pane from window        C-a e / E    edit .vimrc / .tmux.conf
  C-a x  kill pane                    C-a C-l      clear screen
  C-a q  show pane numbers            C-a :        command prompt
```
