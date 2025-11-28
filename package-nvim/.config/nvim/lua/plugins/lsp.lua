-- LSP configuration file for nvim v0.11 (no longer using lspconfig, mason, or
-- mason-lspconfig).

---------- global LSP configuration ----------

vim.diagnostic.enable(false) -- off by default but can toggle
vim.diagnostic.config({
    virtual_text = true,     -- (display diagnostics as end-of-line virtual text)
    -- virtual_lines = true, -- (display diagnostics as line-below virtual text)
})
vim.lsp.inlay_hint.enable(true)

vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true, wrap = false })
end, { desc = "previous diagnostic" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true, wrap = false })
end, { desc = "next diagnostic" })
vim.keymap.set("n", "<leader>d", function()
    vim.diagnostic.open_float()
    print("You can now use <c-w>d to show diagnostics.")
end, { desc = "diagnostic float" })
vim.keymap.set("n", "<leader>D", vim.diagnostic.setqflist, {
    desc = "populate qflist with diagnostics",
})
vim.keymap.set("n", "<leader>ld", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle LSP diagnostics" })

-- buffer-local LSP configuration
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Nvim has lots of builtin LSP keymaps now (see :h grn for all):
        -- * grn to rename
        -- * gra to do code actions
        -- * grr to get references
        -- * gri to goto implementation
        -- * K to hover
        local function bufmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = ev.buf })
        end
        -- i like having the option to use the dumber (but usually much faster)
        -- "goto definition" built into vim
        bufmap("n", "<leader>gd", vim.lsp.buf.definition, "LSP goto definition")
        bufmap("n", "<leader>gD", vim.lsp.buf.declaration, "LSP goto Declaration")
        bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "code actions")
        bufmap("i", "<C-h>", function()
            print("Nvim now uses <c-s> in Insert mode for signature help.")
        end)
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
        bufmap("n", "<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, "toggle inlay hints")
        -- print("LSP successfully attached 😊")
    end,
})

-- TODO How to replace LspStart? You'd need a way to map the current buffer's
-- filetype to its server name.
vim.api.nvim_create_user_command("MyLspStop", function()
    local current_buffer_clients = vim.lsp.get_clients({ bufnr = 0 })
    for i, client in ipairs(current_buffer_clients) do
        vim.lsp.enable(client.name, false)
    end
end, {})
vim.api.nvim_create_user_command("MyLspRestart", function()
    local current_buffer_clients = vim.lsp.get_clients({ bufnr = 0 })
    for i, client in ipairs(current_buffer_clients) do
        vim.lsp.enable(client.name, false)
        vim.lsp.enable(client.name, true)
    end
end, {})
vim.api.nvim_create_user_command("MyLspInfo", function()
    vim.cmd("checkhealth vim.lsp")
    print("Use ':checkhealth vim.lsp' instead.")
end, {})

---------- example config ----------

-- (as a first pass, these configs were originally copied from lspconfig)
-- :h lsp-quickstart
-- :h vim.lsp.Config

-- install luarocks, then 'sudo luarocks install lua-language-server' (this
-- may be broken on arm though)
vim.lsp.config["luals"] = {
    -- extra arguments can be added as separate strings within this table:
    cmd = { "lua-language-server" },
    -- automatically attach to these filetypes:
    filetypes = { "lua" },
    -- most->least priority (nested tables have equal precedence):
    root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            }
        }
    }
}
-- 🦐 Shrimply 🍤 comment this line out to disable LSPs
vim.lsp.enable("luals")

---------- ok here are the rest ----------

-- did you know clangd exists on arm? mason always broke on arm
vim.lsp.config["clangd"] = {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" }
}
vim.lsp.enable("clangd")

vim.lsp.config["gopls"] = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
}
vim.lsp.enable("gopls")

vim.lsp.config["jdtls"] = {
    cmd = { "jdtls", "-configuration", "/home/runner/.cache/jdtls/config", "-data", "/home/runner/.cache/jdtls/workspace" },
    filetypes = { "java" },
    root_markers = { ".git", "build.gradle", "build.gradle.kts", "build.xml", "pom.xml", "settings.gradle", "settings.gradle.kts" }
}
vim.lsp.enable("jdtls")

vim.lsp.config["basedpyright"] = {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    rorot_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true
            }
        }
    }
}
vim.lsp.enable("basedpyright")
