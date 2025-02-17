local NuiPopup = require("nui.popup")
local Object = require("lsp_diag.utils.class")
local BasePopup = require("lsp_diag.popup")
local code_action = require("lsp_diag.code_action")

--- @alias lsp_diag.Popup.Actions.constructor fun(options:lsp_diag.Popup.options,actions:lsp.CodeAction[]):lsp_diag.Popup.Actions

--- @class lsp_diag.Popup.Actions : lsp_diag.Popup
--- @field all_actions all_actions
--- @field bound_keys string[]
local ActionsPopup = BasePopup:extend()

--- @param options lsp_diag.Popup.options
--- @param all_actions all_actions
function ActionsPopup:init(options, all_actions)
	self.all_actions = all_actions

	--- @type nui_popup_options
	local default_options = {
		anchor = "NW",
		relative = "cursor",
		position = {
			row = 2,
			col = 1,
		},
		size = {
			width = 20,
			height = 5,
		},
	}
	options.nui_options = vim.tbl_deep_extend("keep", options.nui_options or {}, default_options)
	BasePopup.init(self, options)
end

function ActionsPopup:unmount()
	BasePopup.unmount(self)
	-- self:del_actions()
end

function ActionsPopup:del_actions()
	local bufnr = vim.api.nvim_get_current_buf()
	local bound_keys = self.bound_keys or {}
	for _, key in ipairs(bound_keys) do
		vim.api.nvim_buf_del_keymap(bufnr, "n", key)
	end
	self.bound_keys = nil
end

function ActionsPopup:mount()
	BasePopup.mount(self)
	self:write_lines()
	self:create_all_actions_shortcut()
end

function ActionsPopup:create_all_actions_shortcut()
	local bufnr = vim.api.nvim_get_current_buf()

	for client_id, actions in ipairs(self.all_actions) do
		code_action.actions_shortcut(bufnr, actions, {
			callback = function(key, action)
				local client = vim.lsp.get_client_by_id(client_id)
				if not client then
					print("No client found!")
					return
				end
				code_action.run_action(action, client)
				self:unmount()
			end,
		})
	end
end

--- @param actions lsp.CodeAction[]
--- @return nui_layout_option_size
function ActionsPopup:get_default_size(actions)
	return {
		width = 90,
		height = #actions or 0,
	}
end

--- @param options nui_popup_options
--- @return nui_layout_option_position
function ActionsPopup:get_default_position(options)
	return {
		row = options.position.row + options.size.height + 1,
		col = options.position.col,
	}
end

function ActionsPopup:write_lines()
	local bufnr = self.popup.bufnr
	--- @type string[]
	local items = {}

	local index = 1
	for _, item in ipairs(self.all_actions) do
		for _, action in ipairs(item[2]) do
			items[#items + 1] = string.format("%d. %s", index, action.title or "123")
			index = index + 1
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, items)
end

return ActionsPopup
