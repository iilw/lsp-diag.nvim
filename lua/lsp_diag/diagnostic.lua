local M = require("lsp_diag.utils.class"):extend()

--- @param diagnostic vim.Diagnostic
--- @return {row: integer, col: integer}
function M.get_pos(diagnostic)
	return {
		row = diagnostic.lnum + 1,
		col = diagnostic.col,
	}
end

--- @param diagnostic vim.Diagnostic
function M.is_cursor_on_diagnostic(diagnostic)
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	return diagnostic.lnum == cursor_pos[1] - 1
end

--- @param diagnostic? vim.Diagnostic
function M.set_cursor(diagnostic)
	if diagnostic and M.is_cursor_on_diagnostic(diagnostic) == false then
		vim.api.nvim_win_set_cursor(0, M.get_pos(diagnostic))
	else
		print("diagnostic not found")
	end
end

--- @param diagnostic vim.Diagnostic
function M.get_message_width(diagnostic)
	return vim.fn.strwidth(diagnostic.message)
end

return M
