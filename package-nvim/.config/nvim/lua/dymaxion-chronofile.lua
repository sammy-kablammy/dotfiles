
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

Logs should ignore files with 0 seconds, also anything in /tmp/ (or at least
make it configurable to ignore things in /tmp/), and .git/COMMIT_EDITMSG

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

-- constant referring to time spent without a file, i think this time should be
-- folded in with the previous file
local NO_FILE = "<NO_FILE>"

-- Make sure log directory exists. Return false if it fails to create.
local function ensure_dir_exists(dirname)
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

local function setup()
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
    -- Some header info
    file:write("version 1\n") -- This is still super experimental so the version number doesn't mean anything yet, but eventually it will
    -- vim can actually infer, this is not necessary:
    -- file:write("# vim: ft=conf\n") -- for comment highlighting
    file:write("# event log file created on " .. os.date() .. '\n')

end

setup()

----------------------------------- Logging ------------------------------------

-- Why use UTC if we only care about the difference between two timestamps?
-- Because the system timezone may change while a vim instance is open.
local function get_current_time_utc()
    -- ! to use UTC
    -- *t to return a table instead of a string, because os.time expects a table
    -- os.time() converts date into a single-number timestamp
    return os.time(os.date('!*t'))
    -- return vim.fn.localtime()
end

local function append_event_to_file(ev)
    if disable_logging_for_this_session then
        return
    end

    -- RECALL:
    -- vim.print(ev)
    -- ev.event -- event name
    -- ev.file -- file path
    -- ev.buf -- buffer number

    local event_name = ev.event
    local event_file = ev.file
    local event_buf = ev.buf

    -- TODO should we use uv.gettimeofday() instead? then we could have better than second precision
    local unix_timestamp = get_current_time_utc()

    if ev.event == "BufEnter" and not vim.bo[ev.buf].buflisted then
        -- TODO make this a callback that the user can specify, like treesitter's disable callback
        file:write("# Skipping unlisted buffer " .. ev.event .. ' ' .. ev.buf .. ' ' .. ev.file .. '\n')
        file:flush()
        return
    end

    -- File paths should always be stored as precisely as possible. This creates a
    -- canonical representation of the filename for storage. Displaying file names
    -- in a condensed way is ok.
    --
    -- We can't use vim.fs.normalize because it assumes the normalization is
    -- happening on the local filesystem. we want this to work even if the session
    -- files we're analyzing no longer exist or don't exist on the current machine
    local tilde_expand_filename = vim.fn.expand

    local git_branch = "<NO_GIT_BRANCH>"
    local file_dir = tilde_expand_filename(vim.fs.dirname(event_file))
    -- Make sure to -C into the file's dir, just in case vim's pwd is in a different repo than the file
    local obj = vim.system({ "git", "-C", file_dir, "rev-parse", "--abbrev-ref", "HEAD" }, {
        timeout = 1000, -- unsure of the units here...
    }, nil):wait()
    local EXIT_SUCCESS = 0
    if obj.code == EXIT_SUCCESS then
        git_branch = string.sub(obj.stdout, 1, -2) -- (remove trailing newline)
    else
    end

    if event_file == "" then
        event_file = NO_FILE
    else
        event_file = tilde_expand_filename(event_file)
        -- escape special characters here, remember to un-escape them when analyzing
        event_file = string.gsub(event_file, ' ', '%%20')
    end

    file:write(unix_timestamp, "\t", event_name, "\t", git_branch, "\t", event_file, "\n")
    file:flush()
end

local events_to_log = {
    "BufEnter",
    "FocusLost",
    "FocusGained",
    -- we probably don't want matching bufleaves and bufenters
    -- "BufLeave",
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
    end,
    desc = "Dymaxion Chronofile exit event",
})

--------------------------------- Analyze logs ---------------------------------

-- Put all members of 'source' into 'dest', adding times cumulatively
local function merge_tables(dest, source)
    for filename, seconds in pairs(source) do
        if dest[filename] == nil then
            dest[filename] = seconds
        else
            dest[filename] = dest[filename] + seconds
        end
    end
end

local function print_error(...)
    vim.print("dymaxion-chronofile error:", ...)
end

