# pretty much copied directly from tmux-sessionizer
# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # this was the original line, but it seems to hide symlinks? i don't know...
    # selected=$(find ~/.config ~/my_neovim_plugins -mindepth 1 -maxdepth 1 -type d | fzf)
    # this line seems to work better with GNU stow
    selected=$(find ~ ~/dotfiles ~/my_neovim_plugins -mindepth 1 -maxdepth 1 | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _) # this line is magic
tmux_running=$(pgrep tmux)

# tmux not opened yet -> simply open tmux and you're done
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

# tmux is open -> add a new session and switch to it
if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name
