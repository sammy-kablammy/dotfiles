-- Note that the compiled spellfile will be suffixed '.spl'
local my_spellfile = vim.fs.joinpath(vim.fn.stdpath("config"), "spell", "en.utf-8.add")

local ensure_spell_file_is_built = function()
    local target = my_spellfile .. ".spl"
    vim.uv.fs_stat(target, function(err, stat)
        if err == nil then
            return -- Spellfile already exists :)
        end
        vim.defer_fn(function() vim.cmd("mkspell! " .. my_spellfile) end, 0)
        if not vim.uv.fs_stat(target) then
            print("Failed to build spellfile '" .. my_spellfile .. "'.")
        else
            print("Built spellfile '" .. my_spellfile .. "'.")
        end
    end)
end
-- Use vim.schedule so this happens after startup (otherwise it breaks)
vim.schedule(ensure_spell_file_is_built)
