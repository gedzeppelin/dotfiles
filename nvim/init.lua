-- Essential options
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.equalalways = false
vim.opt.hlsearch = true
vim.opt.inccommand = "split"
vim.opt.scrolloff = 10
vim.opt.timeoutlen = 300
vim.opt.updatetime = 250

-- Session
vim.opt.sessionoptions = {
	"buffers",
	"curdir",
	"folds",
	"globals",
	-- "help",
	"localoptions",
	"tabpages",
	-- "terminal",
	"winsize",
}

-- Indentation
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Basic key mappings
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" }) -- Exit terminal mode with double Esc

-- Custom filetypes
vim.filetype.add({
	extension = { tsql = "sql" },
})

-- Auto commands
-- Overrides for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("filetype-indentation", { clear = true }),
	desc = "Set indentation for specific filetypes",
	pattern = {
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
		"html",
	},
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.tabstop = 2
	end,
})
-- Enable English spell checking only for markdown and text
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("spell-checking", { clear = true }),
	desc = "Enable spell checking for markdown and text files",
	pattern = {
		"markdown",
		"text",
	},
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en,es"
	end,
})
-- Pack hooks
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.kind ~= "install" or ev.data.kind ~= "update" then
			return
		end
		if ev.data.spec.name ~= "telescope-fzf-native.nvim" then
			vim.system(
				{ "cmake", "-S.", "-Bbuild", "-DCMAKE_BUILD_TYPE=Release" },
				{ cwd = ev.data.path },
				function(obj)
					if obj.code ~= 0 then
						vim.notify("cmake --build failed for telescope-fzf-native.nvim")
					else
						vim.system(
							{ "cmake", "--build", "build", "--config", "Release", "--target", "install" },
							{ cwd = ev.data.path }
						)
					end
				end
			)
		end
	end,
})

vim.pack.add({
	-- Dependencies
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",

	-- Aesthetics
	"https://github.com/j-hui/fidget.nvim",

	-- Treesitter
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	"https://github.com/romus204/tree-sitter-manager.nvim",

	-- LSP
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/neovim/nvim-lspconfig",

	-- Git
	"https://github.com/NeogitOrg/neogit",
	"https://github.com/sindrets/diffview.nvim",

	-- AI
	"https://github.com/folke/sidekick.nvim",
	{ src = "https://github.com/zbirenbaum/copilot.lua", version = "v2.0.4" },

	-- Telescope
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
	"https://github.com/nvim-telescope/telescope-ui-select.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",

	-- Navigation / Formatting / Mini
	"https://github.com/folke/flash.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/stevearc/conform.nvim",

	-- Debugging
	"https://github.com/igorlfs/nvim-dap-view",
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/mfussenegger/nvim-dap-python",
	"https://github.com/theHamsta/nvim-dap-virtual-text",
})

-- Dependencies
require("mason").setup()

-- Aesthetics
---@diagnostic disable-next-line: missing-fields
require("tokyonight").setup({
	transparent = true,
	plugins = {
		all = false,
		auto = false,
		-- Actual plugins
		copilot = true,
		dap = true,
		flash = true,
		mini_animate = true,
		mini_completion = true,
		mini_cursorword = true,
		mini_files = true,
		mini_icons = true,
		mini_indentscope = true,
		mini_notify = true,
		mini_statusline = true,
		mini_surround = true,
		mini_tabline = true,
		neogit = true,
		sidekick = true,
		telescope = true,
		["treesitter-context"] = true,
		["which-key"] = true,
	},
})
vim.cmd.colorscheme("tokyonight-night")

-- Use a slightly brighter background for visual selections to improve visibility.
vim.api.nvim_set_hl(0, "Visual", { bg = "#293c6c" })
vim.api.nvim_set_hl(0, "VisualNOS", { bg = "#293c6c" })
-- Keep LSP document highlights visible, but dimmer than an active visual selection.
vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#2e3c64" })
vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#2e3c64" })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#3b4261", underline = true })
-- Copilot suggestions should be visible but not distracting, and italic to differentiate from actual code.
vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#a9b1d6", italic = true })

