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

local TooltipView = Roact.Component:extend("TooltipView")

local ADDED_WIDTH = 40 or 79

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
					for i = #objTags, 1, -1 do
						if string.sub(objTags[i], 1, 1) == "." then
							table.remove(objTags, i)
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
			Part = part,
			Tags = tags,
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
		width = 200,
		height = 32,
	})

	self.lastContentSize = nil
end

function TooltipView:render()
	local props = self.props

	local children = {
		UIListLayout = Roact.createElement("UIListLayout", {
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
					Scheduler.Spawn(function()
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

		ObjectDesc = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			LayoutOrder = 0,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 4),
				[Roact.Ref] = self.nameRef,
			}),

			Margin = Roact.createElement("Frame", {
				Size = UDim2.new(0, 10, 1, 0),
				BackgroundTransparency = 1,
			}),

			InstanceClass = Roact.createElement(TextLabel, {
				Text = self.state.Part and self.state.Part.ClassName or "",
				LayoutOrder = 1,
				TextColor3 = Constants.VeryDarkGrey,
				Font = Enum.Font.SourceSansSemibold,
			}),

			InstanceName = Roact.createElement(TextLabel, {
				Text = self.state.Part and self.state.Part.Name or "",
				LayoutOrder = 2,
				Font = Enum.Font.SourceSansSemibold,
			}),
		}),
	}

	local tags = self.state.Tags or {}
	table.sort(tags)

	for _, tag in ipairs(tags) do
		local icon = "computer_error"
		for _, entry in pairs(props.tagData) do
			if entry.Name == tag then
				icon = entry.Icon or icon
				break
			end
		end

		children[tag] = Roact.createElement(Tag, {
			Tag = tag,
			Icon = icon,
		})
	end

	return Roact.createElement(Roact.Portal, {
		target = CoreGui,
	}, {
		TagEditorTooltip = Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}, {
			Window = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Visible = self.state.Part ~= false and props.worldView,

				[Roact.Ref] = function(rbx)
					if rbx then
						self.mouseSteppedConn = self:_runRunServiceEvent():Connect(function()
							local inset = GuiService:GetGuiInset()
							local pos = UserInputService:GetMouseLocation() - inset + Vector2.new(20, 0)
							rbx.Position = UDim2.new(0, pos.X, 0, pos.Y)
						end)
					else
						self.mouseSteppedConn:Disconnect()
					end
				end,
			}, {
				HorizontalDivider = Roact.createElement("Frame", {
					Size = UDim2.new(1, 2, 1, 0),
					Position = UDim2.new(0, -1, 0, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = TooltipGrey,
				}),

				VerticalDivider = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, 2),
					Position = UDim2.new(0, 0, 0, -1),
					BorderSizePixel = 0,
					BackgroundColor3 = TooltipGrey,
				}),

				Container = Roact.createElement("Frame", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Constants.White,
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
