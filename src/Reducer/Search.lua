return function(state, action)
	state = state or ""

	if action.type == "SetSearch" then
		assert(type(action.text) == "string")
		return action.text
	end

	return state
end
