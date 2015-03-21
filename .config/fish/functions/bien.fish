function __bien_help
  echo "Unrecognized command."
end

function __bien_ignore_patterns
  set -l repo $argv[1]
  set -l ignore_file $repo/.bienignore

  if test -e $ignore_file
    paste -s -d" " (sed '/^[[:space:]]*$/d' $repo/.bienignore | awk '{print " ! -name \""$0"\""}' | psub)
  else
    ""
  end
end

function __bien_linkable_files
  set -l repo $argv[1]
  set -l ignore_patterns (__bien_ignore_patterns $repo)
  set -l search_patterns "\\( -name '*'$ignore_patterns \\)"

  eval find $repo -depth 1 "$search_patterns" | grep -v ".bienignore"
end

function __bien_link
  set -l repo $HOME/.bien/$argv[1]

  if not test -d $repo
    echo "No $repo directory found. Exiting."
    return
  end

  set -l symlink_dir $HOME/test
  echo "Syncing $repo with $symlink_dir"

  for file in (__bien_linkable_files $repo)
    set -l base_name (basename $file)
    set -l source_path $file
    set -l target_path $symlink_dir/$base_name

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

function bien --description  "deja in fish"
  if not test -d $HOME/.bien/
    echo "No ~/.bien/ directory found. Exiting."
    return
  end

  if test (count $argv) -ne 2
    __bien_help
    return
  end

  set -l subcommand $argv[1]

  if [ "$subcommand" = "link" ]
    __bien_link $argv[2]
  end
end
