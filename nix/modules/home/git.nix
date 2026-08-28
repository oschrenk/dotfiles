{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  # Relative to $HOME, which is what home.file keys on.
  gitHooksDir = ".config/git/hooks";
in
{
  # git-extras: subcommands like `git summary`, `git ignore`, `git browse`, `git changelog`.
  # Auto-discovered by git as `git-<name>` binaries on PATH; no config wiring needed.
  home.packages = [
    pkgs.git-extras
  ];

  # delta: better-looking diffs (separate module in HM 25.11)
  programs.delta = {
    enable = true;
    # wire delta as git's pager and interactive.diffFilter
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      true-color = "always";
      hunk-header-style = "omit";
      line-numbers = true;
      file-added-label = "[+]";
      file-copied-label = "[==]";
      file-modified-label = "[*]";
      file-removed-label = "[-]";
      file-renamed-label = "[->]";
    };
  };

  programs.git = {
    enable = true;

    # git-lfs: large file storage (replaces [filter "lfs"] block)
    lfs.enable = true;

    signing = {
      format = "ssh";
      key = osConfig.my.personal.sshKey;
      signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

    settings = {
      user.name = osConfig.my.personal.name;

      alias = {
        a = "add";
        # add from root dir
        aa = "add --all";
        # interactive staging
        ai = "add -i";
        # interactive hunk staging
        ap = "add -p";
        au = "add -u";
        # show sha1 and commit subject line for each head, with relationship to upstream
        b = "branch --verbose";
        # list both remote-tracking and local branches
        branches = "branch --all";
        c = "commit";
        # replace tip of current branch with new commit; use to fix last commit message or add hunks
        cam = "commit --amend";
        # show only names of files with merge conflicts
        conflicts = "diff --name-only --diff-filter=U";
        # credit an author on the latest commit: git credit "John Doe" jdoe@domain.tld
        credit = "!f() { git commit --amend --author \"$1 <$2>\" -C HEAD; }; f";
        d = "diff";
        dc = "diff --cached";
        # remove branches already merged into master
        dm = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
        dt = "difftool";
        dtc = "difftool --cached";
        f = "!git find";
        # find a file path in codebase
        find = "!git ls-files | rg";
        # simple log
        l = "log --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
        # log graph
        lol = "log --oneline --graph --all";
        # push --force-with-lease ensures nobody else pushed on top of your old remote
        please = "push --force-with-lease";
        pop = "stash pop";
        # list the last 10 branches that have seen changes, with relative dates
        # based on http://ses4j.github.io/2020/04/01/git-alias-recent-branches/
        recent = "!git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[$1]++' | head -n 10 | awk -F' ~ HEAD@{' '{printf(\"  \\033[33m%s: \\033[37m%s\\033[0m\\n\", $1, substr($2, 1, length($2)-1))}'";
        # show remote url after name
        remotes = "remote -v";
        # give the output in the short-format
        s = "status --short";
        # run `git serve`, get your ip and tell your buddy to: git fetch git://192.168.1.123/
        serve = "daemon --verbose --export-all --base-path=.git --reuseaddr --strict-paths .git/";
        ss = "status";
        # stash only unstaged changes to tracked files
        stsh = "stash --keep-index";
        # stash untracked and tracked files
        staash = "stash --include-untracked";
        # stash ignored, untracked, and tracked files
        staaash = "stash --all";
        # switch to last branch
        t = "checkout -";
        # list tags with names that match the given pattern (or all if no pattern is given)
        tags = "tag -l";
        # set up branch to track origin/<current-branch>
        track = "!git branch --set-upstream-to origin/$(git rev-parse --abbrev-ref HEAD)";
        # opposite of git add — remove items from staging area
        unstage = "reset HEAD";
      };

      # sort ordering of branches when displayed by git-branch
      branch.sort = "committerdate";

      # default is true since 1.8.4
      color.ui = true;
      "color \"diff\"" = {
        commit = "227 bold";
        frag = "magenta bold";
        meta = "227";
        new = "green bold";
        old = "red bold";
        whitespace = "red reverse";
      };
      "color \"diff-highlight\"" = {
        newHighlight = "green bold 22";
        newNormal = "green bold";
        oldHighlight = "red bold 52";
        oldNormal = "red bold";
      };
      column.ui = "auto";

      # show unified diff between HEAD and what would be committed at bottom of commit message template
      commit = {
        gpgsign = true;
        verbose = true;
      };

      core = {
        editor = "nvim";
        # Absolute, because git resolves a relative hooksPath against the
        # repository root rather than $HOME.
        hooksPath = "${config.home.homeDirectory}/${gitHooksDir}";
      };

      diff = {
        # try to create more aesthetically pleasing diffs (since git 2.11)
        indentHeuristic = true;
        # use better, descriptive initials (c, i, w) instead of a/b:
        #   git diff                  compares the (i)ndex and the (w)ork tree
        #   git diff HEAD             compares a (c)ommit and the (w)ork tree
        #   git diff --cached         compares a (c)ommit and the (i)ndex
        #   git diff HEAD:file1 file2 compares an (o)bject and a (w)ork tree entity
        #   git diff --no-index a b   compares two non-git things (1) and (2)
        mnemonicPrefix = true;
        # moved lines in a diff are colored differently (since git 2.17)
        # default/zebra: blocks of moved text painted using color.diff.{old,new}Moved
        #   alternating colors indicate a new block was detected
        colorMoved = "default";
      };

      init.defaultBranch = "main";

      merge = {
        # show summary of changes being merged
        summary = true;
        # diff3 adds ||||||| marker with original text, making conflicts easier to resolve
        conflictstyle = "diff3";
      };

      # fail if there is a commit that can't be fast-forwarded (since git 2.0)
      pull.ff = "only";

      push = {
        # push current branch to branch of same name (default since git 2.0)
        default = "current";
        # push relevant tags by default (since git 2.4.1)
        followTags = true;
      };

      rebase = {
        # automatically stash before rebase and apply after (since git 2.7)
        autoStash = true;
        # replaces default `oneline` format (<sha1> <title>) with committer name + title
        # format placeholders: %cn = committer name, %s = title line
        # see https://git-scm.com/docs/git-log (search format:<string>)
        instructionFormat = "%cn: %s";
      };

      # reuse recorded resolution: remember how conflicts were resolved and reapply automatically
      rerere.enabled = true;

      # see https://git-scm.com/docs/git-tag#Documentation/git-tag.txt---sortltkeygt
      tag = {
        gpgsign = true;
        sort = "version:refname";
      };

      # avoid trying to guess defaults for user.email and user.name (since git 2.4.1)
      user.useConfigOnly = true;
    };

    ignores = [
      # OS
      ".DS_Store"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      ".icloud"
      "Desktop.ini"
      "Thumbs.db"
      "ehthumbs.db"
      "$RECYCLE.BIN/"

      # General
      ".rsync_cache/"
      "tmp/**"
      "tmp/**/*"
      "*.tmp"
      "*.bak"
      "*.swp"
      "*.log"
      "log/"
      "logs/"
      "tmp/"

      # Archives
      "*.7z"
      "*.bz2"
      "*.bzip"
      "*.deb"
      "*.dmg"
      "*.egg"
      "*.gem"
      "*.gz"
      "*.iso"
      "*.lzma"
      "*.rar"
      "*.rpm"
      "*.tar"
      "*.xpi"
      "*.xz"
      "*.zip"

      # Eclipse
      "*.pydevproject"
      ".project"
      ".metadata"
      "bin"
      "bin/"
      "bin/**"
      "*~.nib"
      "local.properties"
      ".classpath"
      ".settings/"
      ".loadpath"
      ".externalToolBuilders/"
      "*.launch"
      ".cproject"
      ".buildpath"

      # Netbeans
      "nbproject/private/"
      "build/"
      "nbbuild/"
      "dist/"
      "nbdist/"
      "nbactions.xml"
      "nb-configuration.xml"

      # IntelliJ IDEA
      "*.iml"
      "*.ipr"
      "*.iws"
      ".idea/"
      ".idea_modules/"

      # XCode
      "xcuserdata"
      "project.xcworkspace"

      # Notepad++
      "nppBackup"

      # SublimeText
      "*.sublime-workspace"

      # Textmate
      "*.tmproj"
      "*.tmproject"
      "tmtags"

      # vim
      ".*.sw[a-z]"
      "*.un~"
      "Session.vim"
      ".netrwhist"

      # ensime
      ".ensime"
      ".ensime_cache"

      # Editors with AutoBackup
      "*~"

      # Autotools
      "Makefile.in"
      "/autom4te.cache"
      "/aclocal.m4"
      "/compile"
      "/configure"
      "/depcomp"
      "/install-sh"
      "/missing"

      # npm
      "node_modules"

      # waf
      ".waf-*"
      ".lock-*"

      # Maven
      ".m2/"
      "target/"
      "pom.xml.tag"
      "pom.xml.releaseBackup"
      "pom.xml.versionsBackup"
      "pom.xml.next"
      "release.properties"
      "dependency-reduced-pom.xml"

      # ivy
      ".ivy2/"

      # Leiningen
      ".lein/"
      ".lein-deps-sum"
      ".lein-repl-history"
      ".lein-plugins/"
      ".lein-failures"
      ".nrepl-port"

      # rbenv
      ".rbenv/"

      # jenv
      ".jenv/"

      # Mercurial
      "/.hg/*"
      "*/.hg/*"
      ".hgignore"

      # SVN
      ".svn/"

      # Java
      "*.class"
      "*.ear"
      "*.jar"
      "*.war"

      # C
      "*.o"
      "*.lib"
      "*.a"
      "*.dll"
      "*.ko"
      "*.so"
      "*.so.*"
      "*.dylib"
      "*.exe"
      "*.out"
      "*.app"

      # C++
      "*.slo"
      "*.lo"
      "*.lai"
      "*.la"

      # LaTeX
      "*.acn"
      "*.acr"
      "*.alg"
      "*.aux"
      "*.bcf"
      "*.bbl"
      "*.blg"
      "*.brf"
      "*.dvi"
      "*.fdb_latexmk"
      "*.fls"
      "*.glg"
      "*.glo"
      "*.gls"
      "*.idx"
      "*.ilg"
      "*.ind"
      "*.ist"
      "*.lof"
      "*.lol"
      "*.lot"
      "*.maf"
      "*.mtc"
      "*.mtc0"
      "*.nav"
      "*.nlo"
      "*.pdfsync"
      "*.pdftex"
      "*.ps"
      "*.pyg"
      "*.snm"
      "*.synctex.gz"
      "*.thm"
      "*.toc"
      "*.vrb"
      "*.xdy"
      "*.tdo"

      # Python
      "*.pyc"

      # Ruby
      ".bundle/"
      "vendor/bundle"

      # Scala / sbt
      ".cache"
      ".history"
      "lib_managed/"
      "src_managed/"
      "project/boot/"
      "project/plugins/project/"
      "project/target"
      "project/project/"
      ".scala_dependencies"
      ".worksheet"
      ".metals/"
      ".bloop/"
      "metals.sbt"
      ".bsp"

      # Swift
      ".build"

      # Kotlin / Gradle
      ".kotlin/"
      ".gradle"
      "**/build/"

      # Various
      "cache/"
      "coverage/"
      "externs/"
      "javascripts/"
      "vendor/"

      # Shell tools
      ".envrc"
      "TODO.md"
      ".scannerwork"
      ".rumdl_cache"
      ".task"

      # Claude
      "**/.claude/settings.local.json"

      # direnv
      ".direnv/"
    ];

    attributes = [
      # Unix scripts — force LF line endings
      "*.sh  text eol=lf"
      "*.ac  text eol=lf"
      "*.am  text eol=lf"
      "*.in  text eol=lf"
      "Makefile  text eol=lf"
      "configure  text eol=lf"

      # Windows project files — binary, union merge
      "*.csproj -text merge=union"
      "*.vbproj -text merge=union"
      "*.fsproj -text merge=union"
      "*.dbproj -text merge=union"
      "*.sln -text merge=union"

      # Office documents
      "*.doc   diff=astextplain"
      "*.DOC   diff=astextplain"
      "*.docx  diff=astextplain"
      "*.DOCX  diff=astextplain"
      "*.dot   diff=astextplain"
      "*.DOT   diff=astextplain"
      "*.pdf   diff=astextplain"
      "*.PDF   diff=astextplain"
      "*.rtf   diff=astextplain"

      # XCode
      "*.pbxproj binary"

      # Java
      "*.java text"

      # Binary files
      "*.jar binary"
      "*.so binary"
      "*.dll binary"
    ];
  };

  # Global hooks directory. core.hooksPath makes git look here and nowhere else,
  # so every hook in it must hand control back to the repo's own .git/hooks or
  # those stop running. git-lfs installs four (post-checkout, post-commit,
  # post-merge, pre-push) and this repo tracks LFS objects, so dropping them
  # would corrupt checkouts quietly rather than loudly.
  #
  # Hence: one dispatcher per hook name git-lfs claims, plus commit-msg, which
  # is the one that carries logic of its own.
  home.file =
    let
      # Re-exec the repo-local hook of the same name, if there is one. Uses
      # --git-dir rather than --git-path hooks, because --git-path honours
      # core.hooksPath and would point back at this directory forever.
      dispatch = ''
        localHook="$(git rev-parse --git-dir)/hooks/$(basename "$0")"
        if [ -x "$localHook" ]; then
          "$localHook" "$@" || exit $?
        fi
      '';
      passthrough = name: {
        "${gitHooksDir}/${name}" = {
          executable = true;
          text = ''
            #!${pkgs.runtimeShell}
            ${dispatch}
            exit 0
          '';
        };
      };
    in
    lib.mkMerge (
      (map passthrough [
        "post-checkout"
        "post-commit"
        "post-merge"
        "pre-push"
      ])
      ++ [
        {
          "${gitHooksDir}/commit-msg" = {
            executable = true;
            text = ''
              #!${pkgs.runtimeShell}
              set -eu

              msgFile="$1"

              # vale only finds the global config when XDG_CONFIG_HOME is set; with
              # it unset it reports "no config file found" instead of probing
              # ~/.config, and a hook does not inherit the login shell environment.
              export XDG_CONFIG_HOME="${config.xdg.configHome}"

              # Strip the comment block git appends, and anything below the
              # scissors line, so neither is linted as prose.
              scratch="$(mktemp)"
              trap 'rm -f "$scratch"' EXIT
              ${pkgs.gnused}/bin/sed -e '/^# ------------------------ >8 ------------------------$/,$d' \
                                     -e '/^#/d' "$msgFile" > "$scratch"

              # Lint under the COMMIT_EDITMSG name so the [**/COMMIT_EDITMSG]
              # section applies rather than the markdown one.
              lintDir="$(mktemp -d)"
              trap 'rm -f "$scratch"; rm -rf "$lintDir"' EXIT
              cp "$scratch" "$lintDir/COMMIT_EDITMSG"

              report="$(${pkgs.vale}/bin/vale --output=JSON "$lintDir/COMMIT_EDITMSG" 2>/dev/null || true)"

              # Block only on attribution. The rest of ai-tells-commits is style,
              # and a style rule that can veto a commit turns into --no-verify as a
              # habit, which disables the part that matters here too.
              blocking="$(printf '%s' "$report" | ${pkgs.jq}/bin/jq -r '
                [ .[][] | select(.Check == "ai-tells-commits.CommitAttribution"
                               or .Check == "Local.CommitSessionLink") ]
                | .[] | "  line \(.Line): \(.Match)"
              ' 2>/dev/null || true)"

              if [ -n "$blocking" ]; then
                echo "commit-msg: attribution trailer in the commit message." >&2
                echo "$blocking" >&2
                echo "" >&2
                echo "Remove it and commit again. This is a deliberate setting, not a lint nit." >&2
                exit 1
              fi

              ${dispatch}
              exit 0
            '';
          };
        }
      ]
    );
}
