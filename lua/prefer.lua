local M = {}

local api = vim.api

local cache = {
  buf = {},
  win = {},
}

---@class infra.prefer.Descriptor
local Descriptor = {
  --@type {buf: number?, win: number?} used for api.nvim_{g,s}et_option_value
  opts = nil,
  __index = function(t, k) return api.nvim_get_option_value(k, t.opts) end,
  __newindex = function(t, k, v) return api.nvim_set_option_value(k, v, t.opts) end,
}

---@param scope 'buf'|'win'
---@param checker fun(handle: number): boolean
local function new_local_descriptor(scope, checker)
  ---@param handle number
  ---@return infra.prefer.Descriptor
  return function(handle)
    assert(handle and handle ~= 0)
    if not checker(handle) then error(string.format("%s#%d does not exist", scope, handle)) end
    if cache[scope][handle] == nil then cache[scope][handle] = setmetatable({ opts = { [scope] = handle } }, Descriptor) end
    return cache[scope][handle]
  end
end

do
  local aug = api.nvim_create_augroup("prefer", { clear = true })
  api.nvim_create_autocmd("bufwipeout", {
    group = aug,
    callback = function(args) cache.buf[assert(tonumber(args.buf))] = nil end,
  })
  api.nvim_create_autocmd("winclosed", {
    group = aug,
    callback = function(args) cache.win[assert(tonumber(args.match))] = nil end,
  })
end

M.buf = new_local_descriptor("buf", api.nvim_buf_is_valid)
M.win = new_local_descriptor("win", api.nvim_win_is_valid)

--getter or setter
---@param bufnr number
---@param k string
function M.bo(bufnr, k, v)
  local descriptor = M.buf(bufnr)
  if v == nil then return descriptor[k] end
  descriptor[k] = v
end

--getter or setter
---@param winid number
---@param k string
function M.wo(winid, k, v)
  local descriptor = M.win(winid)
  if v == nil then return descriptor[k] end
  descriptor[k] = v
end

return M
