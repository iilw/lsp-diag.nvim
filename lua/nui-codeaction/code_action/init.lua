local util = require("nui-codeaction.code_action.util")
local Config = require("nui-codeaction.config")

local M = {}

function M.show()
	local bufnr = vim.api.nvim_get_current_buf()
	local params = vim.lsp.util.make_range_params()
	params.context = {
		diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr),
	}
	util.send_code_actions(bufnr, {
		params = params,
		callback = function(action_tuples)
			if #action_tuples > 0 then
				util.render_popup(action_tuples)
			else
				if not Config.options.notify_silent then
					vim.notify("Not found actions", "info")
				end
			end
		end,
	})
end

return M
