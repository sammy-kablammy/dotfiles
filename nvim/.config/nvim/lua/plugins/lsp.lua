-- https://github.com/neovim/nvim-lspconfig
-- https://github.com/williamboman/mason.nvim
-- https://github.com/williamboman/mason-lspconfig.nvim

--[[

what plugins are needed:
- mason: just a package manager that happens to be inside of neovim (but a
    package manager specifically for language servers). mason servers aren't
    added to your path, they're just for nvim (see ~/.local/share/mason/bin).
- lspconfig: sets up language servers to work with neovim
- mason-lspconfig: an amalgam of features that make your life easier when
  working with both mason and lspconfig. the main benefit is automatically
  setting up servers installed via mason with lspconfig (otherwise you'll have
  to set each one up individually).

setup order requirements:
- mason before any language servers
- mason-lspconfig before lspconfig

]]

vim.diagnostic.enable(false)

-- i used to have all the language servers i use in the 'ensure_installed'
-- fields but they aren't really necessary on most machines i use, so now you're
-- just gonna have to use this usercommand when you want to install LSPs.
vim.api.nvim_create_user_command("LspMe", function()
    -- note: use mason names here, not lspconfig names
    local my_servers = {
        -- careful installing too many things. especially with null-ls.
        -- they tend to conflict with each other.
        "lua-language-server",
        "clangd",
        "jdtls",
        "pyright",
        "typescript-language-server",
        "css-lsp",
        "gopls",
    }
    for _, server in ipairs(my_servers) do
        vim.cmd("MasonInstall " .. server)
    end
end, { desc = "install all my preferred language servers" })

require("mason").setup({})
require("mason-lspconfig").setup({})
-- :h mason-lspconfig-automatic-server-setup
require("mason-lspconfig").setup_handlers({
    function(server_name)
        require("lspconfig")[server_name].setup({})
    end,
})

-- setup servers that aren't from mason
require("lspconfig").dartls.setup({})

-- global LSP mappings
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "diagnostic float" })
vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist, {
    desc = "populate loclist with diagnostics",
})
vim.keymap.set("n", "<leader>ld", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "LSP diagnostic enable/disable" })

-- buffer-local LSP mappings
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local function bufmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = ev.buf })
        end
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        -- note: K does LSP hover. this is nvim default behavior now, apparently
        bufmap("n", "gd", vim.lsp.buf.definition, "LSP goto definition")
        bufmap("n", "gD", vim.lsp.buf.declaration, "LSP goto Declaration")
        bufmap("n", "gr", vim.lsp.buf.references, "LSP get references")
        bufmap('n', '<leader>gi', vim.lsp.buf.implementation, "LSP goto implementation")
        bufmap("n", "<leader>lr", vim.lsp.buf.rename, "LSP rename")
        bufmap("n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
        bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "code actions")
        bufmap("i", "<C-h>", vim.lsp.buf.signature_help, "insert mode signature help")
        bufmap("n", "<leader>lf", function()
            vim.lsp.buf.format({ async = true })
        end, "LSP format entire buffer")
        bufmap("v", "<leader>lf", function()
            vim.lsp.buf.format({
                async = true,
                range = {
                    ["start"] = vim.api.nvim_buf_get_mark(0, "<"),
                    ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
                },
            })
        end, "LSP format selection")
        bufmap("i", "<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, "toggle inlay hints")
        -- print("LSP successfully attached 😊")
    end,
})

vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>")
vim.keymap.set("n", "<leader>ll", "<cmd>LspLog<cr>")
vim.keymap.set("n", "<leader>la", "<cmd>LspStart<cr>")
vim.keymap.set("n", "<leader>ls", "<cmd>LspStop<cr>")
