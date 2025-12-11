local config = require("test-file-switch.config")

local M = {}

-- Supported file extensions
local supported_extensions = { ".js", ".ts", ".jsx", ".tsx" }

--- Check if a file extension is supported
---@param ext string File extension (e.g., ".js")
---@return boolean
local function is_supported_extension(ext)
  for _, supported in ipairs(supported_extensions) do
    if ext == supported then
      return true
    end
  end
  return false
end

--- Get the file extension from a path
---@param path string File path
---@return string Extension including the dot (e.g., ".js")
local function get_extension(path)
  return path:match("^.+(%.[^.]+)$") or ""
end

--- Get the base name without extension
---@param path string File path
---@return string Base name without extension
local function get_basename_without_ext(path)
  local basename = vim.fn.fnamemodify(path, ":t")
  return basename:match("^(.+)%.[^.]+$") or basename
end

--- Check if the current file is a test file
---@param path string Relative file path
---@return boolean
function M.is_test_file(path)
  local opts = config.get()
  local test_dir = opts.test_dir .. "/"

  -- Check if path starts with test directory
  if not vim.startswith(path, test_dir) then
    return false
  end

  -- Check if filename contains the test suffix
  local filename = vim.fn.fnamemodify(path, ":t")
  return filename:match(vim.pesc(opts.test_suffix) .. "%.[jt]sx?$") ~= nil
end

--- Get the test file path for a source file
---@param source_path string Relative path to source file
---@return string|nil Test file path, or nil if unsupported
function M.get_test_path(source_path)
  local opts = config.get()
  local ext = get_extension(source_path)

  if not is_supported_extension(ext) then
    return nil
  end

  -- Determine test extension (preserve js vs ts)
  local test_ext
  if ext == ".js" or ext == ".jsx" then
    test_ext = opts.test_suffix .. ".js"
  else
    test_ext = opts.test_suffix .. ".ts"
  end

  -- Get directory and basename
  local dir = vim.fn.fnamemodify(source_path, ":h")
  local basename = get_basename_without_ext(source_path)

  -- Construct test path
  local test_path
  if dir == "." then
    test_path = opts.test_dir .. "/" .. basename .. test_ext
  else
    test_path = opts.test_dir .. "/" .. dir .. "/" .. basename .. test_ext
  end

  return test_path
end

--- Get the source file path for a test file
---@param test_path string Relative path to test file
---@return string|nil Source file path, or nil if not found
function M.get_source_path(test_path)
  local opts = config.get()
  local test_dir = opts.test_dir .. "/"

  -- Remove test directory prefix
  if not vim.startswith(test_path, test_dir) then
    return nil
  end

  local relative_path = test_path:sub(#test_dir + 1)

  -- Get directory and filename
  local dir = vim.fn.fnamemodify(relative_path, ":h")
  local filename = vim.fn.fnamemodify(relative_path, ":t")

  -- Remove test suffix and get base name
  -- Pattern: name.spec.js or name.spec.ts
  local basename = filename:match("^(.+)" .. vim.pesc(opts.test_suffix) .. "%.[jt]s$")
  if not basename then
    return nil
  end

  -- Determine if it was js or ts test
  local was_ts = filename:match(vim.pesc(opts.test_suffix) .. "%.ts$") ~= nil

  -- Try to find the source file with different extensions
  local extensions_to_try
  if was_ts then
    extensions_to_try = { ".ts", ".tsx" }
  else
    extensions_to_try = { ".js", ".jsx" }
  end

  local cwd = vim.fn.getcwd()

  for _, ext in ipairs(extensions_to_try) do
    local source_path
    if dir == "." then
      source_path = basename .. ext
    else
      source_path = dir .. "/" .. basename .. ext
    end

    local full_path = cwd .. "/" .. source_path
    if vim.fn.filereadable(full_path) == 1 then
      return source_path
    end
  end

  -- If no file found, return the first option (for error messaging)
  local default_ext = was_ts and ".ts" or ".js"
  if dir == "." then
    return basename .. default_ext
  else
    return dir .. "/" .. basename .. default_ext
  end
end

--- Create a test file (and parent directories if needed)
---@param path string Relative path to the test file
---@return boolean Success
function M.create_test_file(path)
  local cwd = vim.fn.getcwd()
  local full_path = cwd .. "/" .. path

  -- Create parent directories
  local dir = vim.fn.fnamemodify(full_path, ":h")
  vim.fn.mkdir(dir, "p")

  -- Create empty file
  local file = io.open(full_path, "w")
  if file then
    file:close()
    return true
  end

  return false
end

--- Prompt user to create a test file
---@param path string Relative path to the test file
---@return boolean User confirmed creation
function M.prompt_create_test(path)
  local choice = vim.fn.confirm(
    "Test file does not exist: " .. path .. "\nCreate it?",
    "&Yes\n&No",
    2
  )
  return choice == 1
end

--- Open a file in the current buffer
---@param path string Relative path to open
local function open_file(path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

--- Main switch function - toggles between source and test file
function M.switch()
  local opts = config.get()
  local cwd = vim.fn.getcwd()
  local current_file = vim.fn.expand("%:p")

  -- Get relative path from cwd
  local relative_path
  if vim.startswith(current_file, cwd .. "/") then
    relative_path = current_file:sub(#cwd + 2)
  else
    vim.notify("File is not in the current working directory", vim.log.levels.ERROR)
    return
  end

  -- Check if current file is a test file or source file
  if M.is_test_file(relative_path) then
    -- Switch to source file
    local source_path = M.get_source_path(relative_path)
    if not source_path then
      vim.notify("Could not determine source file path", vim.log.levels.ERROR)
      return
    end

    local full_source_path = cwd .. "/" .. source_path
    if vim.fn.filereadable(full_source_path) == 1 then
      open_file(source_path)
    else
      vim.notify("Source file does not exist: " .. source_path, vim.log.levels.ERROR)
    end
  else
    -- Switch to test file
    local test_path = M.get_test_path(relative_path)
    if not test_path then
      vim.notify("Unsupported file type. Only .js, .ts, .jsx, .tsx files are supported.", vim.log.levels.WARN)
      return
    end

    local full_test_path = cwd .. "/" .. test_path
    if vim.fn.filereadable(full_test_path) == 1 then
      open_file(test_path)
    else
      -- Test file doesn't exist - handle based on config
      if opts.auto_create then
        if M.create_test_file(test_path) then
          open_file(test_path)
          vim.notify("Created test file: " .. test_path, vim.log.levels.INFO)
        else
          vim.notify("Failed to create test file: " .. test_path, vim.log.levels.ERROR)
        end
      elseif opts.prompt_create then
        if M.prompt_create_test(test_path) then
          if M.create_test_file(test_path) then
            open_file(test_path)
            vim.notify("Created test file: " .. test_path, vim.log.levels.INFO)
          else
            vim.notify("Failed to create test file: " .. test_path, vim.log.levels.ERROR)
          end
        end
      else
        vim.notify("Test file does not exist: " .. test_path, vim.log.levels.WARN)
      end
    end
  end
end

return M

