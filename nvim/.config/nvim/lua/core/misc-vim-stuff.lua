-- this file is for vimrc-style things other than remap stuff

-- pressing the tab key causes spaces to be inserted
vim.o.expandtab = true
-- 'tabstop' is the number of characters displayed in a tab byte. setting this
-- to something other than your shiftwidth lets you see tabs when they're used.
-- ...but it's also jarring to switch indentation amounts between files
vim.o.tabstop = 4
-- 'shiftwidth' is the number of characters to shift when using << or >>, or
-- when pressing <tab>. it will keep inserting your preference of whitespace
-- characters until this column number is reached
vim.o.shiftwidth = 4

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { '*.js', '*.html', '*.css', '*.c', '*.h' },
    callback = function()
        vim.o_local.tabstop = 2
        vim.o_local.shiftwidth = 2
    end,
})

-- disable line wrapping (wrapping causes lines to be displayed on multiple
-- lines, it won't insert any linebreaks)
-- NOTE: the 'wrap' setting is 'soft' wrap. it is visual and won't alter text
vim.o.wrap = false
vim.o.breakindent = true
-- break up text onto the next line after this many characters
-- this applies to comments if 'c' is a formatoption; it applies to normal text if 't' is set
vim.o.textwidth = 80

-- display a big visual column at this many characters
vim.o.colorcolumn = "80"

-- See :h fo-table.
-- You want 'r' enabled so that comments are continued in insert mode.
-- You want 'o' disabled so that comments don't continue when using 'o' motion.
-- Also you need to use an autocmd because "vim.opt.formatoptions" gets
-- overwritten somehow :(
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

-- preview substitutions
vim.o.inccommand = 'split'

-- If a search query includes caps then it's case-sensitive, else it's case-insensitive.
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

-- self-explanatory enough (or just use :h)
vim.o.number = true         -- needed for absolute number on current line
vim.o.relativenumber = true -- relative everywhere else
vim.o.cursorline = true
vim.o.scrolloff = 5
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.mouse = "a"
vim.o.signcolumn = "yes"
vim.o.wrapscan = false
vim.o.hls = false
vim.o.showmode = false
