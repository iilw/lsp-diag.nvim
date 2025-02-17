local utils = require("lsp_diag.utils")
local methods = require("vim.lsp.protocol").Methods

--- @alias all_actions table<integer, lsp.CodeAction[]>

local M = {}

--- @param action lsp.CodeAction
--- @param client vim.lsp.Client
function M.run_action(action, client)
	if action.edit then
		vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
	end
	if action.command then
		local command = action.command
		local params
		if command then
			if type(command) == "string" then
				params = { command = command }
			else
				params = {
					command = command.command,
					arguments = command.arguments or {},
				}
			end
		end
		client.request(methods.workspace_executeCommand, params, function(err, result)
			if err then
				vim.notify("Lsp Command Error:" .. err.message, vim.log.levels.ERROR)
			end
			if result then
				vim.notify("LSP Command Executed Successfully", vim.log.levels.INFO)
			end
		end)
	end
end

--- @param bufnr integer
--- @param callback fun(all_actions: all_actions)
--- @param code_action_context? lsp.CodeActionContext
function M.send_code_actions(bufnr, callback, code_action_context)
	local offset_encoding = utils.get_offset_encoding(bufnr)
	local params = vim.lsp.util.make_range_params(0, offset_encoding)
	local context = vim.tbl_deep_extend("force", {
		diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr),
	}, code_action_context or {})
	params.context = context
	vim.lsp.buf_request_all(bufnr, methods.textDocument_codeAction, params, function(results)
		local all_actions = {}

		for client_id, response in ipairs(results) do
			table.insert(all_actions, {
				client_id,
				response.result,
			})
		end

		callback(all_actions)
	end)
end

---@param bufnr integer
---@param actions lsp.CodeAction[]
---@param options {
--- callback: fun(key: string,action:lsp.CodeAction),
--- get_key?:fun(num:number,action:lsp.CodeAction):string}
function M.actions_shortcut(bufnr, actions, options)
	for num, action in ipairs(actions) do
		local key = tostring(num)
		if options.get_key then
			key = options.get_key(num, action)
		end
		vim.api.nvim_buf_set_keymap(bufnr, "n", key, "", {
			noremap = true,
			silent = true,
			callback = function()
				options.callback(key, action)
			end,
		})
	end
end

return M
