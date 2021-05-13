local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local RootPortal = require(script.Parent.Parent.RootPortal)
local ThemeContext = require(script.Parent.Parent.ThemeContext)

local ValueSlider = Roact.PureComponent:extend("ValueSlider")

local Roact_createElement = Roact.createElement

function ValueSlider:init()
	self:setState({
		mouseDown = false,
	})

	self._rootRef = Roact.createRef()
end

function ValueSlider:xToAlpha(x)
	local rbx = self._rootRef.current
	return math.clamp((x - rbx.AbsolutePosition.X) / rbx.AbsoluteSize.X, 0, 1)
end

function ValueSlider:render()
	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			local props = self.props
			local state = self.state

			return Roact_createElement("ImageButton", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 0, 1, 5),
				AnchorPoint = Vector2.new(),
				Image = "rbxassetid://1357203924",
				ImageColor3 = Color3.fromHSV(props.hue, props.sat, 1),
				AutoButtonColor = false,
				BorderColor3 = theme.Border.Default,
				[Roact.Ref] = self._rootRef,

				[Roact.Event.MouseButton1Down] = function(_, x)
					self:setState({
						valueMouseDown = true,
					})

					props.updatePosition(self:xToAlpha(x))
				end,
			}, {
				Position = Roact_createElement("ImageLabel", {
					Size = UDim2.fromOffset(8, 5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(props.val, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Image = "rbxassetid://2610863246",
					-- Hardcode this color, since the color it's on top of doesn't respond to themes
					ImageColor3 = Color3.fromRGB(255, 255, 255),
				}),

				Portal = Roact_createElement(RootPortal, nil, {
					ValueSliderInputCapturer = Roact_createElement("ImageButton", {
						BackgroundTransparency = 1,
						ZIndex = 100,
						Size = state.valueMouseDown and UDim2.fromScale(1, 1) or UDim2.new(),
						Visible = state.valueMouseDown,
						[Roact.Event.MouseButton1Up] = function(_, x)
							if state.valueMouseDown then
								self:setState({
									valueMouseDown = false,
								})

								props.updatePosition(self:xToAlpha(x))
							end
						end,

						[Roact.Event.MouseMoved] = function(_, x)
							if state.valueMouseDown then
								props.updatePosition(self:xToAlpha(x))
							end
						end,
					}),
				}),
			})
		end,
	})
end

return ValueSlider
