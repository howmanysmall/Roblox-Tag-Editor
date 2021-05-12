local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local ListItemChrome = require(script.Parent.Parent.ListItemChrome)
local ThemeContext = require(script.Parent.Parent.ThemeContext)

local CLOSED_ARROW_IMAGE = "rbxassetid://2606412312"
local OPEN_ARROW_IMAGE = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png"

local function Group(props)
	return Roact.createElement(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		showDivider = true,
		leftClick = function()
			props.toggleHidden(props.Name)
		end,
	}, {
		Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
				}, {
					GroupText = Roact.createElement("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = props.Name,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -70, 1, 0),
						Position = UDim2.new(0, 20, 0, 0),
						TextColor3 = theme.MainText.Default,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = 20,
					}),

					Arrow = Roact.createElement("ImageLabel", {
						Size = UDim2.new(0, 12, 0, 12),
						Position = UDim2.new(0, 10, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Image = props.Hidden and CLOSED_ARROW_IMAGE or OPEN_ARROW_IMAGE,
						BackgroundTransparency = 1,
						-- FIXME: This needs a non-hardcoded icon color.
						-- The studio theme API doesn't have a class for this :(
						ImageColor3 = theme.ThemeName == "Light" and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(242, 242, 242),
					}),
				})
			end,
		}),
	})
end

return Group
