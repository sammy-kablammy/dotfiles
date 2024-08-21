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
