local diagnostic = require("lsp_diag.diagnostic")
local diagnostic_popup = require("lsp_diag.diagnostic_popup")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local api = vim.api

local ms = require("vim.lsp.protocol").Methods

local M = {}

local function get_diagnostics()
	local bufnr = api.nvim_get_current_buf()
	return vim.diagnostic.get(bufnr)
end

local function send_code_actions(callback)
	local bufnr = api.nvim_get_current_buf()
	local context = { diagnostics = vim.diagnostic.get(bufnr) }
	local params = vim.lsp.util.make_range_params()
	params.context = context
	vim.lsp.buf_request(bufnr, ms.textDocument_codeAction, params, function(_, actions)
		--- @type lsp.CodeAction[]
		local items = {}
		if actions then
			for _, action in ipairs(actions) do
				table.insert(items, action)
			end
		end
		callback(items)
	end)
end

function M.show()
	local cur_diagnostic = diagnostic.get_next()

	diagnostic.set_cursor(cur_diagnostic)

	local d_popup_size = {
		width = vim.fn.strwidth(cur_diagnostic.message),
		height = 1,
	}

	local actions_popup_size = {
		width = d_popup_size.width,
		height = 5,
	}

	local popup = Popup({
		position = {
			row = cur_diagnostic.lnum + 2,
			col = cur_diagnostic.end_col,
		},
		size = d_popup_size,
		border = {
			style = "rounded",
			text = {
				top = "HINT",
			},
		},
		buf_options = {
			modifiable = true,
			readonly = false,
		},
		win_options = {
			winblend = 10,
		},
	})

	local actions_popup = Popup({
		position = {
			row = cur_diagnostic.lnum + 2 + 3,
			col = cur_diagnostic.end_col,
		},
		size = actions_popup_size,
		border = {
			style = "rounded",
			text = {
				top = "ACTIONS",
			},
		},
		buf_options = {
			modifiable = true,
			readonly = false,
		},
		win_options = {
			winblend = 10,
		},
	})

	local layout = Layout(
		{
			position = {
				row = cur_diagnostic.lnum + 1,
				col = cur_diagnostic.end_col,
			},
			size = {
				width = "50%",
				height = "50%",
			},
		},
		Layout.Box({
			Layout.Box(popup, { size = d_popup_size }),
			Layout.Box(actions_popup, { size = actions_popup_size }),
		}, { dir = "col" })
	)

	api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, { cur_diagnostic.message })

	layout:mount()

	--- @param action lsp.CodeAction
	local function run_action(action)
		-- if action.edit then
		-- 	vim.lsp.util.apply_workspace_edit(action.edit, vim.bo.fileencoding or "utf-8")
		-- end
		-- if action.command then
		-- 	vim.lsp.buf.execute_command(action.command)
		-- end
	end

	send_code_actions(function(_actions)
		--- @type lsp.CodeAction[]
		local actions = _actions

		--- @type string[]
		local actions_texts = {}
		for index, action in pairs(actions) do
			table.insert(actions_texts, string.format("%d. %s", index, action.title))
		end
		api.nvim_buf_set_lines(actions_popup.bufnr, 0, -1, false, actions_texts)

		if #actions > 0 then
			if layout._.mounted then
				for i = 1, #actions do
					vim.keymap.set("n", tostring(i), function()
						run_action(actions[i])
					end, {
						silent = true,
						noremap = true,
					})
				end
			end
		end
	end)

	vim.defer_fn(function()
		api.nvim_create_autocmd("CursorMoved", {
			callback = function()
				if layout._.mounted then
					layout:unmount()
				end
			end,
		})
	end, 100)
end

function M.setup(opts)
	api.nvim_set_keymap("n", "]e", "<cmd>lua require('lsp_diag.actions').goto_next()<cr>", {
		noremap = true,
		silent = true,
	})
	api.nvim_set_keymap("n", "[e", "<cmd>lua require('lsp_diag.actions').goto_prev()<cr>", {
		noremap = true,
		silent = true,
	})
end

return M
