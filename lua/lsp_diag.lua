local M = {}

--- @param opts lsp_diag.Options
function M.setup(opts)
	require("lsp_diag.config").setup(opts)

	vim.api.nvim_set_keymap("n", "]e", "<cmd>lua require('lsp_diag.actions').show_goto_next_diagnostic()<cr>", {
		noremap = true,
		silent = true,
	})
	vim.api.nvim_set_keymap("n", "[e", "<cmd>lua require('lsp_diag.actions').show_goto_next_actions()<cr>", {
		noremap = true,
		silent = true,
	})
end

return M