-- Treesitter
local tsFiletypes = {
	"bash",
	"c",
	"dockerfile",
	"http",
	"javascript",
	"javascriptreact",
	"json",
	"lua",
	"markdown",
	"python",
	"sql",
	"typescript",
	"typescriptreact",
	"vue",
	"yaml",
}

require("tree-sitter-manager").setup({
	ensure_installed = vim.tbl_filter(function(ft)
		return not string.match(ft, "react")
	end, tsFiletypes),
	highlight = false,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter-init", { clear = true }),
	desc = "Initiate Treesitter for supported filetypes",
	pattern = tsFiletypes,
	callback = function()
		vim.treesitter.start()
		vim.opt_local.foldenable = true
		vim.opt_local.foldlevel = 99
		vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo[0][0].foldmethod = "expr"
	end,
})

-- LSP
vim.lsp.log.set_level("warn")

vim.lsp.config("*", {
	capabilities = vim.lsp.protocol.make_client_capabilities(),
})
vim.diagnostic.config({
	float = {
		source = true,
		border = "rounded",
	},
	virtual_text = {
		enabled = true,
		source = true,
		spacing = 2,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

vim.lsp.config("codebook", {
	filetypes = vim.tbl_filter(function(ft)
		return not string.match(ft, "markdown")
	end, tsFiletypes),
	init_options = {
		logLevel = "warn",
		diagnosticSeverity = "hint",
	},
})
vim.lsp.config("lua_ls", {
	on_init = function(client)
		local path = ""

		if client.workspace_folders and #client.workspace_folders > 0 then
			path = client.workspace_folders[1].name
		elseif client.root_dir or client.settings.root_dir then
			path = client.root_dir or client.settings.root_dir
		else
			path = vim.fn.getcwd()
		end

		if vim.fs.normalize(path) == vim.fs.normalize(vim.fn.stdpath("config")) then
			client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
				runtime = {
					version = "LuaJIT",
					path = {
						"lua/?.lua",
						"lua/?/init.lua",
					},
				},
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
						vim.fn.stdpath("data") .. "/site/pack/core/opt",
					},
				},
			})
		end
	end,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = { checkThirdParty = false },
			diagnostics = { enable = true },
			hint = { enable = true },
			format = { enable = false }, -- stylua will be used for formatting
		},
	},
})
vim.lsp.config("ty", {
	settings = {
		ty = { diagnosticMode = "workspace" },
	},
})

vim.lsp.enable({
	"codebook",
	"lua_ls",
	"ty",
	"ruff",
	"tsgo",
	"oxlint",
	"jsonls",
})

