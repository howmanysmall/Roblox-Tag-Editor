local Icon = require(script.Parent.Icon)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local TextLabel = require(script.Parent.TextLabel)
local ThemeContext = require(script.Parent.ThemeContext)

local function Page(props)
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("ImageButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = theme.MainBackground.Default,
				ZIndex = 10,
				Visible = props.visible,
				AutoButtonColor = false,
			}, {
				Topbar = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = theme.Titlebar.Default,
					BorderSizePixel = 0,
					ZIndex = 2,
				}, {
					Back = Roact.createElement("TextButton", {
						Size = UDim2.new(0, 48, 0, 32),
						Text = "Back",
						TextSize = 20,
						Font = Enum.Font.SourceSansBold,
						BackgroundTransparency = 1,
						TextColor3 = theme.TitlebarText.Default,
						[Roact.Event.MouseButton1Click] = props.close,
					}),

					Title = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 4),
						}),

						Icon = props.titleIcon and Roact.createElement(Icon, {
							Name = props.titleIcon,
							LayoutOrder = 1,
						}),

						Label = Roact.createElement(TextLabel, {
							Text = props.title,
							LayoutOrder = 2,
							TextColor3 = theme.TitlebarText.Default,
							Font = Enum.Font.SourceSansSemibold,
						}),
					}),

					Separator = Roact.createElement("Frame", {
						-- This separator acts as a bottom border, so we should use the border color, not the separator color
						BackgroundColor3 = theme.Border.Default,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 1),
						Position = UDim2.new(0, 0, 1, 0),
						AnchorPoint = Vector2.new(0, 1),
						ZIndex = 2,
					}),
				}),

				Body = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, -32),
					Position = UDim2.new(0, 0, 0, 32),
					BackgroundTransparency = 1,
				}, props[Roact.Children]),
			})
		end,
	})
end

return Page
