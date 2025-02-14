local diagnostic = require("lsp_diag.diagnostic")
local code_action = require("lsp_diag.code_action")
local popup = require("lsp_diag.popup")

local M = {}

function M.goto_next()
	local bufnr = vim.api.nvim_get_current_buf()
	local next_diag = diagnostic.get_next({ bufnr = bufnr })
	if next_diag then
		diagnostic.set_cursor(next_diag)
		popup:init()
		code_action:send_code_actions(bufnr, function(actions)
			popup:show({
				actions = actions,
				diagnostic = next_diag,
			})
		end)
	else
		print("next diagnostic not found")
	end
end

function M.goto_prev()
	local prev_diag = diagnostic.get_prev()
	if prev_diag then
		diagnostic.set_cursor(prev_diag)
	else
		print("prev diagnostic not found")
	end
end

return M
