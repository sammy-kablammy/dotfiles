-- we love golang!!! hooray!!!

vim.bo.expandtab = false
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.b.sam_override_whitespace_settings = true

vim.bo.formatprg = "gofmt"

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
--     pattern = { "*.go" },
--     callback = function()
--         vim.cmd("silent %!gofmt")
--     end,
-- })

vim.cmd([[inoreabbrev ien if err != nil {]])
vim.cmd([[inoreabbrev ienf if err != nil {<cr>log.Fatal(err)<cr>}]])

vim.b.sam_documentation_url = "https://pkg.go.dev/std"

InsertMap("f", "for i := 0; i < len; i++ {\n}<esc>O")
InsertMap("m", "func main() {<cr>}<esc>O")
InsertMap("p", 'fmt.Println("")<left><left>')
