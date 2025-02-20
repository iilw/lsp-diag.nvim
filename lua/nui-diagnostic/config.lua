local M = {}

--- @class lsp_diag.Options
local defaults = {
	code_action = {
		enabled = true,
	},
	diagnostic = {
		enabled = true,
	},
}

--- @type lsp_diag.Options
M.options = nil

--- @params options? lsp_diag.Options
function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options or {})
end

return M
