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
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansBold,
			LayoutOrder = index,
			Size = UDim2.fromScale(1, 1 / #props.TagName),
			Text = name,
			TextColor3 = Constants.White,
			TextScaled = true,
			TextSize = 20,
			TextStrokeTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Bottom,
		})
	end

	return Roact_createElement("BillboardGui", {
		Adornee = props.Adornee,
		AlwaysOnTop = props.AlwaysOnTop,
		ExtentsOffsetWorldSpace = Vector3.new(1, 1, 1),
		Size = UDim2.fromScale(10, #props.TagName),
		SizeOffset = Vector2.new(0.5, 0.5),
	}, children)
end

return TextAdorn
