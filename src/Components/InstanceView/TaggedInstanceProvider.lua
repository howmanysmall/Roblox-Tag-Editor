local CollectionService = game:GetService("CollectionService")
local Selection = game:GetService("Selection")
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)

local TaggedInstanceProvider = Roact.PureComponent:extend("TaggedInstanceProvider")

local Roact_oneChild = Roact.oneChild

function TaggedInstanceProvider:init()
	self.nextId = 1
	self.partIds = {}

	self.selectionChangedConn = Selection.SelectionChanged:Connect(function()
		self:updateState(self.state.tagName)
	end)

	self.ancestryChangedConns = {}
	self.nameChangedConns = {}

	self:setState({
		parts = {},
		selected = {},
	})
end

local function sortParts(a, b)
	local aPath = a.path
	local bPath = b.path
	if aPath < bPath then
		return true
	end

	if bPath < aPath then
		return false
	end

	local aInstance = a.instance
	local bInstance = b.instance
	if aInstance.Name < bInstance.Name then
		return true
	end

	if bInstance.Name < bInstance.Name then
		return false
	end

	local aClassName = aInstance.ClassName
	local bClassName = bInstance.ClassName
	if aClassName < bClassName then
		return true
	end

	if bClassName < bClassName then
		return false
	end

	return false
end

function TaggedInstanceProvider:updateState(tagName)
	local selected = {}
	for _, instance in ipairs(Selection:Get()) do
		selected[instance] = true
	end

	local parts
	if tagName then
		parts = CollectionService:GetTagged(tagName)
	else
		parts = {}
	end

	for index, part in ipairs(parts) do
		local path = {}
		local cur = part.Parent
		while cur and cur ~= game do
			table.insert(path, 1, cur.Name)
			cur = cur.Parent
		end

		local id = self.partIds[part]
		if not id then
			id = self.nextId
			self.nextId += 1
			self.partIds[part] = id
		end

		parts[index] = {
			id = id,
			instance = part,
			path = table.concat(path, "."),
		}
	end

	table.sort(parts, sortParts)

	self:setState({
		parts = parts,
		selected = selected,
	})

	return parts, selected
end

function TaggedInstanceProvider:didUpdate(prevProps)
	local tagName = self.props.tagName

	if tagName ~= prevProps.tagName then
		local parts = self:updateState(tagName)

		-- Setup signals
		if self.instanceAddedConn then
			self.instanceAddedConn:Disconnect()
			self.instanceAddedConn = nil
		end

		if self.instanceRemovedConn then
			self.instanceRemovedConn:Disconnect()
			self.instanceRemovedConn = nil
		end

		for _, conn in pairs(self.ancestryChangedConns) do
			conn:Disconnect()
		end

		for _, conn in pairs(self.nameChangedConns) do
			conn:Disconnect()
		end

		self.ancestryChangedConns = {}
		self.nameChangedConns = {}
		if tagName then
			self.instanceAddedConn = CollectionService:GetInstanceAddedSignal(tagName):Connect(function(inst)
				self.nameChangedConns[inst] = inst:GetPropertyChangedSignal("Name"):Connect(function()
					self:updateState(tagName)
				end)

				self.ancestryChangedConns[inst] = inst.AncestryChanged:Connect(function()
					self:updateState(tagName)
				end)

				self:updateState(tagName)
			end)

			self.instanceRemovedConn = CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(inst)
				self.nameChangedConns[inst]:Disconnect()
				self.nameChangedConns[inst] = nil

				self.ancestryChangedConns[inst]:Disconnect()
				self.ancestryChangedConns[inst] = nil

				self:updateState(tagName)
			end)
		end

		for _, entry in ipairs(parts) do
			local part = entry.instance
			self.nameChangedConns[part] = part:GetPropertyChangedSignal("Name"):Connect(function()
				self:updateState(tagName)
			end)

			self.ancestryChangedConns[part] = part.AncestryChanged:Connect(function()
				self:updateState(tagName)
			end)
		end
	end
end

function TaggedInstanceProvider:willUnmount()
	if self.instanceAddedConn then
		self.instanceAddedConn:Disconnect()
	end

	if self.instanceRemovedConn then
		self.instanceRemovedConn:Disconnect()
	end

	self.selectionChangedConn:Disconnect()
	for _, conn in pairs(self.ancestryChangedConns) do
		conn:Disconnect()
	end

	for _, conn in pairs(self.nameChangedConns) do
		conn:Disconnect()
	end
end

function TaggedInstanceProvider:render()
	local state = self.state
	return Roact_oneChild(self.props[Roact.Children])(state.parts, state.selected)
end

return TaggedInstanceProvider
