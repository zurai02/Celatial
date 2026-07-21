--[[
    Celestial UI Library v3.0.0
    Integrated Edition

    External dependencies (auto-loaded via game:HttpGet):
    - https://raw.githubusercontent.com/zurai02/Celatial/main/C.lua
    - https://raw.githubusercontent.com/zurai02/Celatial/main/CelestialSerialize.lua
    - https://raw.githubusercontent.com/zurai02/Celatial/main/NetworkTransformer.lua
    - https://raw.githubusercontent.com/zurai02/Celatial/main/ErrorHandler.lua

    Exposed on Celestial table:
    - Celestial.Serializer        -> CelestialSerialize module
    - Celestial.NetworkTransformer -> NetworkTransformer module  
    - Celestial.ErrorHandler      -> ErrorHandler module
    - Celestial._errorHandler     -> ErrorHandler instance (with Notify integration)
    - Celestial._networkTransformer -> NetworkTransformer instance (ready for requests)
]]

--!optimize 2
--!strict
--!native

--[[
    Celestial UI Library v3.0.0
    Integrated Edition with NetworkTransformer, ErrorHandler, CelestialSerialize

    External loads:
    C.lua                      -> Config
    CelestialSerialize.lua     -> Serializer
    NetworkTransformer.lua     -> NetworkTransformer
    ErrorHandler.lua           -> ErrorHandler
]]

------------------------------------------------------------------------
-- Load Shared Config
------------------------------------------------------------------------
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/zurai02/Celatial/main/C.lua"))()

-- Fallback if Config fails to load
if not Config or not Config.SV then
	warn("[Celestial] Failed to load shared config (C.lua). Using minimal fallback.")
	local UISf = game:GetService("UserInputService")
	local TSf = game:GetService("TweenService")
	local function makef(cls, props, parent)
		local i = Instance.new(cls)
		for k, v in pairs(props or {}) do pcall(function() (i :: any)[k] = v end) end
		if parent then i.Parent = parent end
		return i
	end
	Config = {
		SV = {
			UserInputService = UISf, TweenService = TSf,
			Players = game:GetService("Players"), CoreGui = game:GetService("CoreGui"),
			HttpService = game:GetService("HttpService"), RunService = game:GetService("RunService"),
			TextService = game:GetService("TextService"), SoundService = game:GetService("SoundService"),
		},
		Safe = function(fn, ...)
			if type(fn) ~= "function" then return nil end
			local ok, r = pcall(fn, ...)
			if not ok then warn("[Celestial] " .. tostring(r)) return nil end
			return r
		end,
		Tween = function(inst, info, goals)
			if not inst then return nil end
			local t = TSf:Create(inst, info, goals)
			t:Play()
			return t
		end,
		TW = {
			Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			Med = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			Slow = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			Spring = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			Soft = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		},
		N = {
			Make = makef,
			Corner = function(r, p) return makef("UICorner", {CornerRadius = UDim.new(0, r)}, p) end,
			Pad = function(l, r, t, b, p) return makef("UIPadding", {PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0), PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0)}, p) end,
			Stroke = function(c, th, tr, p) return makef("UIStroke", {Color = c, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p) end,
			List = function(dir, sort, sp, p) return makef("UIListLayout", {FillDirection = dir or Enum.FillDirection.Vertical, SortOrder = sort or Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, sp or 6)}, p) end,
			Gradient = function(r, kp, tp, p) return makef("UIGradient", {Rotation = r or 0, Color = kp, Transparency = tp}, p) end,
		},
		File = {MakeFolder = function(p) if makefolder and not (isfolder and isfolder(p)) then pcall(makefolder, p) end end},
		Th = {},
	}
end

------------------------------------------------------------------------
-- Load Serializer
------------------------------------------------------------------------
local Serializer = nil
local function loadSerializer()
	if Serializer then return true end
	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/zurai02/Celatial/main/CelestialSerialize.lua"))()
	end)
	if ok and result then
		Serializer = result
		return true
	end
	warn("[Celestial] Serializer not available. Config save/load will use JSON.")
	return false
end
loadSerializer()

------------------------------------------------------------------------
-- Load NetworkTransformer
------------------------------------------------------------------------
local NetworkTransformer = nil
local function loadNetworkTransformer()
	if NetworkTransformer then return true end
	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/zurai02/Celatial/main/NetworkTransformer.lua"))()
	end)
	if ok and result then
		NetworkTransformer = result
		return true
	end
	warn("[Celestial] NetworkTransformer failed to load. Network compression unavailable.")
	return false
end
loadNetworkTransformer()

------------------------------------------------------------------------
-- Load ErrorHandler
------------------------------------------------------------------------
local ErrorHandler = nil
local function loadErrorHandler()
	if ErrorHandler then return true end
	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/zurai02/Celatial/main/ErrorHandler.lua"))()
	end)
	if ok and result then
		ErrorHandler = result
		return true
	end
	warn("[Celestial] ErrorHandler failed to load. Using fallback pcall wrapper.")
	return false
end
loadErrorHandler()

------------------------------------------------------------------------
-- Thin alias layer over Config
------------------------------------------------------------------------
local UIS = Config.SV.UserInputService
local TweenService = Config.SV.TweenService
local Players = Config.SV.Players
local CoreGui = Config.SV.CoreGui
local Http = Config.SV.HttpService
local Run = Config.SV.RunService
local TextService = Config.SV.TextService
local SoundService = Config.SV.SoundService

local IS_STUDIO = Run:IsStudio()

local safecall = Config.Safe
local folder = Config.File.MakeFolder
local tw = Config.Tween

local T_FAST = Config.TW.Fast
local T_MED = Config.TW.Med
local T_SLOW = Config.TW.Slow
local T_SPRING = Config.TW.Spring
local T_SPRING_SOFT = Config.TW.Soft

local make = Config.N.Make
local corner = Config.N.Corner
local pad = Config.N.Pad
local stroke = Config.N.Stroke
local listLayout = Config.N.List
local gradient = Config.N.Gradient

local VERSION = "3.0.0"
local NAME = "Celestial"
local FOLDER_ROOT = "Celestial"
local FOLDER_CFG = FOLDER_ROOT .. "/Configs"
local CFG_EXT = ".cltl"


------------------------------------------------------------------------
-- THEMES
------------------------------------------------------------------------
local Themes = Config.Th

if not Themes or not next(Themes) then
	warn("[Celestial] Config.Th missing — using built-in fallback theme.")
	Themes = {
		Nebula = {
			Accent = Color3.fromRGB(138, 107, 255), AccentDim = Color3.fromRGB(96, 74, 200),
			AccentHover = Color3.fromRGB(162, 135, 255), AccentText = Color3.fromRGB(255, 255, 255),
			WindowBg = Color3.fromRGB(17, 15, 26), WindowBg2 = Color3.fromRGB(11, 10, 19), WindowTrans = 0.03,
			Surface = Color3.fromRGB(255, 255, 255), SurfaceTrans = 0.94, SurfaceDeep = Color3.fromRGB(255, 255, 255),
			SurfaceDeepTrans = 0.905, SurfaceHover = 0.86, TopbarBg = Color3.fromRGB(20, 18, 30), TopbarTrans = 0.25,
			SidebarBg = Color3.fromRGB(15, 13, 23), SidebarTrans = 0.35, Divider = Color3.fromRGB(255, 255, 255), DividerTrans = 0.90,
			TextPrimary = Color3.fromRGB(247, 246, 255), TextSecondary = Color3.fromRGB(196, 191, 222), TextMuted = Color3.fromRGB(140, 134, 170),
			StrokeLight = Color3.fromRGB(255, 255, 255), StrokeLightTrans = 0.88, StrokeDark = Color3.fromRGB(110, 95, 175), StrokeDarkTrans = 0.68,
			Toggle = Color3.fromRGB(138, 107, 255), ToggleOff = Color3.fromRGB(58, 54, 80),
			SliderFill = Color3.fromRGB(138, 107, 255), SliderTrack = Color3.fromRGB(46, 42, 68),
			Ripple = Color3.fromRGB(205, 190, 255), Shadow = Color3.fromRGB(3, 2, 10), Glow = Color3.fromRGB(138, 107, 255),
		},
	}
end

------------------------------------------------------------------------
-- NOTIFICATIONS LAYER
------------------------------------------------------------------------
local _notifScreen = nil
local _notifHolder = nil

