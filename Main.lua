--!optimise 2
--!strict
--!native

--[[

	╔═══════════════════════════════════════════════════════╗
	║           Celestial Interface Suite v1.0.0            ║
	║      Fluent · Glassmorphic · Premium · Modern         ║
	╚═══════════════════════════════════════════════════════╝

	by zurai02
	Forked from Zenith (Rayfield lineage)
	Redesigned with Fluent UI / WinUI 3 design language

]]

------------------------------------------------------------------------
-- Services
------------------------------------------------------------------------
local function getService(name)
	local s = game:GetService(name)
	return if cloneref then cloneref(s) else s
end

local UIS         = getService("UserInputService")
local TweenService= getService("TweenService")
local Players     = getService("Players")
local CoreGui     = getService("CoreGui")
local Http        = getService("HttpService")
local Run         = getService("RunService")
local TextService = getService("TextService")

local IS_STUDIO   = Run:IsStudio()

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
local function safecall(fn, ...)
	if not fn then return end
	local ok, r = pcall(fn, ...)
	if not ok then warn("[Celestial] " .. tostring(r)) end
	return ok and r or nil
end

local function folder(path)
	if isfolder and not safecall(isfolder, path) then
		safecall(makefolder, path)
	end
end

local function tw(inst, info, goals)
	return TweenService:Create(inst, info, goals)
end

-- Shared tween presets
local T_FAST   = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local T_MED    = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local T_SLOW   = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local T_SPRING = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)

local function make(cls, props, parent)
	local i = Instance.new(cls)
	for k, v in props do
		pcall(function()
			(i :: any)[k] = v
		end)
	end
	if parent then i.Parent = parent end
	return i
end

local function corner(r, p) return make("UICorner", { CornerRadius = UDim.new(0, r) }, p) end
local function pad(l, r, t, b, p)
	return make("UIPadding", {
		PaddingLeft   = UDim.new(0, l or 0),
		PaddingRight  = UDim.new(0, r or 0),
		PaddingTop    = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
	}, p)
end
local function stroke(color, thick, trans, p)
	return make("UIStroke", { Color = color, Thickness = thick or 1, Transparency = trans or 0 }, p)
end
local function listLayout(dir, sort, spacing, p)
	return make("UIListLayout", {
		FillDirection    = dir or Enum.FillDirection.Vertical,
		SortOrder        = sort or Enum.SortOrder.LayoutOrder,
		Padding          = UDim.new(0, spacing or 6),
	}, p)
end

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
local VERSION     = "1.0.0"
local NAME        = "Celestial"
local FOLDER_ROOT = "Celestial"
local FOLDER_CFG  = FOLDER_ROOT .. "/Configs"
local CFG_EXT     = ".cltl"

------------------------------------------------------------------------
-- Glass palette — Fluent / Mica / Acrylic inspired
------------------------------------------------------------------------
local Themes = {

	Nebula = {
		Accent            = Color3.fromRGB(128, 100, 255),
		AccentHover       = Color3.fromRGB(150, 125, 255),
		AccentText        = Color3.fromRGB(255, 255, 255),
		WindowBg          = Color3.fromRGB(14, 12, 24),
		WindowTrans       = 0.08,
		Surface           = Color3.fromRGB(255, 255, 255),
		SurfaceTrans      = 0.92,
		SurfaceDeep       = Color3.fromRGB(255, 255, 255),
		SurfaceDeepTrans  = 0.88,
		TopbarBg          = Color3.fromRGB(255, 255, 255),
		TopbarTrans       = 0.88,
		SidebarBg         = Color3.fromRGB(255, 255, 255),
		SidebarTrans      = 0.90,
		Divider           = Color3.fromRGB(255, 255, 255),
		DividerTrans      = 0.82,
		TextPrimary       = Color3.fromRGB(245, 245, 255),
		TextSecondary     = Color3.fromRGB(200, 196, 225),
		TextMuted         = Color3.fromRGB(150, 145, 180),
		StrokeLight       = Color3.fromRGB(255, 255, 255),
		StrokeLightTrans  = 0.80,
		StrokeDark        = Color3.fromRGB(100, 90, 160),
		StrokeDarkTrans   = 0.70,
		Toggle            = Color3.fromRGB(128, 100, 255),
		ToggleOff         = Color3.fromRGB(80, 75, 110),
		SliderFill        = Color3.fromRGB(128, 100, 255),
		SliderTrack       = Color3.fromRGB(60, 55, 100),
		Ripple            = Color3.fromRGB(200, 190, 255),
		Shadow            = Color3.fromRGB(5, 3, 18),
	},

	Aurora = {
		Accent            = Color3.fromRGB(32, 200, 165),
		AccentHover       = Color3.fromRGB(50, 220, 185),
		AccentText        = Color3.fromRGB(10, 30, 25),
		WindowBg          = Color3.fromRGB(8, 20, 18),
		WindowTrans       = 0.08,
		Surface           = Color3.fromRGB(255, 255, 255),
		SurfaceTrans      = 0.92,
		SurfaceDeep       = Color3.fromRGB(255, 255, 255),
		SurfaceDeepTrans  = 0.88,
		TopbarBg          = Color3.fromRGB(255, 255, 255),
		TopbarTrans       = 0.88,
		SidebarBg         = Color3.fromRGB(255, 255, 255),
		SidebarTrans      = 0.90,
		Divider           = Color3.fromRGB(255, 255, 255),
		DividerTrans      = 0.82,
		TextPrimary       = Color3.fromRGB(220, 250, 240),
		TextSecondary     = Color3.fromRGB(160, 210, 195),
		TextMuted         = Color3.fromRGB(110, 160, 150),
		StrokeLight       = Color3.fromRGB(255, 255, 255),
		StrokeLightTrans  = 0.80,
		StrokeDark        = Color3.fromRGB(30, 140, 115),
		StrokeDarkTrans   = 0.65,
		Toggle            = Color3.fromRGB(32, 200, 165),
		ToggleOff         = Color3.fromRGB(50, 85, 78),
		SliderFill        = Color3.fromRGB(32, 200, 165),
		SliderTrack       = Color3.fromRGB(30, 70, 62),
		Ripple            = Color3.fromRGB(180, 255, 235),
		Shadow            = Color3.fromRGB(2, 10, 8),
	},

	Dusk = {
		Accent            = Color3.fromRGB(255, 130, 70),
		AccentHover       = Color3.fromRGB(255, 150, 95),
		AccentText        = Color3.fromRGB(30, 10, 0),
		WindowBg          = Color3.fromRGB(22, 12, 6),
		WindowTrans       = 0.08,
		Surface           = Color3.fromRGB(255, 255, 255),
		SurfaceTrans      = 0.92,
		SurfaceDeep       = Color3.fromRGB(255, 255, 255),
		SurfaceDeepTrans  = 0.88,
		TopbarBg          = Color3.fromRGB(255, 255, 255),
		TopbarTrans       = 0.88,
		SidebarBg         = Color3.fromRGB(255, 255, 255),
		SidebarTrans      = 0.90,
		Divider           = Color3.fromRGB(255, 255, 255),
		DividerTrans      = 0.82,
		TextPrimary       = Color3.fromRGB(255, 238, 220),
		TextSecondary     = Color3.fromRGB(215, 185, 155),
		TextMuted         = Color3.fromRGB(165, 135, 110),
		StrokeLight       = Color3.fromRGB(255, 255, 255),
		StrokeLightTrans  = 0.80,
		StrokeDark        = Color3.fromRGB(180, 90, 40),
		StrokeDarkTrans   = 0.65,
		Toggle            = Color3.fromRGB(255, 130, 70),
		ToggleOff         = Color3.fromRGB(100, 60, 40),
		SliderFill        = Color3.fromRGB(255, 130, 70),
		SliderTrack       = Color3.fromRGB(80, 48, 30),
		Ripple            = Color3.fromRGB(255, 210, 170),
		Shadow            = Color3.fromRGB(12, 5, 2),
	},

	Void = {
		Accent            = Color3.fromRGB(160, 110, 255),
		AccentHover       = Color3.fromRGB(180, 135, 255),
		AccentText        = Color3.fromRGB(255, 255, 255),
		WindowBg          = Color3.fromRGB(4, 3, 8),
		WindowTrans       = 0.05,
		Surface           = Color3.fromRGB(255, 255, 255),
		SurfaceTrans      = 0.94,
		SurfaceDeep       = Color3.fromRGB(255, 255, 255),
		SurfaceDeepTrans  = 0.91,
		TopbarBg          = Color3.fromRGB(255, 255, 255),
		TopbarTrans       = 0.91,
		SidebarBg         = Color3.fromRGB(255, 255, 255),
		SidebarTrans      = 0.92,
		Divider           = Color3.fromRGB(255, 255, 255),
		DividerTrans      = 0.88,
		TextPrimary       = Color3.fromRGB(240, 235, 255),
		TextSecondary     = Color3.fromRGB(185, 175, 215),
		TextMuted         = Color3.fromRGB(130, 120, 160),
		StrokeLight       = Color3.fromRGB(255, 255, 255),
		StrokeLightTrans  = 0.85,
		StrokeDark        = Color3.fromRGB(120, 80, 220),
		StrokeDarkTrans   = 0.72,
		Toggle            = Color3.fromRGB(160, 110, 255),
		ToggleOff         = Color3.fromRGB(55, 45, 85),
		SliderFill        = Color3.fromRGB(160, 110, 255),
		SliderTrack       = Color3.fromRGB(35, 28, 60),
		Ripple            = Color3.fromRGB(210, 190, 255),
		Shadow            = Color3.fromRGB(2, 1, 6),
	},

	Frost = {
		Accent            = Color3.fromRGB(10, 130, 230),
		AccentHover       = Color3.fromRGB(30, 150, 250),
		AccentText        = Color3.fromRGB(255, 255, 255),
		WindowBg          = Color3.fromRGB(200, 215, 235),
		WindowTrans       = 0.25,
		Surface           = Color3.fromRGB(255, 255, 255),
		SurfaceTrans      = 0.55,
		SurfaceDeep       = Color3.fromRGB(255, 255, 255),
		SurfaceDeepTrans  = 0.45,
		TopbarBg          = Color3.fromRGB(255, 255, 255),
		TopbarTrans       = 0.45,
		SidebarBg         = Color3.fromRGB(255, 255, 255),
		SidebarTrans      = 0.50,
		Divider           = Color3.fromRGB(0, 0, 0),
		DividerTrans      = 0.90,
		TextPrimary       = Color3.fromRGB(15, 25, 50),
		TextSecondary     = Color3.fromRGB(60, 80, 120),
		TextMuted         = Color3.fromRGB(110, 130, 165),
		StrokeLight       = Color3.fromRGB(255, 255, 255),
		StrokeLightTrans  = 0.35,
		StrokeDark        = Color3.fromRGB(10, 80, 180),
		StrokeDarkTrans   = 0.70,
		Toggle            = Color3.fromRGB(10, 130, 230),
		ToggleOff         = Color3.fromRGB(150, 170, 200),
		SliderFill        = Color3.fromRGB(10, 130, 230),
		SliderTrack       = Color3.fromRGB(170, 190, 220),
		Ripple            = Color3.fromRGB(180, 215, 255),
		Shadow            = Color3.fromRGB(40, 60, 100),
	},
}