local lsp_document_highlight_group = vim.api.nvim_create_augroup("lsp-document-highlight", { clear = false })
local lsp_document_highlight_method = vim.lsp.protocol.Methods.textDocument_documentHighlight

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Some shit I need to done when LSP attaches to a buffer",
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)

		if not client then
			return
		end

		if #vim.lsp.get_clients({ bufnr = event.buf, method = lsp_document_highlight_method }) > 0 then
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				desc = "LSP: Highlight references under cursor",
				group = lsp_document_highlight_group,
				buffer = event.buf,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
				desc = "LSP: Clear highlighted references",
				group = lsp_document_highlight_group,
				buffer = event.buf,
				callback = vim.lsp.buf.clear_references,
			})
		end

		local m = vim.lsp.protocol.Methods
		local lsp_keymaps = vim.b[event.buf].lsp_keymaps or {}
		vim.b[event.buf].lsp_keymaps = lsp_keymaps

		local map = function(keys, func, desc, method)
			if lsp_keymaps[keys] or (method and not client:supports_method(method)) then
				return
			end
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
			lsp_keymaps[keys] = true
		end

		local tb = require("telescope.builtin")

		map("gR", tb.lsp_references, "Go to references", m.textDocument_references)
		map("gI", tb.lsp_implementations, "Go to implementation", m.textDocument_implementation)
		map("gD", tb.lsp_definitions, "Go to definition", m.textDocument_definition)
		map("gT", tb.lsp_type_definitions, "Go to type definition", m.textDocument_typeDefinition)
		map("<leader>ds", tb.lsp_document_symbols, "Document symbols", m.textDocument_documentSymbol)
		map("<leader>ws", tb.lsp_dynamic_workspace_symbols, "Workspace symbols", m.workspace_symbol)
		map("<leader>rn", vim.lsp.buf.rename, "Rename symbol", m.textDocument_rename)
		map("<leader>ca", vim.lsp.buf.code_action, "Code actions", m.textDocument_codeAction)
		map("<leader>q", function()
			vim.diagnostic.setloclist({ severity = { min = vim.diagnostic.severity.INFO } })
		end, "Open diagnostic quickfix list")
		map("K", function()
			vim.lsp.buf.hover({ border = "rounded" })
		end, "Hover documentation", m.textDocument_hover)
		map("]w", function()
			vim.diagnostic.jump({ severity = { min = vim.diagnostic.severity.INFO }, count = 1 })
		end, "Go to next warning", m.textDocument_formatting)
		map("[w", function()
			vim.diagnostic.jump({ severity = { min = vim.diagnostic.severity.INFO }, count = -1 })
		end, "Go to previous warning", m.textDocument_formatting)
	end,
})
vim.api.nvim_create_autocmd("LspDetach", {
	desc = "LSP: Clean up document highlights",
	group = lsp_document_highlight_group,
	callback = function(event)
		if not vim.api.nvim_buf_is_valid(event.buf) then
			return
		end

		vim.api.nvim_buf_call(event.buf, vim.lsp.buf.clear_references)

		if #vim.lsp.get_clients({ bufnr = event.buf, method = lsp_document_highlight_method }) == 0 then
			vim.api.nvim_clear_autocmds({
				group = lsp_document_highlight_group,
				buffer = event.buf,
			})
		end
	end,
})

-- Vue LSP setup
vim.api.nvim_create_user_command("VueStart", function()
	local vue_language_server_path = vim.json.decode(
		vim.fn.system(
			[[pnpm ls -g --long --json @vue/language-server | jq '.[0].dependencies."@vue/language-server".path']]
		)
	)
	vim.lsp.config("vtsls", {
		settings = {
			vtsls = {
				tsserver = {
					globalPlugins = {
						{
							name = "@vue/typescript-plugin",
							location = vue_language_server_path,
							languages = { "vue" },
							configNamespace = "typescript",
						},
					},
				},
			},
		},
		filetypes = { "vue" },
	})

	vim.lsp.enable({ "vtsls", "vue" })
end, { desc = "Configure and start Vue LSP support" })

require("fidget").setup({
	notification = {
		override_vim_notify = false,
		window = { normal_hl = "Normal" },
	},
})

-- Git
require("neogit").setup({})
vim.keymap.set("n", "<leader>gg", require("neogit").open, { desc = "Show Neogit UI" })

-- AI
local copilot_filetypes = { ["*"] = false }
for _, ft in ipairs(tsFiletypes) do
	copilot_filetypes[ft] = true
