--------------------------------------------------------------------------------
--                          Yeah I don't use this 😔                          --
--------------------------------------------------------------------------------

-- should probably archive the whole file



-- custom command you can re-run easily. who needs makefiles anyway?

local custom_command_job_id = 0
local custom_command_buffer_id = 0
local custom_command_string = ""

-- probably don't use <enter> for anything because it's too easy to mispress and
-- it conflicts with <c-m>

vim.keymap.set("n", "<leader>ge", function()
    vim.ui.input({
        prompt = "Command: ",
    }, function(input)
        if input == nil or input == "" then
            return
        end

        custom_command_string = input
        if custom_command_job_id > 0 then
            return
        end

        vim.cmd("vertical terminal")
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.buflisted = false
        custom_command_job_id = vim.bo.channel
        custom_command_buffer_id = vim.fn.bufnr()
        vim.fn.chansend(custom_command_job_id, { custom_command_string .. "\r\n" })
    end)
end, { desc = "Enter custom command to re-run" })

-- vim.keymap.set("n", "<leader>rr", function()
--     if custom_command_job_id == 0 then
--         print("No custom command string to re-run.")
--         return
--     end
--
--     local is_terminal_hidden = vim.fn.bufwinid(custom_command_buffer_id) == -1
--     if is_terminal_hidden then
--         vim.cmd("vertical sbuffer" .. custom_command_buffer_id)
--     end
--
--     vim.fn.chansend(custom_command_job_id, { custom_command_string .. "\r\n" })
-- end, { desc = "re-run custom command" })
