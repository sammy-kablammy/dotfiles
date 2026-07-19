vim.keymap.set(
    "n",
    "<leader><enter>",
    -- TODO you need to output the file into the correct location, no? just dump it into /tmp/vim_c_run_temp_file, no need to delete
    -- "<cmd>!gcc -std=gnu11 -lm -Wall -Werror %:p && %:h/a.out<cr>",
    "<cmd>!gcc -o /tmp/c_executable_from_neovim % && /tmp/c_executable_from_neovim<cr>",
    { buffer = true }
)

-- vim.keymap.set("n", "<leader>m", vim.cmd.make, { buffer = true })

vim.bo.complete = ".,w,b,u" -- (because tag file is too big and slow)

create_filetype_snippets({
    ["p"] = 'printf("$1");',
    ["f"] = 'for (int i = 0; i < len; i++) {\n    $1\n}',
    ["m"] = 'int main(int argc, char **argv) {\n    $1\n}',
})
