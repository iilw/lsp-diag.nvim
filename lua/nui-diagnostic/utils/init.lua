local M = {}

--- @param bufnr integer
--- @param fallback? "utf-8" | "utf-16" | "utf-32"
function M.get_offset_encoding(bufnr, fallback)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	if #clients > 0 and clients[1].offset_encoding then
		return clients[1].offset_encoding
	end
	return fallback or "utf-8"
end

function M.get_left_col_width()
	local winid = vim.api.nvim_get_current_win()
	local wininfo = vim.fn.getwininfo(winid)[1]
	return wininfo.textoff
end

return M
