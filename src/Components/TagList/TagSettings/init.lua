local Actions = require(script.Parent.Parent.Parent.Actions)
local Button = require(script.Parent.Parent.Button)
local Checkbox = require(script.Parent.Parent.Checkbox)
local DeleteButton = require(script.DeleteButton)
local Dropdown = require(script.Parent.Parent.Dropdown)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Vendor.RoactRodux)
local TagManager = require(script.Parent.Parent.Parent.TagManager)
local TextLabel = require(script.Parent.Parent.ThemedTextLabel)
local ThemeContext = require(script.Parent.Parent.ThemeContext)

local Roact_createElement = Roact.createElement

local function TagSettings(props)
	return Roact_createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		SideButtons = Roact_createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.4, 1),
		}, {
			Padding = Roact_createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
			}),

			Layout = Roact_createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),

			ChangeIcon = Roact_createElement(Button, {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Change icon",
				leftClick = function()
					props.iconPicker(props.tagMenu)
				end,
			}),

			ChangeGroup = Roact_createElement(Button, {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Change group",
				leftClick = function()
					props.groupPicker(props.tagMenu)
				end,
			}),

			TaggedInstances = Roact_createElement(Button, {
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Tagged instances",
				leftClick = function()
					props.instanceView(props.tagMenu)
				end,
			}),

			Delete = Roact_createElement(DeleteButton, {
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Delete",
				leftClick = function()
					TagManager.Get():DelTag(props.tagMenu)
					props.close()
				end,
			}),
		}),

		Visualization = Roact_createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -5, 0, 0),
			Size = UDim2.new(0.6, -10, 1, 0),
		}, {
			Padding = Roact_createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
			}),

			Layout = Roact_createElement("UIListLayout", {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Title = Roact_createElement(TextLabel, {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Tag Visualization",
				TextSize = 20,
			}),

			ChangeColor = Roact_createElement(Button, {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Change color",
				leftClick = function()
					props.colorPicker(props.tagMenu)
				end,
			}, {
				ColorVisualization = Roact_createElement(ThemeContext.Consumer, {
					render = function(theme)
						return Roact_createElement("Frame", {
							AnchorPoint = Vector2.new(1, 0.5),
							BackgroundColor3 = props.tagColor,
							BorderColor3 = theme.Border.Default,
							Position = UDim2.new(1, -5, 0.5, 0),
							Size = UDim2.new(1, -10, 1, -10),
						}, {
							ARConstraint = Roact_createElement("UIAspectRatioConstraint", {
								AspectRatio = 1,
								DominantAxis = Enum.DominantAxis.Height,
							}),
						})
					end,
				}),
			}),

			AlwaysOnTop = Roact_createElement("ImageButton", {
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Position = UDim2.fromOffset(0, 40),
				Size = UDim2.new(1, 0, 0, 30),
				[Roact.Event.MouseButton1Click] = function()
					TagManager.Get():SetAlwaysOnTop(props.tagMenu, not props.tagAlwaysOnTop)
				end,
			}, {
				Padding = Roact_createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5),
				}),

				Check = Roact_createElement(Checkbox, {
					Checked = props.tagAlwaysOnTop,
					leftClick = function()
						TagManager.Get():SetAlwaysOnTop(props.tagMenu, not props.tagAlwaysOnTop)
					end,
				}),

				Label = Roact_createElement(TextLabel, {
					Position = UDim2.fromOffset(30, 0),
					Size = UDim2.new(1, -30, 1, 0),
					Text = "Always on top",
					TextSize = 16,
				}),
			}),

			VisualizationKind = Roact_createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, 30),
			}, {
				Layout = Roact_createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				Label = Roact_createElement(TextLabel, {
					LayoutOrder = 1,
					Text = "Visualize as:",
					TextSize = 16,
				}),

				Dropdown = Roact_createElement(Dropdown, {
					CurrentOption = props.tagDrawType,
					LayoutOrder = 2,
					Options = {"None", "Icon", "Outline", "Box", "Sphere", "Text"},
					Size = UDim2.new(1, -75, 0, 30),
					onOptionSelected = function(option)
						TagManager.Get():SetDrawType(props.tagMenu, option)
					end,
				}),
			}),
		}),
	})
end

local function mapStateToProps(state)
	local icon
	local drawType
	local color
	local alwaysOnTop = false
	for _, v in ipairs(state.TagData) do
		if v.Name == state.TagMenu then
			icon = v.Icon
			drawType = v.DrawType or "Box"
			color = v.Color
			alwaysOnTop = v.AlwaysOnTop
		end
	end

	return {
		tagAlwaysOnTop = alwaysOnTop,
		tagColor = color,
		tagDrawType = drawType,
		tagIcon = icon or "tag_green",
		tagMenu = state.TagMenu,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.OpenTagMenu(nil))
		end,

		colorPicker = function(tagMenu)
			dispatch(Actions.ToggleColorPicker(tagMenu))
		end,

		groupPicker = function(tagMenu)
			dispatch(Actions.ToggleGroupPicker(tagMenu))
		end,

		iconPicker = function(tagMenu)
			dispatch(Actions.ToggleIconPicker(tagMenu))
		end,

		instanceView = function(tagMenu)
			dispatch(Actions.OpenInstanceView(tagMenu))
		end,
	}
end

TagSettings = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(TagSettings)

return TagSettings
