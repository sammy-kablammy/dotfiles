function _custom_operator_func_listify()
    vim.cmd("'[,']normal I- ")
end
function listify()
    vim.o.operatorfunc = "v:lua._custom_operator_func_listify"
    vim.api.nvim_feedkeys("g@", "n", false)
end

function _custom_operator_func_numbered_listify()
    vim.cmd("'[,']normal I1. ")
end
function numbered_listify()
    vim.o.operatorfunc = "v:lua._custom_operator_func_numbered_listify"
    vim.api.nvim_feedkeys("g@", "n", false)
end

filetype_create_listify_keymaps = function()
    vim.keymap.set({ "n", "v" }, "gl", listify, {
        desc = "listify",
        buffer = true,
    })
    vim.keymap.set({ "n", "v" }, "gL", numbered_listify, {
        desc = "numbered listify",
        buffer = true,
    })
end
