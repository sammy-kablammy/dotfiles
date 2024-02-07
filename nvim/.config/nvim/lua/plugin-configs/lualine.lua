local lualine = require('lualine')

function count_language_servers()
    -- is this really the way to get the length of a lua table? seriously?
    return #vim.lsp.get_active_clients()
end

lualine.setup {
    options = {
        icons_enabled = true,
        -- theme = 'dracula',
        theme = 'catppuccin',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
            'NvimTree',
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = {
            {
                'filename',
                path = 4
            }
        },
        lualine_x = { 'encoding', 'fileformat' },
        -- lualine_y = { 'filetype' },
        lualine_y = { 'diagnostics', { count_language_servers } },
        lualine_z = { 'progress', 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}