------------------------------------------------------------------------
-- Notification system
------------------------------------------------------------------------
local _notifScreen = nil
local _notifHolder = nil

local function ensureNotifLayer()
	if _notifHolder and _notifHolder.Parent then return end

	_notifScreen = make("ScreenGui", {
		Name           = "CelestialNotifs",
		ResetOnSpawn   = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function() _notifScreen.Parent = CoreGui end)

	_notifHolder = make("Frame", {
		Name                  = "Holder",
		Size                  = UDim2.new(0, 300, 1, -20),
		Position              = UDim2.new(1, -316, 0, 10),
		BackgroundTransparency = 1,
	}, _notifScreen)

	make("UIListLayout", {
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		FillDirection     = Enum.FillDirection.Vertical,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Padding           = UDim.new(0, 8),
	}, _notifHolder)
end

------------------------------------------------------------------------
-- Celestial Library
------------------------------------------------------------------------
local Celestial       = {}
Celestial.__index     = Celestial
Celestial.Themes      = Themes
Celestial.ActiveTheme = Themes.Nebula
Celestial.Windows     = {}
Celestial.Flags       = {}

------------------------------------------------------------------------
-- Notify
------------------------------------------------------------------------
function Celestial:Notify(opts: {
	Title:    string,
	Content:  string?,
	Duration: number?,
	Theme:    string?,
	Type:     string?,
})
	ensureNotifLayer()

	local t        = Themes[opts.Theme or ""] or self.ActiveTheme
	local duration = opts.Duration or 4
	local notifType= opts.Type or "info"

	local accentMap = {
		info    = t.Accent,
		success = Color3.fromRGB(50, 210, 120),
		warn    = Color3.fromRGB(255, 185, 40),
		error   = Color3.fromRGB(255, 70, 70),
	}
	local accent = accentMap[notifType] or t.Accent

	local card = make("Frame", {
		Name                  = "Notif",
		Size                  = UDim2.new(1, 0, 0, 68),
		BackgroundColor3      = t.Surface,
		BackgroundTransparency= t.SurfaceTrans,
		ClipsDescendants      = false,
	}, _notifHolder)
	corner(12, card)
	stroke(t.StrokeLight, 1, t.StrokeLightTrans, card)

	local pill = make("Frame", {
		Size             = UDim2.new(0, 3, 0.7, 0),
		Position         = UDim2.new(0, 8, 0.15, 0),
		BackgroundColor3 = accent,
	}, card)
	corner(4, pill)

	local iconMap = { info = "ℹ", success = "✓", warn = "⚠", error = "✕" }
	make("TextLabel", {
		Position              = UDim2.new(0, 20, 0.5, -10),
		Size                  = UDim2.new(0, 20, 0, 20),
		BackgroundTransparency= 1,
		Text                  = iconMap[notifType] or "ℹ",
		TextColor3            = accent,
		Font                  = Enum.Font.GothamBold,
		TextSize              = 14,
	}, card)

	make("TextLabel", {
		Position              = UDim2.new(0, 46, 0, 10),
		Size                  = UDim2.new(1, -54, 0, 20),
		BackgroundTransparency= 1,
		Text                  = opts.Title or "",
		TextColor3            = t.TextPrimary,
		Font                  = Enum.Font.GothamBold,
		TextSize              = 13,
		TextXAlignment        = Enum.TextXAlignment.Left,
	}, card)

	if opts.Content and #opts.Content > 0 then
		make("TextLabel", {
			Position              = UDim2.new(0, 46, 0, 32),
			Size                  = UDim2.new(1, -54, 0, 28),
			BackgroundTransparency= 1,
			Text                  = opts.Content,
			TextColor3            = t.TextSecondary,
			Font                  = Enum.Font.Gotham,
			TextSize              = 11,
			TextXAlignment        = Enum.TextXAlignment.Left,
			TextWrapped           = true,
		}, card)
	end

	local bar = make("Frame", {
		Position         = UDim2.new(0, 0, 1, -2),
		Size             = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.4,
	}, card)
	corner(2, bar)

	card.Position = UDim2.new(1, 16, 0, 0)
	tw(card, T_SPRING, { Position = UDim2.new(0, 0, 0, 0) }):Play()

	tw(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 2),
	}):Play()

	task.delay(duration, function()
		tw(card, T_MED, {
			Position              = UDim2.new(1, 16, 0, 0),
			BackgroundTransparency = 1,
		}):Play()
		task.wait(0.3)
		card:Destroy()
	end)
end

