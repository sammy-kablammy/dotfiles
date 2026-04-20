#!/bin/sh

# Run this after cloning dotfiles.

################################################################################

# this is a surprise tool that will help us later 🤓
isYes() {
    test "$1" = "y" || test "$1" = "Y"
}

# **** make common directories ****
dirs="$HOME/.config $HOME/.local/share/Trash $HOME/.local/bin $HOME/.ssh"
read -p "-> Make common directories ($dirs)? " response
if isYes "$response"; then
    for dir in $dirs; do
        mkdir --verbose --parents "$dir"
    done
fi
echo ""

# **** set up git stow ****
read -p "-> Stow packages? " response
if isYes "$response"; then
    # TODO don't hardcode apt here
    sudo apt install -y stow
    stow -R package*
fi
echo ""



GREEN='\e[0;32m'
YELLOW='\e[0;33m'
CLEAR='\e[0m'
make_symlink() {
    target="$1"
    link_name="$2"

    if [ -h "$link_name" ]; then # (-h tests for symlinkness)
        # the "no target directory" explanation is somewhere around here
        echo "Symlink $YELLOW'$link_name'$CLEAR already exists"
        ln --symbolic --interactive --no-target-directory "$target" "$link_name"
    else
        echo "Creating new symlink $GREEN'$link_name'$CLEAR"
        ln --symbolic --interactive --no-target-directory "$target" "$link_name"
    fi

}

# **** make symlinks ****
read -p "-> EXPERIMENTAL create symlinks? " response
if isYes "$response"; then
    # All these dotfiles go in $XDG_CONFIG_HOME (how nice of them😊)
    dotfiles_path="$(dirname $(realpath $0))"
    if [ -z "$XDG_CONFIG_HOME" ]; then
        XDG_CONFIG_HOME="$HOME/.config"
    fi
    XDG_CONFIG_HOME="$HOME/testdir" # TODO remove, this is for debugging
    for package in new_kitty package-awesome package-kitty; do
        echo ""
        target="$dotfiles_path/$package"
        package_basename="$(echo "$package" | sed 's/package-//')"
        link_name="$XDG_CONFIG_HOME/$package_basename"
        make_symlink "$target" "$link_name"
    done

    # One-off dotfiles (eww why🤮)
    # TODO

    # Bash
    # target="$dotfiles_path/bash/bashrc_after"
    # link_name="$HOME/.bashrc_after"
    # $dotfiles_path/bash/bashrc_after
    # # Could rename .bashrc_after to dotfiles/bash/bashrc_after to remove the dot
    # import='if [ -f $HOME/.bashrc_after ]; then source $HOME/.bashrc_after; fi'

    # Vim
    # target="$dotfiles_path/vim/vimrc"
    # link_name="$HOME/.vimrc"
    # make_symlink "$target" "$link_name"

    # Scripts
    # target="$dotfiles_path/scripts"
    # link_name="$HOME/.local/sam-bin"
    # make_symlink "$target" "$link_name"

fi
echo ""



# **** install preferred font ****
# font_install_dir="$HOME/.local/share/fonts/truetype/"
# font_url="https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/JetBrainsMonoNLNerdFontMono-Regular.ttf"
# read -p "-> Install font to $font_install_dir? " response
# if isYes "$response"; then
#     curl --create-dirs --output-dir "$font_install_dir" -LO "$font_url"
# fi
font_install_dir="$HOME/.local/share/fonts/truetype/"
read -p "-> Install fonts to $font_install_dir? " response
if isYes "$response"; then
    mkdir --verbose --parents "$font_install_dir"
    cp -t "$font_install_dir" fonts/*.ttf
fi

# **** install neovim ****
# TODO could probably make a nix package for the version of nvim currently used in my dotfiles ❄
read -p "-> Install Neovim? " response
neovim_checkout_dir="$HOME/checkouts/testneovim"
if isYes "$response"; then
    # TODO don't hardcode apt here
    sudo apt install -y ninja-build gettext cmake curl build-essential
    # sudo dnf -y install ninja-build cmake gcc make gettext curl glibc-gconv-extra git
    mkdir --verbose --parents "$neovim_checkout_dir"
    git clone "https://github.com/neovim/neovim.git" "$neovim_checkout_dir"
    git -C "$neovim_checkout_dir" checkout v0.11.3
    make -C "$neovim_checkout_dir" CMAKE_BUILD_TYPE=Release
    sudo make -C "$neovim_checkout_dir" install
fi
echo ""

echo "-> Don't forget to add 'Defaults !tty_tickets' to /etc/sudoers."
echo "-> Also 'Defaults timestamp_timeout=5' (minutes) if you want to change it later"
echo "   (I don't know how to automate this)"

# TODO remember to create .env file for obs-save-replay. it needs a password.
# you can use 'read -p' for this

# TODO edit existing .bashrc and remove things as necessary (I know history
# needs to be changed, for example). Or just copy the existing bashrc to a
# .old_bashrc

# TODO copy example ssh config to .ssh and maybe do some other stuff there

# TODO need tree-sitter-cli for tree-sitter-manager to compile grammars or
# something idk
