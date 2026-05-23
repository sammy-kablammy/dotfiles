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
- `g<` to re-show the previous command output
- use `<enter>` to go to the beginning of the next line. easier than `j^`

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

### git introspection

- `git blame somefile` shows the last time a line was touched. However, this
  often points to a useless commit (like "abc123: format entire codebase") that
  has nothing to do with any particular line. For this, you can try to re-blame
  at that commit, but who knows how long this process will repeat. (To be fair,
  text editors often have git blame integration that makes this repeated blaming
  much faster.)
  - `git blame -L 10,20` only show blame for lines 10 through 20. (Lines are
    1-based, both bounds are included e.g. `1,2` prints the two very first lines
    in the file)
- `git log --all -- FILEPATH` show commits that touched FILEPATH
- `git log -S somestring` ("What commits added or removed this string?") will
  search through all commit *diffs* for the given string. If a line of code was
  added and subsequently removed, this will show the relevant commits.
- `git log -G somestring` ("What commits added, removed, or changed this
  string?") is like `-S` but also includes commits that changed the string. You
  know how git will say something like "1 line removed, 1 line added"? This
  catches that kind of thing.
- `git log -S someregex --pickaxe-regex` is what you think. Recall that git uses
  POSIX extended regular expressions. Note that the regex must come directly
  after the `-S`
- `git log -S someregex --pickaxe-regex -i` for case insensitive regex. In fact,
  `-i` implies `--pickaxe-regex`.

- example: `git log -S mystring dev~100..dev -- subdir` shows commits in the
  past 100 that touched 'mystring' in directory 'subdir'

## GitLab CI

*merge request convention*: if you have a CI job that's supposed to run on a
per-MR basis, it will run when that job is defined in the feature branch. the CI
jobs in the main branch (AKA the merge target branch) do not run. only the merge
source branch.
- this is the only sensible way it could work. imagine if the main pipeline is
  broken such that it can never pass. how would you merge in a fix if you were
  required to pass the broken main pipeline in order to merge?

## markdown

i rely on very few markdown features. no tables, no images, no render step. just
use plain text.

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
  - You can press `e` to edit the selected buffer (`tmux show-opt editor`)
  - press `d` to delete buffer from history

## C programming

```c
const int *ptr; // pointer to a const int
int const *ptr; // pointer to a const int
int * const ptr; // const pointer to an int
int const *const ptr; // const pointer to a const int
```

## Lua

```lua
-- Variadic arguments
function print_var_args(...)
    print(...)
    -- Or, if you want a specific number of them:
    local first, second = ...
    print(first, second)
end
```

## ctags

universal-ctags is a maintained version. exuberant-ctags may be older

you can add tags for local variables like `ctags --kind-C=+l`. but you can also
just do vim's default `gd`.

`ctags -o -` to output to stdout instead of creating tags file

## top

- M sort by memory
- C sort by cpu
- z enable color
- `?` help (also `h`)
- m show some memory stuff in a pretty lil bar

## networking shi

list Listening Tcp ports `netstat -lt`
