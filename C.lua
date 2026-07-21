--[[
    CelestialConfig v3.0.0
    Shared utility layer for Celestial UI Library

    Load via:
        local C = loadstring(game:HttpGet("YOUR_RAW_URL"))()

    Features:
    - 50+ cached Roblox services (with cloneref support)
    - Tween presets + auto-cancel registry
    - Maid pattern for cleanup
    - Table / Math / Color utilities
    - File system wrappers (executor env)
    - Instance factory (C.N.Make, C.N.Corner, etc.)
    - 5 built-in themes (Nebula, Aurora, Dusk, Void, Frost)
    - Player tracking with health/position history
    - Input, Camera, Raycast helpers
    - Drawing + ESP system
    - Notification system
    - Serializer integration (CelestialSerialize)

    Serializer URL:
    https://raw.githubusercontent.com/zurai02/Celatial/main/CelestialSerialize.lua
]]

--!optimize 2
--!strict
--!native

--[[
    CelestialConfig v3.0.0
    Shared utility layer for Celestial UI Library
    Load via: loadstring(game:HttpGet("YOUR_RAW_URL"))()

    Integrates with CelestialSerialize for config persistence.
    Serializer URL: https://raw.githubusercontent.com/zurai02/Celatial/main/CelestialSerialize.lua
]]

local C = {}

------------------------------------------------------------------------
-- Environment Detection
------------------------------------------------------------------------
C.IsClient = game:GetService("Players").LocalPlayer ~= nil
C.IsServer = not C.IsClient
C.IsStudio = game:GetService("RunService"):IsStudio()

------------------------------------------------------------------------
-- Services (cached with cloneref support)
------------------------------------------------------------------------
local function gs(n)
	local s = game:GetService(n)
	return if cloneref then cloneref(s) else s
end

C.SV = {
	AdService=gs("AdService"), AnalyticsService=gs("AnalyticsService"),
	AssetService=gs("AssetService"), BadgeService=gs("BadgeService"),
	ChangeHistoryService=gs("ChangeHistoryService"), Chat=gs("Chat"),
	CollectionService=gs("CollectionService"), ContentProvider=gs("ContentProvider"),
	ContextActionService=gs("ContextActionService"), CoreGui=gs("CoreGui"),
	Debris=gs("Debris"), DebuggerManager=gs("DebuggerManager"),
	DraftsService=gs("DraftsService"), DraggerService=gs("DraggerService"),
	FilteredSelection=gs("FilteredSelection"), FriendService=gs("FriendService"),
	GamePassService=gs("GamePassService"), GamepadService=gs("GamepadService"),
	Geometry=gs("Geometry"), GroupService=gs("GroupService"), GuiService=gs("GuiService"),
	HSRDataContentProvider=gs("HSRDataContentProvider"), HapticService=gs("HapticService"),
	HttpRbxApiService=gs("HttpRbxApiService"), HttpService=gs("HttpService"),
	InsertService=gs("InsertService"), JointsService=gs("JointsService"),
	LanguageService=gs("LanguageService"), Lighting=gs("Lighting"),
	LocalizationService=gs("LocalizationService"), LogService=gs("LogService"),
	MarketplaceService=gs("MarketplaceService"), MemStorageService=gs("MemStorageService"),
	MeshContentProvider=gs("MeshContentProvider"), NotificationService=gs("NotificationService"),
	PermissionsService=gs("PermissionsService"), PhysicsService=gs("PhysicsService"),
	Players=gs("Players"), PluginDebugService=gs("PluginDebugService"),
	PluginGuiService=gs("PluginGuiService"), PointsService=gs("PointsService"),
	PolicyService=gs("PolicyService"), ProcessInstancePhysicsService=gs("ProcessInstancePhysicsService"),
	ReplicatedFirst=gs("ReplicatedFirst"), ReplicatedStorage=gs("ReplicatedStorage"),
	RunService=gs("RunService"), ScriptContext=gs("ScriptContext"),
	Selection=gs("Selection"), ServerScriptService=gs("ServerScriptService"),
	ServerStorage=gs("ServerStorage"), SolidModelContentProvider=gs("SolidModelContentProvider"),
	SoundService=gs("SoundService"), StarterGui=gs("StarterGui"), StarterPack=gs("StarterPack"),
	StarterPlayer=gs("StarterPlayer"), Stats=gs("Stats"), StudioService=gs("StudioService"),
	Teams=gs("Teams"), TeleportService=gs("TeleportService"), TestService=gs("TestService"),
	TextService=gs("TextService"), TouchInputService=gs("TouchInputService"),
	TweenService=gs("TweenService"), UserInputService=gs("UserInputService"),
	VRService=gs("VRService"), VirtualInputManager=gs("VirtualInputManager"),
	Visit=gs("Visit"), Workspace=gs("Workspace"),
}

-- Shorthand
C.UIS = C.SV.UserInputService
C.TS  = C.SV.TweenService
C.PS  = C.SV.Players
C.CG  = C.SV.CoreGui
C.HS  = C.SV.HttpService
C.RUN = C.SV.RunService
C.TXS = C.SV.TextService
C.WS  = C.SV.Workspace
C.LG  = C.SV.Lighting
C.RS  = C.SV.ReplicatedStorage
C.SG  = C.SV.StarterGui
C.NS  = C.SV.NotificationService
C.VIM = C.SV.VirtualInputManager
C.GUI = C.SV.GuiService
C.MS  = C.SV.MarketplaceService
C.SND = C.SV.SoundService
C.TP  = C.SV.TeleportService
C.TM  = C.SV.Teams

------------------------------------------------------------------------
-- Timing
------------------------------------------------------------------------
C.Wait   = task.wait
C.Defer  = task.defer or function(f, ...) task.delay(0, f, ...) end
C.Spawn  = task.spawn
C.Delay  = task.delay

