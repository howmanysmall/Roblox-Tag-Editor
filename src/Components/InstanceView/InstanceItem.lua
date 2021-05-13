local Selection = game:GetService("Selection")
local UserInputService = game:GetService("UserInputService")

local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local ThemedTextLabel = require(script.Parent.Parent.ThemedTextLabel)
local ListItemChrome = require(script.Parent.Parent.ListItemChrome)

local InstanceItem = Roact.PureComponent:extend("InstanceItem")

local Roact_createElement = Roact.createElement

local function isDown(key)
	return UserInputService:IsKeyDown(Enum.KeyCode[key])
end

function InstanceItem:render()
	local props = self.props
	local state = "Default"

	if props.Selected then
		state = "Selected"
	elseif self.state.hover then
		state = "Hover"
	end

	return Roact_createElement(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		state = state,

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

		leftClick = function()
			local currentSelection = Selection:Get()
			local alreadySelected = table.find(currentSelection, props.Instance) ~= nil

			if alreadySelected then
				if #currentSelection > 1 then
					-- select only this
					Selection:Set({props.Instance})
				else
					-- deselect
					local baseSel = {}
					for _, instance in ipairs(currentSelection) do
						if instance ~= props.Instance then
							table.insert(baseSel, instance)
						end
					end

					Selection:Set(baseSel)
				end
			else
				-- select
				local baseSel = {}
				if isDown("LeftControl") or isDown("RightControl") or isDown("LeftShift") or isDown("RightShift") then
					baseSel = currentSelection
				end

				table.insert(baseSel, props.Instance)
				Selection:Set(baseSel)
			end
		end,
	}, {
		Container = Roact_createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIPadding = Roact_createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 12),
			}),

			UIListLayout = Roact_createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			InstanceClass = Roact_createElement(ThemedTextLabel, {
				LayoutOrder = 1,
				Text = props.ClassName,
				TextSize = 16,

				object = "DimmedText",
				state = state,
			}),

			InstanceName = Roact_createElement(ThemedTextLabel, {
				LayoutOrder = 2,
				Text = props.Name,
				state = state,
			}),

			Path = Roact_createElement(ThemedTextLabel, {
				Font = Enum.Font.SourceSansItalic,
				LayoutOrder = 3,
				Text = props.Path,
				TextSize = 16,
				state = state,
			}),
		}),
	})
end

return InstanceItem
