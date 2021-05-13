local Actions = require(script.Parent.Parent.Actions)
local GroupItem = require(script.GroupItem)
local Item = require(script.Parent.ListItem)
local Page = require(script.Parent.Page)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local TagManager = require(script.Parent.Parent.TagManager)

local Roact_createElement = Roact.createElement

local function GroupPicker(props)
	local children = {
		UIPadding = Roact_createElement("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		}),

		Default = Roact_createElement(GroupItem, {
			Name = "Default",
			Group = nil,
			Active = props.tagGroup == nil,
			LayoutOrder = -1,
		}),
	}

	table.sort(props.groups, function(a, b)
		return a.Name < b.Name
	end)

	for index, entry in ipairs(props.groups) do
		local group = entry.Name
		children["Group " .. group] = Roact_createElement(GroupItem, {
			Name = group,
			Group = group,
			Active = props.tagGroup == group,
			LayoutOrder = index,
		})
	end

	children.AddNew = Roact_createElement(Item, {
		LayoutOrder = 99999999,
		Text = "Add new group...",
		Icon = "folder_add",
		IsInput = true,

		onSubmit = function(_, text)
			TagManager.Get():AddGroup(text)
		end,
	})

	return Roact_createElement(Page, {
		visible = props.groupPicker ~= nil,
		title = tostring(props.groupPicker) .. " - Select a Group",
		titleIcon = props.tagIcon,
		close = props.close,
	}, {
		Body = Roact_createElement(ScrollingFrame, {
			Size = UDim2.fromScale(1, 1),
			List = true,
		}, children),
	})
end

local function mapStateToProps(state)
	local tag = state.GroupPicker and TagManager.Get().tags[state.GroupPicker]

	return {
		groupPicker = state.GroupPicker,
		tagIcon = tag and tag.Icon or nil,
		tagGroup = tag and tag.Group or nil,
		groups = state.GroupData,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.ToggleGroupPicker(nil))
		end,
	}
end

GroupPicker = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(GroupPicker)

return GroupPicker
