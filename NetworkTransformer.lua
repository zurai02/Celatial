--[[
    Celestial Middleware: ErrorHandler
    ------------------------------------------------
    Wraps unsafe data transformations (JSON decode, deserialization,
    config parsing, callback execution) in pcall so a bad payload or
    a user Callback error never crashes the calling thread. On failure
    it returns a default fallback schema instead, and optionally logs
    /notifies through Celestial.

    Usage:
        local ErrorHandler = loadstring(readfile("ErrorHandler.lua"))()
        local eh = ErrorHandler.New(Celestial) -- pass your Celestial instance (optional)

        local data = eh:Try(function()
            return Http:JSONDecode(rawString)
        end, { fallback = {} })

        local safeFn = eh:Wrap(someCallback, { context = "Toggle:MyFlag" })
        safeFn(true) -- never throws; logs + reports instead

        eh:Validate(data, {
            type = "table",
            required = {"Name", "Value"},
        }, { fallback = {Name = "unknown", Value = 0} })
]]

local ErrorHandler = {}
ErrorHandler.__index = ErrorHandler

function ErrorHandler.New(celestial)
	local self = setmetatable({}, ErrorHandler)
	self._celestial = celestial -- optional, used for Notify() on failures
	self.LogPrefix = "[Celestial ErrorHandler]"
	self.Silent = false        -- set true to suppress warn() spam
	self.NotifyOnError = false -- set true to surface a toast on failures
	self._errorCount = 0
	self._lastErrors = {}      -- ring buffer of recent errors for debugging
	self._maxLastErrors = 20
	return self
end

function ErrorHandler:_record(context, err)
	self._errorCount += 1
	table.insert(self._lastErrors, {
		time = os.clock(),
		context = context or "unknown",
		message = tostring(err),
	})
	if #self._lastErrors > self._maxLastErrors then
		table.remove(self._lastErrors, 1)
	end
	if not self.Silent then
		warn(("%s [%s] %s"):format(self.LogPrefix, context or "unknown", tostring(err)))
	end
	if self.NotifyOnError and self._celestial and self._celestial.Notify then
		pcall(function()
			self._celestial:Notify({
				Title = "Error handled",
				Content = tostring(context or "unknown") .. " failed safely",
				Type = "warn",
				Duration = 2.5,
			})
		end)
	end
end

------------------------------------------------------------------------
-- Try: run fn(...) in pcall. On success returns fn's result(s) unwrapped.
-- On failure, returns opts.fallback (default nil) and records the error.
------------------------------------------------------------------------
function ErrorHandler:Try(fn, opts, ...)
	opts = opts or {}
	if type(fn) ~= "function" then
		self:_record(opts.context or "Try", "fn is not callable (" .. type(fn) .. ")")
		return opts.fallback
	end
	local results = table.pack(pcall(fn, ...))
	local ok = results[1]
	if ok then
		return table.unpack(results, 2, results.n)
	end
	self:_record(opts.context, results[2])
	return opts.fallback
end

------------------------------------------------------------------------
-- Wrap: returns a new function that behaves like fn but never throws.
-- Handy for wrapping user-supplied Callbacks passed into UI elements.
------------------------------------------------------------------------
function ErrorHandler:Wrap(fn, opts)
	opts = opts or {}
	local context = opts.context or "Wrapped callback"
	return function(...)
		local args = table.pack(...)
		return self:Try(function()
			return fn(table.unpack(args, 1, args.n))
		end, { fallback = opts.fallback, context = context })
	end
end

------------------------------------------------------------------------
-- Validate: shallow schema check for decoded data (e.g. loaded configs).
-- schema = {
--     type = "table" | "string" | "number" | ...,
--     required = {"Key1", "Key2"},        -- keys that must be present (table only)
-- }
-- Returns (value, true) if valid, or (fallback, false) if not.
------------------------------------------------------------------------
function ErrorHandler:Validate(value, schema, opts)
	opts = opts or {}
	schema = schema or {}
	local context = opts.context or "Validate"

	if schema.type and type(value) ~= schema.type then
		self:_record(context, ("expected %s, got %s"):format(schema.type, type(value)))
		return opts.fallback, false
	end

	if schema.type == "table" and schema.required then
		for _, key in ipairs(schema.required) do
			if value[key] == nil then
				self:_record(context, "missing required field: " .. tostring(key))
				return opts.fallback, false
			end
		end
	end

	return value, true
end

------------------------------------------------------------------------
-- Combined helper: decode + validate in one safe step. Great for
-- reading config files or remote payloads that feed into UI Flags.
------------------------------------------------------------------------
function ErrorHandler:SafeDecode(raw, decodeFn, schema, opts)
	opts = opts or {}
	local decoded = self:Try(function() return decodeFn(raw) end, {
		fallback = opts.fallback,
		context = (opts.context or "SafeDecode") .. ":decode",
	})
	if decoded == nil then
		return opts.fallback, false
	end
	if schema then
		return self:Validate(decoded, schema, {
			fallback = opts.fallback,
			context = (opts.context or "SafeDecode") .. ":validate",
		})
	end
	return decoded, true
end

function ErrorHandler:GetStats()
	return {
		ErrorCount = self._errorCount,
		RecentErrors = self._lastErrors,
	}
end

function ErrorHandler:Reset()
	self._errorCount = 0
	self._lastErrors = {}
end

return ErrorHandler
