local NuiPopup = require("nui.popup")
local autocmd = require("nui.utils.autocmd")
local Object = require("lsp_diag.utils.class")
local config = require("lsp_diag.config")

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
	self:close_autocmds()
end

function Popup:unmount()
	self.popup:unmount()
end

function Popup:close_autocmds()
	local bufnr = vim.api.nvim_get_current_buf()

	local close_autocmds = {
		autocmd.event.CursorMoved,
		autocmd.event.CursorMovedI,
		autocmd.event.InsertEnter,
		autocmd.event.BufDelete,
		autocmd.event.WinScrolled,
	}
	vim.defer_fn(function()
		local autocmd_id
		autocmd_id = vim.api.nvim_create_autocmd(close_autocmds, {
			buffer = bufnr,
			once = true,
			callback = function()
				self:unmount()
				if autocmd_id then
					vim.api.nvim_del_autocmd(autocmd_id)
				end
			end,
		})
	end, 0)
end

return Popup
