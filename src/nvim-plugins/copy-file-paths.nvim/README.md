# copy-file-paths.nvim

Select and copy the absolute or relative directory, absolute or relative file
path, working directory, or GitHub URL. File-specific entries include line
numbers when invoked from a visual selection.

The URL is pinned to the current commit, so it continues to point at the same
version of the file even after the branch moves.

## Requirements

- Neovim 0.10 or newer
- Git
- A repository whose `origin` remote points to GitHub

## Usage

```lua
require("copy-file-paths").select_paths()
```

For example, copy the URL to the system clipboard:

```lua
vim.keymap.set({ "n", "x" }, "<leader>p", function()
  require("copy-file-paths").select_paths()
end, { desc = "Copy file path" })
```

The GitHub URL can also be retrieved without opening the picker. It has no line
fragment in normal mode and includes the selection when called in visual mode:

```lua
local url = require("copy-file-paths").get_url()
```

Individual picker values are available through `get_relative_path()`,
`get_url()`, `get_absolute_path()`, `get_absolute_dirname()`,
`get_relative_dirname()`, and `get_cwd()`.

Only GitHub SSH and HTTP(S) origin URLs are supported currently.
