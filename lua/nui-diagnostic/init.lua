local M = {}

function M.setup(opts)
	-- require("nui-diagnostic.config").setup(opts)
	-- require("nui-diagnostic.command").setup()
	-- require("nui-diagnostic.code_action").setup()

	vim.api.nvim_create_user_command("NuiDiagnosticAction", function()
		require("nui-diagnostic.code_action").run()
	end, {})
end

return M
