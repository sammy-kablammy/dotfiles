-- https://github.com/nvim-treesitter/nvim-treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects

vim.keymap.set('n', '<leader>tr', '<cmd>InspectTree<cr>')
vim.keymap.set('n', '<leader>te', '<cmd>EditQuery<cr>')
vim.keymap.set('n', '<leader>ts', '<cmd>InspectTree<cr><cmd>EditQuery<cr><cmd>wincmd =<cr>')
vim.keymap.set('n', '<leader>th', '<cmd>TSToggle highlight<cr>')

require("nvim-treesitter.configs").setup({
    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    -- List of parsers to ignore installing (for "all")
    -- ignore_install = { "javascript" },

    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

    highlight = {
        enable = true,

        -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)
        -- list of language that will be disabled
        -- disable = { "c", "rust" },
        -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
        disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<leader>ti",
            node_incremental = "<c-h>",
            -- scope_incremental = "",
            node_decremental = "<c-l>",
        },
    },

    -- this field is for nvim-treesitter-textobjects
    textobjects = {
        move = {
            enable = true,
            set_jumps = false, -- don't clutter up the jumplist
            goto_next_start = {
                ["]f"] = "@function.outer",
            },
            goto_next_end = {
                ["]F"] = "@function.outer",
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
            },
            goto_previous_end = {
                ["[F"] = "@function.outer",
            },
        },
        select = {
            enable = true,

            -- Automatically jump forward to textobjects, similar to targets.vim
            lookahead = true,
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                -- ["ac"] = "@class.outer",
                -- you can optionally set descriptions to the mappings (used in the desc parameter of nvim_buf_set_keymap
                -- ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },

                -- markdown code blocks
                -- note to self: see
                -- ~/.local/share/nvim/lazy/nvim-treesitter-textobjects/ and
                -- find the textobjects.scm files for the correct names
                ["ic"] = "@block.inner",
                ["ac"] = "@block.outer",

            },
            -- You can choose the select mode (default is charwise 'v')
            selection_modes = {
                ["@parameter.outer"] = "v", -- charwise
                ["@function.outer"] = "V", -- linewise
                -- ["@class.outer"] = "<c-v>", -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`. Can also be a function (see above).
            include_surrounding_whitespace = false,
        },
        swap = {
            enable = true,
            swap_previous = {
                ["<leader>tp"] = "@parameter.inner",
            },
            swap_next = {
                ["<leader>tn"] = "@parameter.inner",
            },
        },
    },
    -- okay that was nvim-treesitter-textobjects
})
