#!/usr/bin/env bash
# Refresh Cadova reference material bundled in this skill.
# Run manually when Cadova upstream ships a new release.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SKILL_DIR"

CADOVA_VERSION="${CADOVA_VERSION:-main}"

echo ">> Refreshing Cadova wiki..."
if [ -d "wiki/.git" ]; then
    git -C wiki pull --ff-only
else
    rm -rf wiki
    git clone --depth 1 https://github.com/tomasf/Cadova.wiki.git wiki
fi

echo ">> Refreshing Cadova source (for DocC comments)..."
if [ -d "source/.git" ]; then
    git -C source fetch --depth 1 origin "$CADOVA_VERSION"
    git -C source checkout "$CADOVA_VERSION"
else
    rm -rf source
    git clone --depth 1 --branch "$CADOVA_VERSION" https://github.com/tomasf/Cadova.git source 2>/dev/null \
        || git clone --depth 1 https://github.com/tomasf/Cadova.git source
fi

echo ">> Extracting Examples wiki page..."
if [ -f wiki/Examples.md ]; then
    cp wiki/Examples.md examples.md
    echo "   examples.md updated"
else
    echo "   WARNING: wiki/Examples.md not found"
fi

echo ">> Snapshot of versions:"
echo "   wiki:   $(git -C wiki rev-parse --short HEAD)"
echo "   source: $(git -C source rev-parse --short HEAD) ($(git -C source describe --tags --always 2>/dev/null || echo 'no tag'))"

echo ">> Done. Reference material is in:"
echo "   - $SKILL_DIR/wiki/         (full wiki, grep-friendly)"
echo "   - $SKILL_DIR/source/       (Cadova source with DocC comments)"
echo "   - $SKILL_DIR/examples.md   (Examples page for quick scanning)"
