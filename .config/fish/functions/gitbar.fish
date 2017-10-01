function gitbar --description  "return git status of frontmost pane"

  function git_ahead
    set -l ahead (echo \u2191)
    set -l behind (echo \u2193)
    set -l diverged (echo \u2191\u2193)
    command git rev-list --count --left-right "@{upstream}...HEAD" ^ /dev/null | command awk "
        /0\t0/          { print \"$none\"       ? \"$none\"     : \"\";    exit 0 }
        /[0-9]+\t0/     { print \"$behind\"     ? \"$behind\"   : \"-\";    exit 0 }
        /0\t[0-9]+/     { print \"$ahead\"      ? \"$ahead\"    : \"+\";    exit 0 }
        //              { print \"$diverged\"   ? \"$diverged\" : \"±\";    exit 0 }
    "
  end

  function git_is_dirty -d "Test if there are changes not staged for commit"
    if command git diff --no-ext-diff --quiet --exit-code ^ /dev/null
      return 1
    end

    git_is_repo
  end

  function git_branch_name -d "Get the name of the current Git branch, tag or sha1"
    set -l branch_name (command git symbolic-ref --short HEAD ^/dev/null)

    if test -z "$branch_name"
      set -l tag_name (command git describe --tags --exact-match HEAD ^ /dev/null)

      if test -z "$tag_name"
        command git rev-parse --short HEAD ^ /dev/null
      else
        printf "%s\n" "$tag_name"
      end
    else
      printf "%s\n" "$branch_name"
    end
  end

function git_is_touched -d "Test if there are any changes in the working tree"
    if not git_is_repo
        return 1
    end

    command git status --porcelain ^ /dev/null | command awk '
        // {
            z++
            exit 0
        }
        END {
            exit !z
        }
    '
end

function git_is_repo -d "Test if the current directory is a Git repository"
    if not command git rev-parse --git-dir > /dev/null ^ /dev/null
        return 1
    end
end


  set -l pane_pid (tmux list-panes -F '#{pane_active} #{pane_pid}' | grep "^1" | awk '{print $2}')
  set -l pane_dir (lsof -a -p $pane_pid | head -2 | tail -n +2 | awk '{print $9}')
  cd $pane_dir

  if set branch_name (git_branch_name)
    set -l project (git rev-parse --show-toplevel | rev | cut -d '/' -f 1 | rev)
    if git_is_touched
      set git_dirty ±
    end
    echo $project\u2325 $branch_name $git_ahead $git_dirty
else
    set -l project (pwd | rev | cut -d '/' -f 1 | rev)
    echo $project
  end

end
