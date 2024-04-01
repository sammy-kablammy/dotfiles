-- this file is for vimrc-style things other than keymaps

--[[
- vim.g is read-only.
- vim.opt_global isn't read only, BUT it returns an Option you have to unpack.
- vim.o is probably what you want to use for most things.
(:h lua-vim-options)

WARNING: doing a top-level "vim.o.setting = value" statement will usually work,
but seems to break when opening multiple files from the command line:
("vim file1 file2 file3"). only the first buffer will receive these top-level
settings. for this case, you'll want to use a BufEnter autocommand / ftplugin
(or just NEVER EVER open multiple files at once from the command line and you
should be fine).
--]]

--[[
- 'expandtab' will replace a tab *keypress* with several space *bytes*
- 'tabstop' is the number of characters displayed on screen for each tab byte
- 'shiftwidth' is the number of characters on screen that your cursor will jump
  forward when you press the tab key or use < > motions.
- 'softtabstop' i don't know how to explain but basically it affects <tab> and
  <bs> when other text exists. see example below.

NOTE 'softtabstop' example. if your 'sts' is set to 4, then pressing <bs> while
in insert mode at the beginning of "hello," you will see the following change:
hi there        hello again
hi there    hello again
(it deletes four spaces, even in the middle of a line)

WARNING: if expandtab, don't let your tabstop exceed your shiftwidth.
otherwise, you'll have chunks of spaces turn into tabs once they get longer.
with (ts=8 sw=4) a single tab press does this:
____text goes here
the second tab press does this:
>       text goes here

WARNING: if expandtab, don't let your shiftwidth exceed your tabstop.
otherwise, you'll be indenting with multiple tab bytes per indentation level.
at that point, you might as well use spaces.
with (ts=4 sw=8) a single tab press does this:
>   >   text goes here

TL;DR use the same value for ts, sw, and sts. then, 'expandtab' is the only
thing you need to change to flip between tabs and spaces.

--]]

-- NOTE: Since et, ts, and sw are all "local to buffer" options, this section
-- should only be used as a fallback. Rely on after/ftplugin or some kind of
-- autocommand setup first.
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

-- TODO use after/ftplugin for whitespace settings. or maybe not??? idk
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { '*.js', '*.html', '*.css', '*.c', '*.h', '*.md', },
    callback = function()
        vim.o.expandtab = true
        vim.o.tabstop = 2
        vim.o.shiftwidth = 2
        vim.o.softtabstop = 2
    end,
})

function FixStupidVimIndentationSettings()
    vim.o.tabstop = 4
    vim.o.shiftwidth = 4
    vim.o.softtabstop = 4
end

vim.api.nvim_create_user_command('FixStupidVimIndentationSettings',
    FixStupidVimIndentationSettings, {})

-- 'wrap' is soft wrap. it's visual and won't insert any newline characters.
vim.o.wrap = false
-- 'textwidth' is hard wrap. it inserts newlines into the buffer after a
-- certain number of characters. this applies to comments if 'c' is a
-- formatoption; it applies to normal text if 't' is.
vim.o.textwidth = 80
vim.o.breakindent = true

-- See :h fo-table.
-- You want 't' disabled so that line breaks are not inserted on long lines of
-- code (but you might want 't' in prose filetypes).
-- You want 'c' enabled so that line breaks ARE inserted on long code comments.
-- You want 'r' enabled so that comments are continued in insert mode.
-- You want 'o' disabled so that comments don't continue when using 'o' motion.
-- You want 'l' disabled so that lines can be wrapped in insert mode (this
-- respects the 't' option in code files)
-- You need to use an autocommand because 'fo' is a "local to buffer" option.
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.o.formatoptions = "jcrq"
    end,
})
-- note: this autocmd fires after BufEnter
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { '*.md' },
    callback = function()
        vim.o.formatoptions = "jcrqt"
    end,
})

-- TODO lookup fold settings

-- open help windows to the right instead of below
vim.api.nvim_create_user_command('H', function(opts)
    local help_page_to_open = opts.args
    vim.cmd('vertical help ' .. help_page_to_open)
end, {
    nargs = 1
})

vim.api.nvim_create_user_command('HtmlMe', function()
    local original_color = vim.g.colors_name
    vim.cmd.color('slate')
    vim.cmd('TSToggle highlight')
    vim.cmd('TOhtml')
    vim.cmd('TSToggle highlight')
    vim.cmd.color(original_color)
end, {})

-- netrw stuff
vim.g.netrw_banner = 0 -- hide banner by default
-- vim.g.netrw_keepdir = 0 -- sync netrw directory with working directory
-- tree style file browser instead of list style
-- ...actually no that breaks the ability to open a new instance that focuses
-- on the current file
-- vim.g.netrw_liststyle = 3
-- vim.g.netrw_preview = -1 -- open file previews LEFT (default DOWN)
-- it seems you can't do BufEnter, as netrw overwrites that event
-- i don't know how to execute a callback when netrw opens :(
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { 'netrw', },
    callback = function() end,
})

-- preview substitutions with :s
vim.o.inccommand = 'split'

-- if a search query includes caps then it's case-sensitive, else it's case-insensitive
vim.o.ignorecase = true
vim.o.smartcase = true

-- faster autosave for swapfiles
vim.o.updatetime = 50

vim.o.spelllang = "en_us"
-- default spellcheck behavior marks lowercase words as wrong. cringe.
vim.o.spellcapcheck = ""

-- we love visualizing leading and trailing spaces!! hooray!!
vim.o.listchars = "lead:·,trail:·,tab:> "
vim.api.nvim_create_user_command("Listchars", function()
    vim.ui.input({
        prompt = "set listchars=",
        default = vim.o.listchars,
    }, function(input)
        vim.o.listchars = input
    end)
end, {})

-- you can use :h for these
vim.o.number = true         -- needed for absolute number on current line
vim.o.relativenumber = true -- relative numbers everywhere else
vim.o.colorcolumn = "80"
vim.o.cursorline = true
vim.o.scrolloff = 3
vim.o.sidescrolloff = 3
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.mouse = "a"
vim.o.signcolumn = "yes"
vim.o.wrapscan = false
vim.o.hls = false
vim.o.showmode = false