------------------------------------------------------------------------
-- Tween Presets + Registry (auto-cancel old tweens on same instance)
------------------------------------------------------------------------
C.TI = TweenInfo
C.TW = {
	Fast    = C.TI.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Med     = C.TI.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Slow    = C.TI.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Spring  = C.TI.new(0.45, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
	Soft    = C.TI.new(0.50, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Linear  = C.TI.new(0.30, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	Bounce  = C.TI.new(0.50, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
	Elastic = C.TI.new(0.50, Enum.EasingStyle.Elastic,Enum.EasingDirection.Out),
	Smooth  = C.TI.new(0.20, Enum.EasingStyle.Sine,   Enum.EasingDirection.InOut),
	Snap    = C.TI.new(0.05, Enum.EasingStyle.Quad,   Enum.EasingDirection.Out),
}

C.TwF  = C.TW.Fast
C.TwM  = C.TW.Med
C.TwS  = C.TW.Slow
C.TwSP = C.TW.Spring
C.TwSO = C.TW.Soft
C.TwL  = C.TW.Linear
C.TwB  = C.TW.Bounce
C.TwE  = C.TW.Elastic
C.TwSM = C.TW.Smooth
C.TwSN = C.TW.Snap

C._tweens = {}
function C.Tween(inst, info, goals)
	if not inst then return nil end
	local old = C._tweens[inst]
	if old then pcall(function() old:Cancel() end) end
	local t = C.TS:Create(inst, info, goals)
	C._tweens[inst] = t
	t:Play()
	local c = t.Completed:Connect(function()
		if C._tweens[inst] == t then C._tweens[inst] = nil end
		c:Disconnect()
	end)
	return t
end
C.Tw = C.Tween

------------------------------------------------------------------------
-- SafeCall
------------------------------------------------------------------------
function C.Safe(fn, ...)
	if type(fn) ~= "function" then return nil end
	local ok, r = pcall(fn, ...)
	if not ok then warn("[Celestial] " .. tostring(r)) return nil end
	return r
end

------------------------------------------------------------------------
-- Maid (cleanup utility)
------------------------------------------------------------------------
function C.Maid()
	local m = {_j = {}}
	function m:Give(j)
		if j then table.insert(self._j, j) end
		return j
	end
	function m:Clean()
		for _, j in ipairs(self._j) do
			if typeof(j) == "RBXScriptConnection" then j:Disconnect()
			elseif typeof(j) == "Instance" then pcall(function() j:Destroy() end)
			elseif type(j) == "function" then pcall(j)
			elseif type(j) == "table" and j.Destroy then pcall(function() j:Destroy() end)
			end
		end
		for i = #self._j, 1, -1 do self._j[i] = nil end
	end
	function m:Destroy() self:Clean() end
	return m
end


------------------------------------------------------------------------
-- Table Utils
------------------------------------------------------------------------
C.Tbl = {}
function C.Tbl.Find(t, v) for i, x in ipairs(t) do if x == v then return i end end return nil end
function C.Tbl.Count(t) local n = 0 for _ in pairs(t) do n += 1 end return n end
function C.Tbl.Copy(t) if type(t) ~= "table" then return t end local c = {} for k, v in pairs(t) do c[k] = v end return c end
function C.Tbl.DeepCopy(t, seen)
	if type(t) ~= "table" then return t end
	seen = seen or {}
	if seen[t] then return seen[t] end
	local c = {}
	seen[t] = c
	for k, v in pairs(t) do c[C.Tbl.DeepCopy(k, seen)] = C.Tbl.DeepCopy(v, seen) end
	return c
end
function C.Tbl.Merge(a, b) local c = C.Tbl.Copy(a) if b then for k, v in pairs(b) do c[k] = v end end return c end
function C.Tbl.Filter(t, fn) local r = {} for i, v in ipairs(t) do if fn(v, i) then table.insert(r, v) end end return r end
function C.Tbl.Map(t, fn) local r = {} for i, v in ipairs(t) do r[i] = fn(v, i) end return r end
function C.Tbl.Keys(t) local r = {} for k in pairs(t) do table.insert(r, k) end return r end
function C.Tbl.Values(t) local r = {} for _, v in pairs(t) do table.insert(r, v) end return r end
function C.Tbl.Reverse(t) local r = {} for i = #t, 1, -1 do table.insert(r, t[i]) end return r end
function C.Tbl.Contains(t, v) for _, x in pairs(t) do if x == v then return true end end return false end
function C.Tbl.Flatten(t) local r = {} for _, v in ipairs(t) do if type(v) == "table" then for _, x in ipairs(v) do table.insert(r, x) end else table.insert(r, v) end end return r end
function C.Tbl.ShallowEqual(a, b)
	if type(a) ~= "table" or type(b) ~= "table" then return a == b end
	for k, v in pairs(a) do if b[k] ~= v then return false end end
	for k, v in pairs(b) do if a[k] ~= v then return false end end
	return true
end

------------------------------------------------------------------------
-- Math Utils
------------------------------------------------------------------------
C.Mth = {}
function C.Mth.Lerp(a, b, t) return a + (b - a) * t end
function C.Mth.Map(x, a, b, c, d) return c + (d - c) * ((x - a) / (b - a)) end
function C.Mth.Clamp(x, a, b) return math.clamp(x, a, b) end
function C.Mth.Round(x, dec)
	if not dec or dec == 0 then return math.floor(x + 0.5) end
	local m = 10^dec
	return math.floor(x * m + 0.5) / m
end
function C.Mth.Snap(x, step, min)
	min = min or 0
	local raw = math.round((x - min) / step) * step + min
	local s = tostring(step)
	local d = s:find("%.")
	if d then return C.Mth.Round(raw, #s - d) end
	return raw
end
function C.Mth.Dist(a, b) return (a - b).Magnitude end
function C.Mth.Dist2D(a, b) return math.sqrt((a.X - b.X)^2 + (a.Y - b.Y)^2) end
function C.Mth.RandomRange(a, b) return math.random() * (b - a) + a end
function C.Mth.Sign(x) return x > 0 and 1 or x < 0 and -1 or 0 end
function C.Mth.Approach(a, b, amt) return a < b and math.min(a + amt, b) or math.max(a - amt, b) end
function C.Mth.Floor(x, dec) local m = 10^(dec or 0) return math.floor(x * m) / m end
function C.Mth.Ceil(x, dec) local m = 10^(dec or 0) return math.ceil(x * m) / m end

------------------------------------------------------------------------
-- Color Utils
------------------------------------------------------------------------
C.Col = {}
function C.Col.RGB(r, g, b) return Color3.fromRGB(r, g, b) end
function C.Col.Hex(hex)
	hex = hex:gsub("#", "")
	return Color3.fromRGB(tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16))
end
function C.Col.ToHex(c) return string.format("#%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)) end
function C.Col.Lerp(a, b, t) return Color3.new(C.Mth.Lerp(a.R, b.R, t), C.Mth.Lerp(a.G, b.G, t), C.Mth.Lerp(a.B, b.B, t)) end
function C.Col.HSV(h, s, v) return Color3.fromHSV(h, s, v) end
function C.Col.ToHSV(c) return Color3.toHSV(c) end
function C.Col.Darken(c, amt) local h, s, v = C.Col.ToHSV(c) return C.Col.HSV(h, s, math.max(0, v - amt)) end
function C.Col.Lighten(c, amt) local h, s, v = C.Col.ToHSV(c) return C.Col.HSV(h, s, math.min(1, v + amt)) end
function C.Col.Random() return C.Col.HSV(math.random(), math.random(0.5, 1), math.random(0.7, 1)) end
function C.Col.WithA(c, a)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, c),
		ColorSequenceKeypoint.new(1, c)
	})
end

------------------------------------------------------------------------
-- File System (executor environment)
------------------------------------------------------------------------
C.File = {}
function C.File.Exists(p) return isfile and isfile(p) end
function C.File.Read(p) return readfile and readfile(p) end
function C.File.Write(p, d) return writefile and writefile(p, d) end
function C.File.IsFolder(p) return isfolder and isfolder(p) end
function C.File.MakeFolder(p) if makefolder and not C.File.IsFolder(p) then C.Safe(makefolder, p) end end
function C.File.List(p) return listfiles and listfiles(p) or {} end
function C.File.Ensure(p) C.File.MakeFolder(p) end
function C.File.Delete(p) if delfile and C.File.Exists(p) then delfile(p) end end
function C.File.DeleteFolder(p) if delfolder and C.File.IsFolder(p) then delfolder(p) end end
function C.File.Append(p, d) if appendfile then appendfile(p, d) end end
function C.File.LoadJSON(p)
	if not C.File.Exists(p) then return nil end
	local raw = C.File.Read(p)
	if not raw then return nil end
	local ok, result = pcall(function() return C.HS:JSONDecode(raw) end)
	return ok and result or nil
end
function C.File.SaveJSON(p, data)
	local ok, enc = pcall(function() return C.HS:JSONEncode(data) end)
	if ok then C.File.Write(p, enc) end
end

------------------------------------------------------------------------
-- Serializer Integration (CelestialSerialize)
------------------------------------------------------------------------
C.Serializer = nil
C.SerializerURL = "https://raw.githubusercontent.com/zurai02/Celatial/main/CelestialSerialize.lua"

function C.LoadSerializer(url)
	url = url or C.SerializerURL
	if C.Serializer then return C.Serializer end
	local ok, result = pcall(function()
		return loadstring(game:HttpGet(url))()
	end)
	if ok and result then
		C.Serializer = result
		return result
	else
		warn("[Celestial] Serializer load failed: " .. tostring(result))
		return nil
	end
end

function C.Serialize(data, opts)
	if C.Serializer then return C.Serializer.Serialize(data, opts) end
	-- Fallback to JSON
	local ok, result = pcall(function() return C.HS:JSONEncode(data) end)
	if ok then return result end
	warn("[Celestial] Serialize failed: no serializer loaded")
	return nil
end

function C.Deserialize(str, opts)
	if C.Serializer then return C.Serializer.Deserialize(str, opts) end
	-- Fallback to JSON
	local ok, result = pcall(function() return C.HS:JSONDecode(str) end)
	if ok then return result end
	warn("[Celestial] Deserialize failed: no serializer loaded")
	return nil
end

function C.SaveConfig(path, data)
	C.File.Ensure(path:match("^(.*)/") or "")
	if C.Serializer then
		local enc = C.Serializer.Serialize(data, {PrettyPrint = true})
		C.File.Write(path, enc)
	else
		C.File.SaveJSON(path, data)
	end
end

function C.LoadConfig(path)
	if not C.File.Exists(path) then return nil end
	local raw = C.File.Read(path)
	if not raw then return nil end
	if C.Serializer then
		return C.Serializer.Deserialize(raw)
	else
		return C.HS:JSONDecode(raw)
	end
end

-- Auto-attempt to load serializer
C.Safe(C.LoadSerializer)


------------------------------------------------------------------------
-- Instance Factory
------------------------------------------------------------------------
C.N = {}
function C.N.Make(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do pcall(function() (i :: any)[k] = v end) end
	if parent then i.Parent = parent end
	return i
end
function C.N.Corner(r, p) return C.N.Make("UICorner", {CornerRadius = UDim.new(0, r or 6)}, p) end
function C.N.Pad(l, r, t, b, p)
	return C.N.Make("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
		PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
	}, p)
end
function C.N.Stroke(c, th, tr, p)
	return C.N.Make("UIStroke", {Color = c, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p)
end
function C.N.List(dir, sort, sp, p)
	return C.N.Make("UIListLayout", {FillDirection = dir or Enum.FillDirection.Vertical, SortOrder = sort or Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, sp or 6)}, p)
end
function C.N.Grid(cs, rs, p)
	return C.N.Make("UIGridLayout", {CellSize = cs or UDim2.new(0, 100, 0, 100), CellPadding = rs or UDim.new(0, 6)}, p)
end
function C.N.Gradient(r, kp, tp, p)
	return C.N.Make("UIGradient", {Rotation = r or 0, Color = kp, Transparency = tp or NumberSequence.new(0)}, p)
end
function C.N.Frame(props, parent) return C.N.Make("Frame", props, parent) end
function C.N.Label(props, parent) return C.N.Make("TextLabel", props, parent) end
function C.N.Button(props, parent) return C.N.Make("TextButton", props, parent) end
function C.N.Box(props, parent) return C.N.Make("TextBox", props, parent) end
function C.N.Image(props, parent) return C.N.Make("ImageLabel", props, parent) end
function C.N.ImageBtn(props, parent) return C.N.Make("ImageButton", props, parent) end
function C.N.Scroll(props, parent) return C.N.Make("ScrollingFrame", props, parent) end
function C.N.Screen(props, parent) return C.N.Make("ScreenGui", props, parent) end

------------------------------------------------------------------------
-- UI Helpers
------------------------------------------------------------------------
function C.N.Glass(th, h, p, o)
	local r = C.N.Frame({Size = UDim2.new(1, 0, 0, h or 50), BackgroundColor3 = th.Surface, BackgroundTransparency = th.SurfaceDeepTrans, ClipsDescendants = false, LayoutOrder = o or 0}, p)
	C.N.Corner(12, r)
	C.N.Stroke(th.StrokeLight, 1, th.StrokeLightTrans, r)
	return r
end
function C.N.Ripple(p, x, y, th)
	local r = C.N.Frame({Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, x, 0, y), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = th.Ripple, BackgroundTransparency = 0.65, ZIndex = 20}, p)
	C.N.Corner(999, r)
	C.Tween(r, C.TI.new(0.45, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 130, 0, 130), BackgroundTransparency = 1})
	C.Delay(0.45, function() if r and r.Parent then r:Destroy() end end)
