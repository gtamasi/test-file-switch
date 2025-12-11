local config = require("test-file-switch.config")
local switcher = require("test-file-switch.switcher")

describe("switcher", function()
  before_each(function()
    config.setup()
  end)

  describe("is_test_file", function()
    it("returns true for test file in test directory", function()
      assert.is_true(switcher.is_test_file("test/helper.spec.js"))
    end)

    it("returns true for nested test file", function()
      assert.is_true(switcher.is_test_file("test/src/utils/helper.spec.js"))
    end)

    it("returns true for typescript test file", function()
      assert.is_true(switcher.is_test_file("test/src/helper.spec.ts"))
    end)

    it("returns false for source file", function()
      assert.is_false(switcher.is_test_file("src/helper.js"))
    end)

    it("returns false for file not in test directory", function()
      assert.is_false(switcher.is_test_file("other/helper.spec.js"))
    end)

    it("returns false for file without spec suffix", function()
      assert.is_false(switcher.is_test_file("test/helper.js"))
    end)

    it("respects custom test_dir", function()
      config.setup({ test_dir = "__tests__" })
      assert.is_true(switcher.is_test_file("__tests__/helper.spec.js"))
      assert.is_false(switcher.is_test_file("test/helper.spec.js"))
    end)

    it("respects custom test_suffix", function()
      config.setup({ test_suffix = ".test" })
      assert.is_true(switcher.is_test_file("test/helper.test.js"))
      assert.is_false(switcher.is_test_file("test/helper.spec.js"))
    end)
  end)

  describe("get_test_path", function()
    it("converts js file to spec.js", function()
      local result = switcher.get_test_path("src/helper.js")
      assert.equals("test/src/helper.spec.js", result)
    end)

    it("converts ts file to spec.ts", function()
      local result = switcher.get_test_path("src/helper.ts")
      assert.equals("test/src/helper.spec.ts", result)
    end)

    it("converts jsx file to spec.js", function()
      local result = switcher.get_test_path("components/Button.jsx")
      assert.equals("test/components/Button.spec.js", result)
    end)

    it("converts tsx file to spec.ts", function()
      local result = switcher.get_test_path("components/Button.tsx")
      assert.equals("test/components/Button.spec.ts", result)
    end)

    it("handles root level files", function()
      local result = switcher.get_test_path("index.js")
      assert.equals("test/index.spec.js", result)
    end)

    it("handles deeply nested paths", function()
      local result = switcher.get_test_path("src/lib/utils/helpers/string.ts")
      assert.equals("test/src/lib/utils/helpers/string.spec.ts", result)
    end)

    it("returns nil for unsupported extensions", function()
      assert.is_nil(switcher.get_test_path("styles.css"))
      assert.is_nil(switcher.get_test_path("config.json"))
      assert.is_nil(switcher.get_test_path("README.md"))
    end)

    it("respects custom test_dir", function()
      config.setup({ test_dir = "__tests__" })
      local result = switcher.get_test_path("src/helper.js")
      assert.equals("__tests__/src/helper.spec.js", result)
    end)

    it("respects custom test_suffix", function()
      config.setup({ test_suffix = ".test" })
      local result = switcher.get_test_path("src/helper.js")
      assert.equals("test/src/helper.test.js", result)
    end)
  end)

  describe("get_source_path", function()
    it("converts spec.js to js", function()
      local result = switcher.get_source_path("test/src/helper.spec.js")
      assert.equals("src/helper.js", result)
    end)

    it("converts spec.ts to ts", function()
      local result = switcher.get_source_path("test/src/helper.spec.ts")
      assert.equals("src/helper.ts", result)
    end)

    it("handles root level test files", function()
      local result = switcher.get_source_path("test/index.spec.js")
      assert.equals("index.js", result)
    end)

    it("handles deeply nested test paths", function()
      local result = switcher.get_source_path("test/src/lib/utils/string.spec.ts")
      assert.equals("src/lib/utils/string.ts", result)
    end)

    it("returns nil for non-test paths", function()
      assert.is_nil(switcher.get_source_path("src/helper.js"))
    end)

    it("returns nil for invalid test file format", function()
      assert.is_nil(switcher.get_source_path("test/helper.js"))
    end)

    it("respects custom test_dir", function()
      config.setup({ test_dir = "__tests__" })
      local result = switcher.get_source_path("__tests__/src/helper.spec.js")
      assert.equals("src/helper.js", result)
    end)

    it("respects custom test_suffix", function()
      config.setup({ test_suffix = ".test" })
      local result = switcher.get_source_path("test/src/helper.test.js")
      assert.equals("src/helper.js", result)
    end)
  end)

  describe("create_test_file", function()
    local test_dir

    before_each(function()
      test_dir = vim.fn.tempname()
      vim.fn.mkdir(test_dir, "p")
      vim.cmd("cd " .. test_dir)
    end)

    after_each(function()
      vim.fn.delete(test_dir, "rf")
    end)

    it("creates file in existing directory", function()
      vim.fn.mkdir(test_dir .. "/test", "p")
      local result = switcher.create_test_file("test/helper.spec.js")
      assert.is_true(result)
      assert.equals(1, vim.fn.filereadable(test_dir .. "/test/helper.spec.js"))
    end)

    it("creates parent directories if needed", function()
      local result = switcher.create_test_file("test/src/utils/helper.spec.js")
      assert.is_true(result)
      assert.equals(1, vim.fn.filereadable(test_dir .. "/test/src/utils/helper.spec.js"))
    end)

    it("creates empty file", function()
      vim.fn.mkdir(test_dir .. "/test", "p")
      switcher.create_test_file("test/helper.spec.js")
      local content = vim.fn.readfile(test_dir .. "/test/helper.spec.js")
      assert.same({}, content)
    end)
  end)
end)

