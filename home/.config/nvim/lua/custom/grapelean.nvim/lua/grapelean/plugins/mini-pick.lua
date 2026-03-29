local colors = require('grapelean.utils').colors
local Group = require('grapelean.utils').Group

-- Mini Pick
Group.new('MiniPickNormal', colors.white, colors.bg_dark, nil)
Group.new('MiniPickBorder', colors.bg_dark, colors.bg_dark, nil)
Group.new('MiniPickBorderBusy', colors.gray_dark, colors.bg_dark, nil)
Group.new('MiniPickBorderText', colors.gray_light, colors.bg_dark, nil)
Group.new('MiniPickCursor', colors.white, colors.bg_light, nil)
Group.new('MiniPickIconDirectory', colors.blue, colors.bg_dark, nil)
Group.new('MiniPickIconFile', colors.gray_light, colors.bg_dark, nil)
Group.new('MiniPickHeader', colors.purple, colors.bg_dark, nil)
Group.new('MiniPickMatchCurrent', colors.yellow_light, colors.bg_dark, nil)
Group.new('MiniPickMatchMarked', colors.yellow, colors.bg_dark, nil)
Group.new('MiniPickMatchRanges', colors.green, nil, nil)
Group.new('MiniPickPreviewLine', colors.white, colors.bg_light, nil)
Group.new('MiniPickPreviewRegion', colors.white, colors.bg_light, nil)
Group.new('MiniPickPrompt', colors.green, colors.bg_dark, nil)
Group.new('MiniPickPromptCaret', colors.green, colors.bg_dark, nil)
Group.new('MiniPickPromptPrefix', colors.purple, colors.bg_dark, nil)

-- Grep result highlighting
Group.new('MiniPickGrepFile', colors.blue, nil, nil)
Group.new('MiniPickGrepLnum', colors.gray_light, nil, nil)
