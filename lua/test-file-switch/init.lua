local config = require("test-file-switch.config")
local switcher = require("test-file-switch.switcher")

local M = {}

--- Setup the plugin with user options
---@param opts table|nil User configuration options
function M.setup(opts)
  -- Initialize configuration
  local options = config.setup(opts)

  -- Register keymap if enabled
  if options.keymap_enabled and options.keymap then
    vim.keymap.set(options.keymap_mode, options.keymap, function()
      switcher.switch()
    end, {
      desc = "Toggle between source and test file",
      silent = true,
    })
  end

  -- Register user command
  vim.api.nvim_create_user_command("TestFileSwitch", function()
    switcher.switch()
  end, {
    desc = "Toggle between source and test file",
  })
end

--- Switch between source and test file
--- Exposed for manual keymap setup
function M.switch()
  switcher.switch()
end

return M

