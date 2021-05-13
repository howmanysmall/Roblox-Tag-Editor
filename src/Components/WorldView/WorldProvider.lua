local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local Janitor = require(script.Parent.Parent.Parent.Vendor.Janitor)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local TagManager = require(script.Parent.Parent.Parent.TagManager)

local WorldProvider = Roact.PureComponent:extend("WorldProvider")

local Roact_oneChild = Roact.oneChild

function WorldProvider:init()
	self:setState({
		partsList = {},
	})

	self.nextId = 0
	self.partIds = {}
	self.trackedParts = {}
	self.trackedTags = {}
	self.instanceAddedConns = Janitor.new()
	self.instanceRemovedConns = Janitor.new()
	self.instanceAncestryChangedConns = Janitor.new()
	self.janitor = Janitor.new()

	local function cameraAdded(camera)
		self.janitor:Remove("cameraMovedConn")
		if camera then
			local origPos = camera.CFrame.Position
			self.janitor:Add(camera:GetPropertyChangedSignal("CFrame"):Connect(function()
				local newPos = camera.CFrame.Position
				if (origPos - newPos).Magnitude > 50 then
					origPos = newPos
					self:updateParts()
				end
			end), "Disconnect", "cameraMovedConn")
		end
	end

	self.janitor:Add(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cameraAdded), "Disconnect", "cameraChangedConn")
	cameraAdded(Workspace.CurrentCamera)
end

function WorldProvider:didMount()
	local manager = TagManager.Get()

	for name in pairs(manager:GetTags()) do
		self:tagAdded(name)
	end

	self.onTagAddedConn = manager:OnTagAdded(function(name)
		if manager.tags[name].Visible ~= false and manager.tags[name].DrawType ~= "None" then
			self:tagAdded(name)
			self:updateParts()
		end
	end)

	self.onTagRemovedConn = manager:OnTagRemoved(function(name)
		if manager.tags[name].Visible ~= false and manager.tags[name].DrawType ~= "None" then
			self:tagRemoved(name)
			self:updateParts()
		end
	end)

	self.onTagChangedConn = manager:OnTagChanged(function(name)
		local tag = manager.tags[name]
		local wasVisible = self.trackedTags[name] ~= nil
		local nowVisible = tag.DrawType ~= "None" and tag.Visible ~= false

		if nowVisible and not wasVisible then
			self:tagAdded(name)
		elseif wasVisible and not nowVisible then
			self:tagRemoved(name)
		end

		self:updateParts()
	end)

	self:updateParts()
end

local function sortedInsert(array, value, lessThan)
	local start = 1
	local stop = #array

	while stop - start > 1 do
		local pivot = math.floor(start + (stop - start) / 2)
		if lessThan(value, array[pivot]) then
			stop = pivot
		else
			start = pivot + 1
		end
	end

	table.insert(array, start, value)
end

