local NuiPopup = require("nui.popup")
local Object = require("lsp_diag.utils.class")

--- @class lsp_diag.ActionsPopup
--- @field nui_popup NuiPopup
--- @field nui_options nui_popup_options
--- @field actions lsp.CodeAction[]
local Popup = Object:extend()

--- @alias lsp_diag.ActionsPopup.constructor fun(actions:lsp.CodeAction[],options?:nui_popup_options):lsp_diag.ActionsPopup
--- @param actions lsp.CodeAction[]
--- @param diag_options nui_popup_options
--- @param options? nui_popup_options
function Popup:new(actions, diag_options, options)
	local f_options = options or {}
	local c_options = require("lsp_diag.config").options.popup.actions or {}

	--- @type nui_layout_option_position
	local position
	--- @type nui_layout_option_size
	local size

	if f_options.position == nil and c_options.position == nil then
		position = self:get_default_position(diag_options)
	end
	if f_options.size == nil and c_options.size == nil then
		size = self:get_default_size(actions)
	end

	self.nui_options = vim.tbl_deep_extend("force", { position = position, size = size }, c_options, f_options)
	self.nui_popup = NuiPopup(self.nui_options)

	self.actions = actions
	self:write_lines()

	return self
end

--- @param actions lsp.CodeAction[]
--- @return nui_layout_option_size
function Popup:get_default_size(actions)
	return {
		width = 90,
		height = #actions,
	}
end

--- @param options nui_popup_options
--- @return nui_layout_option_position
function Popup:get_default_position(options)
	return {
		row = options.position.row + options.size.height + 1,
		col = options.position.col,
	}
end

function Popup:unmount()
	self.nui_popup:unmount()
end

function Popup:mount()
	self.nui_popup:mount()
end

function Popup:write_lines()
	local bufnr = self.nui_popup.bufnr
	--- @type string[]
	local items = {}
	--- @type fun(index:integer,action:lsp.CodeAction):string
	local format = function(index, action)
		return string.format("%d. %s", index, action.title)
	end
	for index, action in pairs(self.actions) do
		table.insert(items, format(index, action))
	end
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, items)
end

--- @type lsp_diag.ActionsPopup | lsp_diag.ActionsPopup.constructor
local ActionsPopup = Popup

return ActionsPopup
