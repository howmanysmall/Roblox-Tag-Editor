-- Sanity check.
if not plugin then
	error("Hot reloader must be executed as a plugin!")
end

-- Change to true to enable hot reloading support. Opening a place
-- containing the code synced via Rojo will cause the plugin to be
-- reloaded in edit mode. (No need for play solo or the hotswap plugin.)
local Config = require(script.Parent.Config)
local useDevSource = Config.useDevSource
local ServerStorage = game:GetService("ServerStorage")
local devSource = ServerStorage:FindFirstChild("TagEditor")

-- The source that's shipped integrated into the plugin.
local builtinSource = script.Parent

-- `source` is where we should watch for changes.
-- `currentRoot` is the clone we make of source to avoid require()
-- returning stale values.
local source = builtinSource
local currentRoot = source

if useDevSource then
	if devSource ~= nil then
		source = devSource
		currentRoot = source
	else
		warn("Tag editor development source is not present, running using built-in source.")
	end
end

local PluginFacade = {
	_toolbars = {},
	_pluginGuis = {},
	_buttons = {},
	_watching = {},
	_beforeUnload = nil,
	isDev = useDevSource and devSource ~= nil,
}

--[[
	Abstraction for plugin:CreateToolbar
]]
function PluginFacade:toolbar(name)
	if self._toolbars[name] then
		return self._toolbars[name]
	end

	local toolbar = plugin:CreateToolbar(name)

	self._toolbars[name] = toolbar

	return toolbar
end

--[[
	Abstraction for toolbar:CreateButton
]]
function PluginFacade:button(toolbar, name, tooltip, icon)
	local existingButtons = self._buttons[toolbar]

	if existingButtons then
		local existingButton = existingButtons[name]

		if existingButton then
			return existingButton
		end
	else
		existingButtons = {}
		self._buttons[toolbar] = existingButtons
	end

	local button = toolbar:CreateButton(name, tooltip, icon)

	existingButtons[name] = button

	return button
end

--[[
	Wrapper around plugin:CreatePluginGui
]]
function PluginFacade:createDockWidgetPluginGui(name, ...)
	if self._pluginGuis[name] then
		return self._pluginGuis[name]
	end

	local gui = plugin:CreateDockWidgetPluginGui(name, ...)
	self._pluginGuis[name] = gui

	return gui
end

--[[
	Sets the method to call the next time the system tries to reload
]]
function PluginFacade:beforeUnload(callback)
	self._beforeUnload = callback
end

function PluginFacade:_load(savedState)
	local ok, result = pcall(require, currentRoot.Main)

	if not ok then
		warn("Plugin failed to load: " .. result)
		return
	end

	--- @type function
	local Plugin = result

	ok, result = pcall(Plugin, PluginFacade, savedState)

	if not ok then
		warn("Plugin failed to run: " .. result)
		return
	end
end

function PluginFacade:unload()
	if self._beforeUnload then
		local saveState = self._beforeUnload()
		self._beforeUnload = nil

		return saveState
	end
end

function PluginFacade:_reload()
	local saveState = self:unload()
	currentRoot = source:Clone()

	self:_load(saveState)
end

function PluginFacade:_watch(instance)
	if self._watching[instance] then
		return
	end

	-- Don't watch ourselves!
	if instance == script then
		return
	end

	local connection1 = instance.Changed:Connect(function()
		print("Reloading due to", instance:GetFullName())
		self:_reload()
	end)

	local connection2 = instance.ChildAdded:Connect(function(instance2)
		self:_watch(instance2)
	end)

	local connections = {connection1, connection2}

	self._watching[instance] = connections

	for _, child in ipairs(instance:GetChildren()) do
		self:_watch(child)
	end
end

PluginFacade:_load()
PluginFacade:_watch(source)