end
function C.N.UpdCanvas(f)
	local l = f:FindFirstChildOfClass("UIListLayout") or f:FindFirstChildOfClass("UIGridLayout")
	if l then f.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 24) end
end
function C.N.Inside(pos, inst)
	if not inst or not inst.Parent then return false end
	local ap = inst.AbsolutePosition
	local as = inst.AbsoluteSize
	return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
end
function C.N.Shadow(p, th)
	return C.N.Image({Name = "Shadow", Size = UDim2.new(1, 90, 1, 90), Position = UDim2.new(0, -45, 0, -45), BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = th.Shadow, ImageTransparency = 0.15, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 0}, p)
end
function C.N.Glow(p, th)
	return C.N.Image({Name = "Glow", Size = UDim2.new(1, 0, 0, 220), Position = UDim2.new(0, 0, 0, -110), BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = th.Glow, ImageTransparency = 0.88, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 0}, p)
end
function C.N.Tooltip(parent, text)
	if not text or text == "" then return end
	local sg = C.N.Screen({Name = "CelestialTooltip", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999})
	pcall(function() sg.Parent = C.CG end)
	local bg = C.N.Frame({Name = "Tip", BackgroundColor3 = Color3.fromRGB(20, 18, 28), BackgroundTransparency = 0.05, Size = UDim2.new(0, 0, 0, 26), Visible = false, ZIndex = 500}, sg)
	C.N.Corner(6, bg)
	C.N.Stroke(Color3.fromRGB(255, 255, 255), 1, 0.85, bg)
	local lbl = C.N.Label({Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(235, 235, 245), Font = Enum.Font.Gotham, TextSize = 11, ZIndex = 501}, bg)

	parent.MouseEnter:Connect(function()
		local w = C.TXS:GetTextSize(text, 11, Enum.Font.Gotham, Vector2.new(400, 20)).X + 16
		bg.Size = UDim2.new(0, w, 0, 26)
		bg.Visible = true
	end)
	parent.MouseLeave:Connect(function() bg.Visible = false end)
	parent.MouseMoved:Connect(function(x, y)
		if bg.Visible then bg.Position = UDim2.new(0, x + 16, 0, y + 16) end
	end)
