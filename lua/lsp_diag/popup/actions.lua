local NuiPopup = require("nui.popup")
local Object = require("lsp_diag.utils.class")
local BasePopup = require("lsp_diag.popup")
local code_action = require("lsp_diag.code_action")
local autocmd = require("nui.utils.autocmd")

--- @alias lsp_diag.Popup.Actions.constructor fun(options:lsp_diag.Popup.options,actions:lsp.CodeAction[]):lsp_diag.Popup.Actions

--- @class lsp_diag.Popup.Actions : lsp_diag.Popup
--- @field action_tuples action_tuple[]
--- @field bound_keys string[]
local ActionsPopup = BasePopup:extend()

--- @param options lsp_diag.Popup.options
--- @param action_tuples action_tuple[]
function ActionsPopup:init(options, action_tuples)
	self.action_tuples = action_tuples or {}

	local lines_and_size = code_action.get_lines_and_size(self.action_tuples)
	local size = lines_and_size.size
	local lines = lines_and_size.lines

	--- @type nui_popup_options
	local default_options = {
		size = size,
	}
	options.nui_options = vim.tbl_deep_extend("keep", options.nui_options or {}, default_options)
	BasePopup.init(self, "actions", options)

	local bufnr = self.popup.bufnr
	-- write_lines
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

function ActionsPopup:unmount()
	BasePopup.unmount(self)
	self:unbind_autocmd()
end

function ActionsPopup:mount()
	BasePopup.mount(self)
	self:binding_autocmd()
end

function ActionsPopup:unbind_autocmd()
	local bufnr = vim.api.nvim_get_current_buf()
	code_action.unbind_actions_shortcut(bufnr, self.action_tuples)
end

function ActionsPopup:binding_autocmd()
	local bufnr = vim.api.nvim_get_current_buf()
	code_action.actions_shortcut(bufnr, self.action_tuples, {
		callback = function(key, action_tuple)
			code_action.run_action(action_tuple)
			self:unmount()
		end,
	})
end

return ActionsPopup
