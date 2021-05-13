local Actions = require(script.Parent.Parent.Actions)
local Constants = require(script.Parent.Parent.Constants)
local Group = require(script.Group)
local Item = require(script.Parent.ListItem)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local Tag = require(script.Tag)
local TagManager = require(script.Parent.Parent.TagManager)

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

local TagList = Roact.PureComponent:extend("TagList")
TagList.defaultProps = {
	Size = UDim2.fromScale(1, 1),
}

local Roact_createElement = Roact.createElement

function TagList:render()
	local props = self.props

	local function toggleGroup(group)
		self:setState({
			["Hide" .. group] = not self.state["Hide" .. group],
		})
	end

	local tags = props.Tags
	table.sort(tags, function(a, b)
		local ag = a.Group or ""
		local bg = b.Group or ""
		if ag < bg then
			return true
		end

		if bg < ag then
			return false
		end

		local an = a.Name or ""
		local bn = b.Name or ""

		return an < bn
	end)

	local children = {
		UIListLayout = Roact_createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 1),

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

				update()
				rbx:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
			end,
		}),
	}

	local lastGroup
	local itemCount = 1
	for _, tag in ipairs(tags) do
		local groupName = tag.Group or "Default"
		if tag.Group ~= lastGroup then
			lastGroup = tag.Group
			children["Group" .. groupName] = Roact_createElement(Group, {
				Name = groupName,
				LayoutOrder = itemCount,
				toggleHidden = toggleGroup,
				Hidden = self.state["Hide" .. groupName],
			})

			itemCount = itemCount + 1
		end

		children[tag.Name] = Roact_createElement(Tag, merge(tag, {
			Hidden = self.state["Hide" .. groupName],
			Tag = tag.Name,
			LayoutOrder = itemCount,
		}))

		itemCount = itemCount + 1
	end

	for _, tag in ipairs(props.unknownTags) do
		children[tag] = Roact_createElement(Item, {
			Text = string.format("%s (click to import)", tag),
			Icon = "help",
			ButtonColor = Constants.LightRed,
			LayoutOrder = itemCount,
			TextProps = {
				Font = Enum.Font.SourceSansItalic,
			},

			leftClick = function()
				TagManager.Get():AddTag(tag)
			end,
		})

		itemCount = itemCount + 1
	end

	if #tags == 0 then
		children.NoResults = Roact_createElement(Item, {
			LayoutOrder = itemCount,
			Text = "No search results found.",
			Icon = "cancel",
			TextProps = {
				Font = Enum.Font.SourceSansItalic,
			},
		})

		itemCount = itemCount + 1
	end

	local searchTagExists = table.find(tags, props.searchTerm) ~= nil
	if props.searchTerm and #props.searchTerm > 0 and not searchTagExists then
		children.AddNew = Roact_createElement(Item, {
			LayoutOrder = itemCount,
			Text = string.format("Add tag %q...", props.searchTerm),
			Icon = "tag_blue_add",

			leftClick = function()
				TagManager.Get():AddTag(props.searchTerm)
				props.setSearch("")
			end,
		})
	else
		children.AddNew = Roact_createElement(Item, {
			LayoutOrder = itemCount,
			Text = "Add new tag...",
			Icon = "tag_blue_add",
			IsInput = true,

			onSubmit = function(_, text)
				TagManager.Get():AddTag(text)
			end,
		})
	end

	return Roact_createElement(ScrollingFrame, {
		Size = props.Size,
	}, children)
end

local function mapStateToProps(state)
	local tags = {}
	local search = state.Search

	for _, tag in ipairs(state.TagData) do
		-- todo: LCS
		local passSearch = not search or string.find(string.lower(tag.Name), string.lower(search))
		if passSearch then
			table.insert(tags, tag)
		end
	end

	local unknownTags = {}
	for _, tag in ipairs(state.UnknownTags) do
		-- todo: LCS
		local passSearch = not search or string.find(string.lower(tag), string.lower(search))
		if passSearch then
			table.insert(unknownTags, tag)
		end
	end

	return {
		Tags = tags,
		searchTerm = state.Search,
		menuOpen = state.TagMenu,
		unknownTags = unknownTags,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setSearch = function(term)
			dispatch(Actions.SetSearch(term))
		end,
	}
end

TagList = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(TagList)

return TagList
