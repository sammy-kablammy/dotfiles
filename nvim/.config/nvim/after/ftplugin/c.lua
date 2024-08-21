vim.keymap.set(
    "n",
    "<leader><enter>",
    -- TODO you need to output the file into the correct location, no? just dump it into /tmp/vim_c_run_temp_file, no need to delete
    -- "<cmd>!gcc -std=gnu11 -lm -Wall -Werror %:p && %:h/a.out<cr>",
    "<cmd>!gcc -o /tmp/c_executable_from_neovim % && /tmp/c_executable_from_neovim<cr>",
    { buffer = true }
)

InsertMap("p", "printf(\"\\n\");<left><left><left><left><left>")
InsertMap("f", "for (i = 0; i < len; i++) {\n}<esc>O")
InsertMap("m", "int main(void) {<cr>}<esc>O")
