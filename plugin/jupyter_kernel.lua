require("cmp").register_source("jupyter", require("jupyter_kernel.cmp").new())

vim.api.nvim_create_user_command(
	"JupyterAttach",
	require("jupyter_kernel").attach,
	{ desc = "Attach to a running jupyter kernel" }
)

vim.api.nvim_create_user_command("JupyterDetach", "call JupyterDetach()", { desc = "Detach jupyter kernel" })

vim.api.nvim_create_user_command(
	"JupyterInspect",
	require("jupyter_kernel").inspect,
	{ desc = "Inpsect object in the kernel" }
)

vim.keymap.set("n", "<leader>k", "<Cmd>JupyterInspect<CR>")
