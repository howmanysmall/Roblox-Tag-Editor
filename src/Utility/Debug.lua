local Debug = {}
local TAB = "\t" or string.rep(" ", 4)

local Services = setmetatable({}, { -- Memoize GetService calls
	__index = function(self, Index)
		local Success, Object = pcall(game.GetService, game, Index)
		local Service = Success and Object
		self[Index] = Service
		return Service
	end,
})

local Nil = nil

function Debug.DirectoryToString(Object: Instance)
	assert(typeof(Object) == "Instance", string.format("invalid argument #1 to 'Debug.DirectoryToString' (Instance expected, got %s)", typeof(Object)))
	local FullName = {}
	local Count = 0

	while Object.Parent ~= game and Object.Parent ~= Nil do
		local ObjectName = string.gsub(Object.Name, "([\\\"])", "\\%1")

		if string.find(ObjectName, "^[_%a][_%w]*$") then
			FullName[Count] = "." .. ObjectName
		else
			FullName[Count] = "[\"" .. ObjectName .. "\"]"
		end

		Count -= 1
		Object = Object.Parent
	end

	if Services[Object.ClassName] == Object then
		FullName[Count] = "game:GetService(\"" .. Object.ClassName .. "\")"
	else
		FullName[Count] = "." .. "[\"" .. Object.Name .. "\"]" -- A dot at the beginning indicates a rootless Object
	end

	return table.concat(FullName, "", Count, 0)
end

local Replacers = {
	["Index ?"] = "__index",
	["Newindex ?"] = "__newindex",
}

local function GetErrorData(Error, ...) -- Make sure if you don't intend to format arguments in, you do %%f instead of %f
	if type(Error) ~= "string" then
		error(GetErrorData("!The first parameter of error formatting must be a string", "Debug"))
	end

	local Arguments = {...}
	local Traceback = debug.traceback()
	local ErrorDepth = select(2, string.gsub(Traceback, "\n", "")) - 2

	local Prefix
	Error, Prefix = string.gsub(Error, "^!", "", 1)
	-- local ModuleName = Prefix == 1 and table.remove(Arguments, 1) or "Command bar" -- CommandBar.Name
	local ModuleName = Prefix == 1 and table.remove(Arguments, 1) or table.remove(string.split(debug.info(ErrorDepth, "s"), ".")) or "Command bar"

	local FunctionName = ""

	for Index = 1, select("#", ...) do
		Arguments[Index] = Debug.Inspect(Arguments[Index])
	end

	for X in string.gmatch(string.sub(Traceback, 1, -11), "%- [^\r\n]+[\r\n]") do
		FunctionName = X
	end

	FunctionName = string.gsub(string.gsub(string.sub(FunctionName, 3, -2), "%l+ (%S+)$", "%1"), " ([^\n\r]+)", " %1", 1)

	local Index = 0
	for X in string.gmatch(Error, "%%%l") do
		Index += 1
		if X == "%q" then
			Arguments[Index] = string.gsub(Arguments[Index], " (%S+)$", " \"%1\"", 1)
		end
	end

	local Success, ErrorString = pcall(string.format, "[%s] {%s} " .. string.gsub(Error, "%%q", "%%s"), ModuleName, Replacers[FunctionName] or FunctionName, table.unpack(Arguments))

	if Success then
		return ErrorString, ErrorDepth
	else
		error(GetErrorData("!Error formatting failed, perhaps try escaping non-formattable tags like so: %%%%f\n(Error Message): " .. ErrorString, "Debug"))
	end
end

function Debug.Warn(...)
	warn((GetErrorData(...)))
end

function Debug.Error(...)
	error(GetErrorData(...))
end

function Debug.Assert(Condition, ...)
	return Condition or error(GetErrorData(...))
end

local function Alphabetically(A, B)
	local TypeA = typeof(A)
	local TypeB = typeof(B)

	if TypeA == TypeB then
		if TypeA == "number" then
			return A < B
		else
			return string.lower(tostring(A)) < string.lower(tostring(B))
		end
	else
		return TypeA < TypeB
	end
end

function Debug.AlphabeticalOrder(Dictionary)
	assert(type(Dictionary) == "table", string.format("invalid argument #1 to 'Debug.AlphabeticalOrder' (table expected, got %s)", typeof(Dictionary)))
	local Order = {}
	local Length = 0

	for Key in next, Dictionary do
		Length += 1
		Order[Length] = Key
	end

	table.sort(Order, Alphabetically)

	local Index = 0
	return function(Table)
		Index += 1
		local Key = Order[Index]
		return Key, Table[Key], Index
	end, Dictionary, Nil
end

local Debug_AlphabeticalOrder = Debug.AlphabeticalOrder
local Debug_DirectoryToString = Debug.DirectoryToString

function Debug.UnionIteratorFunctions(...)
	local IteratorFunctions = {...}

	for _, IteratorFunction in ipairs(IteratorFunctions) do
		if type(IteratorFunction) ~= "function" then
			error("Cannot union Iterator functions which aren't functions", 2)
		end
	end

	return function(Table)
		local Count = 0
		local Order = {[0] = {}}
		local KeysSeen = {}

		for Index, IteratorFunction in ipairs(IteratorFunctions) do
			local Function, TableToIterateThrough, Next = IteratorFunction(Table)

			if type(Function) ~= "function" or type(TableToIterateThrough) ~= "table" then
				error("Iterator function " .. Index .. " must return a stack of types as follows: Function, Table, Variant", 2)
			end

			while true do
				local Data = {Function(TableToIterateThrough, Next)}
				Next = Data[1]
				if Next == Nil then
					break
				end

				if not KeysSeen[Next] then
					KeysSeen[Next] = true
					Count += 1
					table.insert(Data, Index)
					Order[Count] = Data
				end
			end
		end

		return function(_, Previous)
			for Index = 0, Count do
				if Order[Index][1] == Previous then
					local Data = Order[Index + 1]
					if Data then
						return table.unpack(Data)
					else
						return Nil
					end
				end
			end

			error("invalid key to unioned iterator function: " .. Previous, 2)
		end, Table, Nil
	end
