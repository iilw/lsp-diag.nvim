--- @class nui_code_action_options
--- @field nui_options nui_popup_options
--- @field notify_silent boolean

local M = {}

function M.defaults()
	--- @type nui_code_action_options
	local defaults = {
		notify_silent = false,
		nui_options = {
			border = {
				style = "rounded",
				text = {
					top = "ACTIONS",
				},
			},
		},
	}
	return defaults
end

--- @param options nui_code_action_options
function M.setup(options)
	options = options or {}
	M.options = vim.tbl_deep_extend("force", M.defaults(), options)
end

return M
