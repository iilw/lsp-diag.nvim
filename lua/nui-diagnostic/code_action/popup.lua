local NuiPopup = require("nui.popup")
local NuiTree = require("nui.tree")

--- @class code_action_popup_internal: nui_popup_internal
--- @field items NuiTree.Node[]

--- @class CodeActionPopup:NuiPopup
--- @field _ code_action_popup_internal
--- @field tree? NuiTree
local Popup = NuiPopup:extend("CodeActionPopup")

--- @param action_tuple action_tuple
--- @param extend table
function Popup.Item(action_tuple, extend)
	return NuiTree.Node(vim.tbl_deep_extend("force", action_tuple.action, extend))
end

--- @class code_action_popup_options
--- @field items NuiTree.Node[]

--- @param nui_options nui_popup_options
--- @param options code_action_popup_options
function Popup:init(nui_options, options)
	Popup.super.init(self, nui_options)
	self._.items = options.items
end

function Popup:mount()
	Popup.super.mount(self)
	self.tree = NuiTree({
		bufnr = self.bufnr,
		ns_id = self.ns_id,
		nodes = self._.items,
	})
	self.tree:render()
	self:autohide()
end

function Popup:autohide()
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
		group = vim.api.nvim_create_augroup("actions_popup_autohide", { clear = true }),
		callback = function()
			vim.defer_fn(function()
				self:unmount()
			end, 10)
		end,
	})
end

function Popup:unmount()
	Popup.super.unmount(self)
end

--- @alias CodeActionPopup.constructor fun(nui_options:nui_popup_options,option:code_action_popup_options):CodeActionPopup
--- @type CodeActionPopup|CodeActionPopup.constructor
local CodeActionPopup = Popup

return CodeActionPopup
