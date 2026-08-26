# Claude Code configuration, for both profiles.
# Migrated from chezmoi (home/private_dot_config/claude/).
{ config, osConfig, lib, ... }:
let
  dotfiles = osConfig.my.personal.dotfiles;

  # One symlink per managed entry, never one for the profile directory. Claude
  # Code keeps its state in the same directory: sessions, projects, plans,
  # history.jsonl, caches and more, none of which belongs in a repository.
  # Naming what is wanted is also what replaces the .chezmoiignore files this
  # tree used to need, which had grown to twenty lines.
  link =
    profile: entries:
    lib.listToAttrs (
      map (entry: {
        name = ".config/claude/${profile}/${entry}";
        value.source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/claude/${profile}/${entry}";
      }) entries
    );
in
{
  # The two profiles do not hold the same things, so they get their own lists
  # rather than one list applied twice.
  home.file =
    link "personal" [
      "CLAUDE.md"
      "commands"
      "keybindings.json"
      "settings.json"
      "skills"
    ]
    // link "work" [
      ".envrc"
      "CLAUDE.md"
      "keybindings.json"
      "policy-limits.json"
      "remote-settings.json"
      "settings.json"
      "skills"
    ];

  # Every tree deployed this way points at the working copy, so a wrong or
  # missing clone leaves dangling symlinks rather than an error: neovim would
  # start with no config and Claude Code with no skills, both silently. Fail the
  # activation instead.
  home.activation.checkDotfilesPath = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    if [ ! -d "${dotfiles}/config" ]; then
      echo "my.personal.dotfiles is ${dotfiles}, which has no config/ directory." >&2
      echo "Clone the repository there, or correct the value in nix/identity.nix." >&2
      exit 1
    fi
  '';
}
