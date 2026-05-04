local M = {}

M.check = function()
    vim.health.start("sam's checkhealth")

    if vim.g.sam_notes_path == nil then
        vim.health.error("notes path variable not defined")
    elseif vim.uv.fs_stat(vim.g.sam_notes_path) == nil then
        vim.health.error("notes directory does not exist")
    else
        vim.health.ok("found valid notes directory")
    end

end

return M
