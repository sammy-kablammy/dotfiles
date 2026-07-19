
-- vim.g.sam_do_fancy_shmancy = 1
vim.g.sam_do_fancy_shmancy = false
-- idea is to open a non-focusable popup window, show the message slide on
-- screen, then close the popup
function new_show_animated_msg(msg)
    local bufnr = vim.api.nvim_create_buf(false, true)
    local win_width = vim.api.nvim_list_uis()[1].width
    local win_height = vim.api.nvim_list_uis()[1].height
    local winnr = vim.api.nvim_open_win(bufnr, false, {
        width=#msg+1, -- not sure why +1
        height=1,
        col=(win_width - #msg) / 2,
        row=win_height / 2,
        relative='editor',
        border='none',
    })
    vim.api.nvim_set_option_value("number", false, { win = winnr })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = winnr })
    vim.api.nvim_set_option_value("colorcolumn", "", { win = winnr })
    vim.api.nvim_set_option_value("winfixbuf", true, { win = winnr })

    local done_func = function()
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    local each_char_delay_ms = 1
    local final_delay_ms = 100

    local i = 1
    local function f()
        local line = string.sub(msg, 1, i)
        i = i + 1

        vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { line })

        if (i <= #msg) then
            vim.defer_fn(f, each_char_delay_ms)
        else
            vim.defer_fn(done_func, final_delay_ms)
        end
    end
    f() -- get it started
    -- Could also have the text slide "off" the screen in the same way it slides on
end

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(ev)
        if not vim.g.sam_do_fancy_shmancy then
            return
        end
        local name = vim.api.nvim_buf_get_name(ev.buf)
        name = vim.fs.basename(name)
        new_show_animated_msg(name)
    end,
    desc = "Fancy shmancy animated buffer name",
})

