-- Automatically update spellfile


-- local spellfile = "/home/sam/.config/nvim/spell/en.utf-8.add.spl"

-- TODO must do this after dictionary is actually set
-- vim.uv.fs_stat(vim.opt.dictionary:get())

-- testword

-- -- TODO If spell file is older than 1 day, update it (asynchronously)
-- vim.uv.fs_stat(spellfile, function(err, stat)
--     if err ~= nil then
--         -- Spellfile probably just doesn't exist yet
--         -- vim.defer_fn(function() vim.cmd("mkspell! " .. spellfile) end, 0)
--         return
--     end
--     -- vim.print(stat.mtime)
-- end)

vim.api.nvim_create_user_command("MakeSpell", function()
    -- TODO I think nvim uses site/ now, consider changing spellfile location
    vim.cmd("mkspell! " .. spellfile)
end, { desc = "Generate spellfile into my preferred location" })

-- TODO research thesaurus setting
-- find some free thesaurus files, possibly like this one https://cgit.freedesktop.org/libreoffice/dictionaries/tree/
