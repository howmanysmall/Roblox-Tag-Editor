local Icon = require(script.Parent.Icon)
local ListItemChrome = require(script.Parent.ListItemChrome)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local ThemeContext = require(script.Parent.ThemeContext)

local function merge(orig, new)
	local t = {}
	for k, v in pairs(orig or {}) do
		t[k] = v
	end

	for k, v in pairs(new or {}) do
		t[k] = v
	end

	return t
end

local Item = Roact.Component:extend("Item")

function Item:render()
	local props = self.props
	local ignoresMenuOpen = props.ignoresMenuOpen
	local isHover = self.state.Hover and (not props.menuOpen or ignoresMenuOpen)
	local indent = props.Indent or 0
	local height = props.Height or 26

	local state = Enum.StudioStyleGuideModifier.Default
	if props.Active or props.SemiActive then
		state = Enum.StudioStyleGuideModifier.Selected
	elseif isHover then
		state = Enum.StudioStyleGuideModifier.Hover
	end

	return Roact.createElement(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		hidden = props.Hidden,
		state = state.Name,
		height = height,
		showDivider = props.ShowDivider,

		mouseEnter = function()
			self:setState({
				Hover = true,
			})
		end,

		mouseLeave = function()
			self:setState({
				Hover = false,
			})
		end,

		leftClick = props.leftClick,
		rightClick = props.rightClick,
	}, {
		Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 0),
				}, {
					TopElements = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -indent, 0, 26),
						Position = UDim2.new(0, indent, 0, 0),
					}, {
						Icon = props.Icon and Roact.createElement(Icon, {
							Name = props.Icon,
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0, 24, 0.5, 0),
						}),

						Name = Roact.createElement(props.IsInput and "TextBox" or "TextLabel", merge({
							BackgroundTransparency = 1,
							TextXAlignment = Enum.TextXAlignment.Left,
							Position = props.Icon and UDim2.new(0, 40, 0, 0) or UDim2.new(0, 14, 0, 0),
							Size = UDim2.new(1, -40, 1, 0),
							Text = props.IsInput and "" or props.Text,
							PlaceholderText = props.IsInput and props.Text or nil,
							PlaceholderColor3 = props.IsInput and theme.DimmedText.Default or nil,
							Font = Enum.Font.SourceSans,
							TextSize = 20,
							TextColor3 = theme.MainText.Default,

							[Roact.Event.FocusLost] = props.IsInput and function(rbx, enterPressed)
								local text = rbx.Text
								rbx.Text = ""
								if props.onSubmit and enterPressed then
									props.onSubmit(rbx, text)
								end
							end or nil,
						}, props.TextProps or {})),

						Visibility = props.onSetVisible and Roact.createElement(Icon, {
							Name = props.Visible and "lightbulb" or "lightbulb_off",
							Position = UDim2.new(1, -4, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),

							onClick = props.onSetVisible,
						}),

						Settings = props.onSettings and Roact.createElement(Icon, {
							Name = "cog",
							Position = UDim2.new(1, -24, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),

							onClick = props.onSettings,
						}),

						Delete = props.onDelete and Roact.createElement(Icon, {
							Name = "cancel",
							Position = UDim2.new(1, -4, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),

							onClick = props.onDelete,
						}),
					}),

					Children = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 1, -26),
						Position = UDim2.new(0, 0, 0, 26),
						BackgroundColor3 = theme.MainBackground.Default,
						BorderSizePixel = 0,
					}, props[Roact.Children]),
				})
			end,
		}),
	})
end

local function mapStateToProps(state)
	return {
		menuOpen = state.TagMenu and not state.GroupPicker,
	}
end

Item = RoactRodux.connect(mapStateToProps)(Item)

return Item
