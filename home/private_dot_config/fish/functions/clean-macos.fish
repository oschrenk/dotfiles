function clean-macos -d "Clean macOS caches and unused data"
    echo "🧹 Cleaning macOS..."

    # Docker
    if command -q docker
        set -l reclaimable (docker system df --format '{{.Reclaimable}}' 2>/dev/null)
        set -l has_space false
        for r in $reclaimable
            if not string match -q '0B*' "$r"
                set has_space true
                break
            end
        end
        if test "$has_space" = true
            printf "\n--- Docker ---\n"
            echo "Docker reclaimable space:"
            docker system df
            echo
            read -l -P "Run docker system prune -a? [y/N] " confirm; or return 1
            if test "$confirm" = y
                docker system prune -a -f
            else
                echo "  Skipped."
            end
        end
    end

    # Homebrew
    if command -q brew
        set -l brew_cache (brew --cache)
        if test -d "$brew_cache"
            set -l size (du -sh "$brew_cache" 2>/dev/null | awk '{print $1}')
            if test "$size" != 0B
                printf "\n--- Homebrew ---\n"
                echo "Homebrew cache: $size"
                read -l -P "Run brew cleanup and delete download cache? [y/N] " confirm; or return 1
                if test "$confirm" = y
                    brew cleanup -s
                    test -d "$brew_cache/downloads"; and rm -rf "$brew_cache/downloads"
                    echo "  Deleted."
                else
                    echo "  Skipped."
                end
            end
        end

        # Caskroom .pkg installers
        set -l caskroom (brew --prefix)/Caskroom
        if test -d "$caskroom"
            for pkg in (find "$caskroom" -type f -name '*.pkg' 2>/dev/null)
                _clean_confirm_file "$pkg" "Cask installer: "(basename "$pkg")
                or return 1
            end
        end
    end

    # Yarn
    if command -q yarn
        printf "\n--- Yarn ---\n"
        yarn cache clean
    end

    # Global npm modules
    if command -q npm
        printf "\n--- npm global modules ---\n"
        npm ls -gp --depth=0 | awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}' | xargs npm -g rm
    end

    # IINA thumb cache
    _clean_confirm ~/Library/Caches/com.colliderli.iina/thumb_cache "IINA thumb cache"; or return 1

    # JetBrains caches
    _clean_confirm ~/Library/Caches/JetBrains "JetBrains caches"; or return 1

    # Coursier caches
    _clean_confirm ~/Library/Caches/Coursier/v1 "Coursier v1 cache"; or return 1
    _clean_confirm ~/.coursier/cache "Coursier legacy cache"; or return 1

    # Minikube
    if command -q minikube; and test -d ~/.minikube
        printf "\n--- Minikube ---\n"
        read -l -P "Delete minikube cluster and cache? [y/N] " confirm; or return 1
        if test "$confirm" = y
            minikube delete
            rm -rf ~/.minikube/cache
        end
    end

    # Xcode simulator caches and devices
    _clean_confirm ~/Library/Developer/CoreSimulator/Caches "Xcode simulator caches"; or return 1
    _clean_confirm ~/Library/Developer/CoreSimulator/Devices "Xcode simulator devices"; or return 1

    # Android SDK
    _clean_confirm ~/Library/Android/sdk "Android SDK"; or return 1

    # Go module cache
    if command -q go
        set -l gomod ~/Frameworks/go/pkg/mod
        if test -d "$gomod"
            set -l size (du -sh "$gomod" 2>/dev/null | awk '{print $1}')
            if test "$size" != 0B
                read -l -P "Clean Go module cache ($size)? [y/N] " confirm; or return 1
                if test "$confirm" = y
                    go clean -modcache
                    echo "  Deleted."
                else
                    echo "  Skipped."
                end
            end
        end
    end

    # Gradle cache
    _clean_confirm ~/.gradle "Gradle cache"; or return 1

    # npm cache
    _clean_confirm ~/.npm "npm cache"; or return 1

    # XDG cache (~/.cache) per-directory
    if test -d ~/.cache
        for dir in ~/.cache/*/
            set -l name (basename "$dir")
            _clean_confirm "$dir" "cache: $name"; or return 1
        end
    end

    # Expo cache
    _clean_confirm ~/.expo "Expo cache"; or return 1

    # Cargo registry
    _clean_confirm ~/.local/share/cargo/registry "Cargo registry cache"; or return 1

    # Old JetBrains configs (per-version)
    set -l jb_base ~/Library/Application\ Support/JetBrains
    if test -d "$jb_base"
        for dir in "$jb_base"/*/
            set -l name (basename "$dir")
            _clean_confirm "$dir" "JetBrains config: $name"; or return 1
        end
    end

    # Arc browser cache
    _clean_confirm ~/Library/Caches/Arc/User\ Data "Arc browser cache"; or return 1

    # App logs (top 5 by size)
    if test -d ~/Library/Logs
        for dir in (du -sh ~/Library/Logs/*/ 2>/dev/null | sort -rh | head -5 | awk '{print $2}')
            set -l name (basename "$dir")
            _clean_confirm "$dir" "Logs: $name"; or return 1
        end
    end

    printf "\n✅ Done!\n"
end

function _clean_confirm_file -a path label
    if test -f "$path"
        set -l size (du -sh "$path" 2>/dev/null | awk '{print $1}')
        if test "$size" = 0B
            return 0
        end
        read -l -P "Delete $label ($size)? [y/N] " confirm
        or return 1
        if test "$confirm" = y
            rm -f "$path"
            echo "  Deleted."
        else
            echo "  Skipped."
        end
    end
end

function _clean_confirm -a path label
    if test -d "$path"
        set -l size (du -sh "$path" 2>/dev/null | awk '{print $1}')
        if test "$size" = 0B
            return 0
        end
        read -l -P "Delete $label ($size)? [y/N] " confirm
        or return 1
        if test "$confirm" = y
            rm -rf "$path"
            echo "  Deleted."
        else
            echo "  Skipped."
        end
    end
end
