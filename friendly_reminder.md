while still using GNU stow, don't forget to create `~/.local/bin`.

(eventually it'd be good to switch to a bare repo. stow has caused too many annoyances in the past)

also, to make `sudo` carry over between tmux windows, you can go to the
`/etc/sudoers` and add the line `Defaults !tty_tickets`
