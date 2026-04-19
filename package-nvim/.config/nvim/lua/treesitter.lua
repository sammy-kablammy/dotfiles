--[[

RIP nvim-treesitter

Now using tree-sitter-manager to install parsers and keep track of grammars.
Open :TSManager and install parsers with 'i'
https://github.com/romus204/tree-sitter-manager.nvim

Still relying on tree-sitter-textobjects because it's 🔥🔥🔥
https://github.com/nvim-treesitter/nvim-treesitter-textobjects

...and treesj because i use it sometimes
https://github.com/Wansmer/treesj

--]]

--------------------------------- stock neovim ---------------------------------

vim.keymap.set('n', '<leader>ti', '<cmd>InspectTree<cr>')
vim.keymap.set('n', '<leader>te', '<cmd>EditQuery<cr>')
vim.keymap.set('n', '<leader>ts', '<cmd>InspectTree<cr><cmd>EditQuery<cr><cmd>wincmd =<cr>')
vim.keymap.set('n', '<leader>th', '<cmd>TSToggle highlight<cr>')

-- incremental selection is builtin nowadays, that's cool
-- Not sure which of these bindings to use yet
vim.keymap.set("v", "<c-h>", "an", { remap = "true", desc = "incremental selection", })
vim.keymap.set("v", "<c-l>", "in", { remap = "true", desc = "incremental selection" })
vim.keymap.set("v", "+", "an", { remap = "true", desc = "incremental selection", })
vim.keymap.set("v", "-", "in", { remap = "true", desc = "incremental selection" })
vim.keymap.set("v", "<c-space>", "an", { remap = "true", desc = "incremental selection" })

------------------------------ tree-sitter-manager -----------------------------

local tsm = require("tree-sitter-manager")
tsm.setup({
    ensure_installed = {
        -- The basics for vim
        "c",
        "vim",
        "vimdoc",
        "lua",
        "query",
        -- -- More basics
        "markdown",
        "gitignore",
        "gitcommit",
        "diff", -- this gives highlighting for git commits when "verbose" is enabled
        "bash",
        "make",
        -- -- Dotfiles
        "git_config",
        "ssh_config",
        -- "tmux", -- Tmux is broken for some reason
        -- -- For work 💼
        "cpp",
        "python",
        "cmake",
        "c_sharp",
        "bitbake",
        "nix",
        "dockerfile",
        -- -- Whatever
        "json",
        "yaml",
        "toml",
        "csv",
        "go",
        "gomod",
        -- "java",
        -- "html",
        -- "css",
        -- "javascript",
    }, -- list of parsers to install at the start of a neovim session
    -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
    -- auto_install = false, -- if enabled, install missing parsers when editing a new file
    -- highlight = true, -- treesitter highlighting is enabled by default
    -- languages = {}, -- override or add new parser sources
    -- parser_dir = vim.fn.stdpath("data") .. "/site/parser",
    -- query_dir = vim.fn.stdpath("data") .. "/site/queries",
})

---------------------------------- textobjects ---------------------------------

-- NOTE builtin matchit plugin supports "a%"

-- configuration
require("nvim-treesitter-textobjects").setup({
    select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
            -- ['@parameter.outer'] = 'v', -- charwise
            -- ['@function.outer'] = 'V', -- linewise
            -- ['@class.outer'] = '<c-v>', -- blockwise
            ["@function.inner"] = "V",
            ["@function.outer"] = "V",
            ["@loop.inner"] = "V",
            ["@loop.outer"] = "V",
            ["@conditional.inner"] = "V",
            ["@conditional.outer"] = "V",
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true of false
        include_surrounding_whitespace = false,
    },

    move = {
        -- whether to set jumps in the jumplist
        set_jumps = true,
    },

})

-- You can use the capture groups defined in `textobjects.scm`
-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
-- Example: gf this file
-- ~/.local/share/nvim/lazy/nvim-treesitter-textobjects/queries/lua/textobjects.scm

-- "Select" mappings:
local selectobj = require("nvim-treesitter-textobjects.select").select_textobject
vim.keymap.set({ "x", "o" }, "if", function() selectobj("@function.inner", "textobjects") end)
vim.keymap.set({ "x", "o" }, "af", function() selectobj("@function.outer", "textobjects") end)
vim.keymap.set({ "x", "o" }, "il", function() selectobj("@loop.inner", "textobjects") end)
vim.keymap.set({ "x", "o" }, "al", function() selectobj("@loop.outer", "textobjects") end)
vim.keymap.set({ "x", "o" }, "io", function() selectobj("@conditional.inner", "textobjects") end)
vim.keymap.set({ "x", "o" }, "ao", function() selectobj("@conditional.outer", "textobjects") end)
-- Don't know if i want this since 's' conflicts with sentences 🤔
-- vim.keymap.set({ "x", "o" }, "as", function() selectobj("@local.scope", "locals") end)

-- "Move" mappings:
local move = require("nvim-treesitter-textobjects.move")
vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end)
-- keymaps [l and ]l are used for location list, so use 'o' for both conditions AND loops:
vim.keymap.set({ "n", "x", "o" }, "]o", function()
    move.goto_next_start({ "@conditional.outer", "@loop.outer" }, "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]O", function()
    move.goto_next_end({ "@conditional.outer", "@loop.outer" }, "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[o", function()
    move.goto_previous_start({ "@conditional.outer", "@loop.outer" }, "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[O", function()
    move.goto_previous_end({ "@conditional.outer", "@loop.outer" }, "textobjects")
end)

-- "Swap" mappings (i haven't really used these)
local swap = require("nvim-treesitter-textobjects.swap")
vim.keymap.set("n", "<leader>tn", function()
    swap.swap_next("@parameter.inner")
end)
vim.keymap.set("n", "<leader>tp", function()
    swap.swap_previous("@parameter.inner")
end)

------------------------------------ treesj ------------------------------------

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
