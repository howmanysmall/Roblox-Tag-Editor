local Roact = require(script.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local Roact_createElement = Roact.createElement

local function ListItemChrome(props)
	local height = props.height or 26
	local state = props.state or Enum.StudioStyleGuideModifier.Default
	local showDivider = props.showDivider
	local child = Roact.oneChild(props[Roact.Children])

	state = type(state) == "string" and state or state.Name

	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact_createElement("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = theme.Item[state],
				BorderSizePixel = 0,
				LayoutOrder = props.LayoutOrder,
				Size = UDim2.new(1, 0, 0, height),
				Text = "",
				Visible = not props.hidden,

				[Roact.Event.MouseButton1Click] = props.leftClick,
				[Roact.Event.MouseButton2Click] = props.rightClick,
				[Roact.Event.MouseEnter] = props.mouseEnter,
				[Roact.Event.MouseLeave] = props.mouseLeave,
			}, {
				Divider = Roact_createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = theme.Separator.Default,
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0, -1),
					Size = UDim2.new(1, 0, 0, 1),
					Visible = showDivider,
				}),

				Contents = child,
			})
		end,
	})
end

return ListItemChrome
