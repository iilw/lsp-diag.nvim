local NuiPopup = require("nui.popup")
local NuiTree = require("nui.tree")

--- @class code_action_popup_internal:nui_popup_internal
--- @field items NuiTree.Node[]

--- @class CodeActionPopup:NuiPopup
--- @field private _ code_action_popup_internal
--- @field tree NuiTree
--- @field nui_popup_options nui_popup_options
local Popup = NuiPopup:extend("CodeActionPopup")

--- @param action_tuple action_tuple
--- @param extend_data table
function Popup.Item(action_tuple, extend_data)
	local data = vim.tbl_deep_extend("force", action_tuple, extend_data)
	return NuiTree.Node(data)
end

--- @class code_action_popup_options
--- @field items NuiTree.Node[]

--- @param nui_options nui_popup_options
--- @param options code_action_popup_options
function Popup:init(nui_options, options)
	self.nui_options = nui_options
	Popup.super.init(self, self.nui_options)
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
end

return Popup
