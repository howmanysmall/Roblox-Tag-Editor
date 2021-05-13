local InstanceItem = require(script.Parent.InstanceItem)
local Page = require(script.Parent.Parent.Page)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local ScrollingFrame = require(script.Parent.Parent.ScrollingFrame)
local ThemedTextLabel = require(script.Parent.Parent.ThemedTextLabel)

local Roact_createElement = Roact.createElement

local function InstanceList(props)
	local parts = props.parts
	local selected = props.selected

	local children = {
		UIPadding = Roact_createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
			PaddingTop = UDim.new(0, 2),
		}),

		InstanceCount = Roact_createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = -1,
			Size = UDim2.new(1, 0, 0, 36),
		}, {
			Label = Roact_createElement(ThemedTextLabel, {
				Font = Enum.Font.SourceSansLight,
				Position = UDim2.fromOffset(16, 4),
				Text = string.format("Instance List (%d instances)", #parts),
				TextSize = 24,
			}),
		}),
	}

	for index, entry in ipairs(parts) do
		local part = entry.instance
		local id = entry.id
		local path = entry.path

		children[id] = Roact_createElement(InstanceItem, {
			ClassName = part.ClassName,
			Instance = part,
			LayoutOrder = index,
			Name = part.Name,
			Path = path,
			Selected = selected[part] ~= nil,
		})
	end

	return Roact_createElement(Page, {
		close = props.close,
		title = tostring(props.tagName),
		titleIcon = props.tagIcon,
		visible = props.tagName ~= nil,
	}, {
		Body = Roact_createElement(ScrollingFrame, {
			List = {
				Padding = UDim.new(0, 1),
			},

			Size = UDim2.fromScale(1, 1),
		}, children),
	})
end

return InstanceList
