function journal-template --description "Create a template for journal entries"
  set -l template_dir "$HOME/.config/journal"

  function __template
    echo $argv | read -l weekday
    if test -z "$weekday"
      echo "unknown"
    else
      # re-parse for validation
      string lower (gdate --date="$weekday" "+%A")
    end
  end
  set -l template (__template $argv[1])
  set -l template_path "$template_dir/$template.md"
  if test -e $template_path
    cat $template_path
  else
    cat "$template_dir/generic.md"
  end
end
