-- https://github.com/hrsh7th/nvim-cmp
-- https://github.com/L3MON4D3/LuaSnip
-- https://github.com/rafamadriz/friendly-snippets
-- https://github.com/saadparwaiz1/cmp_luasnip
-- https://github.com/hrsh7th/cmp-nvim-lsp
-- https://github.com/hrsh7th/cmp-path
-- https://github.com/hrsh7th/cmp-buffer

--[[

what the heck are all these plugins doing?
- nvim-cmp displays a popup window for completion. gui stuff. it allows
  completion as you type but doesn't have any sources itself.
- luasnip expands snippets. this modifies the text in the buffer. (you know,
  the thing you wanted to do in the first place)
- friendly-snippets is a collection of snippets that people have made. it's used
  by luasnip

these are completion sources used by cmp. try disabling each one and see how
completion suggestions are changed.
- cmp_luasnip (unsurprisingly) bridges cmp and luasnip
- cmp-nvim-lsp gets completion suggestions from active language servers
- cmp-path gets completion suggestions file system
- cmp-buffer gets completion suggestions from the text in the current buffer.
  (this is basically replacing vim's builtin <c-n>)

as some random reddit user once said,
> "luasnip gives you the snippets feature, cmp gives you the autocompletion
> feature, while cmp-luasnip makes luasnip collaborate with cmp by allowing for
> snippets to show up in the cmp completion menu"

this whole situation is further complicated by the fact that i really like vim's
builtin completion, and i keep enabled alongside cmp-nvim-lua-cmp-lsp-whatever.
it's much simpler, really fast, and you can specify what kind of completion you
want (like tokens, file paths, lines, etc). the big downside is that vim's
builtin completion doesn't use LSP.

--]]

require("luasnip.loaders.from_vscode").lazy_load()

local cmp = require("cmp")
local luasnip = require("luasnip")

-- TODO why was this here?
-- vim.keymap.set({ "i", "s" }, "<C-l>", function() luasnip.jump(1) end, { silent = true })
-- vim.keymap.set({ "i", "s" }, "<C-p>", function() luasnip.jump(-1) end, { silent = true })

cmp.setup({
    enabled = function()
        local filetype = vim.o.filetype
        return not (filetype == "TelescopePrompt")
    end,
    performance = {
        -- these is supposed to make things faster, idrk
        -- bonkers. why isn't this the default behavior?? so much more usable.
        debounce = 0,
        throttle = 0,
    },
    -- only offer suggestions on keypress; don't have a popup window constantly
    -- appearing with suggestions.
    completion = {
        autocomplete = false,
    },
    window = {
        documentation = cmp.config.window.bordered(),
        -- completion = cmp.config.window.bordered(),
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({

        -- Use <c-l> ("L" for "Lsp"). I don't like relying on LSP/snippets when
        -- the default (string-based) completion will do. Plus, builtin is way
        -- faster.
        ["<C-l>"] = cmp.mapping.complete(),
        ["<C-n>"] = function()
            if cmp.visible() then
                cmp.select_next_item()
            else
                vim.api.nvim_input("<c-x><c-n>")
            end
        end,
        ["<C-p>"] = function()
            if cmp.visible() then
                cmp.select_prev_item()
            else
                vim.api.nvim_input("<c-x><c-p>")
            end
        end,
        
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
    }),
})

vim.keymap.set("n", "<leader>lc", "<cmd>CmpStatus<cr>")
