if [[ $# -eq 1 ]]; then
    selected=$1
else
    # some notes on `find` command:
    # `-type d` only finds directories
    # `-not -path '*/.*'` is used to ignore dotfiles
    # NOTE: you can also use `-mindepth n` and `-maxdepth n`
    selected=$(find ~ -mindepth 0 -maxdepth 3 -type d -not -path '*/.*' | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

# i'd rather have the name auto-update than set it upon creating the window
# selected_name=$(basename "$selected" | tr . _) # this line is magic
# tmux new-window -c $selected -n $selected_name
tmux new-window -c $selected
