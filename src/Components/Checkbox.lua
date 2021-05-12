local Roact = require(script.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.ThemeContext)

local function Checkbox(props)
	local state = props.Checked and "Selected" or "Default"

	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("ImageButton", {
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundColor3 = theme.CheckedFieldBackground[state],
				BorderColor3 = theme.CheckedFieldBorder[state],
				AutoButtonColor = false,
				Position = props.Position,
				AnchorPoint = props.AnchorPoint,
				LayoutOrder = props.LayoutOrder,
				[Roact.Event.MouseButton1Click] = props.leftClick,
			}, {
				Check = Roact.createElement("ImageLabel", {
					Size = UDim2.new(0, 16, 0, 12),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Visible = props.Checked == true,
					ImageColor3 = theme.CheckedFieldIndicator[state],
					Image = "rbxassetid://2617163557",
				}),
			})
		end,
	})
end

return Checkbox