end

------------------------------------------------------------------------
-- Themes
------------------------------------------------------------------------
C.Th = {
	Nebula = {
		Accent = C.Col.RGB(138, 107, 255), AccentDim = C.Col.RGB(96, 74, 200), AccentHover = C.Col.RGB(162, 135, 255), AccentText = C.Col.RGB(255, 255, 255),
		WindowBg = C.Col.RGB(17, 15, 26), WindowBg2 = C.Col.RGB(11, 10, 19), WindowTrans = 0.03,
		Surface = C.Col.RGB(255, 255, 255), SurfaceTrans = 0.94, SurfaceDeep = C.Col.RGB(255, 255, 255), SurfaceDeepTrans = 0.905, SurfaceHover = 0.86,
		TopbarBg = C.Col.RGB(20, 18, 30), TopbarTrans = 0.25, SidebarBg = C.Col.RGB(15, 13, 23), SidebarTrans = 0.35,
		Divider = C.Col.RGB(255, 255, 255), DividerTrans = 0.90,
		TextPrimary = C.Col.RGB(247, 246, 255), TextSecondary = C.Col.RGB(196, 191, 222), TextMuted = C.Col.RGB(140, 134, 170),
		StrokeLight = C.Col.RGB(255, 255, 255), StrokeLightTrans = 0.88, StrokeDark = C.Col.RGB(110, 95, 175), StrokeDarkTrans = 0.68,
		Toggle = C.Col.RGB(138, 107, 255), ToggleOff = C.Col.RGB(58, 54, 80),
		SliderFill = C.Col.RGB(138, 107, 255), SliderTrack = C.Col.RGB(46, 42, 68),
		Ripple = C.Col.RGB(205, 190, 255), Shadow = C.Col.RGB(3, 2, 10), Glow = C.Col.RGB(138, 107, 255),
	},
	Aurora = {
		Accent = C.Col.RGB(28, 214, 175), AccentDim = C.Col.RGB(18, 150, 122), AccentHover = C.Col.RGB(60, 235, 195), AccentText = C.Col.RGB(6, 24, 20),
		WindowBg = C.Col.RGB(9, 22, 20), WindowBg2 = C.Col.RGB(6, 15, 14), WindowTrans = 0.03,
		Surface = C.Col.RGB(255, 255, 255), SurfaceTrans = 0.94, SurfaceDeep = C.Col.RGB(255, 255, 255), SurfaceDeepTrans = 0.905, SurfaceHover = 0.86,
		TopbarBg = C.Col.RGB(11, 26, 24), TopbarTrans = 0.25, SidebarBg = C.Col.RGB(8, 19, 18), SidebarTrans = 0.35,
		Divider = C.Col.RGB(255, 255, 255), DividerTrans = 0.90,
		TextPrimary = C.Col.RGB(222, 252, 244), TextSecondary = C.Col.RGB(158, 212, 198), TextMuted = C.Col.RGB(104, 156, 145),
		StrokeLight = C.Col.RGB(255, 255, 255), StrokeLightTrans = 0.88, StrokeDark = C.Col.RGB(26, 150, 124), StrokeDarkTrans = 0.62,
		Toggle = C.Col.RGB(28, 214, 175), ToggleOff = C.Col.RGB(42, 74, 68),
		SliderFill = C.Col.RGB(28, 214, 175), SliderTrack = C.Col.RGB(26, 58, 52),
		Ripple = C.Col.RGB(180, 255, 235), Shadow = C.Col.RGB(1, 8, 7), Glow = C.Col.RGB(28, 214, 175),
	},
	Dusk = {
		Accent = C.Col.RGB(255, 122, 62), AccentDim = C.Col.RGB(200, 90, 42), AccentHover = C.Col.RGB(255, 150, 95), AccentText = C.Col.RGB(28, 10, 0),
		WindowBg = C.Col.RGB(24, 13, 7), WindowBg2 = C.Col.RGB(16, 9, 5), WindowTrans = 0.03,
		Surface = C.Col.RGB(255, 255, 255), SurfaceTrans = 0.94, SurfaceDeep = C.Col.RGB(255, 255, 255), SurfaceDeepTrans = 0.905, SurfaceHover = 0.86,
		TopbarBg = C.Col.RGB(28, 15, 8), TopbarTrans = 0.25, SidebarBg = C.Col.RGB(20, 11, 6), SidebarTrans = 0.35,
		Divider = C.Col.RGB(255, 255, 255), DividerTrans = 0.90,
		TextPrimary = C.Col.RGB(255, 240, 224), TextSecondary = C.Col.RGB(219, 188, 158), TextMuted = C.Col.RGB(160, 130, 106),
		StrokeLight = C.Col.RGB(255, 255, 255), StrokeLightTrans = 0.88, StrokeDark = C.Col.RGB(190, 96, 44), StrokeDarkTrans = 0.62,
		Toggle = C.Col.RGB(255, 122, 62), ToggleOff = C.Col.RGB(76, 52, 38),
		SliderFill = C.Col.RGB(255, 122, 62), SliderTrack = C.Col.RGB(62, 42, 30),
		Ripple = C.Col.RGB(255, 210, 170), Shadow = C.Col.RGB(10, 4, 2), Glow = C.Col.RGB(255, 122, 62),
	},
	Void = {
		Accent = C.Col.RGB(172, 122, 255), AccentDim = C.Col.RGB(120, 84, 200), AccentHover = C.Col.RGB(192, 148, 255), AccentText = C.Col.RGB(255, 255, 255),
		WindowBg = C.Col.RGB(6, 5, 11), WindowBg2 = C.Col.RGB(3, 2, 7), WindowTrans = 0.02,
		Surface = C.Col.RGB(255, 255, 255), SurfaceTrans = 0.955, SurfaceDeep = C.Col.RGB(255, 255, 255), SurfaceDeepTrans = 0.925, SurfaceHover = 0.89,
		TopbarBg = C.Col.RGB(9, 8, 15), TopbarTrans = 0.2, SidebarBg = C.Col.RGB(5, 4, 10), SidebarTrans = 0.3,
		Divider = C.Col.RGB(255, 255, 255), DividerTrans = 0.92,
		TextPrimary = C.Col.RGB(242, 238, 255), TextSecondary = C.Col.RGB(180, 170, 212), TextMuted = C.Col.RGB(122, 112, 155),
		StrokeLight = C.Col.RGB(255, 255, 255), StrokeLightTrans = 0.90, StrokeDark = C.Col.RGB(130, 90, 230), StrokeDarkTrans = 0.7,
		Toggle = C.Col.RGB(172, 122, 255), ToggleOff = C.Col.RGB(48, 40, 72),
		SliderFill = C.Col.RGB(172, 122, 255), SliderTrack = C.Col.RGB(30, 24, 50),
		Ripple = C.Col.RGB(215, 195, 255), Shadow = C.Col.RGB(1, 1, 4), Glow = C.Col.RGB(172, 122, 255),
	},
	Frost = {
		Accent = C.Col.RGB(0, 122, 235), AccentDim = C.Col.RGB(0, 90, 180), AccentHover = C.Col.RGB(30, 145, 250), AccentText = C.Col.RGB(255, 255, 255),
		WindowBg = C.Col.RGB(224, 232, 244), WindowBg2 = C.Col.RGB(206, 217, 232), WindowTrans = 0.12,
		Surface = C.Col.RGB(255, 255, 255), SurfaceTrans = 0.5, SurfaceDeep = C.Col.RGB(255, 255, 255), SurfaceDeepTrans = 0.38, SurfaceHover = 0.2,
		TopbarBg = C.Col.RGB(255, 255, 255), TopbarTrans = 0.35, SidebarBg = C.Col.RGB(255, 255, 255), SidebarTrans = 0.45,
		Divider = C.Col.RGB(20, 40, 70), DividerTrans = 0.88,
		TextPrimary = C.Col.RGB(12, 22, 46), TextSecondary = C.Col.RGB(55, 76, 116), TextMuted = C.Col.RGB(104, 124, 158),
		StrokeLight = C.Col.RGB(255, 255, 255), StrokeLightTrans = 0.25, StrokeDark = C.Col.RGB(0, 90, 190), StrokeDarkTrans = 0.68,
		Toggle = C.Col.RGB(0, 122, 235), ToggleOff = C.Col.RGB(158, 176, 204),
		SliderFill = C.Col.RGB(0, 122, 235), SliderTrack = C.Col.RGB(178, 196, 220),
		Ripple = C.Col.RGB(170, 210, 255), Shadow = C.Col.RGB(30, 50, 90), Glow = C.Col.RGB(0, 122, 235),
	},
}
C.ActiveTheme = C.Th.Nebula
function C.Theme(n) return C.Th[n] or C.ActiveTheme end
function C.SetTheme(n) local t = C.Th[n] if t then C.ActiveTheme = t end return t end

