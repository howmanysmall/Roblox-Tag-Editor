local InstanceItem = require(script.Parent.InstanceItem)
local Page = require(script.Parent.Parent.Page)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local ScrollingFrame = require(script.Parent.Parent.ScrollingFrame)
local ThemedTextLabel = require(script.Parent.Parent.ThemedTextLabel)

local Logger = require(script.Parent.Parent.Parent.Utility.Logger)

local ENABLED = true

local Roact_createElement = Roact.createElement
local InstanceListLogger = Logger.new("InstanceListLogger"):SetEnabled(ENABLED)

local function InstanceList(props)
	InstanceListLogger:Debug("InstanceList.props: {:?}", props)
	local parts = props.parts
	local selected = props.selected

	local children = {
		UIPadding = Roact_createElement("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		}),

		InstanceCount = Roact_createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			LayoutOrder = -1,
			BackgroundTransparency = 1,
		}, {
			Label = Roact_createElement(ThemedTextLabel, {
				Position = UDim2.fromOffset(16, 4),
				TextSize = 24,
				Text = string.format("Instance List (%d instances)", #parts),
				Font = Enum.Font.SourceSansLight,
			}),
		}),
	}

	for index, entry in ipairs(parts) do
		local part = entry.instance
		local id = entry.id
		local path = entry.path

		children[id] = Roact_createElement(InstanceItem, {
			LayoutOrder = index,
			Name = part.Name,
			ClassName = part.ClassName,
			Path = path,
			Instance = part,
			Selected = selected[part] ~= nil,
		})
	end

	return Roact_createElement(Page, {
		visible = props.tagName ~= nil,
		titleIcon = props.tagIcon,
		title = tostring(props.tagName),
		close = props.close,
	}, {
		Body = Roact_createElement(ScrollingFrame, {
			Size = UDim2.fromScale(1, 1),
			List = {
				Padding = UDim.new(0, 1),
			},
		}, children),
	})
end

return InstanceList
