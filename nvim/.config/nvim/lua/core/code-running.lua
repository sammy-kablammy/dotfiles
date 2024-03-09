function runc()
    local path = debug.getinfo(1).short_src
    local current_dir = path:match("(.-)[\\/][^\\/]-$") -- pure sorcery
    local template = current_dir .. "/ctemplate.c"

    -- first, we send the current selection into a new file. (trying to work
    -- with selections & complex shell commands simultaneously is annoying).
    -- also, we use 'w' so that the command doesn't delete the selection.
    vim.cmd([[silent '<,'>w ! cat > /tmp/code_running.c]])

    vim.cmd([[silent !sed '/REPLACEME/r /tmp/code_running.c' ]] .. template .. [[ > /tmp/code_running_final.c]])

    vim.cmd([[silent !gcc -o /tmp/code_running_executable /tmp/code_running_final.c]])
    vim.cmd([[!/tmp/code_running_executable]])
end

vim.keymap.set('v', '<leader>rc', runc)
