local M = {}

-- Spinner animation frames
local spinners = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" }

local function get_spinner()
  local idx = (math.floor(vim.loop.hrtime() / 100000000) % #spinners) + 1
  return spinners[idx]
end

---Provider function for the lsp_progress component.
---@param opts? FancylineLspProgressComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  -- Check if LSP progress is available
  if not rawget(vim, "lsp") or not vim.lsp then
    return nil
  end

  -- Get progress messages
  local ok, messages = pcall(vim.lsp.util.get_progress_messages)
  if not ok or not messages or #messages == 0 then
    return nil
  end

  local message = messages[1]

  -- Build the display text
  local spinner = get_spinner()
  local name = message.name or "LSP"
  local percentage = message.percentage

  local text_parts = { spinner }

  -- Add percentage if available
  if percentage then
    table.insert(text_parts, string.format("%d%%", math.floor(percentage)))
  end

  -- Add message/title if available
  if message.title then
    table.insert(text_parts, message.title)
  end

  local text = table.concat(text_parts, " ")

  return {
    text = text,
    highlight = "FancylineLspProgress",
    style = opts.style or "default",
    state = "n",
  }
end

return M
