local NuiPopup = require("nui.popup")

local M = require("lsp_diag.utils.class"):extend()

--- @param diagnostic vim.Diagnostic
--- @param options? nui_popup_options
function M:init(diagnostic, options)
	--- @type nui_popup_options
	local default_popup_options = {
		position = {
			row = diagnostic.lnum + 2,
			col = diagnostic.end_col,
		},
		size = {
			width = vim.fn.strwidth(diagnostic.message),
			height = 1,
		},
		buf_options = {
			modifiable = true,
		},
		win_options = {
			winblend = 10,
		},
	}
	self.diagnostic = diagnostic
	self.options = vim.tbl_deep_extend("force", default_popup_options, options or {})
	self.popup = NuiPopup(self.options)
	return self
end

return M
