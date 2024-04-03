-- we love golang!!! hooray!!!

vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

vim.o.formatprg = "gofmt"

-- integrate vim's :make command and quickfix list with go
vim.cmd("compiler go")
-- i prefer "go run" to "go build" as "go run" won't produce a binary
vim.o.makeprg = "go run"

vim.keymap.set("n", "<leader>ts", "<cmd>!go test<cr>", { buffer = true })
vim.keymap.set("n", "<leader>W", "<cmd>%!gofmt<cr><cmd>w<cr><cmd>!go test<cr>", { buffer = true })
-- TODO consider <leader><enter> instead
vim.keymap.set("n", "<enter>", "<cmd>!go run %<cr>", { buffer = true })

-- vim.api.nvim_create_autocmd({ "BufWrite" }, {
-- 	pattern = { "*.go" },
-- 	callback = function()
--         vim.cmd("silent %!gofmt")
-- 	end,
-- })
