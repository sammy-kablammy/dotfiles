vim.bo.expandtab = true
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.b.sam_override_whitespace_settings = true

vim.cmd("inoreabbrev <buffer> hr ---")

-- hide backticks, asterisks, and probably some others (this depends on treesitter)
vim.o.conceallevel = 3

vim.keymap.set('n', '<leader>ma', 'o[](<c-r>#)<esc>^', { desc = "markdown: link to Alternate file", buffer = true })
vim.keymap.set('n', '<leader>mc', 'I[<esc>A]<esc>jI(<esc>A)<esc>kJx', { desc = "markdown: Create link", buffer = true })
vim.keymap.set('n', '<leader>mn', 'o[[<c-r>#]]<esc>^w', { desc = "markdown: link to Alternate file", buffer = true })

vim.keymap.set("i", "<c-x><enter>", "<enter><c-d>- [ ] ", { desc = "create new checkbox" })

if vim.fn.expand("%:t") == "resume.md" then
    vim.keymap.set("n", "<leader><enter>", "<cmd>silent make open<enter>", { buffer = true })
end

InsertMap("a", "**<left>")

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

-- TODO move to linkma. in fact, a handy linkma feature would be a function that
-- simply returns info about all the links in the document. each link could have
-- a type (named vs wiki), info about where it goes (a local file, the web), and
-- line number info.

-- this really could use treesitter but ehhhh i don't feel it
-- you need your title to be of the form [](main/*.md) for title to be inserted
function UpdateNoteTitles()
    local notes_dir = "/home/sam/notes/main/"
    ClearNoteTitles()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for linenum, line in ipairs(lines) do
        local start_idx, end_idx = string.find(line, [[%d%d%d%d%-%d%d%-%d%d_%d%d%-%d%d%-%d%d%.md]])
        if start_idx then
            local filename = notes_dir .. string.sub(line, start_idx, end_idx)
            local fd = io.open(filename, "r")
            local title
            if fd == nil then
                title = "UNKNOWN NOTE :("
            else
                local full_title = fd:read("*l")
                fd:close()
                title = string.sub(full_title, 3) -- (remove "# ")
            end
            local ns_id = vim.api.nvim_create_namespace("markdown_link_note_title")
            vim.api.nvim_buf_set_extmark(0, ns_id, linenum - 1, end_idx, {
                virt_text = {
                    {
                        "  " .. title .. "  ",
                        "MatchParen",
                    },
                },
                virt_text_pos = "eol",
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

-- For any youtube links, show which are not backed up locally.
function UpdateYoutubeDownloadStatus()
    local video_backups_dir = "/home/sam/Desktop/media/backups/"
    ClearYoutubeDownloadStatus()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for linenum, line in ipairs(lines) do
        -- TODO also support youtu.be links, youtube.com/clip links, etc.
        local start_idx, end_idx = string.find(line, "youtube.com/watch?")
        if start_idx then
            local video_id_start = start_idx + #"youtube.com/watch?v="
            local id_length = 11 -- it appears all IDs are this long
            local video_id = string.sub(line, video_id_start, video_id_start + id_length - 1)
            local files = vim.fs.find(function(name, path)
                return name:match(".*" .. video_id .. ".*")
            end, { path = video_backups_dir, type = "file", })
            local title = "video not downloaded"
            local hlgroup = "Substitute"
            if #files > 0 then
                title = "video downloaded: " .. files[1]
                hlgroup = "TabLine"
            end
            local ns_id = vim.api.nvim_create_namespace("markdown_link_youtube")
            vim.api.nvim_buf_set_extmark(0, ns_id, linenum - 1, end_idx, {
                virt_text = {
                    {
                        "  " .. title .. "  ",
                        hlgroup,
                    },
                },
                virt_text_pos = "eol",
            })
        end
    end
end
function ClearYoutubeDownloadStatus()
    local ns_id = vim.api.nvim_create_namespace("markdown_link_youtube")
    local all_extmarks = vim.api.nvim_buf_get_extmarks(0, ns_id, 0, -1, {})
    for _, extmark in pairs(all_extmarks) do
        vim.api.nvim_buf_del_extmark(0, ns_id, extmark[1])
    end
end
-- i choose BufWrite because the act of scanning the entire buffer and
-- opening/closing several files could turn out very taxing if done frequently
vim.api.nvim_create_autocmd({ "BufEnter", "BufWrite" }, {
    buffer = 0,
    callback = UpdateYoutubeDownloadStatus,
    desc = "update youtube download status",
})


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
vim.keymap.set({ "n", "v" }, "gl", function()
    -- this is ugly but i don't know of a better way
    vim.o.operatorfunc = "v:lua.Listify"
    vim.api.nvim_feedkeys("g@", "n", false)
end)


-- TODO use vim.spell.check() to do spell checking across entire file, buffer
-- list, or current directory. print fancy results and/or use quickfix list
