return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Function to get the Python path from virtual environment
		local get_python_path = function(workspace)
			-- Check for a .venv file
			local venv = workspace .. "/.venv"
			local venv_file = io.open(venv, "r")
			if venv_file then
				local venv_path = venv_file:read()
				venv_file:close()
				return venv_path .. "/bin/python"
			end
			-- Use activated virtualenv.
			if vim.env.VIRTUAL_ENV then
				return vim.env.VIRTUAL_ENV .. "/bin/python"
			end
			-- Find and use virtualenv in workspace directory.
			for _, pattern in ipairs({ "venv", ".venv" }) do
				local match = vim.fn.glob(vim.fn.getcwd() .. "/" .. pattern)
				if match ~= "" then
					return match .. "/bin/python"
				end
			end
			-- Fallback to system Python.
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end

		-- Get the current working directory
		local cwd = vim.fn.getcwd()

		-- Set up pylint with dynamic PYTHONPATH
		local python_path = get_python_path(cwd)
		local pylint_args = { "--init-hook", 'import sys; sys.path.insert(0, "' .. cwd .. '")' }

		if python_path then
			pylint_args = {
				"--init-hook",
				'import sys; sys.path.insert(0, "' .. cwd .. '"); sys.path.append("' .. python_path .. '")',
			}
		end

		lint.linters.pylint.args = pylint_args

		lint.linters_by_ft = {
			javascript = { "eslint" },
			typescript = { "eslint" },
			javascriptreact = { "eslint" },
			typescriptreact = { "eslint" },
			svelte = { "eslint" },
			python = { "pylint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
