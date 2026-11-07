# Writing with novel.nvim

The `no-typterm` configuration loads [novel.nvim](https://github.com/dreaminsea/novel.nvim).
If `~/Code/novel.nvim/lua/novel` exists, Lazy uses that checkout; other machines install the GitHub plugin.
The existing Markdown renderer, preview, completion and language server continue to handle editing.

Restart Neovim after updating the config. On a new machine run `:Lazy sync`.
Export requires Pandoc 3.1+; PDF also requires XeLaTeX (TeX Live or MacTeX).
Run `:checkhealth novel` to inspect dependencies.

```vim
:Novel init ~/Writing/MyBook
:Novel open ~/Writing/MyBook
:Novel export html
:Novel export pdf
:Novel export rtf
:Novel export docx
:Novel export txt
```

`init` creates `novel.json` and imports existing Markdown under that directory.
In the sidebar, press `a` for a sheet, `g` for a group, `Enter` to edit,
`J`/`K` to reorder, `m` to move into a group, and `x` to include/exclude.
`d` removes an outline entry while keeping its Markdown files.
`r` changes the outline label; edit the Markdown heading separately.

| Key | Action |
| --- | --- |
| `<leader>Np` | Toggle the project sidebar |
| `<leader>Ni` | Create a writing project |
| `<leader>No` | Open a writing project |
| `<leader>Nn` | New sheet |
| `<leader>Ng` | New group |
| `<leader>Ne` | Choose an export format |
| `<leader>Ns` | Writing statistics |
| `<leader>Nm` | Edit title, author, language, outline and goal |

The capital `N` keeps LazyVim's existing `<leader>n` notification shortcut available.
New sheets/groups go inside the selected group, or beside the selected sheet;
when the sidebar is not focused they go at the project root.

Exports go to `exports/<project-title>.<format>`. For an existing output use
`:Novel! export html` (the bang is on `Novel`). A custom destination can follow
the format, including spaces, without quotes: `:Novel export pdf ~/Desktop/My Book.pdf`.
Unsaved Markdown buffers are included without writing them to disk. Failed
exports leave an existing output untouched.

The interface is English. Set `"language": "zh-CN"` in `novel.json` for Chinese
documents. PDF uses `Songti SC` on macOS and `Noto Serif CJK SC` elsewhere by
default. Change `export.cjk_font` in `lua/plugins/novel.lua` if needed.

See `:help novel.nvim` or the plugin README for the manifest format and all commands.
