function TPLS()
    vim.lsp.start {
        name = "toki pona language server",
        cmd = {
            "npx", "ts-node",
            vim.fn.expand("~/tpls/server/src/server.ts")
        },
        capabilities = vim.lsp.protocol.make_client_capabilities()
    }
end

-- function TPLS()
-- vim.lsp.start {
--     name = "toki pona language server",
--     cmd = {
--         "node",
--         vim.fn.expand("~/tpls/jsonly/server.js")
--     },
--     capabilities = vim.lsp.protocol.make_client_capabilities()
-- }
-- end
