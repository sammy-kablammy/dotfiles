local harpoon = require("harpoon")

harpoon:setup()

local function map(lhs, rhs, desc)
    if desc then
        vim.keymap.set('n', '<leader><tab>' .. lhs, rhs, { desc = desc })
    else
        vim.keymap.set('n', '<leader><tab>' .. lhs, rhs, {})
    end
end

map('<Tab>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
'harpoon list')
map('a', function() harpoon:list():append() end, '-=> harpoon append <=-')
map('n', function() harpoon:list():select(1) end, 'harpoon select 1')
map('e', function() harpoon:list():select(2) end, 'harpoon select 2')
map('i', function() harpoon:list():select(3) end, 'harpoon select 3')
map('o', function() harpoon:list():select(4) end, 'harpoon select 4')

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
