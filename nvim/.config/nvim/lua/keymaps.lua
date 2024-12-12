--[[

PLEASE USE after/plugin thank you that is all

jeez i need descriptions for lots of these mappings

some notes on keymaps:

- <leader> needs to be set up in init.lua, right before setting up lazy.
- for notation, see :h keycodes
- if some keys aren't working, see :h map-special-keys
  for example, <C-m> is treated as a carriage return (not to be confused with a
  linefeed! that's <c-j>). this will inevitably cost you tens of minutes of
  pain in the future when you will bind something to <C-[>.
- what's the difference between <cr>, <enter>, and <return>? nothing.
- what's the difference between : and <cr>? : requires you to be in normal
  mode, while <cmd> can be invoked from any mode. this lets you
  programmatically execute commands even from insert mode. just remember
  to include a corresponding <cr> for every <cmd>.
- keymap order matters! for example, suppose you do this:
      :nnoremap <c-up> <c-u>
      :nnoremap <c-u> <c-u>zz
  pressing <c-up> at this point does NOT do the centering. the first remap causes <c-up>
  to effectively "dereference" the <c-u> mapping's value.

--]]

-- remove annoying mappings (must be at the top in case i re-add these mappings)
vim.keymap.set("n", "<c-q>", "<nop>")
vim.keymap.set("n", "U", "<nop>")
vim.keymap.set("n", "gs", "<nop>")
vim.keymap.set("n", "gQ", "<nop>")
-- vim.keymap.set("n", "zg", "<nop>") -- remember: zug to undo zg
vim.keymap.set("n", "zw", "<nop>")
vim.keymap.set("n", "<C-'>", '<nop>') -- i don't even know what this is but it conflicts with my qmk combos

-- insert mode "leader key" style bindings. snippets for dummies. note that the
-- key following <c-x> does NOT have control pressed. those are already used (:h
-- i_CTRL-X_index)
InsertMap = function(lhs, rhs)
    vim.keymap.set("i", "<c-x>" .. lhs, rhs, { buffer = true })
end
-- here are some to get ya started. the rest will be defined by ftplugins.
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function()
        InsertMap("b", "``<left>")
        InsertMap("n", "\\n")
        InsertMap("q", '""<left>')
        InsertMap("r", "_")
        InsertMap("t", "~")
        -- date. this is so annoying. we have a lua string that turns into a vim command
        -- string that THEN turns into a shell command. like three levels of escaping.
        InsertMap("d", [[<cmd>r! date +"\%A \%b \%d, \%Y"<cr><esc>kJA]])
    end,
})
vim.keymap.set("c", "<c-x>t", "~")
-- TODO read :h cmdline-char and define bindings that are exclusive to regular
-- command mode
vim.keymap.set("c", "<c-o>", "lua=vim.api.nvim_")
-- searchy command mode
vim.keymap.set("c", "<c-x>k", [[\(.*\)]])
vim.keymap.set("c", "<c-x>n", [[\d\+]])
vim.keymap.set("c", "<c-x>w", [[\<\><left><left>]])

-- (recall that the + register is the windows/macos clipboard, while the * reg is
-- the X11 middle click thing. i only ever use + and never use *)
-- paste recently selected text
vim.keymap.set({"n", "v"}, "<leader>p", '"0p')
vim.keymap.set({"n", "v"}, "<leader>P", '"0P')
-- yank/put using system clipboard
vim.keymap.set({ "n", "v", }, "gy", "\"+y") -- is gy really unused by default? really?
vim.keymap.set({ "n", "v", }, "gY", "\"+Y")
vim.keymap.set({ "n", "v", }, "gp", "\"+p")
vim.keymap.set({ "n", "v", }, "gP", "\"+P")

-- movement should work how you expect even if a line is wrapped
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- scroll up and down without getting disoriented
vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("n", "<c-up>", "<c-u>zz")
vim.keymap.set("n", "<c-down>", "<c-d>zz")
vim.keymap.set("n", "<s-up>", "<c-u>zz")
vim.keymap.set("n", "<s-down>", "<c-d>zz")

-- this way, 'n' will always search downward, 'N' will always search upward.
-- (the default behavior is that 'n' always searches in the same direction of
-- the most recent search, and 'N' is the opposite direction)
vim.keymap.set({ "n", "v" }, "n", "/<c-r>/<cr>")
vim.keymap.set({ "n", "v" }, "N", "?<c-r>/<cr>")

vim.keymap.set({ "n", "v" }, "gd", "gd<cmd>nohlsearch<cr>")
vim.keymap.set({ "n", "v" }, "gD", "gd<cmd>nohlsearch<cr>")

