local Icon = require(script.Parent.Parent.Icon)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local Roact_createElement = Roact.createElement

local function IconAdorn(props)
	local children = {}
	if #props.Icon > 1 then
		children.UIListLayout = Roact_createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.125, 0),
		})
	end

	for index, icon in ipairs(props.Icon) do
		children[index] = Roact_createElement(Icon, {
			Name = icon,
			Size = UDim2.fromScale(1 / #props.Icon, 1),
		})
	end

	return Roact_createElement("BillboardGui", {
		Adornee = props.Adornee,
		AlwaysOnTop = props.AlwaysOnTop,
		ExtentsOffsetWorldSpace = Vector3.new(1, 1, 1),
		Size = UDim2.fromScale(#props.Icon, 1),
		SizeOffset = Vector2.new(0.5, 0.5),
	}, children)
end

return IconAdorn
