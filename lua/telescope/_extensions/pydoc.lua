local py_u = require("telescope._extensions.pydoc_utils")
local pydoc = {}

local pydoc_opts

return require("telescope").register_extension({

	setup = function(opts)
		pydoc_opts = opts
        py_u.createJson(opts)
	end,

	exports = {

		createJson = py_u.createJson,
		show_picker = function(opts)
			local data_path = string.format("%s/%s", pydoc_opts.root_folder, "data/pydoc_keywords.json")
			local cont = py_u.read_file(data_path)

			if cont == nil then
				print(string.format("%s is null", data_path))
				return
			end

			local json_d = vim.json.decode(cont)

			local content_array = {}
			for key, value in pairs(json_d) do
				table.insert(content_array, key)
			end
			table.insert(content_array, "all")

			local function get_all()
				local all = {}
				for _, arr in pairs(json_d) do
					for _, value in ipairs(arr) do
						table.insert(all, value)
					end
				end
				return all
			end

			if opts.all == true then
				py_u.show_picker({ remove_previewer = true }, get_all(), function(selection)
					py_u.show_pydoc_in_buffer(selection)
				end)

				return
			end

			py_u.show_picker({ remove_previewer = true }, content_array, function(selection_topic)
				local value_arr

				if selection_topic == "all" then
					value_arr = get_all()
				else
					value_arr = json_d[selection_topic]
				end

				py_u.show_picker({ remove_previewer = true }, value_arr, function(selection)
					py_u.show_pydoc_in_buffer(selection)
				end)
			end)

			-- print(cont)
		end,
	},
})
