local config = require("test-file-switch.config")
local switcher = require("test-file-switch.switcher")

local M = {}

---@param opts table|nil
function M.setup(opts)
  local options = config.setup(opts)

  if options.keymap_enabled and options.keymap then
    vim.keymap.set(options.keymap_mode, options.keymap, function()
      switcher.switch()
    end, {
      desc = "Toggle between source and test file",
      silent = true,
    })
  end

  vim.api.nvim_create_user_command("TestFileSwitch", function()
    switcher.switch()
  end, {
    desc = "Toggle between source and test file",
  })
end

function M.switch()
  switcher.switch()
end

return M