function WorldProvider:updateParts()
	debug.profilebegin("[Tag Editor] Update WorldProvider")
	local currentCamera = Workspace.CurrentCamera
	if not currentCamera then
		return
	end

	local camPos = currentCamera.CFrame.Position
	local function sortFunc(a, b)
		return a.AngularSize > b.AngularSize
	end

	local function partAngularSize(pos, size)
		local dist = (pos - camPos).Magnitude
		local sizeM = size.Magnitude
		return sizeM / dist
	end

	local newList = {}

	for obj in pairs(self.trackedParts) do
		local class = obj.ClassName
		if class == "Model" then
			local primary = obj.PrimaryPart
			if not primary then
				for _, child in ipairs(obj:GetChildren()) do
					if child:IsA("BasePart") then
						primary = child
						break
					end
				end
			end

			if primary then
				local entry = {
					AngularSize = partAngularSize(primary.Position, obj:GetExtentsSize()),
					Instance = obj,
				}

				sortedInsert(newList, entry, sortFunc)
			end
		elseif class == "Attachment" then
			local entry = {
				AngularSize = partAngularSize(obj.WorldPosition, Vector3.new()),
				Instance = obj,
			}

			sortedInsert(newList, entry, sortFunc)
		else -- assume part
			local entry = {
				AngularSize = partAngularSize(obj.Position, obj.Size),
				Instance = obj,
			}

			sortedInsert(newList, entry, sortFunc)
		end

		local size = #newList
		while size > 500 do
			newList[size] = nil
			size -= 1
		end
	end

	local adornMap = {}
	for _, new in ipairs(newList) do
		local tags = CollectionService:GetTags(new.Instance)
		local outlines = {}
		local outlinesLength = 0

		local boxes = {}
		local boxesLength = 0

		local icons = {}
		local iconsLength = 0

		local labels = {}
		local labelsLength = 0

		local spheres = {}
		local spheresLength = 0

		local anyAlwaysOnTop = false

		for _, tagName in ipairs(tags) do
			local tag = TagManager.Get().tags[tagName]
			if self.trackedTags[tagName] and tag then
				if tag.DrawType == "Outline" then
					outlinesLength += 1
					outlines[outlinesLength] = tag.Color
				elseif tag.DrawType == "Box" then
					boxesLength += 1
					boxes[boxesLength] = tag.Color
				elseif tag.DrawType == "Icon" then
					iconsLength += 1
					icons[iconsLength] = tag.Icon
				elseif tag.DrawType == "Text" then
					labelsLength += 1
					labels[labelsLength] = tagName
				elseif tag.DrawType == "Sphere" then
					spheresLength += 1
					spheres[spheresLength] = tag.Color
				end

				if tag.AlwaysOnTop then
					anyAlwaysOnTop = true
				end
			end
		end

		local partId = self.partIds[new.Instance]

		if outlinesLength > 0 then
			local r, g, b = 0, 0, 0
			for _, outline in ipairs(outlines) do
				r += outline.R
				g += outline.G
				b += outline.B
			end

			r /= outlinesLength
			g /= outlinesLength
			b /= outlinesLength
			local avg = Color3.new(r, g, b)
			adornMap["Outline:" .. partId] = {
				AlwaysOnTop = anyAlwaysOnTop,
				Color = avg,
				DrawType = "Outline",
				Id = partId,
				Part = new.Instance,
			}
		end

		if boxesLength > 0 then
			local r, g, b = 0, 0, 0
			for _, box in ipairs(boxes) do
				r += box.R
				g += box.G
				b += box.B
			end

			r /= boxesLength
			g /= boxesLength
			b /= boxesLength
			local avg = Color3.new(r, g, b)
			adornMap["Box:" .. partId] = {
				AlwaysOnTop = anyAlwaysOnTop,
				Color = avg,
				DrawType = "Box",
				Id = partId,
				Part = new.Instance,
			}
		end

		if outlinesLength > 0 then
			adornMap["Icon:" .. partId] = {
				AlwaysOnTop = anyAlwaysOnTop,
				DrawType = "Icon",
				Icon = icons,
				Id = partId,
				Part = new.Instance,
			}
		end

		if labelsLength > 0 then
			table.sort(labels)
			if iconsLength > 0 then
				table.insert(labels, "")
			end

			adornMap["Text:" .. partId] = {
				AlwaysOnTop = anyAlwaysOnTop,
				DrawType = "Text",
				Id = partId,
				Part = new.Instance,
				TagName = labels,
			}
		end

		if spheresLength > 0 then
			local r, g, b = 0, 0, 0
			for _, sphere in ipairs(spheres) do
				r += sphere.R
				g += sphere.G
				b += sphere.B
			end

			r /= spheresLength
			g /= spheresLength
			b /= spheresLength
			local avg = Color3.new(r, g, b)
			adornMap["Sphere:" .. partId] = {
				AlwaysOnTop = anyAlwaysOnTop,
				Color = avg,
				DrawType = "Sphere",
				Id = partId,
				Part = new.Instance,
			}
		end
	end

	-- make sure it's not the same as the current list
	local isNew = false
	local props = {"Part", "Icon", "Id", "DrawType", "Color", "TagName", "AlwaysOnTop"}

	local oldMap = self.state.partsList
	for key, newValue in pairs(adornMap) do
		local oldValue = oldMap[key]
		if not oldValue then
			isNew = true
			break
		else
			for _, prop in ipairs(props) do
				if newValue[prop] ~= oldValue[prop] then
					isNew = true
					break
				end
			end
		end
	end

	if not isNew then
		for key in pairs(oldMap) do
			if not adornMap[key] then
				isNew = true
				break
			end
		end
	end

	if isNew then
		self:setState({
			partsList = adornMap,
		})
	end

	debug.profileend()
