#!/usr/bin/env bash
# Refresh the Cadova + Helical reference material bundled in this skill.
# Run manually when upstream ships a new release.
#
#   bash update.sh                       # pins below (Cadova 0.8.1 / Helical 1.0.3)
#   CADOVA_VERSION=main bash update.sh   # track latest instead
#   HELICAL_VERSION=1.0.3 bash update.sh # override individually

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SKILL_DIR"

# Keep these in sync with the versions your projects pin in Package.swift.
CADOVA_VERSION="${CADOVA_VERSION:-0.8.1}"
HELICAL_VERSION="${HELICAL_VERSION:-1.0.3}"

# clone_or_update <repo-url> <dir> <ref>
clone_or_update() {
    local url="$1" dir="$2" ref="$3"
    if [ -d "$dir/.git" ]; then
        git -C "$dir" fetch --depth 1 origin "$ref"
        git -C "$dir" checkout --force FETCH_HEAD
    else
        rm -rf "$dir"
        git clone --depth 1 --branch "$ref" "$url" "$dir" 2>/dev/null \
            || git clone --depth 1 "$url" "$dir"
    fi
}

echo ">> Refreshing Cadova wiki (wiki/cadova)..."
if [ -d "wiki/cadova/.git" ]; then
    git -C wiki/cadova pull --ff-only
else
    rm -rf wiki/cadova
    mkdir -p wiki
    git clone --depth 1 https://github.com/tomasf/Cadova.wiki.git wiki/cadova
fi

echo ">> Refreshing Cadova source ($CADOVA_VERSION) — for DocC comments..."
clone_or_update https://github.com/tomasf/Cadova.git sources/cadova "$CADOVA_VERSION"

# Helical (screw threads, bolts, nuts) has no wiki upstream — source only.
echo ">> Refreshing Helical source ($HELICAL_VERSION)..."
clone_or_update https://github.com/tomasf/Helical.git sources/helical "$HELICAL_VERSION"

echo ">> Extracting Examples wiki page..."
if [ -f wiki/cadova/Examples.md ]; then
    cp wiki/cadova/Examples.md examples.md
    echo "   examples.md updated"
else
    echo "   WARNING: wiki/cadova/Examples.md not found"
fi

echo ">> Snapshot of versions:"
echo "   wiki:    $(git -C wiki/cadova rev-parse --short HEAD)"
echo "   cadova:  $(git -C sources/cadova rev-parse --short HEAD) ($(git -C sources/cadova describe --tags --always 2>/dev/null || echo 'no tag'))"
echo "   helical: $(git -C sources/helical rev-parse --short HEAD) ($(git -C sources/helical describe --tags --always 2>/dev/null || echo 'no tag'))"

echo ">> Done. Reference material is in:"
echo "   - $SKILL_DIR/wiki/cadova/      (Cadova wiki, grep-friendly)"
echo "   - $SKILL_DIR/sources/cadova/   (Cadova source with DocC comments)"
echo "   - $SKILL_DIR/sources/helical/  (Helical source — bolts, threads, nuts)"
echo "   - $SKILL_DIR/examples.md       (Examples page for quick scanning)"
