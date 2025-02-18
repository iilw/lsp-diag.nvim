local M = {}

--- @class lsp_diag.Options
local defaults = {
	popup = {
		--- @type nui_popup_options
		base = {
			anchor = "NW",
			relative = "cursor",
			position = {
				row = 2,
				col = 1,
			},
			border = {
				style = "rounded",
			},
		},
		---@type nui_popup_options
		diag = {
			border = {
				text = {
					top = "HINT",
				},
			},
		},
		--- @type nui_popup_options
		actions = {
			border = {
				text = {
					top = "ACTIONS",
				},
			},
		},
	},
}

--- @type lsp_diag.Options
M.options = nil

--- @params options? lsp_diag.Options
function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options or {})
end

return M
