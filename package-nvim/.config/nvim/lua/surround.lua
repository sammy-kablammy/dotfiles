--[[

custom vim surround
working title "ilo sike"

--]]

-- TODO handle nested parens (and other nestables). For example, the surrounding
-- parens here are NOT ("n"...function(). The function should be skipped over,
-- and we should match the final paren.
--     vim.keymap.set("n", "<leader><leader>ds", function())

-- When the user types dot, we don't call the result of the mapping; instead,
-- vim calls the recent 'operatorfunc' directly. That's how you can tell the
-- difference between a genuine operator and dot-repeated operator. So to handle
-- dot-repeat with surround operators, we maintain this state table between
-- calls. When the user types a surround operator, the state's is_dot is reset;
-- but when the user types dot, the is_dot retains its previous value and ch.
local dot_repeat_state = {
    is_dot = false,
    dot_char = '',
}

local function get_input_ch()
    -- Must pcall because <c-c> will cause vim to freak out
    local ok, ch = pcall(vim.fn.getcharstr)
    if not ok then
        return vim.keycode("<esc>")
    end
    if vim.fn.char2nr(ch) == 128 then
        -- This happens when you mispress alt when entering ch. Bail, otherwise
        -- you'd get a garbled ch.
        --
        -- If you eventually do want to read alt keys, you could use
        -- vim.fn.getchar (not getcharstr) with the right opts.
        return vim.keycode("<esc>")
    end
    return ch
end

-- Note that vim-surround also supports these:
--     'f' for "func(obj)"
--     '<' or 't' for "<tag>obj</tag>"
function desugar_ch(ch)
    local start_ch = ch
    local end_ch = ch
    if ch == '(' or ch == ')' or ch == 'b' then
        start_ch = '('
        end_ch = ')'
    elseif ch == '{' or ch == '}' or ch == 'B' then
        start_ch = '{'
        end_ch = '}'
    elseif ch == '[' or ch == ']' or ch == 'r' then
        start_ch = '['
        end_ch = ']'
    elseif ch == '<' or ch == '>' or ch == 'a' then
        start_ch = '<'
        end_ch = '>'
    end
    return start_ch, end_ch
end

function add_surround(start_line_num, start_col_num, end_line_num, end_col_num)
    -- Get character to surround object with.
    -- Currently 'ch' is only one character.
    local ch = dot_repeat_state.dot_char
    if not dot_repeat_state.is_dot then
        ch = get_input_ch()
        if ch == vim.keycode("<esc>") then
            return
        end
    end
    -- Save dot repeat state for later
    dot_repeat_state.is_dot = true
    dot_repeat_state.dot_char = ch
    -- For paired ch's, split ch into start and end
    local start_ch, end_ch = desugar_ch(ch)

    if start_line_num == end_line_num then

        -- Prepend ch to textobject's start
        local old_start_line = vim.fn.getline(start_line_num)
        local new_start_line = string.sub(old_start_line, 1, start_col_num - 1) .. start_ch .. string.sub(old_start_line, start_col_num)
        vim.fn.setline(start_line_num, new_start_line)

        -- (By appending ch to the start, we moved end_col_num right)
        end_col_num = end_col_num + string.len(start_ch)

        -- Append ch to textobject's end
        local old_end_line = vim.fn.getline(end_line_num)
        local new_end_line = string.sub(old_end_line, 1, end_col_num) .. end_ch .. string.sub(old_end_line, end_col_num + 1)
        vim.fn.setline(end_line_num, new_end_line)

    else
        -- Multi-line objects should probably behave like vim-surround. Add a
        -- new line above and below. Surrounding multiple lines with ([{ should
        -- probably indent the object too.

        -- Prepend ch to textobject's start
        local new_line = vim.text.indent(vim.fn.cindent(start_line_num), start_ch)
        vim.fn.append(start_line_num - 1, new_line)

        -- (By appending a line to the start, we moved end_line_num down)
        end_line_num = end_line_num + 1

        -- Append ch to textobject's end
        new_line = vim.text.indent(vim.fn.cindent(end_line_num), end_ch)
        vim.fn.append(end_line_num, new_line)

        if vim.tbl_contains({ '(', ')', '{', '}' }, ch) then
            print("TODO: indent object inside block")
            -- TODO when deleting surrounding {}, you should dedent the contents
        end

    end
end

function _custom_operatorfunc_surround()
    -- Get textobject to surround
    local start = vim.api.nvim_buf_get_mark(0, '[')
    local start_line_num = start[1]
    local start_col_num = start[2] + 1
    local _end = vim.api.nvim_buf_get_mark(0, ']')
    local end_line_num = _end[1]
    local end_col_num = _end[2] + 1
    -- Do the surround
    add_surround(start_line_num, start_col_num, end_line_num, end_col_num)
end
vim.keymap.set("n", "<leader><leader>ys", function()
    dot_repeat_state.is_dot = false

    vim.o.operatorfunc = "v:lua._custom_operatorfunc_surround"
    vim.api.nvim_feedkeys("g@", "n", false)
end, { desc = "add surround" })

-- TODO for some reason this breaks <leader><leader>ys
-- vim.keymap.set("n", "<leader><leader>yss", function()
--     dot_repeat_state.is_dot = false
--
--     local lnum = vim.api.nvim_win_get_cursor(0)[1]
--     local line = vim.fn.getline(lnum)
--
--     local get_first_non_whitespace_character = function(str)
--         local start_col = 1
--         while vim.tbl_contains({ " ", "\t" }, string.sub(line, start_col, start_col)) do
--             start_col = start_col + 1
--         end
--         return start_col
--     end
--
--     local start_col = get_first_non_whitespace_character(line)
--
--     -- NOTE vim-surround's yss goes to the last non-whitespace character on the
--     -- line, like the g_ motion. I just go to end of line.
--     local end_col = #line
--
--     add_surround(lnum, start_col, lnum, end_col)
--
--     -- Move cursor to the start of the changed line. This is how vim-surround
--     -- behaves on yss and it just feels more vimmy
--     -- vim.api.nvim_feedkeys("^", "n", false)
-- end)

function change_surround(old_ch, new_ch)
    local old_start_ch, old_end_ch = desugar_ch(old_ch)
    local new_start_ch, new_end_ch = desugar_ch(new_ch)

    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1]
    local cursor_col = cursor[2]

    -- search backward for ch, save pos
    -- At first i thought we'd search up line by line for the start ch. But
    -- after some thought i think that's basically useless. The furthest back
    -- we'll ever search is the start of the current line. This might make more
    -- sense for different things, i.e. "change surround quotes" should
    -- prioritize a single-line surround while "change surrounding XML tag"
    -- would want to the above lines for the start tag.
    local start_row = cursor_row
    local start_col = nil
    local line = vim.fn.getline(start_row)
    -- First try to search before cursor
    for i = cursor_col + 1 - #old_start_ch, 1, -1 do -- +1 because fuck you
        -- print("Start iter", i)
        local does_line_have_start_ch = string.sub(line, i, i + #old_start_ch - 1) == old_start_ch
        if does_line_have_start_ch then
            start_col = i
            break
        end
    end
    if start_col == nil then
        -- Didn't find it before cursor, so now search after cursor.
        for i = cursor_col, #line, 1 do
            local does_line_have_start_ch = string.sub(line, i, i + #old_start_ch - 1) == old_start_ch
            if does_line_have_start_ch then
                start_col = i
                break
            end
        end
    end
    if start_col == nil then
        -- Still didn't find it, bail entirely
        print("Did not find surrounding " .. old_ch)
        return
    end
    -- print("Found start", start_row, start_col)
    -- Set cursor position because search()/searchpos() always start searching
    -- from cursor position:
    vim.api.nvim_win_set_cursor(0, { start_row, start_col + 1 })
    local end_pos = vim.fn.searchpos(old_end_ch, "cnWz")
    local end_row = end_pos[1]
    local end_col = end_pos[2]
        -- Old, not using searchpos():
                -- local end_col = start_col + 1
                -- if pos == cursor_row then
                --     -- start search at cursor position, not beginning of line
                --     end_col = cursor_col
                -- end
                -- local line = vim.fn.getline(end_row)
                -- for i = cursor_col, #line, 1 do
                --     if string.sub(line, i, i + #old_end_ch - 1) == old_end_ch then
                --         end_col = i
                --         break
                --     end
                -- end
                -- if end_col == nil then
                --     print("Some weird shit goin on in surround, vim.fn.search() lied?")
                --     return
                -- end
    if end_row == 0 and end_col == 0 then
        -- searchpos() returns (0, 0) when it fails, so there must not be an
        -- end. Bail.
        return
    end
    -- Assert end is actually after start
    if end_row < start_row or (end_row == start_row and end_col <= start_col) then
        print("(surround) Somehow end position is before start position?")
    end
    -- print("Found end", end_row, end_col)

    -- change old start ch to new start ch
    local old_start_text = vim.fn.getline(start_row)
    local new_start_text =
        string.sub(old_start_text, 1, start_col - 1) ..
        new_start_ch ..
        -- Max with 1 because a replacement of "" (for delete-surround) should
        -- still delete at least one character
        string.sub(old_start_text, start_col + math.max(#new_start_ch, 1))
    vim.fn.setline(start_row, new_start_text)

    -- account for len(newch) != len(oldch)
    if start_row == end_row then
        end_col = end_col + (#new_start_ch - #old_start_ch)
    end

    -- change old end ch to new end ch
    local old_end_text = vim.fn.getline(end_row)
    local new_end_text =
        string.sub(old_end_text, 1, end_col - 1) ..
        new_end_ch ..
        -- Max with 1, same as above
        string.sub(old_end_text, end_col + math.max(#new_end_ch, 1))
    vim.fn.setline(end_row, new_end_text)

    -- Put cursor at start_ch position (this mirrors vim-surround's behavior)
    vim.api.nvim_win_set_cursor(0, { start_row, start_col - #old_start_ch })
end
vim.keymap.set("n", "<leader><leader>cs", function()
    local old_ch = get_input_ch()
    if old_ch == vim.keycode("<esc>") then
        return
    end
    local new_ch = get_input_ch()
    if new_ch == vim.keycode("<esc>") then
        return
    end
    change_surround(old_ch, new_ch)
end, { desc = "change surround" })

function delete_surround(old_ch)
    change_surround(old_ch, "")
end

vim.keymap.set("n", "<leader><leader>ds", function()
    local ch = get_input_ch()
    if ch == vim.keycode("<esc>") then
        return
    end
    delete_surround(ch)
end, { desc = "delete surround" })
