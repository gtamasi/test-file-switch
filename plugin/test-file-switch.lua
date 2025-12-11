-- test-file-switch.nvim
-- A Neovim plugin to quickly switch between source and test files

-- Prevent loading the plugin multiple times
if vim.g.loaded_test_file_switch then
  return
end
vim.g.loaded_test_file_switch = true

-- The plugin requires explicit setup via require("test-file-switch").setup()
-- This file only marks the plugin as loaded

