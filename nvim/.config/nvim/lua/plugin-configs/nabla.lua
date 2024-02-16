local nabla = require("nabla")

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.tex", "*.md" },
	callback = function()
		-- toggle the equations!!!!
		vim.keymap.set("n", "<leader>lt", function()
			nabla.toggle_virt({ autogen = true })
		end, {
			desc = "'latex' - toggle nabla equations",
		})
		vim.keymap.set(
			"n",
			"K",
			function()
				nabla.popup({ border = "rounded" })
			end,
			-- this option makes the keybind buffer-local
			{ buffer = true }
		)
	end,
})
