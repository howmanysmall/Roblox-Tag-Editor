local Roact = require(script.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.ThemeContext)

local function ListItemChrome(props)
	local height = props.height or 26
	local state = props.state or Enum.StudioStyleGuideModifier.Default
	local showDivider = props.showDivider
	local child = Roact.oneChild(props[Roact.Children])

	state = type(state) == "string" and state or state.Name

	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("TextButton", {
				Size = UDim2.new(1, 0, 0, height),
				AutoButtonColor = false,
				LayoutOrder = props.LayoutOrder,
				Visible = not props.hidden,
				BackgroundColor3 = theme.Item[state],
				BorderSizePixel = 0,
				Text = "",

				[Roact.Event.MouseEnter] = props.mouseEnter,
				[Roact.Event.MouseLeave] = props.mouseLeave,
				[Roact.Event.MouseButton1Click] = props.leftClick,
				[Roact.Event.MouseButton2Click] = props.rightClick,
			}, {
				Divider = Roact.createElement("Frame", {
					Visible = showDivider,
					Size = UDim2.new(1, 0, 0, 1),
					Position = UDim2.new(0.5, 0, 0, -1),
					AnchorPoint = Vector2.new(0.5, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = theme.Separator.Default,
				}),

				Contents = child,
			})
		end,
	})
end

return ListItemChrome
