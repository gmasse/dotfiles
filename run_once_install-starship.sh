#!/bin/sh

if ! command -v starship >/dev/null 2>&1; then
    mkdir -p ~/.local/bin
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
fi