------------------------------------------------------------------------
-- Flags (global state storage)
------------------------------------------------------------------------
C.Flags = {}
function C.Flag(n, v) if v ~= nil then C.Flags[n] = v end return C.Flags[n] end
function C.GetFlag(n) return C.Flags[n] end
function C.ClearFlags() C.Flags = {} end


------------------------------------------------------------------------
-- Player Tracking (client-only; safe on server)
------------------------------------------------------------------------
C.PD = {}
C.PC = {}

function C.Track(plr)
	if not plr or C.PD[plr.UserId] then return end
	local d = {
		UserId = plr.UserId, Name = plr.Name, DisplayName = plr.DisplayName,
		AccountAge = plr.AccountAge, MembershipType = tostring(plr.MembershipType),
		Team = nil, Character = nil, RootPart = nil, Humanoid = nil,
		Position = Vector3.zero, LastPosition = Vector3.zero,
		Velocity = Vector3.zero, Speed = 0,
		Health = 100, MaxHealth = 100, LastHealth = 100,
		HealthHistory = {}, PositionHistory = {},
		IsAlive = false, IsLoaded = false, LastSeen = tick(),
		JoinedAt = tick(), DeathCount = 0,
		_persistent = {},
	}
	C.PD[plr.UserId] = d

	local charMaid = C.Maid()
	C.PC[plr.UserId] = charMaid

	local function onChar(char)
		charMaid:Clean()
		if not char then
			d.Character, d.RootPart, d.Humanoid, d.IsAlive = nil, nil, nil, false
			return
		end
		d.Character = char
		local hum = char:WaitForChild("Humanoid", 5)
		local root = char:WaitForChild("HumanoidRootPart", 5)
		if hum and root then
			d.Humanoid, d.RootPart, d.MaxHealth, d.IsLoaded = hum, root, hum.MaxHealth, true
			charMaid:Give(C.RUN.Heartbeat:Connect(function()
				if not char.Parent or not root.Parent then return end
				d.LastPosition = d.Position
				d.Position = root.Position
				d.Velocity = root.Velocity
				d.Speed = root.Velocity.Magnitude
				d.LastHealth = d.Health
				d.Health = hum.Health
				d.IsAlive = hum.Health > 0
				d.Team = plr.Team and plr.Team.Name or nil
				d.LastSeen = tick()
				table.insert(d.HealthHistory, {Time = tick(), Health = d.Health, Change = d.Health - d.LastHealth})
				if #d.HealthHistory > 100 then table.remove(d.HealthHistory, 1) end
				table.insert(d.PositionHistory, {Time = tick(), Position = d.Position})
				if #d.PositionHistory > 60 then table.remove(d.PositionHistory, 1) end
			end))
			charMaid:Give(hum.Died:Connect(function()
				d.IsAlive = false; d.Health = 0; d.DeathCount += 1
			end))
		end
	end

	if plr.Character then task.defer(onChar, plr.Character) end
	table.insert(d._persistent, plr.CharacterAdded:Connect(onChar))
	table.insert(d._persistent, plr.CharacterRemoving:Connect(function()
		d.IsAlive = false; d.Character = nil; d.RootPart = nil; d.Humanoid = nil
		charMaid:Clean()
	end))
