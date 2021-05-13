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
	self.closeFunc = function()
		self.props.close()
	end

	self.onHoverFunc = function(icon)
		self.props.setHoveredIcon(icon)
	end
end

function IconPicker:shouldUpdate(newProps)
	local props = self.props
	return props.tagName ~= newProps.tagName or props.search ~= newProps.search
end

function IconPicker:render()
	local props = self.props
	local children = {}
	local cats = {}
	for name, icons in pairs(IconCategories) do
		table.insert(cats, {
			Name = name,
			Icons = icons,
		})
	end

	table.sort(cats, function(a, b)
		local aIsUncat = a.Name == "Uncategorized" and 1 or 0
		local bIsUncat = b.Name == "Uncategorized" and 1 or 0

		if aIsUncat < bIsUncat then
			return true
		end

		if bIsUncat < aIsUncat then
			return false
		end

		return a.Name < b.Name
	end)

	for index, cat in ipairs(cats) do
		local name = cat.Name
		local icons = cat.Icons
		children[name] = Roact_createElement(Category, {
			LayoutOrder = index,
			CategoryName = name,
			Icons = icons,
			tagName = props.tagName,
			search = props.search,
			close = self.closeFunc,
			onHover = self.onHoverFunc,
		})
	end

	children.UIPadding = Roact_createElement("UIPadding", {
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	})

	return Roact_createElement(Page, {
		visible = props.tagName ~= nil,
		title = tostring(props.tagName) .. " - Select an Icon",
		titleIcon = props.tagIcon,

		close = props.close,
	}, {
		IconList = Roact_createElement(ScrollingFrame, {
			Size = UDim2.new(1, 0, 1, -64),
			Position = UDim2.fromOffset(0, 64),
			List = true,
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
						Size = UDim2.new(1, -56, 0, 40),
						Position = UDim2.fromOffset(56, 0),

						term = props.search,
						setTerm = props.setTerm,
					}),

					Preview = Roact_createElement(IconPreview, {
						Position = UDim2.fromOffset(8, 8),
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
				})
			end,
		}),
	})
end

local function mapStateToProps(state)
	local tagName = state.IconPicker
	local tagIcon
	for _, tag in pairs(state.TagData) do
		if tag.Name == tagName then
			tagIcon = tag.Icon
			break
		end
	end

	return {
		tagName = tagName,
		tagIcon = tagIcon,
		search = state.IconSearch,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.ToggleIconPicker(nil))
		end,

		setTerm = function(term)
			dispatch(Actions.SetIconSearch(term))
		end,

		setHoveredIcon = function(icon)
			dispatch(Actions.SetHoveredIcon(icon))
		end,
	}
end

IconPicker = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(IconPicker)

return IconPicker
