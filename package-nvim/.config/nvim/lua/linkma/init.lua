local M = {}

M.setup = function()
    -- stub
end

M.toc_loclist = function()
    vim.cmd([[
        lvimgrep /^\# / %
        lopen
    ]])
end

-- Find the next link in the buffer. Returns table with line number, starting
-- column, ending column, and text; returns nil if no links are found.
local function get_next_link()
    -- todo specify caseness in the regexes ("regeces"?)
    local standard_markdown_link = [[\[.*\](\S*)]]
    local wiki_link = "\\[\\[.*\\]\\]"
    local monstrous_regex = "\\m\\c" .. standard_markdown_link .. "\\|" .. wiki_link
    local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
    local bufnr = vim.fn.bufnr() -- (matchbufline doesn't support bufnr of 0)
    local matches = vim.fn.matchbufline(bufnr, monstrous_regex, current_line_num, "$")
    if #matches == 0 then
        return nil
    end
    local end_col = matches[1].byteidx + #(matches[1].text) - 1
    return { row = matches[1].lnum, start_col = matches[1].byteidx, end_col = end_col, text = matches[1].text }
end

M.follow_link = function()
    local match = get_next_link()
    if match == nil then
        return
    end
    local link = match.text
    local internet_link_pattern = [[\m\c(\(http\|https\):\/\/\(\(www\.\)\=\)\S*)]]
    local internet_match = vim.fn.matchstr(match.text, internet_link_pattern)
    local is_internet_link = #internet_match ~= 0
    if is_internet_link then
        local url_without_parens = internet_match:sub(2, -2)
        vim.ui.open(url_without_parens)
        return
    end
    local filename
    if match.text:sub(1, 2) == "[[" then
        -- this link is [[wiki style]]
        filename = match.text:sub(3, -3)
    else
        -- this link is [normal markdown style]()
        -- ugh. lua patterns use % to escape, not \. this got me for like 15 minutes
        local idx_of_paren = match.text:find("%(")
        filename = match.text:sub(idx_of_paren + 1, -2)
    end
    vim.cmd.edit(filename)
end

M.select_link_text_object = function(around)
    local match = get_next_link()
    if match == nil then
        return
    end
    vim.api.nvim_buf_set_mark(0, "<", match.row, match.start_col, {})
    if around then
        vim.api.nvim_buf_set_mark(0, ">", match.row, match.end_col + 1, {})
    else
        vim.api.nvim_buf_set_mark(0, ">", match.row, match.end_col, {})
    end
    vim.api.nvim_feedkeys("gv", "n", true)
end

local checkbox_pattern = "^[ \t]*- \\[[x ]\\]" -- this is abhorrent

M.next_checkbox = function()
    vim.fn.search(checkbox_pattern, "We")
end

M.previous_checkbox = function()
    vim.fn.search(checkbox_pattern, "Wbe")
end

M.toggle_checkbox = function()
    local line_number = vim.fn.search(checkbox_pattern, "Wncb")
    if line_number == 0 then
        return
    end
    local original = vim.fn.getline(line_number)
    local checkbox_start_pos = vim.fn.match(original, "\\[")
    local before_checkbox = string.sub(original, 1, checkbox_start_pos)
    local after_checkbox = string.sub(original, checkbox_start_pos + 4)
    local is_checked = string.sub(original, checkbox_start_pos + 2, checkbox_start_pos + 2) == "X"
    local new = ""
    if is_checked then
        new = before_checkbox .. "[ ]" .. after_checkbox
    else
        new = before_checkbox .. "[X]" .. after_checkbox
    end
    vim.fn.setline(line_number, new)
end

return M
