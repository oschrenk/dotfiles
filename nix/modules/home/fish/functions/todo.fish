function todo --description "List the open tasks in the repo's tasks/ directory"
    set -l root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$root"
        echo "todo: not in a git repository" >&2
        return 1
    end

    set -l dir $root/tasks
    if not test -d $dir
        echo "todo: no tasks/ in $root" >&2
        return 1
    end

    set -l rows
    for file in $dir/*.md
        mdq -q '+++ /state: (todo|in-progress)/' $file; or continue

        set -l rank (mdq -o plain '+++' $file | sed -n 's/^rank: //p')
        test -z "$rank"; and set rank 999999999

        set -l title (mdq -o plain '#' $file | awk 'NR==1')
        test -z "$title"; and set title (path basename $file .md)

        set -a rows (printf '%s\t%s' $rank $title)
    end

    if test (count $rows) -eq 0
        echo "todo: no open tasks in $dir" >&2
        return 1
    end

    set -l open (printf '%s\n' $rows | sort -n | cut -f2-)

    switch "$argv[1]"
        case ''
            printf '%s\n' $open
        case next
            echo $open[1]
        case '*'
            echo "todo: unknown argument: $argv[1]" >&2
            return 1
    end
end
