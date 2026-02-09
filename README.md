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

why moving away from stow:
- it's annoying to install on every machine across package managers. i only use
  stow for initial dotfiles setup and then never again
- fuzzy finders can't find anything since `.config` is hidden
- because stow only supports relative paths, the dotfiles repo must be close to
  the eventual symlink location. otherwise your package paths are super long.

## statusization

ever leave your computer for a while but forget to push your changes and then
have to deal with a bunch of merging when you get back?? haha me neither.

<img src="https://raw.githubusercontent.com/sammy-kablammy/dotfiles/main/statusize.png" width="380" />

## TODO

should implement these one day. (or don't, see if i care 🙄)

- instead of having individual backups commands in cron, use a single backups.sh
  called once by cron
- write my own lightweight version of stow instead of relying on actual GNU
  stow. stow is too finicky. should run in posix shell with no other deps. only
  needs to support the very small feature set i use for dotfiles; no need to
  make a general purpose symlink manager.
- nvim keymap that toggles :diffthis mode on all open windows?
- add some `ls` colorization to dotfiles
- move all machine-specific environment variables into one place (e.g. ytdlp
  path, notes path, shell prompt probably)
- have a reference program for ANSI escape codes. it's fine to have a text
  reference, but why not make it a program? that way it actually shows the codes
  in context, accounting for your terminal color+font settings. one use case is
  for writing programs using ANSI codes, and another is as a quick benchmark to
  test your terminal+font settings (almost like a fetcher program). should be a
  single sh file, no dependencies
  - print every color code in that color
  - aside from colors do bold, italics, underline, strikethrough, etc.
  - also test some unicode / patched font characters
- DIY nvim startup profiling? like :Lazy profile but simpler? idk
- are there any good TUI treemap viewers? if not i could make one.
- write a tags analyzer to break down tags file size by path. that way you can
  see what tags are big and exclude the ones you don't want
- Need to merge my vim reminders.md into dotfiles so i have it with me. tbh many
  standalone files like this can all be merged here
- nvim zen mode (`<leader>sz`) is super jank. Honestly should get rid of it.
- linkma should navigate between UNCHECKED checkboxes only with `[x` and `]x`.
  capital X can go between all checkboxes if you want.
- add an example of parsing args in bash, or just point to one of my existing
  files
- add ls color customization to dotfiles. on windows rn my directories are blue
  with light green background; basically unreadable
- it would be convenient to have a git alias that tells you what branch your
  current branch was created off of. I haven't found an elegant way of doing
  this though, so don't waste too much time. i have other notes on this
- I need a dedicated alt+tab button on my keyboard layout. my numbered bindings
  are helpful. But some programs aren't used frequently enough to justify a
  dedicated slot.
- Should use bottom row of keyboard's top layer as harpoon keys. You know, to
  mirror the desktop and window switching keys. Makes me more likely to
  actually, you know, use harpoon. While we're making keeb adjustments, i should
  have a work profile (can you make it persist across reboots?) that swaps the
  volume knob for mouse wheel. Future keebs should just have two knobs; it's not
  like the second knob would take up any extra space.
- Keyboard symbols need to be rethought. Especially + (i keep pressing pageup
  instead). Mainly worried about right hand modifier with left hand keys. bad
  pattern
- make markdown textobjects for "inside asterisks", "inside list item", and even
  "inside markdown header" (in progress but not fully tested yet)
  - Test nested list item here
  - [ ] Test checkbox here
  - [X] Test checked checkbox here
- https://stackoverflow.com/questions/782511/case-preserving-substitute-in-vim
  Look into this (someone linked a tpope example plugin) and try to get some
  similar functionality
- Should visualize marks in the signcolumn
- need a git-switch-local that's like git-switch but only autocompletes local
  branches. could be as simple as parsing 'git branch' to get local branch
  names.
- does zip.vim (the builtin plugin that allows you to view archives) support
  epubs? try it out. also get PDFs working in my config a bit better.
- make scp not do local copies, it's so annoying. `remote` should be assumed to
  mean `remote:~`
- there should probably be a script to install nix and install a bunch of
  packages using nix. that way i have something cross-platform
  - add universal ctags (this is a fork from exuberant ctags) to packages list

Things to regularly check in on:
- update readme
- bump nvim plugin versions
- sort spellfile and git aliases
- go through each nvim plugin and update them if they're not working right. i
  know iconpicker is weird rn
