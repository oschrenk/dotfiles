# null:// is deliberate: it always reports a value as missing, satisfying
# secretspec's "a default provider must exist" rule while leaving each secret to
# resolve through its own providers. A real vault here would answer silently for
# a secret that declared none.
#
# package = null: secretspec is pinned per project in that project's devShell.
{ ... }:
{
  programs.secretspec = {
    enable = true;
    package = null;
    settings.defaults.provider = "null://";
  };
}
