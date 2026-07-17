--!native
--!Optimize 2
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/zurai02/Celatial/main/CelestialConfig.lua"))()

local UIS = Config.Services.UserInputService
local TweenService = Config.TS
local Players = Config.PS
local CoreGui = Config.CG
local Http = Config.HS
local Run = Config.RUN
local TextService = Config.TXS
local UserInputService = UIS

local IS_STUDIO = Run:IsStudio()

local function safecall(fn, ...)
	if not fn then return nil end
	local ok, r = pcall(fn, ...)
	if not ok then warn("[Celestial] " .. tostring(r)) end
	if ok then return r end
	return nil
end

local function folder(path)
	if isfolder and not safecall(isfolder, path) then
		safecall(makefolder, path)
	end
end

local function tw(inst, info, goals)
	return TweenService:Create(inst, info, goals)
end

local function TrackConnections()
	local conns = {}
	return {
		Add = function(c) table.insert(conns, c) return c end,
		Clean = function()
			for _, c in ipairs(conns) do
				if c and c.Connected then pcall(function() c:Disconnect() end) end
			end
			table.clear(conns)
		end
	}
end

local T_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local T_MED = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local T_SLOW = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local T_SPRING = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local T_SPRING_SOFT = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function make(className, props, parent)
	local inst = Instance.new(className)
	for k, v in props do
		pcall(function() (inst :: any)[k] = v end)
	end
	if parent then inst.Parent = parent end
	return inst
end

local function corner(r, p) return make("UICorner", { CornerRadius = UDim.new(0, r) }, p) end
local function pad(l, r, t, b, p)
	return make("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
	}, p)
end
local function stroke(color, thick, trans, p)
	return make("UIStroke", { Color = color, Thickness = thick or 1, Transparency = trans or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p)
end
local function listLayout(dir, sort, spacing, p)
	return make("UIListLayout", {
		FillDirection = dir or Enum.FillDirection.Vertical,
		SortOrder = sort or Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, spacing or 6),
	}, p)
end
local function gradient(rotation, keypoints, transKeypoints, p)
	return make("UIGradient", { Rotation = rotation or 0, Color = keypoints, Transparency = transKeypoints }, p)
end

local VERSION = "3.0.0"
local NAME = "Celestial"
local FOLDER_ROOT = "Celestial"
local FOLDER_CFG = FOLDER_ROOT .. "/Configs"
local CFG_EXT = ".cltl"

local Themes = {
	Nebula = {
		Accent = Color3.fromRGB(138, 107, 255), AccentDim = Color3.fromRGB(96, 74, 200),
		AccentHover = Color3.fromRGB(162, 135, 255), AccentText = Color3.fromRGB(255, 255, 255),
		WindowBg = Color3.fromRGB(17, 15, 26), WindowBg2 = Color3.fromRGB(11, 10, 19), WindowTrans = 0.03,
		Surface = Color3.fromRGB(255, 255, 255), SurfaceTrans = 0.94,
		SurfaceDeep = Color3.fromRGB(255, 255, 255), SurfaceDeepTrans = 0.905, SurfaceHover = 0.86,
		TopbarBg = Color3.fromRGB(20, 18, 30), TopbarTrans = 0.25,
		SidebarBg = Color3.fromRGB(15, 13, 23), SidebarTrans = 0.35,
		Divider = Color3.fromRGB(255, 255, 255), DividerTrans = 0.90,
		TextPrimary = Color3.fromRGB(247, 246, 255), TextSecondary = Color3.fromRGB(196, 191, 222),
		TextMuted = Color3.fromRGB(140, 134, 170),
		StrokeLight = Color3.fromRGB(255, 255, 255), StrokeLightTrans = 0.88,
		StrokeDark = Color3.fromRGB(110, 95, 175), StrokeDarkTrans = 0.68,
		Toggle = Color3.fromRGB(138, 107, 255), ToggleOff = Color3.fromRGB(58, 54, 80),
		SliderFill = Color3.fromRGB(138, 107, 255), SliderTrack = Color3.fromRGB(46, 42, 68),
		Ripple = Color3.fromRGB(205, 190, 255), Shadow = Color3.fromRGB(3, 2, 10), Glow = Color3.fromRGB(138, 107, 255),
	},
	Aurora = {
		Accent = Color3.fromRGB(28, 214, 175), AccentDim = Color3.fromRGB(18, 150, 122),
		AccentHover = Color3.fromRGB(60, 235, 195), AccentText = Color3.fromRGB(6, 24, 20),
		WindowBg = Color3.fromRGB(9, 22, 20), WindowBg2 = Color3.fromRGB(6, 15, 14), WindowTrans = 0.03,
		Surface = Color3.fromRGB(255, 255, 255), SurfaceTrans = 0.94,
		SurfaceDeep = Color3.fromRGB(255, 255, 255), SurfaceDeepTrans = 0.905, SurfaceHover = 0.86,
		TopbarBg = Color3.fromRGB(11, 26, 24), TopbarTrans = 0.25,
		SidebarBg = Color3.fromRGB(8, 19, 18), SidebarTrans = 0.35,
		Divider = Color3.fromRGB(255, 255, 255), DividerTrans = 0.90,
		TextPrimary = Color3.fromRGB(222, 252, 244), TextSecondary = Color3.fromRGB(158, 212, 198),
		TextMuted = Color3.fromRGB(104, 156, 145),
		StrokeLight = Color3.fromRGB(255, 255, 255), StrokeLightTrans = 0.88,
		StrokeDark = Color3.fromRGB(26, 150, 124), StrokeDarkTrans = 0.62,
		Toggle = Color3.fromRGB(28, 214, 175), ToggleOff = Color3.fromRGB(42, 74, 68),
		SliderFill = Color3.fromRGB(28, 214, 175), SliderTrack = Color3.fromRGB(26, 58, 52),
		Ripple = Color3.fromRGB(180, 255, 235), Shadow = Color3.fromRGB(1, 8, 7), Glow = Color3.fromRGB(28, 214, 175),
	},
	Dusk = {
		Accent = Color3.fromRGB(255, 122, 62), AccentDim = Color3.fromRGB(200, 90, 42),
		AccentHover = Color3.fromRGB(255, 150, 95), AccentText = Color3.fromRGB(28, 10, 0),
		WindowBg = Color3.fromRGB(24, 13, 7), WindowBg2 = Color3.fromRGB(16, 9, 5), WindowTrans = 0.03,
		Surface = Color3.fromRGB(255, 255, 255), SurfaceTrans = 0.94,
		SurfaceDeep = Color3.fromRGB(255, 255, 255), SurfaceDeepTrans = 0.905, SurfaceHover = 0.86,
		TopbarBg = Color3.fromRGB(28, 15, 8), TopbarTrans = 0.25,
		SidebarBg = Color3.fromRGB(20, 11, 6), SidebarTrans = 0.35,
		Divider = Color3.fromRGB(255, 255, 255), DividerTrans = 0.90,
		TextPrimary = Color3.fromRGB(255, 240, 224), TextSecondary = Color3.fromRGB(219, 188, 158),
		TextMuted = Color3.fromRGB(160, 130, 106),
		StrokeLight = Color3.fromRGB(255, 255, 255), StrokeLightTrans = 0.88,
		StrokeDark = Color3.fromRGB(190, 96, 44), StrokeDarkTrans = 0.62,
		Toggle = Color3.fromRGB(255, 122, 62), ToggleOff = Color3.fromRGB(76, 52, 38),
		SliderFill = Color3.fromRGB(255, 122, 62), SliderTrack = Color3.fromRGB(62, 42, 30),
		Ripple = Color3.fromRGB(255, 210, 170), Shadow = Color3.fromRGB(10, 4, 2), Glow = Color3.fromRGB(255, 122, 62),
	},
	Void = {
		Accent = Color3.fromRGB(172, 122, 255), AccentDim = Color3.fromRGB(120, 84, 200),
		AccentHover = Color3.fromRGB(192, 148, 255), AccentText = Color3.fromRGB(255, 255, 255),
		WindowBg = Color3.fromRGB(6, 5, 11), WindowBg2 = Color3.fromRGB(3, 2, 7), WindowTrans = 0.02,
		Surface = Color3.fromRGB(255, 255, 255), SurfaceTrans = 0.955,
		SurfaceDeep = Color3.fromRGB(255, 255, 255), SurfaceDeepTrans = 0.925, SurfaceHover = 0.89,
		TopbarBg = Color3.fromRGB(9, 8, 15), TopbarTrans = 0.2,
		SidebarBg = Color3.fromRGB(5, 4, 10), SidebarTrans = 0.3,
		Divider = Color3.fromRGB(255, 255, 255), DividerTrans = 0.92,
		TextPrimary = Color3.fromRGB(242, 238, 255), TextSecondary = Color3.fromRGB(180, 170, 212),
		TextMuted = Color3.fromRGB(122, 112, 155),
		StrokeLight = Color3.fromRGB(255, 255, 255), StrokeLightTrans = 0.90,
		StrokeDark = Color3.fromRGB(130, 90, 230), StrokeDarkTrans = 0.7,
		Toggle = Color3.fromRGB(172, 122, 255), ToggleOff = Color3.fromRGB(48, 40, 72),
		SliderFill = Color3.fromRGB(172, 122, 255), SliderTrack = Color3.fromRGB(30, 24, 50),
		Ripple = Color3.fromRGB(215, 195, 255), Shadow = Color3.fromRGB(1, 1, 4), Glow = Color3.fromRGB(172, 122, 255),
	},
	Frost = {
		Accent = Color3.fromRGB(0, 122, 235), AccentDim = Color3.fromRGB(0, 90, 180),
		AccentHover = Color3.fromRGB(30, 145, 250), AccentText = Color3.fromRGB(255, 255, 255),
		WindowBg = Color3.fromRGB(224, 232, 244), WindowBg2 = Color3.fromRGB(206, 217, 232), WindowTrans = 0.12,
		Surface = Color3.fromRGB(255, 255, 255), SurfaceTrans = 0.5,
		SurfaceDeep = Color3.fromRGB(255, 255, 255), SurfaceDeepTrans = 0.38, SurfaceHover = 0.2,
		TopbarBg = Color3.fromRGB(255, 255, 255), TopbarTrans = 0.35,
		SidebarBg = Color3.fromRGB(255, 255, 255), SidebarTrans = 0.45,
		Divider = Color3.fromRGB(20, 40, 70), DividerTrans = 0.88,
		TextPrimary = Color3.fromRGB(12, 22, 46), TextSecondary = Color3.fromRGB(55, 76, 116),
		TextMuted = Color3.fromRGB(104, 124, 158),
		StrokeLight = Color3.fromRGB(255, 255, 255), StrokeLightTrans = 0.25,
		StrokeDark = Color3.fromRGB(0, 90, 190), StrokeDarkTrans = 0.68,
		Toggle = Color3.fromRGB(0, 122, 235), ToggleOff = Color3.fromRGB(158, 176, 204),
		SliderFill = Color3.fromRGB(0, 122, 235), SliderTrack = Color3.fromRGB(178, 196, 220),
		Ripple = Color3.fromRGB(170, 210, 255), Shadow = Color3.fromRGB(30, 50, 90), Glow = Color3.fromRGB(0, 122, 235),
	},
}

