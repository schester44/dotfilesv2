local colors = require('grapelean.utils').colors
local Group = require('grapelean.utils').Group

-- Mini Notify
Group.new('MiniNotifyNormal', colors.white, colors.bg_dark, nil)
Group.new('MiniNotifyBorder', colors.bg_dark, colors.bg_dark, nil)
Group.new('MiniNotifyTitle', colors.purple, colors.bg_dark, nil)
Group.new('MiniNotifyLspProgress', colors.gray_light, colors.bg_dark, nil)
