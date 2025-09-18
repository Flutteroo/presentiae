#!/bin/bash
set -e

read_version() {
    local version_file="pubspec.yaml"
    local current_version=$(grep '^version:' "$version_file" | awk '{print $2}')
    echo "$current_version"
}

VERSION=$(read_version)

if [[ -z "$VERSION" ]]; then
    echo "ERROR: could not read version from pubspec.yaml"
    exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

echo "Preparing release commit for version ${VERSION} on branch ${BRANCH}"

if git diff --quiet -- CHANGELOG.md && git diff --cached --quiet -- CHANGELOG.md; then
    echo "No changes in CHANGELOG.md to commit. Skipping commit."
    exit 0
fi

git add CHANGELOG.md
git commit -m "engineering notes (${VERSION})"
git push origin "$BRANCH"