local function ensureNotifLayer()
	if _notifHolder and _notifHolder.Parent then return end
	_notifScreen = make("ScreenGui", {
		Name = "CelestialNotifs",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local parentSuccess = false
	if CoreGui then
		parentSuccess = pcall(function() _notifScreen.Parent = CoreGui end)
	end
	if not parentSuccess then
		parentSuccess = pcall(function() _notifScreen.Parent = game:GetService("CoreGui") end)
	end
	if _notifScreen.Parent then
		_notifHolder = make("Frame", {
			Name = "Holder",
			Size = UDim2.new(0, 310, 1, -20),
			Position = UDim2.new(1, -326, 0, 10),
			BackgroundTransparency = 1,
		}, _notifScreen)
		make("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
		}, _notifHolder)
	end
end

------------------------------------------------------------------------
-- CELESTIAL MAIN TABLE
------------------------------------------------------------------------
local Celestial = {}
Celestial.__index = Celestial
Celestial.Themes = Themes
Celestial.ActiveTheme = Themes.Nebula or Themes.Aurora or Themes.Void
Celestial.Windows = {}
Celestial.Flags = {}
Celestial.Version = VERSION
Celestial.Name = NAME
Celestial._flagRegistry = {}
Celestial._activeCfgFile = nil
Celestial.SoundEnabled = true

-- Expose loaded modules
Celestial.Serializer = Serializer
Celestial.NetworkTransformer = NetworkTransformer
Celestial.ErrorHandler = ErrorHandler

-- Initialize ErrorHandler instance
Celestial._errorHandler = nil
if ErrorHandler then
	local ok, eh = pcall(function() return ErrorHandler.New(Celestial) end)
	if ok then Celestial._errorHandler = eh end
end

-- Initialize NetworkTransformer instance
Celestial._networkTransformer = nil
if NetworkTransformer then
	local ok, nt = pcall(function() return NetworkTransformer.New(Config) end)
	if ok then Celestial._networkTransformer = nt end
end

-- Wrapped safecall using ErrorHandler when available
local function safeCall(fn, ...)
	if Celestial._errorHandler then
		return Celestial._errorHandler:Try(fn, {context = "Celestial"}, ...)
	end
	return safecall(fn, ...)
end

-- Serializer-aware auto-save
local function autoSaveFlags()
	if not Celestial._activeCfgFile then return end
	local ok, enc
	if Serializer then
		ok, enc = pcall(function() return Serializer.Serialize(Celestial.Flags, {PrettyPrint = false}) end)
	else
		ok, enc = pcall(function() return Http:JSONEncode(Celestial.Flags) end)
	end
	if ok then safecall(writefile, Celestial._activeCfgFile, enc) end
end

local function registerFlag(flagName, setFn)
	if not flagName then return end
	Celestial._flagRegistry[flagName] = setFn
end

function Celestial:LoadConfiguration()
	if not Celestial._activeCfgFile then
		warn("[Celestial] LoadConfiguration() called but no window has ConfigurationSaving enabled.")
		return false
	end
	if not safecall(isfile, Celestial._activeCfgFile) then return false end
	local raw = safecall(readfile, Celestial._activeCfgFile)
	if not raw then return false end

	local ok, decoded
	if Serializer then
		ok, decoded = pcall(function() return Serializer.Deserialize(raw) end)
	else
		ok, decoded = pcall(function() return Http:JSONDecode(raw) end)
	end

	if not ok or type(decoded) ~= "table" then
		warn("[Celestial] LoadConfiguration() failed to parse saved config.")
		return false
	end
	local restored = 0
	for flagName, value in pairs(decoded) do
		local setFn = Celestial._flagRegistry[flagName]
		if setFn then
			safecall(setFn, value)
			restored += 1
		end
		Celestial.Flags[flagName] = value
	end
	self:Notify({
		Title = "Configuration Loaded",
		Content = restored .. " setting(s) restored",
		Duration = 2.5,
		Type = "success",
	})
	return true
end

if not next(Themes) then
	warn("[Celestial] No themes loaded! Using fallback theme.")
	Celestial.ActiveTheme = {
		Accent = Color3.fromRGB(138, 107, 255),
		AccentHover = Color3.fromRGB(162, 135, 255),
		WindowBg = Color3.fromRGB(17, 15, 26),
	}
end

------------------------------------------------------------------------
-- ICONS + SOUND + TOOLTIP
------------------------------------------------------------------------
Celestial.Icons = {
	settings = "rbxassetid://10734950309",
	home = "rbxassetid://10723347849",
	search = "rbxassetid://10734950706",
	star = "rbxassetid://10734950309",
	bolt = "rbxassetid://10723347922",
	eye = "rbxassetid://10734943412",
	game = "rbxassetid://10723347849",
	info = "rbxassetid://10747384394",
	warning = "rbxassetid://10747384394",
	shield = "rbxassetid://10747384394",
	user = "rbxassetid://10747384394",
}
local function resolveIcon(icon)
	if not icon then return nil end
	if Celestial.Icons[icon] then return Celestial.Icons[icon] end
	return icon
end

local function playSound(id, volume)
	if not Celestial.SoundEnabled then return end
	safecall(function()
		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = volume or 0.4
		s.Parent = SoundService or CoreGui
		s:Play()
		game:GetService("Debris"):AddItem(s, 2)
	end)
end
local SOUND_CLICK = "rbxassetid://6895079853"
local SOUND_HOVER = "rbxassetid://6895079733"
local SOUND_TOGGLE = "rbxassetid://6895079966"
local SOUND_NOTIFY = "rbxassetid://6895079591"

-- Tooltip layer
local _tooltipGui, _tooltipLabel, _tooltipBg
local function ensureTooltipLayer()
	if _tooltipGui and _tooltipGui.Parent then return end
	_tooltipGui = make("ScreenGui", {
		Name = "CelestialTooltip",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})
	pcall(function() _tooltipGui.Parent = CoreGui end)
	_tooltipBg = make("Frame", {
		Name = "Tip",
		BackgroundColor3 = Color3.fromRGB(20, 18, 28),
		BackgroundTransparency = 0.05,
		Size = UDim2.new(0, 0, 0, 26),
		Visible = false,
		ZIndex = 500,
	}, _tooltipGui)
	corner(6, _tooltipBg)
	stroke(Color3.fromRGB(255, 255, 255), 1, 0.85, _tooltipBg)
	_tooltipLabel = make("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Color3.fromRGB(235, 235, 245),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		ZIndex = 501,
	}, _tooltipBg)
end

local function attachTooltip(inst, text)
	if not text or text == "" then return end
	inst.MouseEnter:Connect(function()
		ensureTooltipLayer()
		_tooltipLabel.Text = text
		local w = TextService:GetTextSize(text, 11, Enum.Font.Gotham, Vector2.new(400, 20)).X + 16
		_tooltipBg.Size = UDim2.new(0, w, 0, 26)
		_tooltipBg.Visible = true
	end)
	inst.MouseLeave:Connect(function()
		if _tooltipBg then _tooltipBg.Visible = false end
	end)
	inst.MouseMoved:Connect(function(x, y)
		if _tooltipBg and _tooltipBg.Visible then
			_tooltipBg.Position = UDim2.new(0, x + 16, 0, y + 16)
		end
	end)
end

------------------------------------------------------------------------
-- THEME REGISTRATION + NOTIFY + CONFIRM
------------------------------------------------------------------------
function Celestial:RegisterTheme(name, themeTable)
	local base = Themes.Nebula or {}
	local merged = {}
	for k, v in pairs(base) do merged[k] = v end
	for k, v in pairs(themeTable or {}) do merged[k] = v end
	Themes[name] = merged
	return merged
end

function Celestial:GetTooltipLayer()
	ensureTooltipLayer()
	return _tooltipGui
end

function Celestial:Notify(opts)
	ensureNotifLayer()
	if not _notifHolder then
		print("[Celestial Notify] " .. (opts.Title or "Notification") .. ": " .. (opts.Content or ""))
		return
	end

	local MAX_VISIBLE_NOTIFS = 5
	local existing = {}
	for _, c in ipairs(_notifHolder:GetChildren()) do
		if c:IsA("Frame") and c.Name == "Notif" then table.insert(existing, c) end
	end
	if #existing >= MAX_VISIBLE_NOTIFS then existing[1]:Destroy() end

	playSound(SOUND_NOTIFY)

	local t = Themes[opts.Theme or ""] or self.ActiveTheme
	local duration = opts.Duration or 4
	local notifType = opts.Type or "info"
	local accentMap = {
		info = t.Accent,
		success = Color3.fromRGB(58, 214, 130),
		warn = Color3.fromRGB(255, 178, 40),
		error = Color3.fromRGB(255, 82, 82),
	}
	local accent = accentMap[notifType] or t.Accent

	local card = make("Frame", {
		Name = "Notif",
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundColor3 = t.WindowBg,
		BackgroundTransparency = 0.06,
		ClipsDescendants = false,
	}, _notifHolder)
	corner(14, card)
	stroke(t.StrokeLight, 1, t.StrokeLightTrans, card)

	make("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = t.Surface,
		BackgroundTransparency = t.SurfaceDeepTrans,
		ZIndex = 0,
	}, card)

	local pill = make("Frame", {
		Size = UDim2.new(0, 3, 0.62, 0),
		Position = UDim2.new(0, 10, 0.19, 0),
		BackgroundColor3 = accent,
		ZIndex = 3,
	}, card)
	corner(4, pill)

	local iconMap = {info = "i", success = "v", warn = "!", error = "x"}
	local chip = make("Frame", {
		Position = UDim2.new(0, 20, 0, 12),
		Size = UDim2.new(0, 26, 0, 26),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.82,
		ZIndex = 3,
	}, card)
	corner(8, chip)
	make("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = iconMap[notifType] or "i",
		TextColor3 = accent,
		Font = Enum.Font.GothamBlack,
		TextSize = 14,
		ZIndex = 4,
	}, chip)

	make("TextLabel", {
		Position = UDim2.new(0, 56, 0, 11),
		Size = UDim2.new(1, -70, 0, 20),
		BackgroundTransparency = 1,
		Text = opts.Title or "",
		TextColor3 = t.TextPrimary,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	}, card)

	if opts.Content and #opts.Content > 0 then
		make("TextLabel", {
			Position = UDim2.new(0, 56, 0, 32),
			Size = UDim2.new(1, -70, 0, 30),
			BackgroundTransparency = 1,
			Text = opts.Content,
			TextColor3 = t.TextSecondary,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = 3,
		}, card)
	end

	local barTrack = make("Frame", {
		Position = UDim2.new(0, 12, 1, -6),
		Size = UDim2.new(1, -24, 0, 3),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.82,
		ZIndex = 3,
	}, card)
	corner(2, barTrack)
	local bar = make("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.1,
		ZIndex = 4,
	}, barTrack)
	corner(2, bar)

	card.Position = UDim2.new(1, 24, 0, 0)
	card.BackgroundTransparency = 1
	tw(card, T_SPRING_SOFT, {Position = UDim2.new(0, 0, 0, 0)})
	tw(card, T_MED, {BackgroundTransparency = 0.06})
	tw(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})

	task.delay(duration, function()
		tw(card, T_MED, {Position = UDim2.new(1, 24, 0, 0), BackgroundTransparency = 1})
		task.wait(0.3)
		if card and card.Parent then card:Destroy() end
	end)
end

