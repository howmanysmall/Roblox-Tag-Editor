local Icons = require(script.Parent.Parent.FamFamFam)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local Roact_createElement = Roact.createElement

local function Icon(props)
	local data = type(props.Name) == "string" and Icons.Lookup(props.Name) or Icons.Lookup("computer_error")
	local newProps = {
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = props.BackgroundTransparency or 1,
		Position = props.Position,
		Size = props.Size or UDim2.fromOffset(16, 16),

		[Roact.Event.MouseButton1Click] = props.onClick,
		[Roact.Event.MouseEnter] = function()
			local onHover = props.onHover
			if onHover then
				onHover(true)
			end
		end,

		[Roact.Event.MouseLeave] = function()
			local onHover = props.onHover
			if onHover then
				onHover(false)
			end
		end,
	}

	for key, value in pairs(data) do
		newProps[key] = value
	end

	for key, value in pairs(props) do
		if key ~= "Name" and key ~= "onClick" and key ~= "onHover" then
			newProps[key] = value
		end
	end

	return Roact_createElement(props.onClick and "ImageButton" or "ImageLabel", newProps)
end

return Icon
