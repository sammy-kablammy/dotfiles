-- we love golang!!! hooray!!!



-- vim.bo.expandtab = false
-- vim.bo.tabstop = 4
-- vim.bo.shiftwidth = 4
-- vim.bo.softtabstop = 4
-- vim.b.sam_override_whitespace_settings = true
override_whitespace_settings = function(kind, thickness)
    if kind == "tabs" then
        vim.bo.expandtab = false
    elseif kind == "spaces" then
        vim.bo.expandtab = true
    else
        print("Unknown indentation kind: '" .. kind .. "'")
    end
    vim.bo.tabstop = thickness
    vim.bo.shiftwidth = thickness
    vim.bo.softtabstop = thickness
    vim.b.sam_override_whitespace_settings = true
end
-- Yep this works :) time to port to all filetypes
override_whitespace_settings("tabs", 3)



vim.bo.formatprg = "gofmt"

-- integrate vim's :make command and quickfix list with go
vim.cmd("compiler go")
vim.o.makeprg = "go run"

vim.keymap.set("n", "<leader><enter>", "<cmd>!go run .<cr>", { buffer = true, desc = "run current file" })
vim.keymap.set("n", "<leader>gt", "<cmd>!go test .<cr>", { buffer = true, desc = "go test" })
-- gb is git blame right now
-- vim.keymap.set("n", "<leader>gb", "<cmd>!go test -bench=.<cr>", { buffer = true, desc = "go benchmark" })

vim.cmd([[inoreabbrev ien if err != nil {]])
vim.cmd([[inoreabbrev ienf if err != nil {<cr>log.Fatal(err)<cr>}]])

vim.b.sam_documentation_url = "https://pkg.go.dev/std"

InsertMap("f", "for i := 0; i < len; i++ {\n}<esc>O")
InsertMap("m", "func main() {<cr>}<esc>O")
InsertMap("p", 'fmt.Println("")<left><left>')
InsertMap("a", 'slice = append(slice, val)')
InsertMap("e", 'fmt.Fprintf(os.Stderr, "\\n")<left><left><left><left>')
