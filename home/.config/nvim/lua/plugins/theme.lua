local plugins = require 'lib/plugins'

-- Colors loaded from ~/.dotfiles/system/theme.json (symlink to active palette)
-- Swap palettes with: theme-swap <name> (e.g. theme-swap cobalt44, theme-swap grapelean)

return {
  {
    dir = plugins.custom_path 'grapelean.nvim',
    cond = not vim.g.vscode,
    dependencies = { 'tjdevries/colorbuddy.nvim', tag = 'v1.0.0' },
    priority = 1000,
    init = function()
      require('colorbuddy').colorscheme 'grapelean'
    end,
  },
}
