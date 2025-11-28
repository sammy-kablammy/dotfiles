# dotfiles

Don't forget to run `setup.sh`.

## using stow for dotfile wizardry

- create some packages. these can be named whatever you want.
- dotfiles that belong in `~` (like `.vimrc`) can just go directly in the
  package
- dotfiles that belong in `.config` (like `tmux.conf`) need the path relative to
  `~` to be recreated inside of the package's directory

example directory structure:
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

in this example, "vim" is the package name you use when you type `stow vim`.
since `.vimrc` belongs in `~`, no extra structure is needed. compare this
to `tmux.conf`, which belongs in `~/.config/tmux/tmux.conf`.

- `stow <package name>` to add a package
- `stow -D <package name>` to delete a package
- `stow */` to add all directories

Non-stow-package directories are here, try to remember not to symlink them. Stow
packages are named `package-xxx` so you can just `stow -R package*` to get them all.

WARNING: GNU Stow's `--dotfiles` flag doesn't work when a directory is a
dotfile, e.g. `.config/` (Years old, will likely never be fixed
https://github.com/aspiers/stow/issues/33). One of many janky behaviors that
make me want to ditch stow in the future.

## statusization

ever leave your computer for a while but forget to push your changes and then
have to deal with a bunch of merging when you get back?? haha me neither.

<img src="https://raw.githubusercontent.com/sammy-kablammy/dotfiles/main/statusize.png" width="380" />