end
require("copilot").setup({
	suggestion = { enabled = true, auto_trigger = true },
	panel = { enabled = false },
	filetypes = copilot_filetypes,
})
require("sidekick").setup({
	nes = { enabled = true },
	cli = {
		win = {
			layout = "float",
			float = { border = "rounded" },
		},
		mux = {
			backend = "tmux",
			enabled = false,
		},
		tools = {
			pi = {
				cmd = { "pi", "--no-session" },
			},
		},
	},
})
vim.keymap.set({ "i", "n" }, "<tab>", function()
	if require("sidekick").nes_jump_or_apply() then
		return
	end
	if require("copilot.suggestion").is_visible() then
		require("copilot.suggestion").accept_word()
		return
	end
	return "<tab>"
end, { expr = true, desc = "Go-to/Apply Copilot suggestion" })
vim.keymap.set({ "i", "n" }, "<s-tab>", function()
	if require("sidekick.nes").apply() then
		return
	end
	if require("copilot.suggestion").is_visible() then
		require("copilot.suggestion").accept()
		return
	end
	return "<tab>"
end, { expr = true, desc = "Apply Copilot suggestion" })
vim.keymap.set({ "n", "t", "i", "x" }, "<c-.>", function()
	require("sidekick.cli").focus({ name = "pi" })
end, { desc = "Sidekick Focus" })
vim.keymap.set("x", "<leader>av", function()
	require("sidekick.cli").send({ msg = "{selection}" })
end, { desc = "Send {selection}" })
vim.keymap.set({ "x", "n" }, "<leader>ap", function()
	require("sidekick.cli").send({ msg = "{position}" })
end, { desc = "Send {position}" })

-- Telescope
local telescope = require("telescope")
local telescopeConfig = require("telescope.config")

local file_ignore_patterns = {
	".codebook.toml",
	".venv/**",
	"codebook.toml",
	"lazy-lock.json",
	"node_modules/**",
	"package-lock.json",
	"pnpm-lock.yaml",
	"yarn.lock",
}

local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
for _, v in ipairs(file_ignore_patterns) do
	table.insert(vimgrep_arguments, "--glob")
	table.insert(vimgrep_arguments, "!" .. v)
end

local find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
for _, v in ipairs(file_ignore_patterns) do
	table.insert(find_command, "--exclude")
	table.insert(find_command, v)
end

telescope.setup({
	defaults = {
		layout_config = {
			horizontal = {
				width = 0.9,
				height = 0.9,
				preview_width = 0.6,
			},
		},
		file_ignore_patterns = file_ignore_patterns,
		vimgrep_arguments = vimgrep_arguments,
	},
	pickers = {
		find_files = { find_command = find_command },
		lsp_references = { jump_type = "never" },
		lsp_implementations = { jump_type = "never" },
		lsp_definitions = { jump_type = "never" },
	},
	extensions = {
		["ui-select"] = { require("telescope.themes").get_dropdown({}) },
	},
})

telescope.load_extension("fzf")
telescope.load_extension("ui-select")

local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fz", tb.current_buffer_fuzzy_find, { desc = "Find in buffer" })
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Grep in project" })
vim.keymap.set("n", "<leader>fh", tb.help_tags, { desc = "Search help tags" })
vim.keymap.set("n", "<leader>fr", tb.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fc", tb.commands, { desc = "Find commands" })

-- Navigation / Formatting / Mini
-- Navigation
require("nvim-tree").setup({
	update_focused_file = {
		enable = true,
		update_root = nil,
	},
	view = {
		float = {
			enable = true,
			open_win_config = function()
				local screen_w = vim.opt.columns:get()
				local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
				local window_w = math.floor(screen_w * 0.5)
				local window_h = math.floor(screen_h * 0.5)
				local center_x = math.floor((screen_w - window_w) / 2)
				local center_y = math.floor((screen_h - window_h) / 2)
				return {
					relative = "editor",
					border = "rounded",
					row = center_y,
					col = center_x,
					width = window_w,
					height = window_h,
				}
			end,
		},
	},
})
vim.keymap.set("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle({ focus = true })
end, { desc = "Toggle file explorer" })

-- Formatting
require("conform").setup({
	notify_on_error = true,
	format_after_save = { timeout_ms = 256, lsp_format = "fallback" },
	formatters = {
		oxfmt = {
			args = function()
				local root_markers = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }
				local has_root_marker = #vim.fs.find(root_markers, { path = vim.fn.getcwd(), upward = false }) > 0
				local args = { "--stdin-filepath", "$FILENAME" }

				if not has_root_marker then
					vim.list_extend(args, { "--config", vim.fn.expand("~/code/typescript/config/oxfmt.config.ts") })
				end

				return args
			end,
		},
	},
	formatters_by_ft = {
		javascript = { "oxfmt" },
		javascriptreact = { "oxfmt" },
		json = { "oxfmt" },
		jsonc = { "oxfmt" },
		lua = { "stylua" },
		python = { "ruff_format", "ruff_organize_imports" },
		toml = { "taplo" },
		typescript = { "oxfmt" },
		typescriptreact = { "oxfmt" },
		vue = { "oxfmt" },
		yaml = { "oxfmt" },
	},
})
vim.o.formatexpr = "v:lua.require('conform').formatexpr()"

