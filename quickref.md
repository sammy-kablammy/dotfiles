# quick reference

who knows how up to date this is

there should be a quick way of opening this to a particular section, likely 'q'
shell function. maybe nvim `<leader>?` since i'm already using that

## workflow

programming gooder and faster yes ok thank you

## vim (and neovim)

Use `<leader>?` to open quick reference

- Telescope's live_grep has `C-<space>` to "lock in" part of a search, allowing
  you to layer a second search query on top.
- `CTRL-W_P` to switch to previously accessed window
- settings: 'modifiable' determines whether the buffer can be changed,
  'readonly' determines whether `:write` (or `:x` or equivalents) will fail.
  Help buffers are both `readonly` and `nomodifiable`.
- a *colorscheme* is basically just a file with lots of `:highlight` commands.
  It sets all the highlight groups (`:h highlight-groups`).
- Arglist common commands:
  - `:ar[gs]` print arglist
  - `:ar[gs] one two three` set new arglist to "one two three"
  - `arga[dd] filename` add filename if provided, otherwise add current buffer
  - `[count]argu[ment] [count]` edit arg with index (count can go either spot)
  - `argd[elete] pattern` remove all files that match pattern
  - `3argd` remove entry 3 (arglist is 1-indexed btw)
  - `:argded[upe]` deduplicate, duh
  - `next`, `prev`, `[a`, `]a` to navigate one at a time
  - `argc()` and `argv()` vimscript functions do what you expect
- redirect errors with `:redir! > ~/vim_errors.txt`, useful when you're seeing
  errors on VimLeave that disappear too quickly

## shell (and bash)

- you CAN use single parens (no dollar sign) to deal with operator precedence.
  but be careful because this also creates arrays sometimes. not sure how to
  tell the difference
- to get absolute path of currently executing script, do `realpath $0`.
- Remember that `~` is a shell feature (shell expansion), while `$HOME` is an
  environment variable and can be used everywhere. Prefer HOME.
- POSIX if statements: Searching manpages (likely dash) for `test expression` or
  `test condition` will be helpful.
- see unix timestamp with `date +%s`

### flock

```sh
# Run the following commands in quick succession. Both sleep for 10 seconds.
# When the first one exits, it will echo 'hello'
flock myfile sleep 10
flock myfile echo hello
# With -n, the second command instantly fails instead of waiting for unlock
flock myfile sleep 10
flock -n myfile echo hello
```

## git

- check if string is a valid ref: `git check-ref-format 'nocommas,'` (doesn't
  output anything, must check exit code)

### Submodules

don't.

### patch files

git-diff's output IS a patch file

```sh
git diff > myfile.patch
git apply myfile.patch
```

## GitLab CI

*merge request convention*: if you have a CI job that's supposed to run on a
per-MR basis, it will run when that job is defined in the feature branch. the CI
jobs in the main branch (AKA the merge target branch) do not run. only the merge
source branch.

## Makefiles

- Use `make --warn-undefined-variables` when debugging makefiles.
- Remember that environment variables become make variables.

```make
# Default value for variable, can be overwritten like "VAR=hello make"
VAR ?= howdy

# phony job
.PHONY: help
help:
    echo whatever

# conditionally defined job
ifeq ( $(SOMEVAR), contents )
this-sometimes-does-not-exist:
    $(CC) $(CFLAGS) somefile
endif

# add dependency to existing job
myjob: extra_file
myjob: file1 file2 file3
    do_myjob

```

## tmux

- use `<prefix>=` to select from your paste buffer history

## C programming

```c
const int *ptr; // pointer to a const int
int * const ptr; // const pointer to an int
```
