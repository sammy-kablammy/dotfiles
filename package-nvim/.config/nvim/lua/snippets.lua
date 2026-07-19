-- This will eventually replace InsertMap

--[[

I first tried using "ia" mode when creating keymaps to do snippets. But this
creates auto-expanding snippets, which I don't like. I want to *always* manually
trigger things like completion, LSP actions, snippet expansion, etc.

(In much the same way, I don't use "tab" to do magic completion; instead I rely
on Vim's builtin notion of several ctrl-x completion modes, e.g. identifiers in
open buffers, file paths, ctags. See :h ins-completion for the full list)

So this file defines a snippets-like experience just without the auto expansion.
Meaning I have to trigger the snippet myself. Instead of typing "fori<space>"
and having that automatically expand into a for-i loop, you would (in insert
mode) type "" for example.

Examples of what to use this for:
* new program boilerplate
* for loop boilerplate
* print statements

Remember to use the same binds for different filetypes for memorability.


Alternative ideas for the future:
- Use user completion <c-x><c-u>. Feels more vimmy

- have a list you can search through through vim.ui.select

--]]

local SNIPPET_LEADER = "<c-g>"

-- Universal snippets. These apply to all filetypes but can be overwritten.
local global_snippets = {
    ['h'] = 'hello',
    ['-'] = '->',
    [';'] = ':=',
}
for lhs, rhs in pairs(global_snippets) do
    vim.keymap.set("i", SNIPPET_LEADER .. lhs, function()
        vim.snippet.expand(rhs)
    end, { desc = "global snippet: " .. rhs })
end

-- TODO check for overriding of global snippets and warn about it

-- Filetype local snippets.
create_filetype_snippets = function(snippets)
    for lhs, rhs in pairs(snippets) do
        vim.keymap.set("i", SNIPPET_LEADER .. lhs, function()
            vim.snippet.expand(rhs)
        end, { buffer = true, desc = "filetype snippet: " .. rhs })
    end
end
-- Example usage:
-- create_filetype_snippets({
--     ['p'] = 'print("$1")',
--     ['f'] = 'for (${1:foo}; ${2:bar}; ${3:baz})',
-- })

-- Navigate snippets
-- Can't use <c-g>p because that's used for [p]rint.
vim.keymap.set({ "i", "v" }, "<c-g>p", function() vim.snippet.jump(-1) end)
vim.keymap.set({ "i", "v" }, "<c-g>n", function() vim.snippet.jump(1) end)
vim.keymap.set({ "i", "v" }, "<c-g><c-p>", function() vim.snippet.jump(-1) end)
vim.keymap.set({ "i", "v" }, "<c-g><c-n>", function() vim.snippet.jump(1) end)

-- snippets stay active after backing out into normal mode. don't do that.
vim.api.nvim_create_autocmd("ModeChanged", {
    callback = function(ev)
        if ev.match == "i:n" then
            -- vim.print(ev)
            vim.snippet.stop()
        end
    end,
})

-- what's the difference between completefunc and omnifunc? omnifunc is defined
-- by filetype (e.g. vim has builtin css properties omnicomplete) and
-- completefunc is defined by user. Anything I make for myself should be user
-- completion.
