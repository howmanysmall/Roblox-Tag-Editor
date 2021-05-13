local Roact = require(script.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local Roact_createElement = Roact.createElement

local function ScrollingFrame(props)
	local children = {}

	if props.List then
		local newProps = {
			SortOrder = Enum.SortOrder.LayoutOrder,
			[Roact.Ref] = function(rbx)
				if not rbx then
					return
				end

				local function update()
					if not rbx.Parent then
						return
					end

					rbx.Parent.CanvasSize = UDim2.fromOffset(0, rbx.AbsoluteContentSize.Y)
				end

				rbx:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
				update()
			end,
		}

		for key, value in pairs(props.List == true and {} or props.List) do
			newProps[key] = value
		end

		children.UIListLayout = Roact_createElement("UIListLayout", newProps)
	end

	for key, value in pairs(props[Roact.Children]) do
		children[key] = value
	end

	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact_createElement("Frame", {
				AnchorPoint = props.AnchorPoint,
				BackgroundColor3 = theme.MainBackground.Default,
				BorderColor3 = theme.Border.Default,
				BorderSizePixel = props.ShowBorder and 1 or 0,
				ClipsDescendants = true,
				LayoutOrder = props.LayoutOrder,
				Position = props.Position,
				Size = props.Size or UDim2.fromScale(1, 1),
				Visible = props.Visible,
				ZIndex = props.ZIndex,
				[Roact.Ref] = props[Roact.Ref],
			}, {
				BarBackground = Roact_createElement("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = theme.ScrollBarBackground.Default,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.new(0, 12, 1, 0),
				}),

				ScrollingFrame = Roact_createElement("ScrollingFrame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					BottomImage = "rbxasset://textures/StudioToolbox/ScrollBarBottom.png",
					MidImage = "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",
					ScrollBarImageColor3 = theme.ThemeName == "Dark" and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(245, 245, 245), --theme:GetColor("ScrollBar"),
					ScrollBarThickness = 8,
					Size = UDim2.new(1, -2, 1, 0),
					TopImage = "rbxasset://textures/StudioToolbox/ScrollBarTop.png",
					VerticalScrollBarInset = Enum.ScrollBarInset.Always,
				}, children),
			})
		end,
	})
end

return ScrollingFrame
