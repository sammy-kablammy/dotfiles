-- sitelen: toki pona for "symbol" or "glyph"
--
-- no dependencies, just vim's matchfuzzy(). if you want to use telescope or
-- ripgrep or whatever, go somewhere else
--
-- basically a lightweight clone of https://github.com/ziontee113/icon-picker.nvim

-- the symbol itself comes first, after that put keywords to help with searching
local symbols = {
    "Δ delta | greek delta",
    "Γ gamma | greek gamma",
    "Ω omega | greek omega",
    "™ TM | trademark",
    "🤓 nerd",
    "😮 surprise",
    "😳 flushed",
    "🤤 drool",
    "🤔 thinking",
    "😈 imp | demon",
    "🦝 raccoon | kijetesantakalu",
    "💀 skull",
    "💯 100 | hundred",
    "🧙 wizard | warlock | mage",
    "🐸 frog",
    "🚌 bus | bussin",
    "🤷 shrug",
    "💩 poop",
    "👉👈 pointing | pwetty pwease",
    "👆 pointing up | ermm actually",
    "🐋 whale | docker",
    "🐳 squirty whale | docker",
    "✨ sparkles",
    "🦇 bat",
    "🚨 alarm | siren | wee woo",
    "🦐 shrimp",
    "🍤 fried shrimp",
    "🔥 fire",
}
-- Could possibly parse vim.fn.digraph_getlist(true) for more

local function insert_string_at_cursor(str)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor[1]
    local cursor_col = cursor[2]
    if vim.api.nvim_get_mode().mode == "n" then
        -- insert at RIGHT edge of cursor block, not left edge. This more
        -- closely mirrors putting text with 'p'.
        cursor_col = cursor_col + 1
    end
    -- insert text at cursor
    local oldline = vim.fn.getline(cursor_line)
    local newline = string.sub(oldline, 1, cursor_col) .. str .. string.sub(oldline, cursor_col + 1)
    vim.fn.setline(cursor_line, newline)
    -- advance cursor forward by length of text
    vim.api.nvim_win_set_cursor(0, { cursor_line, cursor_col + #str })
end

function iconpick()
    vim.ui.select(symbols, {
        prompt = "o wile e sitelen | Choose symbol",
    }, function(choice, idx)
        if choice == nil or not vim.bo.modifiable then
            return
        end
        local symbol = vim.fn.split(choice)[1]
        -- why was this here?
        -- if symbol == "v:null" then
        --     return
        -- end
        vim.api.nvim_paste(symbol, false, -1)
    end)
end

-- TODO use these arguments to better mirror vim.ui.select
function custom_select_func(items, opts, on_choice)
    -- todo make popup, calling on_choice when done, and override vim.ui.input with this func
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].bufhidden = "wipe"
    local revert_to_normal_mode_when_done = false
    vim.api.nvim_create_autocmd("BufWinEnter", {
        buffer = bufnr,
        callback = function(e)
            if vim.api.nvim_get_mode().mode ~= "i" then
                vim.api.nvim_feedkeys("i", "n", false) -- immediately enter insert mode
                revert_to_normal_mode_when_done = true
            end
        end,
    })

    local width_scaling_factor = 0.25 -- (scaling factors are 0-1)
    local height_scaling_factor = 0.90 -- (scaling factors are 0-1)
    local win_width = vim.api.nvim_list_uis()[1].width
    local win_height = vim.api.nvim_list_uis()[1].height
    local width = win_width * width_scaling_factor
    local height = win_height * height_scaling_factor
    width = math.max(width, 35) -- minimum window width
    local win_id = vim.api.nvim_open_win(bufnr, true, {
        width=math.floor(width),
        height=math.floor(height),
        col=(win_width - width) / 2,
        row=(win_height - height) / 2,
        relative='editor',
        border='single',
        title={ { ' select ', 'Title' } },
        title_pos='center',
    })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = win_id })
    vim.api.nvim_set_option_value("colorcolumn", "", { win = win_id })
    vim.api.nvim_set_option_value("winfixbuf", true, { win = win_id })
    vim.api.nvim_set_option_value("number", false, { win = win_id })

    local function close_popup(selection)
        if revert_to_normal_mode_when_done then
            vim.api.nvim_feedkeys(vim.keycode("<esc>"), "n", true)
        end
        vim.api.nvim_buf_delete(bufnr, {})
        local idx = vim.fn.index(items, selection)
        on_choice(selection)
    end
    vim.keymap.set({ "n", "i" }, "<c-c>", close_popup, { buffer = bufnr })
    vim.keymap.set("n", "<esc>", close_popup, { buffer = bufnr })

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = bufnr,
        callback = function(e)
            vim.api.nvim_win_close(win_id, false)
        end,
    })

    local function populate_popup_with_digraphs(items)
        -- Populate the popup. pop pop pop
        -- Header
        vim.api.nvim_buf_set_lines(bufnr, 1, 2, false, { string.rep("=", 100) })
        -- Options
        local startline = 2
        local endline = 999999 -- Symbols just go to the end of the buffer
        local strict_indexing = false
        vim.api.nvim_buf_set_lines(bufnr, startline, endline, strict_indexing, items)
    end
    populate_popup_with_digraphs(items)

    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = bufnr,
        callback = function(e)
            -- TODO validate, make sure user is unable to edit anything other
            -- than the first line. etc.
            local user_input = vim.api.nvim_buf_get_lines(bufnr, 0, 1, true)
            user_input = user_input[1]
            local matches = vim.fn.matchfuzzy(items, user_input)
            if user_input == "" then
                -- For whatever reason, matchfuzzy() returns no matches for an
                -- empty query.
                matches = items
            end
            populate_popup_with_digraphs(matches)
        end,
    })

    vim.api.nvim_create_autocmd({ "CursorMovedI" }, {
        buffer = bufnr,
        callback = function(e)
            local cursor_line = vim.api.nvim_win_get_cursor(win_id)[1]
            if cursor_line ~= 1 then
                -- Move the cursor back
                local user_query_length = #vim.api.nvim_buf_get_lines(bufnr, 1, 2, true)[1]
                vim.api.nvim_win_set_cursor(win_id, { 1, user_query_length })
            end
        end,
    })

    vim.keymap.set("i", "<enter>", function()
        local selection = vim.fn.getline(vim.api.nvim_win_get_cursor(0)[1] + 2)
        close_popup(selection)
    end, { buffer = bufnr })
    vim.keymap.set("n", "<enter>", function()
        local selection = vim.fn.getline(vim.api.nvim_win_get_cursor(0)[1])
        close_popup(selection)
    end, { buffer = bufnr })

end

vim.keymap.set("i", "<c-q>", iconpick, { desc = "sitelen" })
vim.keymap.set("n", "<leader><leader>i", iconpick, { desc = "sitelen" })

local prev_select = vim.ui.select
vim.ui.select = custom_select_func



-- TODO split this file into vim.ui.select and the actual emoji picker thing.
-- Also make the vim.ui.select window resize when VimResized. see toothpick for
-- reference. Also do vim.ui.input while we're at it. Goes in vim_ui.lua.

-- TODO programming language nerd font icons. Also put those in the toothpick
-- signcolumn if possible
