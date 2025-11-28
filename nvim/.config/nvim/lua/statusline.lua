-- i used to use a statusline plugin but honestly vim's builtin statusline is
-- totally fine. besides, most statusline plugins aren't really hiding any
-- complexity; they're horizontal abstractions. i'd rather avoid an extra
-- dependency in my config and just use the default one.

-- 'winbar' and 'tabline' are similar options that could go here

-- :h statusline
-- :h lua-eval

-- always show statusline
vim.o.laststatus = 2
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
    local num_servers = #vim.lsp.get_clients({ bufnr = 0 })
    local num_diagnostics = #vim.diagnostic.count()
    if num_servers ~= 0 then
        retval = retval .. "%#SamLspStatusLineTitle#LSP%#StatusLine#"
    end
    if num_diagnostics ~= 0 then
        retval = retval .. " %#SamLspStatusLineError#" .. num_diagnostics .. "%#StatusLine#"
    end
    return retval .. " "
end

local matchparencolor = vim.api.nvim_get_hl(0, { name = "MatchParen" }).fg
local matchparenhex = string.format('#%06x', matchparencolor)
vim.cmd("highlight SamStatusLineNoteTitle guifg=" .. matchparenhex .. " guibg=" .. bgcolorhex)
function StatusLineNoteTitle()
    if vim.bo.filetype ~= "markdown" then
        return ""
    end
    return "%#SamStatusLineNoteTitle# (" .. vim.fn.getline(1) .. ")%#StatusLine#"
end

function StatusLineFileformat()
    if vim.bo.fileformat == "unix" then
        return ""
    end
    return vim.bo.fileformat .. " "
end

function StatusLinePosition()
    local row = vim.fn.line(".")
    local col = vim.fn.col(".")
    -- Virtual column might be different for files with tabs
    local virtcol = vim.fn.virtcol(".")
    if col == virtcol then
        return "(" .. row .. "," .. col .. ")"
    end
    return "(" .. row .. "," .. col .. "/" .. virtcol .. ")"
end

-- Display typed keys at the bottom of the screen. Useful for screen sharing.
vim.g.enable_keylogger = "" -- nonempty string to enable, empty string to disable
local keylogger_size = 15
local keylog = ""
local keylog_position = 1
local onkey_namespace_id = vim.on_key(function(key, typed)
    local c = typed:byte()
    if c == nil then
        return
    end
    local is_visible_ascii_character = c >= string.byte(' ' ) and c <= string.byte('~')
    if not is_visible_ascii_character then
        return
    end
    keylog = keylog .. typed
    keylog_position = keylog_position + 1
end, 0)
function StatusLineKeylogger()
    if vim.g.enable_keylogger ~= "" then
        return "→ " .. keylog:sub(keylog_position - keylogger_size) .. " ←"
    else
        return ""
    end
end

local filename = '%{expand("%:.")}'
local cutoff_point = "%< "
local modified_flag = "%m"
local readonly_flag = "%r"
local keylog = '%{luaeval("StatusLineKeylogger()")}'
local padding = " %= "
local note_title = '%{%luaeval("StatusLineNoteTitle()")%}'
local fileformat = '%{luaeval("StatusLineFileformat()")}'
local lsp = '%{%luaeval("LspStatusline()")%}'
local position = '%{%luaeval("StatusLinePosition()")%}'
vim.o.statusline = " " ..
    filename ..
    cutoff_point ..
    modified_flag ..
    readonly_flag ..
    note_title ..
    padding ..
    keylog ..
    "    " ..
    " " ..
    fileformat ..
    lsp ..
    position

-- i haven't yet figured out how to make 'showcmdloc' use the statusline's %S
-- instead of the command line at the bottom line of the screen. when i try, it
-- just displays a : and nothing else. this would be nice though.

-- this is the part of the statusline that shows the name of the current file.
-- my statusline used to use %f (path relative to current directory), but this
-- doesn't properly relativize full paths (like with :edit /path/to/new/file).
-- you could instead use %F (absolute path), but i find this cluttered,
-- especially when the screen is split. expand("%:.") is a dirty hack to get
-- around vim's counterintuitive treatment of the % register by forcing the path
-- to be relative. this fixes the statusline for my purposes, but any other use
-- of the % register should also be formatted in this way IMO.
