local isValueObj = {
	BrickColorValue = true,
	CFrameValue = true,
	ObjectValue = true,
	IntValue = true,
	NumberValue = true,
	Vector3Value = true,
	RayValue = true,
	StringValue = true,
	Color3Value = true,
	BoolValue = true,
}

local Watcher = {}
Watcher.__index = Watcher

function Watcher.new(root)
	local self = setmetatable({}, Watcher)

	self.root = root
	self.changedConns = {}
	self.nameChangedConns = {}
	self.descendantAddedConn = nil
	self.descendantRemovingConn = nil
	self.running = false

	return self
end

function Watcher:Destroy()
	if self.running then
		self:WatcherStop()
	end
end

function Watcher:WatcherStart()
	self.running = true

	local function instanceAdded(instance)
		if isValueObj[instance.ClassName] then
			local oldValue = instance.Value
			self.changedConns[instance] = instance.Changed:Connect(function(newValue)
				self:InstanceChanged(instance, oldValue, newValue)
				oldValue = newValue
			end)
		end

		local oldName = instance.Name
		self.nameChangedConns[instance] = instance:GetPropertyChangedSignal("Name"):Connect(function()
			local descendants = instance:GetDescendants()

			for i = #descendants, 1, -1 do
				self:InstanceRemoving(descendants[i], descendants[i].Name)
			end

			self:InstanceRemoving(instance, oldName)
			oldName = instance.Name

			self:InstanceAdded(instance)
			for _, descendant in ipairs(descendants) do
				self:InstanceAdded(descendant)
			end
		end)

		self:InstanceAdded(instance)
	end

	self.descendantAddedConn = self.root.DescendantAdded:Connect(instanceAdded)
	self.descendantRemovingConn = self.root.DescendantRemoving:Connect(function(instance)
		self:InstanceRemoving(instance, instance.Name)
		if self.nameChangedConns[instance] then
			self.nameChangedConns[instance]:Disconnect()
			self.nameChangedConns[instance] = nil
		end

		if self.changedConns[instance] then
			self.changedConns[instance]:Disconnect()
			self.changedConns[instance] = nil
		end
	end)

	for _, instance in ipairs(self.root:GetDescendants()) do
		instanceAdded(instance)
	end
end

function Watcher:WatcherStop()
	self.descendantAddedConn:Disconnect()
	self.descendantRemovingConn:Disconnect()

	for _, conn in pairs(self.changedConns) do
		conn:Disconnect()
	end

	for _, conn in pairs(self.nameChangedConns) do
		conn:Disconnect()
	end

	self.running = false
end

function Watcher:InstanceAdded(_instance, _name)
end

function Watcher:InstanceRemoving(_instance, _name)
end

function Watcher:ValueChanged(_instance, _oldValue, _newValue)
end

return Watcher
