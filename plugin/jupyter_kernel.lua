require("cmp").register_source("jupyter", require("jupyter_kernel.cmp").new())

vim.api.nvim_create_user_command(
	"JupyterAttach",
	require("jupyter_kernel").attach,
	{ nargs = "?", desc = "Attach to a running jupyter kernel" }
)

vim.api.nvim_create_user_command("JupyterDetach", "call JupyterDetach()", { desc = "Detach jupyter kernel" })

vim.api.nvim_create_user_command(
	"JupyterInspect",
	require("jupyter_kernel").inspect,
	{ desc = "Inpsect object in the kernel" }
)

vim.api.nvim_create_user_command(
	"JupyterExecute",
	require("jupyter_kernel").execute,
	{
		desc = "Send code to execute with kernel",
		nargs = "?", -- Accept 0 or 1 argument
		range = 2,  -- or a visual selection
	}
)
