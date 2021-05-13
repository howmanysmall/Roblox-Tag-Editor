local Actions = require(script.Parent.Parent.Actions)
local Button = require(script.Parent.Button)
local Constants = require(script.Parent.Parent.Constants)
local Page = require(script.Parent.Page)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local TagManager = require(script.Parent.Parent.TagManager)
local TextBox = require(script.TextBox)
local ThemeContext = require(script.Parent.ThemeContext)
local ValueSlider = require(script.ValueSlider)

local ColorPicker = Roact.PureComponent:extend("ColorPicker")

local Roact_createElement = Roact.createElement

function ColorPicker:init()
	self:setState({
		h = 0,
		s = 0,
		v = 0,
	})
end

function ColorPicker.getDerivedStateFromProps(nextProps, lastState)
	if nextProps.tagColor == nil then
		return {
			h = 0,
			s = 0,
			v = 0,
		}
	end

	if lastState.tagColor ~= nextProps.tagColor then
		lastState.tagColor = nextProps.tagColor
		local h, s, v = Color3.toHSV(nextProps.tagColor)
		return {
			-- When we open a fresh color picker, it should default to the color that the tag already was
			h = h,
			s = s,
			v = v,
			tagColor = nextProps.tagColor,
		}
	end
end

function ColorPicker:render()
	local props = self.props
	local state = self.state

	local hue, sat, val = state.h, state.s, state.v
	local color = Color3.fromHSV(hue, sat, val)
	local red, green, blue = color.R, color.G, color.B

	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact_createElement(Page, {
				close = props.close,
				title = tostring(props.tagName) .. " - Select a Color",
				titleIcon = props.tagIcon,
				visible = props.tagName ~= nil,
			}, {
				Body = Roact_createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
				}, {
					UIAspectRatioConstraint = Roact_createElement("UIAspectRatioConstraint", {
						AspectRatio = 500 / 280,
					}),

					UIPadding = Roact_createElement("UIPadding", {
						PaddingBottom = UDim.new(0, 10),
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 10),
					}),

					Wheel = Roact_createElement("ImageButton", {
						AutoButtonColor = false,
						BackgroundColor3 = Constants.Black,
						BorderColor3 = theme.Border.Default,
						Image = "rbxassetid://1357075261",
						ImageTransparency = 1 - val,
						Position = UDim2.new(),
						Size = UDim2.new(0.5, -4, 1, 0),

						[Roact.Event.MouseButton1Down] = function()
							self:setState({
								wheelMouseDown = true,
							})
						end,

						[Roact.Event.InputEnded] = function(rbx, inputObject)
							if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and self.state.wheelMouseDown then
								local x, y = inputObject.Position.X, inputObject.Position.Y
								local position = (Vector2.new(x, y) - rbx.AbsolutePosition) / rbx.AbsoluteSize
								position = Vector2.new(math.clamp(position.X, 0, 1), math.clamp(position.Y, 0, 1))
								self:setState({
									h = position.X,
									s = 1 - position.Y,
									wheelMouseDown = false,
								})
							end
						end,

						[Roact.Event.InputChanged] = function(rbx, inputObject)
							if state.wheelMouseDown and inputObject.UserInputType == Enum.UserInputType.MouseMovement then
								local position = (Vector2.new(inputObject.Position.X, inputObject.Position.Y) - rbx.AbsolutePosition) / rbx.AbsoluteSize

								self:setState({
									h = position.X,
									s = 1 - position.Y,
								})
							end
						end,
					}, {
						UIAspectRatioConstraint = Roact_createElement("UIAspectRatioConstraint"),
						Position = Roact_createElement("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Constants.DarkGrey,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(hue, 1 - sat),
							Size = UDim2.fromOffset(4, 4),
						}),

						ValueSlider = Roact_createElement(ValueSlider, {
							hue = hue,
							sat = sat,
							val = val,
							updatePosition = function(newValue)
								self:setState({
									v = newValue,
								})
							end,
						}),
					}),

					PropertiesPanel = Roact_createElement("Frame", {
						AnchorPoint = Vector2.new(1, 0),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(1, 0),
						Size = UDim2.new(0.5, -8, 1, -64),
					}, {
						UIListLayout = Roact_createElement("UIListLayout", {
							Padding = UDim.new(0, 8),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						Hex = Roact_createElement(TextBox, {
							Label = "Hex",
							LayoutOrder = 1,
							Size = UDim2.new(1, 0, 0, 20),
							Text = string.format("#%02x%02x%02x", red * 255, green * 255, blue * 255),

							TextChanged = function(text)
								local r, g, b = string.match(text, "^%s*#?(%x%x)(%x%x)(%x%x)%s*$")
								r = tonumber(r, 16)
								g = tonumber(g, 16)
								b = tonumber(b, 16)
								local intermediaryColor = Color3.fromRGB(r, g, b)
								local newH, newS, newV = Color3.toHSV(intermediaryColor)

								self:setState({
									h = newH,
									s = newS,
									v = newV,
								})
							end,

							Validate = function(text)
								return string.match(text, "^%s*#?(%x%x%x%x%x%x)%s*$") ~= nil
							end,
						}),

						Rgb = Roact_createElement(TextBox, {
							Label = "RGB",
							LayoutOrder = 2,
							Size = UDim2.new(1, 0, 0, 20),
							Text = string.format("%d, %d, %d", red * 255, green * 255, blue * 255),

							TextChanged = function(text)
								local r, g, b = string.match(text, "^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%s*$")
								r = tonumber(r)
								g = tonumber(g)
								b = tonumber(b)
								local intermediaryColor = Color3.fromRGB(r, g, b)
								local newH, newS, newV = Color3.toHSV(intermediaryColor)

								self:setState({
									h = newH,
									s = newS,
									v = newV,
								})
							end,

							Validate = function(text)
								local r, g, b = string.match(text, "^%s*(%d?%d?%d)%s*,%s*(%d?%d?%d)%s*,%s*(%d?%d?%d)%s*%s*$")
								if r == nil or g == nil or b == nil then
									return false
								end

								if tonumber(r) > 255 or tonumber(g) > 255 or tonumber(b) > 255 then
									return false
								end

								return true
							end,
						}),

						Hsv = Roact_createElement(TextBox, {
							Label = "HSV",
							LayoutOrder = 3,
							Size = UDim2.new(1, 0, 0, 20),
							Text = string.format("%d, %d, %d", hue * 360, sat * 100, val * 100),

							TextChanged = function(text)
								local h, s, v = string.match(text, "^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%s*$")
								h = tonumber(h) / 360
								s = tonumber(s) / 100
								v = tonumber(v) / 100
								self:setState({
									h = h,
									s = s,
									v = v,
								})
							end,

							Validate = function(text)
								local h, s, v = string.match(text, "^%s*(%d?%d?%d)%s*,%s*(%d?%d?%d)%s*,%s*(%d?%d?%d)%s*%s*$")
								if h == nil or s == nil or v == nil then
									return false
								end

								if tonumber(h) > 360 then
									return false
								end

								if tonumber(s) > 100 or tonumber(v) > 100 then
									return false
								end

								return true
							end,
						}),

						Preview = Roact_createElement("Frame", {
							AnchorPoint = Vector2.new(0, 1),
							BackgroundColor3 = color,
							BorderColor3 = theme.Border.Default,
							LayoutOrder = 4,
							Size = UDim2.new(1, 0, 0, 48),
						}),

						Buttons = Roact_createElement("Frame", {
							BackgroundTransparency = 1,
							LayoutOrder = 5,
							Size = UDim2.new(1, 0, 0, 24),
						}, {
							UIListLayout = Roact_createElement("UIListLayout", {
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								Padding = UDim.new(0, 8),
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),

							Cancel = Roact_createElement(Button, {
								LayoutOrder = 2,
								leftClick = props.close,
								Size = UDim2.new(0.5, 0, 0, 24),
								Text = "Cancel",
							}),

							Submit = Roact_createElement(Button, {
								LayoutOrder = 1,
								Size = UDim2.new(0.5, 0, 0, 24),
								Text = "Submit",
								leftClick = function()
									TagManager.Get():SetColor(props.tagName, Color3.fromHSV(state.h, state.s, state.v))
									props.close()
								end,
							}),
						}),
					}),
				}),
			})
		end,
	})
end

local function mapStateToProps(state)
	local tag = state.ColorPicker
	local tagIcon
	local tagColor
	for _, entry in ipairs(state.TagData) do
		if entry.Name == tag then
			tagIcon = entry.Icon
			tagColor = entry.Color
			break
		end
	end

	return {
		tagName = tag,
		tagIcon = tagIcon,
		tagColor = tagColor,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.ToggleColorPicker(nil))
		end,
	}
end

ColorPicker = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(ColorPicker)

return ColorPicker
