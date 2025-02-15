local DiagPopup = require("lsp_diag.diag_popup")
local ActionsPopup = require("lsp_diag.actions_popup")
local code_action = require("lsp_diag.code_action")
local PopupLayout = require("lsp_diag.popup_layout")

local M = {}

function M.goto_next()
	local bufnr = vim.api.nvim_get_current_buf()
	local diag = vim.diagnostic.get_next({ bufnr = bufnr })
	if diag then
		code_action.send_code_actions(bufnr, function(actions)
			local diag_popup = DiagPopup(diag)
			local actions_popup = ActionsPopup(actions, diag_popup.nui_options)

			local layout = PopupLayout(diag_popup, actions_popup)

			layout:mount()
		end)
	end
end

function M.goto_prev() end

return M
