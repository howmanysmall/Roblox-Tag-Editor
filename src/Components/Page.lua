local Icon = require(script.Parent.Icon)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local TextLabel = require(script.Parent.TextLabel)
local ThemeContext = require(script.Parent.ThemeContext)
local Roact_createElement = Roact.createElement

local function Page(props)
	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact_createElement("ImageButton", {
				AutoButtonColor = false,
				BackgroundColor3 = theme.MainBackground.Default,
				Size = UDim2.fromScale(1, 1),
				Visible = props.visible,
				ZIndex = 10,
			}, {
				Topbar = Roact_createElement("Frame", {
					BackgroundColor3 = theme.Titlebar.Default,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 32),
					ZIndex = 2,
				}, {
					Back = Roact_createElement("TextButton", {
						BackgroundTransparency = 1,
						Font = Enum.Font.SourceSansBold,
						Size = UDim2.fromOffset(48, 32),
						Text = "Back",
						TextColor3 = theme.TitlebarText.Default,
						TextSize = 20,
						[Roact.Event.MouseButton1Click] = props.close,
					}),

					Title = Roact_createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
					}, {
						UIListLayout = Roact_createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, 4),
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),

						Icon = props.titleIcon and Roact_createElement(Icon, {
							LayoutOrder = 1,
							Name = props.titleIcon,
						}),

						Label = Roact_createElement(TextLabel, {
							Font = Enum.Font.SourceSansSemibold,
							LayoutOrder = 2,
							Text = props.title,
							TextColor3 = theme.TitlebarText.Default,
						}),
					}),

					Separator = Roact_createElement("Frame", {
						-- This separator acts as a bottom border, so we should use the border color, not the separator color
						AnchorPoint = Vector2.new(0, 1),
						BackgroundColor3 = theme.Border.Default,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.new(1, 0, 0, 1),
						ZIndex = 2,
					}),
				}),

				Body = Roact_createElement("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 32),
					Size = UDim2.new(1, 0, 1, -32),
				}, props[Roact.Children]),
			})
		end,
	})
end

return Page
