local M = {}

--- @param opts? vim.diagnostic.GotoOpts
function M.get_next(opts)
	return vim.diagnostic.get_next(opts)
end

--- @param opts? vim.diagnostic.GotoOpts
function M.get_prev(opts)
	return vim.diagnostic.get_prev(opts)
end

--- @param diagnostic vim.Diagnostic
--- @return integer[]
function M.get_pos(diagnostic)
	return {
		diagnostic.lnum + 1,
		diagnostic.col,
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

return M
