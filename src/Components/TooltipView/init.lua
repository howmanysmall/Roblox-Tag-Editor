local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Constants = require(script.Parent.Parent.Constants)
local Roact = require(script.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Vendor.RoactRodux)
local Scheduler = require(script.Parent.Parent.Scheduler)
local Tag = require(script.Tag)
local TextLabel = require(script.Parent.TextLabel)

local TooltipGrey = Color3.fromRGB(238, 238, 238)

local TooltipView = Roact.PureComponent:extend("TooltipView")

local ADDED_WIDTH = 40 or 79

local Roact_createElement = Roact.createElement
local Scheduler_Spawn = Scheduler.Spawn

function TooltipView:didMount()
	self.mouseSunk = false
	self.steppedConn = self:_runRunServiceEvent():Connect(function()
		local camera = Workspace.CurrentCamera
		local part = false
		local tags = {}
		if camera and not self.mouseSunk then
			local mouse = UserInputService:GetMouseLocation()
			local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
			local origin, direction = ray.Origin, ray.Direction.Unit * 1000

			local ignore = {}
			local parameters = RaycastParams.new()
			parameters.FilterType = Enum.RaycastFilterType.Blacklist
			parameters.FilterDescendantsInstances = ignore

			for _ = 1, 10 do
				local objResult = Workspace:Raycast(origin, direction, parameters)
				local obj = objResult and objResult.Instance
				local objTags = obj and CollectionService:GetTags(obj)

				if objTags then
					for index = #objTags, 1, -1 do
						if string.sub(objTags[index], 1, 1) == "." then
							table.remove(objTags, index)
						end
					end
				end

				--- @type Instance
				local model = obj and obj.Parent and obj.Parent:IsA("Model") and obj.Parent
				local modelTags = model and CollectionService:GetTags(model)
				if objTags and #objTags > 0 then
					part = obj
					tags = objTags
					break
				elseif modelTags and #modelTags > 0 then
					part = model
					tags = modelTags
					break
				elseif obj and obj:IsA("Part") and obj.Transparency >= 0.9 then
					table.insert(ignore, obj)
					parameters.FilterDescendantsInstances = ignore
				else
					break
				end
			end
		end

		self:setState({
			part = part,
			tags = tags,
		})
	end)

	self.inputChangedConn = UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self.mouseSunk = gameProcessed
		end
	end)
end

function TooltipView:willUnmount()
	self.steppedConn:Disconnect()
	self.inputChangedConn:Disconnect()
end

function TooltipView:init()
	self.nameRef = Roact.createRef()
	self:setState({
		height = 32,
		width = 200,
	})

	self.lastContentSize = nil
end

function TooltipView:render()
	local props = self.props
	local state = self.state

	local children = {
		UIListLayout = Roact_createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,

			[Roact.Change.AbsoluteContentSize] = function(rbx)
				local absoluteContentSize = rbx.AbsoluteContentSize
				local skipCheck = false
				if not self.lastContentSize then
					self.lastContentSize = absoluteContentSize
					skipCheck = true
				end

				if not skipCheck and self.lastContentSize == absoluteContentSize then
					return
				end

				if rbx.Parent and rbx.Parent.Parent then
					--- @type UIListLayout
					local nameRef = self.nameRef:getValue()
					Scheduler_Spawn(function()
						if nameRef then
							rbx.Parent.Parent.Size = UDim2.fromOffset(math.max(nameRef.AbsoluteContentSize.X + ADDED_WIDTH, 200), absoluteContentSize.Y)
						else
							rbx.Parent.Parent.Size = UDim2.fromOffset(200, absoluteContentSize.Y)
						end

						self.lastContentSize = absoluteContentSize
					end)
				end
			end,
		}),

		ObjectDesc = Roact_createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 0,
			Size = UDim2.new(1, 0, 0, 32),
		}, {
			UIListLayout = Roact_createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				[Roact.Ref] = self.nameRef,
			}),

			Margin = Roact_createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 10, 1, 0),
			}),

			InstanceClass = Roact_createElement(TextLabel, {
				Font = Enum.Font.SourceSansSemibold,
				LayoutOrder = 1,
				Text = state.part and state.part.ClassName or "",
				TextColor3 = Constants.VeryDarkGrey,
			}),

			InstanceName = Roact_createElement(TextLabel, {
				Font = Enum.Font.SourceSansSemibold,
				LayoutOrder = 2,
				Text = state.part and state.part.Name or "",
			}),
		}),
	}

	local tags = state.tags or {}
	table.sort(tags)

	for _, tag in ipairs(tags) do
		local icon = "computer_error"
		for _, entry in ipairs(props.tagData) do
			if entry.Name == tag then
				icon = entry.Icon or icon
				break
			end
		end

		children[tag] = Roact_createElement(Tag, {
			Icon = icon,
			Tag = tag,
		})
	end

	return Roact_createElement(Roact.Portal, {
		target = CoreGui,
	}, {
		TagEditorTooltip = Roact_createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}, {
			Window = Roact_createElement("Frame", {
				BackgroundTransparency = 1,
				Visible = state.part ~= false and props.worldView,

				[Roact.Ref] = function(rbx)
					if rbx then
						self.mouseSteppedConn = self:_runRunServiceEvent():Connect(function()
							local guiInset = GuiService:GetGuiInset()
							local position = UserInputService:GetMouseLocation() - guiInset + Vector2.new(20, 0)
							rbx.Position = UDim2.fromOffset(position.X, position.Y)
						end)
					else
						self.mouseSteppedConn:Disconnect()
					end
				end,
			}, {
				HorizontalDivider = Roact_createElement("Frame", {
					BackgroundColor3 = TooltipGrey,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(-1, 0),
					Size = UDim2.new(1, 2, 1, 0),
				}),

				VerticalDivider = Roact_createElement("Frame", {
					BackgroundColor3 = TooltipGrey,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, -1),
					Size = UDim2.new(1, 0, 1, 2),
				}),

				Container = Roact_createElement("Frame", {
					BackgroundColor3 = Constants.White,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 2,
				}, children),
			}),
		}),
	})
end

--- RenderStepped errors out in Start Server, so bind to stepped if we can't bind to RenderStepped
function TooltipView:_runRunServiceEvent()
	if RunService:IsClient() then
		return RunService.RenderStepped
	else
		return RunService.Stepped
	end
end

local function mapStateToProps(state)
	return {
		tagData = state.TagData,
		worldView = state.WorldView,
	}
end

TooltipView = RoactRodux.connect(mapStateToProps)(TooltipView)

return TooltipView
