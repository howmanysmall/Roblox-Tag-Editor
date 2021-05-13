local ColorPicker = require(script.Parent.ColorPicker)
local GroupPicker = require(script.Parent.GroupPicker)
local IconPicker = require(script.Parent.IconPicker)
local InstanceView = require(script.Parent.InstanceView)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local Scheduler = require(script.Parent.Parent.Scheduler)
local TagList = require(script.Parent.TagList)
local TagSearch = require(script.Parent.TagSearch)
local ThemeContext = require(script.Parent.ThemeContext)
local ThemeController = require(script.Parent.ThemeController)
local TooltipView = require(script.Parent.TooltipView)
local WorldView = require(script.Parent.WorldView)

local rootKey = require(script.Parent.rootKey)

local App = Roact.PureComponent:extend("App")

local Roact_createElement = Roact.createElement
local Scheduler_Spawn = Scheduler.Spawn
local Scheduler_Wait = Scheduler.Wait

function App:init()
	self._rootRef = Roact.createRef()
	self._context[rootKey] = self._rootRef
end

function App:render()
	return Roact_createElement(ThemeController, {}, {
		MainApp = Roact_createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			[Roact.Ref] = self._rootRef,
		}, {
			Background = Roact_createElement(ThemeContext.Consumer, {
				render = function(theme)
					return Roact_createElement("Frame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = theme.MainBackground.Default,
						ZIndex = -100,
					})
				end,
			}),

			Container = Roact_createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				UIListLayout = Roact_createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,

					-- hack :(
					[Roact.Ref] = function(rbx)
						if rbx then
							Scheduler_Spawn(function()
								Scheduler_Wait(0.03)
								Scheduler_Wait(0.03)
								rbx:ApplyLayout()
							end)
						end
					end,
				}),

				UIPadding = Roact_createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
				}),

				TagList = Roact_createElement(TagList, {
					Size = UDim2.new(1, 0, 1, -40),
				}),

				TagSearch = Roact_createElement(TagSearch, {
					Size = UDim2.new(1, 0, 0, 40),
				}),
			}),

			InstanceView = Roact_createElement(InstanceView),
			GroupPicker = Roact_createElement(GroupPicker),
			IconPicker = Roact_createElement(IconPicker),
			ColorPicker = Roact_createElement(ColorPicker),
			WorldView = Roact_createElement(WorldView),
			TooltipView = Roact_createElement(TooltipView),
		}),
	})
end

return App