-- slide text left and right whhheeeeeeeeeeeee!!! nrrooooooooom!!!
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- (recall that @: executes the : register, which contains the previous command)
vim.keymap.set({ "n", "v" }, "<leader>.", "<cmd>@:<cr>", { desc = "execute previous command" })

-- change settings
vim.keymap.set("n", "<leader>sh", "<cmd>set hls!<cr>")
vim.keymap.set("n", "<leader>sl", "<cmd>set list!<cr>")
vim.keymap.set("n", "<leader>sn", "<cmd>set number!<cr>")
vim.keymap.set("n", "<leader>sr", "<cmd>set relativenumber!<cr>")
vim.keymap.set("n", "<leader>sw", "<cmd>set wrap!<cr>")
vim.keymap.set("n", "<leader>ss", "<cmd>set spell!<cr>")
vim.keymap.set("n", "<leader>st", function() vim.o.laststatus = 2 - vim.o.laststatus end, { desc = "toggle statusline" })
vim.keymap.set("n", "<leader>sc", function() vim.o.cmdheight = 1 - vim.o.cmdheight end, { desc = "set cmdheight to whatever" })
vim.keymap.set("n", "<leader>sf", function() vim.o.foldcolumn = "" .. 1 - vim.o.foldcolumn end, { desc = "toggle foldcolumn" })
vim.keymap.set('n', '<leader>so', function() vim.o.conceallevel = 3 - vim.o.conceallevel end, { desc = "toggle conceallevel" })
vim.keymap.set("n", "<leader>sx", function()
    if vim.o.textwidth == 80 then
      vim.o.textwidth = 100
    elseif vim.o.textwidth == 100 then
      vim.o.textwidth = 80
    end
end, { desc = "set textwidth to whatever" })

-- for cleaner screen demos
vim.api.nvim_create_user_command("Zenma", function()
    if vim.g.zenma_is_enabled then
        vim.o.colorcolumn = vim.g.zenma_colorcolumn
        vim.o.laststatus = vim.g.zenma_laststatus
        vim.o.cmdheight = vim.g.cmdheight
        vim.g.zenma_is_enabled = false
        return
    end
    vim.g.zenma_colorcolumn = vim.o.colorcolumn
    vim.g.zenma_laststatus = vim.o.laststatus
    vim.g.zenma_cmdheight = vim.o.cmdheight
    vim.o.colorcolumn = ""
    vim.o.laststatus = 0
    vim.o.cmdheight = 0
    vim.g.zenma_is_enabled = true
end, {})
vim.keymap.set("n", "<leader>sz", "<cmd>Zenma<cr>", { desc = "experimental zen mode??👀" })

-- square bracket fun time [ [ [ ] ] ]
vim.keymap.set("n", "[b", vim.cmd.bprevious, { desc = "prev buffer" })
vim.keymap.set("n", "]b", vim.cmd.bnext, { desc = "next buffer" })
vim.keymap.set("n", "[c", vim.cmd.cprev, { desc = "prev qflist entry" })
vim.keymap.set("n", "]c", vim.cmd.cnext, { desc = "next qflist entry" })
vim.keymap.set("n", "[C", vim.cmd.colder, { desc = "older qflist" })
vim.keymap.set("n", "]C", vim.cmd.cnewer, { desc = "newer qflist" })
vim.keymap.set("n", "[l", vim.cmd.lprev, { desc = "prev loclist" })
vim.keymap.set("n", "]l", vim.cmd.lnext, { desc = "next loclist" })
vim.keymap.set("n", "[t", "gT", { desc = "prev tab" })
vim.keymap.set("n", "]t", "gt", { desc = "next tab" })
vim.keymap.set("n", "[T", function() vim.cmd.tabmove("-1") end, { desc = "move tab left" })
vim.keymap.set("n", "]T", function() vim.cmd.tabmove("+1") end, { desc = "move tab right" })

-- it's annoying for search results highlighted all the time, so i press this occasionally
vim.keymap.set("n", "<leader>/", "<cmd>nohlsearch<cr>")
-- display current buffer in new tab. unlike <c-w>T because it keeps the old
-- window where it was
vim.keymap.set("n", "<c-w>t", "<cmd>tabnew %<cr>", { desc = "create new tab"})

