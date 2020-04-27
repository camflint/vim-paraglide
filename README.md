# vim-paraglide 🪂

vim-paraglide is a simple plugin to make navigating around paragraphs easier. Think of it as a better `}` and `{`.


## Features

* jumps to the last *non-blank* line, instead of the line after the paragraph
* jumps to the beginnng or end of the paragraph
* works with motions (operator-pending mode) and visual mode


## Default mappings

| Key        | Mapping                                         |
|------------|-------------------------------------------------|
| `<down>`   | Start of next paragraph                         |
| `<up>`     | Start of previous paragraph                     |
| `g-<down>` | Start or end of next paragraph                  |
| `g-<up>`   | Start of end of previous paragraph              |
| `}`        | End (last non-blank line) of next paragraph     |
| `{`        | End (last non-blank line) of previous paragraph |


## Customization

To set up a custom mapping, add the following to your .vimrc:

```vim
" Use 'gj' and 'gk' to navigate up and down paragraph markers.
noremap <silent> gj <Plug>ParaglideDownAny
noremap <silent> gk <Plug>ParaglideUpAny
```
