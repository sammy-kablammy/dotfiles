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
vim.keymap.set("n", "<leader>bn", "<cmd>!go test -bench=.<cr>", { buffer = true })
vim.keymap.set("n", "<leader>W", "<cmd>%!gofmt<cr><cmd>w<cr>", { buffer = true })
-- NOTE you can't just use <enter> because that messes with the keybind that
-- jumps to a quickfix list element... or does it??? maybe it just wasn't buffer
-- local before... 🤔🤔🤔
vim.keymap.set("n", "<leader><enter>", "<cmd>!go run %<cr>", { buffer = true })
vim.keymap.set("n", "<leader><leader><enter>", "<cmd>vert new | r!go run #<cr>", { buffer = true })

-- vim.api.nvim_create_autocmd({ "BufWrite" }, {
-- 	pattern = { "*.go" },
-- 	callback = function()
--         vim.cmd("silent %!gofmt")
-- 	end,
-- })

vim.cmd([[inoreabbrev ien if err != nil {]])
vim.cmd([[inoreabbrev ienf if err != nil {<cr>log.Fatal(err)<cr>}]])

-- TODO make a keybind that opens the docs (https://pkg.go.dev/std) in a browser
