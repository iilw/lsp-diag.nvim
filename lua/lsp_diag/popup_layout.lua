local autocmd = require("nui.utils.autocmd")
local NuiLayout = require("nui.layout")
local Object = require("lsp_diag.utils.class")

--- @class lsp_diag.PopupLayout
--- @field layout NuiLayout
--- @field layout_options nui_layout_options
local Layout = Object:extend()

--- @alias lsp_diag.PopupLayout.constructor fun():lsp_diag.PopupLayout
--- @param diag_popup lsp_diag.DiagPopup
--- @param actions_popup lsp_diag.ActionsPopup
function Layout:new(diag_popup, actions_popup)
	self.layout_options = {
		position = diag_popup.nui_options.position,
		size = diag_popup.nui_options.size,
	}
	self.layout = NuiLayout(
		self.layout_options,
		NuiLayout.Box({
			NuiLayout.Box(diag_popup.nui_popup, { size = diag_popup.nui_options.size }),
			NuiLayout.Box(actions_popup.nui_popup, { size = actions_popup.nui_options.size }),
		}, { dir = "col" })
	)

	return self
end

function Layout:unmount()
	self.layout:unmount()
end

function Layout:mount()
	self.layout:mount()

	local bufnr = vim.api.nvim_get_current_buf()
	local close_autocmds = {
		autocmd.event.CursorMoved,
		autocmd.event.CursorMovedI,
		autocmd.event.InsertEnter,
		autocmd.event.BufDelete,
		autocmd.event.WinScrolled,
	}

	vim.defer_fn(function()
		vim.api.nvim_create_autocmd(close_autocmds, {
			buffer = bufnr,
			once = true,
			callback = function()
				self:unmount()
			end,
		})
	end, 0)
end

--- @Type lsp_diag.PopupLayout | lsp_diag.PopupLayout.constructor
local PopupLayout = Layout

return PopupLayout
