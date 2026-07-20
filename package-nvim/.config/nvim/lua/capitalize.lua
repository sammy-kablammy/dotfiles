-- Capitalize some text. Works best with 'iw' and 'is' motions.
--
--                             this is some TEXT
--                                ... gC$ ...
--                             This Is Some Text

-- For example "---Hello.there my-guy_." becomes { "Hello" "there" "my" "guy" }
function split_keywords(str)
    local keywords = {}
    local current_keyword = ""
    local is_keyword_over = false
    for _, ch in ipairs(vim.fn.str2list(str)) do
        ch = vim.fn.nr2char(ch)
        -- print(ch)
        local is_keyword = vim.fn.match(ch, "\\k") ~= -1
        if is_keyword_over and is_keyword then
            -- This is be the start of the next keyword
            table.insert(keywords, current_keyword)
            current_keyword = ""
            is_keyword_over = false
        elseif not is_keyword then
            -- End current keyword, but don't actually end it until we pass over
            -- all the non-keyword characters too. Otherwise "foo.bar" would be
            -- split into { "foo" "bar" }, losing information.
            is_keyword_over = true
        end
        current_keyword = current_keyword .. ch
    end
    -- End final word
    if current_keyword ~= "" then
        table.insert(keywords, current_keyword)
    end
    return keywords
end

function Capitalize_operatorfunc()
    local startpos = vim.api.nvim_buf_get_mark(0, "[")
    local endpos = vim.api.nvim_buf_get_mark(0, "]")
    -- api-indexing makes this hard to read but it works
    local text = vim.api.nvim_buf_get_text(0, startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2], {})
    local newtext = {}
    for i, line in ipairs(text) do
        -- We shouldn't use split! we should be splitting based on keywordness,
        -- using 'iskeyword'.
        -- local split = vim.fn.split(line)
        local split = split_keywords(line)
        -- vim.print(line, split)

        local split = vim.fn.split(line)
        local newline = {}
        for j, word in ipairs(split) do
            -- Lowercase the word first so that 'WORD' becomes 'Word'
            local lowerword = vim.fn.tolower(word)
            firstchar = lowerword[1]
            newline[j] = lowerword:sub(1, 1):upper() .. lowerword:sub(2)
        end
        newtext[i] = vim.fn.join(newline, "")
        -- Now make sure the line is indented properly
        -- local lnum = startpos[1] + i - 1
        -- newtext[i] = vim.text.indent(vim.fn.cindent(lnum), newtext[i])
    end
    vim.api.nvim_buf_set_text(0, startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2], newtext)
end

vim.keymap.set("n", "gC", function()
    vim.o.operatorfunc = "v:lua.Capitalize_operatorfunc"
    vim.api.nvim_feedkeys("g@", "n", false)
end)
