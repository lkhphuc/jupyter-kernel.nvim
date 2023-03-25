local M = {}

local function _attach(kernel)
  vim.fn.JupyterAttach(kernel)
  vim.b.jupyter_attached = true
  vim.notify("Attach to " .. kernel)
end

function M.attach(opts)
  local kernel = opts.args -- User supplied full path
  if kernel ~= "" then -- User didn't supply full path
    _attach(kernel)
  else
    vim.fn.JupyterKernels() -- not sure why but 1st called always return nil
    local kernels = vim.fn.JupyterKernels(kernel)
    kernel = vim.ui.select(kernels, { prompt = "Select a kernel" }, function(kernel)
      if kernel ~= nil then
        _attach(kernel)
      end
    end)
  end
end

function M.inspect()
  if vim.b.jupyter_attached ~= true then
    vim.notify("No jupyter kernel attached. Select kernel:")
    M.attach({ args="" })
    return
  end

  local inspect = vim.fn.JupyterInspect(M.opts.timeout)
  local out = ""

  if inspect.status ~= "ok" then
    out = inspect.status
  elseif inspect.found ~= true then
    out = "_No information from kernel_"
  else
    local sections = vim.split(inspect.data["text/plain"], "\x1b%[0;31m")
    for _, section in ipairs(sections) do
      section = section
        -- Strip ANSI Escape code: https://stackoverflow.com/a/55324681
        -- \x1b is the escape character
        -- %[%d+; is the ANSI escape code for a digit color
        :gsub("\x1b%[%d+;%d+;%d+;%d+;%d+m", "")
        :gsub("\x1b%[%d+;%d+;%d+;%d+m", "")
        :gsub("\x1b%[%d+;%d+;%d+m", "")
        :gsub("\x1b%[%d+;%d+m", "")
        :gsub("\x1b%[%d+m", "")
        :gsub("\x1b%[H", "\t")
        -- Groups: name, 0 or more new line, content till end
        -- TODO: Fix for non-python kernel
        :gsub("^(Call signature):(%s*)(.-)\n$", "```python\n%3 # %1\n```")
        :gsub("^(Init signature):(%s*)(.-)\n$", "```python\n%3 # %1\n```")
        :gsub("^(Signature):(%s*)(.-)\n$",      "```python\n%3 # %1\n```")
        :gsub("^(String form):(%s*)(.-)\n$",    "```python\n%3 # %1\n```")
        :gsub("^(Docstring):(%s*)(.-)$",        "\n---\n```rst\n%3\n```")
        :gsub("^(Class docstring):(%s*)(.-)$",  "\n---\n```rst\n%3\n```")
        :gsub("^(File):(%s*)(.-)\n$",           "*%1*: `%3`\n")
        :gsub("^(Type):(%s*)(.-)\n$",           "*%1*: %3\n")
        :gsub("^(Length):(%s*)(.-)\n$",         "*%1*: %3\n")
        :gsub("^(Subclasses):(%s*)(.-)\n$",     "*%1*: %3\n")
      if section:match("%S") ~= nil and section:match("%S") ~= "" then
        -- Only add non-empty section
        out = out .. section
      end
    end
  end

  local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(out)
  markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
  vim.lsp.util.open_floating_preview(markdown_lines, "markdown", M.opts.inspect.window)
end

function M.execute(opts)
  if vim.b.jupyter_attached ~= true then
    vim.notify("No jupyter kernel attached. Select kernel:")
    M.attach({ args="" })
    return
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  local codes = vim.fn.getline(opts.line1) -- default to current line
  if opts.range == 2 then
    codes = vim.fn.getline(opts.line1, opts.line2)
    codes = table.concat(codes, "\n")
  elseif opts.args ~= "" then
    codes = opts.args
  end
  local status = vim.fn.JupyterExecute(codes)
  if status ~= "ok" then
    vim.notify(status)
  end
end


local default_config = {
  inspect = {
    -- opts for vim.lsp.util.open_floating_preview
    window = {
      max_width = 84,
      focus_id = "jupyter",
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
