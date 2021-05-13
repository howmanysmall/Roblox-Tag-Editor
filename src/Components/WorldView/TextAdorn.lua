local Constants = require(script.Parent.Parent.Parent.Constants)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local Roact_createElement = Roact.createElement

local function TextAdorn(props)
	local children = {}
	if #props.TagName > 1 then
		children.UIListLayout = Roact_createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	end

	for index, name in ipairs(props.TagName) do
		children[name] = Roact_createElement("TextLabel", {
			LayoutOrder = index,
			Size = UDim2.fromScale(1, 1 / #props.TagName),
			Text = name,
			TextScaled = true,
			TextSize = 20,
			Font = Enum.Font.SourceSansBold,
			TextColor3 = Constants.White,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			TextStrokeTransparency = 0,
		})
	end

	return Roact_createElement("BillboardGui", {
		Adornee = props.Adornee,
		Size = UDim2.fromScale(10, #props.TagName),
		SizeOffset = Vector2.new(0.5, 0.5),
		ExtentsOffsetWorldSpace = Vector3.new(1, 1, 1),
		AlwaysOnTop = props.AlwaysOnTop,
	}, children)
end

return TextAdorn
