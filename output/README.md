<div align="center">

# Fresh

**A terminal-based IDE and text editor: easy, powerful and fast.**

![GitHub Release](https://img.shields.io/github/v/release/sinelaw/fresh?display_name=tag&color=%23a6a)
![GitHub License](https://img.shields.io/github/license/sinelaw/fresh)

</div>

## About

Fresh is a terminal text editor that behaves like a modern GUI editor:
familiar keybindings, mouse support, a command palette and menus, and no modal
editing required. It brings IDE features to the terminal: syntax highlighting,
multi-cursor editing, LSP integration, a file explorer, split panes,
integrated terminals and a TypeScript plugin runtime. Very large files open
instantly.

The package is called `fresh-editor`; the command is **`fresh`**.

**[Read the documentation](https://getfresh.dev/)**

## Quick start

```sh
fresh                     # reopen the last workspace
fresh src/main.rs         # open a file
fresh src/main.rs:42:7    # open a file at line 42, column 7
echo hello | fresh        # edit standard input
```

Press `Ctrl+P` for the command palette; **Open Settings** from there changes
most options. `man fresh` lists every command-line flag.

## Sessions

Fresh can keep running in the background as a session daemon, with its
terminals and agents, while you detach:

```sh
fresh -a                  # attach to the session for the current directory
fresh -a NAME             # attach to a named session
fresh --cmd daemon list   # list running sessions
fresh --web               # serve the editor to a browser on 127.0.0.1:8137
```

## Updates

This package is managed by apt. Fresh records that it was installed through
apt, so `fresh --cmd update` and the startup update check point you to
`sudo apt upgrade` instead of replacing the binary themselves. Start it with
`--no-upgrade-check` to turn the check (and its anonymous usage ping) off.

## Documentation

- [Documentation site](https://getfresh.dev/)
- [Changelog](https://github.com/sinelaw/fresh/blob/master/CHANGELOG.md)
- [Upstream repository](https://github.com/sinelaw/fresh)
