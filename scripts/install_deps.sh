#!/bin/bash

deps=(
    "nvim-lua/plenary.nvim plenary.nvim"
    "nvim-neotest/neotest neotest"
    "nvim-neotest/nvim-nio nvim-nio"
    "nvim-treesitter/nvim-treesitter nvim-treesitter"
)

log() {
    echo $1 >&2
}

fail() {
    local msg="${1:-Unknown error occurred}"

    log "An error occurred during dependencies installation, rolling back"
    log message

    for entry in "${deps[@]}"; do
        read -r repo target <<<"$entry"

        if [ -d "$target" ]; then
            log "Removing $repo directory $target"
            rm -rf "$target"
        fi
    done

    exit 1
}

trap 'fail "Error on line $LINENO: $BASH_COMMAND"' ERR

get_tarball_url() {
    local repo="$1"
    local tarball_url

    local release_url="https://api.github.com/repos/${repo}/releases/latest"
    local tag_url="https://api.github.com/repos/${repo}/tags"

    tarball_url=$(curl -fsSL "$release_url" | grep '"tarball_url":' | cut -d '"' -f4)

    if [ -z "${tarball_url:-}" ]; then
        log "Release not found in $release_url"
        log "Trying to fetch tarball URL from $tag_url"

        tarball_url=$(curl -fsSL "$tag_url" | grep '"tarball_url":' | head -n1 | cut -d '"' -f4)
    fi

    if [ -z "${tarball_url:-}" ]; then
        fail "Failed to find tarball URL for $repo"
    fi

    echo "$tarball_url"
}

for entry in "${deps[@]}"; do
    read -r repo target <<<"$entry"

    if [ -d "$target" ]; then
        echo "$target is already installed, skipping..."
        continue
    fi

    mkdir -p "$target"

    tarball_url=$(get_tarball_url "$repo")
    tarball_tmp=$(mktemp)

    echo "Downloading $target from $tarball_url"

    curl -fsSL "$tarball_url" -o "$tarball_tmp" || fail "Failed to download $repo"
    tar -xzf "$tarball_tmp" --strip-components=1 -C "$target" || fail "Failed to unpack $repo"

    rm -f "$tarball_tmp"

    echo "Done! Installed $repo to $target"
done
