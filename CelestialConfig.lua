-- CelestialConfig.lua
-- Central service aliasing and constants for Celestial UI Suite
-- Host this on GitHub raw alongside Celestial.lua

local Config = {}

------------------------------------------------------------------------
-- Services (cached with cloneref support for executors)
------------------------------------------------------------------------
local function getService(name)
	local s = game:GetService(name)
	return if cloneref then cloneref(s) else s
end

Config.Services = {
	TweenService       = getService("TweenService"),
	UserInputService   = getService("UserInputService"),
	Players            = getService("Players"),
	CoreGui            = getService("CoreGui"),
	HttpService        = getService("HttpService"),
	RunService         = getService("RunService"),
	TextService        = getService("TextService"),
	StarterGui         = getService("StarterGui"),
	ReplicatedStorage  = getService("ReplicatedStorage"),
	Lighting           = getService("Lighting"),
	Workspace          = getService("Workspace"),
}

-- Short aliases
Config.TS  = Config.Services.TweenService
Config.UIS = Config.Services.UserInputService
Config.RS  = Config.Services.RunService
Config.PS  = Config.Services.Players
Config.CG  = Config.Services.CoreGui
Config.HS  = Config.Services.HttpService
Config.TXS = Config.Services.TextService

------------------------------------------------------------------------
-- Yield / Timing
------------------------------------------------------------------------
Config.Yield   = task.wait
Config.Defer   = task.defer
Config.Spawn   = task.spawn
Config.Delay   = task.delay

------------------------------------------------------------------------
-- Tween Presets
------------------------------------------------------------------------
Config.TI = TweenInfo

Config.Tweens = {
	Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Med    = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Slow   = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Spring = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
	Linear = TweenInfo.new(0.30, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
}

Config.T_FAST   = Config.Tweens.Fast
Config.T_MED    = Config.Tweens.Med
Config.T_SLOW   = Config.Tweens.Slow
Config.T_SPRING = Config.Tweens.Spring
Config.T_LINEAR = Config.Tweens.Linear

------------------------------------------------------------------------
-- Utility Functions
------------------------------------------------------------------------
function Config.SafeCall(fn, ...)
	if not fn then return nil end
	local ok, r = pcall(fn, ...)
	if not ok then warn("[Celestial] " .. tostring(r)) end
	return ok and r or nil
end

function Config.Tween(inst, info, goals)
	return Config.TS:Create(inst, info, goals)
end

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
Config.VERSION     = "1.0.0"
Config.NAME        = "Celestial"
Config.FOLDER_ROOT = "Celestial"
Config.FOLDER_CFG  = Config.FOLDER_ROOT .. "/Configs"
Config.CFG_EXT     = ".cltl"
Config.IS_STUDIO   = Config.RS:IsStudio()

------------------------------------------------------------------------
-- Theme Placeholder (populated by main library)
------------------------------------------------------------------------
Config.ActiveTheme = nil

return Config
