local Icon = require(script.Parent.Parent.Icon)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local Scheduler = require(script.Parent.Parent.Parent.Scheduler)
local TagManager = require(script.Parent.Parent.Parent.TagManager)
local ThemedTextLabel = require(script.Parent.Parent.ThemedTextLabel)

local function matchesSearch(term, subject)
	if not term then
		return true
	end

	return string.find(subject, term) ~= nil
end

local Category = Roact.PureComponent:extend("Category")

local Roact_createElement = Roact.createElement
local Scheduler_Spawn = Scheduler.Spawn

function Category:render()
	local cellSize = 24
	local props = self.props

	local children = {
		UIGridLayout = Roact_createElement("UIGridLayout", {
			CellSize = UDim2.fromOffset(cellSize, cellSize),
			CellPadding = UDim2.new(),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	local numMatched = 0
	for index, icon in ipairs(props.Icons) do
		local matches = matchesSearch(props.search, icon)
		if matches then
			numMatched += 1
		end

		children[icon] = Roact_createElement("TextButton", {
			BackgroundTransparency = 1,
			LayoutOrder = index,
			Text = "",
			Visible = matches,
			[Roact.Event.MouseButton1Click] = function()
				TagManager.Get():SetIcon(props.tagName, icon)
				props.close()
			end,

			[Roact.Event.MouseEnter] = function(rbx)
				self._enteredButton = rbx
				props.onHover(icon)
			end,

			[Roact.Event.MouseLeave] = function(rbx)
				if self._enteredButton == rbx then
					props.onHover(nil)
					self._enteredButton = nil
				end
			end,
		}, {
			Icon = Roact_createElement(Icon, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Name = icon,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(16, 16),
			}),
		})
	end

	return Roact_createElement("Frame", {
		Size = UDim2.fromScale(1, 0),
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,
		Visible = numMatched > 0,
	}, {
		Label = Roact_createElement(ThemedTextLabel, {
			Text = props.CategoryName,
			Size = UDim2.new(1, 0, 0, 20),
			Font = Enum.Font.SourceSansSemibold,
		}),

		Body = Roact_createElement("Frame", {
			Size = UDim2.fromScale(1, 0),
			Position = UDim2.fromOffset(0, 20),
			BackgroundTransparency = 1,

			[Roact.Change.AbsoluteSize] = function(rbx)
				Scheduler_Spawn(function()
					local stride = cellSize
					local epsilon = 0.001
					local w = math.floor(rbx.AbsoluteSize.X / stride + epsilon)
					local h = math.ceil(numMatched / w)

					rbx.Size = UDim2.new(1, 0, 0, h * stride)
					if rbx.Parent then
						rbx.Parent.Size = UDim2.new(1, 0, 0, h * stride + 24)
					end
				end)
			end,
		}, children),
	})
end

return Category
