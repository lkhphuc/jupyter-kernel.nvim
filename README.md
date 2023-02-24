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

## AutoCompletion with nvim-cmp
![Screenshot 2023-02-24 at 15 25 55](https://user-images.githubusercontent.com/12573521/221217793-c6f12569-6049-4427-855d-15e850d889f3.png)

## Non-features
This plugin will only implement features that receives information from Jupyter Kernel back to Neovim.
For controlling or sending code to kernel from Neovim, uses your favorite Neovim plugins or directly through Jupyter Console or Jupyter Notebook.

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
    timeout = 0.5, -- time to wait for response from kernel
  },
  cmd = "JupyterAttach",
  build = ":UpdateRemotePlugins",
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

# FAQ

#### I don't see any kernel for my IPython console
Ipython console runs a single process, without a server-client architecture. Use `jupyter console` as a replacement.

#### Complementary neovim plugins to run code with Jupyter kernel
- https://github.com/jpalardy/vim-slime
- https://github.com/hanschen/vim-ipython-cell
- https://github.com/dccsillag/magma-nvim
- https://github.com/smzm/hydrovim
- ... and many more repl and terminal plugin

#### Alternative
- https://github.com/bfredl/nvim-ipy : Two-way interactions, omnifunc and split pane. 
- https://github.com/mtikekar/nvim-send-to-term

Speical thanks to those plugins for inspiration and examples.

# Contributing
Issues and Pull Requests are welcome. See issue #1 for a TODO list and cast your votes.
