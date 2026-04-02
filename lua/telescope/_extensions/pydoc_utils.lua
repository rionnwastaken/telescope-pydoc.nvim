local M = {}

local pydoc
local function setup(opts)
	pydoc = opts
end

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local utils = require("telescope.utils")
local conf = require("telescope.config").values

---@param func_to_do function
local function show_picker(opts, content_array, func_to_do)
	local previewer_opts = opts.remove_previewer
	if previewer_opts == nil then
		previewer_opts = previewers.cat.new(opts)
	else
		previewer_opts = nil
	end

	pickers
		.new(opts, {
			prompt_title = opts.prompt_title,
			finder = finders.new_table({
				results = content_array,
				entry_maker = function(line)
					return make_entry.set_default_entry_mt({
						ordinal = line,
						display = line,
						filename = line,
					}, opts)
				end,
			}),
			previewer = previewer_opts,
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					if selection == nil then
						utils.__warn_no_selection("builtin.planets")
						return
					end

					actions.close(prompt_bufnr)
					func_to_do(selection.display)
				end)

				return true
			end,
		})
		:find()
end

local open = io.open
local function read_file(path)
	local file = open(path, "rb") -- r read mode and b binary mode
	if not file then
		return nil
	end
	local content = file:read("*a") -- *a or *all reads the whole file
	file:close()
	return content
end

local function show_pydoc_in_buffer(keyword)
	local b_id = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, b_id)
	vim.schedule(function()
		vim.cmd("set filetype=man")
		vim.cmd("setlocal buftype=nofile")
		vim.cmd("setlocal bufhidden=wipe")
		vim.cmd("setlocal noswapfile")
		local escaped = vim.fn.shellescape(keyword)
		vim.cmd(string.format("r !%s %s", pydoc.command, escaped))
		vim.api.nvim_win_set_cursor(0, { 1, 1 })
	end)
end

--Creates json file with keywords only if file doesnt exist
local createJson = function()
	local overwrite = ""

	if pydoc.overwrite_write == true then
		overwrite = "-f"
	end

	local script = pydoc.pydoc_lazy_path .. "/python/createJson.py"

	if pydoc.local_root_folder ~= nil then
		script = string.format("%s/%s", pydoc.local_root_folder, "python/createJson.py")
	end


    -- Script checks: file exists ? exit(0) : gather keywords
	vim.system({ "python3", script, overwrite })
end

local merge_tables = function(table_origin, table2)
	local merged_table = {}

	for key, value in pairs(table_origin) do
		merged_table[key] = value
	end

	for key, value in pairs(table2) do
		merged_table[key] = value
	end

	return merged_table
end

M.read_file = read_file
M.createJson = createJson
M.show_picker = show_picker
M.show_pydoc_in_buffer = show_pydoc_in_buffer
M.merge_tables = merge_tables
M.setup = setup

return M
