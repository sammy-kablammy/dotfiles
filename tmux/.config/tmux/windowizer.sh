if [[ $# -eq 1 ]]; then
    selected=$1
else
    # some notes on `find` command:
    # `-type d` only finds directories
    # `-not -path '*/.*'` is used to ignore dotfiles
    # NOTE: you can also use `-mindepth n` and `-maxdepth n`
    selected=$(find ~ -mindepth 0 -maxdepth 2 -type d -not -path '*/.*' | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _) # this line is magic

tmux new-window -c $selected -n $selected_name
