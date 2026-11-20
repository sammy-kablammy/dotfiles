create_filetype_snippets({
    ["p"] = 'println!("$1");',
    ["l"] = 'let $1: $2 = $3;',
    ["="] = '=>',
})

-- Cargo caches error messages, so if this is broken you should `touch` one of
-- your source files. Or `cargo clean` will also work
vim.bo.makeprg = "cargo clean && cargo check --message-format=short"
vim.bo.errorformat = "%f:%l:%c: %m"

vim.keymap.set("n", "<leader>m", vim.cmd.make, { buffer = true, desc = ":make" })

vim.keymap.set("n", "<leader><enter>", function()
    local cargo_toml = vim.fn.findfile("Cargo.toml", vim.fn.expand("%:p") .. ";")
    if cargo_toml == "" then
        print("Unable to find Cargo.toml, cannot cargo run")
        return
    end
    -- `cargo run` will recompile, but i do a redundant `make` here anyways so
    -- that the quickfix list can be populated in event of error
    local res = vim.cmd.make()
    print("sam", res)
    -- vim.cmd("! cargo run --message-format=short --manifest-path " .. cargo_toml)
end, { buffer = true })
