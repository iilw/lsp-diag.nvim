local M = {}

--- @param opts nui_code_action_options
function M.setup(opts)
	vim.notify("hello nui-codeaction.nvim")

	require("nui-codeaction.config").setup(opts)

	-- create command
	vim.api.nvim_create_user_command("NuiCodeactionShow", function()
		require("nui-codeaction.code_action").show()
	end, {})
end

return M
