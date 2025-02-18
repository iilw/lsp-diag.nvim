local DiagPopup = require("lsp_diag.popup.diagnostic")
local ActionsPopup = require("lsp_diag.popup.actions")
local code_action = require("lsp_diag.code_action")
local diagnostic = require("lsp_diag.diagnostic")
local Layout = require("lsp_diag.layout")

local M = {}

--- @param bufnr integer
--- @param callback fun(diagnostic: lsp_diag.Diagnostic):nil
local function goto_next_diagnostic(bufnr, callback)
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
	local bufnr = vim.api.nvim_get_current_buf()
	goto_next_diagnostic(bufnr, function(diag)
		code_action.send_code_actions(0, function(action_tuples)
			local actions_popup = ActionsPopup({
				diagnostic = diag,
			}, action_tuples)
			actions_popup:mount()
		end)
	end)
end

function M.show_goto_next_diagnostic()
	local bufnr = vim.api.nvim_get_current_buf()
	goto_next_diagnostic(bufnr, function(diag)
		local diag_popup = DiagPopup({
			diagnostic = diag,
		})
		diag_popup:mount()
	end)
end

function M.show_layout()
	local bufnr = vim.api.nvim_get_current_buf()
	goto_next_diagnostic(bufnr, function(next_diag)
		code_action.send_code_actions(bufnr, function(actions)
			--- show layout popup
			local diagnostic_popup = DiagPopup({
				diagnostic = next_diag,
				nui_options = {
					position = {
						row = 0,
						col = 0,
					},
				},
			})
			local actions_popup = ActionsPopup({
				diagnostic = next_diag,
				nui_options = {
					position = {
						row = 5,
						col = 5,
					},
				},
			}, actions)

			local layout = Layout({
				diagnostic_popup,
				actions_popup,
			})

			layout:mount()
		end)
	end)
end

return M
