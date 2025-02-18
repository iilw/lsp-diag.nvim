local autocmd = require("nui.utils.autocmd")

local M = {}

--- @param bufnr integer
--- @param callback fun(autocmd_id:integer)
function M.close_autocmds(bufnr, callback)
	local close_autocmds = {
		autocmd.event.CursorMoved,
		autocmd.event.CursorMovedI,
		autocmd.event.InsertEnter,
		autocmd.event.BufDelete,
		autocmd.event.WinScrolled,
	}
	vim.defer_fn(function()
		local autocmd_id
		autocmd_id = vim.api.nvim_create_autocmd(close_autocmds, {
			buffer = bufnr,
			once = true,
			callback = function()
				callback(autocmd_id)
			end,
		})
	end, 0)
end

return M
