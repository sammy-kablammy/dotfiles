-- Capitalize some text. Works best with 'iw' and 'is' motions.
--
--                             this is some TEXT
--                                ... gC$ ...
--                             This Is Some Text

function Capitalize_operatorfunc()
    local startpos = vim.api.nvim_buf_get_mark(0, "[")
    local endpos = vim.api.nvim_buf_get_mark(0, "]")
    -- api-indexing makes this hard to read but it works
    local text = vim.api.nvim_buf_get_text(0, startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2] + 1, {})
    local newtext = {}
    for i, line in ipairs(text) do
        local split = vim.fn.split(line)
        local newline = {}
        for j, word in ipairs(split) do
            -- Lowercase the word first so that 'WORD' becomes 'Word'
            local lowerword = vim.fn.tolower(word)
            firstchar = lowerword[1]
            newline[j] = lowerword:sub(1, 1):upper() .. lowerword:sub(2)
        end
        newtext[i] = vim.fn.join(newline)
    end
    vim.api.nvim_buf_set_text(0, startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2] + 1, newtext)
end

vim.keymap.set("n", "gC", function()
    vim.o.operatorfunc = "v:lua.Capitalize_operatorfunc"
    vim.api.nvim_feedkeys("g@", "n", false)
end)
