--[[
    Celestial Middleware: NetworkTransformer
    ------------------------------------------------
    Wraps outgoing/incoming network payloads (e.g. config syncs, remote
    telemetry, webhook posts) with lightweight compression so large
    JSON/string payloads use less bandwidth. Designed to slot into the
    same Config.SV / safecall pattern used by the rest of Celestial.

    Usage:
        local NetworkTransformer = loadstring(readfile("NetworkTransformer.lua"))()
        local mw = NetworkTransformer.New(Config)

        local compressed = mw:Compress(largeJsonString)
        local original    = mw:Decompress(compressed)

        -- or wrap a raw HTTP call directly:
        local ok, response = mw:Request({
            Url = "https://example.com/api",
            Method = "POST",
            Body = someTable,        -- auto JSON-encoded + compressed
        })
]]

local NetworkTransformer = {}
NetworkTransformer.__index = NetworkTransformer

------------------------------------------------------------------------
-- Simple run-length + escape codec.
-- Roblox has no native zlib/gzip binding, so this trades some ratio for
-- zero external deps. It's most effective on repetitive JSON (padding,
-- repeated keys/whitespace) and safe on arbitrary binary-ish strings.
------------------------------------------------------------------------
local ESCAPE = "\1"      -- marks an encoded run
local MAX_RUN = 255

local function rleEncode(input)
	local out = {}
	local i, n = 1, #input
	while i <= n do
		local c = input:sub(i, i)
		local runLen = 1
		while i + runLen <= n and input:sub(i + runLen, i + runLen) == c and runLen < MAX_RUN do
			runLen += 1
		end
		if runLen >= 4 or c == ESCAPE then
			out[#out + 1] = ESCAPE .. string.char(runLen) .. c
		else
			out[#out + 1] = string.rep(c, runLen)
		end
		i += runLen
	end
	return table.concat(out)
end

local function rleDecode(input)
	local out = {}
	local i, n = 1, #input
	while i <= n do
		local c = input:sub(i, i)
		if c == ESCAPE and i + 2 <= n then
			local runLen = string.byte(input, i + 1)
			local ch = input:sub(i + 2, i + 2)
			out[#out + 1] = string.rep(ch, runLen)
			i += 3
		else
			out[#out + 1] = c
			i += 1
		end
	end
	return table.concat(out)
end

------------------------------------------------------------------------
-- Constructor
------------------------------------------------------------------------
function NetworkTransformer.New(Config)
	local self = setmetatable({}, NetworkTransformer)
	self._safe = (Config and Config.Safe) or function(fn, ...)
		local ok, r = pcall(fn, ...)
		if not ok then warn("[NetworkTransformer] " .. tostring(r)) return nil end
		return r
	end
	self._http = Config and Config.SV and Config.SV.HttpService
	self.MinSizeToCompress = 96 -- bytes; skip tiny payloads, RLE overhead isn't worth it
	return self
end

-- Compress a string. Returns {c = true/false, d = data} so Decompress
-- knows whether the payload was actually transformed.
function NetworkTransformer:Compress(str)
	if type(str) ~= "string" then return {c = false, d = str} end
	if #str < self.MinSizeToCompress then
		return {c = false, d = str}
	end
	local ok, encoded = pcall(rleEncode, str)
	if not ok or #encoded >= #str then
		-- compression didn't help (or errored) — send raw
		return {c = false, d = str}
	end
	return {c = true, d = encoded}
end

function NetworkTransformer:Decompress(payload)
	if type(payload) ~= "table" then return payload end
	if not payload.c then return payload.d end
	local ok, decoded = pcall(rleDecode, payload.d)
	if not ok then
		warn("[NetworkTransformer] Failed to decompress payload, returning raw data")
		return payload.d
	end
	return decoded
end

------------------------------------------------------------------------
-- Convenience: wrap an HTTP request end-to-end.
-- Body (if a table) is JSON-encoded, then compressed before sending;
-- the response body is decompressed + JSON-decoded if it matches our
-- {c=, d=} envelope, otherwise returned as-is.
------------------------------------------------------------------------
function NetworkTransformer:Request(opts)
	opts = opts or {}
	if not self._http then
		return false, "HttpService unavailable"
	end

	local bodyStr = opts.Body
	if type(bodyStr) == "table" then
		local ok, encoded = pcall(function() return self._http:JSONEncode(bodyStr) end)
		if not ok then return false, "Failed to JSON-encode body" end
		bodyStr = encoded
	end

	local envelope = bodyStr and self:Compress(bodyStr) or nil

	local ok, result = pcall(function()
		if opts.Method == "POST" then
			return self._http:PostAsync(
				opts.Url,
				envelope and self._http:JSONEncode(envelope) or "",
				Enum.HttpContentType.ApplicationJson,
				false
			)
		else
			return self._http:GetAsync(opts.Url)
		end
	end)

	if not ok then
		return false, "Request failed: " .. tostring(result)
	end

	-- Try to interpret response as a compressed envelope; fall back to raw text.
	local decoded, wasEnvelope = self._safe(function()
		local parsed = self._http:JSONDecode(result)
		if type(parsed) == "table" and parsed.d ~= nil and parsed.c ~= nil then
			return self:Decompress(parsed), true
		end
		return parsed, false
	end)

	if decoded == nil then
		return true, result -- couldn't parse; hand back raw string
	end
	return true, decoded
end

return NetworkTransformer