-- given a line, validate that it's a valid entry, return a table containing each field
local function parse_and_validate_entry(line)
    local split = vim.split(line, "\t", {})
    -- vim.print("Validating:", split)
    if #split ~= 4 then
        vim.print("Failed to validate number of fields in entry", split, #split)
    end
    -- Timestamp sanity checks
    local timestamp = split[1]
    timestamp = tonumber(timestamp)
    if timestamp == nil then
        print("Failed to validate timestamp. Expected number, got", timestamp)
    end
    if timestamp <= 0 then
        print("Failed to validate timestamp. Expected >0, got", timestamp)
    end
    local event = split[2]
    local git_branch = split[3]
    local filename = split[4]
    -- un-escape weird characters in file names here
    filename = string.gsub(filename, '%%20', ' ')
    return {
        timestamp = timestamp,
        event = event,
        git_branch = git_branch,
        filename = filename,
    }
end

-- TODO when bailing, move the log file to an error dir. that way we don't try
-- again later.
--
-- Parse filename for errors
local function parse_single_log(lines, filename)
    -- print("FILE!")
    version = 1 -- default version
    local running_file = ""
    local running_file_edit_start_time = 0
    local time_map = {} -- maps file names to total editing times
    local debug_loop_count = 0
    for _, line in pairs(lines) do
        if line == '' or string.sub(line, 1, 1) == '#' then
            -- Skip empty lines and comments
            -- print('SKIPPINGTON: "' .. line .. '"')
            -- (continue)
        elseif string.sub(line, 1, #"version") == "version" then
            version = string.sub(line, #"version " + 1)
            -- (continue)
        else -- else: this must be a normal record
            local entry = parse_and_validate_entry(line)

            -- TODO we need to not put the branch in here. should keep the data
            -- structured for longer. during this rewrite, let's go ahead and
            -- use maplike tables { .branch, .file, time } instead of arraylike
            -- tables. Everything up until the sort functions should be
            -- maplike.
            local pretty_filename = entry.git_branch .. ':' .. entry.filename
            -- Ensure that this file is in the time map so we can do a simple += later on
            if time_map[pretty_filename] == nil then
                time_map[pretty_filename] = 0
            end

            -- print("loop number", debug_loop_count, entry.event, running_file, running_file_edit_start_time)
            debug_loop_count = debug_loop_count + 1
            -- switch on the event type:
            if entry.event == "BufEnter" then
                if running_file == "" then
                    -- print('start counting for', pretty_filename)
                    -- start counting
                    running_file = pretty_filename
                    running_file_edit_start_time = entry.timestamp
                else
                    -- print('stop counting for', running_file, 'start counting for', pretty_filename)
                    -- stop counting previous file
                    local previous_file_edit_time = entry.timestamp - running_file_edit_start_time
                    time_map[running_file] = time_map[running_file] + previous_file_edit_time
                    -- start counting this file
                    running_file = pretty_filename
                    running_file_edit_start_time = entry.timestamp
                end
            elseif entry.event == "FocusLost" or entry.event == "VimSuspend" then
                if running_file == "" then
                    -- Somehow we lost focus before ever opening a file... hmmm...
                    return {}
                end
                -- Stop counting until vim is refocused
                local previous_file_edit_time = entry.timestamp - running_file_edit_start_time
                -- print(running_file, time_map[running_file], previous_file_edit_time)
                time_map[running_file] = time_map[running_file] + previous_file_edit_time
            elseif entry.event == "FocusGained" or entry.event == "VimResume" then
                -- Resume counting at previous file
                running_file_edit_start_time = entry.timestamp
            elseif entry.event == "VimEnter" then
                -- Not used right now
            elseif entry.event == "VimLeave" then
                -- stop counting
                local edit_time = entry.timestamp - running_file_edit_start_time
                if running_file == "" then
                    -- This happens when you never open any counted files, just skipped ones
                    return {}
                    -- TODO generally, we want to catch errors and just return the empty table from this function, that way one bad log won't prevent all the good logs from being used
                end
                -- print(time_map, running_file, time_map[running_file], edit_time)
                time_map[running_file] = time_map[running_file] + edit_time
                running_file = ""

                -- Break in case more events appear after VimLeave. I've seen
                -- this happen with FocusLost sometimes.
                -- Or maybe this isn't needed? Ehh just delete
                -- break

            else
                -- TODO make sure we handle all events
                print_error('do not know how to parse event:', entry.event)
                return {}
            end

        end
    end

    -- Some quick sanity checks
    if running_file ~= "" then
        -- Somehow we started time for a file but never finished. Maybe vim
        -- crashed and so the log file didn't contain a VimLeave?
        print("Unfinished time entry, bailing")
        return {}
    end
    local SECONDS_PER_YEAR = 31536000
    for filename, seconds in pairs(time_map) do
        if seconds > SECONDS_PER_YEAR then
            -- This is probably a system time change or something. Needs to be
            -- figured out.
            print("Ummm... file '" .. filename .. "' logged over a year in a single session: " .. seconds)
            return {}
        end
        if seconds < 0 then
            -- For some reason this triggers sometimes. idk.
            -- print("Somehow edited file for a negative amount of time?", filename)
            return {}
        end
    end

    return time_map
end

local function analyze_complete_logs()
    if not ensure_dir_exists(complete_log_dir) then
        return {}
    end
    -- TODO could also verify that files match the expected name format... then again the version number should be at the top... idk.
    all_log_files = vim.fn.readdir(complete_log_dir)
    total_time_map = {}
    for _, log in pairs(all_log_files) do
        if log == "example.log" then -- for testing, remove
        elseif log == "expected.log" then -- for testing, remove
        else
            log = complete_log_dir .. '/' .. log
            local lines = vim.fn.readfile(log)
            -- print('parsing this file ', log)
            local time_map = parse_single_log(lines, log)
            if #time_map == 0 then
                -- print("Empty table from", log)
            end
            merge_tables(total_time_map, time_map)
        end
    end

    -- shorten $HOME to ~ for display purposes
    local home = vim.fn.getenv("HOME")
    for filename, time in pairs(total_time_map) do
        local home_abbreviated = string.gsub(filename, home, '~')
        total_time_map[filename] = nil
        total_time_map[home_abbreviated] = time
    end
    -- remove files in /tmp/
    local home = vim.fn.getenv("HOME")
    for filename, time in pairs(total_time_map) do
        if vim.fn.matchstr(filename, ':/tmp/') ~= "" then
            total_time_map[filename] = nil
        end
    end
    -- remove times below a certain cutoff value
    local REMOVE_SHORTER_THAN_THIS_SECONDS = 5
    for filename, time in pairs(total_time_map) do
        if time < REMOVE_SHORTER_THAN_THIS_SECONDS then
            total_time_map[filename] = nil
        end
    end
    -- TODO beautify times, so instead of seconds it's hours:minutes

    return total_time_map
end

-- given a week (week format TBD), find all complete logs whose vim sessions STARTED
-- during that week, compute the total editing times for that week, and finally
-- squish all those files into a tarball so we don't run out of inodes after
-- using this for a while lmao
--
-- No we should do days instead. Days make more sense as the atomic unit. Remember: we're doing
-- START of a day so there are no day crossover conflicts. Can group days into
-- year directories to not have >366 days in one directory.
local function consolidate_day()
end

------------------------------------- GUI --------------------------------------

local function dymaxion_gui()
    -- TODO all this gui code is copied from toothpick, need to scrub it more carefully for differences
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "dymaxion", { buf = bufnr })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
    -- Use the PID to create uniqueness in the buffer name, otherwise two vim
    -- instances couldn't open the popup in the same directory
    vim.api.nvim_buf_set_name(bufnr, "Dymaxion" .. vim.fn.getpid())

    local function populate_popup(sort_func)

        -- The sort funcs should operate on structured data only, the last-mile string formatting should happen here
        -- Definition of a sort func (may change, but we need to define it
        -- clearly when adding more. Currently return { time, filename }
        arraylike_data = sort_func()
        stringified = {}
        for _, entry in ipairs(arraylike_data) do
            table.insert(stringified, string.format("%6d", entry[1]) .. "\t\t" .. entry[2])
        end

        vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
        vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { "Time\t\tFilename" })
        vim.api.nvim_buf_set_lines(bufnr, 1, 999999, false, stringified)
        vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
    end
    local function sort_by_time()
        local map = analyze_complete_logs()
        local arraylike = {}
        -- convert the maplike table into an arraylike table, such that the
        -- following:    map[filename]=time   becomes    map[1]={time,filename}
        for filename, time in pairs(map) do
            table.insert(arraylike, {time, filename})
        end
        -- now sort that table.
        table.sort(arraylike, function(a, b)
            -- Note that a typical sort func is supposed to be a < b but I want times sorted from high to low. So we use >
            return a[1] > b[1]
        end)

        return arraylike
    end
    vim.keymap.set("n", "T", function()
        populate_popup(sort_by_time)
    end, { buffer = bufnr })
    vim.keymap.set("n", "G", function()
        print("sort by Git branch not yet implemented")
    end, { buffer = bufnr })

    vim.api.nvim_create_autocmd({ "BufEnter" }, {
        buffer = bufnr,
        callback = function()
            populate_popup(sort_by_time)
        end,
    })

    -- Highlight settings for the arglist window title
    local ns_id = vim.api.nvim_create_namespace("dymaxion_title")
    vim.api.nvim_set_hl(ns_id, "DymaxionWindowTitle", { bold = true, })

    local width_scaling_factor = 0.9 -- (scaling factors are 0-1)
    local height_scaling_factor = 0.9 -- (scaling factors are 0-1)
    local win_width = vim.api.nvim_list_uis()[1].width
    local win_height = vim.api.nvim_list_uis()[1].height
    local width = win_width * width_scaling_factor
    local height = win_height * height_scaling_factor
    local col = (win_width - width) / 2
    local row = (win_height - height) / 2
    local win_id = vim.api.nvim_open_win(bufnr, true, {
        width=math.floor(width),
        height=math.floor(height),
        col=col,
        row=row,
        relative='editor',
        border='single',
        title={ { ' dymaxion chronofile ', 'DymaxionWindowTitle' } },
        title_pos='center',
        footer='bottom text',
        footer_pos='right',
    })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = win_id })
    vim.api.nvim_set_option_value("colorcolumn", "", { win = win_id })
    vim.api.nvim_set_option_value("winfixbuf", true, { win = win_id })
    vim.api.nvim_set_option_value("number", false, { win = win_id })

    -- Close without saving
    local close_popup = function()
        if vim.api.nvim_win_get_buf(0) ~= bufnr then
            -- The window is already closed. I don't know how we got here but
            -- there's nothing to do.
            return
        end
        vim.api.nvim_win_close(win_id, true)
        -- unset name because the next time popup is opened it would conflict
        vim.api.nvim_buf_set_name(bufnr, "")
    end
    vim.keymap.set("n", "<esc>", close_popup, { buffer = bufnr })
    vim.keymap.set("n", "<BS>", close_popup, { buffer = bufnr })
    vim.keymap.set("n", "q", close_popup, { buffer = bufnr })
    vim.keymap.set("n", "<C-c>", close_popup, { buffer = bufnr })

    -- this autocmd exists to handle selecting another window, like with <C-w>h
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        buffer = bufnr,
        callback = close_popup,
    })
