-- you CANNOT use a lua function because this relies on the :<c-u> hack to make
-- non-background commands (at least i think, idk this is very hacky. there
-- should be a better way to get the current visual mode selection without
-- backing out of visual mode first)
-- vim.keymap.set("v", "<leader><enter>", ":<c-u><cr><cmd>RunC<cr>", { buffer = true })

-- it seems that keymaps are not passed start/end line numbers when in visual
-- mode. so you have to get it manually (hard, since the '< and '> marks are
-- only updated after exiting visual mode) or make a mapping for a user command.

-- Run some C code. Accepts a count or range, adding common #includes and main
-- function. Otherwise, run the whole file (without adding any boilerplate).
vim.api.nvim_create_user_command("RunC", function(args)
    local start_linenum, end_linenum
    local need_boilerplate = true
    if args.range == 2 then
        start_linenum = args.line1 - 1
        end_linenum = args.line2
    elseif args.range == 1 then
        start_linenum = vim.api.nvim_win_get_cursor(0)[1] - 1
        end_linenum = start_linenum + args.count
    else
        start_linenum = 0
        end_linenum = -1
        need_boilerplate = false
    end

    local tempname = vim.fn.tempname()
    local source_code_tempfile = tempname .. ".c"
    local binary_tempfile = tempname .. ".out"
    local fd = io.open(source_code_tempfile, "w")
    if fd == nil then
        print("tempname() returned nil. this shouldn't happen")
        return
    end
    if need_boilerplate then
        fd:write("#include <stdio.h>\n", "#include <stdlib.h>\n", "#include <string.h>\n", "#include <stdint.h>\n", "#include <ctype.h>\n", "int main(void) {\n")
    end
    local lines = vim.api.nvim_buf_get_lines(0, start_linenum, end_linenum, true)
    for _, line in ipairs(lines) do
        fd:write(line, "\n")
    end
    if need_boilerplate then
        fd:write("return 0;\n} // (end main)\n")
    end
    fd:close()

    vim.cmd("!gcc -o " .. binary_tempfile .. " " .. source_code_tempfile .. " && " .. binary_tempfile)
end, { range = true })
