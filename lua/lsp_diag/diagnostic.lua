--- @class lsp_diag.Diagnostic
--- @field private diagnostic vim.Diagnostic
local M = require("lsp_diag.utils.class"):extend()

--- @param diagnostic vim.Diagnostic
function M:new(diagnostic)
	self.diagnostic = diagnostic
	return self
end

function M:get()
	return self.diagnostic
end

--- @return {row: integer, col: integer}
function M:get_pos()
	return {
		row = self.diagnostic.lnum + 1,
		col = self.diagnostic.col,
	}
end

function M:is_cursor_on_diagnostic()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	return self.diagnostic.lnum == cursor_pos[1] - 1
end

function M:set_cursor()
	local pos = M:get_pos()
	vim.api.nvim_win_set_cursor(0, { pos.row, pos.col })
end

function M:get_message_width()
	return vim.fn.strwidth(self.diagnostic.message)
end

return M
