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

function Category:render()
	local cellSize = 24
	local props = self.props
	local children = {
		UIGridLayout = Roact.createElement("UIGridLayout", {
			CellSize = UDim2.new(0, cellSize, 0, cellSize),
			CellPadding = UDim2.new(),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	local numMatched = 0
	for i, icon in pairs(props.Icons) do
		local matches = matchesSearch(props.search, icon)
		if matches then
			numMatched = numMatched + 1
		end

		children[icon] = Roact.createElement("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Visible = matches,
			LayoutOrder = i,
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
			Icon = Roact.createElement(Icon, {
				Name = icon,
				Size = UDim2.new(0, 16, 0, 16),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
			}),
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,
		Visible = numMatched > 0,
	}, {
		Label = Roact.createElement(ThemedTextLabel, {
			Text = props.CategoryName,
			Size = UDim2.new(1, 0, 0, 20),
			Font = Enum.Font.SourceSansSemibold,
		}),

		Body = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 20),
			BackgroundTransparency = 1,

			[Roact.Change.AbsoluteSize] = function(rbx)
				Scheduler.Spawn(function()
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
