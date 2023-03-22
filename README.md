# jupyter-kernel.nvim
Get completion suggestion and inspect object from (IPython) Jupyter kernel inside neovim. 


# Motivation
There are a lots of plugins out there to help with sending Python code to a REPL, but not a lot of plugins helps extracting the benefit of interactive coding back into Neovim, where your cursor will reside most of the time. 
This is a simple plugin that wrap-around python package 'jupyter_client' to provide ergonomic workflow that enhance your coding experience with any Jupyter kernels.

# Features
## Object inspection
Open a floating window to inspect  object under the cursor 

- Command `:JupyterInspect`
![Screenshot 2023-02-24 at 15 23 38](https://user-images.githubusercontent.com/12573521/221217194-c18b98ec-0100-4865-a133-9a043a09bcaf.png)

- Result from LSP hover with same object:
![Screenshot 2023-02-24 at 15 24 01](https://user-images.githubusercontent.com/12573521/221217272-03676fd6-ed59-4dc3-8e03-4a8e66931fcb.png)

## Auto Completion with nvim-cmp
![Screenshot 2023-02-24 at 15 25 55](https://user-images.githubusercontent.com/12573521/221217793-c6f12569-6049-4427-855d-15e850d889f3.png)

## Send code to execute in kernel
Very basic functionality to send code to directly to kernel in normal and visual mode.

## Non-features
No fancy display of execution outputs, as it would complicate the plugin a lot by having async code check if execution is complete or not.
Use this alongside your terminal/qt console for basic text and image display, or notebook if you need fancy widgets or latex. 

# Setup

- Neovim must have `python3` provider to run remote plugins (`:checkhealth provider`)
- `python3 -m pip install -U pynvim jupyter_client` from your neovim's python provider.
- Add `jupyter` to nvim-cmp sources.
- Install plugin with your favorite package manager and call `require('jupyter-kernel.nvim').setup(opts)` to override default options.
- Run `UpdateRemotePlugins` after installed.

## lazy.nvim with default options
```
{ 
  "jupyter-kernel.nvim", 
  opts = {
    inspect = {
      -- opts for vim.lsp.util.open_floating_preview
      window = {
        max_width = 84,
      },
    },
    -- time to wait for kernel's response in seconds
    timeout = 0.5,
  }
  cmd = {"JupyterAttach", "JupyterInspect", "JupyterExecute"},
  build = ":UpdateRemotePlugins",
  keys = { { "<leader>k", "<Cmd>JupyterInspect<CR>", desc = "Inspect object in kernel" } },
}
```

## Add to nvim-cmp's sources
```lua
{ -- cmp configs ...
   sources = cmp.config.sources({
      { name = "jupyter" }, -- Add this
      -- existing sources
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "treesitter" }
      { name = "path" },
      { name = "copilot" },
    })
}
```

# Usage

### 1. start jupyter kernel
Start and run jupyter kernel using your favorite method (Notebook, `qtconsole`, `jupyter console` in tmux/neovim/window-manager/togglerterm/floaterm.

If you have multiple kernels running or the kernel you want to connect is not the most recently created, check the magic `%connect_info` and look for something like 
```
`... if you are local, you can connect with just:
    $> jupyter <app> --existing kernel-4301.json`
```

### 2. attach to jupyter kernel
Edit your code and send it to kernel however you like. Then attach the current buffer to the kernel using `:JupyterAttach` command.
A popup will appear and list all the available kernels to connect to, sorted by most recently created. 
![Screenshot 2023-02-24 at 16 00 23](https://user-images.githubusercontent.com/12573521/221226323-587c4823-7ab6-42dd-abf0-5bde499eca89.png)

### 3. Benefit from jupyter kernel
- Completions are provided automatically by `nvim-cmp`, given you have it setup.
- Call `JupyterInspect` to inspect word under cursor.


# References
Only the following commands are provided, without any default keymaps.
- `JupyterAttach`: 1st argument is path to kernel's json. If no path is provided, a popup will appear to select a running kernel to attach.
- `JupyterDetach`: detach buffer from kernel
- `JupyterInspect`: inspect object under cursor. This command send the current line and cursor location to `jupyter_client`, it is up to the kernel to decide which object to inspect.
- `JupyterExecute`: send code to execute in kernel. Support 3 options in order:
  - Visual mode: Send current selection, lines are properly joined with `\n`
  - Normal mode with argument: Send entire argument as one line
  - Normal mode without argument: Send current line

- Buffer variable `vim.b.jupyter_attached` to check if current buffer is attached to any kernel.

```lua
vim.keymap.set("n", "<leader>k", "<CMD>JupyterInspect<CR>", {desc = "Inspect object"})
```

# FAQ

#### I don't see any kernel for my IPython console
Ipython console runs a single process, without a server-client architecture. Use `jupyter console` as a replacement.

#### Complementary neovim plugins to run code with Jupyter kernel
- https://github.com/jpalardy/vim-slime
- https://github.com/hanschen/vim-ipython-cell
- https://github.com/dccsillag/magma-nvim (or maintained [fork](https://github.com/WhiteBlackGoose/magma-nvim-goose) by @WhiteBlackGoose)
- https://github.com/smzm/hydrovim
- ... and many more repl and terminal plugin

#### Alternative
- https://github.com/kiyoon/jupynium.nvim : Two-way interactions, nvim-cmp and notebooks in browser
- https://github.com/bfredl/nvim-ipy : Two-way interactions, omnifunc and split pane. 
- https://github.com/mtikekar/nvim-send-to-term

Speical thanks to those plugins for inspiration and examples.

# Contributing
Issues and Pull Requests are welcome. See issue #1 for a TODO list and cast your votes.
