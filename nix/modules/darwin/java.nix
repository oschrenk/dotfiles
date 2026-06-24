{ ... }:

# Register keg-only Homebrew JDKs with macOS so /usr/libexec/java_home finds
# them. Homebrew installs openjdk@NN keg-only and only prints a caveat with a
# manual `sudo ln`; nix-darwin can never run that on its own, so a fresh machine
# has the JDK installed but unregistered and java_home throws "no Java runtime".
# This does the symlink reproducibly on every activation (runs as root).
#
# Guarded on the source existing: on first bootstrap the JDK may not be brew-
# installed yet, in which case the link is created on the next rebuild.
{
  system.activationScripts.registerJdks.text = ''
    for v in 17 21; do
      src="/opt/homebrew/opt/openjdk@$v/libexec/openjdk.jdk"
      dst="/Library/Java/JavaVirtualMachines/openjdk-$v.jdk"
      if [ -d "$src" ]; then
        mkdir -p /Library/Java/JavaVirtualMachines
        ln -sfn "$src" "$dst"
      fi
    done
  '';
}
