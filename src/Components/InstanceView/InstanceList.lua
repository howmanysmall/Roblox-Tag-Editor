local InstanceItem = require(script.Parent.InstanceItem)
local Page = require(script.Parent.Parent.Page)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local ScrollingFrame = require(script.Parent.Parent.ScrollingFrame)
local ThemedTextLabel = require(script.Parent.Parent.ThemedTextLabel)

local function InstanceList(props)
	local parts = props.parts
	local selected = props.selected

	local children = {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		}),

		InstanceCount = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			LayoutOrder = -1,
			BackgroundTransparency = 1,
		}, {
			Label = Roact.createElement(ThemedTextLabel, {
				Position = UDim2.new(0, 16, 0, 4),
				TextSize = 24,
				Text = string.format("Instance List (%d instances)", #parts),
				Font = Enum.Font.SourceSansLight,
			}),
		}),
	}

	for i, entry in ipairs(parts) do
		local part = entry.instance
		local id = entry.id
		local path = entry.path

		children[id] = Roact.createElement(InstanceItem, {
			LayoutOrder = i,
			Name = part.Name,
			ClassName = part.ClassName,
			Path = path,
			Instance = part,
			Selected = selected[part] ~= nil,
		})
	end

	return Roact.createElement(Page, {
		visible = props.tagName ~= nil,
		titleIcon = props.tagIcon,
		title = tostring(props.tagName),
		close = props.close,
	}, {
		Body = Roact.createElement(ScrollingFrame, {
			Size = UDim2.new(1, 0, 1, 0),
			List = {
				Padding = UDim.new(0, 1),
			},
		}, children),
	})
end

return InstanceList
