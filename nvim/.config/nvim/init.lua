function GetCurrentLine()
    local current_cursor_row_number, current_cursor_col_number = unpack(vim.api.nvim_win_get_cursor(0))
    -- oh my god WHY ARE COLUMNS ZERO BASED WHEN LINE NUMBERS ARE 1 BASED (i am
    -- going to attack somebody)
    local current_line = vim.api.nvim_buf_get_lines(0, current_cursor_row_number - 1, current_cursor_row_number, false)
    return current_line[1] -- ew. [1].
end

math.randomseed(os.time())
local function print_random_startup_message()
    local messages = {
        '🤓🤓 neovim, btw 🤓🤓',
        '👀 hello neovimmers',
        'any neovimmers?? 👀👀',
        'welcome to vscode',
        'kama pona tawa ilo Neowin',
        'Welcome to GNU Emacs, one component of the GNU/Linux operating system.',
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
            lazy = false,
            dependencies = {
                "rafamadriz/friendly-snippets",
                "saadparwaiz1/cmp_luasnip",
            },
        },
        {
            "hrsh7th/cmp-nvim-lsp",
            lazy = false,
            config = true,
        },
        {
            "hrsh7th/nvim-cmp",
            lazy = false,
            dependencies = {
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-buffer",
            },
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
        ft = "lua", -- only load on lua files
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
    },
    {
        "tpope/vim-surround",
        dependencies = {
            "tpope/vim-repeat",
        },
    },
    {
        "ziontee113/icon-picker.nvim",
        dependencies = {
            "stevearc/dressing.nvim",
        },
        config = function()
            require("icon-picker").setup({ disable_legacy_commands = true })
        end
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
    -- yeah i just don't use this
    -- {
    --     "debugloop/telescope-undo.nvim",
    --     dependencies = {
    --         "nvim-telescope/telescope.nvim",
    --         "nvim-lua/plenary.nvim",
    --     },
    -- },
    "ThePrimeagen/vim-be-good",
    {
        "echasnovski/mini.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- my custom plugins
    "sammy-kablammy/nvim_plugin_template",
    {
        "sammy-kablammy/simpletodo.nvim",
        init = function()
            require("simpletodo").setup({})
        end,
    },

    {
        "sammy-kablammy/linkma.nvim",
        config = function()
            local linkma = require("linkma")
            vim.api.nvim_create_autocmd({ "BufEnter" }, {
                pattern = { "*.md" },
                callback = function()
                    vim.api.nvim_buf_create_user_command(0, "LinkmaToc", linkma.toc_loclist, {})
                    vim.keymap.set("n", "<enter>", linkma.follow_link, { buffer = 0, desc = "follow link" })
                    -- link text object support
                    vim.keymap.set("x", "il", linkma.select_link_text_object, { buffer = 0, desc = "inner link" })
                    vim.keymap.set("o", "il", ":normal vil<cr>", { buffer = 0, desc = "inner link" })
                    vim.keymap.set("x", "al", function() linkma.select_link_text_object(true) end, { buffer = 0, desc = "around link" })
                    vim.keymap.set("o", "al", ":normal val<cr>", { buffer = 0, desc = "around link" })
                end,
            })
        end,
    },

    -- { dir = '~/my_neovim_plugins/showcase.nvim' },
    -- { dir = '~/my_neovim_plugins/simpletodo.nvim' },
    -- { dir = '~/my_neovim_plugins/commentma.nvim' },
})

-- ...and these are my config files :)
require("plugins")
require("vim_settings")
require("keymaps")
require("statusline")
require("abbreviations")
require("crunner")

-- this really belongs somewhere else
-- huh?
-- inspired by wtf.nvim (https://github.com/piersolenski/wtf.nvim)
vim.api.nvim_create_user_command("Huh", function()
    local diag = vim.diagnostic.get_next()
    if not diag then
        print("no diagnostics to search")
        return
    end
    -- there may be some URL characters that aren't escaped properly
    local formatted_msg = vim.fn.substitute(diag.message, " ", "%20", "g")
    formatted_msg = vim.fn.substitute(formatted_msg, ";", "%3b", "g")
    local ddg = [[https://duckduckgo.com/?t=lm&q=]]
    local search_query = ddg .. vim.bo.filetype .. "%20" .. formatted_msg
    vim.print(search_query)
    vim.ui.open(ddg .. search_query)
end, {})

-- for cleaner screen demos, TODO make a user command for toggling this
-- vim.o.colorcolumn = ""
-- vim.o.laststatus = 0

-- vim.cmd("packadd termdebug")
-- vim.keymap.set("n", "<leader>Da", "<cmd>Asm<cr>", { desc = "Debug: Asm" })
-- vim.keymap.set("n", "<leader>Db", "<cmd>Break<cr>", { desc = "Debug: Breakpoint (:Clear to undo)" })
-- vim.keymap.set("n", "<leader>Dc", "<cmd>Continue<cr>", { desc = "Debug: Continue" })
-- vim.keymap.set("n", "<leader>De", "<cmd>Evaluate<cr>", { desc = "Debug: Evaluate" })
-- vim.keymap.set("n", "<leader>Dn", "<cmd>Over<cr>", { desc = "Debug: Next (step over)" })
-- vim.keymap.set("n", "<leader>Ds", "<cmd>Step<cr>", { desc = "Debug: Step (step into)" })
