local Fmt = require(script.Parent.Parent.Vendor.Fmt).Fmt

local Logger = {ClassName = "Logger"}
Logger.__index = Logger

local function FastSpawn(Function, ...)
	local Arguments = table.pack(...)
	local BindableEvent = Instance.new("BindableEvent")

	BindableEvent.Event:Connect(function()
		Function(table.unpack(Arguments, 1, Arguments.n))
	end)

	BindableEvent:Fire()
	BindableEvent:Destroy()
end

--[[**
	Creates a new Logger.
	@param [t:string] Prefix The prefix for the log messages.
	@param [t:boolean?] IsEnabled Whether or not the logger is enabled by default.
	@returns [t:Logger]
**--]]
function Logger.new(Prefix: string, IsEnabled: boolean?)
	if IsEnabled == nil then
		IsEnabled = true
	end

	return setmetatable({
		Prefix = Prefix,
		Enabled = IsEnabled,
	}, Logger)
end

--[[**
	Sets whether or not the Logger is enabled.
	@param [t:boolean] Enabled Whether or not the logger is enabled.
	@returns [t:Logger]
**--]]
function Logger:SetEnabled(Enabled: boolean)
	self.Enabled = Enabled
	return self
end

--[[**
	Sets the prefix of the log messages.
	@param [t:string] Prefix The new prefix.
	@returns [t:Logger]
**--]]
function Logger:SetPrefix(Prefix: string)
	self.Prefix = Prefix
	return self
end

--[[**
	If the logger is enabled, this will print a message with the format `[TRACE/Prefix]: Message` using `print`. The arguments are formatted using Fmt.
	@param [t:string] Message The message to print.
	@param [t:...any?] ... The arguments to format with.
	@returns [t:Logger]
**--]]
function Logger:Trace(Message: string, ...)
	if self.Enabled then
		print("[TRACE/" .. self.Prefix .. "]:", Fmt(Message, ...))
	end

	return self
end

--[[**
	If the logger is enabled, this will print a message with the format `[DEBUG/Prefix]: Message` using `print`. The arguments are formatted using Fmt.
	@param [t:string] Message The message to print.
	@param [t:...any?] ... The arguments to format with.
	@returns [t:Logger]
**--]]
function Logger:Debug(Message: string, ...)
	if self.Enabled then
		print("[DEBUG/" .. self.Prefix .. "]:", Fmt(Message, ...))
	end

	return self
end

--[[**
	If the logger is enabled, this will print a message with the format `[INFO/Prefix]: Message` using `print`. The arguments are formatted using Fmt.
	@param [t:string] Message The message to print.
	@param [t:...any?] ... The arguments to format with.
	@returns [t:Logger]
**--]]
function Logger:Info(Message: string, ...)
	if self.Enabled then
		print("[INFO/" .. self.Prefix .. "]:", Fmt(Message, ...))
	end

	return self
end

--[[**
	If the logger is enabled, this will print a message with the format `[WARNING/Prefix]: Message` using `warn`. The arguments are formatted using Fmt.
	@param [t:string] Message The message to print.
	@param [t:...any?] ... The arguments to format with.
	@returns [t:Logger]
**--]]
function Logger:Warning(Message: string, ...)
	if self.Enabled then
		warn("[WARNING/" .. self.Prefix .. "]:", Fmt(Message, ...))
	end

	return self
end

--[[**
	If the logger is enabled, this will print a message with the format `[ERROR/Prefix]: Message` using `error` on a separate thread. The arguments are formatted using Fmt.
	@param [t:string] Message The message to print.
	@param [t:...any?] ... The arguments to format with.
	@returns [t:Logger]
**--]]
function Logger:Error(Message: string, ...)
	if self.Enabled then
		FastSpawn(error, string.format("[ERROR/" .. self.Prefix .. "]: %s", Fmt(Message, ...)))
	end

	return self
end

--[[**
	If the logger is enabled, this will print a message with the format `[FATAL/Prefix]: Message` using `error` on a separate thread. The arguments are formatted using Fmt.
	@param [t:string] Message The message to print.
	@param [t:...any?] ... The arguments to format with.
	@returns [t:Logger]
**--]]
function Logger:Fatal(Message: string, ...)
	if self.Enabled then
		FastSpawn(error, string.format("[FATAL/" .. self.Prefix .. "]: %s", Fmt(Message, ...)))
	end

	return self
end

return Logger
