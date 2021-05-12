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

function App:init()
	self._rootRef = Roact.createRef()
	self._context[rootKey] = self._rootRef
end

function App:render()
	return Roact.createElement(ThemeController, {}, {
		MainApp = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			[Roact.Ref] = self._rootRef,
		}, {
			Background = Roact.createElement(ThemeContext.Consumer, {
				render = function(theme)
					return Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = theme.MainBackground.Default,
						ZIndex = -100,
					})
				end,
			}),

			Container = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,

					-- hack :(
					[Roact.Ref] = function(rbx)
						if rbx then
							Scheduler.Spawn(function()
								Scheduler.Wait(0.03)
								Scheduler.Wait(0.03)
								rbx:ApplyLayout()
							end)
						end
					end,
				}),

				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
				}),

				TagList = Roact.createElement(TagList, {
					Size = UDim2.new(1, 0, 1, -40),
				}),

				TagSearch = Roact.createElement(TagSearch, {
					Size = UDim2.new(1, 0, 0, 40),
				}),
			}),

			InstanceView = Roact.createElement(InstanceView),
			GroupPicker = Roact.createElement(GroupPicker),
			IconPicker = Roact.createElement(IconPicker),
			ColorPicker = Roact.createElement(ColorPicker),
			WorldView = Roact.createElement(WorldView),
			TooltipView = Roact.createElement(TooltipView),
		}),
	})
end

return App
