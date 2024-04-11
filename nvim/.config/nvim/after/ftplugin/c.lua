vim.keymap.set(
    "n",
    "<leader><enter>",
    "<cmd>!gcc -std=gnu11 -lm -Wall -Werror %:p && %:h/a.out<cr>",
    { buffer = true }
)
