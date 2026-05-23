-- square bracket keymaps are kinda annoying to retype over and over again. Make
-- semicolon repeat the previous square bracket jump. This could apply to other
-- things too, not just square brackets.

-- I think a better API might be, instead of a single table of "keymaps to be
-- semicolon-repeated", have a function like "enable_semicolon_repeat(mode,lhs)"
-- and just call that for every map you want to repeat. that way this can exist
-- in my treesitter.lua file for example, at the definition site of those
-- mappings.

-- working title "ilo-sin"

is_custom_repeat = false

repeat_callback = nil

vim.keymap.set("n", ";", function()
    -- print("semicolon repeat")
    if not is_custom_repeat then
        -- this works without infinite looping???!!??
        vim.api.nvim_feedkeys(";", "n", false)
        return
    end
    if repeat_callback == nil then
        print("Somehow tried to invoke repeat_callback despite repeat_callback being null?")
        return
    end
    repeat_callback()
end, { desc = "custom semicolon repeat" })

-- TODO preserve vim.keymap.set's options
function get_keymap_rhs_callback(mode, lhs)
    local map = vim.fn.maparg(lhs, mode, false, true)
    -- TODO if map.rhs is non-null, it's a regular, non-callback keymap.
    -- I should wrap feedkeys in a function and return THAT so we're
    -- always returning a function here.
    return map.callback
end

-- Could probably use maplist() or nvim_get_keymap() to automatically build this
-- table based on which LHSs start with a bracket, but for now manual is ok
local keymaps_using_custom_semicolon_repeat = {
    n = {
        "[h",
        "]h",
        "[o",
        "]o",
        "[l",
        "]l",
        "[b",
        "]b",
    },
    -- v = {
    --     "[h",
    --     "]h",
    --     "[o",
    --     "]o",
    --     "[l",
    --     "]l",
    --     "[b",
    --     "]b",
    -- },
    -- TODO take a pass over this whole file and think about how it should
    -- support different modes. currently most things assume normal mode. i've
    -- played with this a little but at least something would always break,
    -- often regular 'f' in normal or visual modes.
}
-- When one of the marked keymaps is pressed, set a flag telling semicolon that
-- it ought to custom repeat instead of default repeat
for mode, keymaps in pairs(keymaps_using_custom_semicolon_repeat) do
    -- Assert mode string is valid
    local valid_modes = { "n", "i", "v", "x" } -- List comes from :h nvim_set_keymap()
    if not vim.tbl_contains(valid_modes, mode) then
        print("Errmmmm, '" .. mode .. "' is not a valid vim mode")
        break
    end
    -- Make mappings
    for _, mapping in pairs(keymaps) do
        -- print(mode, mapping)
        local original_rhs = get_keymap_rhs_callback(mode, mapping)
        vim.keymap.set(mode, mapping, function()
            original_rhs()
            is_custom_repeat = true
            repeat_callback = original_rhs
        end)
    end
end

-- When f/t/F/T/friends are pressed, unset the flag so that semicolon will now
-- do the default thing. Or maybe this will be unnecessary if we just treat
-- f/t/F/T the same as marked keymaps
-- vim.print(get_keymap_rhs_callback("n", "f"))
--
-- Since 'f' is built we have to use feedkeys, should work fine though since
-- vim.keymap.set defaults to non-recursive mappings
for _, f in pairs({ "f", "F", "t", "T" }) do
    vim.keymap.set("n", f, function()
        is_custom_repeat = false
        vim.api.nvim_feedkeys(f, "n", false)
    end)
end

-- TODO "include guard"... basically a way to ensure this file's setup only ever
-- happens once. if it happens multiple times that would be VERY BAD and would
-- likely cause infinitely recursive keymaps