local _tooltipGui, _tooltipBg, _tooltipLabel, _tooltipConn, _tooltipTarget

local function ensureTooltipLayer()
	if _tooltipGui then return end
	_tooltipGui = make("ScreenGui", { Name = "CelestialTooltip", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 99999 })
	pcall(function() _tooltipGui.Parent = CoreGui end)
	_tooltipBg = make("Frame", { Size = UDim2.new(0, 120, 0, 28), BackgroundColor3 = Color3.fromRGB(20, 20, 30), BackgroundTransparency = 0.08, BorderSizePixel = 0, Visible = false, ZIndex = 100000 }, _tooltipGui)
	corner(6, _tooltipBg)
	make("UIStroke", { Color = Color3.fromRGB(100, 100, 120), Thickness = 1, Transparency = 0.5 }, _tooltipBg)
	_tooltipLabel = make("TextLabel", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(240, 240, 255), Font = Enum.Font.Gotham, TextSize = 11, ZIndex = 100001 }, _tooltipBg)
end

local function showTooltip(text, target)
	if not text or text == "" then return end
	ensureTooltipLayer()
	_tooltipTarget = target
	_tooltipLabel.Text = text
	local size = TextService:GetTextSize(text, 11, Enum.Font.Gotham, Vector2.new(300, 40))
	_tooltipBg.Size = UDim2.new(0, size.X + 16, 0, 28)
	_tooltipBg.Visible = true
	_tooltipBg.BackgroundTransparency = 1
	tw(_tooltipBg, T_FAST, { BackgroundTransparency = 0.08 }):Play()
	if _tooltipConn then _tooltipConn:Disconnect() end
	_tooltipConn = Run.Heartbeat:Connect(function()
		if not _tooltipTarget or not _tooltipTarget.Parent then hideTooltip() return end
		local mouse = UserInputService:GetMouseLocation()
		_tooltipBg.Position = UDim2.new(0, mouse.X + 15, 0, mouse.Y + 15)
	end)
end

local function hideTooltip()
	if _tooltipConn then _tooltipConn:Disconnect() _tooltipConn = nil end
	if _tooltipBg then
		tw(_tooltipBg, T_FAST, { BackgroundTransparency = 1 }):Play()
		task.delay(0.12, function() if _tooltipBg then _tooltipBg.Visible = false end end)
	end
	_tooltipTarget = nil
end

local _notifScreen, _notifHolder, _activeNotifs, MAX_NOTIFS = nil, nil, 0, 5

