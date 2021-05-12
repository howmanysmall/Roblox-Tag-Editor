local Actions = require(script.Parent.Parent.Parent.Actions)
local Item = require(script.Parent.Parent.ListItem)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Vendor.RoactRodux)
local TagManager = require(script.Parent.Parent.Parent.TagManager)

local function GroupItem(props)
	return Roact.createElement(Item, {
		Icon = "folder",
		Text = props.Name,
		Active = props.Active,
		LayoutOrder = props.LayoutOrder,

		leftClick = function()
			TagManager.Get():SetGroup(props.Tag, props.Group)
			props.close()
		end,

		onDelete = props.Group and function()
			props.delete(props.Group)
		end or nil,
	})
end

local function mapStateToProps(state)
	return {
		Tag = state.GroupPicker,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.ToggleGroupPicker(nil))
		end,

		delete = function(name)
			TagManager.Get():DelGroup(name)
		end,
	}
end

GroupItem = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(GroupItem)

return GroupItem
