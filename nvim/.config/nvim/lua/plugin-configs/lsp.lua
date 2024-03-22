--[[
- mason: just a package manager that happens to be inside of neovim
  (but a package manager specifically for language servers)
- lspconfig: sets up language servers to work with neovim
- mason-lspconfig: an amalgam of features that make your life easier when
  working with both mason and lspconfig. the main benefit is automatically
  setting up servers installed via mason with lspconfig (otherwise you'll have
  to set each one up individually)
- null-ls/none-ls: takes CLI tools (which can't be easily used within neovim)
  and wraps them in a language server interface
- note on the two mason-* plugins: to make them automatically call setup on each
  server detected by mason, you need to set handlers. see each plugin's docs.
]]

-- SETUP ORDER REQUIREMENTS:
-- mason before any language servers
-- mason-lspconfig before lspconfig
-- mason-null-ls before null-ls
-- neodev before lspconfig

-- I used to have all the language servers i use in the 'ensure_installed'
-- fields but they aren't really necessary on most machines i use, so now you're
-- just gonna have to use this usercommand when you want to install LSPs.
vim.api.nvim_create_user_command("LspMe", function()
	-- NOTE: you need to use mason names, not lspconfig/null-ls names :(
	local my_servers = {
		-- for mason-lspconfig:
		"lua-language-server",
		"clangd",
		"jdtls",
		"pyright",
		"typescript-language-server",
		"css-lsp",

		-- careful installing too many things. especially with null-ls.
		-- they tend to conflict with each other

		-- for mason-null-ls:
		"stylua",
		"prettierd",
		"clang-format",
		"black",

		-- no
		-- "ltex",
		-- "remark_ls",
		-- "html-lsp", -- formatting is nicer than prettierd but it conflicts
	}
	for _, server in ipairs(my_servers) do
		vim.cmd("MasonInstall " .. server)
	end
end, { desc = "install all my preferred language servers" })

require("mason").setup({})

require("neodev").setup({})

require("mason-lspconfig").setup({
	-- ensure_installed = mason_lspconfig_set_these_up_please,
})

-- :h mason-lspconfig-automatic-server-setup
require("mason-lspconfig").setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({})
	end,
})

-- Global mappings.
-- TODO read this
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
-- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set("n", "<space>d", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist, {
	desc = "populate loclist from LSP",
})

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- i have no idea what this does 💀
		-- Enable completion triggered by <c-x><c-o>
		-- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		-- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		-- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		-- TODO read this
		-- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		-- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		-- vim.keymap.set('n', '<space>wl', function()
		--     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		-- end, opts)
		-- vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		-- format entire buffer
		vim.keymap.set("n", "<leader>lf", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
		-- format selection
		vim.keymap.set("v", "<leader>lf", function()
			vim.lsp.buf.format({
				async = true,
				range = {
					["start"] = vim.api.nvim_buf_get_mark(0, "<"),
					["end"] = vim.api.nvim_buf_get_mark(0, ">"),
				},
			})
		end)
        -- TODO use this more
		vim.keymap.set("i", "<C-h>", function()
			vim.lsp.buf.signature_help()
		end)

		-- print("LSP successfully attached 😊")
	end,
})

require("mason-null-ls").setup({
	-- A list of sources to install if they're not already installed.
	-- This setting has no relation with the `automatic_installation` setting.
	-- ensure_installed = mason_null_ls_setup_these_please,
	ensure_installed = {},
	automatic_installation = true,
	handlers = {},
})

-- setting up null-ls is not required if you only use mason-null-ls.
-- if you have custom servers not found in mason, then you have to manually set
-- them up here. see :h null-ls-setup

-- you can install gdtoolkit with: pip3 install "gdtoolkit==4.*"
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.gd",
	callback = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.diagnostics.gdlint,
				null_ls.builtins.formatting.gdformat,
			},
		})
		-- require('lspconfig').gdscript.setup({})
	end,
})

vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>")
vim.keymap.set("n", "<leader>ll", "<cmd>LspLog<cr>")
vim.keymap.set("n", "<leader>ls", "<cmd>LspStop<cr>")
vim.keymap.set("n", "<leader>ln", "<cmd>NullLsInfo<cr>")
