local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader><tab>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "harpoon list" })
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "harpoon select 1" })
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "harpoon select 2" })
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "harpoon select 3" })
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "harpoon select 4" })
vim.keymap.set("n", "<leader>0", function()
    harpoon:list():append()
    print("appended buffer to harpoon list! :)")
end, { desc = "harpoon append" })

-- create bindings within the harpoon window
harpoon:extend({
    UI_CREATE = function(cx)
        vim.keymap.set("n", "<C-v>", function()
            harpoon.ui:select_menu_item({ vsplit = true })
        end, { buffer = cx.bufnr })

        vim.keymap.set("n", "<C-x>", function()
            harpoon.ui:select_menu_item({ split = true })
        end, { buffer = cx.bufnr })

        vim.keymap.set("n", "<C-c>", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { buffer = cx.bufnr })
    end,
})
