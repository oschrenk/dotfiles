function evict-icloud --description "Fill disk to force macOS to evict iCloud files"
    set -l buffer_gb 10
    if test (count $argv) -gt 0
        set buffer_gb $argv[1]
    end
    set -l outfile hugefile
    set -l bs (math "15 * 1024 * 1024")

    set -l avail_kb (df -Pk . | awk 'NR==2 {print $4}')
    set -l avail_bytes (math "$avail_kb * 1024")
    set -l buffer_bytes (math "$buffer_gb * 1024 * 1024 * 1024")
    set -l fill_bytes (math "$avail_bytes - $buffer_bytes")

    if test $fill_bytes -le 0
        set -l avail_gb (math -s1 "$avail_bytes / 1024 / 1024 / 1024")
        echo "Only $avail_gb GB free, already below $buffer_gb GB buffer. Nothing to do."
        return 1
    end

    set -l avail_gb (math -s1 "$avail_bytes / 1024 / 1024 / 1024")
    set -l fill_gb (math -s1 "$fill_bytes / 1024 / 1024 / 1024")
    set -l count (math -s0 "$fill_bytes / $bs")

    echo "Free space: $avail_gb GB"
    echo "Will write: $fill_gb GB (leaving $buffer_gb GB free)"
    read -l -P "Continue? [y/N] " confirm
    string match -qi y $confirm; or return 0

    dd if=/dev/zero of=$outfile bs=15m count=$count
    echo "Done. Remove with: rm $outfile"
end
