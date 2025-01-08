local M = {}

-- Neovimのレジスタ一覧を取得する関数
function M.get_registers()
	local registers = {}
	local reg_names =
		{ '"', "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=", "_", "*", "+", "#", "%", "/", ":" }
	for _, reg in ipairs(reg_names) do
		local content = vim.fn.getreg(reg)
		if content ~= "" then
			table.insert(registers, { name = reg, content = content })
		end
	end
	return registers
end

-- レジスタの内容を新しいバッファに表示する
function M.show_registers()
	local registers = M.get_registers()

	-- 新しいバッファを作成
	vim.cmd("vnew")
	local buf = vim.api.nvim_get_current_buf()

	-- バッファを読み取り専用に設定
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- レジスタの内容をフォーマットして挿入
	local lines = {}
	for _, reg in ipairs(registers) do
		table.insert(lines, string.format("%s: %s", reg.name, reg.content:gsub("\n", "\\n")))
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- 読み取り専用に変更
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- プラグインのコマンドを設定
function M.setup()
	vim.api.nvim_create_user_command("ShowRegisters", function()
		M.show_registers()
	end, {})
end

return M
