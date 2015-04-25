function __tilde_help
  echo "Unrecognized command."
  echo ""
  echo "Usage: tilde COMMAND [OPTIONS]"
  echo ""
  echo "Commands:"
  echo ""
  echo " clone <GIT REPO NAME>"
  echo " link <REPO NAME>"
  echo ""
end

function __tilde_ignore_patterns
  set -l tilde_dir $argv[1]i
  # TODO it might be a good idea to merge .tildeignore files from various levels
  # At the moment it only really reads ignores for current directory. Perhaps
  # we should merge with some sort of global ignores and repo ignores
  set -l tilde_ignore_file $tilde_dir/.tildeignore

  if test -e $tilde_ignore_file
    paste -s -d" " (sed '/^[[:space:]]*$/d' $tilde_ignore_file | awk '{print " ! -name \""$0"\""}' | psub)
  else
    return
  end
end

function __tilde_linkable_files
  set -l dir $argv[1]
  set -l default_ignore_patterns '! -name ".git" ! -name ".tilde" ! -name ".tildeignore"'
  set -l dynamic_ignore_patterns (__tilde_ignore_patterns $dir)
  set -l search_patterns "-depth 1 \\( -name '*' $default_ignore_patterns $dynamic_ignore_patterns \\)"

  eval find $dir "$search_patterns"
end


# When are files symlinked?
# 1. dotfiles_home/file_path points to repo_dir/file_path
# 2. parent directories is symlinked and path token is same
function __is_linked
  echo $argv | read -l dotfiles_home tilde_repo_dir file_path_suffix
  if $file_path_suffix = "."
    return 0
  end

  set -l symlink_path $dotfiles_home/$file_path_suffix
  set -l repo_path $repo_dir/$file_path_suffix

  # symlink points to repo
  if readlink $symlink_path = $repo_path
    echo "symlinked"
  else if test -e $symlink_path
    __is_linked $dotfiles_home $repo_dir (dirname $file_path_suffix)
  end
end

function __tilde_meta_tags
  echo $argv | read -l dotfiles_home tilde_repo_dir file_path_suffix

  set -l symlink_path $dotfiles_home/$file_path_suffix
  set -l tilde_path $tilde_repo_dir/$file_path_suffix

  set -l meta_tags ""

  if test -d $tilde_path
    # TODO what are the implications of set without `-l`
    set meta_tags "dir, $meta_tags"
  end

  # TODO it seems that -f also sees symlinks
  # TODO make sure that if symlink to tilde_path its fine
  if test -e $symlink_path -a not test -L $symlink_path
    set meta_tags "conflicts, $meta_tags"
  end

  if not __is_linked $dotfiles_home $tilde_repo_dir $file_path_suffix
    set meta_tags "unlinked, $meta_tags"
  end

  echo "[ $meta_tags ]"
end

function __tilde_ls
  echo $argv | read -l dotfiles_home tilde_home tilde_rel_dir
  set -l tilde_abs_dir $tilde_home/$tilde_rel_dir

  if not test -d $tilde_abs_dir
    echo "Error: directory $tilde_abs_dir not found"
    return
  end

  set -l repo_rel_dir (echo $tilde_rel_dir | awk -F "/" '{$1="";print $0}' OFS='/' | cut -c 2-)
  set -l dotfiles_home $dotfiles_home/$repo_rel_dir

  echo "dotfiles_home $dotfiles_home"
  echo "tilde_home    $tilde_home"
  echo "tilde_rel_dir $tilde_rel_dir"
  echo "repo_rel_dir  $repo_rel_dir"
  echo "dotfiles_home $dotfiles_home"

  for tilde_path in (__tilde_linkable_files $tilde_abs_dir)
    set -l name (basename $tilde_path)
    set -l symlink_path $dotfiles_home$name

    #echo $name (__tilde_meta_tags $symlink_path $tilde_path)
  end
end

function __tilde_clone
  echo $argv | read -l tilde_home original_repo_name local_repo_name

  if test -z $local_repo_name
    set local_repo_name (basename $original_repo_name)
  end

  set -l repo_url "git@github.com:$original_repo_name.git"
  git clone $repo_url $tilde_home/$local_repo_name
end

function __tilde_link
  echo $argv | read -l dotfiles_home tilde_home repo_name

  set -l tilde_repo $tilde_home/$repo_name

  if not test -d $tilde_repo
    echo "No $tilde_repo directory found. Exiting."
    return
  end

  echo "Syncing $tilde_repo with $dotfiles_home"
  echo ""

  for file in (__tilde_linkable_files $tilde_repo)
    set -l base_name (basename $file)
    set -l source_path $file
    set -l target_path $dotfiles_home/$base_name

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

function tilde --description  "node-deja implemented in fish"

  # tilde default settings
  # ----------------------------------------
  # make sure dotfiles_home doesn't end in /
  set -l dotfiles_home (dirname $HOME/.)
  # until production ready,reuse $HOME/.deja
  set -l tilde_home $dotfiles_home/.deja

  if not test -d $tilde_home
    echo "No $tilde_home directory found. Exiting."
    # TODO offer to create dir
    return
  end

  if test \( (count $argv) -ge 4 -o  (count $argv) -lt 2 \)
    __tilde_help
    return
  end

  echo $argv | read -l subcommand argument_1 argument_2

  if test -z $argument_1
    __tilde_help
    return
  end

  switch $subcommand
    case "link"
      __tilde_link  $dotfiles_home $tilde_home $argument_1
    case "ls"
      __tilde_ls    $dotfiles_home $tilde_home $argument_1
    case "clone"
      __tilde_clone $tilde_home $argument_1 $argument_2
  end
end
