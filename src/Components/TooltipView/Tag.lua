local TextService = game:GetService("TextService")

local Constants = require(script.Parent.Parent.Parent.Constants)
local Icon = require(script.Parent.Parent.Icon)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local TextLabel = require(script.Parent.Parent.TextLabel)

local Roact_createElement = Roact.createElement

local function Tag(props)
	local size = TextService:GetTextSize(props.Tag, 20, Enum.Font.SourceSans, Vector2.new(160, 100000))

	return Roact_createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 12 + size.Y),
	}, {
		Divider = Roact_createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Constants.LightGrey,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(1, -20, 0, 1),
		}),

		Holder = Roact_createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -20, 0, size.Y),
		}, {
			UIListLayout = Roact_createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Icon = Roact_createElement(Icon, {
				LayoutOrder = 1,
				Name = props.Icon,
			}),

			Tag = Roact_createElement(TextLabel, {
				LayoutOrder = 2,
				Size = UDim2.new(1, -20, 0, size.Y),
				Text = props.Tag,
				TextWrapped = true,
			}),
		}),
	})
end

return Tag
