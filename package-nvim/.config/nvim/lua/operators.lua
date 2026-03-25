function _custom_operator_func_listify()
    vim.cmd("'[,']normal I- ")
end
function listify()
    vim.o.operatorfunc = "v:lua._custom_operator_func_listify"
    vim.api.nvim_feedkeys("g@", "n", false)
end
