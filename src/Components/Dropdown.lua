local Button = require(script.Parent.Button)
local ListItem = require(script.Parent.ListItem)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RootPortal = require(script.Parent.RootPortal)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local ThemeContext = require(script.Parent.ThemeContext)
local rootKey = require(script.Parent.rootKey)

local ARROW_IMAGE = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png"

local Roact_createElement = Roact.createElement

-- TODO: Convert to context api

local DropdownItem = function(props)
	return Roact_createElement(ListItem, {
		ShowDivider = false,
		Text = props.Text,
		leftClick = props.leftClick,
		ignoresMenuOpen = true,
		TextProps = {
			TextSize = 16,
		},
	})
end

local Dropdown = Roact.PureComponent:extend("Dropdown")

function Dropdown:init()
	self:setState({
		open = false,
	})

	self._listRef = Roact.createRef()
end

function Dropdown.getDerivedStateFromProps(nextProps)
	return {
		dropdownHeight = math.min(120, #nextProps.Options * 26),
	}
end

function Dropdown:render()
	local props = self.props
	local state = self.state
	local children = {}

	for _, option in ipairs(props.Options) do
		children[option] = Roact_createElement(DropdownItem, {
			Text = option,
			Height = 26,
			leftClick = function()
				self:setState({
					open = false,
				})

				props.onOptionSelected(option)
			end,
		})
	end

	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact_createElement(Button, {
				Size = props.Size,
				LayoutOrder = props.LayoutOrder,
				Position = props.Position,
				Text = props.CurrentOption,
				[Roact.Event.Changed] = function(rbx)
					local list = self._listRef.current

					if list ~= nil then
						local buttonPosition = rbx.AbsolutePosition
						local buttonSize = rbx.AbsoluteSize
						local viewportHeight = self._context[rootKey].current.AbsoluteSize.Y
						local remainingHeight = viewportHeight - buttonPosition.Y - buttonSize.Y - 8
						local listHeight = math.min(remainingHeight, state.dropdownHeight)

						if remainingHeight - self.state.dropdownHeight < -60 then
							-- There's not enough space below; put the dropdown above the button
							list.Position = UDim2.fromOffset(buttonPosition.X, buttonPosition.Y - state.dropdownHeight - 4)
							list.Size = UDim2.fromOffset(buttonSize.X, state.dropdownHeight)
						else
							list.Position = UDim2.fromOffset(buttonPosition.X, buttonPosition.Y + buttonSize.Y + 4)
							list.Size = UDim2.fromOffset(buttonSize.X, listHeight)
						end
					end
				end,

				leftClick = function()
					self:setState({
						open = not state.open,
					})
				end,
			}, {
				Portal = Roact_createElement(RootPortal, nil, {
					OptionList = Roact_createElement(ScrollingFrame, {
						List = true,
						ShowBorder = true,
						Size = UDim2.new(1, 0, 0, state.dropdownHeight),
						Visible = state.open,
						ZIndex = 5,
						[Roact.Ref] = self._listRef,
					}, children),
				}),

				Arrow = Roact_createElement("ImageLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					Image = ARROW_IMAGE,
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.fromOffset(12, 12),
					-- FIXME: This needs a non-hardcoded icon color.
					-- The studio theme API doesn't have a class for this :(
					ImageColor3 = theme.ThemeName == "Light" and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(242, 242, 242),
				}),
			})
		end,
	})
end

return Dropdown
