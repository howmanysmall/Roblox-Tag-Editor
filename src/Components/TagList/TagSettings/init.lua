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

local function TagSettings(props)
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	}, {
		SideButtons = Roact.createElement("Frame", {
			Size = UDim2.new(0.4, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
			}),

			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 5),
			}),

			ChangeIcon = Roact.createElement(Button, {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Change icon",
				leftClick = function()
					props.iconPicker(props.tagMenu)
				end,
			}),

			ChangeGroup = Roact.createElement(Button, {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Change group",
				leftClick = function()
					props.groupPicker(props.tagMenu)
				end,
			}),

			TaggedInstances = Roact.createElement(Button, {
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Tagged instances",
				leftClick = function()
					props.instanceView(props.tagMenu)
				end,
			}),

			Delete = Roact.createElement(DeleteButton, {
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Delete",
				leftClick = function()
					TagManager.Get():DelTag(props.tagMenu)
					props.close()
				end,
			}),
		}),

		Visualization = Roact.createElement("Frame", {
			Size = UDim2.new(0.6, -10, 1, 0),
			Position = UDim2.new(1, -5, 0, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
			}),

			Layout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Title = Roact.createElement(TextLabel, {
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = 1,
				Text = "Tag Visualization",
				TextSize = 20,
			}),

			ChangeColor = Roact.createElement(Button, {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "Change color",
				leftClick = function()
					props.colorPicker(props.tagMenu)
				end,
			}, {
				ColorVisualization = Roact.createElement(ThemeContext.Consumer, {
					render = function(theme)
						return Roact.createElement("Frame", {
							Size = UDim2.new(1, -10, 1, -10),
							Position = UDim2.new(1, -5, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),
							BackgroundColor3 = props.tagColor,
							BorderColor3 = theme.Border.Default,
						}, {
							ARConstraint = Roact.createElement("UIAspectRatioConstraint", {
								AspectRatio = 1,
								DominantAxis = Enum.DominantAxis.Height,
							}),
						})
					end,
				}),
			}),

			AlwaysOnTop = Roact.createElement("ImageButton", {
				LayoutOrder = 3,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 30),
				Position = UDim2.new(0, 0, 0, 40),
				[Roact.Event.MouseButton1Click] = function()
					TagManager.Get():SetAlwaysOnTop(props.tagMenu, not props.tagAlwaysOnTop)
				end,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5),
				}),

				Check = Roact.createElement(Checkbox, {
					Checked = props.tagAlwaysOnTop,
					leftClick = function()
						TagManager.Get():SetAlwaysOnTop(props.tagMenu, not props.tagAlwaysOnTop)
					end,
				}),

				Label = Roact.createElement(TextLabel, {
					Size = UDim2.new(1, -30, 1, 0),
					Position = UDim2.new(0, 30, 0, 0),
					Text = "Always on top",
					TextSize = 16,
				}),
			}),

			VisualizationKind = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				LayoutOrder = 4,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 5),
				}),

				Label = Roact.createElement(TextLabel, {
					Text = "Visualize as:",
					LayoutOrder = 1,
					TextSize = 16,
				}),

				Dropdown = Roact.createElement(Dropdown, {
					LayoutOrder = 2,
					Size = UDim2.new(1, -75, 0, 30),
					Options = {"None", "Icon", "Outline", "Box", "Sphere", "Text"},
					CurrentOption = props.tagDrawType,
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
	for _, v in pairs(state.TagData) do
		if v.Name == state.TagMenu then
			icon = v.Icon
			drawType = v.DrawType or "Box"
			color = v.Color
			alwaysOnTop = v.AlwaysOnTop
		end
	end

	return {
		tagMenu = state.TagMenu,
		tagIcon = icon or "tag_green",
		tagColor = color,
		tagDrawType = drawType,
		tagAlwaysOnTop = alwaysOnTop,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.OpenTagMenu(nil))
		end,

		iconPicker = function(tagMenu)
			dispatch(Actions.ToggleIconPicker(tagMenu))
		end,

		colorPicker = function(tagMenu)
			dispatch(Actions.ToggleColorPicker(tagMenu))
		end,

		groupPicker = function(tagMenu)
			dispatch(Actions.ToggleGroupPicker(tagMenu))
		end,

		instanceView = function(tagMenu)
			dispatch(Actions.OpenInstanceView(tagMenu))
		end,
	}
end

TagSettings = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(TagSettings)

return TagSettings
