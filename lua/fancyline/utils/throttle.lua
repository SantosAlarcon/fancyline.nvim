local M = {}

function M.throttle(fn, ms)
  local timer = assert(vim.loop.new_timer())
  local pending = false
  local args = nil

  return function(...)
    args = { ... }
    if not pending then
      pending = true
      timer:start(ms, 0, vim.schedule_wrap(function()
        pending = false
        if args then
          fn(unpack(args, 1, #args))
          args = nil
        end
      end))
    end
  end
end

function M.debounce(fn, ms)
  local timer = assert(vim.loop.new_timer())
  local pending = false

  return function(...)
    local args = { ... }
    if pending then
      timer:stop()
    end
    pending = true
    timer:start(ms, 0, vim.schedule_wrap(function()
      pending = false
      fn(unpack(args, 1, #args))
    end))
  end
end

function M.cleanup(timer_obj)
  if timer_obj then
    timer_obj:stop()
    timer_obj:close()
  end
end

return M
