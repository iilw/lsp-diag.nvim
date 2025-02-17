local DiagPopup = require("lsp_diag.popup.diagnostic")
local ActionsPopup = require("lsp_diag.popup.actions")
local code_action = require("lsp_diag.code_action")
local diagnostic = require("lsp_diag.diagnostic")

local M = {}

--- @param callback fun(diagnostic: lsp_diag.Diagnostic):nil
local function goto_next_diagnostic(callback)
	local bufnr = vim.api.nvim_get_current_buf()
	local diag = vim.diagnostic.get_next({ bufnr = bufnr })
	if diag then
		local cur = diagnostic:new(diag)
		-- set cursor
		if cur:is_cursor_on_diagnostic() == false then
			diagnostic:set_cursor()
		end
		callback(cur)
	else
		print("not found")
	end
end

function M.show_goto_next_actions()
	goto_next_diagnostic(function(diag)
		code_action.send_code_actions(0, function(all_actions)
			local actions_popup = ActionsPopup({
				diagnostic = diag,
			}, all_actions)
			actions_popup:mount()
		end)
	end)
end

function M.show_goto_next_diagnostic()
	goto_next_diagnostic(function(diag)
		local diag_popup = DiagPopup({
			diagnostic = diag,
		})
		diag_popup:mount()
	end)
end

return M
