vim.bo.expandtab = true
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.b.sam_override_whitespace_settings = true

vim.cmd("inoreabbrev <buffer> hr ---")

-- hide backticks, asterisks, and probably some others (this depends on treesitter)
-- vim.o.conceallevel = 2
-- vim.o.conceallevel = 3

vim.keymap.set('n', '<leader>ma', 'o[](<c-r>#)<esc>^', { desc = "markdown: link to Alternate file", buffer = true })
vim.keymap.set('n', '<leader>mc', 'I[<esc>A]<esc>jI(<esc>A)<esc>kJx', { desc = "markdown: Create link", buffer = true })


-- -- code block detection (experimental, not working, don't really know why,
-- just gonna use treesitter-textobjects instead i guess)
-- vim.keymap.set("v", "am", function()
--     local linenum = vim.fn.search("```", "cnW")
--     local line = vim.fn.getline(linenum)
--     local codeblock_start_pattern = [[```.\+$]]
--     local codeblock_end_pattern = [[```$]]
--     local is_codeblock_end = string.match(line, codeblock_end_pattern) ~= nil
--     if (is_codeblock_end) then
--         local start_linenum = vim.fn.search(codeblock_start_pattern, "bnW")
--         vim.print(start_linenum, linenum)
--         vim.api.nvim_buf_set_mark(0, "<", start_linenum, 0, {})
--         vim.api.nvim_buf_set_mark(0, ">", linenum, 0, {})
--     else
--         local end_linenum = vim.fn.search(codeblock_end_pattern, "nW")
--         vim.print(linenum, end_linenum)
--         vim.api.nvim_buf_set_mark(0, "<", linenum, 0, {})
--         vim.api.nvim_buf_set_mark(0, ">", end_linenum, 0, {})
--     end
--     vim.cmd.normal("gv")
-- end, { desc = "Markdown code block" })


-- 'a' option is cool but it messes up lists and basically everything
vim.bo.formatoptions = "trqnj"
vim.b.sam_override_formatoptions = true
---------- experimental formatting stuff
-- make bulleted lists continue. i like having 'c' removed from formatoptions
-- for this to feel good.
-- this is IMPORTANT! 'fb:-' overrides 'b:-'. the 'fb' version will preserve
-- indentation in lists while the 'b' version does not, BUT the 'b' version will
-- auto insert new bullets on new lines.
-- NOTE! these kinda ruin gqip, so probably just don't enable them
-- vim.opt.com:remove("fb:-")
-- vim.opt.com:append("b:-")
-- vim.opt.com:append("b:1.")
----------

-- TODO split this into its own plugin
-- TODO if when gO is pressed, the current buffer type is quickfix, bypass the
-- vimgrep and instead vimgrep in the previous window
-- TODO remove filename and line number from the quickfix entry (if possible)
local function generate_toc(heading_level, include_horizontal_rule)
  if include_horizontal_rule then
    vim.cmd("vimgrep /^\\(#\\{1," .. heading_level .. "\\} \\)\\|---$/ % | copen | wincmd =")
  else
    vim.cmd("vimgrep /^\\(#\\{1," .. heading_level .. "\\} \\)/ % | copen | wincmd =")
  end
  -- so many escape sequences 💀
end

-- NOTE it seems that vim doesn't use g1 through g6... hmm... (it does use g0
-- and g8 though)

vim.keymap.set('n', 'gO', function() generate_toc(2, true) end, { buffer = true })
vim.keymap.set('n', '1gO', function() generate_toc(1) end, { buffer = true })
vim.keymap.set('n', 'g1', function() generate_toc(1) end, { buffer = true })
vim.keymap.set('n', '2gO', function() generate_toc(2, true) end, { buffer = true })
vim.keymap.set('n', '3gO', function() generate_toc(3, true) end, { buffer = true })
vim.keymap.set('n', '4gO', function() generate_toc(4, true) end, { buffer = true })
vim.keymap.set('n', '5gO', function() generate_toc(5, true) end, { buffer = true })
vim.keymap.set('n', '6gO', function() generate_toc(6, true) end, { buffer = true })



----------------------------------
-- virtual text with the first line of a markdown note, used because i don't
-- title my notes

-- TODO move to linkma

-- this really could use treesitter but ehhhh i don't feel it
-- you need your title to be of the form [](main/*.md) for title to be inserted
function UpdateNoteTitles()
    local notes_dir = "/home/sam/notes/main/"
    ClearNoteTitles()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for linenum, line in ipairs(lines) do
        local start_idx, end_idx = string.find(line, [[%[%]%(.*%.md*%)]])
        if (start_idx) then
            local offset = #"[](main/"
            local filename = notes_dir .. string.sub(line, start_idx + offset, end_idx - 1)
            local fd = io.open(filename, "r")
            if fd == nil then
                print("ruh roh, note '" .. filename .. "' not found")
                return
            end
            local title = fd:read("*l")
            local shortened_title = string.sub(title, 3) -- (remove "# ")
            fd:close()
            local ns_id = vim.api.nvim_create_namespace("markdown_link_note_title")
            vim.api.nvim_buf_set_extmark(0, ns_id, linenum - 1, start_idx, {
                virt_text = {
                    {
                        shortened_title,
                        "WarningMsg",
                    },
                },
                virt_text_pos = "inline",
            })
        end
    end
end
function ClearNoteTitles()
    local ns_id = vim.api.nvim_create_namespace("markdown_link_note_title")
    local all_extmarks = vim.api.nvim_buf_get_extmarks(0, ns_id, 0, -1, {})
    for _, extmark in pairs(all_extmarks) do
        vim.api.nvim_buf_del_extmark(0, ns_id, extmark[1])
    end
end
-- i choose BufWrite because the act of scanning the entire buffer and
-- opening/closing several files could turn out very taxing if done frequently
vim.api.nvim_create_autocmd({ "BufEnter", "BufWrite" }, {
    callback = UpdateNoteTitles,
    buffer = 0,
    desc = "update markdown note titles",
})



-- TODO make a "get backlinks" function, could be useful. call it when opening a file?
