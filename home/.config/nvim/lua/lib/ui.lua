local M = {}

M.border_chars_empty = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }

-- @param {string} hl
-- @param {string} str
M.hl_str = function(hl, str)
  return '%#' .. hl .. '#' .. str .. '%*'
end

return M
