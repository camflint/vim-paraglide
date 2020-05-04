# vim-paraglide 🪂

vim-paraglide is a simple plugin to make navigating paragraphs easier.

<!-- vim-markdown-toc GFM -->

* [Motivation](#motivation)
* [Features](#features)
  * [Jump to edges](#jump-to-edges)
  * [Jump to only top or bottom edges](#jump-to-only-top-or-bottom-edges)
  * [Block, or column-aware jumps](#block-or-column-aware-jumps)
  * [Support for visual mode](#support-for-visual-mode)
  * [Support for motions](#support-for-motions)
* [Mappings](#mappings)
  * [Default mappings](#default-mappings)
  * [Custom mappings](#custom-mappings)
* [Settings](#settings)
* [Related plugins](#related-plugins)

<!-- vim-markdown-toc -->


## Motivation

The standard `}` and `{` paragraph motions jump to the blank lines before and after a paragraph, respectively, rather than to the start and end of the paragraph. If you want to change this behavior, you have to edit the somewhat-arcane _nroff_ macros of the`'paragraphs'` options.

The standard paragraph motions also don't work very well with blocks, such as when you want to select a vertical column in a markdown table. vim-paraglide provides flexible mappings for most use cases around paragraph navigation.


## Features

### Jump to edges

![Demo: jumping to all edges](media/demo1.gif)

Default keybinding: `<down>`/`<up>`.

### Jump to only top or bottom edges

![Demo: jumping to only top or bottom edges](media/demo2.gif)

Default keybindings:

+ `<s-down>`/`<s-up>` for top edges
+ `}`/`{` for bottom edges (similar to default paragraph motions)

Tip: hold down `shift` and use the arrow keys to move across paragraphs quickly, if you're just navigating through the file.

### Block, or column-aware jumps

![Demo: block, or column-aware jumps](media/demo3.gif)

Default keybinding: `g<down>`/`g<up>`.

This works by ignoring characters to the left of the cursor column when searching for a paragraph break.

### Support for visual mode

![Demo: visual mode](media/demo4.gif)

### Support for motions

![Demo: visual mode](media/demo5.gif)


## Mappings

### Default mappings

| Key                     | Mapping                             |
|-------------------------|-------------------------------------|
| `<down>`                | Jump to next edge                   |
| `<up>`                  | Jump to previous edge               |
| `<s-down>` (shift-down) | Jump to next edge (top only)        |
| `<s-up>`   (shift-up)   | Jump to previous edge (top only)    |
| `}`                     | Jump to next edge (bottom only)     |
| `{`                     | Jump to previous edge (bottom only) |
| `g<down>`               | Block-wise jump to next edge        |
| `g<up>`                 | Block-wise jump to previous edge    |


### Custom mappings

To set up a custom mapping, add the following to your .vimrc:

```vim
" Use 'gj' and 'gk' to navigate paragraphs instead of the arrow keys.
noremap <silent> gj <Plug>ParaglideDownAny
noremap <silent> gk <Plug>ParaglideUpAny
```

To see the full list of available keys, do:

```vim
:map <Plug>Paraglide <ENTER>
```

## Settings

| Setting                       | Purpose                                                    | Default |
|-------------------------------|------------------------------------------------------------|---------|
| `g:paraglide_default_maps`    | Whether to install the default mappings.                   | 1       |
| `g:paraglide_modify_jumplist` | Whether to add jumps to the window jumplist.               | 1       |
| `g:paraglide_wrap`            | Whether to wrap around to the top or bottom while jumping. | 0       |


## Related plugins

If you like the idea of this plugin, you may also be interested in:

* [targets.vim](https://github.com/wellle/targets.vim) - Vim plugin that provides additional text objects
* [vim-easymotion](https://github.com/easymotion/vim-easymotion) - Vim motions on speed!
