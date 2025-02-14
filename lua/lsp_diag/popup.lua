local NuiLayout = require("nui.layout")
local NuiPopup = require("nui.popup")

local M = require("lsp_diag.utils.class"):extend()

function M:init()
	self.code_action_popup = self:get_code_action_popup()
	self.diagnostic_popup = self:get_diagnostic_popup()
	self.layout = NuiLayout(
		{
			position = "50%",
			size = {
				width = 50,
				height = "50%",
			},
		},
		NuiLayout.Box({
			NuiLayout.Box(self.diagnostic_popup, { size = "50%" }),
			NuiLayout.Box(self.code_action_popup, { size = "50%" }),
		}, { dir = "col" })
	)
end

--- @param opts {
--- actions:lsp.CodeAction[],
--- diagnostic:vim.Diagnostic,
--- }
function M:show(opts)
	local actions = opts.actions
	local diag = opts.diagnostic

	self.layout:mount()

	self:set_diagnostic_lines(diag)
	self:set_code_action_lines(actions)
end

--- @param diagnostic vim.Diagnostic
function M:set_diagnostic_lines(diagnostic)
	local bufnr = self.diagnostic_popup.bufnr
	local lines = { diagnostic.message }
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

--- @param actions lsp.CodeAction[]
function M:set_code_action_lines(actions)
	local bufnr = self.code_action_popup.bufnr
	local lines = {}
	for index, action in pairs(actions) do
		table.insert(lines, self:get_code_action_message_format(index, action))
	end
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

--- @param index integer
--- @param action lsp.CodeAction
--- @return string
function M:get_code_action_message_format(index, action)
	return string.format("%d. %s", index, action.title)
end

function M:get_code_action_popup()
	return NuiPopup({
		position = {
			row = 1,
			col = 1,
		},
		size = {
			width = 59,
			height = 50,
		},
		buf_options = {},
		win_options = {},
		border = "rounded",
	})
end

function M:get_diagnostic_popup()
	return NuiPopup({
		border = "rounded",
		position = {
			row = 1,
			col = 1,
		},
		size = {
			width = 50,
			height = 50,
		},
		buf_options = {},
		win_options = {},
	})
end

return M
