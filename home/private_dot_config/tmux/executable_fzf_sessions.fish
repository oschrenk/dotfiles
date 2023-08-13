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

function __tmux_create_or_switch_by_entry -a entry
  # destructure selection
  # currently not all fields are used
  set --local selected_source (echo $entry | cut -f 1 )
  set --local selected_search_path (echo $entry | cut -f 2)
  set --local selected_full_path (echo $entry | cut -f 3 )
  set --local display_path (echo $entry | cut -f 4 )
  set --local session_name (echo "$display_path" | tr . - | tr ' ' - | tr ':' - | tr '[:upper:]' '[:lower:]')

  __tmux_create_or_switch_by_name $session_name $session_path
end

function __tmux_create_or_switch_by_name -a session_name session_path
  # create session if it does not exist
  tmux has-session -t="$session_name" &> /dev/null
    or tmux new-session -d -s $session_name -c "$session_path"

  switch (__tmux_context)
    case "attached"
      echo "a"
      tmux switch -t $session_name
    case "detached"
      echo "d"
      tmux attach -t $session_name
    case "serverless"
      echo "s"
      tmux switch-client -t $session_name
    case '*'
      echo "Error: Invalid tmux context" 1>&2
      exit 1
  end
end


# entry format:
#   "$source\t$search_path\t$full_path\t$display_path"
# with
# - $source       [default|git]
# - $search_path  search path that discovered this entry
#   - empty if source is default
#   - set if source is git
# - $session_path full path to initial directory, also used as session_path
# - $display_path relative path to search_path for displaying
function __build_search_entries -a temp_file default_entry search_path
  set --local search_path_length (math (string length $search_path) + 2)

  # store default as first option
  echo -e $default_entry >> $temp_file

  for session_path in (find -L $search_path -type d -name ".git" -maxdepth 3 | rev | cut -c6- | rev | sort);
    set --local source "git"
    set --local display_path (echo $session_path | cut -c$search_path_length-)

    # store as git source
    set --local entry (echo "$source\t$search_path\t$session_path\t$display_path")
    echo -e $entry >> $temp_file
  end
end

###################
# CONFIG
###################
#
set --local default_entry (echo "default\t\t$HOME/Downloads\tdefault")
set --local base_dir $HOME/Projects
set --local temp_file (mktemp)

###################
# LOGIC
###################

# default to `start` sub_command
set sub_command $argv[1]
set -q sub_command; or set sub_command 'start'

switch $sub_command

  # load default profile
  case "init"
    __tmux_create_or_switch_by_entry (echo -e $default_entry)

  # search through available sesssions
  case "search"
    # build entries
    __build_search_entries $temp_file $default_entry $base_dir

    # make selection
    set --local selected_entry (cat $temp_file | fzf --delimiter='\t' --with-nth=4 --info=inline-right)

    # cleanup, TODO create trap for this
    rm -f $temp_file

    # exit early if selection is not valid (eg: user pressed escape)
    if test -z $selected_entry
      exit
    end

    __tmux_create_or_switch_by_entry $selected_entry

  # show detached sessions
  # since status left show always the active session, we just return detached
  case "sessions"
    tmux list-sessions -F "#{session_name}" -f "#{==:#{session_attached},0}" | cut -d "/" -f2 | head -3 | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
  case '*'
    echo "Error: Unknown command `$sub_command`" 1>&2
    exit 1
end

