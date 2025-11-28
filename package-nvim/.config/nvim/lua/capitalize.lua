-- Capitalize some text. Works best with 'iw' and 'is' motions.
--
--                             this is some text
--                                ... gC$ ...
--                             This Is Some Text

function Capitalize_operatorfunc()
    local startpos = vim.api.nvim_buf_get_mark(0, "[")
    local endpos = vim.api.nvim_buf_get_mark(0, "]")
    local text = vim.api.nvim_buf_get_text(0, startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2], {})
    local newtext = {}
    for i, line in ipairs(text) do
        local split = vim.fn.split(line)
        local newline = {}
        for j, word in ipairs(split) do
            firstchar = word[1]
            newline[j] = word:sub(1, 1):upper() .. word:sub(2)
        end
        newtext[i] = vim.fn.join(newline)
    end
    vim.api.nvim_buf_set_text(0, startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2], newtext)
end

vim.keymap.set("n", "gC", function()
    vim.o.operatorfunc = "v:lua.Capitalize_operatorfunc"
    vim.api.nvim_feedkeys("g@", "n", false)
end)
