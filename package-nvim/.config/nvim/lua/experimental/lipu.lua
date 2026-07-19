
--[[

like mini files but without all the invisible text and stuff. Basically use the
signcolumn instead of weird characters so that yy can actually work.

important:
- should be able to manipulate the filesystem like a text buffer
- preview files as you scroll (unlike Netrw's preview system)
- Miller (of xu88 fame) columns
- Should have bidirectional telescope integration, not directly but should
  expose enough functionality to do things like open the current telescope
  selection in files, open the current dir in telescope, etc.

api:
open_file_explorer(directory) directory defaults to vim.fn.getcwd()

--]]

open_file_explorer = function(directory)
    if directory == nil then
        directory = vim.fn.getcwd()
    end
    print("Directory " .. directory)

    local contents = vim.fn.readdir(directory)
    vim.print(contents)
end
vim.keymap.set("n", "<leader><leader>l", open_file_explorer)
