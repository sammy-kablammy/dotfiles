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
(it deletes four spaces, even in the middle of a line. if sts is 0, this action
would delete a single space.)

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
thing you need to change to flip between tabs and spaces. when reading someone
else's files, you're just gonna have to make do.

--]]

vim.o.number = true -- needed for absolute number on current line
-- vim.o.relativenumber = true -- relative numbers everywhere else
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if not vim.b.sam_override_whitespace_settings then
            vim.o.expandtab = true
            vim.o.tabstop = 4
            vim.o.shiftwidth = 4
            vim.o.softtabstop = 4
        end
    end,
})
function FixStupidVimIndentationSettings()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
end
vim.api.nvim_create_user_command('FixStupidVimIndentationSettings', FixStupidVimIndentationSettings, {})

-- recall: autocommands of the same event type will fire in order of definition

--[[

here's the deal with buffer settings and autocommands:

i find it REALLY annoying that ftplugin/ and after/ftplugin are evaluated before
the BufEnter event, as there are buffer-settings i would like to apply for every
non-ftplugin-ified buffer. but i can't AFAIK. also, to add to the confusion, the
order of autocommand events is apparently not well defined, so depending on
whether you're opening a new file, existing file, the first file within a vim
session, or a subsequent file, things can spiral out of control quickly.

the obvious solution is to apply generic options first, *then* specific ones to
override them. but by loading ftplugins before BufEnter events, vim is backwards

the solution is this:
- global settings just go in init.lua (or file required by init.lua) like normal
- filetype settings go in the after/ftplugin, along with a buffer variable
  indicating that some settings have been changed
- buffer local settings are defined in a BufEnter autocommand, buf gated by the
  aforementioned buffer variable

you probably could create some sort of automated framework for this, but i'm
trying to keep my config as minimal as possible, so this will have to do 😠💢

--]]

--------------------------------global settings---------------------------------

-- 'wrap' is soft wrap. it's visual and won't insert any newline characters.
vim.o.wrap = false
-- 'breakindent' will cause long indented lines to wrap onto the next line
-- whilst preserving their indent level. this can make long indented lines take
-- up several lines more when wrapped than they really should.
vim.o.breakindent = false

-- if a search query includes caps then it's case-sensitive, else it's case-insensitive
vim.o.ignorecase = true
vim.o.smartcase = true

-- make vim's :find command search downward into subdirectories (i don't often
-- use this since telescope is better but it's nice to have)
vim.opt.path:append("**")

-- just use :h you dingus
vim.o.inccommand = 'split' -- preview substitutions
vim.o.updatetime = 500 -- faster autosave for swapfiles (milliseconds)
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.mouse = "a"
vim.o.wrapscan = false
vim.o.hls = true
vim.o.showmode = false
vim.o.timeout = false
vim.o.foldcolumn = "1"
vim.o.dictionary = "/usr/share/dict/american-english"


---------------------------"local to buffer" settings---------------------------
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function()
        -- 'textwidth' is hard wrap. it inserts newlines into the buffer after a
        -- certain number of characters. this applies to comments if 'c' is a
        -- formatoption; it applies to normal text if 't' is.
        vim.o.textwidth = 80

        vim.o.spelllang = "en_us"
        -- default spellcheck behavior marks lowercase words as wrong. cringe.
        vim.o.spellcapcheck = ""

        -- see :h fo-table.
        -- 't' is disabled so that line breaks are not inserted on long lines of code
        -- (but you might want 't' in prose filetypes).
        -- 'c' is enabled so that line breaks ARE inserted on long code comments.
        -- 'r' is enabled so that comments are continued in insert mode.
        -- 'o' is disabled so that comments don't continue when using 'o' motion.
        -- 'l' is disabled so that lines can be wrapped in insert mode (this respects
        -- the 't' option in code files)
        if not vim.b.sam_override_formatoptions then
            vim.bo.formatoptions = "jcrq"
        end

        vim.o.swapfile = true
        vim.o.undofile = true
    end,
})

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

-- highlight on yank (how did i not know this was built in to neovim!?!?!?)
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ timeout = 100 })
    end
})

--------------------some "local to window" settings, i guess--------------------

-- i used to use vim.o.colorcolumn = "80" BUT this is hardcoded whereas using +0 sets colorcolumn to be in sync with 'textwidth'
vim.o.colorcolumn = "+0"
vim.o.cursorline = true
-- i used to use scrolloff=5, then 3, but these days i think i prefer none. i
-- use motions like H M L <c-e> <c-y> zt zz zb to scroll around
vim.o.scrolloff = 0
vim.o.sidescrolloff = 3
vim.o.signcolumn = "yes" -- i would use "number" but gitsigns signs are too common


