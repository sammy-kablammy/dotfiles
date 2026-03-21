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

-- the impetus for this command is having two files session.md (my notes for the
-- session) and the vim file itself session.vim. it's easy to tab complete the
-- md and overwrite the wrong file.
vim.api.nvim_create_user_command("Mks", function(cmd)
    session_name = cmd.fargs[1] .. ".vim"
    print("Session name is", session_name)

    -- if file is there, send existing file to a backup location and make a new session
    if vim.uv.fs_stat(session_name) then
        local oldsessions = vim.fn.stdpath("state") .. "/oldsessions/"
        local obj = vim.system({ "mkdir", "--parents", oldsessions }, {
            timeout = 1000,
        }, nil):wait()
        obj = vim.system({ "mv", "--backup=numbered", session_name, oldsessions }, {
            timeout = 1000,
        }, nil):wait()
    end
    vim.cmd.mksession(session_name)

end, {
    -- TODO should we handle no args?
    nargs = 1,
    complete = function(arglead, cmdline, cursorpos)
        local matches = vim.fn.glob(arglead .. "*.vim")
        -- glob() returns newline separated. we want a list:
        matches = vim.fn.split(matches)
        for i, match in ipairs(matches) do
            -- remove trailing ".vim"
            matches[i] = string.sub(match, 1, #match - 4)
        end
        return matches
    end,
})
