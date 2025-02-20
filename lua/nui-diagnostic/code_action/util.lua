local methods = require("vim.lsp.protocol").Methods
local Popup = require("nui-diagnostic.code_action.popup")

--- @class action_tuple
--- @field action lsp.CodeAction
--- @field client_id integer

local M = {}

--- @param bufnr integer
function M.get_range_params(bufnr)
	local params = {}
	params = vim.lsp.util.make_range_params()
	params.context = {
		diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr),
	}
	return params
end

--- @param action_tuple action_tuple
function M.run_action(action_tuple)
	local client = vim.lsp.get_client_by_id(action_tuple.client_id)
	if not client then
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
--- @param options {
--- params: table,
--- callback: fun(action_tuples:action_tuple[])}
function M.send_code_actions(bufnr, options)
	local method = methods.textDocument_codeAction
	vim.lsp.buf_request_all(bufnr, method, options.params, function(results)
		local action_tuples = {} --- @type action_tuple[]
		for client_id, res in ipairs(results) do
			if type(res.result) == "table" and #res.result > 0 then
				for _, action in ipairs(res.result) do
					action_tuples[#action_tuples + 1] = {
						action = action,
						client_id = client_id,
					}
				end
			end
		end
		options.callback(action_tuples)
	end)
end

--- @param action_tuples action_tuple[]
function M.render_popup(action_tuples)
	local items = {} --- @type NuiTree.Node|table[]
	--- @type {key:string,run:fun()}[]
	local shortcut_keymaps = {}
	local max_width = 0

	for index, action_tuple in ipairs(action_tuples) do
		local text = string.format("[%d] %s", index, action_tuple.action.title)
		local text_width = vim.fn.strdisplaywidth(text)
		items[#items + 1] = Popup.Item(action_tuple, {
			text = text,
		})
		max_width = math.max(max_width, text_width)
		shortcut_keymaps[#shortcut_keymaps + 1] = {
			key = tostring(index),
			run = function()
				M.run_action(action_tuple)
			end,
		}
	end

	--- @type nui_popup_options
	local popup_nui_options = {
		anchor = "NW",
		relative = {
			type = "cursor",
		},
		enter = false,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = "ACTIONS",
			},
		},
		position = {
			row = 1,
			col = -1,
		},
		size = {
			width = max_width + 1,
			height = 2,
		},
	}

	local popup = Popup(popup_nui_options, {
		items = items,
	})

	local cur_bufnr = vim.api.nvim_get_current_buf()
	local function register_keymaps()
		for _, keymap in ipairs(shortcut_keymaps) do
			vim.api.nvim_buf_set_keymap(cur_bufnr, "n", keymap.key, "", {
				noremap = true,
				silent = true,
				callback = function()
					keymap.run()
					popup:unmount()
				end,
			})
		end
	end

	local function unregister_keymaps()
		for _, keymap in ipairs(shortcut_keymaps) do
			vim.api.nvim_buf_del_keymap(cur_bufnr, "n", keymap.key)
		end
	end

	popup:on("BufWinEnter", function()
		print("Hello bufenter")
		register_keymaps()
	end, {
		once = true,
	})

	popup:on("BufWinLeave", function()
		print("Hello BufLeave")
		unregister_keymaps()
	end, {
		once = true,
	})

	-- mount
	popup:mount()

	return popup
end

return M
