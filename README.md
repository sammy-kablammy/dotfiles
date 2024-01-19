# how to use stow for dotfile wizardry

- create some packages. these can be named whatever you want.

- dotfiles that belong in ~ (like your .vimrc) can just go directly in the package

- dotfiles that belong in .config (like your tmux.conf) need the path relative to
~ to be recreated inside of the package's directory

```
├── nvim
│   └── .config
│       └── nvim
│           ├── init.lua
│           └── lua/
├── tmux
│   └── .config
│       └── tmux
│           ├── catppuccin.conf
│           ├── my_custom_color_theme.conf
│           ├── sessionizer.sh
│           └── tmux.conf
└── vim
    └── .vimrc
```

In this example, "vim" is the package name you use when you type the "stow vim"
command. Since the .vimrc file belongs in ~, no extra structure is needed.
Compare this to tmux.conf, which belongs in ~/.config/tmux/tmux.conf.

- `stow <package name>` to add a package
- `stow -D <package name>` to delete a package
- `stow */` to add all directories
