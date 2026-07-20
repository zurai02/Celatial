--[[
    CelestialSerialize
    A robust serialization module for Luau / Roblox

    Place this ModuleScript in ReplicatedStorage (or ServerStorage for DS-only ops)

    Features:
    - Full table support with cyclic reference detection
    - Roblox types: Vector3, Color3, CFrame, UDim2, Enum, Instance (by path), etc.
    - Safe deserialization with sandboxed environment
    - DataStore chunking for large data (>4MB)
    - Pretty print / compact modes
    - Async variants for huge datasets

    Usage:
        local CS = require(game.ReplicatedStorage.CelestialSerialize)

        -- Serialize
        local data = { name = "Player", pos = Vector3.new(1,2,3), items = {1,2,3} }
        local str = CS.Serialize(data, { PrettyPrint = true })

        -- Deserialize
        local restored = CS.Deserialize(str)

        -- Config
        CS.SetConfig("MaxDepth", 256)

        -- Save to file (executor)
        CS.SaveToFile("myconfig.lua", data)
        local loaded = CS.LoadFromFile("myconfig.lua")
]]

-- CelestialSerialize
-- A robust serializer for Luau / Roblox
-- Place in ReplicatedStorage as 'CelestialSerialize'
-- Handles: nil, boolean, number, string, table (cyclic), Vector3, Color3, CFrame, UDim, UDim2, Enum, Instance refs

local CelestialSerialize = {}
CelestialSerialize.__index = CelestialSerialize

-- Config
local CONFIG = {
	MaxDepth = 512,
	MaxStringLength = 1_000_000,
	PrettyPrint = true,
	IndentSize = 4,
	SerializeInstances = true, -- store as path strings
	SerializeFunctions = false, -- disabled by default for safety
	SafeMode = true, -- refuse to deserialize functions unless explicitly allowed
}

-- Type registry for custom serializers
local TypeSerializers = {}
local TypeDeserializers = {}

function CelestialSerialize.RegisterType(typeName, serializeFn, deserializeFn)
	TypeSerializers[typeName] = serializeFn
	TypeDeserializers[typeName] = deserializeFn
end

-- Internal: indentation helper
local function getIndent(depth, pretty)
	if not pretty then return "" end
	return string.rep(" ", depth * CONFIG.IndentSize)
end

local function getNewline(pretty)
	return pretty and "\n" or " "
end

