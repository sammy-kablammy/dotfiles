
--[[

proposed file structure:
- Initial logs are stored in ~/.local/nvim/state/dymaxion-chronofile/
- Once logs are completed (i.e. the corresponding vim instance exited
  successfully), they are moved to /completed

Separate files, one per vim session. Each time you open vim, that's a new
file. There will be a separate bit of logic (possibly shell script, possibly vim
user command) to consolidate all these files and display a report. This is a
braindead simple way to avoid 99% of data corruption problems caused by from vim
crashing, computer crashing, or just bugs in the plugin. It also handles
multiple vim sessions being created in parallel (how would you do this simply
and correctly if all vim instances wanted to write to a single file?)

- ideally we collect anything we possibly can about vim usage.
  - one option is to save basically every single event en masse with "dumb"
    loggers, and reconstruct the state of things from that (e.g. "BufEnter" foo
    followed by "BufWrite" means we can deduce foo was written)
  - another option is to save specific events with more intelligent loggers,
    like one that runs on BufWrite that also logs what buffer is being written.

Possible pitfalls:
- if we log git branch information and the branch changes without closing nvim
  (nvim just reads in the updated file), how is that logged? we can't really
  detect that can we? unless BufRead fires when branch is switched... if so we
  could intercept every BufRead and update the branch info.

Example "pretty" data readout:
- branch1:file1.txt 30:02
- branch1:file2.txt 5:41
- branch1:file3.txt 0:31
- 
- branch2:file1.txt
- branch2:file4.txt

We might actually only want to go as precise as a minute in the readout. We can
store seconds but it's not useful to show seconds

Also any time you open a buffer for say 2 seconds, don't edit or write the
buffer, then leave, that should be ignored. You were obviously just cycling
through the buffers.

how is this gonna work with time zones? if we always request timestamps as a
single time zone, since we mostly only care about the relative times, it will be
fine.

What does it mean for an event logfile to be re-created partway through a vim
session? Like the user started a vim session, deleted the event file, and
continued using vim? I think that event file should be completely discarded.

--]]

-- TODO rename these to something better

-- In addition to timestamp, we use PID in case multiple nvim sessions were
-- created in the same second (unlikely but might as well handle it)
local event_log_dir = vim.fn.getenv("HOME") .. "/.local/state/nvim/dymaxion-chronofile"
local complete_log_dir = event_log_dir .. "/completed"
local unix_timestamp = vim.fn.localtime()
local pid = vim.fn.getpid()
local event_log_filename = event_log_dir .. '/' .. unix_timestamp .. '_' .. pid .. ".log"
-- If errors come up, especially during vim exit, we want to see those:
-- local error_log_filename = "/home/sam/dotfiles/dymaxion_error.log"

-- Sometimes we'll want to abort logging because there was an error. This global
-- flag controls this behavior:
-- TODO we don't actually need this, the 'file' global duplicates this meaning
local disable_logging_for_this_session = false

-- This vim instance's log file
local file = nil

-- Make sure log directory exists. Return false if it fails to create.
function ensure_dir_exists(dirname)
    local log_dir_stat = vim.uv.fs_stat(dirname, nil)
    if log_dir_stat == nil or log_dir_stat.type ~= "directory" then
        -- print("Dymaxion directory does not exist! Creating directory:", dirname)
        local MKDIR_ERROR = 0
        local ret = vim.fn.mkdir(dirname, "p")
        if ret == MKDIR_ERROR then
            print("Unabled to make directory:", dirname)
        disable_logging_for_this_session = true
        return false
        end
    end
    return true
end

function setup()
    if not ensure_dir_exists(event_log_dir) then
        disable_logging_for_this_session = true
        return
    end

    -- Check for already-existing logfile
    -- TODO we can handle this gracefully by just appending a "_1" and trying again
    local stat = vim.uv.fs_stat(event_log_filename, nil)
    if stat ~= nil then
        print("🤓 Errrmmm, logfile already exists. Might wanna check up that, bud.")
        vim.print(stat)
        disable_logging_for_this_session = true
    end

    -- Create logfile
    file, errmsg = io.open(event_log_filename, "a")
    if file == nil then
        print("Error opening dymaxion log file!", errmsg)
        return
    end

end

setup()

----------------------------------- Logging ------------------------------------

function append_event_to_file(ev)
    if disable_logging_for_this_session then
        return
    end

    -- RECALL:
    -- vim.print(ev)
    -- ev.event -- event name
    -- ev.file -- file path
    -- ev.buf -- buffer number

    local unix_timestamp = vim.fn.localtime()

    local git_branch = "<NO_GIT_BRANCH>"
    local obj = vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, {
        timeout = 1000, -- unsure of the units here...
    }, nil):wait()
    if obj.code == 0 then
        git_branch = string.sub(obj.stdout, 1, -2) -- (remove trailing newline)
    else
    end

    if not vim.bo[ev.buf].buflisted then
        file:write("SKIP unlisted buffer " .. ev.buf .. ' ' .. ev.file .. '\n')
        file:flush()
        return
    end

    if ev.file == "" then
        ev.file = "<NO_FILE>"
    end

    file:write(unix_timestamp, " ", git_branch, " ", ev.file, " ", ev.event, "\n")
    file:flush()
end

local events_to_log = {
    "FocusGained",
    "FocusLost",
    -- we probably don't want matching bufleaves and bufenters
    -- "BufLeave",
    "BufEnter",
    "VimSuspend",
    "VimResume",
    "VimLeave",
}

vim.api.nvim_create_autocmd(events_to_log, {
    callback = function(ev)
        append_event_to_file(ev)
    end,
    desc = "Dymaxion Chronofile logging",
})

vim.api.nvim_create_autocmd("VimLeave", {
    callback = function(ev)
        if not ensure_dir_exists(complete_log_dir) then
            -- ummm what to do here?
            return
        end
        local obj = vim.system({ "mv", event_log_filename, complete_log_dir .. '/' }, {}, nil):wait() -- TODO check error
        vim.fs.rm(event_log_filename)
    end,
    desc = "Dymaxion Chronofile exit event",
})

--------------------------------- Analyze logs ---------------------------------

function consolidate()
    all_log_files = vim.fn.readdir(complete_log_dir)
    for _, log in pairs(all_log_files) do
        log = complete_log_dir .. '/' .. log
        local lines = vim.fn.readfile(log)
        parse_single_log(lines)
    end
end

-- Reasons to bail out of analysis:
-- * log file doesn't end with VimLeave
-- * background doesn't have matching foreground
-- * FocusLost doesn't have matching FocusGained
--
-- when bailing, move the log file to an error dir. that way we don't try again
-- later.
function parse_single_log(lines)
    print("FILE!")
    for _, line in pairs(lines) do
        print(line)
    end
    print()
end
