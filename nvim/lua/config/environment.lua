local uv = vim.uv or vim.loop

local function load_dotenv(path)
  if not uv.fs_stat(path) then
    return
  end

  for _, line in ipairs(vim.fn.readfile(path)) do
    local key, value = line:match("^%s*([%a_][%w_]*)%s*=%s*(.-)%s*$")
    if key and value then
      local quote = value:sub(1, 1)
      if #value >= 2 and (quote == '"' or quote == "'") and value:sub(-1) == quote then
        value = value:sub(2, -2)
      end
      vim.env[key] = value
    end
  end
end

local function prepend_path(path)
  local current = vim.env.PATH or ""
  local normalized = path:lower():gsub("[\\/]$", "")
  for entry in current:gmatch("[^;]+") do
    if entry:lower():gsub("[\\/]$", "") == normalized then
      return
    end
  end
  vim.env.PATH = path .. ";" .. current
end

local function find_scoop_bin(app, executable)
  local scoop_root = vim.env.SCOOP or vim.fs.joinpath(vim.fn.expand("~"), "scoop")
  local pattern = vim.fs.joinpath(scoop_root, "apps", app, "*", "bin")
  local candidates = vim.fn.glob(pattern, false, true)
  table.sort(candidates, function(left, right)
    local left_stat = uv.fs_stat(left)
    local right_stat = uv.fs_stat(right)
    return (left_stat and left_stat.mtime.sec or 0) > (right_stat and right_stat.mtime.sec or 0)
  end)

  for _, bin in ipairs(candidates) do
    if uv.fs_stat(vim.fs.joinpath(bin, executable)) then
      return bin
    end
  end
end

local function ensure_windows_c_compiler()
  if vim.fn.has("win32") ~= 1 then
    return
  end
  if vim.env.CC then
    return
  end

  if vim.fn.executable("gcc") == 1 then
    vim.env.CC = "gcc"
    return
  end
  local gcc_bin = find_scoop_bin("gcc", "gcc.exe")
  if gcc_bin then
    prepend_path(gcc_bin)
    vim.env.CC = "gcc"
    return
  end

  if vim.fn.executable("cl") == 1 then
    vim.env.CC = "cl"
    return
  end
  if vim.fn.executable("clang") == 1 then
    vim.env.CC = "clang"
    return
  end

  local llvm_bin = find_scoop_bin("llvm", "clang.exe")
  if llvm_bin then
    prepend_path(llvm_bin)
    vim.env.CC = "clang"
  end
end

load_dotenv(vim.fs.joinpath(vim.fn.stdpath("config"), ".env"))
ensure_windows_c_compiler()
