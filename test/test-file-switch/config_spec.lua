local config = require("test-file-switch.config")

describe("config", function()
  before_each(function()
    config.options = {}
  end)

  describe("defaults", function()
    it("has correct default test_dir", function()
      assert.equals("test", config.defaults.test_dir)
    end)

    it("has correct default test_suffix", function()
      assert.equals(".spec", config.defaults.test_suffix)
    end)

    it("has correct default prompt_create", function()
      assert.is_true(config.defaults.prompt_create)
    end)

    it("has correct default auto_create", function()
      assert.is_false(config.defaults.auto_create)
    end)

    it("has correct default keymap", function()
      assert.equals("<leader>fM", config.defaults.keymap)
    end)

    it("has correct default keymap_mode", function()
      assert.equals("n", config.defaults.keymap_mode)
    end)

    it("has correct default keymap_enabled", function()
      assert.is_true(config.defaults.keymap_enabled)
    end)
  end)

  describe("setup", function()
    it("uses defaults when no options provided", function()
      local opts = config.setup()
      assert.equals("test", opts.test_dir)
      assert.equals(".spec", opts.test_suffix)
      assert.equals("<leader>fM", opts.keymap)
    end)

    it("uses defaults when empty table provided", function()
      local opts = config.setup({})
      assert.equals("test", opts.test_dir)
      assert.equals(".spec", opts.test_suffix)
    end)

    it("overrides defaults with custom options", function()
      local opts = config.setup({
        test_dir = "__tests__",
        test_suffix = ".test",
      })
      assert.equals("__tests__", opts.test_dir)
      assert.equals(".test", opts.test_suffix)
    end)

    it("preserves defaults for non-specified options", function()
      local opts = config.setup({
        test_dir = "specs",
      })
      assert.equals("specs", opts.test_dir)
      assert.equals(".spec", opts.test_suffix)
      assert.equals("<leader>fM", opts.keymap)
    end)

    it("stores options for later retrieval", function()
      config.setup({ test_dir = "custom" })
      local opts = config.get()
      assert.equals("custom", opts.test_dir)
    end)
  end)

  describe("get", function()
    it("returns current options", function()
      config.setup({ keymap = "<leader>ts" })
      local opts = config.get()
      assert.equals("<leader>ts", opts.keymap)
    end)

    it("returns empty table before setup", function()
      local opts = config.get()
      assert.same({}, opts)
    end)
  end)
end)