end

function WorldProvider:instanceAdded(inst)
	if self.trackedParts[inst] then
		self.trackedParts[inst] += 1
	else
		self.trackedParts[inst] = 1
		self.nextId += 1
		self.partIds[inst] = self.nextId
	end
end

function WorldProvider:instanceRemoved(inst)
	if self.trackedParts[inst] <= 1 then
		self.trackedParts[inst] = nil
		self.partIds[inst] = nil
	else
		self.trackedParts[inst] -= 1
	end
end

local function isTypeAllowed(instance)
	return instance:IsA("Model") or instance:IsA("Attachment") or instance:IsA("BasePart")
end

function WorldProvider:tagAdded(tagName)
	assert(not self.trackedTags[tagName])
	self.trackedTags[tagName] = true
	for _, obj in ipairs(CollectionService:GetTagged(tagName)) do
		if isTypeAllowed(obj) then
			if obj:IsDescendantOf(Workspace) then
				self:instanceAdded(obj)
			end

			if not self.instanceAncestryChangedConns:Get(obj) then
				self.instanceAncestryChangedConns:Add(obj.AncestryChanged:Connect(function()
					if not self.trackedParts[obj] and obj:IsDescendantOf(Workspace) then
						self:instanceAdded(obj)
						self:updateParts()
					elseif self.trackedParts[obj] and not obj:IsDescendantOf(Workspace) then
						self:instanceRemoved(obj)
						self:updateParts()
					end
				end), "Disconnect", obj)
			end
		end
	end

	self.instanceAddedConns:Add(CollectionService:GetInstanceAddedSignal(tagName):Connect(function(obj)
		if not isTypeAllowed(obj) then
			return
		end

		if obj:IsDescendantOf(Workspace) then
			self:instanceAdded(obj)
			self:updateParts()
		else
			print("outside workspace", obj)
		end

		if not self.instanceAncestryChangedConns:Get(obj) then
			self.instanceAncestryChangedConns:Add(obj.AncestryChanged:Connect(function()
				if not self.trackedParts[obj] and obj:IsDescendantOf(Workspace) then
					self:instanceAdded(obj)
					self:updateParts()
				elseif self.trackedParts[obj] and not obj:IsDescendantOf(Workspace) then
					self:instanceRemoved(obj)
					self:updateParts()
				end
			end), "Disconnect", obj)
		end
	end), "Disconnect", tagName)

	self.instanceRemovedConns:Add(CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(obj)
		if not isTypeAllowed(obj) then
			return
		end

		self:instanceRemoved(obj)
		self:updateParts()
	end), "Disconnect", tagName)
end

function WorldProvider:tagRemoved(tagName)
	assert(self.trackedTags[tagName])
	self.trackedTags[tagName] = nil
	for _, obj in ipairs(CollectionService:GetTagged(tagName)) do
		if obj:IsDescendantOf(Workspace) then
			self:instanceRemoved(obj)
		end
	end

	self.instanceAddedConns:Remove(tagName)
	self.instanceRemovedConns:Remove(tagName)
end

function WorldProvider:willUnmount()
	self.onTagAddedConn:Disconnect()
	self.onTagRemovedConn:Disconnect()
	self.onTagChangedConn:Disconnect()

	self.instanceAddedConns:Destroy()
	self.instanceRemovedConns:Destroy()
	self.janitor:Destroy()
end

function WorldProvider:render()
	local render = Roact_oneChild(self.props[Roact.Children])
	return render(self.state.partsList)
end

return WorldProvider
