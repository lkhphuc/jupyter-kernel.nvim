from pathlib import Path

import pynvim
from jupyter_client import BlockingKernelClient
from jupyter_core.paths import jupyter_runtime_dir

timeout = 0.5

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
    "instance": 6,  # NOTE: not sure what this means
    "magic": 23,
    "path": 19,
    "statement": 13
}


@pynvim.plugin
class JupyterKernel(object):

    def __call__(self):
        return

    def __init__(self, nvim):
        self.nvim = nvim
        self.client = None
        self.kerneldir = Path(jupyter_runtime_dir())

    @pynvim.function('RunningKernels', sync=True)
    def running_kernels(self, args):
        kernels = self.kerneldir.glob('kernel-*.json')
        kernels = sorted(kernels,
                         reverse=True,
                         key=lambda f: f.stat().st_ctime)
        return [kern.name for kern in kernels]

    @pynvim.command('JupyterAttach',
                    complete='customlist,RunningKernels',
                    nargs='?')
    def attach(self, args):
        cfs = args or self.running_kernels(None)
        if not cfs:
            self.nvim.command('echo "No kernel found"')
            return

        if self.client is not None:
            self.client.stop_channels()

        cf = cfs[0]
        self.client = BlockingKernelClient()
        self.client.load_connection_file(self.kerneldir / cf)
        self.client.start_channels()
        self.nvim.command('echo "Attached to jupyter kernel {}"'.format(cf))

    @pynvim.command('JupyterDetach')
    def detach(self):
        if self.client is not None:
            self.client.stop_channels()
            self.nvim.command('echo "Jupyter kernel detached"')

    @pynvim.function('JupyterComplete', sync=True)
    def complete(self, args):
        if self.client is None:
            self.nvim.out_write("No kernel running\n")
            return {}

        try:
            line_content = self.nvim.current.line
            row, col = self.nvim.current.window.cursor
            reply = self.client.complete(line_content,
                                         col,
                                         reply=True,
                                         timeout=timeout)['content']
        except TimeoutError:
            self.nvim.out_write("Jupyter kernel completion timeout\n")
            return {}
        except Exception as e:
            self.nvim.out_write("Jupyter kernel's exception: {}\n".format(e))
            return {}
        if 'metadata' in reply.keys(
        ) and '_jupyter_types_experimental' in reply['metadata'].keys():
            # self.nvim.out_write(
            #     str(reply['metadata']['_jupyter_types_experimental']) + "\n")
            matches = []
            replies = reply['metadata']['_jupyter_types_experimental']
            self.nvim.out_write(str(replies) + "\n")
            for m in replies:
                matches.append({
                    'label':
                    m['text'],
                    'documentation':
                    dict(kind='markdown', value=m['signature']),
                    'kind':
                    CompletionItemKind[m['type']],
                })
            return matches
        else:
            return [{"label": m} for m in reply['matches']]