-- Flash jumps
require("flash").setup()
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", function()
	require("flash").remote()
end, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Treesitter Search" })
vim.keymap.set("c", "<c-s>", function()
	require("flash").toggle()
end, { desc = "Toggle Flash Search" })

-- Mini
require("mini.animate").setup({
	scroll = { enable = false },
})

local gen_spec = require("mini.ai").gen_spec
require("mini.ai").setup({
	mappings = {
		around_next = "aN",
		inside_next = "iN",
		around_last = "aL",
		inside_last = "iL",
	},
	custom_textobjects = {
		P = gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
		F = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
	},
})
require("mini.basics").setup({
	options = {
		basic = true,
		extra_ui = false,
		win_borders = "rounded",
	},
	mappings = {
		option_toggle_prefix = "",
	},
})
require("mini.bufremove").setup()
require("mini.bracketed").setup()
require("mini.completion").setup({
	window = {
		info = { border = "rounded" },
		signature = { border = "rounded" },
	},
})

-- vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", {})
-- vim.api.nvim_set_hl(0, "MiniCursorword", {
-- 	fg = "#ffffff",
-- 	bg = "#444444",
-- 	underline = true,
-- })
require("mini.cursorword").setup()

require("mini.icons").setup()

local indent_forbidden_ft = {
	sidekick_terminal = true,
	NvimTree = true,
}
require("mini.indentscope").setup({
	draw = {
		predicate = function(scope)
			return not indent_forbidden_ft[vim.bo[scope.buf_id].filetype] and not scope.body.is_incomplete
		end,
	},
})
require("mini.notify").setup({
	lsp_progress = { enable = false },
})
require("mini.pairs").setup()
require("mini.statusline").setup()
require("mini.surround").setup({
	mappings = {
		add = "<leader>sa",
		delete = "<leader>sd",
		find = "<leader>sf",
		find_left = "<leader>sF",
		highlight = "<leader>sh",
		replace = "<leader>sc",
	},
})
require("mini.tabline").setup()

vim.keymap.set("n", "<leader>bd", function()
	require("mini.bufremove").delete()
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bD", function()
	require("mini.bufremove").wipe()
end, { desc = "Wipe buffer" })

-- Which-key for key mappings
require("which-key").setup({ preset = "modern" })
vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer keymaps" })

-- Debugging
require("dap-python").setup("uv")
require("nvim-dap-virtual-text").setup({})
require("dap-view").setup()
vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DiagnosticSignError", linehl = "", numhl = "" })

-- Session and Shada
local function get_wip_dir()
	local state_dir = vim.fn.stdpath("state")
	local cwd = vim.fn.getcwd():gsub("/", "-")
	local work_dir = state_dir .. "/wip" .. "/-" .. cwd

	if vim.fn.isdirectory(work_dir) == 0 then
		vim.fn.mkdir(work_dir, "p")
	end

	return work_dir
end

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("session-load", { clear = true }),
	desc = "Load last session if it exists",
	callback = function()
		if vim.fn.argc() > 0 then
			return
		end

		local work_dir = get_wip_dir()

		local session_file = work_dir .. "/session.vim"
		vim.opt.shadafile = work_dir .. "/session.shada"

		if vim.fn.filereadable(session_file) == 1 then
			vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
		end
	end,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
	desc = "Save session on exit",
	callback = function()
		if vim.fn.argc() > 0 then
			return
		end

		local work_dir = get_wip_dir()
		local session_file = work_dir .. "/session.vim"

		vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
	end,
})
