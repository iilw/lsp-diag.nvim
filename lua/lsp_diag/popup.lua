local NuiPopup = require("nui.popup")
local Object = require("lsp_diag.utils.class")
local config = require("lsp_diag.config")
local autocmd = require("lsp_diag.utils.autocmd")

--- @alias lsp_diag.Popup.options { diagnostic:lsp_diag.Diagnostic, nui_options?: nui_popup_options}

--- @class lsp_diag.Popup : lsp_diag.Class
--- @field diagnostic lsp_diag.Diagnostic
--- @field popup NuiPopup
--- @field options nui_popup_options
--- @field name string
local Popup = Object:extend()

--- @param name string
--- @param options lsp_diag.Popup.options
function Popup:init(name, options)
	self.diagnostic = options.diagnostic
	self.options = vim.tbl_deep_extend(
		"force",
		config.options.popup.base or {},
		config.options.popup[name] or {},
		options.nui_options or {}
	)
	self.popup = NuiPopup(self.options)
end

function Popup:__tostring()
	return "Popup: " .. self.name
end

function Popup:mount()
	self.popup:mount()
	local bufnr = vim.api.nvim_get_current_buf()
	autocmd.close_autocmds(bufnr, function(autocmd_id)
		self:unmount()
		vim.api.nvim_del_autocmd(autocmd_id)
	end)
end

function Popup:unmount()
	self.popup:unmount()
end

return Popup
