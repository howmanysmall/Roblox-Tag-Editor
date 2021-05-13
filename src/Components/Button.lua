local Roact = require(script.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.ThemeContext)

local Button = Roact.PureComponent:extend("Button")
Button.defaultProps = {
	Font = Enum.Font.SourceSans,
	TextSize = 16,
}

local Roact_createElement = Roact.createElement

function Button:init()
	self:setState({
		hover = false,
		press = false,
	})

	self._mouseEnter = function()
		self:setState({
			hover = true,
		})
	end

	self._mouseLeave = function()
		self:setState({
			hover = false,
			press = false,
		})
	end

	self._mouseDown = function()
		self:setState({
			press = true,
		})
	end

	self._mouseUp = function()
		self:setState({
			press = false,
		})
	end
end

function Button:render()
	local props = self.props
	local buttonState = "Default"

	if props.Disabled then
		buttonState = "Disabled"
	elseif self.state.press then
		buttonState = "Pressed"
	elseif self.state.hover then
		buttonState = "Hover"
	end

	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact_createElement("TextButton", {
				AnchorPoint = props.AnchorPoint,
				AutoButtonColor = false,
				BackgroundColor3 = theme.Button[buttonState],
				BorderColor3 = theme.ButtonBorder[buttonState],
				BorderSizePixel = 1,
				Font = props.Font,
				LayoutOrder = props.LayoutOrder,
				Position = props.Position,
				Size = props.Size,
				Text = props.Text,
				TextColor3 = theme.ButtonText[buttonState],
				TextSize = props.TextSize,
				ZIndex = props.ZIndex,

				[Roact.Event.MouseEnter] = self._mouseEnter,
				[Roact.Event.MouseLeave] = self._mouseLeave,
				[Roact.Event.MouseButton1Down] = self._mouseDown,
				[Roact.Event.MouseButton1Up] = self._mouseUp,
				[Roact.Event.MouseButton1Click] = props.leftClick,
				[Roact.Event.Changed] = props[Roact.Event.Changed],
			}, props[Roact.Children])
		end,
	})
end

return Button
