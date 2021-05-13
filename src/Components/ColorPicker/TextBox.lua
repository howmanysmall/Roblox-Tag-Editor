local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.Parent.ThemeContext)

local TextBox = Roact.PureComponent:extend("ColorPicker.TextBox")
TextBox.defaultProps = {
	Inset = 36,
}

local Roact_createElement = Roact.createElement

function TextBox:init()
	self:setState({
		hover = false,
		isValid = true,
		press = false,
	})
end

function TextBox:render()
	local props = self.props
	local inset = props.Inset

	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			local state = self.state
			local borderColor
			if not state.isValid then
				borderColor = Color3.fromRGB(255, 0, 0)
			else
				if state.focus then
					borderColor = theme.InputFieldBorder.Selected
				elseif state.hover then
					borderColor = theme.InputFieldBorder.Hover
				else
					borderColor = theme.InputFieldBorder.Default
				end
			end

			return Roact_createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = props.LayoutOrder,
				Position = props.Position,
				Size = props.Size,
			}, {
				Label = props.Label and Roact_createElement("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.SourceSans,
					Size = UDim2.fromOffset(inset, 20),
					Text = props.Label,
					TextColor3 = theme.MainText.Default,
					TextSize = 20,
					TextXAlignment = Enum.TextXAlignment.Left,
				}) or nil,

				Input = Roact_createElement("Frame", {
					BackgroundColor3 = theme.InputFieldBackground.Default,
					BorderColor3 = borderColor,
					Position = UDim2.fromOffset(inset, 0),
					Size = UDim2.new(1, -inset, 1, 0),

					[Roact.Event.MouseEnter] = function()
						self:setState({
							hover = true,
						})
					end,

					[Roact.Event.MouseLeave] = function()
						self:setState({
							hover = false,
						})
					end,
				}, {
					TextBox = Roact_createElement("TextBox", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.SourceSans,
						PlaceholderColor3 = theme.DimmedText.Default,
						PlaceholderText = props.Text,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -16, 1, 0),
						Text = "",
						TextColor3 = theme.MainText.Default,
						TextSize = 20,
						TextXAlignment = Enum.TextXAlignment.Left,

						[Roact.Change.Text] = function(rbx)
							local isValid = true
							if rbx.Text ~= "" then
								isValid = props.Validate(rbx.Text)
							end

							if isValid ~= state.isValid then
								self:setState({
									isValid = isValid,
								})
							end
						end,

						[Roact.Event.Focused] = function()
							self:setState({
								focus = true,
							})
						end,

						[Roact.Event.FocusLost] = function(rbx, enterPressed)
							self:setState({
								focus = false,
							})

							if enterPressed then
								if props.Validate(rbx.Text) then
									props.TextChanged(rbx.Text)
								end
							end
						end,
					}),
				}),
			})
		end,
	})
end

return TextBox
