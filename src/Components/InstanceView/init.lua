local Actions = require(script.Parent.Parent.Actions)
local InstanceList = require(script.InstanceList)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local TaggedInstanceProvider = require(script.TaggedInstanceProvider)
local TagManager = require(script.Parent.Parent.TagManager)
local Logger = require(script.Parent.Parent.Utility.Logger)

local ENABLED = true
local Roact_createElement = Roact.createElement
local InstanceViewLogger = Logger.new("InstanceViewLogger"):SetEnabled(ENABLED)

local function InstanceView(props)
	InstanceViewLogger:Debug("InstanceView.props: {:?}", props)
	return Roact_createElement(TaggedInstanceProvider, {
		tagName = props.tagName,
	}, {
		render = function(parts, selected)
			InstanceViewLogger:Debug("parts: {:?}\nselected: {:?}", parts, selected)
			return Roact_createElement(InstanceList, {
				parts = parts,
				selected = selected,
				tagName = props.tagName,
				tagIcon = props.tagIcon,
				close = props.close,
			})
		end,
	})
end

local function mapStateToProps(state)
	local tag = state.InstanceView and TagManager.Get().tags[state.InstanceView]

	return {
		tagName = state.InstanceView,
		tagIcon = tag and tag.Icon or nil,
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
