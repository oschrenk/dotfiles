---
name: worktrunk
description: "Use when user asks about git worktrees, running AI agents in parallel, wt commands, worktrunk hooks, or managing multiple parallel branches with wt."
user-invocable: true
---

# worktrunk

`wt` (worktrunk) is a CLI for git worktree management, designed for running AI agents in parallel. Worktrees are addressed by branch name; paths are computed from a configurable template.

## Core commands

| Task | Command |
|------|---------|
| Create worktree + branch | `wt switch --create feature` |
| Create + launch Claude | `wt switch --create feature -x claude` |
| Switch to existing worktree | `wt switch feature` |
| Switch to previous worktree | `wt switch -` |
| List all worktrees | `wt list` |
| List with CI/summaries | `wt list --full` |
| List all branches (no worktree) | `wt list --full --branches` |
| Merge current branch | `wt merge main` |
| Remove current worktree | `wt remove` |
| Remove specific worktree | `wt remove feature` |

## `wt switch`

```bash
wt switch --create feature-auth            # Create branch + worktree from default branch
wt switch --create feature-auth --base=@  # Branch from current HEAD (stacked)
wt switch --create feature -x claude       # Create + run claude after switching
wt switch feature -x claude -- 'Fix #123' # Switch + run claude with args
wt switch pr:123                           # Check out a PR's branch
wt switch -                                # Switch to previous worktree
```

The `-x` / `--execute` flag runs a command after switching. Arguments after `--` are passed to it.

## `wt list`

The `@` marker = current worktree. Status columns show staged changes, commits ahead/behind main, and remote sync state.

```bash
wt list                     # compact view
wt list --full              # CI status + LLM branch summaries
wt list --full --branches   # include branches without worktrees
wt list --format=json       # structured output for scripts/dashboards
```

## `wt merge`

Squash-commits, rebases, merges into target branch, removes worktree — all in one step:

```bash
wt merge main
```

Runs `pre-merge` hooks first; failures abort the merge. After merging it removes the worktree if the branch matches the target.

## Template variables & filters

Available in hook commands and config templates:

| Variable/Filter | Description |
|-----------------|-------------|
| `{{ branch }}` | Current branch name |
| `{{ repo }}` | Repository name |
| `{{ worktree_path }}` | Absolute path to the worktree |
| `{{ repo_path }}` | Path to the bare repo / `.git` |
| `{{ vars.key }}` | Per-branch state variable |
| `\| hash_port` | Deterministic port (10000–19999) from branch name |
| `\| sanitize` | Branch name safe for shell/tmux (slashes → dashes) |
| `\| sanitize_db` | DB-safe identifier (lowercase, underscores, hash suffix) |

## Hooks

Hooks run commands at lifecycle points. Defined in `.config/wt.toml` (project) or `~/.config/worktrunk/config.toml` (user).

```toml
[post-start]        # after worktree is created/switched to
setup = "npm install"
server = "npm run dev -- --port {{ branch | hash_port }}"

[pre-start]         # before switching (use if hooks need copied files immediately)
copy = "wt step copy-ignored"

[pre-merge]         # before wt merge; failure aborts merge
lint = "npm run lint"
test = "npm test"

[post-merge]        # after successful merge
notify = "say 'Merge complete'"

[pre-remove]        # before worktree removal
server = "lsof -ti :{{ branch | hash_port }} -sTCP:LISTEN | xargs kill 2>/dev/null || true"

[post-remove]       # after removal
```

## `wt step` — built-in steps

```bash
wt step commit              # commit staged changes (LLM message if configured)
wt step copy-ignored        # copy gitignored files (node_modules, .env, etc) from another worktree
```

## Per-branch variables

Store and read state scoped to the current branch:

```bash
wt config state vars set key=value
wt config state vars get key
wt config state vars set env=staging port=5432
```

Reference in hooks: `{{ vars.key }}` (expanded at execution time).

## Agent handoff pattern

Spawn a worktree with Claude running in the background:

**tmux:**
```bash
tmux new-session -d -s fix-auth "wt switch --create fix-auth -x claude -- 'Fix the session timeout — extend from 5m to 24h.'"
```

**Zellij:**
```bash
zellij run -- wt switch --create fix-auth -x claude -- 'Fix the session timeout — extend from 5m to 24h.'
```

**Alias for one-liner:**
```bash
alias wsc='wt switch --create --execute=claude'
wsc new-feature                         # Creates worktree + launches Claude
wsc feature -- 'Fix GH #322'           # Passes prompt to Claude
```

## Parallel agents

```bash
wt switch -c -x claude feature-a -- 'Add user authentication'
wt switch -c -x claude feature-b -- 'Fix the pagination bug'
wt switch -c -x claude feature-c -- 'Write tests for the API'
```

Each agent gets its own worktree; no file conflicts.

## Dev server per worktree

Each branch gets a deterministic port via `hash_port`:

```toml
# .config/wt.toml
[post-start]
server = "npm run dev -- --port {{ branch | hash_port }}"

[list]
url = "http://localhost:{{ branch | hash_port }}"

[pre-remove]
server = "lsof -ti :{{ branch | hash_port }} -sTCP:LISTEN | xargs kill 2>/dev/null || true"
```

## Useful shortcuts

```bash
wt switch --create hotfix --base=@    # stack on current branch
wt switch -                           # previous worktree
wt remove @                           # remove current
git rebase $(wt config state default-branch)  # reuse detected default branch
```

## Track agent status

```bash
wt config state marker set "🤖"                    # current branch
wt config state marker set "✅" --branch feature   # specific branch
```

Claude Code and OpenCode plugins set these automatically (🤖 = working, 💬 = waiting).

## Config locations

- **Project config:** `.config/wt.toml` (checked into repo)
- **User config:** `~/.config/worktrunk/config.toml`
- **Shell integration:** Run `wt config shell install` once to enable directory switching

## Bare repository layout

```bash
git clone --bare <url> myproject/.git
cd myproject
```

```toml
# ~/.config/worktrunk/config.toml
worktree-path = "{{ repo_path }}/../{{ branch | sanitize }}"
```

Creates `myproject/main/`, `myproject/feature/`, etc — all branches as peer directories.
