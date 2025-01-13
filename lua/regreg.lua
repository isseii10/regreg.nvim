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
		table.insert(lines, reg.reg .. ": " .. reg.content)
	end
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- レジスタ番号部分を編集不可に設定
	for i, reg in ipairs(registers) do
		api.nvim_buf_add_highlight(buf, -1, "Comment", i - 1, 0, 3) -- "1: " 部分にハイライト
	end
	api.nvim_buf_set_option(buf, "modifiable", true)
	api.nvim_buf_set_option(buf, "readonly", false)

	-- フローティングウィンドウを表示
	local opts = {
		relative = "editor",
		width = 40,
		height = #lines,
		col = 10,
		row = 5,
		style = "minimal",
		border = "rounded",
	}
	local win = api.nvim_open_win(buf, true, opts)

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