end

function C.P(uid) return C.PD[uid] end
function C.Root(uid) local p = C.PD[uid] return p and p.RootPart end
function C.Pos(uid) local p = C.PD[uid] return p and p.Position end
function C.Health(uid) local p = C.PD[uid] return p and p.Health end
function C.Closest(uid)
	local me = C.Pos(uid)
	if not me then return nil, math.huge end
	local best, dist = nil, math.huge
	for id, pd in pairs(C.PD) do
		if id ~= uid and pd.IsAlive and pd.RootPart then
			local d = (me - pd.Position).Magnitude
			if d < dist then dist, best = d, pd end
		end
	end
	return best, dist
end
function C.Alive()
	local a = {} for uid, d in pairs(C.PD) do if d.IsAlive then table.insert(a, d) end end return a
end
function C.InitTrack()
	for _, p in ipairs(C.PS:GetPlayers()) do C.Track(p) end
	C.PS.PlayerAdded:Connect(C.Track)
	C.PS.PlayerRemoving:Connect(function(p)
		local d = C.PD[p.UserId]
		if d and d._persistent then
			for _, c in ipairs(d._persistent) do
				pcall(function() c:Disconnect() end)
			end
		end
		if C.PC[p.UserId] then C.PC[p.UserId]:Clean() end
		C.PC[p.UserId] = nil
		C.PD[p.UserId] = nil
	end)
