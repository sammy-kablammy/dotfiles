-- this file is for vimrc-style things other than remap stuff

-- 'expand' a tab keypress into space characters in the buffer
vim.o.expandtab = true
-- 'tabstop' is the number of characters displayed on screen when a tab byte is
-- encountered. setting this to something other than your shiftwidth lets you
-- see tabs when they're used. ...but it's also jarring to switch indentation
-- amounts between files
vim.o.tabstop = 4
-- 'shiftwidth' is the number of spaces inserted when "expandtab" is enabled.
-- it's also the number of spaces when using << or >> motions.
vim.o.shiftwidth = 4

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { '*.js', '*.html', '*.css', '*.c', '*.h' },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

-- 'wrap' is soft wrap. it's visual and won't insert any newline characters.
vim.o.wrap = false
-- 'textwidth' is hard wrap. it inserts newlines into the buffer after a
-- certain number of characters. this applies to comments if 'c' is a
-- formatoption; it applies to normal text if 't' is.
vim.o.textwidth = 80
vim.o.breakindent = true

-- See :h fo-table.
-- You want 'r' enabled so that comments are continued in insert mode.
-- You want 'o' disabled so that comments don't continue when using 'o' motion.
-- Also you need to use an autocmd because "vim.opt.formatoptions" gets
-- overwritten somehow :( TODO figure this out
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(args)
        vim.opt.formatoptions = "jcrql"
    end,
})
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { '*.md' },
    callback = function(args)
        -- the 't' formatoption inserts line breaks on lines that are too long
        vim.opt_local.formatoptions = "jcrqlt"
        vim.opt_local.shiftwidth = 2
    end,
})

-- open help windows to the right instead of below
vim.api.nvim_create_user_command('H', function(opts)
    local help_page_to_open = opts.args
    vim.cmd('vertical help ' .. help_page_to_open)
end, {
    nargs = 1
})

vim.api.nvim_create_user_command('HtmlMe', function(opts)
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
vim.o.scrolloff = 5
vim.o.sidescrolloff = 3
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.mouse = "a"
vim.o.signcolumn = "yes"
vim.o.wrapscan = false
vim.o.hls = false
vim.o.showmode = false