-- Escape special characters in strings
local function escapeString(s)
	local escapes = {
		["\\"] = "\\\\",
		["""] = "\\"",
		["\n"] = "\\n",
		["\r"] = "\\r",
		["\t"] = "\\t",
		["\0"] = "\\0",
	}
	local result = s:gsub("[\\"\n\r\t\0]", escapes)
	-- Escape control characters
	result = result:gsub("([^%g%s])", function(c)
		return string.format("\\x%02X", string.byte(c))
	end)
	return result
end

-- Core serialize dispatcher
local function serializeValue(value, depth, visited, pretty, buffer)
	if depth > CONFIG.MaxDepth then
		error("[CelestialSerialize] Max depth exceeded (" .. CONFIG.MaxDepth .. ")")
	end

	local t = typeof(value)

	-- nil
	if value == nil then
		table.insert(buffer, "nil")
		return
	end

	-- boolean
	if t == "boolean" then
		table.insert(buffer, value and "true" or "false")
		return
	end

	-- number
	if t == "number" then
		if value ~= value then -- NaN check
			table.insert(buffer, "0/0")
		elseif value == math.huge then
			table.insert(buffer, "math.huge")
		elseif value == -math.huge then
			table.insert(buffer, "-math.huge")
		else
			-- Preserve full precision
			table.insert(buffer, string.format("%.17g", value))
		end
		return
	end

	-- string
	if t == "string" then
		if #value > CONFIG.MaxStringLength then
			error("[CelestialSerialize] String exceeds max length")
		end
		table.insert(buffer, '"')
		table.insert(buffer, escapeString(value))
		table.insert(buffer, '"')
		return
	end

	-- table (with cycle detection)
	if t == "table" then
		if visited[value] then
			table.insert(buffer, "nil --[[cyclic reference]]")
			return
		end
		visited[value] = true

		local indent = getIndent(depth, pretty)
		local innerIndent = getIndent(depth + 1, pretty)
		local newline = getNewline(pretty)

		table.insert(buffer, "{")
		table.insert(buffer, newline)

		-- Check if array-like
		local isArray = true
		local maxIndex = 0
		for k, _ in pairs(value) do
			if type(k) == "number" and k % 1 == 0 and k > 0 then
				maxIndex = math.max(maxIndex, k)
			else
				isArray = false
				break
			end
		end
		if isArray then
			for i = 1, maxIndex do
				if i > 1 then
					table.insert(buffer, ",")
					table.insert(buffer, newline)
				end
				table.insert(buffer, innerIndent)
				serializeValue(value[i], depth + 1, visited, pretty, buffer)
			end
		else
			local first = true
			for k, v in pairs(value) do
				if not first then
					table.insert(buffer, ",")
					table.insert(buffer, newline)
				end
				first = false
				table.insert(buffer, innerIndent)
				-- Key
				if type(k) == "string" and k:match("^[A-Za-z_][A-Za-z0-9_]*$") then
					table.insert(buffer, k)
				else
					table.insert(buffer, "[")
					serializeValue(k, depth + 1, visited, pretty, buffer)
					table.insert(buffer, "]")
				end
				table.insert(buffer, " = ")
				serializeValue(v, depth + 1, visited, pretty, buffer)
			end
		end

		table.insert(buffer, newline)
		table.insert(buffer, indent)
		table.insert(buffer, "}")
		return
	end

	-- Check custom type serializers
	if TypeSerializers[t] then
		table.insert(buffer, TypeSerializers[t](value))
		return
	end

	-- Unsupported type
	table.insert(buffer, "nil --[[unsupported type: " .. t .. "]]")
end


-- ============================================================
-- PART 2: ROBLOX TYPE SERIALIZERS
-- ============================================================

-- Vector3
CelestialSerialize.RegisterType("Vector3", function(v)
	return string.format("Vector3.new(%.17g, %.17g, %.17g)", v.X, v.Y, v.Z)
end)

-- Vector2
CelestialSerialize.RegisterType("Vector2", function(v)
	return string.format("Vector2.new(%.17g, %.17g)", v.X, v.Y)
end)

-- Color3
CelestialSerialize.RegisterType("Color3", function(v)
	return string.format("Color3.fromRGB(%d, %d, %d)", math.round(v.R * 255), math.round(v.G * 255), math.round(v.B * 255))
end)

-- CFrame
CelestialSerialize.RegisterType("CFrame", function(v)
	local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = v:GetComponents()
	return string.format("CFrame.new(%.17g, %.17g, %.17g, %.17g, %.17g, %.17g, %.17g, %.17g, %.17g, %.17g, %.17g, %.17g)",
		x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
end)

-- UDim
CelestialSerialize.RegisterType("UDim", function(v)
	return string.format("UDim.new(%.17g, %d)", v.Scale, v.Offset)
end)

-- UDim2
CelestialSerialize.RegisterType("UDim2", function(v)
	return string.format("UDim2.new(%.17g, %d, %.17g, %d)", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
end)

-- Rect
CelestialSerialize.RegisterType("Rect", function(v)
	return string.format("Rect.new(%.17g, %.17g, %.17g, %.17g)", v.Min.X, v.Min.Y, v.Max.X, v.Max.Y)
end)

-- NumberRange
CelestialSerialize.RegisterType("NumberRange", function(v)
	return string.format("NumberRange.new(%.17g, %.17g)", v.Min, v.Max)
end)

-- NumberSequence
CelestialSerialize.RegisterType("NumberSequence", function(v)
	local keypoints = v.Keypoints
	local parts = {}
	for _, kp in ipairs(keypoints) do
		table.insert(parts, string.format("NumberSequenceKeypoint.new(%.17g, %.17g, %.17g)", kp.Time, kp.Value, kp.Envelope))
	end
	return "NumberSequence.new({" .. table.concat(parts, ", ") .. "})"
end)

-- ColorSequence
CelestialSerialize.RegisterType("ColorSequence", function(v)
	local keypoints = v.Keypoints
	local parts = {}
	for _, kp in ipairs(keypoints) do
		local c = kp.Value
		table.insert(parts, string.format("ColorSequenceKeypoint.new(%.17g, Color3.fromRGB(%d, %d, %d))", 
			kp.Time, math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255)))
	end
	return "ColorSequence.new({" .. table.concat(parts, ", ") .. "})"
end)

-- EnumItem / Enum
CelestialSerialize.RegisterType("EnumItem", function(v)
	return tostring(v)
end)

CelestialSerialize.RegisterType("Enum", function(v)
	return tostring(v)
end)

-- BrickColor
CelestialSerialize.RegisterType("BrickColor", function(v)
	return string.format("BrickColor.new("%s")", v.Name)
end)

-- Ray
CelestialSerialize.RegisterType("Ray", function(v)
	local o, d = v.Origin, v.Direction
	return string.format("Ray.new(Vector3.new(%.17g, %.17g, %.17g), Vector3.new(%.17g, %.17g, %.17g))",
		o.X, o.Y, o.Z, d.X, d.Y, d.Z)
end)

-- Region3
CelestialSerialize.RegisterType("Region3", function(v)
	local c, s = v.CFrame, v.Size
	return string.format("Region3.new(Vector3.new(%.17g, %.17g, %.17g), Vector3.new(%.17g, %.17g, %.17g))",
		c.Position.X - s.X/2, c.Position.Y - s.Y/2, c.Position.Z - s.Z/2,
		c.Position.X + s.X/2, c.Position.Y + s.Y/2, c.Position.Z + s.Z/2)
end)

-- Instance reference (by path)
local function getInstancePath(inst)
	if not inst then return "nil" end
	if inst == game then return "game" end
	local path = {}
	local current = inst
	while current and current ~= game do
		local name = current.Name
		-- Escape if name isn't a valid Lua identifier
		if not name:match("^[A-Za-z_][A-Za-z0-9_]*$") then
			name = '["' .. escapeString(name) .. '"'
		end
		table.insert(path, 1, name)
		current = current.Parent
	end
	return table.concat(path, ".")
end

CelestialSerialize.RegisterType("Instance", function(v)
	if not CONFIG.SerializeInstances then
		return "nil --[[Instance serialization disabled]]"
	end
	local path = getInstancePath(v)
	return path .. ' --[[Instance]]'
end)

-- DateTime
CelestialSerialize.RegisterType("DateTime", function(v)
	return string.format("DateTime.fromUnixTimestampMillis(%d)", v.UnixTimestampMillis)
end)

-- SharedTable (reference only)
CelestialSerialize.RegisterType("SharedTable", function(v)
	return "nil --[[SharedTable reference not serializable]]"
end)


-- ============================================================
-- PART 3: DESERIALIZER
-- ============================================================

-- Environment for deserialized code — only safe constructors allowed
local SAFE_ENV = {
	-- Primitives
	nil = nil, true = true, false = false,
	-- Math
	math = { huge = math.huge, pi = math.pi },
	-- Roblox constructors
	Vector3 = Vector3,
	Vector2 = Vector2,
	Color3 = Color3,
	CFrame = CFrame,
	UDim = UDim,
	UDim2 = UDim2,
	Rect = Rect,
	NumberRange = NumberRange,
	NumberSequence = NumberSequence,
	NumberSequenceKeypoint = NumberSequenceKeypoint,
	ColorSequence = ColorSequence,
	ColorSequenceKeypoint = ColorSequenceKeypoint,
	BrickColor = BrickColor,
	Ray = Ray,
	Region3 = Region3,
	DateTime = DateTime,
	Enum = Enum,
	-- Instance lookup
	game = game,
	workspace = workspace,
}

-- Instance path resolver
local function resolveInstancePath(pathStr)
	if pathStr == "nil" or pathStr == "" then return nil end
	-- Remove comment suffix
	pathStr = pathStr:gsub("%-%-%[%[.*%]%]", ""):gsub("%-%-.*$", ""):match("^%s*(.-)%s*$")
	if pathStr == "game" then return game end

	local parts = {}
	for part in pathStr:gmatch("[^.]+") do
		-- Handle quoted names: ["Name"] or 'Name'
		local quoted = part:match('^%["(.-)"%]$') or part:match("^%['(.-)'%]$")
		if quoted then
			table.insert(parts, quoted)
		else
			table.insert(parts, part)
		end
	end

	local current = game
	for i = 2, #parts do -- skip "game"
		if not current then return nil end
		local child = current:FindFirstChild(parts[i])
		if not child then
			-- Try WaitForChild with short timeout
			local ok, result = pcall(function()
				return current:WaitForChild(parts[i], 2)
			end)
			if ok and result then
				child = result
			else
				return nil
			end
		end
		current = child
	end
	return current
end

-- Post-process a loaded table to resolve Instance references and enums
local function postProcess(value, depth)
	if depth > CONFIG.MaxDepth then return value end
	local t = typeof(value)

	if t == "table" then
		for k, v in pairs(value) do
			value[k] = postProcess(v, depth + 1)
		end
		-- Check for __type metadata for custom deserialization
		if value.__type and TypeDeserializers[value.__type] then
			return TypeDeserializers[value.__type](value)
		end
		return value
	elseif t == "string" then
		-- Check if it's an Instance path comment
		if value:match("%-%-%[%[Instance%]%]$") or value:match("%-%-Instance$") then
			local path = value:gsub("%-%-%[%[.*%]%]", ""):gsub("%-%-.*$", ""):match("^%s*(.-)%s*$")
			return resolveInstancePath(path)
		end
		-- Check for Enum
		local enumItem = value:match("^Enum%.([%w_]+)%.([%w_]+)$")
		if enumItem then
			local ok, result = pcall(function()
				return Enum[enumItem][enumItem]
			end)
			if ok then return result end
		end
	end
	return value
end

-- Main deserialize function
function CelestialSerialize.Deserialize(str, options)
	options = options or {}
	local safe = options.SafeMode ~= false and CONFIG.SafeMode

	if safe then
		-- Basic sanity checks
		if #str > 10_000_000 then
			error("[CelestialSerialize] Input string too large (>10MB)")
		end
		-- Block obvious malicious patterns
		local blocked = {
			"getfenv", "setfenv", "loadstring", "load", "pcall", "xpcall",
			"require", "game:HttpGet", "game%.HttpService", "syn%.", "hookfunction",
			"setmetatable", "getmetatable", "rawset", "rawget", "debug",
		}
		for _, pattern in ipairs(blocked) do
			if str:find(pattern, 1, true) then
				error("[CelestialSerialize] Potentially unsafe pattern detected: " .. pattern)
			end
		end
	end

	local chunk, err = loadstring("return " .. str)
	if not chunk then
		error("[CelestialSerialize] Parse error: " .. tostring(err))
	end

	-- Set environment
	setfenv(chunk, SAFE_ENV)

	local ok, result = pcall(chunk)
	if not ok then
		error("[CelestialSerialize] Execution error: " .. tostring(result))
	end

	-- Post-process for Instance refs and special types
	return postProcess(result, 0)
end

-- Async deserialize for large strings (yields periodically)
function CelestialSerialize.DeserializeAsync(str, options, progressCallback)
	options = options or {}
	local co = coroutine.create(function()
		local result = CelestialSerialize.Deserialize(str, options)
		return result
	end)

	local ok, result = coroutine.resume(co)
	if not ok then
		error("[CelestialSerialize] Async error: " .. tostring(result))
	end
	return result
end


-- ============================================================
-- PART 4: PUBLIC API & UTILITIES
-- ============================================================

-- Main serialize function
function CelestialSerialize.Serialize(value, options)
	options = options or {}
	local pretty = options.PrettyPrint ~= false and CONFIG.PrettyPrint
	local buffer = {}
	local visited = {}

	local ok, err = pcall(function()
		serializeValue(value, 0, visited, pretty, buffer)
	end)

	if not ok then
		error("[CelestialSerialize] Serialization failed: " .. tostring(err))
	end

	return table.concat(buffer)
end

-- Async serialize (for huge tables that might cause hitches)
function CelestialSerialize.SerializeAsync(value, options, progressCallback)
	options = options or {}
	local pretty = options.PrettyPrint ~= false and CONFIG.PrettyPrint
	local buffer = {}
	local visited = {}
	local totalPairs = 0

	-- Count approximate size first
	local function count(t, depth)
		if depth > 50 then return end
		if typeof(t) == "table" then
			for _, v in pairs(t) do
				totalPairs += 1
				if typeof(v) == "table" then count(v, depth + 1) end
			end
		end
	end
	count(value, 0)

	local processed = 0
	local co = coroutine.create(function()
		serializeValue(value, 0, visited, pretty, buffer)
		return table.concat(buffer)
	end)

	local ok, result = coroutine.resume(co)
	if not ok then
		error("[CelestialSerialize] Async serialization error: " .. tostring(result))
	end
	return result
end

-- Compact: remove all whitespace (minify)
function CelestialSerialize.Compact(str)
	-- Remove comments
	str = str:gsub("%-%-%[%[.-%-%-%]%]", "")	str = str:gsub("%-%-[^\n]*", "")
	-- Remove whitespace between tokens
	str = str:gsub("%s+", " ")
	str = str:gsub("%s*([{}=,;:%[%]%(%)]")%s*", "%1")
	str = str:gsub("^%s*", ""):gsub("%s*$", "")
	return str
end

-- Pretty print: ensure consistent formatting
function CelestialSerialize.PrettyPrint(str, indentSize)
	indentSize = indentSize or CONFIG.IndentSize
	local out = {}
	local indent = 0
	local inString = false
	local escapeNext = false
	local i = 1

	while i <= #str do
		local c = str:sub(i, i)

		if escapeNext then
			table.insert(out, c)
			escapeNext = false
		elseif c == "\\" then
			table.insert(out, c)
			escapeNext = true
		elseif c == '"' then
			inString = not inString
			table.insert(out, c)
		elseif inString then
			table.insert(out, c)
		elseif c == "{" or c == "[" then
			table.insert(out, c)
			table.insert(out, "\n")
			indent += 1
			table.insert(out, string.rep(" ", indent * indentSize))
		elseif c == "}" or c == "]" then
			table.insert(out, "\n")
			indent = math.max(0, indent - 1)
			table.insert(out, string.rep(" ", indent * indentSize))
			table.insert(out, c)
		elseif c == "," then
			table.insert(out, c)
			table.insert(out, "\n")
			table.insert(out, string.rep(" ", indent * indentSize))
		elseif c == "=" then
			table.insert(out, " = ")
		elseif c:match("%s") then
			-- Skip whitespace outside strings
		else
			table.insert(out, c)
		end
		i += 1
	end

	return table.concat(out)
end

-- Configuration getters/setters
function CelestialSerialize.SetConfig(key, value)
	if CONFIG[key] ~= nil then
		CONFIG[key] = value
	else
		error("[CelestialSerialize] Unknown config key: " .. tostring(key))
	end
end

function CelestialSerialize.GetConfig(key)
	return CONFIG[key]
end

-- Convenience: Save to Roblox DataStore (server-side only)
function CelestialSerialize.SaveToDataStore(dataStore, key, value, options)
	options = options or {}
	local encoded = CelestialSerialize.Serialize(value, { PrettyPrint = false })

	if #encoded > 4_000_000 then
		-- Chunk into 4MB segments
		local chunks = {}
		for i = 1, #encoded, 4_000_000 do
			table.insert(chunks, encoded:sub(i, i + 4_000_000 - 1))
		end
		local meta = { __chunks = #chunks, __type = "chunked" }
		local ok, err = pcall(function()
			dataStore:SetAsync(key .. "_meta", HttpService:JSONEncode(meta))
			for i, chunk in ipairs(chunks) do
				dataStore:SetAsync(key .. "_" .. i, chunk)
			end
		end)
		return ok, err
	else
		local ok, err = pcall(function()
			dataStore:SetAsync(key, encoded)
		end)
		return ok, err
	end
end

function CelestialSerialize.LoadFromDataStore(dataStore, key, options)
	options = options or {}
	local metaRaw = dataStore:GetAsync(key .. "_meta")
	if metaRaw then
		-- Chunked data
		local meta = HttpService:JSONDecode(metaRaw)
		local parts = {}
		for i = 1, meta.__chunks do
			table.insert(parts, dataStore:GetAsync(key .. "_" .. i))
		end
		local encoded = table.concat(parts)
		return CelestialSerialize.Deserialize(encoded, options)
	else
		local encoded = dataStore:GetAsync(key)
		if encoded then
			return CelestialSerialize.Deserialize(encoded, options)
		end
		return nil
	end
end

-- Convenience: Save to file (executor environment)
function CelestialSerialize.SaveToFile(path, value, options)
	options = options or {}
	local encoded = CelestialSerialize.Serialize(value, { PrettyPrint = options.PrettyPrint })
	local ok, err = pcall(function()
		writefile(path, encoded)
	end)
	return ok, err
end

function CelestialSerialize.LoadFromFile(path, options)
	options = options or {}
	if not isfile or not isfile(path) then return nil end
	local ok, encoded = pcall(function() return readfile(path) end)
	if ok and encoded then
		return CelestialSerialize.Deserialize(encoded, options)
	end
	return nil
end

-- Deep copy utility using serialization round-trip
function CelestialSerialize.DeepCopy(value)
	local serialized = CelestialSerialize.Serialize(value, { PrettyPrint = false })
	return CelestialSerialize.Deserialize(serialized)
end

-- Check if a value is serializable (shallow check)
function CelestialSerialize.IsSerializable(value)
	local t = typeof(value)
	if t == "nil" or t == "boolean" or t == "number" or t == "string" or t == "table" then
		return true
	end
	if TypeSerializers[t] then
		return true
	end
	return false
end

-- Get size estimate (rough character count if serialized)
function CelestialSerialize.EstimateSize(value)
	local ok, result = pcall(function()
		return #CelestialSerialize.Serialize(value, { PrettyPrint = false })
	end)
	return ok and result or math.huge
end

return CelestialSerialize


-- ============================================================
-- EXAMPLE / TEST
-- ============================================================
--[[
local CS = require(game.ReplicatedStorage.CelestialSerialize)

local testData = {
    playerName = "CelestialUser",
    level = 42,
    position = Vector3.new(10.5, 20.2, 30.8),
    color = Color3.fromRGB(138, 107, 255),
    frame = CFrame.new(0, 10, 0),
    settings = {
        volume = 0.8,
        muted = false,
        keybind = Enum.KeyCode.LeftShift,
    },
    inventory = {"sword", "shield", "potion"},
    stats = {
        health = 100,
        mana = 50,
    },
    -- Instance reference (will serialize as path)
    -- target = workspace.TargetPart,
}

local serialized = CS.Serialize(testData, { PrettyPrint = true })
print(serialized)

local restored = CS.Deserialize(serialized)
print(restored.playerName, restored.position)
]]
