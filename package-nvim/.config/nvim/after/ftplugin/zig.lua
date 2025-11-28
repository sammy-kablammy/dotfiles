-- help for vim's builtin ftplugin found here: https://github.com/ziglang/zig.vim

-- by default, the zig ftplugin opens the location list on save. i don't like this:
vim.g.zig_fmt_autosave = false

vim.keymap.set("n", "<leader><enter>", "<cmd>!zig run %<enter>", { buffer = true, desc = "run current file" })
vim.keymap.set("n", "<leader>gt", "<cmd>!zig test %<enter>", { buffer = true, desc = "test current file" })

InsertMap("f", "while (i < len) : (i += i) {\n}<esc>O")
InsertMap("m", "pub fn main() void {<cr>}<esc>O")
InsertMap("p", 'std.debug.print("\\n", .{});<left><left><left><left><left><left><left><left><left><left>')

vim.b.sam_documentation_url = "https://ziglang.org/documentation/master/std/"