local function ensureNotifLayer()
	if _notifHolder and _notifHolder.Parent then return end
	_notifScreen = make("ScreenGui", { Name = "CelestialNotifs", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
	pcall(function() _notifScreen.Parent = CoreGui end)
	_notifHolder = make("Frame", { Name = "Holder", Size = UDim2.new(0, 320, 1, -20), Position = UDim2.new(1, -340, 0, 10), BackgroundTransparency = 1 }, _notifScreen)
	make("UIListLayout", { VerticalAlignment = Enum.VerticalAlignment.Bottom, FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) }, _notifHolder)
end

local Celestial = {}
Celestial.__index = Celestial
Celestial.Themes = Themes
Celestial.ActiveTheme = Themes.Nebula
Celestial.Windows = {}
Celestial.Flags = {}

function Celestial:Notify(opts)
	ensureNotifLayer()
	if _activeNotifs >= MAX_NOTIFS then
		local oldest = _notifHolder:FindFirstChildOfClass("Frame")
		if oldest then oldest:Destroy() _activeNotifs -= 1 end
	end
	_activeNotifs += 1

	local t = Themes[opts.Theme or ""] or self.ActiveTheme
	local duration = opts.Duration or 4
	local notifType = opts.Type or "info"
	local accentMap = {
		info = t.Accent, success = Color3.fromRGB(58, 214, 130),
		warn = Color3.fromRGB(255, 178, 40), error = Color3.fromRGB(255, 82, 82),
	}
	local accent = accentMap[notifType] or t.Accent

	local card = make("Frame", { Name = "Notif", Size = UDim2.new(1, 0, 0, opts.Actions and 96 or 72), BackgroundColor3 = t.WindowBg, BackgroundTransparency = 0.06, ClipsDescendants = false, LayoutOrder = tick() }, _notifHolder)
	corner(14, card)
	stroke(t.StrokeLight, 1, t.StrokeLightTrans, card)
	make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = t.Surface, BackgroundTransparency = t.SurfaceDeepTrans, ZIndex = 0 }, card)
	corner(14, card:FindFirstChildOfClass("Frame"))

	local pill = make("Frame", { Size = UDim2.new(0, 3, 0.62, 0), Position = UDim2.new(0, 10, 0.19, 0), BackgroundColor3 = accent, ZIndex = 3 }, card)
	corner(4, pill)
	make("ImageLabel", { Size = UDim2.new(0, 10, 1.6, 0), Position = UDim2.new(0, -3, -0.3, 0), BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = accent, ImageTransparency = 0.55, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 2 }, pill)

	local iconMap = { info = "i", success = "v", warn = "!", error = "x" }
	local iconChip = make("Frame", { Position = UDim2.new(0, 20, 0, 12), Size = UDim2.new(0, 26, 0, 26), BackgroundColor3 = accent, BackgroundTransparency = 0.82, ZIndex = 3 }, card)
	corner(8, iconChip)
	make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = iconMap[notifType] or "i", TextColor3 = accent, Font = Enum.Font.GothamBlack, TextSize = 14, ZIndex = 4 }, iconChip)

	make("TextLabel", { Position = UDim2.new(0, 56, 0, 11), Size = UDim2.new(1, -70, 0, 20), BackgroundTransparency = 1, Text = opts.Title or "", TextColor3 = t.TextPrimary, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3 }, card)

	if opts.Content and #opts.Content > 0 then
		make("TextLabel", { Position = UDim2.new(0, 56, 0, 32), Size = UDim2.new(1, -70, 0, 30), BackgroundTransparency = 1, Text = opts.Content, TextColor3 = t.TextSecondary, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 3 }, card)
	end

	if opts.Actions then
		local btnY = (opts.Content and #opts.Content > 0) and 68 or 56
		local btnX = 56
		for _, action in ipairs(opts.Actions) do
			local aBtn = make("TextButton", { Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(0, btnX, 0, btnY), BackgroundColor3 = accent, BackgroundTransparency = 0.85, Text = action.Name, TextColor3 = accent, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, ZIndex = 4 }, card)
			corner(6, aBtn)
			aBtn.MouseButton1Click:Connect(function()
				safecall(action.Callback)
				tw(card, T_MED, { Position = UDim2.new(1, 24, 0, 0), BackgroundTransparency = 1 }):Play()
				task.delay(0.3, function() if card.Parent then card:Destroy() _activeNotifs -= 1 end end)
			end)
			btnX += 68
		end
	end

	local barTrack = make("Frame", { Position = UDim2.new(0, 12, 1, -6), Size = UDim2.new(1, -24, 0, 3), BackgroundColor3 = accent, BackgroundTransparency = 0.82, ZIndex = 3 }, card)
	corner(2, barTrack)
	local bar = make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = accent, BackgroundTransparency = 0.1, ZIndex = 4 }, barTrack)
	corner(2, bar)

	card.Position = UDim2.new(1, 24, 0, 0)
	card.BackgroundTransparency = 1
	tw(card, T_SPRING_SOFT, { Position = UDim2.new(0, 0, 0, 0) }):Play()
	tw(card, T_MED, { BackgroundTransparency = 0.06 }):Play()
	tw(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()

	local function dismiss()
		tw(card, T_MED, { Position = UDim2.new(1, 24, 0, 0), BackgroundTransparency = 1 }):Play()
		task.delay(0.3, function() if card.Parent then card:Destroy() _activeNotifs -= 1 end end)
	end

	task.delay(duration, dismiss)
	card.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dismiss() end end)
end

