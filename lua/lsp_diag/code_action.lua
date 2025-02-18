local utils = require("lsp_diag.utils")
local methods = require("vim.lsp.protocol").Methods

--- @alias all_actions table<integer, lsp.CodeAction[]>
--- @alias action_tuple { action:lsp.CodeAction, client_id:integer }

local M = {}

--- @param action_tuple action_tuple
function M.run_action(action_tuple)
	local client = vim.lsp.get_client_by_id(action_tuple.client_id)
	if not client then
		print("No client found!")
		return
	end

	if action_tuple.action.edit then
		vim.lsp.util.apply_workspace_edit(action_tuple.action.edit, client.offset_encoding)
	end
	if action_tuple.action.command then
		local command = action_tuple.action.command
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
--- @param callback fun(action_tuples: action_tuple[])
--- @param code_action_context? lsp.CodeActionContext
function M.send_code_actions(bufnr, callback, code_action_context)
	local offset_encoding = utils.get_offset_encoding(bufnr)
	local params = vim.lsp.util.make_range_params(0, offset_encoding)
	local context = vim.tbl_deep_extend("force", {
		diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr),
	}, code_action_context or {})
	params.context = context
	vim.lsp.buf_request_all(bufnr, methods.textDocument_codeAction, params, function(results)
		--- @type action_tuple[]
		local action_tuples = {}
		for client_id, response in ipairs(results) do
			if #response.result > 0 then
				for _, action in pairs(response.result) do
					action_tuples[#action_tuples + 1] = {
						action = action,
						client_id = client_id,
					}
				end
			end
		end
		callback(action_tuples)
	end)
end

---@param bufnr integer
---@param actions action_tuple[]
---@param options {
--- callback: fun(key: string,action:action_tuple)}
function M.actions_shortcut(bufnr, actions, options)
	for num, action_tuple in ipairs(actions) do
		local key = tostring(num)
		vim.api.nvim_buf_set_keymap(bufnr, "n", tostring(num), "", {
			noremap = true,
			silent = true,
			callback = function()
				options.callback(key, action_tuple)
			end,
		})
	end
end

function M.unbind_actions_shortcut(bufnr, actions)
	for num, action in ipairs(actions) do
		vim.api.nvim_buf_del_keymap(bufnr, "n", tostring(num))
	end
end

--- @param action_tuples action_tuple[]
function M.get_lines_and_size(action_tuples)
	local lines = {}
	local width, height = 0, 0

	for index, action_tuple in pairs(action_tuples) do
		local line = string.format("[%d] %s", index, action_tuple.action.title or "")
		local line_width = vim.fn.strdisplaywidth(line)
		lines[#lines + 1] = line
		width = math.max(width, line_width)
	end

	height = math.min(10, #lines)

	return {
		lines = lines,
		size = {
			width = width,
			height = height,
		},
	}
end

return M
