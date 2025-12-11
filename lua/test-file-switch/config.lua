local M = {}

M.defaults = {
  test_dir = "test",
  test_suffix = ".spec",
  prompt_create = true,
  auto_create = false,
  keymap = "<leader>fM",
  keymap_mode = "n",
  keymap_enabled = true,
}

M.options = {}

---@param opts table|nil
---@return table
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
  return M.options
end

---@return table
function M.get()
  return M.options
end

return M
