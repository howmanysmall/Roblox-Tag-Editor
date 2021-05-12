local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.Parent.ThemeContext)

local TextBox = Roact.PureComponent:extend("ColorPicker.TextBox")

function TextBox:init()
	self:setState({
		hover = false,
		press = false,
		isValid = true,
	})
end

function TextBox:render()
	local props = self.props
	local inset = props.Inset or 36

	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			local borderColor
			if not self.state.isValid then
				borderColor = Color3.fromRGB(255, 0, 0)
			else
				if self.state.focus then
					borderColor = theme.InputFieldBorder.Selected
				elseif self.state.hover then
					borderColor = theme.InputFieldBorder.Hover
				else
					borderColor = theme.InputFieldBorder.Default
				end
			end

			return Roact.createElement("Frame", {
				Size = props.Size,
				Position = props.Position,
				BackgroundTransparency = 1,
				LayoutOrder = props.LayoutOrder,
			}, {
				Label = props.Label and Roact.createElement("TextLabel", {
					Text = props.Label,
					Size = UDim2.new(0, inset, 0, 20),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 20,
					Font = Enum.Font.SourceSans,
					TextColor3 = theme.MainText.Default,
					BackgroundTransparency = 1,
				}) or nil,

				Input = Roact.createElement("Frame", {
					Size = UDim2.new(1, -inset, 1, 0),
					Position = UDim2.new(0, inset, 0, 0),
					BackgroundColor3 = theme.InputFieldBackground.Default,
					BorderColor3 = borderColor,

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
					TextBox = Roact.createElement("TextBox", {
						Text = "",
						PlaceholderText = props.Text,
						PlaceholderColor3 = theme.DimmedText.Default,
						Font = Enum.Font.SourceSans,
						TextSize = 20,
						TextColor3 = theme.MainText.Default,
						Size = UDim2.new(1, -16, 1, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,

						[Roact.Change.Text] = function(rbx)
							local isValid = true

							if rbx.Text ~= "" then
								isValid = props.Validate(rbx.Text)
							end

							if isValid ~= self.state.isValid then
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
