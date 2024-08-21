-- you can see all abbreviations with :abbreviate or :ab for short.
-- use :abbreviate (:ab) for both insert and command modes.
-- :cab for command mode only, :iab for insert mode only.

vim.cmd([[
    inoreabbrev mdcode ```<cr><cr>```<up>
    inoreabbrev cdb ```<cr>```<up>
    noreabbrev functino function
    noreabbrev serach search
    noreabbrev seraching searching
]])
