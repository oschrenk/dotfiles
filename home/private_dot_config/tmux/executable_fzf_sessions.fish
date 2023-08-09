#!/usr/bin/env fish

###################
# FUNCTIONS
###################

# determine current tmux context
#   serverless - no running tmux server
#   attached   - attached to the running tmux server
#   detached   - not attached to the running tmux server
function __tmux_context
  # determine if the tmux server is running
  if tmux list-sessions &>/dev/null
    # if $TMUX is set we are already inside TMUX
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
  tmux list-sessions -F '#{session_last_attached} #{session_name} #{session_path}' | sort --nuiiiumeric-sort --reverse | awk '{print $2,$3}'
end

function __tmux_create_or_switch -a session_name session_path
  # create session if it does not exist
  tmux has-session -t="$session_name" &> /dev/null
    or tmux new-session -d -s $session_name -c "$session_path"

  switch (__tmux_context)
    case "attached"
      tmux switch -t $session_name
    case "detached"
      tmux switch-client -t $session_name
    case "serverless"
      tmux attach -t $session_name
    case '*'
      echo "Error: Invalid tmux context" 1>&2
      exit 1
  end
end

function __build_search_entries -a temp_file default_entry search_path
  set --local search_path_length (math (string length $search_path) + 2)

  # store default as first option
  echo -e $default_entry >> $temp_file

  for repo_path in (find -L $search_path -type d -name ".git" -maxdepth 3 | rev | cut -c6- | rev | sort);
    set --local source "git"
    set --local display_path (echo $repo_path | cut -c$search_path_length-)

    # store as git source
    set --local entry (echo "$source\t$search_path\t$full_path\t$display_path")
    echo -e $entry >> $temp_file
  end
end

###################
# CONFIG
###################
set --local default_entry (echo "default\t\t$HOME/Downloads\tdefault")
set --local base_dir $HOME/Projects
set --local temp_file (mktemp)

###################
# LOGIC
###################

# build entries
__build_search_entries $temp_file $default_entry $base_dir

# make selection
set --local selection (cat $temp_file | fzf --delimiter='\t' --with-nth=4)

# cleanup
# TODO create trap for this
rm -f $temp_file

# exit early if selection is not valid (eg: user pressed escape)
if test -z $selection
  exit
end

# destructure selection
set --local selected_source (echo $selection | cut -f 1 )
set --local selected_search_path (echo $selection | cut -f 2)
set --local selected_full_path (echo $selection | cut -f 3 )
set --local display_path (echo $selection | cut -f 4 )
set --local session_name (echo "$display_path" | tr . - | tr ' ' - | tr ':' - | tr '[:upper:]' '[:lower:]')

# create session
__tmux_create_or_switch $session_name $selected_full_path
