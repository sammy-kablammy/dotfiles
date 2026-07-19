
-- :h complete-functions
function _sam_complete_func(should_find_start)
    if should_find_start == 1 then
        -- return the byte index of where completion should begin. In theory
        -- you could go backwards to find the start of the current word, parse
        -- the whole buffer for context, make a network request to start a
        -- remote game of doom, etc.
        return vim.fn.col('.')
    else
        -- return list of completion candidates
        return {
            "one",
            "two",
            "three",
        }
    end

    print("Called complete func!")
    vim.print(args)
end
vim.o.completefunc = "v:lua._sam_complete_func"
