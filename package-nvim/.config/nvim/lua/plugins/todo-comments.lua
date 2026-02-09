-- https://github.com/folke/todo-comments.nvim

vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<cr>")

-- require('todo-comments').setup {
--     signs = true,      -- show icons in the signs column
--     sign_priority = 8, -- sign priority
--     keywords = {
--         FIX = {
--             icon = " ", -- icon used for the sign, and in search results
--             color = "error", -- can be a hex color, or a named color (see below)
--             alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
--             -- signs = false, -- configure signs for some keywords individually
--         },
--         TODO = { icon = " ", color = "info" },
--         HACK = { icon = " ", color = "warning" },
--         WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
--         PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
--         NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
--         TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
--     },
--     gui_style = {
--         fg = "NONE",       -- The gui style to use for the fg highlight group.
--         bg = "BOLD",       -- The gui style to use for the bg highlight group.
--     },
--     merge_keywords = true, -- when true, custom keywords will be merged with the defaults
--     -- highlighting of the line containing the todo comment
--     -- * before: highlights before the keyword (typically comment characters)
--     -- * keyword: highlights of the keyword
--     -- * after: highlights after the keyword (todo text)
--     highlight = {
--         multiline = false,              -- enable multine todo comments
--         multiline_pattern = "^.",       -- lua pattern to match the next multiline from the start of the matched keyword
--         multiline_context = 10,         -- extra lines that will be re-evaluated when changing a line
--         before = "",                    -- "fg" or "bg" or empty
--         keyword = "wide",               -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
--         after = "fg",                   -- "fg" or "bg" or empty
--         pattern = [[.*<(KEYWORDS)\s*]], -- pattern or table of patterns, used for highlighting (vim regex)
--         comments_only = true,           -- uses treesitter to match keywords in comments only
--         max_line_len = 400,             -- ignore lines longer than this
--         exclude = {},                   -- list of file types to exclude highlighting
--     },
--     -- list of named colors where we try to extract the guifg from the
--     -- list of highlight groups or use the hex color if hl not found as a fallback
--     colors = {
--         error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
--         warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
--         info = { "DiagnosticInfo", "#2563EB" },
--         hint = { "DiagnosticHint", "#10B981" },
--         default = { "Identifier", "#7C3AED" },
--         test = { "Identifier", "#FF00FF" }
--     },
--     search = {
--         command = "rg",
--         args = {
--             "--color=never",
--             "--no-heading",
--             "--with-filename",
--             "--line-number",
--             "--column",
--         },
--         -- regex that will be used to match keywords.
--         -- don't replace the (KEYWORDS) placeholder
--         pattern = [[\b(KEYWORDS):]], -- ripgrep regex
--         -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
--     },
-- }



-- experimental todo highlighting myself

-- this version started to use extmarks, not done
function SimplerTodoWithNvimAPI()
    local ns_id = vim.api.nvim_create_namespace("todo_highlighting")
    local line = 5
    local col = 2
    vim.api.nvim_buf_set_extmark(0, ns_id, line, col, {
        -- end_row = 74,
        end_col = 20,
        hl_group = "Cursor",
    })
    -- Could also use signs in the signcolumn, quickfix/loclist integration, etc.
end

-- instead of doing the nvim api stuff, you can just do
-- :match MyHighlightGroup /some_regex/
function SimplerTodo()
    if vim.bo.commentstring == "" and vim.api.nvim_buf_get_name(0) ~= "" then
        print("No commentstring! Cannot highlight todos")
        return
    end

    -- Trying to get colors from builtin highlight groups
    local color = vim.fn.synIDattr(vim.fn.hlID("TermCursor"), "bg#")
    -- vim.print(color)

    -- see ':h attr-list' for things that can go after 'gui='
    vim.cmd.highlight("SimplerTodo gui=bold guifg=#eeeeee guibg=#227799")
    -- test TODO here

    -- we don't "correctly" parse commentstring, just the first 'token' of it
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    -- Since the :match regex has slashes, vim gets confused when there are
    -- unescaped slashes in the commentstring
    commentmarker = vim.fn.substitute(commentmarker, '/', [[\\/]], "g") -- holy escaping

    local regex = '/' .. commentmarker .. " TODO.*$" .. '/'
    vim.cmd.match("SimplerTodo " .. regex)
end

-- need quickfix/loclist integration, and all of (todo, warn, hack, note)

-- we don't need signcolumn integration. The highighting is enough.

-- aside from that i think this is production ready 😏 SHIP IT

-- Need to use an autocommand because 'commentstring' isn't set right away
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = SimplerTodo,
})
