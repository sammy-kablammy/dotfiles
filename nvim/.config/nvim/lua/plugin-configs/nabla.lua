local nabla = require('nabla')

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { '*.tex', '*.md' },
    callback = function()
        vim.keymap.set('n', '<leader>eq', function()
            nabla.toggle_virt({ autogen = true })
        end)
        vim.keymap.set('n', 'K', function()
                nabla.popup({ border = 'rounded' })
            end,
            -- this option makes the keybind buffer-local
            { buffer = true }
        )
    end
})
