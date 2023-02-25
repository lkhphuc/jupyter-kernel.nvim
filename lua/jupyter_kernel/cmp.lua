local source = {}

source.new = function()
	local self = setmetatable({}, { __index = source })
	return self
end

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
	return vim.b.jupyter_attached
end

function source:get_debug_name()
	return "jupyter"
end

---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
	local items = vim.fn.JupyterComplete(vim.g.__jupyter_timeout)
	callback(items)
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
	callback(completion_item)
end

---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
	callback(completion_item)
end

return source
