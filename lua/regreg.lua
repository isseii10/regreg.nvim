local M = {}

local api = vim.api

local reg_names = {
	'"',
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"-",
	"=",
	"_",
	"*",
	"+",
	"#",
	"%",
	"/",
	":",
}

---@private
---@return table
function M.get_registers()
	local registers = {}
	for _, reg in ipairs(reg_names) do
		local content = vim.fn.getreg(reg)
		if content ~= "" then
			table.insert(registers, { name = reg, content = content })
		end
	end
	return registers
end

function M.show_registers()
	local registers = M.get_registers()

	-- フローティングウィンドウ用のバッファを作成
	local buf = api.nvim_create_buf(false, true)
	-- フローティングウィンドウの内容を生成
	local lines = {}
	for _, reg in ipairs(registers) do
		table.insert(lines, reg.name .. ": " .. reg.content)
	end
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- レジスタ番号部分を編集不可に設定
	for i, reg in ipairs(registers) do
		api.nvim_buf_add_highlight(buf, -1, "Comment", i - 1, 0, 3) -- "1: " 部分にハイライト
	end
	api.nvim_buf_set_option(buf, "modifiable", true)
	api.nvim_buf_set_option(buf, "readonly", false)

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

	-- レジスタ番号部分を再編集不可に設定
	for i, reg in ipairs(registers) do
		api.nvim_buf_set_text(buf, i - 1, 0, i - 1, 3, { reg.reg .. ": " })
		api.nvim_buf_set_option(buf, "modifiable", true)
	end

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
