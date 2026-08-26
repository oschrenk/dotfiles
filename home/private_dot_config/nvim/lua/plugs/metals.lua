local metals_au_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })

-- https://github.com/scalameta/metals
return {
	"scalameta/nvim-metals",
	dependencies = {
		"saghen/blink.cmp",
	},
	ft = {
		"scala",
		"sbt",
	},
	config = function()
		local metals_config = require("metals").bare_config()

		metals_config.settings = {
			serverVersion = "latest.snapshot",
			-- prefer bsp over bloop
			-- see also https://github.com/scalameta/metals/discussions/4505
			defaultBspToBuildTool = true,
			-- renamed upstream; nvim-metals rejects the old name on load and lists
			-- the valid settings, so this had been ignored since the rename
			automaticImportBuild = "always",
			showInferredType = true,
			excludedPackages = {
				"akka.actor.typed.javadsl",
				"com.github.swagger.akka.javadsl",
				"akka.stream.javadsl",
				"akka.http.javadsl",
			},
		}

		metals_config.init_options = {
			statusBarProvider = "off",
		}
		metals_config.capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Start metals on certain filetypes
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"scala",
				"sbt",
				"java",
			},
			callback = function()
				require("metals").initialize_or_attach(metals_config)
			end,
			group = metals_au_group,
		})

		-- which-key v3 spec. The v2 `wk.register` nested-table form this replaced
		-- converted the `g` prefixed entries and silently dropped the four
		-- top-level single-key ones, so hover, format, rename and signature help
		-- were never mapped at all.
		--
		-- Those four now sit under <leader>l. As written they were bare `f`, `r`
		-- and `s`, which would have shadowed the find-character, replace-character
		-- and substitute motions in every buffer once metals loaded.
		local wk = require("which-key")
		wk.add({
			{ "<leader>l", icon = { icon = "" }, group = "LSP" },
			{
				"<leader>lf",
				"<cmd>lua vim.lsp.buf.format({ async = true })<CR>",
				desc = "Format buffer or selection",
				mode = { "n", "v" },
			},
			{ "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Rename symbol under cursor" },
			{ "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", desc = "Display signature" },

			-- K keeps its place: replacing keywordprg with LSP hover is the usual
			-- convention and shadows nothing that is used here.
			{ "K", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "Display hover information" },

			{ "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "Goto definition" },
			{ "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", desc = "Get implementations" },
			{ "gr", "<cmd>lua vim.lsp.buf.references()<CR>", desc = "Get references" },
			{ "gds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", desc = "Get document symbols" },
			{ "gws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", desc = "Get workspace symbols" },
		})
	end,
}
