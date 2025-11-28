#!/bin/sh

# Make symlinks for my dotfiles. Basically a toy version of GNU Stow
# And runs in POSIX shell without needing to install whatever else.



# NOTE Script in progress, no guarantee this works at all

echo "This script not yet finished" >&2
exit 1



dotfiles=$(dirname $(readlink -f -- "$0"))

# first argument should be the target, second is the linkname (this mirrors ln)
makelink() {
    echo "making link with '$1' and '$2'"
    if [ ! -e "${1}" ]; then
        echo "Missing dotfile: $" >&2
    fi
    ln -si "$1" "$2"
}

# (remember to use $HOME as ~ doesn't expand in quotes)

mkdir -p ~/.config/
makelink "$dotfiles/nvim/.config/nvim" "$HOME/.config/nvim2" 

# ... etc.
# mkdir -p ~/.local/bin/
# mkdir -p ~/.local/share/Trash/files/
