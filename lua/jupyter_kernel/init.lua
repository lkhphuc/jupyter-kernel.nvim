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
