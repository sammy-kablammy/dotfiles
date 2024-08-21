-- i used to use a statusline plugin but honestly vim's builtin statusline is
-- totally fine. besides, most statusline plugins aren't really hiding any
-- complexity; they're horizontal abstractions. i'd rather avoid an extra
-- dependency in my config and just use the default one. 

-- :h statusline
-- :h lua-eval

-- always show statusline
vim.o.laststatus = 2
vim.o.showcmdloc = "statusline"
vim.o.ruler = false

local errorcolor = vim.api.nvim_get_hl(0, { name = "ErrorMsg" }).fg
local errorcolorhex = string.format('#%06x', errorcolor)
local titlecolor = vim.api.nvim_get_hl(0, { name = "Title" }).fg
local titlecolorhex = string.format('#%06x', titlecolor)
local bgcolor = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg
local bgcolorhex = string.format('#%06x', bgcolor)
vim.cmd("highlight SamLspStatusLineTitle guifg=" .. titlecolorhex .. " guibg=" .. bgcolorhex)
vim.cmd("highlight SamLspStatusLineError guifg=" .. errorcolorhex .. " guibg=" .. bgcolorhex)
function LspStatusline()
    local retval = ""
    local num_servers = #vim.lsp.get_clients()
    local diagnostics = #vim.diagnostic.count()
	if num_servers ~= 0 then
        retval = retval .. "%#SamLspStatusLineTitle#LSPs:" .. num_servers .. "%#StatusLine#"
    end
    if diagnostics ~= 0 then
        retval = retval .. " %#SamLspStatusLineError#Diagnostics:" .. diagnostics .. "%#StatusLine#"
    end
    return retval
end
vim.o.statusline = [[ %f%< %m%r%=%S %{%luaeval("LspStatusline()")%} (%l,%c) ]]



-- TODO make a tabline
-- vim.o.tabline = ""