end

vim.api.nvim_create_user_command("Dymaxion", dymaxion_gui, { desc = "Open dymaxion-chronofile popup window" })

------------------------------------ tests -------------------------------------

function dymaxion_test()

    local test_file = [[
# comment, ignore this
version 1
1772567903	BufEnter	SomeBranchName	/some/repo/README.md
# Skipping unlisted buffer BufEnter 2 minifiles://2//some/repo
# Skipping unlisted buffer BufEnter 5 minifiles://5//some/repo/somefile.cmake
# Skipping unlisted buffer BufEnter 6 minifiles://6//some/repo/Makefile2
# Skipping unlisted buffer BufEnter 7 minifiles://7//some/repo/Makefile
1772567909	BufEnter	SomeBranchName	/some/repo/Makefile
1772567909	BufEnter	SomeBranchName	/some/repo/Makefile
1772567913	FocusLost	SomeBranchName	/some/repo/Makefile
1772567918	FocusGained	SomeBranchName	/some/repo/Makefile
1772567920	BufEnter	SomeBranchName	/some/repo/README.md
1772567921	VimSuspend	SomeBranchName	<NO_FILE>
1772567925	VimResume	SomeBranchName	<NO_FILE>
1772567927	VimLeave	SomeBranchName	/some/repo/README.md
]]

    local lines = vim.fn.split(test_file, "\\n")
    local tab = parse_single_log(lines, "<debug file>")
    vim.print(tab)
    if tab["SomeBranchName:/some/repo/Makefile"] ~= 6 then
        print("Test failed")
    end
    if tab["SomeBranchName:/some/repo/README.md"] ~= 9 then
        print("Test failed")
    end
    print("test passed")
end

-- at time of writing we combine the git branch and filename early on. we want
-- to do that at the very final stringification step. that way we don't need to
-- parse the branch from the file all the time. keep data structured for as long
-- as possible.
