#!/bin/sh

# Run this after cloning dotfiles.

################################################################################

# this is a surprise tool that will help us later 🤓☝
isYes() {
    test "$1" = "y" || test "$1" = "Y"
}

# **** make common directories ****
dirs="$HOME/.config $HOME/.local/share/Trash $HOME/.local/bin"
read -p "-> Make common directories ($dirs)? " response
if isYes "$response"; then
    for dir in $dirs; do
        mkdir --verbose --parents "$dir"
    done
fi

# **** set up git stow ****
read -p "-> Stow packages? " response
if isYes "$response"; then
    # TODO don't hardcode apt here
    sudo apt install -y stow
    stow -R package*
fi

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

echo "-> Don't forget to add 'Defaults !tty_tickets' to /etc/sudoers."
echo "   (I don't know how to automate this)"




# TODO edit existing .bashrc and remove things as necessary (I know history
# needs to be changed, for example). Or just copy the existing bashrc to a
# .old_bashrc

# TODO copy example ssh config to .ssh and maybe do some other stuff there
