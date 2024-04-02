-- what the heck are all these plugins doing?
--[[
- luasnip expands snippets. this modifies the text in the buffer. (you know,
  the thing you wanted to do in the first place)
- nvim-cmp displays a popup window. gui stuff, basically. (i think)
- friendly-snippets is a collection of snippets that people have made

these are completion sources. try disabling each one and see how completion
suggestions are changed.
- cmp-nvim-lsp gets completion suggestions from active language servers
- cmp-path gets completion suggestions file system
- cmp-buffer gets completion suggestions from the text in the current buffer.
    (this is basically replacing vim's builtin <c-n>)
- cmp_luasnip gives you whatever luasnip comes up with
--]]

require("luasnip.loaders.from_vscode").lazy_load()

local cmp = require("cmp")
local luasnip = require("luasnip")

vim.keymap.set({ "i", "s" }, "<C-L>", function()
	luasnip.jump(1)
end, { silent = true })

cmp.setup({
	-- WARNING: using this seems to break C-n and C-p in in telescope :(
	-- enabled = function()
	--     -- disable cmp in certain filetypes here. (probably.)
	--     local filetype = vim.api.nvim_get_option_value('filetype', {
	--         buf = 0,
	--     })
	--     return true
	-- end,
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
		{ name = "path" },
		{ name = "buffer" },
	}),
})

vim.keymap.set("n", "<leader>lc", "<cmd>CmpStatus<cr>")
