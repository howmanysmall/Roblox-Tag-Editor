local Actions = require(script.Parent.Parent.Actions)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local Search = require(script.Parent.Search)

local function mapStateToProps(state)
	return {
		term = state.Search,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setTerm = function(text)
			dispatch(Actions.SetSearch(text))
		end,
	}
end

local TagSearch = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Search)

return TagSearch
