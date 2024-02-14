if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/notes -type f -not -path '*/.*' | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected")

tmux new-window -n "NOTE: $selected_name" "nvim $selected"
# TODO use this version instead
# tmux new-window -n NOTE -c ~/notes nvim +'lua require("telescope.builtin").live_grep()'
