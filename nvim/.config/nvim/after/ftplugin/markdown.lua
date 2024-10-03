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
vim.keymap.set('n', '<leader>mn', 'o[[<c-r>#]]<esc>^w', { desc = "markdown: link to Alternate file", buffer = true })

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

        -- two types of links are supported: standard markdown links and wikilinks:
        local start_idx, end_idx, filename, virt_text_pos
        local start_idx1, end_idx1 = string.find(line, [[%[%]%(.*%.md*%)]]) -- [](note_title_here)
        local start_idx2, end_idx2 = string.find(line, "%[%[.*%.md*%]%]") -- [[note_title_here]]
        if start_idx1 then
            start_idx = start_idx1
            end_idx = end_idx1
            filename = notes_dir .. string.sub(line, start_idx + #"[](main/", end_idx - 1)
            virt_text_pos = "inline"
        elseif start_idx2 then
            start_idx = start_idx2
            end_idx = end_idx2
            filename = notes_dir .. string.sub(line, start_idx + #"[[main/", end_idx - 2)
            virt_text_pos = "eol"
        end
        -- lua doesn't have a 'continue' keyword. kill me.
        if start_idx then
            local fd = io.open(filename, "r")
            local title
            if fd == nil then
                -- print("ruh roh, note '" .. filename .. "' not found")
                title = "UNKNOWN NOTE :("
            else
                local full_title = fd:read("*l")
                fd:close()
                title = string.sub(full_title, 3) -- (remove "# ")
            end
            local ns_id = vim.api.nvim_create_namespace("markdown_link_note_title")
            vim.api.nvim_buf_set_extmark(0, ns_id, linenum - 1, start_idx, {
                virt_text = {
                    {
                        title,
                        "TabLineSel",
                    },
                },
                virt_text_pos = virt_text_pos,
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
    buffer = 0,
    callback = UpdateNoteTitles,
    desc = "update markdown note titles",
})



-- TODO make a "get backlinks" function, could be useful. call it when opening a file?



-- markdown listification operator
-- TODO what should happen when you apply this to text that is already a list?
-- does it change symbol from - to *? does it remove the symbol? to be
-- concluded...
function Listify()
    vim.cmd("'[,']normal I- ")
end
function Unlistify()
    -- todo use this substitution command: s/\s*- /
end
vim.keymap.set("n", "gl", function()
    -- this is ugly but i don't know of a better way
    vim.o.operatorfunc = "v:lua.Listify"
    vim.api.nvim_feedkeys("g@", "n", false)
end)


-- does this belong in ftplugin or is it general enough to have elsewhere?
-- generated by https://loremipsum.io/
vim.api.nvim_create_user_command("LoremIpsum", function()
    vim.cmd.norm("i Lorem ipsum odor amet, consectetuer adipiscing elit. Sociosqu imperdiet volutpat dapibus sed varius quisque duis. Maximus sociosqu mollis convallis himenaeos in. Facilisi eleifend dapibus semper volutpat adipiscing. Luctus nisl lobortis hac molestie mi nam. Gravida pulvinar penatibus cursus, suscipit etiam tincidunt eleifend nunc sed. Augue placerat vulputate sollicitudin malesuada facilisi rhoncus. Dignissim inceptos ullamcorper, bibendum porttitor tristique id suspendisse! Sed taciti adipiscing curabitur nec fringilla tempus.")
end, {})
