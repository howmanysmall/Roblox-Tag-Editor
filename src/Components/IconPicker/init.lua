local Actions = require(script.Parent.Parent.Actions)
local Category = require(script.Category)
local IconCategories = require(script.Parent.Parent.IconCategories)
local IconPreview = require(script.IconPreview)
local Page = require(script.Parent.Page)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local Search = require(script.Parent.Search)
local ThemeContext = require(script.Parent.ThemeContext)

local IconPicker = Roact.PureComponent:extend("IconPicker")

local Roact_createElement = Roact.createElement

function IconPicker:init()
	self.closeFunction = function()
		self.props.close()
	end

	self.onHoverFunction = function(icon)
		self.props.setHoveredIcon(icon)
	end
end

function IconPicker:shouldUpdate(newProps)
	local props = self.props
	return props.tagName ~= newProps.tagName or props.search ~= newProps.search
end

local function sortCategories(a, b)
	local aName = a.Name
	local bName = b.Name

	local aIsUncat = aName == "Uncategorized" and 1 or 0
	local bIsUncat = bName == "Uncategorized" and 1 or 0

	if aIsUncat < bIsUncat then
		return true
	end

	if bIsUncat < aIsUncat then
		return false
	end

	return aName < bName
end

function IconPicker:render()
	local props = self.props
	local children = {}
	local categories = {}
	for name, icons in pairs(IconCategories) do
		table.insert(categories, {
			Name = name,
			Icons = icons,
		})
	end

	table.sort(categories, sortCategories)

	for index, category in ipairs(categories) do
		local name = category.Name
		local icons = category.Icons
		children[name] = Roact_createElement(Category, {
			CategoryName = name,
			Icons = icons,
			LayoutOrder = index,

			close = self.closeFunction,
			onHover = self.onHoverFunction,
			search = props.search,
			tagName = props.tagName,
		})
	end

	children.UIPadding = Roact_createElement("UIPadding", {
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingTop = UDim.new(0, 4),
	})

	return Roact_createElement(Page, {
		close = props.close,
		title = tostring(props.tagName) .. " - Select an Icon",
		titleIcon = props.tagIcon,
		visible = props.tagName ~= nil,
	}, {
		IconList = Roact_createElement(ScrollingFrame, {
			List = true,
			Position = UDim2.fromOffset(0, 64),
			Size = UDim2.new(1, 0, 1, -64),
		}, children),

		TopBar = Roact_createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact_createElement("Frame", {
					BackgroundColor3 = theme.Titlebar.Default,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 64),
					ZIndex = 2,
				}, {
					Search = Roact_createElement(Search, {
						Position = UDim2.fromOffset(56, 0),
						Size = UDim2.new(1, -56, 0, 40),

						setTerm = props.setTerm,
						term = props.search,
					}),

					Preview = Roact_createElement(IconPreview, {
						Position = UDim2.fromOffset(8, 8),
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
				})
			end,
		}),
	})
end

local function mapStateToProps(state)
	local tagName = state.IconPicker
	local tagIcon

	for _, tag in ipairs(state.TagData) do
		if tag.Name == tagName then
			tagIcon = tag.Icon
			break
		end
	end

	return {
		search = state.IconSearch,
		tagIcon = tagIcon,
		tagName = tagName,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.ToggleIconPicker(nil))
		end,

		setHoveredIcon = function(icon)
			dispatch(Actions.SetHoveredIcon(icon))
		end,

		setTerm = function(term)
			dispatch(Actions.SetIconSearch(term))
		end,
	}
end

IconPicker = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(IconPicker)

return IconPicker
