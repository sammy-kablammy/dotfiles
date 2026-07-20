-- remember to :mkspell on a first installation. spellgood or zg should also work
-- vim.cmd('silent mkspell! /home/sam/.config/nvim/spell/en.utf-8.add') -- too slow to run every startup (~20ms)

local seconds, mseconds = vim.uv.gettimeofday()
math.randomseed(mseconds)
local function shitpost()
    local messages = {
        '🤓🤓 neovim, btw 🤓🤓',
        '👀 hello neovimmers',
        'any neovimmers?? 👀👀',
        'welcome to vscode',
        'o kama pona tawa ilo Neowin. o lukin! kijetesantakalu li lon a! 🦝',
        'Welcome to GNU Emacs, one component of the GNU/Linux operating system.',
        'ed (the standard text editor)',
        'neovim - now including like 50 electron instances',
    }
    return messages[math.random(#messages)]
end
print(shitpost())

SAM_AUGROUP = vim.api.nvim_create_augroup("sammy-kablammy", {})

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        -- TODO should pin lazy version
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

vim.o.termguicolors = true

-- note: you can do config = true and lazy will do default plugin setup

require("lazy").setup({
    {
        "nvim-telescope/telescope.nvim",
        tag = "v0.2.2",
        -- TODO plenary might be archived?
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
        -- (for the pretty vim.ui.input box used for LSP renaming; i could live without this one)
        -- ...or could rewrite my own vim.ui.input type thing
        -- TODO dressing might be archived?
        "stevearc/dressing.nvim",
        event = "CursorMoved",
    },
    {
        -- TODO find an alternative
        "ziontee113/icon-picker.nvim",
        dependencies = {
            "stevearc/dressing.nvim",
        },
        config = function()
            require("dressing").setup({
                backend = { "telescope", "builtin" }
            })
            require("icon-picker").setup({ disable_legacy_commands = true })
        end,
        -- event = "InsertEnter",
    },
    -- TODO remove, i don't do webdev, i think this might even be builtin nowadays?
    -- Or could just recreate myself. wouldn't be too hard
    {
        "norcalli/nvim-colorizer.lua",
        ft = "css", -- lazy load this plugin in css files (and then stay loaded for all files afterward)
        config = function()
            return { "css", } -- once lazy loaded, only apply colorization to css files
        end,
    },

    -- my plugins!!! hooray!!!
    -- "sammy-kablammy/nvim_plugin_template",
    {
        "sammy-kablammy/simpletodo.nvim",
        init = function()
            require("simpletodo").setup({})
        end,
    },
    {
        -- Can likely remove because of https://github.com/neovim/neovim/pull/28630
        "sammy-kablammy/linkma.nvim",
        -- NOTE: use "dir = '/path/to/local/plugin'" for local plugins
        config = function()
            local linkma = require("linkma")
            vim.api.nvim_create_autocmd({ "BufEnter" }, {
                pattern = { "*.md" },
                callback = function()
                    vim.api.nvim_buf_create_user_command(0, "LinkmaToc", linkma.toc_loclist, {})
                    vim.keymap.set("n", "<enter>", linkma.follow_link, { buffer = 0, desc = "follow link" })
                    vim.keymap.set("n", "]x", linkma.next_checkbox, { desc = "next checkbox" })
                    vim.keymap.set("n", "[x", linkma.previous_checkbox, { desc = "previous checkbox" })
                    vim.keymap.set("n", "<leader>mx", linkma.toggle_checkbox, { desc = "toggle checkbox" })
                    -- text object for links
                    vim.keymap.set("x", "im", linkma.select_link_text_object, { buffer = 0, desc = "inner link" })
                    vim.keymap.set("o", "im", ":normal vim<cr>", { buffer = 0, desc = "inner link" })
                    vim.keymap.set("x", "am", function() linkma.select_link_text_object(true) end, { buffer = 0, desc = "around link" })
                    vim.keymap.set("o", "am", ":normal vam<cr>", { buffer = 0, desc = "around link" })
                end,
            })
        end,
        ft = "markdown",
    },
})

-- New v0.12 vim.pack hooray!!! yippee!!!

-- Ensure packpath is reachable, this is supposed to be the default but for some
-- reason it isn't sometimes:
vim.go.packpath = vim.go.packpath .. ',' .. "/home/sam/.local/share/nvim/site/"
local github = function(str) return "https://github.com/" .. str end
vim.opt.packpath:append("/home/sam/.local/share/nvim/site/")
vim.pack.add({

    github("ThePrimeagen/vim-be-good"),
    github("folke/which-key.nvim"),
    github("catppuccin/nvim"),
    github("lewis6991/gitsigns.nvim"),

    github("romus204/tree-sitter-manager.nvim"),
    github("nvim-treesitter/nvim-treesitter-textobjects"),
    github('Wansmer/treesj'),

    github("tpope/vim-repeat"), -- needed by vim-surround
    github("tpope/vim-surround"),

    github("echasnovski/mini.nvim"),

})

vim.cmd.packadd("vim-be-good")
vim.cmd.packadd("vim-surround")
require("which-key").setup({
    delay = 750,
})

-- Lazy load these whenever vim gets around to it
vim.schedule(function()
    vim.cmd.packadd("nvim.undotree")
end)

-- vim.pack.add does the download
-- ":packadd name" or require("name") loads it. this allows for lazy loading
-- ^^^This only applies to init.lua though; everywhere else loading is auto.
-- Alternative you can use opts.load=true in package spec

vim.api.nvim_create_user_command("PackOpenUI", function()
    vim.pack.update(nil, { offline = true })
end, {})

require("plugins")
require("vim_settings")
require("keymaps")
require("statusline")
require("abbreviations")
require("crunner")
require("text_objects")
require("operators")
require("user_commands")
require("capitalize")
require("custom_command")
require("commenting")
require("treesitter")
require("surround")
require("sitelen")

require("diagram")
require("custom_semicolon_repeat") -- I think this might need to be required after all keymaps are created

require("dymaxion-chronofile")

require("snippets")

-- What if i tried using the mouse for once?
-- :h popup-menu
vim.cmd([[menu PopUp.Pop\ Tag\ Stack <cmd>pop<cr>]])

-- to go further, couldn't you have a smalltalk like interface with this system?

-- i rarely use termdebug, so best to leave it unloaded until it's actually needed
vim.api.nvim_create_user_command("TermThatDebugMyGuy", function()
    vim.cmd("packadd termdebug")
    vim.keymap.set("n", "<leader>da", "<cmd>Asm<cr>", { desc = "Debug: Asm" })
    vim.keymap.set("n", "<leader>db", "<cmd>Break<cr>", { desc = "Debug: Breakpoint (:Clear to undo)" })
    vim.keymap.set("n", "<leader>dc", "<cmd>Continue<cr>", { desc = "Debug: Continue" })
    vim.keymap.set("n", "<leader>de", "<cmd>Evaluate<cr>", { desc = "Debug: Evaluate" })
    vim.keymap.set("n", "<leader>dn", "<cmd>Over<cr>", { desc = "Debug: Next (step over)" })
    vim.keymap.set("n", "<leader>ds", "<cmd>Step<cr>", { desc = "Debug: Step (step into)" })
    vim.keymap.set("n", "<leader>dv", "<cmd>Var<cr>", { desc = "Debug: Show variables" })
end, {})

vim.cmd.packadd("nvim.undotree")

-- TODO I think we need to move ftplugins out of after. editorconfig is not
-- currently working and i think this is why

-- make gx work on wsl. fckin windows
local EXECUTABLE_EXISTS = 1
if vim.fn.executable("explorer.exe") == EXECUTABLE_EXISTS then
    -- i think this only works for files, not all URIs, but ehh good enough
    local function get_uri_under_cursor()
        return vim.fn.expand("<cfile>")
    end
    vim.keymap.set("n", "gx", function()
        local path = get_uri_under_cursor()
        print("Opening", path, "could take a few seconds though because WSL is literal poop from a butt")
        vim.ui.open(path, {
            cmd = { "explorer.exe" }
        })
    end)
end

-- TODO maybe it'd be nice to have a utility function in my config that just
-- dumps a bunch of autocmd info for the given bufnr. something to think
-- about. or maybe vim has an autocommand debug mode like this builtin?
-- vim.api.nvim_create_autocmd({ "BufLeave" }, {
--     callback = function() print"BufLeave" end,
-- })
-- vim.api.nvim_create_autocmd({ "BufHidden" }, {
--     callback = function() print"BufHidden" end,
-- })
-- vim.api.nvim_create_autocmd({ "BufUnload" }, {
--     callback = function() print"BufUnload" end,
-- })
-- vim.api.nvim_create_autocmd({ "BufWipeout" }, {
--     callback = function() print"BufWipeout" end,
-- })
