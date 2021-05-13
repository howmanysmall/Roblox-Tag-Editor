local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local WorldProvider = require(script.WorldProvider)
local WorldVisual = require(script.WorldVisual)

local Roact_createElement = Roact.createElement

local function WorldView(props)
	if props.enabled then
		return Roact_createElement(WorldProvider, {}, {
			render = function(partsList)
				return Roact_createElement(WorldVisual, {
					partsList = partsList,
					tags = props.tags,
				})
			end,
		})
	else
		return nil
	end
end

local function mapStateToProps(state)
	return {
		enabled = state.WorldView,
		tags = state.TagData,
	}
end

WorldView = RoactRodux.connect(mapStateToProps)(WorldView)

return WorldView
