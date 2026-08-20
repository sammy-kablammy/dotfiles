override_whitespace_settings("spaces", 3)

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
