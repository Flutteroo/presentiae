#!/bin/bash
set -e

increment_version() {
    local version_file="pubspec.yaml"
    local current_version=$(grep '^version:' "$version_file" | awk '{print $2}')
    IFS='.' read -ra version_parts <<< "$current_version"
    local major=${version_parts[0]}
    local minor=${version_parts[1]}
    local maintenance=${version_parts[2]}
    maintenance=$((maintenance + 1))
    if ((maintenance > 42)); then
        maintenance=0
        minor=$((minor + 1))
        if ((minor > 42)); then
            minor=0
            major=$((major + 1))
        fi
    fi
    local new_version="$major.$minor.$maintenance"
    # replace in pubspec.yaml
    sed -i.bak "s/^version: .*/version: $new_version/" "$version_file"
    echo "$new_version"
}

if [[ $# -lt 1 ]]; then
    echo "Error: Provide a commit message"
    exit 1
fi
git add .
git rev-parse --short HEAD > ./REVISION
MSG=$1

# bump version
VERSION=$(increment_version)

# timestamp
TS=$(date +"%Y-%m-%d %H:%M:%S")

# changed files
CHANGED=$(git diff --cached --name-only)

# commit sha
SHA=$(cat ./REVISION)

# commit title = first line of msg
TITLE=$(echo "$MSG" | head -n1)

# update changelog
cat <<EOF >> CHANGELOG.md

## $VERSION, $TITLE, $TS, $SHA
$CHANGED
EOF

git add CHANGELOG.md
git commit -am "${MSG} (${VERSION})"

echo "Read CHANGELOG.md and annotate the changes of the last commit in a technical way, using markdown, but only highlighting the geeky and engineeringly interesting stuff! Only reference the files that are listed in the latest block! Update the changelog with your contribution! <3"