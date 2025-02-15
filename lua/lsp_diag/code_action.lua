local utils = require("lsp_diag.utils")
local methods = require("vim.lsp.protocol").Methods

local M = {}

--- @param action lsp.CodeAction
--- @param client vim.lsp.Client
function M.run_action(action, client)
	if action.edit then
		vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
	end
	if action.command then
		client.request(methods.workspace_executeCommand, action.command, nil)
	end
end

--- @param bufnr integer
--- @param callback fun(actions:lsp.CodeAction[])
--- @param code_action_context? lsp.CodeActionContext
function M.send_code_actions(bufnr, callback, code_action_context)
	local offset_encoding = utils.get_offset_encoding(bufnr)
	local params = vim.lsp.util.make_range_params(0, offset_encoding)
	local context = vim.tbl_deep_extend("force", {
		diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr),
	}, code_action_context or {})
	params.context = context
	vim.lsp.buf_request(bufnr, methods.textDocument_codeAction, params, function(_, actions)
		callback(actions)
	end)
end

return M
