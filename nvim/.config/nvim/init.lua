math.randomseed(os.time())
local function print_random_startup_message()
    local messages = {
        '🤓🤓 neovim, btw 🤓🤓',
        '👀 hello neovimmers',
        'any neovimmers?? 👀👀',
        'welcome to vscode',
        'kama pona tawa ilo Neowin',
        'Welcome to GNU Emacs, one component of the GNU/Linux operating system.',
        'ed (the standard text editor)',
    }
    print(messages[math.random(#messages)])
end
print_random_startup_message()

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
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
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        -- or                              , branch = '0.1.x',
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    "numToStr/Comment.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "lewis6991/gitsigns.nvim",
    -- LSP
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
    },
    -- snippets
    {
        {
            "L3MON4D3/LuaSnip",
            dependencies = {
                "rafamadriz/friendly-snippets",
                "saadparwaiz1/cmp_luasnip",
            },
            event = "InsertEnter", -- this doesn't seem to work
        },
        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                -- "hrsh7th/cmp-path", -- mehhhhh just use <c-x><c-f> instead
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-nvim-lsp",
            },
            event = "InsertEnter", -- this doesn't seem to work
        },
    },
    {
        "folke/which-key.nvim",
        opts = {
            delay = 750,
        }
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    { -- optional completion source for require statements and module annotations
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, {
                name = "lazydev",
                group_index = 0, -- set group index to 0 to skip loading LuaLS completions
            })
        end,
        event = "InsertEnter",
    },
    {
        "tpope/vim-surround",
        dependencies = {
            "tpope/vim-repeat",
        },
        event = "CursorMoved",
    },
    {
        'Wansmer/treesj',
        dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
    },
    {
        -- (for the pretty vim.ui.input box used for LSP renaming; i could live without this one)
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
            require("icon-picker").setup({ disable_legacy_commands = true })
        end,
        event = "InsertEnter",
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2", -- TODO check back when harpoon2 is finished
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    },
    {
        "folke/todo-comments.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
        },
    },
    "ThePrimeagen/vim-be-good",
    {
        "echasnovski/mini.nvim",
        version = "*",
        -- dependencies = { "nvim-tree/nvim-web-devicons" },
    },
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

require("plugins")
require("vim_settings")
require("keymaps")
require("statusline")
require("abbreviations")
require("crunner")
require("text_objects")
require("user_commands")
require("capitalize")
require("custom_command")

-- i rarely use termdebug, so best to leave it unloaded until it's actually needed
vim.api.nvim_create_user_command("TermThatDebugMyGuy", function()
    vim.cmd("packadd termdebug")
    vim.keymap.set("n", "<leader>da", "<cmd>Asm<cr>", { desc = "Debug: Asm" })
    vim.keymap.set("n", "<leader>db", "<cmd>Break<cr>", { desc = "Debug: Breakpoint (:Clear to undo)" })
    vim.keymap.set("n", "<leader>dc", "<cmd>Continue<cr>", { desc = "Debug: Continue" })
    vim.keymap.set("n", "<leader>de", "<cmd>Evaluate<cr>", { desc = "Debug: Evaluate" })
    vim.keymap.set("n", "<leader>dn", "<cmd>Over<cr>", { desc = "Debug: Next (step over)" })
    vim.keymap.set("n", "<leader>ds", "<cmd>Step<cr>", { desc = "Debug: Step (step into)" })
end, {})
