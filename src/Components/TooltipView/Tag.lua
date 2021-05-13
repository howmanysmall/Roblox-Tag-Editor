local TextService = game:GetService("TextService")

local Constants = require(script.Parent.Parent.Parent.Constants)
local Icon = require(script.Parent.Parent.Icon)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local TextLabel = require(script.Parent.Parent.TextLabel)

local Roact_createElement = Roact.createElement

local function Tag(props)
	local size = TextService:GetTextSize(props.Tag, 20, Enum.Font.SourceSans, Vector2.new(160, 100000))

	return Roact_createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 12 + size.Y),
		BackgroundTransparency = 1,
	}, {
		Divider = Roact_createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 1),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Constants.LightGrey,
		}),

		Holder = Roact_createElement("Frame", {
			Size = UDim2.new(1, -20, 0, size.Y),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}, {
			UIListLayout = Roact_createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Icon = Roact_createElement(Icon, {
				Name = props.Icon,
				LayoutOrder = 1,
			}),

			Tag = Roact_createElement(TextLabel, {
				Text = props.Tag,
				LayoutOrder = 2,
				TextWrapped = true,
				Size = UDim2.new(1, -20, 0, size.Y),
			}),
		}),
	})
end

return Tag
