local M = {}

--- @type table<string,fun()>
M.commands = {}

function M.setup()
	vim.api.nvim_create_user_command("NuiDiagnostic", function(args) end, {})
end

--- @return string[]
function M.get_command_keys()
	return vim.tbl_keys(M.commands)
end

--- @param command string
function M.register_command(command, run)
	if not M.commands[command] then
		M.commands[command] = run
	end
end

--- @param command string
function M.unregister_command(command)
	if M.commands[command] then
		M.commands[command] = nil
	end
end

return M
