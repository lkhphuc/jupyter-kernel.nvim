import unittest
from jupyter_kernel import JupyterKernel, CompletionItemKind

# Example reply for completing np.ar
REPLY = {
    'matches': [
        'arange',
        'arccos',
        'arccosh',
        'arcsin',
    ],
    'cursor_end': 5,
    'cursor_start': 3,
    'status': 'ok'
}

REPLY_EXPERIMENTAL = {**REPLY}  # Same as above but with metadata
REPLY_EXPERIMENTAL["metadata"] = {
    '_jupyter_types_experimental': [
        {
            'start':
            3,
            'end':
            5,
            'text':
            'arange',
            'type':
            'function',
            'signature':
            '(start=None, stop, step=None, , dtype=None, *, like=None, /)'
        },
        {
            'start': 3,
            'end': 5,
            'text': 'arccos',
            'type': 'instance',
            'signature': ''
        },
        {
            'start': 3,
            'end': 5,
            'text': 'arccosh',
            'type': 'instance',
            'signature': ''
        },
        {
            'start': 3,
            'end': 5,
            'text': 'arcsin',
            'type': 'instance',
            'signature': ''
        },
    ]
}


class TestCompletionReply(unittest.TestCase):

  def test_completion_reply(self):
    plugin = JupyterKernel(vim=None)
    expected_output = [
        {
            "label": "arange"
        },
        {
            "label": "arccos"
        },
        {
            "label": "arccosh"
        },
        {
            "label": "arcsin"
        },
    ]
    output = plugin._parse_completion_reply(REPLY)
    assert output == expected_output

  def test_completion_reply_experimental(self):
    plugin = JupyterKernel(vim=None)
    expected_output = [
        {
            "label": "arange",
            "documentation": {
                "kind":
                "markdown",
                "value":
                "```python\n(start=None, stop, step=None, , dtype=None, *, like=None, /)\n```"
            },
            "kind": CompletionItemKind["function"],
        },
        {
            "label": "arccos",
            "documentation": {
                "kind": "markdown",
                "value": "```python\n\n```"
            },
            "kind": CompletionItemKind["instance"],
        },
        {
            "label": "arccosh",
            "documentation": {
                "kind": "markdown",
                "value": "```python\n\n```"
            },
            "kind": CompletionItemKind["instance"],
        },
        {
            "label": "arcsin",
            "documentation": {
                "kind": "markdown",
                "value": "```python\n\n```"
            },
            "kind": CompletionItemKind["instance"],
        },
    ]
    output = plugin._parse_completion_reply(REPLY_EXPERIMENTAL)
    assert output == expected_output


if __name__ == '__main__':
  unittest.main()
