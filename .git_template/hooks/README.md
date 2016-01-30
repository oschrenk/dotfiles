source: http://tbaggery.com/2011/08/08/effortless-ctags-with-git.html

```
git config --global init.templatedir '~/.git_template'
mkdir -p ~/.git_template/hooks
```

Now onto the first hook, which isn’t actually a hook at all, but rather a script the other hooks will call. Place in `.git_template/hooks/ctags` and mark as executable:

```
#!/bin/sh
set -e
PATH="/usr/local/bin:$PATH"
dir="`git rev-parse --git-dir`"
trap 'rm -f "$dir/$$.tags"' EXIT
git ls-files | \
  ctags --tag-relative -L - -f"$dir/$$.tags"
mv "$dir/$$.tags" "$dir/tags"
```

Making this a separate script makes it easy to invoke `.git/hooks/ctags` for a one-off re-index (or `git config --global alias.ctags '!.git/hooks/ctags'`, then just `git ctags`), as well as easy to edit for that special case repository that needs a different set of options to ctags.

I stick the tags file in `.git` because if [fugitive.vim](https://github.com/tpope/vim-fugitive) is installed, Vim will be configured to look for it there automatically, regardless of your current working directory. Plus, you don’t need to worry about adding it to `.gitignore`.

Here come the hooks. Mark all four of them executable and place them in `.git_template/hooks`. Use this same content for the first three: `post-commit`, `post-merge`, and `post-checkout`.

```
#!/bin/sh
.git/hooks/ctags >/dev/null 2>&1 &
```

I’ve forked it into the background so that my Git workflow remains as latency-free as possible.

One more hook that oftentimes gets overlooked: `post-rewrite`. This is fired after `git commit --amend` and `git rebase`, but the former is already covered by `post-commit`. Here’s mine:

```
#!/bin/sh
case "$1" in
  rebase) exec .git/hooks/post-merge ;;
esac
```

Once you get this all set up, you can use `git init` in existing repositories to copy these hooks in.

So what does this get you? Any new repositories you create or clone will be immediately indexed with Ctags and set up to re-index every time you check out, commit, merge, or rebase. Basically, you’ll never have to manually run Ctags on a Git repository again.
