-- https://github.com/nvim-treesitter/nvim-treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
-- https://github.com/Wansmer/treesj

vim.keymap.set('n', '<leader>tr', '<cmd>InspectTree<cr>')
vim.keymap.set('n', '<leader>ti', '<cmd>InspectTree<cr>')
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
            local max_filesize = 200 * 1024 -- 200 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
            -- tmux.conf highlighting is broken for some reason, just skip it
            if vim.bo.filetype == "tmux" then
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
            init_selection = "<NOP>", -- (default is gnn, which i don't want polluting my keymaps)
            node_incremental = "<c-h>",
            scope_incremental = "<NOP>",
            node_decremental = "<c-l>",
        },
    },

    -- :h nvim-treesitter-textobjects-modules
    textobjects = {
        move = {
            enable = true,
            set_jumps = false, -- don't clutter up the jumplist
            goto_next_start = {
                ["]f"] = "@function.outer",
            },
            goto_next_end = {
                ["]F"] = "@function.outer",
                ["]O"] = "@condition.outer",
                ["]L"] = "@loop.outer",
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[O"] = "@condition.outer",
                ["[L"] = "@loop.outer",
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
                -- capture groups are defined in:
                -- ~/.local/share/nvim/lazy/nvim-treesitter-textobjects/queries/<language>/textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["il"] = "@loop.inner",
                ["al"] = "@loop.outer",
                ["io"] = "@conditional.inner",
                ["ao"] = "@conditional.outer",
                -- Comments don't work for multiline comments, basically useless, i now have my own textobject for this
                -- ["ig"] = "@comment.inner",
                -- comment textobjects elsewhere
                -- ["ag"] = "@comment.outer",
                -- (markdown code blocks)
                ["ic"] = "@block.inner",
                ["ac"] = "@block.outer",
            },
            -- You can choose the select mode (default is charwise 'v')
            selection_modes = {
                -- ["@parameter.outer"] = "v", -- charwise
                -- ["@function.outer"] = "V", -- linewise
                -- ["@class.outer"] = "<c-v>", -- blockwise
                ["@function.inner"] = "V",
                ["@function.outer"] = "V",
                ["@loop.inner"] = "V",
                ["@loop.outer"] = "V",
                ["@conditional.inner"] = "V",
                ["@conditional.outer"] = "V",
                ["@block.inner"] = "V",
                ["@block.outer"] = "V",
            },
        },
        swap = {
            enable = true,
            swap_previous = {
                ["<leader>tp"] = "@parameter.inner",
                ["[a"] = "@parameter.inner",
            },
            swap_next = {
                ["<leader>tn"] = "@parameter.inner",
                ["]a"] = "@parameter.inner",
            },
        },
    },

})

-- (treesj does syntax-aware splitting and joining of lua tables and similar things)
local tsj = require("treesj")
tsj.setup({
    ---@type boolean Use default keymaps (<space>m - toggle, <space>j - join, <space>s - split)
    use_default_keymaps = false,
    ---@type boolean Node with syntax error will not be formatted
    check_syntax_error = true,
    ---If line after join will be longer than max value,
    ---@type number If line after join will be longer than max value, node will not be formatted
    max_join_length = 120,
    ---Cursor behavior:
    ---hold - cursor follows the node/place on which it was called
    ---start - cursor jumps to the first symbol of the node being formatted
    ---end - cursor jumps to the last symbol of the node being formatted
    ---@type 'hold'|'start'|'end'
    cursor_behavior = 'hold',
    ---@type boolean Notify about possible problems or not
    notify = true,
    ---@type boolean Use `dot` for repeat action
    dot_repeat = true,
    ---@type nil|function Callback for treesj error handler. func (err_text, level, ...other_text)
    on_error = nil,
    ---@type table Presets for languages
    -- langs = {}, -- See the default presets in lua/treesj/langs
})
vim.keymap.set("n", "<leader>tj", tsj.toggle)