function Celestial:CreateWindow(opts)
	local t = Themes[opts.Theme or ""] or self.ActiveTheme
	self.ActiveTheme = t
	folder(FOLDER_ROOT)
	folder(FOLDER_CFG)

	local W = opts.Size and opts.Size.X or 640
	local H = opts.Size and opts.Size.Y or 460
	local MIN_W, MIN_H = 400, 280

	local screen = make("ScreenGui", { Name = opts.Name or NAME, ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
	pcall(function() screen.Parent = CoreGui end)

	local overlay = make("Frame", { Name = "Overlay", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 200 }, screen)

	local win = make("Frame", { Name = "Window", Size = UDim2.new(0, W, 0, H), Position = UDim2.new(0.5, -W/2, 0.5, -H/2), BackgroundColor3 = t.WindowBg, BackgroundTransparency = t.WindowTrans, ClipsDescendants = true, ZIndex = 1 }, screen)
	corner(18, win)
	stroke(t.StrokeLight, 1, t.StrokeLightTrans, win)

	gradient(120, ColorSequence.new({ ColorSequenceKeypoint.new(0, t.WindowBg2), ColorSequenceKeypoint.new(0.5, t.WindowBg), ColorSequenceKeypoint.new(1, t.WindowBg2) }), NumberSequence.new(0), win)

	make("ImageLabel", { Name = "Shadow", Size = UDim2.new(1, 90, 1, 90), Position = UDim2.new(0, -45, 0, -45), BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = t.Shadow, ImageTransparency = 0.15, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 0 }, win)
	make("ImageLabel", { Name = "AccentGlow", Size = UDim2.new(1, 0, 0, 220), Position = UDim2.new(0, 0, 0, -110), BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = t.Glow, ImageTransparency = 0.88, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 0 }, win)

	local topbar = make("Frame", { Name = "Topbar", Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = t.TopbarBg, BackgroundTransparency = t.TopbarTrans, ZIndex = 5 }, win)
	corner(18, topbar)
	make("Frame", { Position = UDim2.new(0, 0, 1, -18), Size = UDim2.new(1, 0, 0, 18), BackgroundColor3 = t.TopbarBg, BackgroundTransparency = t.TopbarTrans, ZIndex = 5 }, topbar)
	make("Frame", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = t.Accent, BackgroundTransparency = 0.75, ZIndex = 6 }, topbar)

	local accentDot = make("Frame", { Position = UDim2.new(0, 18, 0.5, -4), Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = t.Accent, ZIndex = 6 }, topbar)
	corner(4, accentDot)

	make("TextLabel", { Position = UDim2.new(0, 34, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1, Text = opts.Name or NAME, TextColor3 = t.TextPrimary, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6 }, topbar)

	local titleWidth = TextService:GetTextSize(opts.Name or NAME, 14, Enum.Font.GothamBold, Vector2.new(400, 20)).X
	local badge = make("Frame", { Size = UDim2.new(0, 46, 0, 18), Position = UDim2.new(0, 34 + titleWidth + 10, 0.5, -9), BackgroundColor3 = t.Accent, BackgroundTransparency = 0.82, ZIndex = 6 }, topbar)
	corner(6, badge)
	stroke(t.Accent, 1, 0.65, badge)
	make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "v" .. VERSION, TextColor3 = t.Accent, Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 7 }, badge)

	local resizeHandle = make("TextButton", { Name = "ResizeHandle", Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -20, 1, -20), BackgroundTransparency = 1, Text = "", ZIndex = 10 }, win)
	make("ImageLabel", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -14, 1, -14), BackgroundTransparency = 1, Image = "rbxassetid://3926307971", ImageRectOffset = Vector2.new(404, 84), ImageRectSize = Vector2.new(36, 36), ImageColor3 = t.TextMuted, ImageTransparency = 0.5, ZIndex = 10 }, win)

	local function makeCtrl(iconText, hoverColor, xPos, onClick)
		local btn = make("TextButton", { Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, xPos, 0.5, -14), BackgroundColor3 = t.Surface, BackgroundTransparency = 1, Text = iconText, TextColor3 = t.TextMuted, Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false, ZIndex = 6 }, topbar)
		corner(9, btn)
		btn.MouseButton1Click:Connect(onClick)
		btn.MouseEnter:Connect(function() tw(btn, T_FAST, { BackgroundTransparency = 0.82, TextColor3 = hoverColor }):Play() end)
		btn.MouseLeave:Connect(function() tw(btn, T_FAST, { BackgroundTransparency = 1, TextColor3 = t.TextMuted }):Play() end)
		return btn
	end

	local minimised = false
	makeCtrl("×", Color3.fromRGB(255, 100, 90), -36, function()
		tw(win, T_MED, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1 }):Play()
		task.wait(0.24)
		screen:Destroy()
	end)

	makeCtrl("–", t.Accent, -68, function()
		minimised = not minimised
		if minimised then
			tw(win, T_MED, { Size = UDim2.new(0, W, 0, 50) }):Play()
			sidebar.Visible = false
			content.Visible = false
			resizeHandle.Visible = false
		else
			tw(win, T_MED, { Size = UDim2.new(0, W, 0, H) }):Play()
			task.delay(0.15, function()
				sidebar.Visible = true
				content.Visible = true
				resizeHandle.Visible = true
			end)
		end
	end)

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

	do
		local resizing, startMouse, startSize = false, nil, nil
		resizeHandle.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startMouse = i.Position
				startSize = win.Size
			end
		end)
		UIS.InputEnded:Connect(function(i)
			if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and resizing then
				resizing = false
				W = win.Size.X.Offset
				H = win.Size.Y.Offset
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - startMouse
				local newW = math.clamp(startSize.X.Offset + d.X, MIN_W, overlay.AbsoluteSize.X - 20)
				local newH = math.clamp(startSize.Y.Offset + d.Y, MIN_H, overlay.AbsoluteSize.Y - 20)
				win.Size = UDim2.new(0, newW, 0, newH)
			end
		end)
	end

	local sidebar = make("Frame", { Name = "Sidebar", Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(0, 172, 1, -50), BackgroundColor3 = t.SidebarBg, BackgroundTransparency = t.SidebarTrans, ClipsDescendants = true, ZIndex = 4 }, win)
	make("Frame", { Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = t.Accent, BackgroundTransparency = 0.85, ZIndex = 4 }, sidebar)

	local tabHolder = make("Frame", { Name = "TabHolder", Size = UDim2.new(1, 0, 1, -8), BackgroundTransparency = 1 }, sidebar)
	listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 4, tabHolder)
	pad(10, 10, 12, 10, tabHolder)

	local content = make("Frame", { Name = "Content", Position = UDim2.new(0, 173, 0, 50), Size = UDim2.new(1, -173, 1, -50), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2 }, win)

	do
		local swipeStart, swipeSidebarOpen = nil, true
		content.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch then
				swipeStart = i.Position.X
			end
		end)
		content.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch and swipeStart then
				local delta = i.Position.X - swipeStart
				if delta > 80 and not swipeSidebarOpen then
					swipeSidebarOpen = true
					tw(sidebar, T_MED, { Size = UDim2.new(0, 172, 1, -50) }):Play()
					tw(content, T_MED, { Position = UDim2.new(0, 173, 0, 50), Size = UDim2.new(1, -173, 1, -50) }):Play()
				elseif delta < -80 and swipeSidebarOpen then
					swipeSidebarOpen = false
					tw(sidebar, T_MED, { Size = UDim2.new(0, 0, 1, -50) }):Play()
					tw(content, T_MED, { Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 1, -50) }):Play()
				end
				swipeStart = nil
			end
		end)
	end

	local kb = opts.Keybind or Enum.KeyCode.LeftAlt
	local kbConn = UIS.InputBegan:Connect(function(i, gpe)
		if gpe then return end
		if i.KeyCode == kb then win.Visible = not win.Visible end
	end)

	win.Size = UDim2.new(0, 0, 0, 0)
	win.Position = UDim2.new(0.5, 0, 0.5, 0)
	win.BackgroundTransparency = 1
	task.wait()
	tw(win, T_SPRING, { Size = UDim2.new(0, W, 0, H), Position = UDim2.new(0.5, -W/2, 0.5, -H/2), BackgroundTransparency = t.WindowTrans }):Play()

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
	Window._conns = TrackConnections()
	Window._conns.Add(kbConn)

	function Window:_onThemeChange(fn)
		table.insert(self._themeCallbacks, fn)
	end

	function Window:_applyTheme(newTheme)
		for _, cb in ipairs(self._themeCallbacks) do safecall(cb, newTheme) end
	end

	Window:_onThemeChange(function(newTheme)
		tw(win, T_MED, { BackgroundColor3 = newTheme.WindowBg, BackgroundTransparency = newTheme.WindowTrans }):Play()
		tw(topbar, T_MED, { BackgroundColor3 = newTheme.TopbarBg, BackgroundTransparency = newTheme.TopbarTrans }):Play()
		tw(accentDot, T_MED, { BackgroundColor3 = newTheme.Accent }):Play()
	end)

	local function pointInside(pos, inst)
		if not inst then return false end
		local absPos = inst.AbsolutePosition
		local absSize = inst.AbsoluteSize
		return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
	end

	local popupConn = UIS.InputBegan:Connect(function(input, gpe)
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
	Window._conns.Add(popupConn)

	local cfgOpts = opts.ConfigurationSaving
	if cfgOpts and cfgOpts.Enabled then
		local cfgFile = FOLDER_CFG .. "/" .. (cfgOpts.FileName or opts.Name or "config") .. CFG_EXT
		function Window:SaveConfig(data)
			local ok, enc = pcall(function() return Http:JSONEncode(data) end)
			if ok then safecall(writefile, cfgFile, enc) end
		end
		function Window:LoadConfig()
			if safecall(isfile, cfgFile) then
				local raw = safecall(readfile, cfgFile)
				if raw then
					local ok, dec = pcall(function() return Http:JSONDecode(raw) end)
					if ok then return dec end
				end
			end
			return nil
		end
	end

	function Window:SelectTab(index)
		local tab = self._tabs[index]
		if tab and tab._activate then tab:_activate() end
	end

	function Window:Destroy()
		self._conns.Clean()
		for _, popup in ipairs(self._openPopups) do
			if popup._container then popup._container:Destroy() end
		end
		if self._screen then self._screen:Destroy() end
		table.remove(Celestial.Windows, table.find(Celestial.Windows, self))
	end

	function Window:CreateTab(tabOpts)
		local tabName = tabOpts.Name or "Tab"
		local theme = self._theme
		local tabConns = TrackConnections()

		local btn = make("TextButton", { Name = tabName, Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = theme.Accent, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5 }, self._sidebar)
		corner(10, btn)

		local textOffset, textWidth = 14, -14
		if tabOpts.Icon then
			textOffset, textWidth = 38, -38
			if tabOpts.Icon:find("rbxassetid://") or tabOpts.Icon:match("^%d+$") then
				make("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 12, 0.5, -9), BackgroundTransparency = 1, Image = if tabOpts.Icon:match("^%d+$") then "rbxassetid://" .. tabOpts.Icon else tabOpts.Icon, ImageColor3 = theme.TextMuted, ZIndex = 6 }, btn)
			else
				make("TextLabel", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 12, 0.5, -9), BackgroundTransparency = 1, Text = tabOpts.Icon, TextColor3 = theme.TextMuted, Font = Enum.Font.Gotham, TextSize = 14, ZIndex = 6 }, btn)
			end
		end

		local btnLabel = make("TextLabel", { Position = UDim2.new(0, textOffset, 0, 0), Size = UDim2.new(1, textWidth, 1, 0), BackgroundTransparency = 1, Text = tabName, TextColor3 = theme.TextMuted, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6 }, btn)

		local accentBar = make("Frame", { Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = theme.Accent, ZIndex = 6 }, btn)
		corner(4, accentBar)

		local frame = make("ScrollingFrame", { Name = tabName .. "_Frame", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Accent, ScrollBarImageTransparency = 0.4, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, ZIndex = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y }, self._content)
		listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 8, frame)
		pad(16, 16, 14, 16, frame)

		table.insert(self._tabBtns, btn)
		table.insert(self._tabFrames, frame)

		local function activate()
			for _, b in self._tabBtns do
				local bar_ = b:FindFirstChild("Frame")
				tw(b, T_FAST, { BackgroundTransparency = 1 }):Play()
				if bar_ then tw(bar_, T_FAST, { Size = UDim2.new(0, 3, 0, 0) }):Play() end
				local lbl = b:FindFirstChildWhichIsA("TextLabel")
				if lbl then tw(lbl, T_FAST, { TextColor3 = theme.TextMuted, Font = Enum.Font.Gotham }):Play() end
			end
			for _, f in self._tabFrames do f.Visible = false end
			tw(btn, T_FAST, { BackgroundTransparency = 0.88 }):Play()
			tw(accentBar, T_MED, { Size = UDim2.new(0, 3, 0, 18) }):Play()
			tw(btnLabel, T_FAST, { TextColor3 = theme.TextPrimary }):Play()
			btnLabel.Font = Enum.Font.GothamBold
			frame.Visible = true
			self._activeTab = frame
		end

		tabConns.Add(btn.MouseButton1Click:Connect(activate))
		tabConns.Add(btn.MouseEnter:Connect(function() if frame.Visible then return end tw(btn, T_FAST, { BackgroundTransparency = 0.94 }):Play() end))
		tabConns.Add(btn.MouseLeave:Connect(function() if frame.Visible then return end tw(btn, T_FAST, { BackgroundTransparency = 1 }):Play() end))

		local Tab = {}
		Tab._frame = frame
		Tab._window = self
		Tab._layoutOrder = 0
		Tab._activate = activate
		Tab._conns = tabConns
		Tab._elements = {}

		local function nextOrder()
			Tab._layoutOrder += 1
			return Tab._layoutOrder
		end

		local function glassRow(height, parent)
			local row = make("Frame", { Size = UDim2.new(1, 0, 0, height or 50), BackgroundColor3 = theme.Surface, BackgroundTransparency = theme.SurfaceDeepTrans, ClipsDescendants = false, LayoutOrder = nextOrder(), AutomaticSize = Enum.AutomaticSize.Y }, parent or frame)
			corner(12, row)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, row)
			Tab._window:_onThemeChange(function(newTheme)
				tw(row, T_MED, { BackgroundColor3 = newTheme.Surface }):Play()
				local s = row:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeLight end
			end)
			return row
		end

		local function ripple(parent, x, y)
			local r = make("Frame", { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, x, 0, y), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = theme.Ripple, BackgroundTransparency = 0.65, ZIndex = 20 }, parent)
			corner(999, r)
			tw(r, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 140, 0, 140), BackgroundTransparency = 1 }):Play()
			task.delay(0.45, function() r:Destroy() end)
		end

		function Tab:RefreshCanvas()
			local lay = self._frame:FindFirstChildOfClass("UIListLayout")
			if lay then self._frame.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 24) end
		end

		function Tab:CreateSection(text)
			local lbl = make("TextLabel", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = string.upper(text), TextColor3 = theme.TextMuted, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder() }, frame)
			self._window:_onThemeChange(function(newTheme) lbl.TextColor3 = newTheme.TextMuted end)
			return { Destroy = function() lbl:Destroy() end }
		end

		function Tab:CreateDivider(opts)
			local o = opts or {}
			local container = make("Frame", { Size = UDim2.new(1, 0, 0, o.Height or 24), BackgroundTransparency = 1, LayoutOrder = nextOrder() }, frame)
			local left = make("Frame", { Size = UDim2.new(0.5, -30, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = theme.Divider, BackgroundTransparency = theme.DividerTrans }, container)
			local right = make("Frame", { Size = UDim2.new(0.5, -30, 0, 1), Position = UDim2.new(0.5, 30, 0.5, 0), BackgroundColor3 = theme.Divider, BackgroundTransparency = theme.DividerTrans }, container)
			if o.Text then
				make("TextLabel", { Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(0.5, -30, 0, 0), BackgroundTransparency = 1, Text = o.Text, TextColor3 = theme.TextMuted, Font = Enum.Font.GothamBold, TextSize = 10 }, container)
			end
			self._window:_onThemeChange(function(newTheme)
				left.BackgroundColor3 = newTheme.Divider
				right.BackgroundColor3 = newTheme.Divider
			end)
			return { Destroy = function() container:Destroy() end }
		end

		function Tab:CreateLabel(opts)
			local o = opts or {}
			local container = make("Frame", { Size = UDim2.new(1, 0, 0, o.Height or 34), BackgroundTransparency = 1, LayoutOrder = nextOrder() }, frame)
			local textOffset = o.Icon and 28 or 12
			if o.Icon then
				if o.Icon:find("rbxassetid://") or o.Icon:match("^%d+$") then
					make("ImageLabel", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 12, 0.5, -8), BackgroundTransparency = 1, Image = if o.Icon:match("^%d+$") then "rbxassetid://" .. o.Icon else o.Icon, ImageColor3 = o.IconColor or theme.TextMuted }, container)
				else
					make("TextLabel", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 12, 0.5, -8), BackgroundTransparency = 1, Text = o.Icon, TextColor3 = o.IconColor or theme.TextMuted, Font = Enum.Font.Gotham, TextSize = 14 }, container)
				end
			end
			local lbl = make("TextLabel", { Position = UDim2.new(0, textOffset, 0, 0), Size = UDim2.new(1, -textOffset - 12, 1, 0), BackgroundTransparency = 1, Text = o.Text or "", TextColor3 = o.Color or theme.TextSecondary, Font = o.Bold and Enum.Font.GothamBold or Enum.Font.Gotham, TextSize = o.Size or 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, RichText = o.RichText or false }, container)
			if o.Tooltip then
				container.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then showTooltip(o.Tooltip, container) end end)
				container.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then hideTooltip() end end)
			end
			self._window:_onThemeChange(function(newTheme) if not o.Color then lbl.TextColor3 = newTheme.TextSecondary end end)
			return { Set = function(txt) lbl.Text = txt end, Get = function() return lbl.Text end, Destroy = function() container:Destroy() end }
		end

		function Tab:CreateParagraph(o)
			local titleText = o.Title or ""
			local contentText = o.Content or ""
			local container = make("Frame", { Size = UDim2.new(1, 0, 0, o.Height or 60), BackgroundColor3 = theme.Surface, BackgroundTransparency = theme.SurfaceDeepTrans, ClipsDescendants = false, LayoutOrder = nextOrder() }, frame)
			corner(12, container)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, container)
			local titleLabel = make("TextLabel", { Position = UDim2.new(0, 16, 0, 10), Size = UDim2.new(1, -32, 0, 18), BackgroundTransparency = 1, Text = titleText, TextColor3 = theme.TextPrimary, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, container)
			local contentLabel = nil
			if o.Content and o.Content ~= "" then
				contentLabel = make("TextLabel", { Position = UDim2.new(0, 16, 0, 30), Size = UDim2.new(1, -32, 0, 24), BackgroundTransparency = 1, Text = o.Content, TextColor3 = theme.TextSecondary, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, container)
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
			local sizeConn = container:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcHeight)
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
					if contentLabel then contentLabel.Text = c recalcHeight()
					elseif c and c ~= "" then
						contentLabel = make("TextLabel", { Position = UDim2.new(0, 16, 0, 30), Size = UDim2.new(1, -32, 0, 24), BackgroundTransparency = 1, Text = c, TextColor3 = self._window._theme.TextSecondary, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, container)
						recalcHeight()
					end
				end,
				Destroy = function() sizeConn:Disconnect() container:Destroy() end,
			}
		end

		function Tab:CreateButton(o)
			local row = glassRow(50)
			row.ClipsDescendants = true
			make("TextLabel", { Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -104, 1, 0), BackgroundTransparency = 1, Text = o.Name, TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, row)
			if o.Description then
				make("TextLabel", { Position = UDim2.new(0, 16, 0, 29), Size = UDim2.new(1, -104, 0, 16), BackgroundTransparency = 1, Text = o.Description, TextColor3 = theme.TextMuted, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, row)
				row.Size = UDim2.new(1, 0, 0, 62)
			end
			local cBtn = make("TextButton", { Size = UDim2.new(0, 76, 0, 30), Position = UDim2.new(1, -88, 0.5, -15), BackgroundColor3 = theme.Accent, BackgroundTransparency = 0, Text = o.Text or "Run", TextColor3 = theme.AccentText, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 5 }, row)
			corner(9, cBtn)
			gradient(90, ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, theme.Accent) }), NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 1) }), cBtn)
			if o.Tooltip then
				cBtn.MouseEnter:Connect(function() showTooltip(o.Tooltip, cBtn) end)
				cBtn.MouseLeave:Connect(function() hideTooltip() end)
			end
			cBtn.MouseButton1Click:Connect(function()
				tw(cBtn, T_FAST, { Size = UDim2.new(0, 72, 0, 28), Position = UDim2.new(1, -86, 0.5, -14) }):Play()
				ripple(row, cBtn.AbsolutePosition.X - row.AbsolutePosition.X + 38, 25)
				task.delay(0.1, function() tw(cBtn, T_SPRING, { Size = UDim2.new(0, 76, 0, 30), Position = UDim2.new(1, -88, 0.5, -15) }):Play() end)
				safecall(o.Callback)
			end)
			cBtn.MouseEnter:Connect(function() tw(cBtn, T_FAST, { BackgroundColor3 = theme.AccentHover }):Play() end)
			cBtn.MouseLeave:Connect(function() tw(cBtn, T_FAST, { BackgroundColor3 = theme.Accent }):Play() end)
			row.MouseEnter:Connect(function() tw(row, T_FAST, { BackgroundTransparency = theme.SurfaceTrans }):Play() end)
			row.MouseLeave:Connect(function() tw(row, T_FAST, { BackgroundTransparency = theme.SurfaceDeepTrans }):Play() end)
			self._window:_onThemeChange(function(newTheme)
				tw(cBtn, T_MED, { BackgroundColor3 = newTheme.Accent }):Play()
				cBtn.TextColor3 = newTheme.AccentText
			end)
			return { Destroy = function() row:Destroy() end }
		end

		function Tab:CreateToggle(o)
			local hasDesc = o.Description and o.Description ~= ""
			local state = o.Default or false
			local row = glassRow(hasDesc and 62 or 50)
			make("TextLabel", { Position = UDim2.new(0, 16, 0, 9), Size = UDim2.new(1, -84, 0, 18), BackgroundTransparency = 1, Text = o.Name, TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, row)
			if hasDesc then
				make("TextLabel", { Position = UDim2.new(0, 16, 0, 29), Size = UDim2.new(1, -84, 0, 16), BackgroundTransparency = 1, Text = o.Description, TextColor3 = theme.TextMuted, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, row)
			end
			local track = make("Frame", { Size = UDim2.new(0, 46, 0, 26), Position = UDim2.new(1, -60, 0.5, -13), BackgroundColor3 = if state then theme.Toggle else theme.ToggleOff, BackgroundTransparency = 0 }, row)
			corner(13, track)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, track)
			local knob = make("Frame", { Size = UDim2.new(0, 20, 0, 20), Position = if state then UDim2.new(1, -23, 0.5, -10) else UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(255, 255, 255) }, track)
			corner(10, knob)
			local clickArea = make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, row)
			local function setState(val)
				state = val
				tw(track, T_MED, { BackgroundColor3 = if val then theme.Toggle else theme.ToggleOff }):Play()
				tw(knob, T_SPRING, { Position = if val then UDim2.new(1, -23, 0.5, -10) else UDim2.new(0, 3, 0.5, -10), Size = UDim2.new(0, 20, 0, 20) }):Play()
				safecall(o.Callback, val)
				if o.Flag then Celestial.Flags[o.Flag] = val end
			end
			clickArea.MouseButton1Down:Connect(function() tw(knob, T_FAST, { Size = UDim2.new(0, 24, 0, 20) }):Play() end)
			clickArea.MouseButton1Up:Connect(function() setState(not state) end)
			if o.Flag then Celestial.Flags[o.Flag] = state end
			if o.Tooltip then
				clickArea.MouseEnter:Connect(function() showTooltip(o.Tooltip, clickArea) end)
				clickArea.MouseLeave:Connect(function() hideTooltip() end)
			end
			self._window:_onThemeChange(function(newTheme)
				tw(track, T_MED, { BackgroundColor3 = state and newTheme.Toggle or newTheme.ToggleOff }):Play()
				local s = track:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeLight end
			end)
			return { Set = setState, Get = function() return state end, Destroy = function() row:Destroy() end }
		end

		function Tab:CreateSlider(o)
			local hasDesc = o.Description and o.Description ~= ""
			local mn, mx = o.Min, o.Max
			local step = o.Step or 1
			local value = math.clamp(o.Default or mn, mn, mx)
			local row = glassRow(hasDesc and 76 or 66)
			make("TextLabel", { Position = UDim2.new(0, 16, 0, 9), Size = UDim2.new(1, -84, 0, 18), BackgroundTransparency = 1, Text = o.Name, TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, row)
			if hasDesc then
				make("TextLabel", { Position = UDim2.new(0, 16, 0, 27), Size = UDim2.new(1, -84, 0, 16), BackgroundTransparency = 1, Text = o.Description, TextColor3 = theme.TextMuted, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, row)
			end
			local valChip = make("Frame", { Position = UDim2.new(1, -74, 0, 8), Size = UDim2.new(0, 58, 0, 20), BackgroundColor3 = theme.Accent, BackgroundTransparency = 0.84 }, row)
			corner(6, valChip)
			local valLabel = make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = tostring(value) .. (o.Suffix or ""), TextColor3 = theme.Accent, Font = Enum.Font.GothamBold, TextSize = 11 }, valChip)
			local trackY = hasDesc and 52 or 42
			local trackBg = make("Frame", { Position = UDim2.new(0, 16, 0, trackY), Size = UDim2.new(1, -32, 0, 5), BackgroundColor3 = theme.SliderTrack, BackgroundTransparency = 0.15 }, row)
			corner(5, trackBg)
			local fill = make("Frame", { Size = UDim2.new((value - mn)/(mx - mn), 0, 1, 0), BackgroundColor3 = theme.SliderFill }, trackBg)
			corner(5, fill)
			gradient(0, ColorSequence.new({ ColorSequenceKeypoint.new(0, theme.AccentDim), ColorSequenceKeypoint.new(1, theme.Accent) }), NumberSequence.new(0), fill)
			local thumb = make("Frame", { Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new((value - mn)/(mx - mn), -7, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 5 }, trackBg)
			corner(8, thumb)
			stroke(theme.Accent, 2, 0.1, thumb)
			local dragging = false
			local function snapTo(v)
				v = math.clamp(math.round((v - mn) / step) * step + mn, mn, mx)
				value = v
				local pct = (v - mn) / (mx - mn)
				tw(fill, T_FAST, { Size = UDim2.new(pct, 0, 1, 0) }):Play()
				tw(thumb, T_FAST, { Position = UDim2.new(pct, -7, 0.5, -7) }):Play()
				valLabel.Text = tostring(v) .. (o.Suffix or "")
				safecall(o.Callback, v)
				if o.Flag then Celestial.Flags[o.Flag] = v end
			end
			local function onInput(input)
				local rel = math.clamp((input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
				snapTo(mn + rel * (mx - mn))
			end
			trackBg.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					onInput(i)
					tw(thumb, T_FAST, { Size = UDim2.new(0, 19, 0, 19), Position = UDim2.new((value-mn)/(mx-mn), -9, 0.5, -9) }):Play()
				end
			end)
			local dragConn = UIS.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then onInput(i) end
			end)
			local upConn = UIS.InputEnded:Connect(function(i)
				if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and dragging then
					dragging = false
					tw(thumb, T_FAST, { Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new((value-mn)/(mx-mn), -7, 0.5, -7) }):Play()
				end
			end)
			if o.Flag then Celestial.Flags[o.Flag] = value end
			self._window:_onThemeChange(function(newTheme)
				tw(trackBg, T_MED, { BackgroundColor3 = newTheme.SliderTrack }):Play()
				tw(fill, T_MED, { BackgroundColor3 = newTheme.SliderFill }):Play()
				valLabel.TextColor3 = newTheme.Accent
				valChip.BackgroundColor3 = newTheme.Accent
				local s = thumb:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.Accent end
			end)
			return { Set = snapTo, Get = function() return value end, Destroy = function() dragConn:Disconnect() upConn:Disconnect() row:Destroy() end }
		end

		function Tab:CreateInput(o)
			local row = glassRow(50)
			make("TextLabel", { Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(0, 110, 1, 0), BackgroundTransparency = 1, Text = o.Name, TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, row)
			local field = make("Frame", { Position = UDim2.new(0, 130, 0.5, -15), Size = UDim2.new(1, -146, 0, 30), BackgroundColor3 = theme.SurfaceDeep, BackgroundTransparency = theme.SurfaceDeepTrans }, row)
			corner(8, field)
			stroke(theme.StrokeDark, 1, theme.StrokeDarkTrans, field)
			local box = make("TextBox", { Size = UDim2.new(1, -18, 1, 0), Position = UDim2.new(0, 9, 0, 0), BackgroundTransparency = 1, Text = o.Default or "", PlaceholderText = o.Placeholder or "", PlaceholderColor3 = theme.TextMuted, TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false }, field)
			box.Focused:Connect(function()
				tw(field:FindFirstChildWhichIsA("UIStroke"), T_FAST, { Color = theme.Accent, Transparency = 0.2 }):Play()
			end)
			box.FocusLost:Connect(function(enter)
				tw(field:FindFirstChildWhichIsA("UIStroke"), T_FAST, { Color = theme.StrokeDark, Transparency = theme.StrokeDarkTrans }):Play()
				if enter or not o.Numeric then
					local val = box.Text
					if o.Numeric then val = tostring(tonumber(val) or 0) box.Text = val end
					safecall(o.Callback, val)
					if o.Flag then Celestial.Flags[o.Flag] = val end
				end
			end)
			if o.Tooltip then
				box.MouseEnter:Connect(function() showTooltip(o.Tooltip, box) end)
				box.MouseLeave:Connect(function() hideTooltip() end)
			end
			self._window:_onThemeChange(function(newTheme)
				field.BackgroundColor3 = newTheme.SurfaceDeep
				local s = field:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeDark end
				box.TextColor3 = newTheme.TextPrimary
				box.PlaceholderColor3 = newTheme.TextMuted
			end)
			return { Set = function(v) box.Text = tostring(v) end, Get = function() return box.Text end, Destroy = function() row:Destroy() end }
		end

		function Tab:CreateDropdown(o)
			local selected = o.Default or (o.Options[1] or "")
			local open = false
			local multi = o.Multi or false
			local multiSel = {}
			local container = make("Frame", { Name = "Dropdown", Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = theme.Surface, BackgroundTransparency = theme.SurfaceDeepTrans, ClipsDescendants = false, ZIndex = 10, LayoutOrder = nextOrder() }, frame)
			corner(12, container)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, container)
			make("TextLabel", { Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(0, 110, 1, 0), BackgroundTransparency = 1, Text = o.Name, TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 }, container)
			local selBtn = make("TextButton", { Position = UDim2.new(0, 130, 0.5, -15), Size = UDim2.new(1, -146, 0, 30), BackgroundColor3 = theme.SurfaceDeep, BackgroundTransparency = theme.SurfaceDeepTrans, Text = selected, TextColor3 = theme.TextSecondary, Font = Enum.Font.Gotham, TextSize = 12, AutoButtonColor = false, ZIndex = 11 }, container)
			corner(8, selBtn)
			stroke(theme.StrokeDark, 1, theme.StrokeDarkTrans, selBtn)
			pad(11, 26, 0, 0, selBtn)
			local chev = make("TextLabel", { Position = UDim2.new(1, -22, 0.5, -7), Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1, Text = "⌄", TextColor3 = theme.TextMuted, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 12 }, selBtn)

			local panel = make("Frame", { BackgroundColor3 = theme.WindowBg, BackgroundTransparency = 0.03, ClipsDescendants = true, Visible = false, ZIndex = 250 }, self._window._overlay)
			corner(10, panel)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, panel)
			listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 3, panel)
			pad(5, 5, 5, 5, panel)

			local popupEntry = { _isOpen = false, _container = panel, _trigger = selBtn, _clickOutside = nil }
			table.insert(self._window._openPopups, popupEntry)

			local searchBox = nil
			if #o.Options > 6 then
				searchBox = make("TextBox", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = theme.SurfaceDeep, BackgroundTransparency = 0.5, Text = "", PlaceholderText = "Search...", PlaceholderColor3 = theme.TextMuted, TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 11, ZIndex = 251, LayoutOrder = -1 }, panel)
				corner(6, searchBox)
				pad(8, 8, 0, 0, searchBox)
			end

			local function positionPanel()
				local absPos = selBtn.AbsolutePosition
				local absSize = selBtn.AbsoluteSize
				local screenSize = self._window._overlay.AbsoluteSize
				local panelH = math.max(panel.Size.Y.Offset, math.min(#o.Options * 35 + 10, 220))
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
				trackConn1 = self._window._win:GetPropertyChangedSignal("Position"):Connect(function() if not popupEntry._isOpen then return end positionPanel() end)
				trackConn2 = self._frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function() if not popupEntry._isOpen then return end positionPanel() end)
			end
			local function stopTracking()
				if trackConn1 then trackConn1:Disconnect() trackConn1 = nil end
				if trackConn2 then trackConn2:Disconnect() trackConn2 = nil end
			end

			local function buildItems(opts_)
				local currentTheme = self._window._theme
				for _, c in panel:GetChildren() do
					if c:IsA("TextButton") or (c:IsA("TextBox") and c ~= searchBox) then c:Destroy() end
				end
				for idx, opt in opts_ do
					local isActive = multi and multiSel[opt] or (not multi and opt == selected)
					local item = make("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = if isActive then currentTheme.Accent else currentTheme.Surface, BackgroundTransparency = if isActive then 0.1 else 0.96, Text = opt, TextColor3 = if isActive then currentTheme.AccentText else currentTheme.TextSecondary, Font = if isActive then Enum.Font.GothamBold else Enum.Font.Gotham, TextSize = 12, AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 251, LayoutOrder = idx }, panel)
					corner(7, item)
					pad(12, 0, 0, 0, item)
					item.MouseEnter:Connect(function() if not isActive then tw(item, T_FAST, { BackgroundTransparency = 0.82 }):Play() end end)
					item.MouseLeave:Connect(function() if not isActive then tw(item, T_FAST, { BackgroundTransparency = 0.96 }):Play() end end)
					item.MouseButton1Click:Connect(function()
						if multi then
							multiSel[opt] = not multiSel[opt]
							local chosen = {}
							for k, v in multiSel do if v then table.insert(chosen, k) end end
							selected = table.concat(chosen, ", ")
							selBtn.Text = #chosen > 0 and selected or (o.Options[1] or "")
							safecall(o.Callback, chosen)
							if o.Flag then Celestial.Flags[o.Flag] = chosen end
						else
							selected = opt
							selBtn.Text = opt
							safecall(o.Callback, opt)
							if o.Flag then Celestial.Flags[o.Flag] = opt end
							open = false
							popupEntry._isOpen = false
							stopTracking()
							tw(chev, T_FAST, { Rotation = 0 }):Play()
							tw(panel, T_FAST, { Size = UDim2.new(0, panel.Size.X.Offset, 0, 0) }):Play()
							task.delay(0.18, function() panel.Visible = false end)
						end
						buildItems(opts_)
					end)
				end
				local totalH = math.min(#opts_ * 35 + 10, 220)
				if searchBox then totalH += 32 end
				panel.Size = UDim2.new(0, panel.Size.X.Offset, 0, totalH)
			end

			local function closeDropdown()
				if not open then return end
				open = false
				popupEntry._isOpen = false
				stopTracking()
				tw(chev, T_FAST, { Rotation = 0 }):Play()
				tw(panel, T_FAST, { Size = UDim2.new(0, panel.Size.X.Offset, 0, 0) }):Play()
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
					tw(panel, T_SPRING_SOFT, { Size = UDim2.new(0, panel.Size.X.Offset, 0, math.min(#o.Options * 35 + 10, 220)) }):Play()
					tw(chev, T_MED, { Rotation = 180 }):Play()
				else
					closeDropdown()
				end
			end)

			if searchBox then
				searchBox:GetPropertyChangedSignal("Text"):Connect(function()
					local filter = string.lower(searchBox.Text)
					local filtered = {}
					for _, v in ipairs(o.Options) do
						if string.find(string.lower(v), filter, 1, true) then table.insert(filtered, v) end
					end
					buildItems(filtered)
				end)
			end

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
			return {
				Set = function(val) selected = val selBtn.Text = val safecall(o.Callback, val) if o.Flag then Celestial.Flags[o.Flag] = val end end,
				Get = function() return selected end,
				Refresh = function(newOpts) o.Options = newOpts if open then positionPanel() buildItems(newOpts) end end,
				Destroy = function() panel:Destroy() container:Destroy() end,
			}
		end

		function Tab:CreateColorPicker(o)
			local color = o.Default or Color3.fromRGB(255, 255, 255)
			local row = glassRow(50)
			make("TextLabel", { Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -92, 1, 0), BackgroundTransparency = 1, Text = o.Name, TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, row)
			local preview = make("TextButton", { Size = UDim2.new(0, 40, 0, 26), Position = UDim2.new(1, -52, 0.5, -13), BackgroundColor3 = color, Text = "", AutoButtonColor = false, ZIndex = 5 }, row)
			corner(7, preview)
			stroke(theme.StrokeLight, 1.5, theme.StrokeLightTrans, preview)

			local pickerOpen = false
			local picker = nil
			local popupEntry = { _isOpen = false, _container = nil, _trigger = preview, _clickOutside = nil }
			table.insert(self._window._openPopups, popupEntry)

			local function closePicker()
				if not pickerOpen then return end
				pickerOpen = false
				popupEntry._isOpen = false
				if picker then
					tw(picker, T_FAST, { Size = UDim2.new(0, 220, 0, 0) }):Play()
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
				local pickerW, pickerH = 220, 210
				local px = math.clamp(absPos.X - 182, 6, math.max(6, screenSize.X - pickerW - 6))
				local py = absPos.Y + absSize.Y + 6
				if py + pickerH > screenSize.Y - 6 and absPos.Y - pickerH - 6 >= 6 then
					py = absPos.Y - pickerH - 6
				end

				picker = make("Frame", { Size = UDim2.new(0, pickerW, 0, pickerH), Position = UDim2.new(0, px, 0, py), BackgroundColor3 = theme.WindowBg, BackgroundTransparency = 0.03, ZIndex = 250, ClipsDescendants = false }, self._window._overlay)
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
				end

				local function makeSlider(labelText, yPos, gradientSeq, initialVal, callback)
					make("TextLabel", { Position = UDim2.new(0, 12, 0, yPos), Size = UDim2.new(1, -24, 0, 14), BackgroundTransparency = 1, Text = labelText, TextColor3 = theme.TextSecondary, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 251 }, picker)
					local track = make("Frame", { Position = UDim2.new(0, 12, 0, yPos + 17), Size = UDim2.new(1, -24, 0, 10), BackgroundColor3 = Color3.fromRGB(200, 200, 200), ZIndex = 251 }, picker)
					corner(5, track)
					make("UIGradient", { Color = gradientSeq }, track)
					local thumb = make("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(initialVal, -6, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 252 }, track)
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
					local moveConn = UIS.InputChanged:Connect(function(i)
						if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
							local val = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
							thumb.Position = UDim2.new(val, -6, 0.5, -6)
							callback(val)
						end
					end)
					local upConn = UIS.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
					end)
					return track, thumb, moveConn, upConn
				end

				makeSlider("Hue", 10, ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
				}), h, function(val) h = val applyHSV() end)

				makeSlider("Saturation", 48, ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromHSV(h,1,1)), s, function(val) s = val applyHSV() end)
				makeSlider("Brightness", 86, ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255)), v, function(val) v = val applyHSV() end)

				local hexBox = make("TextBox", { Position = UDim2.new(0, 12, 0, 126), Size = UDim2.new(1, -24, 0, 24), BackgroundColor3 = theme.SurfaceDeep, BackgroundTransparency = 0.5, Text = string.upper(string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)), TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 11, ZIndex = 251 }, picker)
				corner(6, hexBox)
				hexBox.FocusLost:Connect(function()
					local txt = hexBox.Text:gsub("#", "")
					local r = tonumber(txt:sub(1,2), 16) or 255
					local g = tonumber(txt:sub(3,4), 16) or 255
					local b = tonumber(txt:sub(5,6), 16) or 255
					color = Color3.fromRGB(r, g, b)
					h, s, v = Color3.toHSV(color)
					preview.BackgroundColor3 = color
					safecall(o.Callback, color)
					if o.Flag then Celestial.Flags[o.Flag] = color end
				end)

				local presets = { Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255), Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0) }
				for i, preset in ipairs(presets) do
					local pBtn = make("TextButton", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 12 + (i-1)*24, 0, 160), BackgroundColor3 = preset, Text = "", ZIndex = 251 }, picker)
					corner(4, pBtn)
					pBtn.MouseButton1Click:Connect(function()
						color = preset
						h, s, v = Color3.toHSV(color)
						preview.BackgroundColor3 = color
						hexBox.Text = string.upper(string.format("#%02X%02X%02X", preset.R * 255, preset.G * 255, preset.B * 255))
						safecall(o.Callback, color)
						if o.Flag then Celestial.Flags[o.Flag] = color end
					end)
				end
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
			return { Set = function(c) color = c preview.BackgroundColor3 = c safecall(o.Callback, c) if o.Flag then Celestial.Flags[o.Flag] = c end end, Get = function() return color end, Destroy = function() if picker then picker:Destroy() end row:Destroy() end }
		end

		function Tab:CreateKeybind(o)
			local key = o.Default or Enum.KeyCode.Unknown
			local binding = false
			local row = glassRow(50)
			make("TextLabel", { Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -114, 1, 0), BackgroundTransparency = 1, Text = o.Name, TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, row)
			local keyBtn = make("TextButton", { Size = UDim2.new(0, 84, 0, 28), Position = UDim2.new(1, -94, 0.5, -14), BackgroundColor3 = theme.SurfaceDeep, BackgroundTransparency = theme.SurfaceDeepTrans, Text = key.Name, TextColor3 = theme.Accent, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, ZIndex = 5 }, row)
			corner(8, keyBtn)
			stroke(theme.Accent, 1, 0.45, keyBtn)
			local function cancelBind()
				binding = false
				keyBtn.Text = key.Name
				tw(keyBtn, T_FAST, { BackgroundTransparency = theme.SurfaceDeepTrans }):Play()
			end
			keyBtn.MouseButton1Click:Connect(function()
				if binding then cancelBind() return end
				binding = true
				keyBtn.Text = "..."
				tw(keyBtn, T_FAST, { BackgroundTransparency = 0.4 }):Play()
			end)
			local bindConn = UIS.InputBegan:Connect(function(i, gpe)
				if not binding or gpe then return end
				if i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType == Enum.UserInputType.Gamepad1 then
					key = i.KeyCode
					cancelBind()
					safecall(o.Callback, key)
					if o.Flag then Celestial.Flags[o.Flag] = key end
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
			return { Set = function(k) key = k keyBtn.Text = k.Name safecall(o.Callback, k) if o.Flag then Celestial.Flags[o.Flag] = k end end, Get = function() return key end, Destroy = function() bindConn:Disconnect() row:Destroy() end }
		end

		function Tab:CreateProgressBar(o)
			local row = glassRow(o.Height or 28)
			row.Size = UDim2.new(1, 0, 0, o.Height or 28)
			local track = make("Frame", { Size = UDim2.new(1, -32, 0, 8), Position = UDim2.new(0, 16, 0.5, -4), BackgroundColor3 = theme.SliderTrack, BackgroundTransparency = 0.2 }, row)
			corner(4, track)
			local fill = make("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = theme.Accent }, track)
			corner(4, fill)
			local label = make("TextLabel", { Size = UDim2.new(1, -32, 1, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundTransparency = 1, Text = o.Text or "", TextColor3 = theme.TextSecondary, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, row)
			self._window:_onThemeChange(function(newTheme)
				tw(track, T_MED, { BackgroundColor3 = newTheme.SliderTrack }):Play()
				tw(fill, T_MED, { BackgroundColor3 = newTheme.Accent }):Play()
			end)
			return {
				Set = function(pct, text)
					pct = math.clamp(pct, 0, 1)
					tw(fill, T_MED, { Size = UDim2.new(pct, 0, 1, 0) }):Play()
					if text then label.Text = text end
				end,
				Destroy = function() row:Destroy() end,
			}
		end

		table.insert(self._tabs, Tab)
		if #self._tabs == 1 then activate() end
		return Tab
	end

	table.insert(self.Windows, Window)
	return Window
end

function Celestial:SetTheme(name)
	local t = Themes[name]
	if not t then warn("[Celestial] Unknown theme: " .. tostring(name)) return end
	self.ActiveTheme = t
	for _, win in ipairs(self.Windows) do
		win._theme = t
		win:_applyTheme(t)
		if win._activeTab then
			local idx = table.find(win._tabFrames, win._activeTab)
			if idx then
				local btn = win._tabBtns[idx]
				local bar = btn:FindFirstChild("Frame")
				local lbl = btn:FindFirstChildWhichIsA("TextLabel")
				if bar then tw(bar, T_MED, { BackgroundColor3 = t.Accent }):Play() end
				if lbl then tw(lbl, T_MED, { TextColor3 = t.TextPrimary }):Play() end
			end
		end
	end
end

function Celestial:Destroy()
	for _, win in self.Windows do
		if win._screen then safecall(function() win._screen:Destroy() end) end
	end
	self.Windows = {}
end

return Celestial
