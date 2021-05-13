local ColorPicker = require(script.ColorPicker)
local Dropdown = require(script.Dropdown)
local GroupData = require(script.GroupData)
local GroupPicker = require(script.GroupPicker)
local HoveredIcon = require(script.HoveredIcon)
local IconPicker = require(script.IconPicker)
local IconSearch = require(script.IconSearch)
local InstanceView = require(script.InstanceView)
local Search = require(script.Search)
local TagData = require(script.TagData)
local TagMenu = require(script.TagMenu)
local UnknownTags = require(script.UnknownTags)
local WorldView = require(script.WorldView)

return function(state, action)
	state = state or {}
	return {
		ColorPicker = ColorPicker(state.ColorPicker, action),
		Dropdown = Dropdown(state.Dropdown, action),
		GroupData = GroupData(state.GroupData, action),
		GroupPicker = GroupPicker(state.GroupPicker, action),
		HoveredIcon = HoveredIcon(state.HoveredIcon, action),
		IconPicker = IconPicker(state.IconPicker, action),
		IconSearch = IconSearch(state.IconSearch, action),
		InstanceView = InstanceView(state.InstanceView, action),
		Search = Search(state.Search, action),
		TagData = TagData(state.TagData, action),
		TagMenu = TagMenu(state.TagMenu, action),
		UnknownTags = UnknownTags(state.UnknownTags, action),
		WorldView = WorldView(state.WorldView, action),
	}
end