function Celestial:Toast(text, notifType, duration)
	self:Notify({Title = text, Duration = duration or 2.5, Type = notifType or "info"})
end

function Celestial:Confirm(opts)
	local t = self.ActiveTheme
	local screen = make("ScreenGui", {
		Name = "CelestialConfirm",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 998,
	})
	pcall(function() screen.Parent = CoreGui end)

	local dim = make("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 400,
	}, screen)
	tw(dim, T_MED, {BackgroundTransparency = 0.45})

	local box = make("Frame", {
		Size = UDim2.new(0, 320, 0, 150),
		Position = UDim2.new(0.5, -160, 0.5, -75),
		BackgroundColor3 = t.WindowBg,
		BackgroundTransparency = 1,
		ZIndex = 401,
	}, screen)
	corner(14, box)
	stroke(t.StrokeLight, 1, t.StrokeLightTrans, box)
	box.Size = UDim2.new(0, 320, 0, 0)
	box.Position = UDim2.new(0.5, -160, 0.5, 0)

	make("TextLabel", {
		Position = UDim2.new(0, 20, 0, 18),
		Size = UDim2.new(1, -40, 0, 22),
		BackgroundTransparency = 1,
		Text = opts.Title or "Are you sure?",
		TextColor3 = t.TextPrimary,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 402,
	}, box)
	make("TextLabel", {
		Position = UDim2.new(0, 20, 0, 44),
		Size = UDim2.new(1, -40, 0, 50),
		BackgroundTransparency = 1,
		Text = opts.Content or "",
		TextColor3 = t.TextSecondary,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 402,
	}, box)

	local function finish(result)
		tw(dim, T_MED, {BackgroundTransparency = 1})
		tw(box, T_MED, {BackgroundTransparency = 1})
		task.delay(0.25, function() screen:Destroy() end)
		safecall(opts.Callback, result)
	end

	local cancelBtn = make("TextButton", {
		Size = UDim2.new(0, 120, 0, 36),
		Position = UDim2.new(0, 20, 1, -54),
		BackgroundColor3 = t.SurfaceDeep,
		BackgroundTransparency = 0.1,
		Text = opts.CancelText or "Cancel",
		TextColor3 = t.TextSecondary,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
		ZIndex = 402,
	}, box)
	corner(9, cancelBtn)
	cancelBtn.MouseButton1Click:Connect(function() playSound(SOUND_CLICK) finish(false) end)

	local confirmBtn = make("TextButton", {
		Size = UDim2.new(0, 120, 0, 36),
		Position = UDim2.new(1, -140, 1, -54),
		BackgroundColor3 = t.Accent,
		Text = opts.ConfirmText or "Confirm",
		TextColor3 = t.AccentText,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
		ZIndex = 402,
	}, box)
	corner(9, confirmBtn)
	confirmBtn.MouseButton1Click:Connect(function() playSound(SOUND_CLICK) finish(true) end)

	tw(box, T_SPRING_SOFT, {BackgroundTransparency = 0.05, Size = UDim2.new(0, 320, 0, 150), Position = UDim2.new(0.5, -160, 0.5, -75)})
	return screen
end


