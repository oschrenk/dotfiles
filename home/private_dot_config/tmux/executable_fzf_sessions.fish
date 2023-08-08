#!/usr/bin/env fish

# determine current tmux context
#   serverless - no running tmux server
#   attached   - attached to the running tmux server
#   detached   - not attached to the running tmux server
function __tmux_context
  # determine if the tmux server is running
  if tmux list-sessions &>/dev/null
	  if test -n "$TMUX" # inside tmux
		  echo "attached"
	  else # outside tmux
	    echo "detached"
    end
  else
      echo "serverless"
  end
end

# list current tmux sessions ordered by most recently uses
# returns `#{session_name} #{session_path}`
function __tmux_sessions_mru
  tmux list-sessions -F '#{session_last_attached} #{session_name} #{session_path}' | sort --numeric-sort --reverse | awk '{print $2,$3}'
end

#echo (__tmux_sessions_mru)

set --local temp_file (mktemp)

set --local default (echo "default\t\t$HOME/Downloads\tdefault")
  echo -e $default >> $temp_file

set -l base_dir $HOME/Projects
set -l length (math (string length $base_dir) + 2)

for repo in (find -L $base_dir -type d -name ".git" -maxdepth 3 | rev | cut -c6- | rev | sort);
  set --local source "git"
  set --local search_path $base_dir
  set --local full_path $repo
  set --local display_path (echo $full_path | cut -c$length-)

  set --local entry (echo "$source\t$search_path\t$full_path\t$display_path")
  echo -e $entry >> $temp_file
end

set --local selection (cat $temp_file | fzf --delimiter='\t' --with-nth=4)
rm -f $temp_file

if test -z $selection
  exit
end

set --local selected_source (echo $selection | cut -f 1 )
set --local selected_search_path (echo $selection | cut -f 2)
set --local selected_full_path (echo $selection | cut -f 3 )
set --local display_path (echo $selection | cut -f 4 )
set --local session_name (echo "$display_path" | tr . - | tr ' ' - | tr ':' - | tr '[:upper:]' '[:lower:]')

if not test (tmux has-session -t=$session_name &> /dev/null)
  tmux new-session -d -s $session_name -c "$selected_full_path"
end

if test -n "$TMUX" # inside tmux
  echo "inside"
  tmux switch -t $session_name
 else # outside tmux
  echo "outside"
  tmux switch-client -t $session_name
end

