-- not all user commands will be here, just whatever doesn't fit anywhere else

-- actually it makes much sense to organize by usage, not by nvim feature. like
-- "user command" is so vague when "git related things" is a better
-- classification imo

-- huh?
-- inspired by wtf.nvim (https://github.com/piersolenski/wtf.nvim)
vim.api.nvim_create_user_command("Huh", function()
    local diag = vim.diagnostic.get_next()
    if not diag then
        print("no diagnostics to search")
        return
    end
    -- there may be some URL characters that aren't escaped properly
    local formatted_msg = vim.fn.substitute(diag.message, " ", "%20", "g")
    formatted_msg = vim.fn.substitute(formatted_msg, ";", "%3b", "g")
    local ddg = [[https://duckduckgo.com/?t=lm&q=]]
    local search_query = ddg .. vim.bo.filetype .. "%20" .. formatted_msg
    vim.print(search_query)
    vim.ui.open(ddg .. search_query)
end, {})

-- peak laziness
vim.api.nvim_create_user_command('Subij', function()
    vim.cmd("s/i/j/g")
    vim.cmd.nohlsearch()
end, {
    desc = "substitute i for j, used in for-loops",
})

-- Open local file in remote git repo
vim.api.nvim_create_user_command('OpenGitRemote', function()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    vim.cmd("!git-open-remote % " .. cursor_line)
end, {
    desc = "open local file in remote git repo",
})

-- TODO Need :Mks that's basically the same as :mks! but it only overwrites .vim
-- files. that way if i have a sesh.md and sesh.vim i don't accidentally tab
-- complete :mks! se<tab> and wipe sesh.md. Ideally it would automatically
-- determine the name of the session file to use too. Not sure how to do that
-- without preserving variables between sessions (maybe we just enable this in
-- sessionoptions)
