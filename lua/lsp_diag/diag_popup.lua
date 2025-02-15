local NuiPopup = require("nui.popup")
local autocmd = require("nui.utils.autocmd")
local Object = require("lsp_diag.utils.class")
local utils = require("lsp_diag.utils")

--- @class lsp_diag.DiagPopup : lsp_diag.Class
--- @field diag vim.Diagnostic
--- @field nui_popup NuiPopup
--- @field nui_options nui_popup_options
local Popup = Object:extend()

--- @alias lsp_diag.DiagPopup.contstructor fun(diag:vim.Diagnostic, options?:nui_popup_options):lsp_diag.DiagPopup
--- @param diag vim.Diagnostic
--- @param options? nui_popup_options
function Popup:new(diag, options)
	local f_options = options or {}
	local c_options = require("lsp_diag.config").options.popup.diag or {}
	--- @type nui_layout_option_position
	local position
	--- @type nui_layout_option_size
	local size

	local diag_msg = self:message_format(diag)

	if f_options.position == nil and c_options.position == nil then
		position = self:get_popup_position({
			diag.lnum,
			diag.col,
		})
	end

	if f_options.size == nil and c_options.size == nil then
		size = {
			width = vim.fn.strwidth(diag_msg),
			height = 1,
		}
	end

	self.nui_options = vim.tbl_deep_extend("force", { position = position, size = size }, c_options, f_options)
	self.diag = diag

	self.nui_popup = NuiPopup(self.nui_options)

	self:write_message(diag_msg, diag.severity)

	return self
end

--- @param diag vim.Diagnostic
function Popup:message_format(diag)
	local source = diag.source or ""
	local code = diag.code or ""
	return diag.message .. " " .. source .. " " .. code
end

--- @param diag_pos table (row,col)
function Popup:get_popup_position(diag_pos)
	return {
		row = diag_pos[1] + 1,
		col = utils.get_left_col_width() + diag_pos[2],
	}
end

--- @param message string
--- @param severity vim.diagnostic.Severity
function Popup:write_message(message, severity)
	local bufnr = self.nui_popup.bufnr
	local hl_group = "Diagnostic" .. vim.diagnostic.severity[severity]

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
		message,
	})

	-- vim.api.nvim_buf_add_highlight(bufnr, 0, "hl_group", 0, 1, 1)
end

function Popup:unmount()
	self.nui_popup:unmount()
end

function Popup:monut()
	self.nui_popup:mount()
	-- local bufnr = vim.api.nvim_get_current_buf()
	-- autocmd.buf.define(bufnr, autocmd.event.CursorMoved, function()
	-- 	self:unmount()
	-- end, {
	-- 	once = true,
	-- })
end

--- @type lsp_diag.DiagPopup | lsp_diag.DiagPopup.contstructor
local DiagPopup = Popup

return DiagPopup
