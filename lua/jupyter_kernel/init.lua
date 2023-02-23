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
	local inspect = vim.fn.JupyterInspect()
	local out = ""

	if inspect.status ~= "ok" then
		out = inspect.status
	elseif inspect.found == false then
		out = "No information from kernel"
	elseif inspect.found == true then
		-- Strip ANSI Escape code: https://stackoverflow.com/a/55324681
		out = inspect.data["text/plain"]
			:gsub("\x1b%[%d+;%d+;%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+m", "")
			:gsub("\x1b%[%d+m", "")
		-- out = string.gsub(inspect.data["text/plain"], "[\\27\\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "")
	end

	local lines = {}
	for line in vim.gsplit(out, "\\n") do
		vim.pretty_print(line)
		table.insert(lines, line)
	end

	vim.lsp.util.open_floating_preview(lines, "markdown", { max_width = 80 })
end

return M
