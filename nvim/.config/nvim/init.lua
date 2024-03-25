-- alias to pretty print
function P(args)
    vim.print(args)
end

function fmt()
    vim.lsp.buf.format()
end

if vim.g.vscode then
    print("👀 hello vscoders")
    vim.keymap.set("n", "j", "gj")
    vim.keymap.set("n", "k", "gk")
    require("core.misc-vim-stuff")
else
    print("👀 hello neovimmers")

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
        -- {
        --     "christoomey/vim-tmux-navigator",
        --     cmd = {
        --         "TmuxNavigateLeft",
        --         "TmuxNavigateDown",
        --         "TmuxNavigateUp",
        --         "TmuxNavigateRight",
        --         "TmuxNavigatePrevious",
        --     },
        --     keys = {
        --         -- { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
        --         { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
        --         { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
        --         -- { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
        --         { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        --     },
        -- },
        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.3",
            -- or                              , branch = '0.1.x',
            dependencies = { "nvim-lua/plenary.nvim" },
        },
        {
            -- { 'VonHeikemen/lsp-zero.nvim',        branch = 'v3.x' },
            --- Uncomment these if you want to manage LSP servers from neovim
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
            -- LSP Support
            {
                "neovim/nvim-lspconfig",
                dependencies = {
                    { "hrsh7th/cmp-nvim-lsp" },
                },
            },
            -- Autocompletion
            {
                "hrsh7th/nvim-cmp",
                dependencies = {
                    { "L3MON4D3/LuaSnip" },
                },
            },
        },
        "nvim-lualine/lualine.nvim",
        "numToStr/Comment.nvim",
        "nvim-treesitter/nvim-treesitter",
        "lewis6991/gitsigns.nvim",
        "folke/neodev.nvim",
        "nvimtools/none-ls.nvim",

        -- ##### NEW SNIPPET STUFF
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
            "jay-babu/mason-null-ls.nvim",
            event = { "BufReadPre", "BufNewFile" },
            dependencies = {
                "williamboman/mason.nvim",
                "nvimtools/none-ls.nvim",
            },
        },
        -- ##### okay that's the new snippet stuff

        {
            "folke/which-key.nvim",
            init = function()
                vim.o.timeout = true
                vim.o.timeoutlen = 500
            end,
        },
        {
            "ziontee113/icon-picker.nvim",
            dependencies = {
                "stevearc/dressing.nvim",
            },
        },
        {
            "ThePrimeagen/harpoon",
            branch = "harpoon2", -- TODO check back when harpoon2 is finished
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-telescope/telescope.nvim",
            },
        },
            "folke/todo-comments.nvim",
            "ThePrimeagen/vim-be-good",
            "jbyuki/nabla.nvim",
        {
            "echasnovski/mini.nvim",
            version = "*",
            dependencies = { "nvim-tree/nvim-web-devicons" },
        },
        { "David-Kunz/gen.nvim" },

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
                        vim.keymap.set("n", "<leader>ml", linkma.follow_link, {
                            buffer = 0, desc = "linkma: follow link"
                        })
                        vim.keymap.set("n", "gl", function()
                            print("this binding is being phased out. use <leader>ml")
                            linkma.follow_link()
                        end, { buffer = 0 })
                    end,
                })
            end,
        },
        -- { dir = '~/my_neovim_plugins/showcase.nvim' },
        -- { dir = '~/my_neovim_plugins/simpletodo.nvim' },
    })

    -- ...and these are my config files :)
    require("plugin-configs")
    require("core.keymaps")
    require("core.misc-vim-stuff")
    require("core.abbreviations")
    require("core.code-running")
end
