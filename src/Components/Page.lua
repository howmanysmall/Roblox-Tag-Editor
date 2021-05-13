local Icon = require(script.Parent.Icon)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local TextLabel = require(script.Parent.TextLabel)
local ThemeContext = require(script.Parent.ThemeContext)
local Roact_createElement = Roact.createElement

local function Page(props)
	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact_createElement("ImageButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = theme.MainBackground.Default,
				ZIndex = 10,
				Visible = props.visible,
				AutoButtonColor = false,
			}, {
				Topbar = Roact_createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = theme.Titlebar.Default,
					BorderSizePixel = 0,
					ZIndex = 2,
				}, {
					Back = Roact_createElement("TextButton", {
						Size = UDim2.fromOffset(48, 32),
						Text = "Back",
						TextSize = 20,
						Font = Enum.Font.SourceSansBold,
						BackgroundTransparency = 1,
						TextColor3 = theme.TitlebarText.Default,
						[Roact.Event.MouseButton1Click] = props.close,
					}),

					Title = Roact_createElement("Frame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
					}, {
						UIListLayout = Roact_createElement("UIListLayout", {
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 4),
						}),

						Icon = props.titleIcon and Roact_createElement(Icon, {
							Name = props.titleIcon,
							LayoutOrder = 1,
						}),

						Label = Roact_createElement(TextLabel, {
							Text = props.title,
							LayoutOrder = 2,
							TextColor3 = theme.TitlebarText.Default,
							Font = Enum.Font.SourceSansSemibold,
						}),
					}),

					Separator = Roact_createElement("Frame", {
						-- This separator acts as a bottom border, so we should use the border color, not the separator color
						BackgroundColor3 = theme.Border.Default,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 1),
						Position = UDim2.fromScale(0, 1),
						AnchorPoint = Vector2.new(0, 1),
						ZIndex = 2,
					}),
				}),

				Body = Roact_createElement("Frame", {
					Size = UDim2.new(1, 0, 1, -32),
					Position = UDim2.fromOffset(0, 32),
					BackgroundTransparency = 1,
				}, props[Roact.Children]),
			})
		end,
	})
end

return Page
