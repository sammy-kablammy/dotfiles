-- not all user commands will be here, just whatever doesn't fit anywhere else

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
