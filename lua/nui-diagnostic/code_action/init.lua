local Config = require("nui-diagnostic.config")
local util = require("nui-diagnostic.code_action.util")

local M = {}

function M.setup()
	if not Config.options.code_action.enabled then
		return
	end

	-- add command
	-- command.register_command("code_action", M.run)
end

function M.show()
	local bufnr = vim.api.nvim_get_current_buf()
	local params = util.get_range_params(bufnr)
	util.send_code_actions(bufnr, {
		params = params,
		callback = function(action_tuples)
			if #action_tuples > 0 then
				util.render_popup(action_tuples)
			end
		end,
	})
end

return M
