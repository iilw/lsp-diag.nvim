local utils = require("lsp_diag.utils")

local BasePopup = require("lsp_diag.popup")

---@alias lsp_diag.Popup.Diagnostic.constructor fun(options:lsp_diag.Popup.options):lsp_diag.Popup.Diagnostic

--- @class lsp_diag.Popup.Diagnostic : lsp_diag.Popup
local DiagPopup = BasePopup:extend()

--- @param options lsp_diag.Popup.options
function DiagPopup:init(options)
	self.diagnostic = options.diagnostic
	--- @type nui_popup_options
	local default_options = {
		size = {
			width = self.diagnostic:get_message_width(),
			height = 1,
		},
	}

	options.nui_options = vim.tbl_deep_extend("keep", options.nui_options or {}, default_options)

	BasePopup.init(self, "diag", options)

	self:write_message()
end

function DiagPopup:mount()
	BasePopup.mount(self)
end

function DiagPopup:message_format()
	local diag = self.diagnostic:get()
	local source = diag.source or ""
	local code = diag.code or ""
	return diag.message .. " " .. source .. " " .. code
end

function DiagPopup:write_message()
	local diag = self.diagnostic:get()
	local message = diag.message
	local bufnr = self.popup.bufnr
	local hl_group = "Diagnostic" .. vim.diagnostic.severity[diag.severity]
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
		message,
	})
	-- vim.api.nvim_buf_add_highlight(bufnr, 0, "hl_group", 0, 1, 1)
end

--- @type lsp_diag.Popup.Diagnostic|lsp_diag.Popup.Diagnostic.constructor
local DiagPopupNew = DiagPopup

return DiagPopupNew