end

local ConvertTableIntoString
local function Parse(Object, Multiline, Depth, EncounteredTables)
	local Type = typeof(Object)
	return Type == "table" and (EncounteredTables[Object] and "[table " .. EncounteredTables[Object] .. "]" or ConvertTableIntoString(Object, Nil, Multiline, Depth + 1, EncounteredTables)) or Type == "string" and "\"" .. Object .. "\"" or Type == "Instance" and "<" .. Debug_DirectoryToString(Object) .. ">" or (Type == "function" or Type == "userdata") and Type or tostring(Object)
end

function ConvertTableIntoString(Table, TableName, Multiline, Depth, EncounteredTables)
	local n = EncounteredTables.n + 1
	EncounteredTables[Table] = n
	EncounteredTables.n = n

	local Array = {}
	local Length = 1
	local CurrentArrayIndex = 1

	if TableName then
		Array[1] = TableName
		Array[2] = " = {"
		Length = 2
	else
		Array[1] = "{"
	end

	if not next(Table) then
		Array[Length + 1] = "}"
		return table.concat(Array)
	end

	for Key, Value in Debug_AlphabeticalOrder(Table) do
		if not Multiline and type(Key) == "number" then
			if Key == CurrentArrayIndex then
				CurrentArrayIndex += 1
			else
				Length += 1
				Array[Length] = "[" .. Key .. "] = "
			end

			Length += 1
			Array[Length] = Parse(Value, Multiline, Depth, EncounteredTables)

			Length += 1
			Array[Length] = ", "
		else
			if Multiline then
				Length += 1
				Array[Length] = "\n"

				Length += 1
				Array[Length] = string.rep(TAB, Depth)
			end

			if type(Key) == "string" and string.find(Key, "^[%a_][%w_]*$") then
				Length += 1
				Array[Length] = Key
			else
				Length += 1
				Array[Length] = "["

				Length += 1
				Array[Length] = Parse(Key, Multiline, Depth, EncounteredTables)

				Length += 1
				Array[Length] = "]"
			end

			Length += 1
			Array[Length] = " = "

			Length += 1
			Array[Length] = Parse(Value, Multiline, Depth, EncounteredTables)

			Length += 1
			Array[Length] = Multiline and ";" or ", "
		end
	end

	if Multiline then
		Length += 1
		Array[Length] = "\n"

		Length += 1
		Array[Length] = string.rep(TAB, Depth - 1)
	else
		Array[Length] = Nil
		Length -= 1
	end

	Length += 1
	Array[Length] = "}"

	local Metatable = getmetatable(Table)

	if Metatable then
		Length += 1
		Array[Length] = " <- "

		Length += 1
		Array[Length] = type(Metatable) == "table" and ConvertTableIntoString(Metatable, Nil, Multiline, Depth, EncounteredTables) or Debug.Inspect(Metatable)
	end

	return table.concat(Array)
end

function Debug.TableToString(Table, Multiline: boolean?, TableName: string?): string
	assert(type(Table) == "table", string.format("invalid argument #1 to 'Debug.TableToString' (table expected, got %s)", typeof(Table)))
	assert(Multiline == nil or type(Multiline) == "boolean", string.format("invalid argument #2 to 'Debug.TableToString' (boolean? expected, got %s)", typeof(Multiline)))
	assert(TableName == nil or type(TableName) == "string", string.format("invalid argument #3 to 'Debug.TableToString' (string? expected, got %s)", typeof(TableName)))

	return ConvertTableIntoString(Table, TableName, Multiline, 1, {n = 0})
end

local Debug_TableToString = Debug.TableToString
local EscapedCharacters = {"%", "^", "$", "(", ")", ".", "[", "]", "*", "+", "-", "?"}
local Escapable: string = "([%" .. table.concat(EscapedCharacters, "%") .. "])"

function Debug.EscapeString(String: string): string
	assert(type(String) == "string", string.format("invalid argument #1 to 'Debug.EscapeString' (string expected, got %s)", typeof(String)))
	return (string.gsub(string.gsub(String, Escapable, "%%%1"), "([\"'\\])", "\\%1"))
end

function Debug.Inspect(...): string
	local List: string = ""

	for Index = 1, select("#", ...) do
		local Data = select(Index, ...)
		local DataType = typeof(Data)
		local DataString

		if DataType == "Instance" then
			DataType = Data.ClassName
			DataString = Debug_DirectoryToString(Data)
		else
			DataString = DataType == "table" and Debug_TableToString(Data) or DataType == "string" and "\"" .. Data .. "\"" or tostring(Data)
		end

		List ..= ", " .. (string.gsub(DataType .. " " .. DataString, "^" .. DataType .. " " .. DataType, DataType, 1))
	end

	if List == "" then
		return "NONE"
	else
		return string.sub(List, 3)
	end
end

return Debug
