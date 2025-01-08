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

-- フローティングウィンドウを作成してレジスタを表示
function M.show_registers()
	local registers = M.get_registers()

	-- レジスタの内容をフォーマット
	local lines = {}
	for _, reg in ipairs(registers) do
		table.insert(lines, string.format("%s: %s", reg.name, reg.content:gsub("\n", "\\n")))
	end

	-- ウィンドウサイズを計算
	local width = math.max(30, vim.fn.winwidth(0) * 0.5)
	local height = math.min(#lines + 2, vim.fn.winheight(0) * 0.8)

	-- フロートウィンドウの設定
	local opts = {
		relative = "editor",
		width = math.floor(width),
		height = math.floor(height),
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	}

	-- 新しいバッファを作成
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- フローティングウィンドウを作成
	vim.api.nvim_open_win(buf, true, opts)

	-- キーマッピングを追加して閉じる
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
end

-- プラグインのコマンドを設定
function M.setup()
	vim.api.nvim_create_user_command("ShowRegisters", function()
		M.show_registers()
	end, {})
end

return M
