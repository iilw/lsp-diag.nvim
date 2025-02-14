local popup = require("lsp_diag.popup")

local M = {}

M.defaults = {}

M.options = {}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", M.defaults, options or {})
end

return M
