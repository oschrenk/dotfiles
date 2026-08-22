{ pkgs, ... }:
{
  home.packages = [ pkgs.rumdl ];

  # Global defaults, found at ~/.config/rumdl/rumdl.toml without needing
  # XDG_CONFIG_HOME set. A project's own .rumdl.toml wins over this file, and
  # `rumdl config get` labels which one it used, so a repo with house rules is
  # unaffected by anything here.
  xdg.configFile."rumdl/rumdl.toml".text = ''
    # Markdown linting via https://rumdl.dev
    #
    # A [RULE] section appears below only where a setting is actually changed.
    # Rules that are simply switched on, with nothing to configure, are noted in
    # the extend-enable list and have no section.

    [global]

    # Optional rules, off by default, switched on here:
    extend-enable = [
      # MD063 headings use title case (configured below)
      "MD063",
      # MD082 a heading must have content before next (configured below)
      "MD082",
      # MD084 disable invisible and discouraged Unicode characters
      "MD084",
      # MD085 paragraph continuation lines are not indented
      "MD085",
      # MD088 use ASCII quotes and dashes (configured below)
      "MD088",
    ]

    # On by default, switched off here:
    extend-disable = [
      # MD013 max line length. Omitting it would not remove the rule, only
      # leave it at its 80-column default, which is stricter than anything
      # written here. Off until there is a wrapping style worth enforcing.
      "MD013",
    ]

    # On by default, nothing to configure, so no sections below:
    #
    #   MD011 https://rumdl.dev/md011/ reversed link syntax. Catches (text)[url]
    #   written the wrong way round, which renders as literal text rather than a
    #   link, so it is easy to miss in review. `fmt` swaps it back.
    #
    #   MD047 https://rumdl.dev/md047/ file ends with exactly one newline. A missing
    #   one makes the last line show as changed in every diff that touches it.

    # MD004 - unordered list marker style.
    # https://rumdl.dev/md004/
    [MD004]

    # Always `-`, at every nesting depth. "consistent" would only require a file to
    # agree with its own first marker, so a document written entirely in `*` would
    # pass; this makes the marker the same everywhere.
    style = "dash"

    # MD051 - link fragments must reference a real heading.
    # https://rumdl.dev/md051/
    [MD051]

    # Anchor slugs are generated the way GitHub generates them, which is where
    # these documents are read. Alternatives ("jekyll", "kramdown", "mkdocs",
    # "python-markdown") slugify differently and would report working links as
    # broken.
    #
    # Worth having because there is no autofix: a mistyped `[jump](#firts-apply)`
    # renders as a link that quietly goes nowhere, and nothing about it looks wrong
    # in review. The rule is the only thing that catches it.
    anchor-style = "github"

    # MD029 - ordered list numbering.
    # https://rumdl.dev/md029/
    [MD029]

    # Number the items 1. 2. 3. rather than the lazy 1. 1. 1. that Markdown also
    # renders correctly. The source then reads the way the output does, and a step
    # referred to as "step 4" can be found by looking for a 4.
    #
    # Caveat: verified inert in rumdl 0.2.58 — the rule produces no findings under
    # any style, including for a list numbered 3. 7. 9., and `fmt` does not
    # renumber. Kept so the intent is recorded and takes effect if the rule is
    # fixed upstream. Other styles: "one", "one-or-ordered" (default),
    # "ordered0", "consistent".
    style = "ordered"

    # MD063 - headings use title case
    # https://rumdl.dev/md063/
    [MD063]
    style = "title-case"

    # Empty on purpose. An identifier in a heading belongs in backticks, which is
    # correct Markdown regardless of rumdl and which MD063 skips entirely, so a
    # wordlist here would be a second place to maintain the same knowledge.
    ignore-words = []

    # A word that already contains capitals is a deliberate spelling, so leave it
    # alone. Covers identifiers like `data.db` and `INTEGER PRIMARY KEY` without
    # having to list every one.
    preserve-cased-words = true

    # MD082 - a heading must have content before the next.
    # https://rumdl.dev/md082/
    [MD082]
    level = 1

    # A parent heading followed straight by its first subheading is a normal shape.
    # Two headings at the same level with nothing between them is the mistake worth
    # catching — it is what a removed section leaves behind.
    allow-parent-headings = true

    # MD088 - ASCII quotes and dashes.
    # https://rumdl.dev/md088/
    [MD088]

    # Quotes are normalized: a curly quote pasted from a web page looks identical
    # to a straight one and is invisible in review.
    normalize-quotes = true

    # Dashes are not, because rewriting them would change prose rather than tidy
    # it. Whether an em dash belongs in the sentence at all is vale's call.
    normalize-dashes = false
  '';
}
