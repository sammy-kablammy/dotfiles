local bufferline = require("bufferline")
bufferline.setup {
    options = {
        numbers = "buffer_id",
        show_close_icon = true, -- this doesn't work lol
        buffer_close_icon = '',
        always_show_bufferline = false,
        separator_style = "thin",
        style_preset = bufferline.style_preset.no_italic,
        diagnostics = "nvim_lsp",
    }
}
