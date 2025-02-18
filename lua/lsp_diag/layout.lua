local Object = require("lsp_diag.utils.class")
local NuiLayout = require("nui.layout")
local autocmd = require("lsp_diag.utils.autocmd")
local config = require("lsp_diag.config")

--- @class lsp_diag.Layout
--- @field popups lsp_diag.Popup[]
--- @field layout NuiLayout
--- @field layout_options nui_layout_options
local Layout = Object:extend()

--- @param popups lsp_diag.Popup[]
--- @param options? nui_layout_options
function Layout:init(popups, options)
	local config_options = config.options.popup.base
	--- @type nui_layout_options
	local default_options = {
		size = {
			width = 50,
			height = 10,
		},
	}
	local max_width = 50

	self.popups = popups

	local popup_boxs = {}
	for _, popup in pairs(popups) do
		-- max_width = math.max(popup.options.size.width, max_width)
		popup_boxs[#popup_boxs + 1] = NuiLayout.Box(popup.popup, { size = "50%" })
	end

	self.layout_options = vim.tbl_deep_extend("force", default_options, config_options, options or {})
	self.layout = NuiLayout(self.layout_options, NuiLayout.Box(popup_boxs, { dir = "col" }))
end

function Layout:mount()
	self.layout:mount()

	for _, popup in ipairs(self.popups) do
		popup:mount()
	end

	local bufnr = vim.api.nvim_get_current_buf()
	autocmd.close_autocmds(bufnr, function(autocmd_id)
		self:unmount()
		vim.api.nvim_del_autocmd(autocmd_id)
	end)
end

function Layout:unmount()
	self.layout:unmount()
end

--- @type lsp_diag.Layout
local LayoutNew = Layout

return Layout