end

------------------------------------------------------------------------
-- Input (client-only)
------------------------------------------------------------------------
C.Inp = {Keys = {}, JustPressed = {}, MousePos = Vector2.zero}

if C.IsClient then
	C.RUN.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Keyboard then
			C.Inp.Keys[i.KeyCode] = true
			C.Inp.JustPressed[i.KeyCode] = tick()
		end
	end)
	C.RUN.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Keyboard then
			C.Inp.Keys[i.KeyCode] = false
		end
	end)
	C.RUN.RenderStepped:Connect(function()
		C.Inp.MousePos = C.UIS:GetMouseLocation()
	end)
end

function C.Inp.Down(k) return C.Inp.Keys[k] == true end
function C.Inp.Pressed(k)
	local t = C.Inp.JustPressed[k]
	return t ~= nil and (tick() - t) < 0.05
end

------------------------------------------------------------------------
-- Camera (client-only)
------------------------------------------------------------------------
C.Cam = {Instance = C.WS.CurrentCamera}

if C.IsClient then
	function C.Cam.Pos() local c = C.Cam.Instance return c and c.CFrame.Position or Vector3.zero end
	function C.Cam.Look() local c = C.Cam.Instance return c and c.CFrame.LookVector or Vector3.zero end
	function C.Cam.CF() local c = C.Cam.Instance return c and c.CFrame or CFrame.new() end
	function C.Cam.W2S(pos) 
		local c = C.Cam.Instance 
		if not c then return Vector2.zero, false end
		local s, v = c:WorldToViewportPoint(pos) 
		return Vector2.new(s.X, s.Y), v 
	end
	function C.Cam.FOV() local c = C.Cam.Instance return c and c.FieldOfView or 70 end
	C.WS:GetPropertyChangedSignal("CurrentCamera"):Connect(function() 
		C.Cam.Instance = C.WS.CurrentCamera 
	end)
else
	function C.Cam.Pos() return Vector3.zero end
	function C.Cam.Look() return Vector3.zero end
	function C.Cam.CF() return CFrame.new() end
	function C.Cam.W2S(pos) return Vector2.zero, false end
	function C.Cam.FOV() return 70 end
end

