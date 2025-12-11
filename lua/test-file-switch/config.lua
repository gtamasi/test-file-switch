local M = {}

-- Default configuration
M.defaults = {
  -- File switching options
  test_dir = "tests",
  test_suffix = ".spec",

  -- Test file creation
  prompt_create = true,
  auto_create = false,

  -- Keymap options
  keymap = "<leader>tt",
  keymap_mode = "n",
  keymap_enabled = true,
}

-- Current configuration (populated by setup)
M.options = {}

--- Merge user options with defaults
---@param opts table|nil User configuration options
---@return table Merged configuration
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
  return M.options
end

--- Get current configuration
---@return table Current configuration
function M.get()
  return M.options
end

return M

