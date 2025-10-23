---@class DockerPhpUnitConfig
---@field enabled? boolean
---@field container_name? string
---@field container_path? string
---@field cmd? string
---@field output? string
local DockerPhpUnitConfig = {}
DockerPhpUnitConfig.__index = DockerPhpUnitConfig

local plenary = require("plenary.path")
local logger = require("neotest.logging")

---Parses project configuration file to create config table.
---@return DockerPhpUnitConfig
function DockerPhpUnitConfig:load()
  local cwd = vim.fn.getcwd()
  local path = plenary:new(cwd, ".neotest.json")
  if not path:exists() then
    return setmetatable({}, self)
  end

  local parsed, data = pcall(vim.fn.readfile, path:absolute())
  if not parsed then
    logger.warn("Failed to read `.neotest.json`")
    return setmetatable({}, self)
  end

  local decoded, config = pcall(vim.fn.json_decode, table.concat(data, "\n"))
  if not decoded then
    logger.error("Failed to parse `.neotest.json`")
    return setmetatable({}, self)
  end

  return setmetatable(config or {}, self)
end

function DockerPhpUnitConfig:docker_cmd()
  local cmd = self.cmd or "vendor/bin/phpunit"
  if not self.enabled then
    return vim.split(cmd, " ")
  end

  local container = self.container_name or "php"
  local parts = vim.split(cmd, " ")

  return vim.list_extend({ "docker", "exec", "-i", container }, parts)
end

---@return string
function DockerPhpUnitConfig:remap(path)
  local cwd = vim.fn.getcwd()
  local target = self.container_path or "/var/www/html"

  return path:gsub("^" .. vim.pesc(cwd), target)
end

function DockerPhpUnitConfig:remap_to_host(path)
  local cwd = vim.fn.getcwd()
  local from = self.container_path or "/var/www/html"

  return path:gsub("^" .. vim.pesc(from), cwd)
end

function DockerPhpUnitConfig:result_path()
  local output_dir = self.output or ".phpunit"
  local result_path = vim.fn.getcwd() .. "/" .. output_dir .. "/results.xml"

  return self:remap(result_path)
end

return DockerPhpUnitConfig:load()
