local Selection = game:GetService("Selection")
local UserInputService = game:GetService("UserInputService")

local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local ThemedTextLabel = require(script.Parent.Parent.ThemedTextLabel)
local ListItemChrome = require(script.Parent.Parent.ListItemChrome)

local InstanceItem = Roact.Component:extend("InstanceItem")

function InstanceItem:render()
	local props = self.props
	local state = "Default"

	if props.Selected then
		state = "Selected"
	elseif self.state.hover then
		state = "Hover"
	end

	return Roact.createElement(ListItemChrome, {
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
			local sel = Selection:Get()
			local alreadySelected = table.find(sel, props.Instance) ~= nil

			if alreadySelected then
				if #sel > 1 then
					-- select only this
					Selection:Set({props.Instance})
				else
					-- deselect
					local baseSel = {}
					for _, instance in pairs(sel) do
						if instance ~= props.Instance then
							table.insert(baseSel, instance)
						end
					end

					Selection:Set(baseSel)
				end
			else
				-- select
				local baseSel = {}
				local function isDown(key)
					return UserInputService:IsKeyDown(Enum.KeyCode[key])
				end

				if isDown("LeftControl") or isDown("RightControl") or isDown("LeftShift") or isDown("RightShift") then
					baseSel = sel
				end

				table.insert(baseSel, props.Instance)
				Selection:Set(baseSel)
			end
		end,
	}, {
		Container = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 12),
			}),

			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
			}),

			InstanceClass = Roact.createElement(ThemedTextLabel, {
				object = "DimmedText",
				state = state,
				TextSize = 16,
				Text = props.ClassName,
				LayoutOrder = 1,
			}),

			InstanceName = Roact.createElement(ThemedTextLabel, {
				state = state,
				Text = props.Name,
				LayoutOrder = 2,
			}),

			Path = Roact.createElement(ThemedTextLabel, {
				Font = Enum.Font.SourceSansItalic,
				state = state,
				Text = props.Path,
				LayoutOrder = 3,
				TextSize = 16,
			}),
		}),
	})
end

return InstanceItem