-- open fileTYpe plugin
vim.keymap.set("n", "<leader>ty", function()
    local ftplugin_path = "~/.config/nvim/after/ftplugin/" .. vim.bo.filetype .. ".lua"
    -- i would rather :edit the file but it messes up whitespace settings (sw,
    -- ts, sts) when you do that so instead i'm gonna :vsplit
    vim.cmd.vsplit(ftplugin_path)
end, { desc = "open fileTYpe plugin"})
-- open filetype specific docs
vim.keymap.set("n", "gX", function()
    local url = vim.b.sam_documentation_url
    if url then
        vim.ui.open(url)
    else
        print("no documentation url found for filetype \"" .. vim.bo.filetype .. "\"")
    end
end, { desc = "open fileType dOcumentation"})

-- like c-g (AKA :file) but with more info
vim.keymap.set("n", "<leader><c-g>", function()
    -- i don't know how to get the [Modified] message. yeah idk.
    -- example: " /home/sam/foo/bar.txt | [Modified] | Line 320/1572 (20%) | Column 42 | 10293 words
    local file_path = vim.api.nvim_buf_get_name(0)
    local pos = vim.api.nvim_win_get_cursor(0)
    local row, col = pos[1], pos[2]
    local total_lines = vim.api.nvim_buf_line_count(0)
    local percent = math.floor((row / total_lines) * 100)
    local wordcount = vim.fn.wordcount().words
    print(" " .. file_path .. " | Line " .. row .. "/" .. total_lines .. " (" .. percent .. "%) | Col " .. col .. " | " .. wordcount .. " words")
end, { desc = "display extended file info" })

-- useful for when you scroll to the right and want to reset view back to the
-- left, but without manually pressing 0 each time. capisce?
vim.keymap.set("n", "^", "0^")

-- my own lil' cheatsheet
vim.keymap.set("n", "<leader>?", "<cmd>vsplit ~/notes/main/2024-03-20_14-45-16.md<cr>")

-- alternate file (this also fixes the c-^ vs c-6 discrepancy between terminals)
vim.keymap.set("n", "<leader>a", "<cmd>b#<cr>", { desc = "alternate file" })

-- misc one-off mappings
vim.keymap.set("n", "gG", "ggVG", { desc = "select entire buffer" })
vim.keymap.set("n", "gQ", "gggqG<c-o><c-o>", { desc = "format (gq) entire buffer" })
vim.keymap.set("n", "<leader>o", vim.cmd.options, { desc = "show vim options" })
vim.keymap.set("v", "<leader>col", "!column -t<cr>", { desc = "columnize selection" })
vim.keymap.set("v", "<leader>qmk", "!column -t<cr>gv>gv>", { desc = "columnize selection and shift, for qmk keymaps" })
vim.keymap.set('n', 'ciq', 'ci"')
vim.keymap.set("n", "<leader>z", "1z=", { desc = "apply first spelling suggestion" })
vim.keymap.set("n", "<leader>w", vim.cmd.update, { desc = "write (well, update) file" })
vim.keymap.set("n", "<leader><leader>e", vim.cmd.edit, { desc = "edit" })
vim.keymap.set("n", "<leader><leader>s", function()
    print("sourced! hooray!")
    vim.cmd.source()
end, { desc = "source" })
vim.keymap.set("n", "<leader>gh", function() vim.cmd("cd %:h") end, { desc = "go here - change cwd to match current buffer" })
vim.keymap.set("n", "<leader><leader>m", "<cmd>messages<cr>")
vim.keymap.set("n", "<leader><leader>p", "<cmd>pwd<cr>")
vim.keymap.set("n", "g=", "g+") -- (redo, alias for g+)
vim.keymap.set("n", "<c-w>u", "<c-w>p")
vim.keymap.set("n", "<c-w><c-u>", "<c-w>p")
vim.keymap.set("v", "s", ":s/") -- default 's' in visual mode is redundant (use 'c' instead)
vim.keymap.set("n", "<bs>", "<cmd>bd<cr>", { desc = "delete buffer" })
vim.keymap.set("n", "<leader>v", "<cmd>vert sb #<cr>", { desc = "vsplit previous buffer" })
vim.keymap.set("n", "<leader>E", function() vim.cmd("Explore") end)
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]]) -- escape terminal mode (because the default mapping is weird)
vim.keymap.set("n", "<c-q>", function()
    if vim.bo.buftype == "quickfix" then
        vim.cmd.cclose()
    else
        vim.cmd.copen()
    end
end)
vim.keymap.set("n", "<leader>q", "<c-q>")
vim.keymap.set("n", "<leader>tm", "<cmd>silent !tmux split -h -c '%:p:h'<cr>", { desc = "open directory in tmux split" })
vim.keymap.set("n", "<leader>x", "<cmd>silent !xdg-open '%:p:h'<cr>", { desc = "open directory in file explorer" })
vim.keymap.set("n", "<leader>lz", "<cmd>Lazy<cr>")
vim.keymap.set("c", "<c-h>", "<left>")
vim.keymap.set("c", "<c-l>", "<right>")



