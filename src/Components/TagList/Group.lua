local ListItemChrome = require(script.Parent.Parent.ListItemChrome)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.Parent.ThemeContext)

local CLOSED_ARROW_IMAGE = "rbxassetid://2606412312"
local OPEN_ARROW_IMAGE = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png"

local Roact_createElement = Roact.createElement

local function Group(props)
	return Roact_createElement(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		leftClick = function()
			props.toggleHidden(props.Name)
		end,

		showDivider = true,
	}, {
		Roact_createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact_createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
				}, {
					GroupText = Roact_createElement("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.SourceSansSemibold,
						Position = UDim2.fromOffset(20, 0),
						Size = UDim2.new(1, -70, 1, 0),
						Text = props.Name,
						TextColor3 = theme.MainText.Default,
						TextSize = 20,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					Arrow = Roact_createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = props.Hidden and CLOSED_ARROW_IMAGE or OPEN_ARROW_IMAGE,

						-- FIXME: This needs a non-hardcoded icon color.
						-- The studio theme API doesn't have a class for this :(
						ImageColor3 = theme.ThemeName == "Light" and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(242, 242, 242),
						Position = UDim2.new(0, 10, 0.5, 0),
						Size = UDim2.fromOffset(12, 12),
					}),
				})
			end,
		}),
	})
end

return Group
