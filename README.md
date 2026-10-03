# dotfiles

zsh, Vim, tmux, Starship and Claude Code configuration, managed with [chezmoi](https://www.chezmoi.io/).

## Installation

```sh
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply gmasse
```

Requirements:

- `zsh`, `vim`, `tmux`
- `jq`: `chezmoi apply` fails without it, since it merges the Claude Code settings
- a terminal with true colour and a [Nerd Font](https://www.nerdfonts.com/), for the theme and the prompt, status line and airline symbols

## Everyday commands

```sh
chezmoi diff        # preview what apply would change
chezmoi update      # pull this repository and apply
chezmoi apply -R    # also download the externals again now
```

## Claude Code

### Instructions: `~/.claude/CLAUDE.md`

Two files, one managed and one owned by each machine:

- `~/.claude/conventions.md` holds the shared conventions. chezmoi rewrites it on every apply, so edit
  [`dot_claude/conventions.md`](dot_claude/conventions.md) in this repository, not the deployed copy.
- `~/.claude/CLAUDE.md` comes from [`dot_claude/create_CLAUDE.md`](dot_claude/create_CLAUDE.md). The
  `create_` prefix makes chezmoi write it only when it is missing, so after that the file belongs to the
  machine. Its initial content is a Claude Code import of the conventions:

  ```markdown
  @~/.claude/conventions.md
  ```

Then, on each machine:

| Need | Edit `~/.claude/CLAUDE.md` to |
|---|---|
| The shared conventions only | keep it as created |
| Extra rules for this machine | keep the import, add the rules below it |
| A managed policy (such as `/etc/claude-code/CLAUDE.md`) already brings the conventions | replace the import with a comment, so they are not loaded twice |

Never leave the file empty or whitespace-only: chezmoi treats it as missing, removes it, and creates it
again with the import.

A machine whose `~/.claude/CLAUDE.md` predates this setup keeps it untouched: replace its content once.

### Settings: `~/.claude/settings.json`

[`dot_claude/modify_settings.json.tmpl`](dot_claude/modify_settings.json.tmpl) merges
[`claude-managed.json`](claude-managed.json) into the existing file with `jq '. * $managed'`:

- Keys absent from `claude-managed.json` are kept, so settings changed in Claude Code itself (model,
  status line, plugins…) survive an apply.
- Managed keys win on every apply. Change them in `claude-managed.json`, not with `/config`.
- Arrays are replaced, not merged. A local entry in `permissions.allow` or `permissions.deny` is dropped
  on the next apply. Add shared rules to `claude-managed.json`, project rules to the project's
  `.claude/settings.local.json`.
- The merge never deletes. Removing a key from `claude-managed.json` leaves it on every machine where it
  was applied; delete it there by hand.
- `attribution` with empty strings turns off the `Co-Authored-By` trailer and the PR attribution line.

`claude-managed.json` is listed in [`.chezmoiignore`](.chezmoiignore): the script reads it from the source
directory and chezmoi never copies it to `$HOME`. Any other repository-only file at the root needs the same
entry.

### Project template

`~/.claude/templates/CLAUDE.md` is a skeleton for a project's own `CLAUDE.md`: copy it into the project and
fill in the placeholders.

## zsh

- `NO_CLOBBER` is on: `>` refuses to overwrite an existing file, use `>|`. It is off when `$CLAUDECODE` is
  set, because Claude Code's shell would otherwise keep the old contents.
- `mv`, `cp` and `ln` ask before overwriting.
- Every `*.zsh` file in `~/.config/zsh/aliases/` is sourced: add a file there for new aliases.
- Every `*.plugin.zsh` under `~/.config/zsh/plugins/` is sourced, except fast-syntax-highlighting, which
  must come last and is loaded on its own at the end.
- A command typed with a leading space is not saved in the history. Up and Down search the history for
  the text already typed.

## tmux

- The prefix is `Ctrl+Space`, not `Ctrl+B`.
- `prefix r` reloads the configuration, `prefix Enter` enters copy mode, where `v`, `V`, `Ctrl+V` and `y`
  select and copy as in Vim.
- Splits open in the current pane's directory.

## Externals

The Starship binary, the zsh, Vim and tmux plugins and the Edgeweave theme are chezmoi externals,
declared in [`.chezmoiexternal.toml.tmpl`](.chezmoiexternal.toml.tmpl) and downloaded again every 7 days.

- Directories declared with `exact = true` are reset to the archive content: local edits there are lost.
- `catppuccin/tmux` is pinned to v2.3.1, the version the Edgeweave tmux colours are written for. Upgrade
  both together.
- Starship lands in `~/.local/bin`, which comes first in `$PATH`.
