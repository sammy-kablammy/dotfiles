-- https://github.com/ThePrimeagen/harpoon

local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader><tab>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "harpoon list" })
vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "harpoon list" })
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "harpoon select 1" })
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "harpoon select 2" })
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "harpoon select 3" })
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "harpoon select 4" })
vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end, { desc = "harpoon select 5" })
vim.keymap.set("n", "<leader>6", function() harpoon:list():select(6) end, { desc = "harpoon select 6" })
vim.keymap.set("n", "<leader>7", function() harpoon:list():select(7) end, { desc = "harpoon select 7" })
vim.keymap.set("n", "<leader>8", function() harpoon:list():select(8) end, { desc = "harpoon select 8" })
vim.keymap.set("n", "<leader>9", function() harpoon:list():select(9) end, { desc = "harpoon select 9" })
vim.keymap.set("n", "<leader>0", function()
    harpoon:list():append()
    print("appended buffer to harpoon list! :)")
end, { desc = "harpoon append" })

vim.keymap.set("n", "[h", function() harpoon:list():prev() end, { desc = "previous harpoon" })
vim.keymap.set("n", "]h", function() harpoon:list():next() end, { desc = "next harpoon" })

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end
vim.keymap.set("n", "<leader>fa", function() toggle_telescope(harpoon:list()) end, { desc = "harpoon list telescope" })

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

vim.api.nvim_create_user_command("PoonMe", function()
    local len = harpoon:list():length()
    for i = 1, len, 1 do
        harpoon:list():select(i)
    end
end, { desc = "open all harpoon marked files" })