------------------------------------------------------------------------
-- CREATE WINDOW
------------------------------------------------------------------------
function Celestial:CreateWindow(opts)
	opts = opts or {}
	local t = Themes[opts.Theme or ""] or self.ActiveTheme
	self.ActiveTheme = t
	folder(FOLDER_ROOT)
	folder(FOLDER_CFG)
	local W = opts.Size and opts.Size.X or 620
	local H = opts.Size and opts.Size.Y or 420
	local sizeLimits = {
		min = Vector2.new(420, 300),
		max = Vector2.new(1200, 850),
	}

	-- Config saving setup
	local cfgOpts = opts.ConfigurationSaving
	local cfgFile, posFile
	local savedPos = nil
	if cfgOpts and cfgOpts.Enabled then
		cfgFile = FOLDER_CFG .. "/" .. (cfgOpts.FileName or opts.Name or "config") .. CFG_EXT
		posFile = FOLDER_CFG .. "/" .. (cfgOpts.FileName or opts.Name or "config") .. "_pos" .. CFG_EXT
		if safecall(isfile, posFile) then
			local raw = safecall(readfile, posFile)
			if raw then
				local ok, dec = pcall(function() return Http:JSONDecode(raw) end)
				if ok and dec and dec.w and dec.h then
					savedPos = dec
					W, H = dec.w, dec.h
				end
			end
		end
	end

	local screen = make("ScreenGui", {
		Name = opts.Name or NAME,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local parentSuccess = false
	if CoreGui then
		parentSuccess = pcall(function() screen.Parent = CoreGui end)
	end
	if not parentSuccess then
		parentSuccess = pcall(function() screen.Parent = game:GetService("CoreGui") end)
	end
	if not screen.Parent then
		error("[Celestial] Failed to parent ScreenGui to CoreGui")
	end

	local overlay = make("Frame", {
		Name = "Overlay",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 200,
	}, screen)

	local win = make("Frame", {
		Name = "Window",
		Size = UDim2.new(0, W, 0, H),
		Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
		BackgroundColor3 = t.WindowBg,
		BackgroundTransparency = t.WindowTrans,
		ClipsDescendants = true,
		ZIndex = 1,
	}, screen)
	corner(18, win)
	stroke(t.StrokeLight, 1, t.StrokeLightTrans, win)

	gradient(120, ColorSequence.new({
		ColorSequenceKeypoint.new(0, t.WindowBg2),
		ColorSequenceKeypoint.new(0.5, t.WindowBg),
		ColorSequenceKeypoint.new(1, t.WindowBg2),
	}), NumberSequence.new(0), win)

	make("ImageLabel", {
		Name = "Shadow",
		Size = UDim2.new(1, 90, 1, 90),
		Position = UDim2.new(0, -45, 0, -45),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = t.Shadow,
		ImageTransparency = 0.15,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		ZIndex = 0,
	}, win)

	make("ImageLabel", {
		Name = "AccentGlow",
		Size = UDim2.new(1, 0, 0, 220),
		Position = UDim2.new(0, 0, 0, -110),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = t.Glow,
		ImageTransparency = 0.88,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		ZIndex = 0,
	}, win)

	-- Topbar
	local topbar = make("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = t.TopbarBg,
		BackgroundTransparency = t.TopbarTrans,
		ZIndex = 5,
	}, win)
	corner(18, topbar)
	make("Frame", {
		Position = UDim2.new(0, 0, 1, -18),
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundColor3 = t.TopbarBg,
		BackgroundTransparency = t.TopbarTrans,
		ZIndex = 5,
	}, topbar)
	make("Frame", {
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = t.Accent,
		BackgroundTransparency = 0.75,
		ZIndex = 6,
	}, topbar)

	local accentDot = make("Frame", {
		Position = UDim2.new(0, 18, 0.5, -4),
		Size = UDim2.new(0, 8, 0, 8),
		BackgroundColor3 = t.Accent,
		ZIndex = 6,
	}, topbar)
	corner(4, accentDot)

	make("TextLabel", {
		Position = UDim2.new(0, 34, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = opts.Name or NAME,
		TextColor3 = t.TextPrimary,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
	}, topbar)

	local titleWidth = TextService:GetTextSize(opts.Name or NAME, 14, Enum.Font.GothamBold, Vector2.new(400, 20)).X
	local badge = make("Frame", {
		Size = UDim2.new(0, 46, 0, 18),
		Position = UDim2.new(0, 34 + titleWidth + 10, 0.5, -9),
		BackgroundColor3 = t.Accent,
		BackgroundTransparency = 0.82,
		ZIndex = 6,
	}, topbar)
	corner(6, badge)
	stroke(t.Accent, 1, 0.65, badge)
	make("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "v" .. VERSION,
		TextColor3 = t.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		ZIndex = 7,
	}, badge)

	local function makeCtrl(iconText, hoverColor, xPos, onClick)
		local btn = make("TextButton", {
			Size = UDim2.new(0, 28, 0, 28),
			Position = UDim2.new(1, xPos, 0.5, -14),
			BackgroundColor3 = t.Surface,
			BackgroundTransparency = 1,
			Text = iconText,
			TextColor3 = t.TextMuted,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			AutoButtonColor = false,
			ZIndex = 6,
		}, topbar)
		corner(9, btn)
		btn.MouseButton1Click:Connect(onClick)
		btn.MouseEnter:Connect(function()
			tw(btn, T_FAST, {BackgroundTransparency = 0.82, TextColor3 = hoverColor})
		end)
		btn.MouseLeave:Connect(function()
			tw(btn, T_FAST, {BackgroundTransparency = 1, TextColor3 = t.TextMuted})
		end)
		return btn
	end

	local minimised = false
	makeCtrl("×", Color3.fromRGB(255, 100, 90), -36, function()
		tw(win, T_MED, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1})
		task.wait(0.24)
		screen:Destroy()
	end)

	makeCtrl("–", t.Accent, -68, function()
		minimised = not minimised
		tw(win, T_MED, {Size = minimised and UDim2.new(0, W, 0, 50) or UDim2.new(0, W, 0, H)})
	end)

	-- Dragging
	do
		local drag, startMouse, startPos = false, nil, nil
		topbar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				drag = true
				startMouse = i.Position
				startPos = win.Position
			end
		end)
		topbar.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				if drag then
					local SNAP = 24
					local screenSize = overlay.AbsoluteSize
					local pos = win.Position
					local size = win.AbsoluteSize
					local x, y = pos.X.Offset, pos.Y.Offset
					local snapped = false
					if x < SNAP then x = 0 snapped = true end
					if x + size.X > screenSize.X - SNAP then x = screenSize.X - size.X snapped = true end
					if y < SNAP then y = 0 snapped = true end
					if snapped then
						tw(win, T_FAST, {Position = UDim2.new(pos.X.Scale, x, pos.Y.Scale, y)})
					end
				end
				drag = false
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - startMouse
				local newX = startPos.X.Offset + d.X
				local newY = startPos.Y.Offset + d.Y
				local screenSize = overlay.AbsoluteSize
				local minVisible = 40
				newX = math.clamp(newX, minVisible - win.AbsoluteSize.X, screenSize.X - minVisible)
				newY = math.clamp(newY, 0, screenSize.Y - minVisible)
				win.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
			end
		end)
	end

	-- Sidebar
	local sidebar = make("Frame", {
		Name = "Sidebar",
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(0, 168, 1, -50),
		BackgroundColor3 = t.SidebarBg,
		BackgroundTransparency = t.SidebarTrans,
		ClipsDescendants = true,
		ZIndex = 4,
	}, win)
	make("Frame", {
		Position = UDim2.new(1, -1, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = t.Accent,
		BackgroundTransparency = 0.85,
		ZIndex = 4,
	}, sidebar)

	-- Search box
	local searchBox = make("Frame", {
		Name = "SearchBox",
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(1, -20, 0, 30),
		BackgroundColor3 = t.Surface,
		BackgroundTransparency = t.SurfaceDeepTrans,
		Visible = true,
		ZIndex = 5,
	}, sidebar)
	corner(8, searchBox)
	stroke(t.StrokeLight, 1, t.StrokeLightTrans, searchBox)
	local searchInput = make("TextBox", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search tabs...",
		PlaceholderColor3 = t.TextMuted,
		TextColor3 = t.TextPrimary,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		ClearTextOnFocus = false,
		ZIndex = 6,
	}, searchBox)

	local tabHolder = make("Frame", {
		Name = "TabHolder",
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(1, 0, 1, -54),
		BackgroundTransparency = 1,
	}, sidebar)
	listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 4, tabHolder)
	pad(10, 10, 0, 10, tabHolder)

	local content = make("Frame", {
		Name = "Content",
		Position = UDim2.new(0, 169, 0, 50),
		Size = UDim2.new(1, -169, 1, -50),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 2,
	}, win)

	-- Resize grip
	local resizeGrip = make("TextButton", {
		Name = "ResizeGrip",
		Size = UDim2.new(0, 18, 0, 18),
		Position = UDim2.new(1, -18, 1, -18),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 20,
	}, win)
	make("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "⌟",
		TextColor3 = t.TextMuted,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Rotation = 0,
		ZIndex = 21,
	}, resizeGrip)
	do
		local resizing, startMouse, startSize = false, nil, nil
		resizeGrip.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startMouse = i.Position
				startSize = win.AbsoluteSize
			end
		end)
		resizeGrip.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				resizing = false
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - startMouse
				local newW = math.clamp(startSize.X + d.X, sizeLimits.min.X, sizeLimits.max.X)
				local newH = math.clamp(startSize.Y + d.Y, sizeLimits.min.Y, sizeLimits.max.Y)
				win.Size = UDim2.new(0, newW, 0, newH)
			end
		end)
	end

	-- Toggle keybind
	local kb = opts.Keybind or Enum.KeyCode.LeftAlt
	UIS.InputBegan:Connect(function(i, gpe)
		if gpe then return end
		if i.KeyCode == kb then win.Visible = not win.Visible end
	end)

	-- Entrance animation
	win.Size = UDim2.new(0, 0, 0, 0)
	win.Position = UDim2.new(0.5, 0, 0.5, 0)
	win.BackgroundTransparency = 1
	task.wait()
	local targetPos = savedPos and savedPos.x and savedPos.y
		and UDim2.new(0, savedPos.x, 0, savedPos.y)
		or UDim2.new(0.5, -W/2, 0.5, -H/2)
	tw(win, T_SPRING, {Size = UDim2.new(0, W, 0, H), Position = targetPos, BackgroundTransparency = t.WindowTrans})

	-- Window object
	local Window = {}
	Window._theme = t
	Window._screen = screen
	Window._win = win
	Window._sidebar = tabHolder
	Window._content = content
	Window._tabs = {}
	Window._tabBtns = {}
	Window._tabFrames = {}
	Window._activeTab = nil
	Window._themeCallbacks = {}
	Window._overlay = overlay
	Window._openPopups = {}
	Window._minSize = sizeLimits.min
	Window._maxSize = sizeLimits.max

	function Window:SetSizeLimits(min, max)
		if min then sizeLimits.min = min end
		if max then sizeLimits.max = max end
	end

	-- Live tab search
	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(searchInput.Text)
		for _, btn in ipairs(Window._tabBtns) do
			if query == "" then
				btn.Visible = true
			else
				btn.Visible = string.find(string.lower(btn.Name), query, 1, true) ~= nil
			end
		end
	end)

	-- UI Scale
	local uiScale = make("UIScale", {Scale = 1}, win)
	function Window:SetScale(factor)
		factor = math.clamp(factor, 0.75, 1.5)
		tw(uiScale, T_MED, {Scale = factor})
	end

	function Window:_onThemeChange(fn)
		table.insert(self._themeCallbacks, fn)
	end
	function Window:_applyTheme(newTheme)
		for _, cb in ipairs(self._themeCallbacks) do safecall(cb, newTheme) end
	end
	Window:_onThemeChange(function(newTheme)
		tw(win, T_MED, {BackgroundColor3 = newTheme.WindowBg, BackgroundTransparency = newTheme.WindowTrans})
		tw(topbar, T_MED, {BackgroundColor3 = newTheme.TopbarBg, BackgroundTransparency = newTheme.TopbarTrans})
	end)

	-- Popup outside-click closer
	local function pointInside(pos, inst)
		if not inst then return false end
		local absPos = inst.AbsolutePosition
		local absSize = inst.AbsoluteSize
		return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
	end
	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		for _, popup in ipairs(Window._openPopups) do
			if popup._isOpen and popup._clickOutside then
				local pos = input.Position
				if not pointInside(pos, popup._container) and not pointInside(pos, popup._trigger) then
					popup._clickOutside()
				end
			end
		end
	end)

	-- Config persistence
	if cfgOpts and cfgOpts.Enabled then
		Celestial._activeCfgFile = cfgFile
		function Window:SaveConfig(data)
			local ok, enc
			if Serializer then
				ok, enc = pcall(function() return Serializer.Serialize(data, {PrettyPrint = false}) end)
			else
				ok, enc = pcall(function() return Http:JSONEncode(data) end)
			end
			if ok then safecall(writefile, cfgFile, enc) end
		end
		function Window:LoadConfig()
			if safecall(isfile, cfgFile) then
				local raw = safecall(readfile, cfgFile)
				if raw then
					local ok, dec
					if Serializer then
						ok, dec = pcall(function() return Serializer.Deserialize(raw) end)
					else
						ok, dec = pcall(function() return Http:JSONDecode(raw) end)
					end
					if ok then return dec end
				end
			end
		end
		local function savePosition()
			local pos, size = win.Position, win.AbsoluteSize
			local ok, enc = pcall(function()
				return Http:JSONEncode({x = pos.X.Offset, y = pos.Y.Offset, w = size.X, h = size.Y})
			end)
			if ok then safecall(writefile, posFile, enc) end
		end
		resizeGrip.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				task.defer(savePosition)
			end
		end)
		topbar.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				task.defer(savePosition)
			end
		end)
	end

	function Window:SelectTab(index)
		local tab = self._tabs[index]
		if tab and tab._activate then tab._activate() end
	end

	-- Tab Groups
	function Window:CreateTabGroup(name)
		local theme = self._theme
		local header = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
		}, self._sidebar)
		local headerLabel = make("TextLabel", {
			Size = UDim2.new(1, -20, 1, 0),
			BackgroundTransparency = 1,
			Text = string.upper(name),
			TextColor3 = theme.TextMuted,
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, header)
		local chevron = make("TextLabel", {
			Position = UDim2.new(1, -16, 0, 0),
			Size = UDim2.new(0, 16, 1, 0),
			BackgroundTransparency = 1,
			Text = "⌄",
			TextColor3 = theme.TextMuted,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
		}, header)
		local subContainer = make("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, self._sidebar)
		listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 4, subContainer)

		local collapsed = false
		header.MouseButton1Click:Connect(function()
			collapsed = not collapsed
			subContainer.Visible = not collapsed
			tw(chevron, T_FAST, {Rotation = collapsed and -90 or 0})
		end)
		self:_onThemeChange(function(newTheme)
			headerLabel.TextColor3 = newTheme.TextMuted
			chevron.TextColor3 = newTheme.TextMuted
		end)

		local Group = {}
		function Group:CreateTab(opts)
			return Window:CreateTab(opts, subContainer)
		end
		return Group
	end


	-- Create Tab
	function Window:CreateTab(tabOpts, parentOverride)
		tabOpts = tabOpts or {}
		local tabName = tabOpts.Name or "Tab"
		local theme = self._theme

		local btn = make("TextButton", {
			Name = tabName,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = theme.Accent,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 5,
		}, parentOverride or self._sidebar)
		corner(10, btn)

		local textOffset = 14
		local textWidth = -14
		if tabOpts.Icon then
			textOffset = 38
			textWidth = -38
			if tabOpts.Icon:find("rbxassetid://") or tabOpts.Icon:match("^%d+$") then
				make("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 12, 0.5, -9),
					BackgroundTransparency = 1,
					Image = tabOpts.Icon:match("^%d+$") and "rbxassetid://" .. tabOpts.Icon or tabOpts.Icon,
					ImageColor3 = theme.TextMuted,
					ZIndex = 6,
				}, btn)
			else
				make("TextLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 12, 0.5, -9),
					BackgroundTransparency = 1,
					Text = tabOpts.Icon,
					TextColor3 = theme.TextMuted,
					Font = Enum.Font.Gotham,
					TextSize = 14,
					ZIndex = 6,
				}, btn)
			end
		end

		local btnLabel = make("TextLabel", {
			Position = UDim2.new(0, textOffset, 0, 0),
			Size = UDim2.new(1, textWidth, 1, 0),
			BackgroundTransparency = 1,
			Text = tabName,
			TextColor3 = theme.TextMuted,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 6,
		}, btn)

		local accentBar = make("Frame", {
			Size = UDim2.new(0, 3, 0, 0),
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = theme.Accent,
			ZIndex = 6,
		}, btn)
		corner(4, accentBar)

		local frame = make("ScrollingFrame", {
			Name = tabName .. "_Frame",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = theme.Accent,
			ScrollBarImageTransparency = 0.4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
			ZIndex = 3,
		}, self._content)
		local layout = listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 8, frame)
		pad(16, 16, 14, 16, frame)

		local function updateCanvas()
			frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
		end
		updateCanvas()
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

		table.insert(self._tabBtns, btn)
		table.insert(self._tabFrames, frame)

		local function activate()
			for _, b in ipairs(self._tabBtns) do
				local bar_ = b:FindFirstChild("Frame")
				tw(b, T_FAST, {BackgroundTransparency = 1})
				if bar_ then tw(bar_, T_FAST, {Size = UDim2.new(0, 3, 0, 0)}) end
				local lbl = b:FindFirstChildWhichIsA("TextLabel")
				if lbl then tw(lbl, T_FAST, {TextColor3 = theme.TextMuted, Font = Enum.Font.Gotham}) end
			end
			for _, f in ipairs(self._tabFrames) do f.Visible = false end
			tw(btn, T_FAST, {BackgroundTransparency = 0.88})
			tw(accentBar, T_MED, {Size = UDim2.new(0, 3, 0, 18)})
			tw(btnLabel, T_FAST, {TextColor3 = theme.TextPrimary})
			btnLabel.Font = Enum.Font.GothamBold
			frame.Visible = true
			self._activeTab = frame
			task.defer(updateCanvas)
		end

		btn.MouseButton1Click:Connect(activate)
		btn.MouseEnter:Connect(function() if frame.Visible then return end tw(btn, T_FAST, {BackgroundTransparency = 0.94}) end)
		btn.MouseLeave:Connect(function() if frame.Visible then return end tw(btn, T_FAST, {BackgroundTransparency = 1}) end)

		local Tab = {}
		Tab._frame = frame
		Tab._window = self
		Tab._layoutOrder = 0
		Tab._activate = activate

		local function nextOrder()
			Tab._layoutOrder += 1
			return Tab._layoutOrder
		end

		local function glassRow(height, parent)
			local row = make("Frame", {
				Size = UDim2.new(1, 0, 0, height or 50),
				BackgroundColor3 = theme.Surface,
				BackgroundTransparency = theme.SurfaceDeepTrans,
				ClipsDescendants = false,
				LayoutOrder = nextOrder(),
			}, parent or frame)
			corner(12, row)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, row)
			return row
		end

		local function ripple(parent, x, y)
			local r = make("Frame", {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0, x, 0, y),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = theme.Ripple,
				BackgroundTransparency = 0.65,
				ZIndex = 20,
			}, parent)
			corner(999, r)
			tw(r, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 130, 0, 130), BackgroundTransparency = 1})
			task.delay(0.45, function() if r and r.Parent then r:Destroy() end end)
		end

		function Tab:RefreshCanvas()
			local lay = self._frame:FindFirstChildOfClass("UIListLayout")
			if lay then self._frame.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 24) end
		end

		function Tab:CreateSection(text)
			local lbl = make("TextLabel", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				Text = string.upper(text),
				TextColor3 = theme.TextMuted,
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = nextOrder(),
			}, frame)
			self._window:_onThemeChange(function(newTheme) lbl.TextColor3 = newTheme.TextMuted end)
		end

		function Tab:CreateDivider()
			local line = make("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = theme.Divider,
				BackgroundTransparency = theme.DividerTrans,
				LayoutOrder = nextOrder(),
			}, frame)
			self._window:_onThemeChange(function(newTheme)
				line.BackgroundColor3 = newTheme.Divider
				line.BackgroundTransparency = newTheme.DividerTrans
			end)
		end

		function Tab:CreateLabel(text)
			local lbl = make("TextLabel", {
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = theme.TextSecondary,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				LayoutOrder = nextOrder(),
			}, frame)
			self._window:_onThemeChange(function(newTheme) lbl.TextColor3 = newTheme.TextSecondary end)
			return {Set = function(newText) lbl.Text = newText end}
		end

		function Tab:CreateButton(o)
			local row = glassRow(50)
			row.ClipsDescendants = true
			make("TextLabel", {
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -104, 1, 0),
				BackgroundTransparency = 1,
				Text = o.Name,
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			if o.Description then
				make("TextLabel", {
					Position = UDim2.new(0, 16, 0, 29),
					Size = UDim2.new(1, -104, 0, 16),
					BackgroundTransparency = 1,
					Text = o.Description,
					TextColor3 = theme.TextMuted,
					Font = Enum.Font.Gotham,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, row)
				row.Size = UDim2.new(1, 0, 0, 62)
			end
			local cBtn = make("TextButton", {
				Size = UDim2.new(0, 76, 0, 30),
				Position = UDim2.new(1, -88, 0.5, -15),
				BackgroundColor3 = theme.Accent,
				BackgroundTransparency = 0,
				Text = "Run",
				TextColor3 = theme.AccentText,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
				ZIndex = 5,
			}, row)
			corner(9, cBtn)
			gradient(90, ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
				ColorSequenceKeypoint.new(1, theme.Accent),
			}), NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.75),
				NumberSequenceKeypoint.new(1, 1),
			}), cBtn)
			cBtn.MouseButton1Click:Connect(function()
				tw(cBtn, T_FAST, {Size = UDim2.new(0, 72, 0, 28), Position = UDim2.new(1, -86, 0.5, -14)})
				ripple(row, cBtn.AbsolutePosition.X - row.AbsolutePosition.X + 38, 25)
				task.delay(0.1, function() tw(cBtn, T_SPRING, {Size = UDim2.new(0, 76, 0, 30), Position = UDim2.new(1, -88, 0.5, -15)}) end)
				playSound(SOUND_CLICK)
				safecall(o.Callback)
			end)
			cBtn.MouseEnter:Connect(function() tw(cBtn, T_FAST, {BackgroundColor3 = theme.AccentHover}) end)
			cBtn.MouseLeave:Connect(function() tw(cBtn, T_FAST, {BackgroundColor3 = theme.Accent}) end)
			row.MouseEnter:Connect(function() tw(row, T_FAST, {BackgroundTransparency = theme.SurfaceTrans}) end)
			row.MouseLeave:Connect(function() tw(row, T_FAST, {BackgroundTransparency = theme.SurfaceDeepTrans}) end)
			self._window:_onThemeChange(function(newTheme)
				tw(cBtn, T_MED, {BackgroundColor3 = newTheme.Accent})
				cBtn.TextColor3 = newTheme.AccentText
			end)
		end

		function Tab:CreateToggle(o)
			local hasDesc = o.Description and o.Description ~= ""
			local state = o.Default or false
			local row = glassRow(hasDesc and 62 or 50)
			make("TextLabel", {
				Position = UDim2.new(0, 16, 0, 9),
				Size = UDim2.new(1, -84, 0, 18),
				BackgroundTransparency = 1,
				Text = o.Name,
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			if hasDesc then
				make("TextLabel", {
					Position = UDim2.new(0, 16, 0, 29),
					Size = UDim2.new(1, -84, 0, 16),
					BackgroundTransparency = 1,
					Text = o.Description,
					TextColor3 = theme.TextMuted,
					Font = Enum.Font.Gotham,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, row)
			end
			local track = make("Frame", {
				Size = UDim2.new(0, 46, 0, 26),
				Position = UDim2.new(1, -60, 0.5, -13),
				BackgroundColor3 = state and theme.Toggle or theme.ToggleOff,
				BackgroundTransparency = 0,
			}, row)
			corner(13, track)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, track)
			local knob = make("Frame", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			}, track)
			corner(10, knob)
			local clickArea = make("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
			}, row)
			local function setState(val)
				state = val
				tw(track, T_MED, {BackgroundColor3 = val and theme.Toggle or theme.ToggleOff})
				tw(knob, T_SPRING, {Position = val and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10), Size = UDim2.new(0, 20, 0, 20)})
				playSound(SOUND_TOGGLE)
				safecall(o.Callback, val)
				if o.Flag then Celestial.Flags[o.Flag] = val end
				if o.Flag then autoSaveFlags() end
			end
			clickArea.MouseButton1Down:Connect(function() tw(knob, T_FAST, {Size = UDim2.new(0, 24, 0, 20)}) end)
			clickArea.MouseButton1Up:Connect(function() setState(not state) end)
			if o.Flag then Celestial.Flags[o.Flag] = state end
			self._window:_onThemeChange(function(newTheme)
				tw(track, T_MED, {BackgroundColor3 = state and newTheme.Toggle or newTheme.ToggleOff})
				local s = track:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeLight end
			end)
			if o.Flag then registerFlag(o.Flag, setState) end
			return {Set = setState}
		end

		function Tab:CreateSlider(o)
			local hasDesc = o.Description and o.Description ~= ""
			local mn, mx = o.Min, o.Max
			local step = o.Step or 1
			local value = math.clamp(o.Default or mn, mn, mx)
			local row = glassRow(hasDesc and 76 or 66)
			make("TextLabel", {
				Position = UDim2.new(0, 16, 0, 9),
				Size = UDim2.new(1, -84, 0, 18),
				BackgroundTransparency = 1,
				Text = o.Name,
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			if hasDesc then
				make("TextLabel", {
					Position = UDim2.new(0, 16, 0, 27),
					Size = UDim2.new(1, -84, 0, 16),
					BackgroundTransparency = 1,
					Text = o.Description,
					TextColor3 = theme.TextMuted,
					Font = Enum.Font.Gotham,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, row)
			end
			local valChip = make("Frame", {
				Position = UDim2.new(1, -74, 0, 8),
				Size = UDim2.new(0, 58, 0, 20),
				BackgroundColor3 = theme.Accent,
				BackgroundTransparency = 0.84,
			}, row)
			corner(6, valChip)
			local valLabel = make("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = tostring(value) .. (o.Suffix or ""),
				TextColor3 = theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
			}, valChip)
			local trackY = hasDesc and 52 or 42
			local trackBg = make("Frame", {
				Position = UDim2.new(0, 16, 0, trackY),
				Size = UDim2.new(1, -32, 0, 5),
				BackgroundColor3 = theme.SliderTrack,
				BackgroundTransparency = 0.15,
			}, row)
			corner(5, trackBg)
			local fill = make("Frame", {
				Size = UDim2.new((value - mn)/(mx - mn), 0, 1, 0),
				BackgroundColor3 = theme.SliderFill,
			}, trackBg)
			corner(5, fill)
			gradient(0, ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.AccentDim),
				ColorSequenceKeypoint.new(1, theme.Accent),
			}), NumberSequence.new(0), fill)
			local thumb = make("Frame", {
				Size = UDim2.new(0, 15, 0, 15),
				Position = UDim2.new((value - mn)/(mx - mn), -7, 0.5, -7),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 5,
			}, trackBg)
			corner(8, thumb)
			stroke(theme.Accent, 2, 0.1, thumb)
			local dragging = false
			local function snapTo(v)
				v = math.clamp(math.round((v - mn) / step) * step + mn, mn, mx)
				value = v
				local pct = (v - mn) / (mx - mn)
				tw(fill, T_FAST, {Size = UDim2.new(pct, 0, 1, 0)})
				tw(thumb, T_FAST, {Position = UDim2.new(pct, -7, 0.5, -7)})
				valLabel.Text = tostring(v) .. (o.Suffix or "")
				safecall(o.Callback, v)
				if o.Flag then Celestial.Flags[o.Flag] = v end
				if o.Flag then autoSaveFlags() end
			end
			local function onInput(input)
				local rel = math.clamp((input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
				snapTo(mn + rel * (mx - mn))
			end
			trackBg.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					onInput(i)
					tw(thumb, T_FAST, {Size = UDim2.new(0, 19, 0, 19), Position = UDim2.new((value-mn)/(mx-mn), -9, 0.5, -9)})
				end
			end)
			UIS.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then onInput(i) end
			end)
			UIS.InputEnded:Connect(function(i)
				if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and dragging then
					dragging = false
					tw(thumb, T_FAST, {Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new((value-mn)/(mx-mn), -7, 0.5, -7)})
				end
			end)
			if o.Flag then Celestial.Flags[o.Flag] = value end
			self._window:_onThemeChange(function(newTheme)
				tw(trackBg, T_MED, {BackgroundColor3 = newTheme.SliderTrack})
				tw(fill, T_MED, {BackgroundColor3 = newTheme.SliderFill})
				valLabel.TextColor3 = newTheme.Accent
				valChip.BackgroundColor3 = newTheme.Accent
				local s = thumb:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.Accent end
			end)
			if o.Flag then registerFlag(o.Flag, snapTo) end
			return {Set = snapTo}
		end

		function Tab:CreateInput(o)
			local row = glassRow(50)
			make("TextLabel", {
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(0, 110, 1, 0),
				BackgroundTransparency = 1,
				Text = o.Name,
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			local field = make("Frame", {
				Position = UDim2.new(0, 130, 0.5, -15),
				Size = UDim2.new(1, -146, 0, 30),
				BackgroundColor3 = theme.SurfaceDeep,
				BackgroundTransparency = theme.SurfaceDeepTrans,
			}, row)
			corner(8, field)
			stroke(theme.StrokeDark, 1, theme.StrokeDarkTrans, field)
			local box = make("TextBox", {
				Size = UDim2.new(1, -18, 1, 0),
				Position = UDim2.new(0, 9, 0, 0),
				BackgroundTransparency = 1,
				Text = "",
				PlaceholderText = o.Placeholder or "",
				PlaceholderColor3 = theme.TextMuted,
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				ClearTextOnFocus = false,
			}, field)
			box.Focused:Connect(function()
				local s = field:FindFirstChildWhichIsA("UIStroke")
				if s then tw(s, T_FAST, {Color = theme.Accent, Transparency = 0.2}) end
			end)
			box.FocusLost:Connect(function(enter)
				local s = field:FindFirstChildWhichIsA("UIStroke")
				if s then tw(s, T_FAST, {Color = theme.StrokeDark, Transparency = theme.StrokeDarkTrans}) end
				if enter or not o.Numeric then
					local val = box.Text
					if o.Numeric then val = tostring(tonumber(val) or 0) end
					safecall(o.Callback, val)
					if o.Flag then Celestial.Flags[o.Flag] = val end
					if o.Flag then autoSaveFlags() end
				end
			end)
			self._window:_onThemeChange(function(newTheme)
				field.BackgroundColor3 = newTheme.SurfaceDeep
				local s = field:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeDark end
				box.TextColor3 = newTheme.TextPrimary
				box.PlaceholderColor3 = newTheme.TextMuted
			end)
			local inputSet = function(val)
				box.Text = tostring(val)
				safecall(o.Callback, val)
				if o.Flag then Celestial.Flags[o.Flag] = val end
				if o.Flag then autoSaveFlags() end
			end
			if o.Flag then registerFlag(o.Flag, inputSet) end
			return {Set = inputSet}
		end


		function Tab:CreateDropdown(o)
			local selected = o.Default or (o.Options[1] or "")
			local open = false
			local multi = o.Multi or false
			local multiSel = {}
			local container = make("Frame", {
				Name = "Dropdown",
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = theme.Surface,
				BackgroundTransparency = theme.SurfaceDeepTrans,
				ClipsDescendants = false,
				ZIndex = 10,
				LayoutOrder = nextOrder(),
			}, frame)
			corner(12, container)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, container)
			make("TextLabel", {
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(0, 110, 1, 0),
				BackgroundTransparency = 1,
				Text = o.Name,
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 11,
			}, container)
			local selBtn = make("TextButton", {
				Position = UDim2.new(0, 130, 0.5, -15),
				Size = UDim2.new(1, -146, 0, 30),
				BackgroundColor3 = theme.SurfaceDeep,
				BackgroundTransparency = theme.SurfaceDeepTrans,
				Text = selected,
				TextColor3 = theme.TextSecondary,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				AutoButtonColor = false,
				ZIndex = 11,
			}, container)
			corner(8, selBtn)
			stroke(theme.StrokeDark, 1, theme.StrokeDarkTrans, selBtn)
			pad(11, 26, 0, 0, selBtn)
			local chev = make("TextLabel", {
				Position = UDim2.new(1, -22, 0.5, -7),
				Size = UDim2.new(0, 14, 0, 14),
				BackgroundTransparency = 1,
				Text = "⌄",
				TextColor3 = theme.TextMuted,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				ZIndex = 12,
			}, selBtn)
			local panel = make("Frame", {
				BackgroundColor3 = theme.WindowBg,
				BackgroundTransparency = 0.03,
				ClipsDescendants = true,
				Visible = false,
				ZIndex = 250,
			}, self._window._overlay)
			corner(10, panel)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, panel)
			listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 3, panel)
			pad(5, 5, 5, 5, panel)
			local popupEntry = {_isOpen = false, _container = panel, _trigger = selBtn, _clickOutside = nil}
			table.insert(self._window._openPopups, popupEntry)
			local function positionPanel()
				local absPos = selBtn.AbsolutePosition
				local absSize = selBtn.AbsoluteSize
				local screenSize = self._window._overlay.AbsoluteSize
				local panelH = math.max(panel.Size.Y.Offset, #o.Options * 35 + 10)
				local px = math.clamp(absPos.X, 6, math.max(6, screenSize.X - absSize.X - 6))
				local py = absPos.Y + absSize.Y + 6
				if py + panelH > screenSize.Y - 6 and absPos.Y - panelH - 6 >= 6 then
					py = absPos.Y - panelH - 6
				end
				panel.Position = UDim2.new(0, px, 0, py)
				panel.Size = UDim2.new(0, absSize.X, 0, panel.Size.Y.Offset)
			end
			local trackConn1, trackConn2
			local function startTracking()
				if trackConn1 then trackConn1:Disconnect() end
				if trackConn2 then trackConn2:Disconnect() end
				trackConn1 = self._window._win:GetPropertyChangedSignal("Position"):Connect(function()
					if not popupEntry._isOpen then return end
					positionPanel()
				end)
				trackConn2 = self._frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
					if not popupEntry._isOpen then return end
					positionPanel()
				end)
			end
			local function stopTracking()
				if trackConn1 then trackConn1:Disconnect() trackConn1 = nil end
				if trackConn2 then trackConn2:Disconnect() trackConn2 = nil end
			end
			local function buildItems(opts_)
				local currentTheme = self._window._theme
				for _, c in ipairs(panel:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				for idx, opt in ipairs(opts_) do
					local isActive = multi and multiSel[opt] or (not multi and opt == selected)
					local item = make("TextButton", {
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundColor3 = isActive and currentTheme.Accent or currentTheme.Surface,
						BackgroundTransparency = isActive and 0.1 or 0.96,
						Text = opt,
						TextColor3 = isActive and currentTheme.AccentText or currentTheme.TextSecondary,
						Font = isActive and Enum.Font.GothamBold or Enum.Font.Gotham,
						TextSize = 12,
						AutoButtonColor = false,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 251,
						LayoutOrder = idx,
					}, panel)
					corner(7, item)
					pad(12, 0, 0, 0, item)
					item.MouseEnter:Connect(function()
						if not isActive then tw(item, T_FAST, {BackgroundTransparency = 0.82}) end
					end)
					item.MouseLeave:Connect(function()
						if not isActive then tw(item, T_FAST, {BackgroundTransparency = 0.96}) end
					end)
					item.MouseButton1Click:Connect(function()
						if multi then
							multiSel[opt] = not multiSel[opt]
							local chosen = {}
							for k, v in pairs(multiSel) do if v then table.insert(chosen, k) end end
							selected = table.concat(chosen, ", ")
							selBtn.Text = #chosen > 0 and selected or (o.Options[1] or "")
							safecall(o.Callback, chosen)
							if o.Flag then Celestial.Flags[o.Flag] = chosen end
							if o.Flag then autoSaveFlags() end
						else
							selected = opt
							selBtn.Text = opt
							safecall(o.Callback, opt)
							if o.Flag then Celestial.Flags[o.Flag] = opt end
							if o.Flag then autoSaveFlags() end
							open = false
							popupEntry._isOpen = false
							stopTracking()
							tw(chev, T_FAST, {Rotation = 0})
							tw(panel, T_FAST, {Size = UDim2.new(0, panel.Size.X.Offset, 0, 0)})
							task.delay(0.18, function() panel.Visible = false end)
						end
						buildItems(opts_)
					end)
				end
				local totalH = #opts_ * 35 + 10
				panel.Size = UDim2.new(0, panel.Size.X.Offset, 0, totalH)
			end
			local function closeDropdown()
				if not open then return end
				open = false
				popupEntry._isOpen = false
				stopTracking()
				tw(chev, T_FAST, {Rotation = 0})
				tw(panel, T_FAST, {Size = UDim2.new(0, panel.Size.X.Offset, 0, 0)})
				task.delay(0.18, function() panel.Visible = false end)
			end
			popupEntry._clickOutside = closeDropdown
			selBtn.MouseButton1Click:Connect(function()
				open = not open
				if open then
					positionPanel()
					buildItems(o.Options)
					panel.Visible = true
					panel.Size = UDim2.new(0, panel.Size.X.Offset, 0, 0)
					popupEntry._isOpen = true
					startTracking()
					tw(panel, T_SPRING_SOFT, {Size = UDim2.new(0, panel.Size.X.Offset, 0, #o.Options * 35 + 10)})
					tw(chev, T_MED, {Rotation = 180})
				else
					closeDropdown()
				end
			end)
			if o.Flag then Celestial.Flags[o.Flag] = selected end
			self._window:_onThemeChange(function(newTheme)
				container.BackgroundColor3 = newTheme.Surface
				local s = container:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeLight end
				selBtn.BackgroundColor3 = newTheme.SurfaceDeep
				local s2 = selBtn:FindFirstChildWhichIsA("UIStroke")
				if s2 then s2.Color = newTheme.StrokeDark end
				selBtn.TextColor3 = newTheme.TextSecondary
				chev.TextColor3 = newTheme.TextMuted
				panel.BackgroundColor3 = newTheme.WindowBg
				local s3 = panel:FindFirstChildWhichIsA("UIStroke")
				if s3 then s3.Color = newTheme.StrokeLight end
				if open then buildItems(o.Options) end
			end)
			local dropdownSet = function(val)
				selected = val
				selBtn.Text = val
				safecall(o.Callback, val)
				if o.Flag then Celestial.Flags[o.Flag] = val end
				if o.Flag then autoSaveFlags() end
			end
			if o.Flag then registerFlag(o.Flag, dropdownSet) end
			return {
				Set = dropdownSet,
				Refresh = function(newOpts)
					o.Options = newOpts
					if open then positionPanel() buildItems(newOpts) end
				end,
			}
		end

		function Tab:CreateColorPicker(o)
			local color = o.Default or Color3.fromRGB(255, 255, 255)
			local row = glassRow(50)
			make("TextLabel", {
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -92, 1, 0),
				BackgroundTransparency = 1,
				Text = o.Name,
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			local preview = make("TextButton", {
				Size = UDim2.new(0, 40, 0, 26),
				Position = UDim2.new(1, -52, 0.5, -13),
				BackgroundColor3 = color,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 5,
			}, row)
			corner(7, preview)
			stroke(theme.StrokeLight, 1.5, theme.StrokeLightTrans, preview)
			local pickerOpen = false
			local picker = nil
			local popupEntry = {_isOpen = false, _container = nil, _trigger = preview, _clickOutside = nil}
			table.insert(self._window._openPopups, popupEntry)
			local function closePicker()
				if not pickerOpen then return end
				pickerOpen = false
				popupEntry._isOpen = false
				if picker then
					tw(picker, T_FAST, {Size = UDim2.new(0, 210, 0, 0)})
					task.delay(0.2, function() if picker then picker:Destroy() picker = nil end end)
				end
			end
			popupEntry._clickOutside = closePicker
			preview.MouseButton1Click:Connect(function()
				pickerOpen = not pickerOpen
				if picker then picker:Destroy() picker = nil end
				if not pickerOpen then popupEntry._isOpen = false return end
				local absPos = preview.AbsolutePosition
				local absSize = preview.AbsoluteSize
				local screenSize = self._window._overlay.AbsoluteSize
				local pickerW, pickerH = 210, 148
				local px = math.clamp(absPos.X - 172, 6, math.max(6, screenSize.X - pickerW - 6))
				local py = absPos.Y + absSize.Y + 6
				if py + pickerH > screenSize.Y - 6 and absPos.Y - pickerH - 6 >= 6 then
					py = absPos.Y - pickerH - 6
				end
				picker = make("Frame", {
					Size = UDim2.new(0, pickerW, 0, pickerH),
					Position = UDim2.new(0, px, 0, py),
					BackgroundColor3 = theme.WindowBg,
					BackgroundTransparency = 0.03,
					ZIndex = 250,
					ClipsDescendants = false,
				}, self._window._overlay)
				corner(12, picker)
				stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, picker)
				popupEntry._container = picker
				popupEntry._isOpen = true
				local h, s, v = Color3.toHSV(color)
				local function applyHSV()
					color = Color3.fromHSV(h, s, v)
					preview.BackgroundColor3 = color
					safecall(o.Callback, color)
					if o.Flag then Celestial.Flags[o.Flag] = color end
					if o.Flag then autoSaveFlags() end
				end
				local function makeSlider(labelText, yPos, gradientSeq, initialVal, callback)
					make("TextLabel", {
						Position = UDim2.new(0, 12, 0, yPos),
						Size = UDim2.new(1, -24, 0, 14),
						BackgroundTransparency = 1,
						Text = labelText,
						TextColor3 = theme.TextSecondary,
						Font = Enum.Font.Gotham,
						TextSize = 11,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 251,
					}, picker)
					local track = make("Frame", {
						Position = UDim2.new(0, 12, 0, yPos + 17),
						Size = UDim2.new(1, -24, 0, 10),
						BackgroundColor3 = Color3.fromRGB(200, 200, 200),
						ZIndex = 251,
					}, picker)
					corner(5, track)
					make("UIGradient", {Color = gradientSeq}, track)
					local thumb = make("Frame", {
						Size = UDim2.new(0, 12, 0, 12),
						Position = UDim2.new(initialVal, -6, 0.5, -6),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						ZIndex = 252,
					}, track)
					corner(6, thumb)
					stroke(Color3.fromRGB(0,0,0), 1, 0.7, thumb)
					local dragging = false
					track.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							local val = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
							thumb.Position = UDim2.new(val, -6, 0.5, -6)
							callback(val)
						end
					end)
					UIS.InputChanged:Connect(function(i)
						if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
							local val = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
							thumb.Position = UDim2.new(val, -6, 0.5, -6)
							callback(val)
						end
					end)
					UIS.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							dragging = false
						end
					end)
					return track, thumb
				end
				makeSlider("Hue", 10, ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
				}), h, function(val) h = val applyHSV() end)
				makeSlider("Saturation", 48, ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromHSV(h,1,1)), s, function(val) s = val applyHSV() end)
				makeSlider("Brightness", 86, ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255)), v, function(val) v = val applyHSV() end)
			end)
			if o.Flag then Celestial.Flags[o.Flag] = color end
			self._window:_onThemeChange(function(newTheme)
				local s = preview:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeLight end
				if picker and picker.Parent then
					picker.BackgroundColor3 = newTheme.WindowBg
					local s2 = picker:FindFirstChildWhichIsA("UIStroke")
					if s2 then s2.Color = newTheme.StrokeLight end
					for _, child in ipairs(picker:GetChildren()) do
						if child:IsA("TextLabel") then child.TextColor3 = newTheme.TextSecondary end
					end
				end
			end)
			local colorSet = function(c)
				color = c
				preview.BackgroundColor3 = c
				safecall(o.Callback, c)
				if o.Flag then Celestial.Flags[o.Flag] = c end
				if o.Flag then autoSaveFlags() end
			end
			if o.Flag then registerFlag(o.Flag, colorSet) end
			return {Set = colorSet}
		end

		function Tab:CreateKeybind(o)
			local key = o.Default or Enum.KeyCode.Unknown
			local binding = false
			local row = glassRow(50)
			make("TextLabel", {
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -114, 1, 0),
				BackgroundTransparency = 1,
				Text = o.Name,
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			local keyBtn = make("TextButton", {
				Size = UDim2.new(0, 84, 0, 28),
				Position = UDim2.new(1, -94, 0.5, -14),
				BackgroundColor3 = theme.SurfaceDeep,
				BackgroundTransparency = theme.SurfaceDeepTrans,
				Text = key.Name,
				TextColor3 = theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				AutoButtonColor = false,
				ZIndex = 5,
			}, row)
			corner(8, keyBtn)
			stroke(theme.Accent, 1, 0.45, keyBtn)
			local function cancelBind()
				binding = false
				keyBtn.Text = key.Name
				tw(keyBtn, T_FAST, {BackgroundTransparency = theme.SurfaceDeepTrans})
			end
			keyBtn.MouseButton1Click:Connect(function()
				if binding then cancelBind() return end
				binding = true
				keyBtn.Text = "..."
				tw(keyBtn, T_FAST, {BackgroundTransparency = 0.4})
			end)
			UIS.InputBegan:Connect(function(i, gpe)
				if not binding or gpe then return end
				if i.UserInputType == Enum.UserInputType.Keyboard then
					key = i.KeyCode
					cancelBind()
					safecall(o.Callback, key)
					if o.Flag then Celestial.Flags[o.Flag] = key end
					if o.Flag then autoSaveFlags() end
				elseif i.UserInputType == Enum.UserInputType.Gamepad1 then
					key = i.KeyCode
					cancelBind()
					safecall(o.Callback, key)
					if o.Flag then Celestial.Flags[o.Flag] = key end
					if o.Flag then autoSaveFlags() end
				elseif i.UserInputType == Enum.UserInputType.Touch then
					cancelBind()
				end
			end)
			if o.Flag then Celestial.Flags[o.Flag] = key end
			self._window:_onThemeChange(function(newTheme)
				keyBtn.TextColor3 = newTheme.Accent
				local s = keyBtn:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.Accent end
			end)
			local keybindSet = function(k)
				key = k
				keyBtn.Text = k.Name
				safecall(o.Callback, k)
				if o.Flag then Celestial.Flags[o.Flag] = k end
				if o.Flag then autoSaveFlags() end
			end
			if o.Flag then registerFlag(o.Flag, keybindSet) end
			return {Set = keybindSet}
		end

		function Tab:CreateProgressBar(o)
			local mn, mx = o.Min or 0, o.Max or 100
			local value = math.clamp(o.Default or mn, mn, mx)
			local row = glassRow(50)
			make("TextLabel", {
				Position = UDim2.new(0, 16, 0, 9),
				Size = UDim2.new(1, -84, 0, 18),
				BackgroundTransparency = 1,
				Text = o.Name or "",
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			local pctLabel = make("TextLabel", {
				Position = UDim2.new(1, -60, 0, 9),
				Size = UDim2.new(0, 44, 0, 18),
				BackgroundTransparency = 1,
				Text = string.format("%.0f%%", (value - mn) / (mx - mn) * 100),
				TextColor3 = theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
			}, row)
			local track = make("Frame", {
				Position = UDim2.new(0, 16, 0, 32),
				Size = UDim2.new(1, -32, 0, 6),
				BackgroundColor3 = theme.SliderTrack,
				BackgroundTransparency = 0.15,
			}, row)
			corner(6, track)
			local fill = make("Frame", {
				Size = UDim2.new((value - mn) / (mx - mn), 0, 1, 0),
				BackgroundColor3 = theme.SliderFill,
			}, track)
			corner(6, fill)
			gradient(0, ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.AccentDim),
				ColorSequenceKeypoint.new(1, theme.Accent),
			}), NumberSequence.new(0), fill)
			local function setValue(v)
				v = math.clamp(v, mn, mx)
				value = v
				local pct = (v - mn) / (mx - mn)
				tw(fill, T_MED, {Size = UDim2.new(pct, 0, 1, 0)})
				pctLabel.Text = string.format("%.0f%%", pct * 100)
			end
			self._window:_onThemeChange(function(newTheme)
				tw(track, T_MED, {BackgroundColor3 = newTheme.SliderTrack})
				tw(fill, T_MED, {BackgroundColor3 = newTheme.SliderFill})
				pctLabel.TextColor3 = newTheme.Accent
			end)
			return {Set = setValue}
		end

		function Tab:CreateSpinner(o)
			o = o or {}
			local row = glassRow(50)
			make("TextLabel", {
				Position = UDim2.new(0, 46, 0, 0),
				Size = UDim2.new(1, -60, 1, 0),
				BackgroundTransparency = 1,
				Text = o.Name or "Loading...",
				TextColor3 = theme.TextSecondary,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			local ring = make("Frame", {
				Position = UDim2.new(0, 16, 0.5, -9),
				Size = UDim2.new(0, 18, 0, 18),
				BackgroundTransparency = 1,
				Visible = false,
			}, row)
			corner(9, ring)
			stroke(theme.Accent, 2, 0.15, ring)
			local ringStroke = ring:FindFirstChildWhichIsA("UIStroke")
			local mask = make("Frame", {
				Size = UDim2.new(0.6, 0, 1.2, 0),
				Position = UDim2.new(0.4, 0, -0.1, 0),
				BackgroundColor3 = theme.Surface,
				BackgroundTransparency = theme.SurfaceDeepTrans,
				ZIndex = 2,
			}, ring)
			local running = false
			local spinConn
			local function start()
				if running then return end
				running = true
				ring.Visible = true
				local angle = 0
				spinConn = Run.RenderStepped:Connect(function(dt)
					angle = (angle + dt * 360) % 360
					ring.Rotation = angle
				end)
			end
			local function stop()
				running = false
				ring.Visible = false
				if spinConn then spinConn:Disconnect() spinConn = nil end
			end
			self._window:_onThemeChange(function(newTheme)
				if ringStroke then ringStroke.Color = newTheme.Accent end
				mask.BackgroundColor3 = newTheme.Surface
				mask.BackgroundTransparency = newTheme.SurfaceDeepTrans
			end)
			if o.AutoStart then start() end
			return {Start = start, Stop = stop, IsRunning = function() return running end}
		end

		function Tab:CreateParagraph(o)
			local titleText = o.Title or ""
			local contentText = o.Content or ""
			local container = make("Frame", {
				Size = UDim2.new(1, 0, 0, o.Height or 60),
				BackgroundColor3 = theme.Surface,
				BackgroundTransparency = theme.SurfaceDeepTrans,
				ClipsDescendants = false,
				LayoutOrder = nextOrder(),
			}, frame)
			corner(12, container)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, container)
			local titleLabel = make("TextLabel", {
				Position = UDim2.new(0, 16, 0, 10),
				Size = UDim2.new(1, -32, 0, 18),
				BackgroundTransparency = 1,
				Text = titleText,
				TextColor3 = theme.TextPrimary,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
			}, container)
			local contentLabel = nil
			if o.Content and o.Content ~= "" then
				contentLabel = make("TextLabel", {
					Position = UDim2.new(0, 16, 0, 30),
					Size = UDim2.new(1, -32, 0, 24),
					BackgroundTransparency = 1,
					Text = o.Content,
					TextColor3 = theme.TextSecondary,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
				}, container)
			end
			local function recalcHeight()
				local availWidth = math.max(container.AbsoluteSize.X - 32, 300)
				local titleSize = TextService:GetTextSize(titleLabel.Text, 13, Enum.Font.GothamBold, Vector2.new(availWidth, math.huge))
				local contentSize = contentLabel and TextService:GetTextSize(contentLabel.Text, 11, Enum.Font.Gotham, Vector2.new(availWidth, math.huge)) or Vector2.new(0, 0)
				titleLabel.Size = UDim2.new(1, -32, 0, titleSize.Y)
				if contentLabel then
					contentLabel.Size = UDim2.new(1, -32, 0, contentSize.Y)
					contentLabel.Position = UDim2.new(0, 16, 0, 10 + titleSize.Y + 4)
				end
				local totalHeight = o.Height or (18 + titleSize.Y + 4 + contentSize.Y + 14)
				container.Size = UDim2.new(1, 0, 0, totalHeight)
				Tab:RefreshCanvas()
			end
			task.defer(recalcHeight)
			container:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcHeight)
			self._window:_onThemeChange(function(newTheme)
				titleLabel.TextColor3 = newTheme.TextPrimary
				if contentLabel then contentLabel.TextColor3 = newTheme.TextSecondary end
				container.BackgroundColor3 = newTheme.Surface
				local s = container:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeLight end
			end)
			return {
				SetTitle = function(newTitle) titleLabel.Text = newTitle recalcHeight() end,
				SetContent = function(c)
					if contentLabel then
						contentLabel.Text = c
						recalcHeight()
					elseif c and c ~= "" then
						contentLabel = make("TextLabel", {
							Position = UDim2.new(0, 16, 0, 30),
							Size = UDim2.new(1, -32, 0, 24),
							BackgroundTransparency = 1,
							Text = c,
							TextColor3 = self._window._theme.TextSecondary,
							Font = Enum.Font.Gotham,
							TextSize = 11,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextWrapped = true,
						}, container)
						recalcHeight()
					end
				end,
			}
		end

		table.insert(self._tabs, Tab)
		if #self._tabs == 1 then activate() end
		return Tab
	end

	table.insert(self.Windows, Window)
	return Window
