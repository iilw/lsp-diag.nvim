local CodeActionPopup = require("nui-codeaction.code_action.popup")
local Config = require("nui-codeaction.config")

local methods = vim.lsp.protocol.Methods

--- @class action_tuple
--- @field action lsp.CodeAction
--- @field client_id integer

local M = {}

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
--- params:table,
--- callback: fun(action_tuples:action_tuple[])
--- }
function M.send_code_actions(bufnr, options)
	vim.lsp.buf_request_all(bufnr, methods.textDocument_codeAction, options.params, function(results)
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
	local max_width = 0
	local keymaps = {} --- @type {key:string,run:fun()}[]

	for index, action_tuple in ipairs(action_tuples) do
		local text = string.format("[%d] %s", index, action_tuple.action.title)
		local text_len = vim.fn.strdisplaywidth(text)

		max_width = math.max(max_width, text_len)

		items[#items + 1] = CodeActionPopup.Item(action_tuple, {
			text = text,
		})
		keymaps[#keymaps + 1] = {
			key = tostring(index),
			run = function()
				M.run_action(action_tuple)
			end,
		}
	end

	--- @type nui_popup_options
	local nui_options = {
		relative = "cursor",
		position = {
			col = 1,
			row = 2,
		},
		size = {
			width = max_width,
			height = #action_tuples,
		},
	}

	local popup = CodeActionPopup(vim.tbl_deep_extend("force", nui_options, Config.options.nui_options), {
		items = items,
	})

	local cur_bufnr = vim.api.nvim_get_current_buf()
	local function close()
		popup:unmount()
	end

	local function register_keymaps()
		for _, keymap in ipairs(keymaps) do
			vim.api.nvim_buf_set_keymap(cur_bufnr, "n", keymap.key, "", {
				noremap = true,
				silent = true,
				callback = function()
					keymap.run()
					close()
				end,
			})
		end
	end

	local function unregister_keymaps()
		for _, keymap in ipairs(keymaps) do
			vim.api.nvim_buf_del_keymap(cur_bufnr, "n", keymap.key)
		end
	end

	popup:on("BufWinEnter", function()
		register_keymaps()
		M.autohide(function()
			close()
		end)
	end, { once = true })

	popup:on("BufWinLeave", function()
		unregister_keymaps()
	end, { once = true })

	popup:mount()
end

--- @param callback fun()
function M.autohide(callback)
	local autocmds = {
		"CursorMoved",
		"CursorMovedI",
		"InsertEnter",
	}
	vim.api.nvim_create_autocmd(autocmds, {
		callback = function()
			vim.schedule(callback)
		end,
	})
end

return M
