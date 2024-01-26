if [[ $# -eq 1 ]]; then
    selected=$1
else
    # this was the original line, but it seems to hide symlinks? i don't know...
    selected=$(find ~ ~/dotfiles ~/my_neovim_plugins ~/notes -mindepth 1 -maxdepth 1 -type d | fzf)
    # this line seems to work better with GNU stow
    # selected=$(find ~ ~/dotfiles ~/my_neovim_plugins ~/notes -mindepth 1 -maxdepth 1 | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _) # this line is magic
tmux_running=$(pgrep tmux)

tmux new-window -c $selected -n $selected_name
