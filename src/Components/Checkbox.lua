local Roact = require(script.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local Roact_createElement = Roact.createElement

local function Checkbox(props)
	local state = props.Checked and "Selected" or "Default"

	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact_createElement("ImageButton", {
				AnchorPoint = props.AnchorPoint,
				AutoButtonColor = false,
				BackgroundColor3 = theme.CheckedFieldBackground[state],
				BorderColor3 = theme.CheckedFieldBorder[state],
				LayoutOrder = props.LayoutOrder,
				Position = props.Position,
				Size = UDim2.fromOffset(20, 20),
				[Roact.Event.MouseButton1Click] = props.leftClick,
			}, {
				Check = Roact_createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://2617163557",
					ImageColor3 = theme.CheckedFieldIndicator[state],
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(16, 12),
					Visible = props.Checked == true,
				}),
			})
		end,
	})
end

return Checkbox
