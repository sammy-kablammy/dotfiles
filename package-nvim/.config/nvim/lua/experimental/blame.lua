-- 'git blame --porcelain' outputs one field per line, parse this into a table.
-- Example:
-- read ! git blame -p -L 90,90 %
--[[
edd22d21d657b04b51c957620236cb349d084ef5 39 90 1
author sammy-kablammy
author-mail <98327570+sammy-kablammy@users.noreply.github.com>
author-time 1724250248
author-tz -0400
committer sammy-kablammy
committer-mail <98327570+sammy-kablammy@users.noreply.github.com>
committer-time 1725036811
committer-tz -0400
summary 2dot2files. big dotfiles revamp
filename nvim/.config/nvim/lua/plugins/gitsigns.lua
	    sign_priority = 6,
--]]
local parse_porcelain_git_blame = function(porcelain)
    local lines = vim.split(porcelain, "\n", {})

    -- First line is the commit SHA plus some numbers idk
    if #lines < 1 then
        print("we expected at least like, oh i don't know, 1 line, from git blame")
    end
    parsed = {}
    parsed["sha"] = vim.split(lines[1], ' ', {})[1]

    -- Then,
    --   several author, committer lines
    --   summary
    --   filename

    -- Final line is empty, second to last is the line itself. Ignore. both
    -- of those. Hence the - 2.
    for i = 2, #lines - 2, 1 do
        local value_start_idx = string.find(lines[i], ' ')
        print("value_start_idx:", value_start_idx)
        local field_name = string.sub(lines[i], 1, value_start_idx - 1)
        -- print("i=", i, lines[i], value_start_idx)
        local field_value = string.sub(lines[i], value_start_idx + 1)

        parsed[field_name] = field_value
    end

    return parsed
end

-- Asynchronously run `git blame`, the callback on_complete receives the
-- formatted blame line.
local get_current_line_blame = function(on_complete)

    if vim.is_callable(on_complete) then
        print("Is callable")
    else
        print("Is NOT callable")
    end

    local row = unpack(vim.api.nvim_win_get_cursor(0))
    -- TODO assert row is a valid line number
    local filename = vim.api.nvim_buf_get_name(0)
    -- TODO assert filename is valid
    local obj = vim.system({
        "git",
        "blame",
        "--porcelain",
        "-L",
        row .. "," .. row,
        filename,
    }, {
        timeout = 1000,
    }, function(out)
        if out.stdout == nil then
        end
        if out.stderr == nil then
        end
        local parsed = parse_porcelain_git_blame(out.stdout)
        -- vim.print(parsed)
        local msg = ""
        if parsed["committer"] == "Not Committed Yet" then
            msg = parsed["committer"]
        else
            msg = parsed["committer"] .. " : " .. parsed["author-time"] .. " : " .. parsed["summary"]
        end
        on_complete(msg)
    end)
end

local BLAME_NAMESPACE_NAME = "sam_git_blame_namespace"
local BLAME_HIGHLIGHT_GROUP = "MatchParen"

-- Given a blame message, insert virtual text on the given line.
local set_blame_virtual_text = function(msg, line_number)
    local ns_id = vim.api.nvim_create_namespace(BLAME_NAMESPACE_NAME)
    -- Clear old extmarks
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, 9999999)
    -- Set new extmark
    vim.api.nvim_buf_set_extmark(0, ns_id, line_number, line_number, {
        -- hl_group = BLAME_HIGHLIGHT_GROUP,
        virt_lines = { { "Hello", BLAME_HIGHLIGHT_GROUP }, { "World", BLAME_HIGHLIGHT_GROUP } },
        virt_text_pos = "eol",
    })
end

-- NOTE
-- CursorMoved should WIPE the existing extmarks. Cursor sitting still should
-- generate a new one on the current line.
--
-- Also this should all be more inlined. more carmackian

-- local do_blame = false
-- vim.api.nvim_create_autocmd({ "CursorMoved" }, {
--     callback = function(ev)
--         if not do_blame then
--             return
--         end
--         get_current_line_blame(function(msg)
--             local line_number = unpack(vim.api.nvim_win_get_cursor(0))
--             set_blame_virtual_text(msg, line_number)
--         end)
--     end,
--     group = SAM_AUGROUP,
--     desc = "show git blame on end of line",
-- })
