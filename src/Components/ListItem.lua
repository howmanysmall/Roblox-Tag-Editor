local Icon = require(script.Parent.Icon)
local ListItemChrome = require(script.Parent.ListItemChrome)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local ThemeContext = require(script.Parent.ThemeContext)

local function merge(orig, new)
	local newTable = {}
	for key, value in pairs(orig or {}) do
		newTable[key] = value
	end

	for key, value in pairs(new or {}) do
		newTable[key] = value
	end

	return newTable
end

local Item = Roact.PureComponent:extend("Item")

local Roact_createElement = Roact.createElement

function Item:init()
	self:setState({
		hover = false,
	})
end

function Item:render()
	local props = self.props
	local ignoresMenuOpen = props.ignoresMenuOpen
	local isHover = self.state.hover and (not props.menuOpen or ignoresMenuOpen)
	local indent = props.Indent or 0
	local height = props.Height or 26

	local state = Enum.StudioStyleGuideModifier.Default
	if props.Active or props.SemiActive then
		state = Enum.StudioStyleGuideModifier.Selected
	elseif isHover then
		state = Enum.StudioStyleGuideModifier.Hover
	end

	return Roact_createElement(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		height = height,
		hidden = props.Hidden,
		leftClick = props.leftClick,

		mouseEnter = function()
			self:setState({
				hover = true,
			})
		end,

		mouseLeave = function()
			self:setState({
				hover = false,
			})
		end,

		rightClick = props.rightClick,
		showDivider = props.ShowDivider,
		state = state.Name,
	}, {
		Roact_createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact_createElement("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.new(),
					Size = UDim2.fromScale(1, 1),
				}, {
					TopElements = Roact_createElement("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(indent, 0),
						Size = UDim2.new(1, -indent, 0, 26),
					}, {
						Icon = props.Icon and Roact_createElement(Icon, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Name = props.Icon,
							Position = UDim2.new(0, 24, 0.5, 0),
						}),

						Name = Roact_createElement(props.IsInput and "TextBox" or "TextLabel", merge({
							BackgroundTransparency = 1,
							Font = Enum.Font.SourceSans,
							PlaceholderColor3 = props.IsInput and theme.DimmedText.Default or nil,
							PlaceholderText = props.IsInput and props.Text or nil,
							Position = props.Icon and UDim2.fromOffset(40, 0) or UDim2.fromOffset(14, 0),
							Size = UDim2.new(1, -40, 1, 0),
							Text = props.IsInput and "" or props.Text,
							TextColor3 = theme.MainText.Default,
							TextSize = 20,
							TextXAlignment = Enum.TextXAlignment.Left,

							[Roact.Event.FocusLost] = props.IsInput and function(rbx, enterPressed)
								local text = rbx.Text
								rbx.Text = ""
								if enterPressed then
									local onSubmit = props.onSubmit
									if onSubmit then
										onSubmit(rbx, text)
									end
								end
							end or nil,
						}, props.TextProps or {})),

						Visibility = props.onSetVisible and Roact_createElement(Icon, {
							AnchorPoint = Vector2.new(1, 0.5),
							Name = props.Visible and "lightbulb" or "lightbulb_off",
							Position = UDim2.new(1, -4, 0.5, 0),
							onClick = props.onSetVisible,
						}),

						Settings = props.onSettings and Roact_createElement(Icon, {
							AnchorPoint = Vector2.new(1, 0.5),
							Name = "cog",
							Position = UDim2.new(1, -24, 0.5, 0),

							onClick = props.onSettings,
						}),

						Delete = props.onDelete and Roact_createElement(Icon, {
							AnchorPoint = Vector2.new(1, 0.5),
							Name = "cancel",
							Position = UDim2.new(1, -4, 0.5, 0),

							onClick = props.onDelete,
						}),
					}),

					Children = Roact_createElement("Frame", {
						BackgroundColor3 = theme.MainBackground.Default,
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(0, 26),
						Size = UDim2.new(1, 0, 1, -26),
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
