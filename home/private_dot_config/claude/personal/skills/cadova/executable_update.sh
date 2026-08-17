#!/usr/bin/env bash
# Refresh the Cadova + Helical reference material bundled in this skill.
# Run manually when upstream ships a new release.
#
#   bash update.sh                       # pins below (Cadova 0.9.1 / Helical 1.0.4)
#   CADOVA_VERSION=main bash update.sh   # track latest instead
#   HELICAL_VERSION=1.0.3 bash update.sh # override individually
#
# Upstream moved its documentation out of the GitHub wiki and into a DocC
# catalog that ships inside the repo (Sources/Cadova/Cadova.docc). The wiki is
# now a single stub page, so this script no longer clones it — it copies the
# DocC articles out of the source checkout instead. They are already markdown.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SKILL_DIR"

# Keep these in sync with the versions your projects pin in Package.swift.
CADOVA_VERSION="${CADOVA_VERSION:-0.9.1}"
HELICAL_VERSION="${HELICAL_VERSION:-1.0.4}"

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

echo ">> Refreshing Cadova source ($CADOVA_VERSION)..."
clone_or_update https://github.com/tomasf/Cadova.git sources/cadova "$CADOVA_VERSION"

# Helical (screw threads, bolts, nuts) has no prose docs upstream — source only.
echo ">> Refreshing Helical source ($HELICAL_VERSION)..."
clone_or_update https://github.com/tomasf/Helical.git sources/helical "$HELICAL_VERSION"

echo ">> Extracting DocC articles to docs/..."
DOCC="sources/cadova/Sources/Cadova/Cadova.docc"
if [ -d "$DOCC" ]; then
    rm -rf docs
    mkdir -p docs
    cp "$DOCC"/*.md docs/
    # The style guide is repo-root, not part of the catalog, but it explains the
    # idioms the API expects you to write in.
    [ -f sources/cadova/CadovaStyleGuide.md ] && cp sources/cadova/CadovaStyleGuide.md docs/
    echo "   $(ls docs/*.md | wc -l | tr -d ' ') markdown files in docs/"
else
    echo "   ERROR: $DOCC not found — did the catalog move again?" >&2
    exit 1
fi

# Remove material from the old wiki-based layout, if a previous run left it.
rm -rf wiki examples.md

echo ">> Snapshot of versions:"
echo "   cadova:  $(git -C sources/cadova rev-parse --short HEAD) ($(git -C sources/cadova describe --tags --always 2>/dev/null || echo 'no tag'))"
echo "   helical: $(git -C sources/helical rev-parse --short HEAD) ($(git -C sources/helical describe --tags --always 2>/dev/null || echo 'no tag'))"

echo ">> Done. Reference material is in:"
echo "   - $SKILL_DIR/docs/             (Cadova guides, markdown — read these first)"
echo "   - $SKILL_DIR/sources/cadova/   (Cadova source with DocC comments — authoritative API)"
echo "   - $SKILL_DIR/sources/helical/  (Helical source — bolts, threads, nuts)"
