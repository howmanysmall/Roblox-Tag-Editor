local CollectionService = game:GetService("CollectionService")
local Selection = game:GetService("Selection")
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)

local TaggedInstanceProvider = Roact.PureComponent:extend("TaggedInstanceProvider")

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

function TaggedInstanceProvider:updateState(tagName)
	local selected = {}
	for _, instance in ipairs(Selection:Get()) do
		selected[instance] = true
	end

	local parts = {}
	if tagName then
		parts = CollectionService:GetTagged(tagName)
	end

	for i, part in ipairs(parts) do
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

		parts[i] = {
			id = id,
			instance = part,
			path = table.concat(path, "."),
		}
	end

	table.sort(parts, function(a, b)
		if a.path < b.path then
			return true
		end

		if b.path < a.path then
			return false
		end

		if a.instance.Name < b.instance.Name then
			return true
		end

		if b.instance.Name < b.instance.Name then
			return false
		end

		if a.instance.ClassName < b.instance.ClassName then
			return true
		end

		if b.instance.ClassName < b.instance.ClassName then
			return false
		end

		return false
	end)

	self:setState({
		parts = parts,
		selected = selected,
	})

	return parts, selected
end

function TaggedInstanceProvider:didUpdate(prevProps)
	local tagName = self.state.tagName

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
	return Roact.oneChild(self.props[Roact.Children])(state.parts, state.selected)
end

return TaggedInstanceProvider
