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

    vim.health.start("are LSPs installed?")
    local all_configs = vim.lsp.config._configs
    for name, config in pairs(all_configs) do
        local cmd = config.cmd[1]
        local COMMAND_IS_EXECUTABLE = 1
        if cmd and vim.fn.executable(cmd) == COMMAND_IS_EXECUTABLE then
            vim.health.ok("LSP server `" .. cmd .. "` (`" .. name .. "`) is executable 🤓")
        else
            vim.health.warn("LSP server `" .. cmd .. "` (`" .. name .. "`) is NOT executable")
        end
    end

end

return M
