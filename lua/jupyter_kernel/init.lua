local M = {}

function M.attach()
	local _ = vim.fn.JupyterKernels() -- not sure why but 1st called always return nil
	local kernels = vim.fn.JupyterKernels()
	vim.ui.select(kernels, { prompt = "Select a kernel" }, function(kernel)
		if kernel == nil then
			return
		end
		vim.fn.JupyterAttach(kernel)
		vim.b.jupyter_attached = true
		vim.notify("Jupyter kernel attached")
	end)
end

function M.inspect()
	if vim.b.jupyter_attached ~= true then
		vim.notify("No jupyter kernel attached")
		return
	end
	local inspect = vim.fn.JupyterInspect(M.opts.timeout)
	local out = ""

	if inspect.status ~= "ok" then
		out = inspect.status
	elseif inspect.found == false then
		out = "No information from kernel"
	elseif inspect.found == true then
		-- Strip ANSI Escape code: https://stackoverflow.com/a/55324681
		-- The above regexes do the following:
		-- 1. \x1b is the escape character
		-- 2. %[%d+; is the ANSI escape code for a digit color
		-- and so on
		out = inspect.data["text/plain"]
			:gsub("\x1b%[%d+;%d+;%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+m", "")
			:gsub("\x1b%[%d+m", "")
		-- The following regex convert ansi code for tab
		-- out = out:gsub("\x1b%[H", "\t")
	end

	local lines = {}
	for line in vim.gsplit(out, "\n") do
		table.insert(lines, line)
	end

	vim.lsp.util.open_floating_preview(lines, "markdown", M.opts.inspect.window)
end

local default_config = {
	inspect = {
		-- opts for vim.lsp.util.open_floating_preview
		window = {
			max_width = 84,
		},
	},
	-- time to wait for kernel's response in seconds
	timeout = 0.5,
}

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", default_config, opts or {})
	vim.g.__jupyter_timeout = M.opts.timeout
end

return M
