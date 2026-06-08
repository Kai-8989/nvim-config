-- Visual line moves: re-indents automatically after moving so the code stays
-- correctly formatted regardless of context.
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep the cursor vertically centered during half-page jumps so context
-- above and below the cursor stays balanced.
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Yank into the + register (OS clipboard) so text is available outside Neovim.
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete into the black-hole register so the deleted text never overwrites
-- whatever is currently in the clipboard.
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- ─── ROS2 LSP Setup ──────────────────────────────────────────────────────────
-- Pyright runs in Neovim's inherited environment and cannot see ROS2 packages
-- unless told where to find them. This command sources install/setup.bash to
-- discover the full Python path, then writes it into pyrightconfig.json so
-- pyright resolves all workspace imports without a virtual environment.
-- Re-run after any `colcon build` that adds new packages.
vim.api.nvim_create_user_command('RosPyrightSetup', function()
    -- Walk up from cwd to find the ROS2 workspace (identified by install/setup.bash,
    -- which colcon generates after a successful build).
    local dir = vim.fn.getcwd()
    local setup = nil
    for _ = 1, 8 do
        local candidate = dir .. '/install/setup.bash'
        if vim.fn.filereadable(candidate) == 1 then
            setup = candidate
            break
        end
        local parent = vim.fn.fnamemodify(dir, ':h')
        if parent == dir then break end
        dir = parent
    end

    if not setup then
        vim.notify('RosPyrightSetup: no install/setup.bash found', vim.log.levels.ERROR)
        return
    end

    local ws_root = vim.fn.fnamemodify(setup, ':h:h')

    -- Source the workspace setup and ask Python for its full sys.path.
    -- setup.bash chains to /opt/ros/<distro>/setup.bash internally, so a single
    -- source gives us both the base ROS paths and the workspace packages.
    local script = 'source ' .. setup .. ' && python3 -c "import sys,json;print(json.dumps([p for p in sys.path if p]))"'
    local output = vim.fn.system('bash -c ' .. vim.fn.shellescape(script))
    local ok, paths = pcall(vim.fn.json_decode, vim.trim(output))

    if not ok or type(paths) ~= 'table' then
        vim.notify('RosPyrightSetup: failed to read Python paths', vim.log.levels.ERROR)
        return
    end

    -- Write a human-readable pyrightconfig.json at the workspace root.
    -- extraPaths is the pyright setting that extends its module search locations.
    local lines = { '{', '  "extraPaths": [' }
    for i, p in ipairs(paths) do
        local comma = i < #paths and ',' or ''
        lines[#lines + 1] = '    "' .. p .. '"' .. comma
    end
    lines[#lines + 1] = '  ]'
    lines[#lines + 1] = '}'

    local config_path = ws_root .. '/pyrightconfig.json'
    local f = io.open(config_path, 'w')
    f:write(table.concat(lines, '\n') .. '\n')
    f:close()

    vim.notify('Written: ' .. config_path .. ' — restarting LSP...', vim.log.levels.INFO)
    -- Brief delay lets the file system flush before pyright re-reads the config.
    vim.defer_fn(function() vim.cmd('LspRestart') end, 300)
end, { desc = 'Generate pyrightconfig.json from ROS2 workspace' })

-- ─── File Runner ─────────────────────────────────────────────────────────────
-- Runs the current file in a centered floating terminal themed to TokyoNight.
-- Python: walks up from cwd looking for a ROS2 install/setup.bash and sources
-- it before running, so workspace packages are importable without a venv.
-- C/C++: compiles to /tmp to avoid polluting the source tree.
vim.keymap.set('n', '<leader>rp', function()
    local cwd      = vim.fn.getcwd()
    local raw_file = vim.fn.expand('%:p')
    local file     = vim.fn.shellescape(raw_file)
    local ft       = vim.bo.filetype
    local out      = vim.fn.shellescape('/tmp/' .. vim.fn.expand('%:t:r'))

    -- Locate a ROS2 workspace by walking up from cwd.
    local function find_ros2_setup()
        local dir = cwd
        for _ = 1, 8 do
            local setup = dir .. '/install/setup.bash'
            if vim.fn.filereadable(setup) == 1 then return setup end
            local parent = vim.fn.fnamemodify(dir, ':h')
            if parent == dir then break end
            dir = parent
        end
    end

    -- Wrap the python3 invocation in `bash -c "source ... && ..."` when a ROS2
    -- workspace is found. shellescape quotes the whole inner string so the shell
    -- receives it as a single argument, preserving spaces in paths.
    local ros2_setup = find_ros2_setup()
    local python_cmd
    if ros2_setup then
        python_cmd = 'bash -c ' .. vim.fn.shellescape('source ' .. ros2_setup .. ' && python3 ' .. raw_file)
    else
        python_cmd = 'python3 ' .. file
    end

    local runners = {
        python     = python_cmd,
        cpp        = 'g++ -std=c++17 ' .. file .. ' -o ' .. out .. ' && ' .. out,
        c          = 'gcc '           .. file .. ' -o ' .. out .. ' && ' .. out,
        javascript = 'node '      .. file,
        typescript = 'ts-node '   .. file,
        sh         = 'bash '      .. file,
        lua        = 'lua '       .. file,
    }

    local cmd = runners[ft]
    if not cmd then
        vim.notify('No runner defined for filetype: ' .. ft, vim.log.levels.WARN)
        return
    end

    -- Open an 80 % × 80 % floating window centered on the editor.
    local width  = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines   * 0.8)
    local row    = math.floor((vim.o.lines   - height) / 2)
    local col    = math.floor((vim.o.columns - width)  / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width, height = height,
        row = row, col = col,
        style = 'minimal',
        border = 'rounded',
    })

    -- Tie the float's colors to TokyoNight's float palette so it doesn't clash
    -- with the transparent main editor background.
    vim.api.nvim_set_option_value('winhighlight', 'Normal:NormalFloat,FloatBorder:FloatBorder', { win = win })

    vim.fn.termopen(cmd, { cwd = cwd })

    -- <Esc> exits terminal-insert mode without closing the window, so the output
    -- remains readable and scrollable.
    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { buffer = buf })
    vim.keymap.set('n', 'q',     '<cmd>close<cr>', { buffer = buf })
    vim.cmd('startinsert')
end, { desc = 'Run current file in floating terminal' })