------------------------------------------------------------------------
-- CreateWindow
------------------------------------------------------------------------
function Celestial:CreateWindow(opts: {
	Name:    string,
	Theme:   string?,
	Icon:    number?,
	Keybind: Enum.KeyCode?,
	Size:    Vector2?,
	ConfigurationSaving: { Enabled: boolean, FileName: string? }?,
}): table

	local t = Themes[opts.Theme or ""] or self.ActiveTheme
	self.ActiveTheme = t

	folder(FOLDER_ROOT)
	folder(FOLDER_CFG)

	local W = opts.Size and opts.Size.X or 580
	local H = opts.Size and opts.Size.Y or 400

	------------------------------------------------------------------------
	-- Root screen
	------------------------------------------------------------------------
	local screen = make("ScreenGui", {
		Name           = opts.Name or NAME,
		ResetOnSpawn   = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function() screen.Parent = CoreGui end)

	-- Global overlay to escape ScrollingFrame clipping
	local overlay = make("Frame", {
		Name = "Overlay",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 200,
	}, screen)

	------------------------------------------------------------------------
	-- Window frame (glass card)
	------------------------------------------------------------------------
	local win = make("Frame", {
		Name                  = "Window",
		Size                  = UDim2.new(0, W, 0, H),
		Position              = UDim2.new(0.5, -W/2, 0.5, -H/2),
		BackgroundColor3      = t.WindowBg,
		BackgroundTransparency= t.WindowTrans,
		ClipsDescendants      = true,
		ZIndex                = 1,
	}, screen)
	corner(16, win)
	stroke(t.StrokeLight, 1, t.StrokeLightTrans, win)

	local topGlow = make("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = t.StrokeLight,
		BackgroundTransparency = 0.55,
		ZIndex           = 10,
	}, win)

	-- Shadow image — ZIndex = 0 because Roblox clamps negatives to 0
	make("ImageLabel", {
		Name                  = "Shadow",
		Size                  = UDim2.new(1, 60, 1, 60),
		Position              = UDim2.new(0, -30, 0, -30),
		BackgroundTransparency= 1,
		Image                 = "rbxassetid://6014261993",
		ImageColor3           = t.Shadow,
		ImageTransparency     = 0.35,
		ScaleType             = Enum.ScaleType.Slice,
		SliceCenter           = Rect.new(49, 49, 450, 450),
		ZIndex                = 0,
	}, win)

	------------------------------------------------------------------------
	-- Topbar
	------------------------------------------------------------------------
	local topbar = make("Frame", {
		Name                  = "Topbar",
		Size                  = UDim2.new(1, 0, 0, 46),
		BackgroundColor3      = t.TopbarBg,
		BackgroundTransparency= t.TopbarTrans,
		ZIndex                = 5,
	}, win)

	local topbarSep = make("Frame", {
		Position         = UDim2.new(0, 0, 1, -1),
		Size             = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = t.Divider,
		BackgroundTransparency = t.DividerTrans,
		ZIndex           = 5,
	}, topbar)

	make("TextLabel", {
		Position              = UDim2.new(0, 16, 0, 0),
		Size                  = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency= 1,
		Text                  = opts.Name or NAME,
		TextColor3            = t.TextPrimary,
		Font                  = Enum.Font.GothamBold,
		TextSize              = 14,
		TextXAlignment        = Enum.TextXAlignment.Left,
		ZIndex                = 6,
	}, topbar)

	local badge = make("Frame", {
		Size                  = UDim2.new(0, 52, 0, 20),
		Position              = UDim2.new(0, 16 + 8, 0.5, -10),
		BackgroundColor3      = t.Accent,
		BackgroundTransparency= 0.75,
		ZIndex                = 6,
	}, topbar)
	corner(6, badge)
	make("TextLabel", {
		Size                  = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency= 1,
		Text                  = "v" .. VERSION,
		TextColor3            = t.Accent,
		Font                  = Enum.Font.GothamBold,
		TextSize              = 10,
		ZIndex                = 7,
	}, badge)
	badge.Position = UDim2.new(0, 16 + (string.len(opts.Name or NAME) * 8.5) + 12, 0.5, -10)

	local function makeCtrl(color, xPos, onClick)
		local btn = make("TextButton", {
			Size             = UDim2.new(0, 14, 0, 14),
			Position         = UDim2.new(1, xPos, 0.5, -7),
			BackgroundColor3 = color,
			Text             = "",
			AutoButtonColor  = false,
			ZIndex           = 6,
		}, topbar)
		corner(7, btn)
		btn.MouseButton1Click:Connect(onClick)
		btn.MouseEnter:Connect(function()
			tw(btn, T_FAST, { BackgroundTransparency = 0.2 }):Play()
		end)
		btn.MouseLeave:Connect(function()
			tw(btn, T_FAST, { BackgroundTransparency = 0 }):Play()
		end)
		return btn
	end

	local minimised = false
	makeCtrl(Color3.fromRGB(255, 90, 80), -28, function()
		tw(win, T_MED, {
			Size     = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1,
		}):Play()
		task.wait(0.28)
		screen:Destroy()
	end)

	makeCtrl(Color3.fromRGB(255, 190, 50), -50, function()
		minimised = not minimised
		tw(win, T_MED, {
			Size = if minimised
				then UDim2.new(0, W, 0, 46)
				else UDim2.new(0, W, 0, H),
		}):Play()
	end)

	------------------------------------------------------------------------
	-- Dragging (Mouse + Touch)
	------------------------------------------------------------------------
	do
		local drag, startMouse, startPos = false, nil, nil
		topbar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 
			   or i.UserInputType == Enum.UserInputType.Touch then
				drag = true
				startMouse = i.Position
				startPos   = win.Position
			end
		end)
		topbar.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 
			   or i.UserInputType == Enum.UserInputType.Touch then
				drag = false
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if drag and (i.UserInputType == Enum.UserInputType.MouseMovement 
			             or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - startMouse
				win.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y
				)
			end
		end)
	end

	------------------------------------------------------------------------
	-- Layout: sidebar + content
	------------------------------------------------------------------------
	local sidebar = make("Frame", {
		Name                  = "Sidebar",
		Position              = UDim2.new(0, 0, 0, 46),
		Size                  = UDim2.new(0, 155, 1, -46),
		BackgroundColor3      = t.SidebarBg,
		BackgroundTransparency= t.SidebarTrans,
		ClipsDescendants      = true,
		ZIndex                = 4,
	}, win)

	local sidebarSep = make("Frame", {
		Position              = UDim2.new(1, -1, 0, 0),
		Size                  = UDim2.new(0, 1, 1, 0),
		BackgroundColor3      = t.Divider,
		BackgroundTransparency= t.DividerTrans,
		ZIndex                = 4,
	}, sidebar)

	listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 4, sidebar)
	pad(8, 8, 10, 10, sidebar)

	local content = make("Frame", {
		Name                  = "Content",
		Position              = UDim2.new(0, 156, 0, 46),
		Size                  = UDim2.new(1, -156, 1, -46),
		BackgroundTransparency= 1,
		ClipsDescendants      = true,
		ZIndex                = 2,
	}, win)

	------------------------------------------------------------------------
	-- Keybind toggle
	------------------------------------------------------------------------
	local kb = opts.Keybind or Enum.KeyCode.LeftAlt
	UIS.InputBegan:Connect(function(i, gpe)
		if gpe then return end
		if i.KeyCode == kb then
			win.Visible = not win.Visible
		end
	end)

	------------------------------------------------------------------------
	-- Open animation
	------------------------------------------------------------------------
	win.Size     = UDim2.new(0, 0, 0, 0)
	win.Position = UDim2.new(0.5, 0, 0.5, 0)
	win.BackgroundTransparency = 1
	task.wait()
	tw(win, T_SPRING, {
		Size                  = UDim2.new(0, W, 0, H),
		Position              = UDim2.new(0.5, -W/2, 0.5, -H/2),
		BackgroundTransparency= t.WindowTrans,
	}):Play()

	------------------------------------------------------------------------
	-- Window object
	------------------------------------------------------------------------
	local Window = {}
	Window._theme      = t
	Window._screen     = screen
	Window._win        = win
	Window._sidebar    = sidebar
	Window._content    = content
	Window._tabs       = {}
	Window._tabBtns    = {}
	Window._tabFrames  = {}
	Window._activeTab  = nil
	Window._themeCallbacks = {}
	Window._overlay    = overlay
	Window._openPopups = {} -- track open dropdowns/colorpickers for click-outside

	function Window:_onThemeChange(fn)
		table.insert(self._themeCallbacks, fn)
	end

	function Window:_applyTheme(newTheme)
		for _, cb in ipairs(self._themeCallbacks) do
			safecall(cb, newTheme)
		end
	end

	-- Register shell elements for live theme reload
	Window:_onThemeChange(function(newTheme)
		tw(win, T_MED, { BackgroundColor3 = newTheme.WindowBg, BackgroundTransparency = newTheme.WindowTrans }):Play()
		tw(topbar, T_MED, { BackgroundColor3 = newTheme.TopbarBg, BackgroundTransparency = newTheme.TopbarTrans }):Play()
		tw(topbarSep, T_MED, { BackgroundColor3 = newTheme.Divider, BackgroundTransparency = newTheme.DividerTrans }):Play()
		tw(sidebar, T_MED, { BackgroundColor3 = newTheme.SidebarBg, BackgroundTransparency = newTheme.SidebarTrans }):Play()
		tw(sidebarSep, T_MED, { BackgroundColor3 = newTheme.Divider, BackgroundTransparency = newTheme.DividerTrans }):Play()
	end)

	-- Click-outside-to-close handler (fix #7)
	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 
		   and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		for _, popup in ipairs(Window._openPopups) do
			if popup._isOpen and popup._clickOutside then
				local pos = input.Position
				local absPos = popup._container and popup._container.AbsolutePosition
				local absSize = popup._container and popup._container.AbsoluteSize
				if absPos and absSize then
					if pos.X < absPos.X or pos.X > absPos.X + absSize.X
					   or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
						popup._clickOutside()
					end
				end
			end
		end
	end)

	------------------------------------------------------------------------
	-- Config persistence
	------------------------------------------------------------------------
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
		end
	end

	------------------------------------------------------------------------
	-- SelectTab
	------------------------------------------------------------------------
	function Window:SelectTab(index: number)
		local tab = self._tabs[index]
		if tab and tab._activate then
			tab._activate()
		end
	end

	------------------------------------------------------------------------
	-- CreateTab
	------------------------------------------------------------------------
	function Window:CreateTab(tabOpts: { Name: string, Icon: string? }): table
		local tabName = tabOpts.Name or "Tab"
		local theme   = self._theme

		--------------------------------------------------------------------
		-- Sidebar button
		--------------------------------------------------------------------
		local btn = make("TextButton", {
			Name                  = tabName,
			Size                  = UDim2.new(1, 0, 0, 34),
			BackgroundColor3      = theme.Surface,
			BackgroundTransparency= 1,
			Text                  = "",
			AutoButtonColor       = false,
			ZIndex                = 5,
		}, self._sidebar)
		corner(8, btn)

		local textOffset = 10
		local textWidth = -10

		-- Icon support
		if tabOpts.Icon then
			textOffset = 34
			textWidth = -34
			if tabOpts.Icon:find("rbxassetid://") or tabOpts.Icon:match("^%d+$") then
				make("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 10, 0.5, -9),
					BackgroundTransparency = 1,
					Image = if tabOpts.Icon:match("^%d+$") then "rbxassetid://" .. tabOpts.Icon else tabOpts.Icon,
					ImageColor3 = theme.TextMuted,
					ZIndex = 6,
				}, btn)
			else
				make("TextLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 10, 0.5, -9),
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
			Position              = UDim2.new(0, textOffset, 0, 0),
			Size                  = UDim2.new(1, textWidth, 1, 0),
			BackgroundTransparency= 1,
			Text                  = tabName,
			TextColor3            = theme.TextMuted,
			Font                  = Enum.Font.Gotham,
			TextSize              = 13,
			TextXAlignment        = Enum.TextXAlignment.Left,
			ZIndex                = 6,
		}, btn)

		local accentBar = make("Frame", {
			Size             = UDim2.new(0, 3, 0.55, 0),
			Position         = UDim2.new(0, 0, 0.225, 0),
			BackgroundColor3 = theme.Accent,
			BackgroundTransparency = 1,
			ZIndex           = 6,
		}, btn)
		corner(4, accentBar)

		--------------------------------------------------------------------
		-- Content scroll frame
		--------------------------------------------------------------------
		local frame = make("ScrollingFrame", {
			Name                  = tabName .. "_Frame",
			Size                  = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency= 1,
			ScrollBarThickness    = 3,
			ScrollBarImageColor3  = theme.Accent,
			ScrollBarImageTransparency = 0.5,
			CanvasSize            = UDim2.new(0, 0, 0, 0),
			Visible               = false,
			ZIndex                = 3,
		}, self._content)

		local layout = listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 6, frame)
		pad(14, 14, 12, 14, frame)

		-- Manual canvas sizing (connect BEFORE any elements are added)
		local function updateCanvas()
			frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
		end
		updateCanvas()

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

		table.insert(self._tabBtns, btn)
		table.insert(self._tabFrames, frame)

		--------------------------------------------------------------------
		-- Activate
		--------------------------------------------------------------------
		local function activate()
			for _, b in self._tabBtns do
				local bar_ = b:FindFirstChild("Frame")
				tw(b, T_FAST, { BackgroundTransparency = 1 }):Play()
				if bar_ then tw(bar_, T_FAST, { BackgroundTransparency = 1 }):Play() end
				local lbl = b:FindFirstChildWhichIsA("TextLabel")
				if lbl then tw(lbl, T_FAST, { TextColor3 = theme.TextMuted, Font = Enum.Font.Gotham }):Play() end
			end
			for _, f in self._tabFrames do f.Visible = false end

			tw(btn, T_FAST, { BackgroundTransparency = theme.SurfaceDeepTrans }):Play()
			tw(accentBar, T_FAST, { BackgroundTransparency = 0 }):Play()
			tw(btnLabel, T_FAST, { TextColor3 = theme.TextPrimary }):Play()
			btnLabel.Font = Enum.Font.GothamBold
			frame.Visible = true
			self._activeTab = frame
			-- Force canvas refresh on activation in case layout shifted while invisible
			task.defer(updateCanvas)
		end

		btn.MouseButton1Click:Connect(activate)
		btn.MouseEnter:Connect(function()
			if frame.Visible then return end
			tw(btn, T_FAST, { BackgroundTransparency = theme.SurfaceTrans }):Play()
		end)
		btn.MouseLeave:Connect(function()
			if frame.Visible then return end
			tw(btn, T_FAST, { BackgroundTransparency = 1 }):Play()
		end)

		-- Removed auto-activate. User must call Window:SelectTab(1) after setup.

		--------------------------------------------------------------------
		-- Tab element API
		--------------------------------------------------------------------
		local Tab = {}
		Tab._frame = frame
		Tab._window = self
		Tab._layoutOrder = 0
		Tab._activate = activate

		local function nextOrder()
			Tab._layoutOrder += 1
			return Tab._layoutOrder
		end

		-- Helper: glass element row
		local function glassRow(height, parent)
			local row = make("Frame", {
				Size                  = UDim2.new(1, 0, 0, height or 48),
				BackgroundColor3      = theme.Surface,
				BackgroundTransparency= theme.SurfaceDeepTrans,
				ClipsDescendants      = false,
				LayoutOrder           = nextOrder(),
			}, parent or frame)
			corner(10, row)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, row)
			return row
		end

		-- Ripple effect
		local function ripple(parent, x, y)
			local r = make("Frame", {
				Size             = UDim2.new(0, 0, 0, 0),
				Position         = UDim2.new(0, x, 0, y),
				AnchorPoint      = Vector2.new(0.5, 0.5),
				BackgroundColor3 = theme.Ripple,
				BackgroundTransparency = 0.7,
				ZIndex           = 20,
			}, parent)
			corner(999, r)
			tw(r, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
				Size = UDim2.new(0, 120, 0, 120),
				BackgroundTransparency = 1,
			}):Play()
			task.delay(0.4, function() r:Destroy() end)
		end

		--------------------------------------------------------------------
		-- RefreshCanvas
		--------------------------------------------------------------------
		function Tab:RefreshCanvas()
			local lay = self._frame:FindFirstChildOfClass("UIListLayout")
			if lay then
				self._frame.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 20)
			end
		end

		--------------------------------------------------------------------
		-- Section
		--------------------------------------------------------------------
		function Tab:CreateSection(text: string)
			local lbl = make("TextLabel", {
				Size                  = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency= 1,
				Text                  = text,
				TextColor3            = theme.TextMuted,
				Font                  = Enum.Font.GothamBold,
				TextSize              = 10,
				TextXAlignment        = Enum.TextXAlignment.Left,
				LayoutOrder           = nextOrder(),
			}, frame)

			self._window:_onThemeChange(function(newTheme)
				lbl.TextColor3 = newTheme.TextMuted
			end)
		end

		--------------------------------------------------------------------
		-- Paragraph (fixes #1, #2, #5, #6: return object + dynamic resize + deferred height)
		--------------------------------------------------------------------
		function Tab:CreateParagraph(o: { Title: string, Content: string?, Height: number? })
			local titleText = o.Title or ""
			local contentText = o.Content or ""

			local container = make("Frame", {
				Size                  = UDim2.new(1, 0, 0, o.Height or 60),
				BackgroundColor3      = theme.Surface,
				BackgroundTransparency= theme.SurfaceDeepTrans,
				ClipsDescendants      = false,
				LayoutOrder           = nextOrder(),
			}, frame)
			corner(10, container)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, container)

			local titleLabel = make("TextLabel", {
				Position              = UDim2.new(0, 14, 0, 8),
				Size                  = UDim2.new(1, -28, 0, 18),
				BackgroundTransparency= 1,
				Text                  = titleText,
				TextColor3            = theme.TextPrimary,
				Font                  = Enum.Font.GothamBold,
				TextSize              = 13,
				TextXAlignment        = Enum.TextXAlignment.Left,
				TextWrapped           = true,
			}, container)

			local contentLabel = nil
			if o.Content and o.Content ~= "" then
				contentLabel = make("TextLabel", {
					Position              = UDim2.new(0, 14, 0, 28),
					Size                  = UDim2.new(1, -28, 0, 24),
					BackgroundTransparency= 1,
					Text                  = o.Content,
					TextColor3            = theme.TextSecondary,
					Font                  = Enum.Font.Gotham,
					TextSize              = 11,
					TextXAlignment        = Enum.TextXAlignment.Left,
					TextWrapped           = true,
				}, container)
			end

			-- Deferred height calculation (fix #6)
			local function recalcHeight()
				local availWidth = math.max(container.AbsoluteSize.X - 28, 300)
				local titleSize = TextService:GetTextSize(titleLabel.Text, 13, Enum.Font.GothamBold, Vector2.new(availWidth, math.huge))
				local contentSize = contentLabel and TextService:GetTextSize(contentLabel.Text, 11, Enum.Font.Gotham, Vector2.new(availWidth, math.huge)) or Vector2.new(0, 0)

				titleLabel.Size = UDim2.new(1, -28, 0, titleSize.Y)
				if contentLabel then
					contentLabel.Size = UDim2.new(1, -28, 0, contentSize.Y)
					contentLabel.Position = UDim2.new(0, 14, 0, 8 + titleSize.Y + 4)
				end

				local totalHeight = o.Height or (16 + titleSize.Y + 4 + contentSize.Y + 12)
				container.Size = UDim2.new(1, 0, 0, totalHeight)
				Tab:RefreshCanvas()
			end

			-- Run after layout is stable
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
				SetTitle = function(t)
					titleLabel.Text = t
					recalcHeight()
				end,
				SetContent = function(c)
					if contentLabel then
						contentLabel.Text = c
						recalcHeight()
					elseif c and c ~= "" then
						contentLabel = make("TextLabel", {
							Position = UDim2.new(0, 14, 0, 28),
							Size = UDim2.new(1, -28, 0, 24),
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

		--------------------------------------------------------------------
		-- Button
		--------------------------------------------------------------------
		function Tab:CreateButton(o: { Name: string, Description: string?, Callback: () -> () })
			local row = glassRow(48)
			row.ClipsDescendants = true

			make("TextLabel", {
				Position              = UDim2.new(0, 14, 0, 0),
				Size                  = UDim2.new(1, -100, 1, 0),
				BackgroundTransparency= 1,
				Text                  = o.Name,
				TextColor3            = theme.TextPrimary,
				Font                  = Enum.Font.Gotham,
				TextSize              = 13,
				TextXAlignment        = Enum.TextXAlignment.Left,
			}, row)

			if o.Description then
				make("TextLabel", {
					Position              = UDim2.new(0, 14, 0, 28),
					Size                  = UDim2.new(1, -100, 0, 16),
					BackgroundTransparency= 1,
					Text                  = o.Description,
					TextColor3            = theme.TextMuted,
					Font                  = Enum.Font.Gotham,
					TextSize              = 10,
					TextXAlignment        = Enum.TextXAlignment.Left,
				}, row)
				row.Size = UDim2.new(1, 0, 0, 60)
			end

			local cBtn = make("TextButton", {
				Size                  = UDim2.new(0, 72, 0, 28),
				Position              = UDim2.new(1, -82, 0.5, -14),
				BackgroundColor3      = theme.Accent,
				BackgroundTransparency= 0.1,
				Text                  = "Run",
				TextColor3            = theme.AccentText,
				Font                  = Enum.Font.GothamBold,
				TextSize              = 12,
				AutoButtonColor       = false,
				ZIndex                = 5,
			}, row)
			corner(7, cBtn)

			cBtn.MouseButton1Click:Connect(function(x, y)
				tw(cBtn, T_FAST, { BackgroundTransparency = 0.4 }):Play()
				ripple(row, cBtn.AbsolutePosition.X - row.AbsolutePosition.X + 36, 24)
				task.delay(0.12, function()
					tw(cBtn, T_FAST, { BackgroundTransparency = 0.1 }):Play()
				end)
				safecall(o.Callback)
			end)

			row.MouseEnter:Connect(function()
				tw(row, T_FAST, { BackgroundTransparency = theme.SurfaceTrans }):Play()
			end)
			row.MouseLeave:Connect(function()
				tw(row, T_FAST, { BackgroundTransparency = theme.SurfaceDeepTrans }):Play()
			end)

			self._window:_onThemeChange(function(newTheme)
				tw(cBtn, T_MED, { BackgroundColor3 = newTheme.Accent }):Play()
				cBtn.TextColor3 = newTheme.AccentText
			end)
		end

		--------------------------------------------------------------------
		-- Toggle
		--------------------------------------------------------------------
		function Tab:CreateToggle(o: {
			Name:     string,
			Description: string?,
			Default:  boolean?,
			Flag:     string?,
			Callback: (boolean) -> (),
		}): { Set: (boolean) -> () }
			local hasDesc = o.Description and o.Description ~= ""
			local state = o.Default or false
			local row   = glassRow(hasDesc and 60 or 48)

			make("TextLabel", {
				Position              = UDim2.new(0, 14, 0, 8),
				Size                  = UDim2.new(1, -80, 0, 18),
				BackgroundTransparency= 1,
				Text                  = o.Name,
				TextColor3            = theme.TextPrimary,
				Font                  = Enum.Font.Gotham,
				TextSize              = 13,
				TextXAlignment        = Enum.TextXAlignment.Left,
			}, row)

			if hasDesc then
				make("TextLabel", {
					Position              = UDim2.new(0, 14, 0, 28),
					Size                  = UDim2.new(1, -80, 0, 16),
					BackgroundTransparency= 1,
					Text                  = o.Description,
					TextColor3            = theme.TextMuted,
					Font                  = Enum.Font.Gotham,
					TextSize              = 10,
					TextXAlignment        = Enum.TextXAlignment.Left,
				}, row)
			end

			local track = make("Frame", {
				Size                  = UDim2.new(0, 44, 0, 24),
				Position              = UDim2.new(1, -56, 0.5, -12),
				BackgroundColor3      = if state then theme.Toggle else theme.ToggleOff,
				BackgroundTransparency= 0.1,
			}, row)
			corner(12, track)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, track)

			local knob = make("Frame", {
				Size             = UDim2.new(0, 18, 0, 18),
				Position         = if state
					then UDim2.new(1, -21, 0.5, -9)
					else UDim2.new(0, 3, 0.5, -9),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			}, track)
			corner(9, knob)

			local clickArea = make("TextButton", {
				Size             = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text             = "",
			}, row)

			local function setState(val: boolean)
				state = val
				tw(track, T_MED, {
					BackgroundColor3 = if val then theme.Toggle else theme.ToggleOff,
				}):Play()
				tw(knob, T_MED, {
					Position = if val
						then UDim2.new(1, -21, 0.5, -9)
						else UDim2.new(0, 3, 0.5, -9),
					Size     = UDim2.new(0, 18, 0, 18),
				}):Play()
				safecall(o.Callback, val)
				if o.Flag then Celestial.Flags[o.Flag] = val end
			end

			clickArea.MouseButton1Down:Connect(function()
				tw(knob, T_FAST, {
					Size = UDim2.new(0, 22, 0, 18),
				}):Play()
			end)
			clickArea.MouseButton1Up:Connect(function()
				setState(not state)
			end)

			if o.Flag then Celestial.Flags[o.Flag] = state end

			self._window:_onThemeChange(function(newTheme)
				tw(track, T_MED, { BackgroundColor3 = state and newTheme.Toggle or newTheme.ToggleOff }):Play()
				local s = track:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeLight end
			end)

			return { Set = setState }
		end

		--------------------------------------------------------------------
		-- Slider
		--------------------------------------------------------------------
		function Tab:CreateSlider(o: {
			Name:     string,
			Description: string?,
			Min:      number,
			Max:      number,
			Default:  number?,
			Step:     number?,
			Suffix:   string?,
			Flag:     string?,
			Callback: (number) -> (),
		}): { Set: (number) -> () }
			local hasDesc = o.Description and o.Description ~= ""
			local mn, mx  = o.Min, o.Max
			local step    = o.Step or 1
			local value   = math.clamp(o.Default or mn, mn, mx)
			local row     = glassRow(hasDesc and 72 or 62)

			make("TextLabel", {
				Position              = UDim2.new(0, 14, 0, 8),
				Size                  = UDim2.new(1, -80, 0, 18),
				BackgroundTransparency= 1,
				Text                  = o.Name,
				TextColor3            = theme.TextPrimary,
				Font                  = Enum.Font.Gotham,
				TextSize              = 13,
				TextXAlignment        = Enum.TextXAlignment.Left,
			}, row)

			if hasDesc then
				make("TextLabel", {
					Position              = UDim2.new(0, 14, 0, 26),
					Size                  = UDim2.new(1, -80, 0, 16),
					BackgroundTransparency= 1,
					Text                  = o.Description,
					TextColor3            = theme.TextMuted,
					Font                  = Enum.Font.Gotham,
					TextSize              = 10,
					TextXAlignment        = Enum.TextXAlignment.Left,
				}, row)
			end

			local valLabel = make("TextLabel", {
				Position              = UDim2.new(1, -68, 0, 8),
				Size                  = UDim2.new(0, 60, 0, 18),
				BackgroundTransparency= 1,
				Text                  = tostring(value) .. (o.Suffix or ""),
				TextColor3            = theme.Accent,
				Font                  = Enum.Font.GothamBold,
				TextSize              = 12,
				TextXAlignment        = Enum.TextXAlignment.Right,
			}, row)

			local trackY = hasDesc and 48 or 38
			local trackBg = make("Frame", {
				Position         = UDim2.new(0, 14, 0, trackY),
				Size             = UDim2.new(1, -28, 0, 4),
				BackgroundColor3 = theme.SliderTrack,
				BackgroundTransparency = 0.4,
			}, row)
			corner(4, trackBg)

			local fill = make("Frame", {
				Size             = UDim2.new((value - mn)/(mx - mn), 0, 1, 0),
				BackgroundColor3 = theme.SliderFill,
			}, trackBg)
			corner(4, fill)

			local thumb = make("Frame", {
				Size             = UDim2.new(0, 14, 0, 14),
				Position         = UDim2.new((value - mn)/(mx - mn), -7, 0.5, -7),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex           = 5,
			}, trackBg)
			corner(7, thumb)
			stroke(theme.Accent, 2, 0.2, thumb)

			local dragging = false

			local function snapTo(v)
				v = math.clamp(
					math.round((v - mn) / step) * step + mn,
					mn, mx
				)
				value = v
				local pct = (v - mn) / (mx - mn)
				tw(fill,  T_FAST, { Size     = UDim2.new(pct, 0, 1, 0) }):Play()
				tw(thumb, T_FAST, { Position = UDim2.new(pct, -7, 0.5, -7) }):Play()
				valLabel.Text = tostring(v) .. (o.Suffix or "")
				safecall(o.Callback, v)
				if o.Flag then Celestial.Flags[o.Flag] = v end
			end

			local function onInput(input)
				local rel = math.clamp(
					(input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X,
					0, 1
				)
				snapTo(mn + rel * (mx - mn))
			end

			trackBg.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 
				   or i.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					onInput(i)
					tw(thumb, T_FAST, { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new((value-mn)/(mx-mn), -9, 0.5, -9) }):Play()
				end
			end)
			UIS.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement 
				                 or i.UserInputType == Enum.UserInputType.Touch) then
					onInput(i)
				end
			end)
			UIS.InputEnded:Connect(function(i)
				if (i.UserInputType == Enum.UserInputType.MouseButton1 
				    or i.UserInputType == Enum.UserInputType.Touch) and dragging then
					dragging = false
					tw(thumb, T_FAST, { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new((value-mn)/(mx-mn), -7, 0.5, -7) }):Play()
				end
			end)

			if o.Flag then Celestial.Flags[o.Flag] = value end

			self._window:_onThemeChange(function(newTheme)
				tw(trackBg, T_MED, { BackgroundColor3 = newTheme.SliderTrack }):Play()
				tw(fill, T_MED, { BackgroundColor3 = newTheme.SliderFill }):Play()
				valLabel.TextColor3 = newTheme.Accent
				local s = thumb:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.Accent end
			end)

			return { Set = snapTo }
		end

		--------------------------------------------------------------------
		-- Input
		--------------------------------------------------------------------
		function Tab:CreateInput(o: {
			Name:        string,
			Placeholder: string?,
			Numeric:     boolean?,
			Flag:        string?,
			Callback:    (string) -> (),
		})
			local row = glassRow(48)

			make("TextLabel", {
				Position              = UDim2.new(0, 14, 0, 0),
				Size                  = UDim2.new(0, 110, 1, 0),
				BackgroundTransparency= 1,
				Text                  = o.Name,
				TextColor3            = theme.TextPrimary,
				Font                  = Enum.Font.Gotham,
				TextSize              = 13,
				TextXAlignment        = Enum.TextXAlignment.Left,
			}, row)

			local field = make("Frame", {
				Position              = UDim2.new(0, 128, 0.5, -14),
				Size                  = UDim2.new(1, -140, 0, 28),
				BackgroundColor3      = theme.SurfaceDeep,
				BackgroundTransparency= theme.SurfaceDeepTrans,
			}, row)
			corner(7, field)
			stroke(theme.StrokeDark, 1, theme.StrokeDarkTrans, field)

			local box = make("TextBox", {
				Size                  = UDim2.new(1, -16, 1, 0),
				Position              = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency= 1,
				Text                  = "",
				PlaceholderText       = o.Placeholder or "",
				PlaceholderColor3     = theme.TextMuted,
				TextColor3            = theme.TextPrimary,
				Font                  = Enum.Font.Gotham,
				TextSize              = 12,
				ClearTextOnFocus      = false,
			}, field) :: TextBox

			box.Focused:Connect(function()
				tw(field:FindFirstChildWhichIsA("UIStroke"), T_FAST, {
					Color = theme.Accent, Transparency = 0.3
				}):Play()
			end)
			box.FocusLost:Connect(function(enter)
				tw(field:FindFirstChildWhichIsA("UIStroke"), T_FAST, {
					Color = theme.StrokeDark, Transparency = theme.StrokeDarkTrans
				}):Play()
				if enter or not o.Numeric then
					local val = box.Text
					if o.Numeric then val = tostring(tonumber(val) or 0) end
					safecall(o.Callback, val)
					if o.Flag then Celestial.Flags[o.Flag] = val end
				end
			end)

			self._window:_onThemeChange(function(newTheme)
				field.BackgroundColor3 = newTheme.SurfaceDeep
				local s = field:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeDark end
				box.TextColor3 = newTheme.TextPrimary
				box.PlaceholderColor3 = newTheme.TextMuted
			end)
		end

		--------------------------------------------------------------------
		-- Dropdown (fixes #1, #3, #4, #7: overlay parent + tracking + theme refresh + click-outside)
		--------------------------------------------------------------------
		function Tab:CreateDropdown(o: {
			Name:     string,
			Options:  { string },
			Default:  string?,
			Multi:    boolean?,
			Flag:     string?,
			Callback: (string | { string }) -> (),
		}): { Set: (string) -> (), Refresh: ({ string }) -> () }
			local selected = o.Default or (o.Options[1] or "")
			local open     = false
			local multi    = o.Multi or false
			local multiSel: { [string]: boolean } = {}

			local container = make("Frame", {
				Name                  = "Dropdown",
				Size                  = UDim2.new(1, 0, 0, 48),
				BackgroundColor3      = theme.Surface,
				BackgroundTransparency= theme.SurfaceDeepTrans,
				ClipsDescendants      = false,
				ZIndex                = 10,
				LayoutOrder           = nextOrder(),
			}, frame)
			corner(10, container)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, container)

			make("TextLabel", {
				Position              = UDim2.new(0, 14, 0, 0),
				Size                  = UDim2.new(0, 110, 1, 0),
				BackgroundTransparency= 1,
				Text                  = o.Name,
				TextColor3            = theme.TextPrimary,
				Font                  = Enum.Font.Gotham,
				TextSize              = 13,
				TextXAlignment        = Enum.TextXAlignment.Left,
				ZIndex                = 11,
			}, container)

			local selBtn = make("TextButton", {
				Position              = UDim2.new(0, 128, 0.5, -14),
				Size                  = UDim2.new(1, -140, 0, 28),
				BackgroundColor3      = theme.SurfaceDeep,
				BackgroundTransparency= theme.SurfaceDeepTrans,
				Text                  = selected,
				TextColor3            = theme.TextSecondary,
				Font                  = Enum.Font.Gotham,
				TextSize              = 12,
				AutoButtonColor       = false,
				ZIndex                = 11,
			}, container) :: TextButton
			corner(7, selBtn)
			stroke(theme.StrokeDark, 1, theme.StrokeDarkTrans, selBtn)
			pad(10, 24, 0, 0, selBtn)

			local chev = make("TextLabel", {
				Position              = UDim2.new(1, -20, 0.5, -7),
				Size                  = UDim2.new(0, 14, 0, 14),
				BackgroundTransparency= 1,
				Text                  = "▾",
				TextColor3            = theme.TextMuted,
				Font                  = Enum.Font.GothamBold,
				TextSize              = 11,
				ZIndex                = 12,
			}, selBtn)

			-- Panel parented to overlay
			local panel = make("Frame", {
				BackgroundColor3      = theme.Surface,
				BackgroundTransparency= 0.04,
				ClipsDescendants      = true,
				Visible               = false,
				ZIndex                = 250,
			}, self._window._overlay)
			corner(8, panel)
			stroke(theme.StrokeLight, 1, 0.6, panel)
			listLayout(Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, 2, panel)
			pad(4, 4, 4, 4, panel)

			-- Popup tracking for click-outside and window drag/scroll
			local popupEntry = {
				_isOpen = false,
				_container = panel,
				_clickOutside = nil,
			}
			table.insert(self._window._openPopups, popupEntry)

			local function positionPanel()
				local absPos = selBtn.AbsolutePosition
				local absSize = selBtn.AbsoluteSize
				panel.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
				panel.Size = UDim2.new(0, absSize.X, 0, 0)
			end

			-- Track window drag and scrolling frame canvas position
			local trackConn1, trackConn2
			local function startTracking()
				if trackConn1 then trackConn1:Disconnect() end
				if trackConn2 then trackConn2:Disconnect() end
				local lastWinPos = self._window._win.Position
				local lastCanvas = self._frame.CanvasPosition
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

			local function buildItems(opts_: { string })
				local currentTheme = self._window._theme
				for _, c in panel:GetChildren() do
					if c:IsA("TextButton") then c:Destroy() end
				end
				for idx, opt in opts_ do
					local isActive = multi and multiSel[opt] or (not multi and opt == selected)
					local item = make("TextButton", {
						Size                  = UDim2.new(1, 0, 0, 30),
						BackgroundColor3      = if isActive then currentTheme.Accent else currentTheme.Surface,
						BackgroundTransparency= if isActive then 0.15 else 0.95,
						Text                  = opt,
						TextColor3            = if isActive then currentTheme.AccentText else currentTheme.TextSecondary,
						Font                  = if isActive then Enum.Font.GothamBold else Enum.Font.Gotham,
						TextSize              = 12,
						AutoButtonColor       = false,
						TextXAlignment        = Enum.TextXAlignment.Left,
						ZIndex                = 251,
						LayoutOrder           = idx,
					}, panel)
					corner(6, item)
					pad(10, 0, 0, 0, item)

					item.MouseEnter:Connect(function()
						if not isActive then
							tw(item, T_FAST, { BackgroundTransparency = 0.80 }):Play()
						end
					end)
					item.MouseLeave:Connect(function()
						if not isActive then
							tw(item, T_FAST, { BackgroundTransparency = 0.95 }):Play()
						end
					end)

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
				local totalH = #opts_ * 34 + 8
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
					tw(panel, T_MED, { Size = UDim2.new(0, panel.Size.X.Offset, 0, #o.Options * 34 + 8) }):Play()
					tw(chev,  T_MED, { Rotation = 180 }):Play()
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
				panel.BackgroundColor3 = newTheme.Surface
				local s3 = panel:FindFirstChildWhichIsA("UIStroke")
				if s3 then s3.Color = newTheme.StrokeLight end
				-- Rebuild items with new theme colors
				if open then
					buildItems(o.Options)
				end
			end)

			return {
				Set = function(val)
					selected = val
					selBtn.Text = val
					safecall(o.Callback, val)
					if o.Flag then Celestial.Flags[o.Flag] = val end
				end,
				Refresh = function(newOpts)
					o.Options = newOpts
					if open then
						positionPanel()
						buildItems(newOpts)
					end
				end,
			}
		end

		--------------------------------------------------------------------
		-- ColorPicker (fixes #1, #5, #7: overlay + theme + click-outside)
		--------------------------------------------------------------------
		function Tab:CreateColorPicker(o: {
			Name:     string,
			Default:  Color3?,
			Flag:     string?,
			Callback: (Color3) -> (),
		}): { Set: (Color3) -> () }
			local color = o.Default or Color3.fromRGB(255, 255, 255)
			local row   = glassRow(48)

			make("TextLabel", {
				Position              = UDim2.new(0, 14, 0, 0),
				Size                  = UDim2.new(1, -90, 1, 0),
				BackgroundTransparency= 1,
				Text                  = o.Name,
				TextColor3            = theme.TextPrimary,
				Font                  = Enum.Font.Gotham,
				TextSize              = 13,
				TextXAlignment        = Enum.TextXAlignment.Left,
			}, row)

			local preview = make("TextButton", {
				Size                  = UDim2.new(0, 36, 0, 24),
				Position              = UDim2.new(1, -48, 0.5, -12),
				BackgroundColor3      = color,
				Text                  = "",
				AutoButtonColor       = false,
				ZIndex                = 5,
			}, row)
			corner(6, preview)
			stroke(theme.StrokeLight, 1, theme.StrokeLightTrans, preview)

			local pickerOpen = false
			local picker     = nil

			-- Popup tracking
			local popupEntry = {
				_isOpen = false,
				_container = nil,
				_clickOutside = nil,
			}
			table.insert(self._window._openPopups, popupEntry)

			local function closePicker()
				if not pickerOpen then return end
				pickerOpen = false
				popupEntry._isOpen = false
				if picker then
					tw(picker, T_FAST, { Size = UDim2.new(0, 200, 0, 0) }):Play()
					task.delay(0.2, function()
						if picker then picker:Destroy() picker = nil end
					end)
				end
			end

			popupEntry._clickOutside = closePicker

			preview.MouseButton1Click:Connect(function()
				pickerOpen = not pickerOpen
				if picker then
					picker:Destroy()
					picker = nil
				end
				if not pickerOpen then
					popupEntry._isOpen = false
					return
				end

				local absPos = preview.AbsolutePosition
				local absSize = preview.AbsoluteSize

				picker = make("Frame", {
					Size                  = UDim2.new(0, 200, 0, 140),
					Position              = UDim2.new(0, absPos.X - 164, 0, absPos.Y + absSize.Y + 4),
					BackgroundColor3      = theme.Surface,
					BackgroundTransparency= 0.04,
					ZIndex                = 250,
					ClipsDescendants      = false,
				}, self._window._overlay)
				corner(10, picker)
				stroke(theme.StrokeLight, 1, 0.6, picker)

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
					make("TextLabel", {
						Position = UDim2.new(0, 10, 0, yPos), Size = UDim2.new(1, -20, 0, 14),
						BackgroundTransparency = 1, Text = labelText,
						TextColor3 = theme.TextSecondary, Font = Enum.Font.Gotham, TextSize = 11,
						TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 251,
					}, picker)

					local track = make("Frame", {
						Position = UDim2.new(0, 10, 0, yPos + 16), Size = UDim2.new(1, -20, 0, 10),
						BackgroundColor3 = Color3.fromRGB(200, 200, 200), ZIndex = 251,
					}, picker)
					corner(5, track)

					make("UIGradient", { Color = gradientSeq }, track)

					local thumb = make("Frame", {
						Size = UDim2.new(0, 10, 0, 10),
						Position = UDim2.new(initialVal, -5, 0.5, -5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						ZIndex = 252,
					}, track)
					corner(5, thumb)

					local dragging = false
					track.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 
						   or i.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							local val = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
							thumb.Position = UDim2.new(val, -5, 0.5, -5)
							callback(val)
						end
					end)
					UIS.InputChanged:Connect(function(i)
						if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement 
						                 or i.UserInputType == Enum.UserInputType.Touch) then
							local val = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
							thumb.Position = UDim2.new(val, -5, 0.5, -5)
							callback(val)
						end
					end)
					UIS.InputEnded:Connect(function(i)
						if (i.UserInputType == Enum.UserInputType.MouseButton1 
						    or i.UserInputType == Enum.UserInputType.Touch) then
							dragging = false
						end
					end)

					return track, thumb
				end

				makeSlider("Hue", 10, ColorSequence.new({
					ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 0,   0)),
					ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,   255, 0)),
					ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,   255, 255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,   0,   255)),
					ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0,   255)),
					ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0,   0)),
				}), h, function(val) h = val; applyHSV() end)

				makeSlider("Saturation", 46, ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromHSV(h,1,1)), s, function(val) s = val; applyHSV() end)

				makeSlider("Brightness", 82, ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255)), v, function(val) v = val; applyHSV() end)
			end)

			if o.Flag then Celestial.Flags[o.Flag] = color end

			self._window:_onThemeChange(function(newTheme)
				local s = preview:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.StrokeLight end
				if picker and picker.Parent then
					picker.BackgroundColor3 = newTheme.Surface
					local s2 = picker:FindFirstChildWhichIsA("UIStroke")
					if s2 then s2.Color = newTheme.StrokeLight end
					-- Update labels inside picker
					for _, child in ipairs(picker:GetChildren()) do
						if child:IsA("TextLabel") then
							child.TextColor3 = newTheme.TextSecondary
						end
					end
				end
			end)

			return {
				Set = function(c)
					color = c
					preview.BackgroundColor3 = c
					safecall(o.Callback, c)
					if o.Flag then Celestial.Flags[o.Flag] = c end
				end,
			}
		end

		--------------------------------------------------------------------
		-- Keybind picker (fix #8: clearer touch UX)
		--------------------------------------------------------------------
		function Tab:CreateKeybind(o: {
			Name:     string,
			Default:  Enum.KeyCode?,
			Flag:     string?,
			Callback: (Enum.KeyCode) -> (),
		}): { Set: (Enum.KeyCode) -> () }
			local key      = o.Default or Enum.KeyCode.Unknown
			local binding  = false
			local row      = glassRow(48)

			make("TextLabel", {
				Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -110, 1, 0),
				BackgroundTransparency = 1, Text = o.Name,
				TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)

			local keyBtn = make("TextButton", {
				Size = UDim2.new(0, 80, 0, 26),
				Position = UDim2.new(1, -90, 0.5, -13),
				BackgroundColor3 = theme.SurfaceDeep,
				BackgroundTransparency = theme.SurfaceDeepTrans,
				Text = key.Name,
				TextColor3 = theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				AutoButtonColor = false,
				ZIndex = 5,
			}, row) :: TextButton
			corner(7, keyBtn)
			stroke(theme.Accent, 1, 0.5, keyBtn)

			local function cancelBind()
				binding = false
				keyBtn.Text = key.Name
				tw(keyBtn, T_FAST, { BackgroundTransparency = theme.SurfaceDeepTrans }):Play()
			end

			keyBtn.MouseButton1Click:Connect(function()
				if binding then
					cancelBind()
					return
				end
				binding = true
				keyBtn.Text = "Press a key..."
				tw(keyBtn, T_FAST, { BackgroundTransparency = 0.5 }):Play()
			end)

			UIS.InputBegan:Connect(function(i, gpe)
				if not binding or gpe then return end
				if i.UserInputType == Enum.UserInputType.Keyboard then
					key = i.KeyCode
					cancelBind()
					safecall(o.Callback, key)
					if o.Flag then Celestial.Flags[o.Flag] = key end
				elseif i.UserInputType == Enum.UserInputType.Gamepad1 then
					key = i.KeyCode
					cancelBind()
					safecall(o.Callback, key)
					if o.Flag then Celestial.Flags[o.Flag] = key end
				elseif i.UserInputType == Enum.UserInputType.Touch then
					-- Touch tap cancels binding
					cancelBind()
				end
			end)

			if o.Flag then Celestial.Flags[o.Flag] = key end

			self._window:_onThemeChange(function(newTheme)
				keyBtn.TextColor3 = newTheme.Accent
				local s = keyBtn:FindFirstChildWhichIsA("UIStroke")
				if s then s.Color = newTheme.Accent end
			end)

			return {
				Set = function(k)
					key = k
					keyBtn.Text = k.Name
					safecall(o.Callback, k)
					if o.Flag then Celestial.Flags[o.Flag] = k end
				end,
			}
		end

		table.insert(self._tabs, Tab)
		return Tab
	end -- CreateTab

	table.insert(self.Windows, Window)
	return Window
end -- CreateWindow

------------------------------------------------------------------------
-- SetTheme  (live swap with tweening)
------------------------------------------------------------------------
function Celestial:SetTheme(name: string)
	local oldTheme = self.ActiveTheme
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
				if bar then
					tw(bar, T_MED, { BackgroundColor3 = t.Accent, BackgroundTransparency = 0 }):Play()
				end
				if lbl then
					tw(lbl, T_MED, { TextColor3 = t.TextPrimary }):Play()
				end
			end
		end
	end
end

------------------------------------------------------------------------
-- Destroy all windows
------------------------------------------------------------------------
function Celestial:Destroy()
	for _, win in self.Windows do
		if win._screen then
			safecall(function() win._screen:Destroy() end)
		end
	end
	self.Windows = {}
end

return Celestial
