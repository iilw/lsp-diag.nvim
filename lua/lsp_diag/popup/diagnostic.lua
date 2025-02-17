local utils = require("lsp_diag.utils")

local BasePopup = require("lsp_diag.popup")

--- @class lsp_diag.Popup.Diagnostic : lsp_diag.Popup
local DiagPopup = BasePopup:extend()

--- @param options lsp_diag.Popup.options
function DiagPopup:init(options)
	local diagnostic = options.diagnostic
	--- @type nui_popup_options
	local default_options = {
		anchor = "NW",
		relative = "cursor",
		position = {
			row = 2,
			col = 1,
		},
		size = {
			width = diagnostic:get_message_width(),
			height = 1,
		},
	}

	options.nui_options = vim.tbl_deep_extend("keep", options.nui_options or {}, default_options)

	BasePopup.init(self, "diag", options)
end

function DiagPopup:mount()
	BasePopup.mount(self)
	self:write_message()
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

return DiagPopup