---------- keymap graveyard ----------
-- i like reusing the previous insertion, so i can't use these
-- vim.keymap.set('i', '<c-a>', '<home>')
-- vim.keymap.set('i', '<c-e>', '<end>')
-- de-indent is super useful!!
-- vim.keymap.set('i', '<c-d>', '<del>')
-- i had these for a while but simply never used them
-- vim.keymap.set('i', '<c-f>', '<right>')
-- vim.keymap.set('i', '<c-b>', '<left>')
-- vim.keymap.set("n", "[g", "?<<<<<<<<cr>")
-- vim.keymap.set("n", "]g", "/<<<<<<<<cr>")
-- vim.keymap.set("n", "<leader>gp", "<cmd>!echo %:p<cr>", { desc = "get path of current buffer" })
-- vim.keymap.set("n", "[j", "<c-o>")
-- vim.keymap.set("n", "]j", "<c-i>")
-- keymap('n', '<leader>a', '$F)i, ') add argument to function
-- window resizing (stolen from tjdevries). convenient but i don't use alt/meta.
-- vim.keymap.set('n', '<m-,>', '<c-w>5<')
-- vim.keymap.set('n', '<m-.>', '<c-w>5>')
-- vim.keymap.set('n', '<m-j>', '<c-w>5+') -- i keep accidentally pressing this
-- vim.keymap.set('n', '<m-k>', '<c-w>5-')
-- i find the "center-after-searching" too disorienting
-- vim.keymap.set('n', '#', '#zz')
-- vim.keymap.set('n', '*', '*zz')
-- vim.keymap.set('n', 'n', 'nzz')
-- vim.keymap.set('n', 'N', 'Nzz')
-- i like matching numbers but don't like how this breaks vim's builtin c_ctrl-e
-- vim.keymap.set('c', '<C-e>', [[\(\d\+\)]])
-- run shell command in fancy popup. fun but not useful
-- vim.keymap.set("n", "<leader>cm", function()
--     vim.ui.input({
--         prompt = "run shell command:",
--     }, function(input)
--         if input then
--             vim.cmd("!" .. input)
--         end
--     end)
-- end)
-- "change inside ___" motions but reversed. not robust enough, needs to support
-- more permutations. maybe one day i'll write a plugin implementing a proper
-- custom textobject 🤔
-- vim.keymap.set('n', 'cr"', '?"<cr><cmd>nohlsearch<cr>ci"')
-- vim.keymap.set('n', "cr'", "?'<cr><cmd>nohlsearch<cr>ci'")
-- vim.keymap.set('n', 'cr`', '?`<cr><cmd>nohlsearch<cr>ci`')
-- vim.keymap.set('n', 'cr(', '?(<cr><cmd>nohlsearch<cr>ci(')
-- vim.keymap.set('n', 'cr[', '?[<cr><cmd>nohlsearch<cr>ci[')
-- vim.keymap.set('n', 'cr{', '?{<cr><cmd>nohlsearch<cr>ci{')
-- vim.keymap.set('n', 'cr<', '?<<cr><cmd>nohlsearch<cr>ci<')
-- vim.keymap.set('n', 'crq', '?"<cr><cmd>nohlsearch<cr>ci"')
-- i like this but i want to try the default 'incsearch' hopping thing for a bit
-- vim.keymap.set("c", "<c-g>", "<c-c>", { desc = "emacs style prompt quitting" })
-- use this if you want ctrl-c to be exactly like pressing escape
-- vim.keymap.set('i', '<C-c>', '<cmd>stopinsert<cr>')
-- vim.keymap.set({ "i", "x", "c" }, "<c-space>", "<esc>") -- experimental ctrl+space mode switching
-- default <space>A applies the A to the next line, i find this more intuitive
-- vim.keymap.set("n", "<leader>A", "A")
-- -- easier navigation between windows (not needed if vim-tmux-navigator present)
-- trying to get rid of these because <c-w> is good enough and i prefer fullscreen over splits these days
-- vim.keymap.set("n", "<c-h>", "<c-w>h")
-- vim.keymap.set("n", "<c-j>", "<c-w>j")
-- vim.keymap.set("n", "<c-k>", "<c-w>k")
-- vim.keymap.set("n", "<c-l>", "<c-w>l")
-- vim.keymap.set("n", "<c-f>", "<c-f>zz") -- this doesn't work
-- vim.keymap.set("n", "<c-b>", "<c-b>zz") -- this doesn't work
