# test-file-switch.nvim

A Neovim plugin to quickly switch between JavaScript/TypeScript source files and their corresponding test files.

## Features

- **Bidirectional toggle**: Use the same keybinding to switch from source → test and test → source
- **Automatic test file creation**: Prompts to create missing test files (with directory creation)
- **Configurable**: Customize keybindings, test directory, and file suffix
- **Zero dependencies**: Pure Lua, no external dependencies

## Installation

### lazy.nvim (recommended)

```lua
{
  "gtamasi/test-file-switch",
  config = function()
    require("test-file-switch").setup()
  end,
  ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
}
```

### packer.nvim

```lua
use {
  "gtamasi/test-file-switch",
  config = function()
    require("test-file-switch").setup()
  end,
}
```

### vim-plug

```vim
Plug 'username/test-file-switch'
```

Then in your config:

```lua
require("test-file-switch").setup()
```

### Manual Installation

```bash
git clone https://github.com/gtamasi/test-file-switch \
  ~/.local/share/nvim/site/pack/plugins/start/test-file-switch
```

## Usage

### Basic Setup

```lua
require("test-file-switch").setup()
```

This enables the default keybinding `<leader>tt` to toggle between source and test files.

### Command

The plugin also provides a command:

```vim
:TestFileSwitch
```

### Examples

#### Switching from source to test

When editing `src/utils/helper.js`, pressing `<leader>tt` opens `tests/src/utils/helper.spec.js`.

#### Switching from test to source

When editing `tests/src/utils/helper.spec.js`, pressing `<leader>tt` opens `src/utils/helper.js`.

#### Creating a new test file

If the test file doesn't exist, the plugin prompts:

```
Test file does not exist: tests/src/utils/helper.spec.js
Create it? [y/N]
```

Confirming creates the file (and any missing directories) and opens it.

## Configuration

### Default Options

```lua
require("test-file-switch").setup({
  -- File switching options
  test_dir = "tests",           -- Root test directory name
  test_suffix = ".spec",        -- Suffix before extension (.spec.js, .spec.ts)

  -- Test file creation
  prompt_create = true,         -- Prompt to create missing test files
  auto_create = false,          -- Auto-create without prompting (overrides prompt_create)

  -- Keymap options
  keymap = "<leader>tt",        -- Keybinding to toggle
  keymap_mode = "n",            -- Mode for keybinding (normal mode)
  keymap_enabled = true,        -- Whether to register the keymap
})
```

### Custom Keybinding

```lua
require("test-file-switch").setup({
  keymap = "<leader>ts",
})
```

### Disable Auto-Keymap (Manual Setup)

```lua
require("test-file-switch").setup({
  keymap_enabled = false,
})

-- Set up your own keymap
vim.keymap.set("n", "<C-t>", require("test-file-switch").switch, {
  desc = "Toggle between source and test file",
})
```

### Auto-Create Test Files

```lua
require("test-file-switch").setup({
  auto_create = true,  -- Always create missing test files without prompting
})
```

### Disable Test File Creation

```lua
require("test-file-switch").setup({
  prompt_create = false,  -- Never offer to create test files
})
```

## File Mapping

The plugin maps source files to test files as follows:

| Source File                 | Test File                             |
| --------------------------- | ------------------------------------- |
| `src/utils/helper.js`       | `tests/src/utils/helper.spec.js`      |
| `src/utils/helper.ts`       | `tests/src/utils/helper.spec.ts`      |
| `lib/components/Button.tsx` | `tests/lib/components/Button.spec.ts` |
| `index.js`                  | `tests/index.spec.js`                 |

## Limitations

- **Supported file types**: Only JavaScript and TypeScript files (`.js`, `.ts`, `.jsx`, `.tsx`)
- **Test directory location**: Test files must be in a `tests/` directory at the project root
- **Naming convention**: Test files must use the `.spec.js` or `.spec.ts` suffix (configurable via `test_suffix`)
- **No co-located tests**: Does not support test files next to source files (e.g., `Component.test.js` alongside `Component.js`)
- **Single test directory**: Does not support multiple test directories or custom glob patterns
- **Neovim only**: Requires Neovim with Lua support (not compatible with Vim)

## License

MIT
