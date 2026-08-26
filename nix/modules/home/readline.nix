# readline — key bindings and completion behaviour for anything linked against
# it (bash, python's REPL, psql).
# Migrated from chezmoi (home/private_dot_config/readline/).
{ ... }:
{
  # Not programs.readline: that module writes ~/.inputrc or ~/.config/inputrc,
  # and fish exports INPUTRC pointing at this path instead. It would also mean
  # splitting the file into bindings and variables attrsets, which would drop
  # the comments explaining what each escape sequence is for.
  xdg.configFile."readline/inputrc".source = ./readline/inputrc;
}
