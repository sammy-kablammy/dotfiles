vim.bo.expandtab = true
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.b.sam_override_whitespace_settings = true

vim.keymap.set({ "n", "v" }, "gl", listify, {
    desc = "listify",
    buffer = true,
})

-- This only applies to gitlab CI yaml files
if vim.fs.basename(vim.api.nvim_buf_get_name(0)) == ".gitlab-ci.yml" then
    -- a section is a job
    vim.keymap.set({ "n", "v" }, "[[", function()
        vim.fn.search("^\\S.*:$", "b")
    end, { desc = "previous job", buffer = true })
    vim.keymap.set({ "n", "v" }, "]]", function()
        vim.fn.search("^\\S.*:$")
    end, { desc = "next job", buffer = true })
end
