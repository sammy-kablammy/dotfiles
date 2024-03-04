-- rough explanation of all the plugins (not entirely accurate but i don't feel
-- like researching any more so here you go):
--[[
- nvim-cmp displays a popup window. gui stuff, basically.
- cmp_luasnip provides nvim-cmp with a list of snippets
- luasnip is a source of snippets for nvim-cmp
- luasnip expands snippets. this modifies the text in the buffer. (you know,
    the thing you wanted to do the entire time)
- cmp-nvim-lsp gives you completion suggestions from language servers.
    you'll notice that if cmp-nvim-lsp is commented out, you don't get lsp stuff
- friendly-snippets is a collection of snippets that people have made
--]]

require("luasnip.loaders.from_vscode").lazy_load()

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
    -- only offer suggestions on keypress; don't have a popup window constantly
    -- appearing with suggestions.
    autocompletion = false,
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
		-- (C-n triggers the completion menu - no need to invoke it separately)
		-- ["<C-y>"] = cmp.mapping.complete(),
		-- ["<Tab>"] = cmp.mapping.confirm({ select = true }),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "path" },
		{ name = "buffer" },
	}),
})
