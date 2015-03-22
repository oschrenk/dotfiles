function __tilde_help
  echo "Unrecognized command."
end

function __tilde_ignore_patterns
  set -l tilde_repo $argv[1]
  set -l tilde_ignore_file $tilde_repo/.tildeignore

  if test -e $ignore_file
    paste -s -d" " (sed '/^[[:space:]]*$/d' $tilde_ignore_file | awk '{print " ! -name \""$0"\""}' | psub)
  else
    return
  end
end

function __tilde_linkable_files
  set -l tilde_repo $argv[1]
  set -l default_ignore_patterns '! -name ".git" ! -name ".tilde" ! -name ".tildeignore"'
  set -l dynamic_ignore_patterns (__tilde_ignore_patterns $tilde_repo)
  set -l search_patterns "-depth 1 \\( -name '*' $default_ignore_patterns $dynamic_ignore_patterns \\)"

  eval find $tilde_repo "$search_patterns"
end

function __tilde_link
  set -l symlink_dir $HOME
  set -l tilde_home $HOME/.tilde
  set -l tilde_repo $tilde_home/$argv[1]

  if not test -d $tilde_repo
    echo "No $tilde_repo directory found. Exiting."
    return
  end

  echo "Syncing $tilde_repo with $symlink_dir"
  echo ""

  for file in (__tilde_linkable_files $tilde_repo)
    set -l base_name (basename $file)
    set -l source_path $file
    set -l target_path $symlink_dir/$base_name

    # TODO test if trying to symlink .tilde
    if test -L $target_path
      echo "Skipped $source_path: Already exists as symbolic link"
    else if test -f $target_path
      echo "Skipped $source_path: Already exists as regular file"
    else
      echo "Symlinking $target_path to $source_path"
      ln -s $source_path $target_path
    end
  end
end

function tilde --description  "deja in fish"
  set -l tilde_home $HOME/.tilde
  if not test -d $tilde_home
    echo "No $tilde_home directory found. Exiting."
    return
  end

  if test (count $argv) -ne 2
    __tilde_help
    return
  end

  set -l subcommand $argv[1]

  if [ "$subcommand" = "link" ]
    __tilde_link $argv[2]
  end
end
