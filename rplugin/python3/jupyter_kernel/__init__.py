from pathlib import Path

import pynvim
from jupyter_client import BlockingKernelClient
from jupyter_core.paths import jupyter_runtime_dir

CompletionItemKind = {
    "text": 1,
    "method": 2,
    "function": 3,
    "constructor": 4,
    "field": 5,
    "variable": 6,
    "class": 7,
    "interface": 8,
    "module": 9,
    "property": 10,
    "unit": 11,
    "value": 12,
    "enum": 13,
    "keyword": 14,
    "snippet": 15,
    "color": 16,
    "file": 17,
    "reference": 18,
    "folder": 19,
    "enumMember": 20,
    "constant": 21,
    "struct": 22,
    "event": 23,
    "operator": 24,
    "typeParameter": 25,
    # Jupyter specific
    "dict key": 14,
    "instance": 6,
    "magic": 23,
    "path": 19,
    "statement": 13
}


@pynvim.plugin
class JupyterKernel:

  def __init__(self, vim):
    self.vim: pynvim.Nvim = vim
    self.client: BlockingKernelClient | None = None
    self.kerneldir = Path(jupyter_runtime_dir())

  @pynvim.function("JupyterKernels", sync=True)
  def running_kernels(self, args):
    del args
    kernels = self.kerneldir.glob('kernel-*.json')
    kernels = sorted(kernels, reverse=True, key=lambda f: f.stat().st_ctime)
    return [kern.name for kern in kernels]

  # @pynvim.command('JupyterAttach',
  #                 complete='customlist,RunningKernels',
  #                 nargs='?')
  @pynvim.function("JupyterAttach")
  def attach(self, args):
    kernel = args[0]
    if self.client is not None:
      self.client.stop_channels()
    self.client = BlockingKernelClient()
    self.client.load_connection_file(self.kerneldir / kernel)
    self.client.start_channels()

  @pynvim.function('JupyterDetach')
  def detach(self, args):
    del args
    if self.client is not None:
      self.client.stop_channels()
      self.vim.command("let b:jupyter_attached = v:false")
      self.vim.command('echo "Jupyter kernel detached"')

  @pynvim.function('JupyterComplete', sync=True)
  def complete(self, args):
    timeout = args[0]
    assert self.client is not None, "No jupyter kernel attached"
    try:
      line_content = self.vim.current.line
      row, col = self.vim.current.window.cursor
      reply = self.client.complete(line_content,
                                   col,
                                   reply=True,
                                   timeout=timeout)['content']
      return self._parse_completion_reply(reply)
    except TimeoutError:
      self.vim.out_write("Jupyter kernel completion timeout\n")
      return {}
    except Exception as e:
      self.vim.out_write(f"Jupyter kernel's exception: {e}\n")
      return {}

  def _parse_completion_reply(self, reply):
    # self.vim.out_write("Jupyter kernel completion reply: {}\n".format(reply))
    has_experimental_types = "metadata" in reply and (
        '_jupyter_types_experimental' in reply['metadata'])
    if not has_experimental_types:
      return [{"label": m} for m in reply["matches"]]

    return [
        {
            "label": match.get("text", ""),
            "documentation": {
                "kind": "markdown",
                "value": f"```python\n{match.get('signature', '')}\n```"
            },
            # default kind: text = 1
            "kind": CompletionItemKind[match.get("type", "text")]
        } for match in reply['metadata']['_jupyter_types_experimental']
    ]

  @pynvim.function("JupyterInspect", sync=True)
  def inspect(self, args):
    assert self.client is not None, "No jupyter kernel attached"
    timeout = args[0]
    try:
      line_content = self.vim.current.line
      row, col = self.vim.current.window.cursor
      reply = self.client.inspect(line_content,
                                  col,
                                  detail_level=0,
                                  reply=True,
                                  timeout=timeout)
      return reply['content']
    except TimeoutError:
      return {'status': "_Kernel timeout_"}
    except Exception as exception:
      return {'status': f"_{str(exception)}_"}

  @pynvim.function("JupyterExecute", sync=True)
  def execute(self, args):
    assert self.client is not None, "No jupyter kernel attached"
    code = args[0]
    try:
      self.client.execute(code, silent=False)
      return "ok"
    except Exception as e:
      return f"Exception: {str(e)}"
