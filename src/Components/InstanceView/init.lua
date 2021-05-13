local Actions = require(script.Parent.Parent.Actions)
local InstanceList = require(script.InstanceList)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local TaggedInstanceProvider = require(script.TaggedInstanceProvider)
local TagManager = require(script.Parent.Parent.TagManager)

local Roact_createElement = Roact.createElement

local function InstanceView(props)
	return Roact_createElement(TaggedInstanceProvider, {
		tagName = props.tagName,
	}, {
		render = function(parts, selected)
			return Roact_createElement(InstanceList, {
				close = props.close,
				parts = parts,
				selected = selected,
				tagIcon = props.tagIcon,
				tagName = props.tagName,
			})
		end,
	})
end

local function mapStateToProps(state)
	local tag = state.InstanceView and TagManager.Get().tags[state.InstanceView]
	return {
		tagIcon = tag and tag.Icon or nil,
		tagName = state.InstanceView,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.OpenInstanceView(nil))
		end,
	}
end

InstanceView = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(InstanceView)

return InstanceView