------------------------------------------------------------------------
-- Raycast
------------------------------------------------------------------------
function C.Ray(o, d, params) return C.WS:Raycast(o, d, params) end
function C.RayToPlayer(targetUid, maxDist)
	if not C.IsClient then return false end
	local me = C.PS.LocalPlayer
	if not me or not me.Character then return false end
	local myRoot = me.Character:FindFirstChild("HumanoidRootPart")
	local t = C.PD[targetUid]
	if not myRoot or not t or not t.RootPart then return false end
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {me.Character, t.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local r = C.WS:Raycast(myRoot.Position, (t.RootPart.Position - myRoot.Position).Unit * (maxDist or 500), params)
	if r then
		local m = r.Instance:FindFirstAncestorOfClass("Model")
		if m and m == t.Character then return true, r end
	end
	return false, nil
end
function C.RayFromMouse(maxDist)
	if not C.IsClient then return nil end
	local cam = C.Cam.Instance
	if not cam then return nil end
	local mousePos = C.UIS:GetMouseLocation()
	local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	return C.WS:Raycast(ray.Origin, ray.Direction * (maxDist or 500))
end


------------------------------------------------------------------------
-- Drawing (client-only)
------------------------------------------------------------------------
C.Drw = {}
function C.Drw.New(class, props)
	if not Drawing then return nil end
	local d = Drawing.new(class)
	for k, v in pairs(props or {}) do pcall(function() d[k] = v end) end
	return d
end
function C.Drw.Line(a, b, c, th, vis)
	return C.Drw.New("Line", {Visible = vis ~= false, Thickness = th or 1, Color = c or Color3.new(1, 1, 1), From = a, To = b})
end
function C.Drw.Circle(pos, r, c, th, vis)
	return C.Drw.New("Circle", {Visible = vis ~= false, Thickness = th or 1, Color = c or Color3.new(1, 1, 1), Position = pos, Radius = r or 5, NumSides = 32})
end
function C.Drw.Text(txt, pos, c, size, vis)
	return C.Drw.New("Text", {Visible = vis ~= false, Text = txt or "", Position = pos or Vector2.zero, Color = c or Color3.new(1, 1, 1), Size = size or 14, Center = true, Outline = true})
end
function C.Drw.Box(pos, sz, c, th, vis, fill)
	return C.Drw.New("Square", {Visible = vis ~= false, Thickness = th or 1, Color = c or Color3.new(1, 1, 1), Position = pos or Vector2.zero, Size = sz or Vector2.new(100, 100), Filled = fill or false})
end

------------------------------------------------------------------------
-- ESP (client-only)
------------------------------------------------------------------------
C.ESP = {Objects = {}, Enabled = true}
function C.ESP.Box(plr, color)
	if not C.IsClient or not plr or not plr.Character then return nil end
	local r = plr.Character:FindFirstChild("HumanoidRootPart")
	if not r then return nil end
	C.ESP.Remove(plr.UserId)
	local b = C.Drw.New("Square", {Visible = false, Thickness = 1, Color = color or Color3.new(1, 1, 1), Filled = false, Transparency = 1})
	if b then
		C.ESP.Objects[plr.UserId] = {Box = b, Player = plr, Color = color or Color3.new(1, 1, 1)}
	end
	return b
end
function C.ESP.Remove(uid)
	local o = C.ESP.Objects[uid]
	if o then
		pcall(function() o.Box:Remove() end)
		C.ESP.Objects[uid] = nil
	end
end
function C.ESP.Clear()
	for uid, o in pairs(C.ESP.Objects) do
		pcall(function() o.Box:Remove() end)
	end
	C.ESP.Objects = {}
end
function C.ESP.Update()
	if not C.ESP.Enabled then return end
	for uid, o in pairs(C.ESP.Objects) do
		local d = C.PD[uid]
		if d and d.RootPart and d.IsAlive and o.Box then
			local pos, onScreen = C.Cam.W2S(d.RootPart.Position)
			if onScreen then
				local dist = (C.Cam.Pos() - d.RootPart.Position).Magnitude
				local scale = math.clamp(3500 / dist, 24, 140)
				o.Box.Visible = true
				o.Box.Position = pos - Vector2.new(scale / 2, scale * 1.1)
				o.Box.Size = Vector2.new(scale, scale * 2.2)
				if o.Color then o.Box.Color = o.Color end
			else
				o.Box.Visible = false
			end
		elseif o.Box then
			o.Box.Visible = false
		end
	end
end
if C.IsClient then
	C.RUN.RenderStepped:Connect(C.ESP.Update)
end

------------------------------------------------------------------------
-- Notifications
------------------------------------------------------------------------
C.NL = nil
function C.EnsureNotify()
	if C.NL and C.NL.Parent then return end
	local sg = C.N.Screen({Name = "CelestialNotifs", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
	local ok = pcall(function() sg.Parent = C.CG end)
	if not ok then ok = pcall(function() sg.Parent = game:GetService("CoreGui") end) end
	if not ok and C.PS.LocalPlayer then pcall(function() sg.Parent = C.PS.LocalPlayer:WaitForChild("PlayerGui") end) end
	local h = C.N.Frame({Name = "Holder", Size = UDim2.new(0, 310, 1, -20), Position = UDim2.new(1, -326, 0, 10), BackgroundTransparency = 1}, sg)
	local l = C.N.List(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 10, h)
	l.VerticalAlignment = Enum.VerticalAlignment.Bottom
	C.NL = h
end
function C.Notify(o)
	o = type(o) == "table" and o or {}
	C.EnsureNotify()
	if not C.NL then return nil end
	local th = C.Theme(o.Theme)
	local dur = tonumber(o.Duration) or 4
	local nt = o.Type or "info"
	local am = {info = th.Accent, success = C.Col.RGB(58, 214, 130), warn = C.Col.RGB(255, 178, 40), error = C.Col.RGB(255, 82, 82)}
	local ac = am[nt] or th.Accent
	local card = C.N.Frame({Size = UDim2.new(1, 0, 0, 72), BackgroundColor3 = th.WindowBg, BackgroundTransparency = 0.06, ClipsDescendants = false}, C.NL)
	C.N.Corner(14, card)
	C.N.Stroke(th.StrokeLight, 1, th.StrokeLightTrans, card)
	C.N.Frame({Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = th.Surface, BackgroundTransparency = th.SurfaceDeepTrans, ZIndex = 0}, card)
	local db = C.N.Button({Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 15}, card)
	local pill = C.N.Frame({Size = UDim2.new(0, 3, 0.62, 0), Position = UDim2.new(0, 10, 0.19, 0), BackgroundColor3 = ac, ZIndex = 3}, card)
	C.N.Corner(4, pill)
	local im = {info = "i", success = "v", warn = "!", error = "x"}
	local chip = C.N.Frame({Position = UDim2.new(0, 20, 0, 12), Size = UDim2.new(0, 26, 0, 26), BackgroundColor3 = ac, BackgroundTransparency = 0.82, ZIndex = 3}, card)
	C.N.Corner(8, chip)
	C.N.Label({Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = im[nt] or "i", TextColor3 = ac, Font = Enum.Font.GothamBlack, TextSize = 14, ZIndex = 4}, chip)
	C.N.Label({Position = UDim2.new(0, 56, 0, 11), Size = UDim2.new(1, -70, 0, 20), BackgroundTransparency = 1, Text = o.Title or "", TextColor3 = th.TextPrimary, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3}, card)
	if o.Content and #o.Content > 0 then
		C.N.Label({Position = UDim2.new(0, 56, 0, 32), Size = UDim2.new(1, -70, 0, 30), BackgroundTransparency = 1, Text = o.Content, TextColor3 = th.TextSecondary, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 3}, card)
	end
	local bt = C.N.Frame({Position = UDim2.new(0, 12, 1, -6), Size = UDim2.new(1, -24, 0, 3), BackgroundColor3 = ac, BackgroundTransparency = 0.82, ZIndex = 3}, card)
	C.N.Corner(2, bt)
	local bar = C.N.Frame({Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = ac, BackgroundTransparency = 0.1, ZIndex = 4}, bt)
	C.N.Corner(2, bar)
	card.Position = UDim2.new(1, 24, 0, 0)
	card.BackgroundTransparency = 1
	C.Tween(card, C.TwSO, {Position = UDim2.new(0, 0, 0, 0)})
	C.Tween(card, C.TwM, {BackgroundTransparency = 0.06})
	C.Tween(bar, C.TI.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
	local alive = true
	local function dismiss()
		if not alive then return end
		alive = false
		C.Tween(card, C.TwM, {Position = UDim2.new(1, 24, 0, 0), BackgroundTransparency = 1})
		C.Delay(0.3, function() if card and card.Parent then card:Destroy() end end)
	end
	db.MouseButton1Click:Connect(dismiss)
	C.Delay(dur, dismiss)
	return {Destroy = dismiss}
end
function C.Toast(text, ntype, duration)
	C.Notify({Title = text, Type = ntype or "info", Duration = duration or 2.5})
end

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
C.VERSION     = "3.0.0"
C.NAME        = "Celestial"
C.FOLDER_ROOT = "Celestial"
C.FOLDER_CFG  = C.FOLDER_ROOT .. "/Configs"
C.CFG_EXT     = ".cltl"

------------------------------------------------------------------------
-- Auto-Init
------------------------------------------------------------------------
C.InitTrack()

return C