-----------------------------interacting with notes-----------------------------
vim.api.nvim_create_user_command('NewNote', function()
    local obj = vim.system({"notenew"}, {}):wait()
    -- there's a trailing newline; remove it
    local filename = string.sub(obj.stdout, 1, -2)
    -- editing the file based on the full path is annoying because it messes up
    -- links, but it's fine if you're just doing a quick note. (this annoyance
    -- resets once reopening nvim, so the fix only matters for longer sessions)
    if vim.fn.getcwd() == "/home/sam/notes" then
        local basename = vim.fs.basename(filename)
        vim.cmd.edit("main/" .. basename)
    else
        vim.cmd.edit(filename)
    end
end, {})
vim.api.nvim_create_user_command('Mainnote', function()
    if vim.bo.modified then
        print("must save note before moving")
        return
    end
    local file_path = vim.fn.expand("%:t")
    vim.cmd("!mv '%' ~/notes/main/")
    vim.cmd.bdelete()
    vim.cmd.edit("~/notes/main/" .. file_path)
end, {})
vim.api.nvim_create_user_command('Inboxnote', function()
    if vim.bo.modified then
        print("must save note before moving")
        return
    end
    local file_path = vim.fn.expand("%:t")
    vim.cmd("!mv '%' ~/notes/inbox/")
    vim.cmd.bdelete()
    vim.cmd.edit("~/notes/inbox/" .. file_path)
end, {})
vim.api.nvim_create_user_command('Deletenote', function()
    local link = vim.api.nvim_buf_get_name(0)
    local basename = vim.fs.basename(link)
    vim.cmd("silent grep " .. basename)
    if #vim.fn.getqflist() ~= 0 then
        print("can't delete this note, it has backlinks!")
        return
    end
    if vim.bo.modified then
        print("must save note before moving")
        return
    end
    vim.cmd("!mv '%' ~/notes/.trash/")
    vim.cmd.bdelete()
end, {})
vim.api.nvim_create_user_command('TagNotes', function()
    vim.cmd("!~/notes/maketags.sh")
end, {})
vim.api.nvim_create_user_command('RandomNote', function()
    local obj = vim.system({ "noterandom" }, {}):wait()
    -- there's a trailing newline; remove it
    local filename = string.sub(obj.stdout, 1, -2)
    vim.cmd.edit(filename)
end, {})
vim.keymap.set("n", "<leader>nt", "<cmd>TagNotes<cr>")
vim.keymap.set("n", "<leader>nn", "<cmd>NewNote<cr>")
vim.keymap.set("n", "<leader>ni", "<cmd>edit ~/notes/main/inbox.md<cr>")
vim.keymap.set("n", "<leader>nr", "<cmd>RandomNote<cr>")

-- the path isn't set properly for some reason (at least on chromeos),
-- preventing my shell scripts from being found
vim.cmd("silent !PATH=$PATH:~/.local.bin")

-- i like to :bd my buffers but sometimes i want to reopen them. the default
-- behavior is for buffers deleted in this way to stay 'unlisted' forever. i
-- think if i reopen a buffer, it should re-list itself.
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if vim.bo.buftype == "" then
            vim.bo.buflisted = true
        end
    end,
    desc = "re-list deleted buffers when they're reopened",
})

vim.api.nvim_create_autocmd("BufNew", {
    callback = function()
        -- this looks like a no-op but it actually forces paths to be relative.
        -- example: suppose pwd is /home/sam/. if you :edit file1 and :edit
        -- /home/sam/file2, then get the name of each file, file1 comes back as
        -- file1 but file2 comes back as /home/sam/file2. this is
        -- counterintuitive because they have the same relative path. confused
        -- yet?
        vim.cmd("cd .")
    end,
    desc = "fix relative path % register behavior",
})

-- reuse a vim session, if one is found
vim.api.nvim_create_user_command("Seshma", function()
    if vim.fn.glob("Session.vim") ~= "" then
        vim.ui.select({ "yes", "no" }, {
            prompt = "A vim session exists, would you like to load and delete it?",
        }, function(choice)
            if choice == "yes" then
                local date = os.date("*t")
                local filename = date.year .. "-" ..
                date.month .. "-" ..
                date.day .. "_" ..
                date.hour .. "-" ..
                date.min .. "-" ..
                date.sec .. ".vim"
                vim.cmd.source("Session.vim")
                vim.cmd("!mkdir --parents ~/.local/share/nvim/old_sessions/")
                vim.cmd("!mv Session.vim ~/.local/share/nvim/old_sessions/deleted_on_" .. filename)
            end
        end)
    else
        print("No session file found.")
    end
end, {})

vim.filetype.add({
    ["*.bash"] = "sh",
    [".bashrc_after"] = "sh",
})




-- netrw stuff (unused for now?)
-- yeah... netrw is just too inconsistent to use. like, sometimes netrw is a
-- buffer, sometimes it's not. sometimes you can preview a file in another
-- split, sometimes it'll open the file in the same split. just don't bother.
-- vim.g.netrw_banner = 0 -- hide banner by default
-- vim.g.netrw_keepdir = 0 -- sync netrw directory with working directory
-- tree style file browser instead of list style
-- ...actually no that breaks the ability to open a new instance that focuses
-- on the current file
-- vim.g.netrw_liststyle = 3
-- vim.g.netrw_preview = -1 -- open file previews LEFT (default DOWN)
-- vim.g.netrw_browse_split = 4
-- vim.keymap.set("n", "<leader>L", "<cmd>Lex<cr>")
-- it seems you can't do BufEnter, as netrw overwrites that event
-- i don't know how to execute a callback when netrw opens :(
-- vim.api.nvim_create_autocmd("BufEnter", {
--     pattern = { 'netrw', },
--     callback = function() end,
-- })
-- like, this works but it only triggers when you actually press a key, not when
-- you enter the buffer
-- vim.cmd[[
-- autocmd filetype netrw echo "hi"
-- ]]
