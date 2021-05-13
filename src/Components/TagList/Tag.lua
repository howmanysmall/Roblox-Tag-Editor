local Actions = require(script.Parent.Parent.Parent.Actions)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Vendor.RoactRodux)
local TagManager = require(script.Parent.Parent.Parent.TagManager)
local Item = require(script.Parent.Parent.ListItem)
local TagSettings = require(script.Parent.TagSettings)

local Roact_createElement = Roact.createElement

local function Tag(props)
	local isOpen = props.tagWithOpenMenu == props.Tag

	return Roact_createElement(Item, {
		Active = props.HasAll,
		Height = isOpen and 171 or 26,
		Hidden = props.Hidden,
		Icon = props.Icon,
		Indent = props.Group and 10 or 0,
		IsInput = false,
		LayoutOrder = props.LayoutOrder,
		SemiActive = props.HasSome,
		Text = props.Tag,
		Visible = props.Visible,

		leftClick = function()
			TagManager.Get():SetTag(props.Tag, not props.HasAll)
		end,

		onSettings = function()
			if not isOpen then
				props.openTagMenu(props.Tag)
			else
				props.openTagMenu(nil)
			end
		end,

		onSetVisible = function()
			TagManager.Get():SetVisible(props.Tag, not props.Visible)
		end,

		rightClick = function()
			if not isOpen then
				props.openTagMenu(props.Tag)
			else
				props.openTagMenu(nil)
			end
		end,
	}, {
		Settings = isOpen and Roact_createElement(TagSettings, {}),
	})
end

local function mapStateToProps(state)
	return {
		tagWithOpenMenu = state.TagMenu,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		openTagMenu = function(tag)
			dispatch(Actions.OpenTagMenu(tag))
		end,
	}
end

Tag = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Tag)

return Tag
