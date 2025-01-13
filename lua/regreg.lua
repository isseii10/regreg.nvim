local M = {}

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
}

-- レジスタ情報を取得
local function get_registers()
	local registers = {}
	for _, reg in ipairs(reg_names) do
		local content = vim.fn.getreg(reg)
		if content ~= "" then
			table.insert(registers, { name = reg, content = content })
		end
	end
	return registers
end

-- レジスタウィンドウを表示
function M.show_registers_window()
	local buf = vim.api.nvim_create_buf(false, true) -- フローティングウィンドウ用のバッファ

	-- ウィンドウの幅と高さを画面の 70% に設定
	local width = math.floor(vim.o.columns * 0.7)
	local height = math.floor(vim.o.lines * 0.7)

	-- ウィンドウを画面中央に配置するための計算
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- フローティングウィンドウを作成
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	})

	local registers = get_registers()

	-- バッファにレジスタ内容を表示
	local lines = {}
	for _, reg in ipairs(registers) do
		table.insert(lines, string.format("%s", reg.content:gsub("\n", "\\n")))
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- サインカラムにレジスタ名を表示
	for i, reg in ipairs(registers) do
		vim.fn.sign_define("RegSign" .. i, { text = reg.name, texthl = "Identifier" })
		vim.fn.sign_place(i, "RegGroup", "RegSign" .. i, buf, { lnum = i })
	end

	-- バッファを編集可能に設定
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- 編集後にレジスタに再登録
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		callback = function()
			local updated_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			for i, line in ipairs(updated_lines) do
				local reg_name = registers[i].name
				vim.fn.setreg(reg_name, line)
			end
		end,
	})

	-- サインカラムの有効化
	vim.api.nvim_win_set_option(win, "signcolumn", "yes:2")
end

-- プラグインのコマンドを設定
function M.setup()
	vim.api.nvim_create_user_command("ShowRegisters", function()
		M.show_registers_window()
	end, {})
	vim.keymap.set("n", '"', M.show_registers_window)
end

return M