end

------------------------------------------------------------------------
-- GLOBAL FUNCTIONS
------------------------------------------------------------------------
function Celestial:SetTheme(name)
	local t = Themes[name]
	if not t then warn("[Celestial] Unknown theme: " .. tostring(name)) return end
	self.ActiveTheme = t
	for _, win in ipairs(self.Windows) do
		win._theme = t
		win:_applyTheme(t)
		if win._activeTab then
			for i, f in ipairs(win._tabFrames) do
				if f == win._activeTab then
					local btn = win._tabBtns[i]
					local bar = btn:FindFirstChild("Frame")
					local lbl = btn:FindFirstChildWhichIsA("TextLabel")
					if bar then tw(bar, T_MED, {BackgroundColor3 = t.Accent}) end
					if lbl then tw(lbl, T_MED, {TextColor3 = t.TextPrimary}) end
					break
				end
			end
		end
	end
end

function Celestial:Destroy()
	for _, win in ipairs(self.Windows) do
		if win._screen then safecall(function() win._screen:Destroy() end) end
	end
	self.Windows = {}
end

function Celestial:GetStatus()
	return {
		Version = VERSION,
		Name = NAME,
		ThemeCount = 0,
		WindowCount = #self.Windows,
		CurrentTheme = self.ActiveTheme and "loaded" or "missing",
	}
end

function Celestial:IsReady()
	return CoreGui ~= nil and TweenService ~= nil and TextService ~= nil
end

return Celestial
