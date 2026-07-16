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
	-- Core Services
	AdService                  = getService("AdService"),
	AnalyticsService           = getService("AnalyticsService"),
	AssetService               = getService("AssetService"),
	BadgeService               = getService("BadgeService"),
	ChangeHistoryService       = getService("ChangeHistoryService"),
	Chat                       = getService("Chat"),
	CollectionService          = getService("CollectionService"),
	ContentProvider            = getService("ContentProvider"),
	ContextActionService       = getService("ContextActionService"),
	CookiesService             = getService("CookiesService"),
	CoreGui                    = getService("CoreGui"),
	Debris                     = getService("Debris"),
	DebuggerManager            = getService("DebuggerManager"),
	DraftsService              = getService("DraftsService"),
	DraggerService             = getService("DraggerService"),
	FilteredSelection          = getService("FilteredSelection"),
	FriendService              = getService("FriendService"),
	GamePassService            = getService("GamePassService"),
	GamepadService             = getService("GamepadService"),
	Geometry                   = getService("Geometry"),
	GroupService               = getService("GroupService"),
	GuiService                 = getService("GuiService"),
	HSRDataContentProvider     = getService("HSRDataContentProvider"),
	HapticService              = getService("HapticService"),
	HttpRbxApiService          = getService("HttpRbxApiService"),
	HttpService                = getService("HttpService"),
	InsertService              = getService("InsertService"),
	JointsService              = getService("JointsService"),
	LanguageService            = getService("LanguageService"),
	Lighting                   = getService("Lighting"),
	LocalizationService        = getService("LocalizationService"),
	LogService                 = getService("LogService"),
	MarketplaceService         = getService("MarketplaceService"),
	MemStorageService          = getService("MemStorageService"),
	MeshContentProvider        = getService("MeshContentProvider"),
	NotificationService        = getService("NotificationService"),
	PermissionsService         = getService("PermissionsService"),
	PhysicsService             = getService("PhysicsService"),
	Players                    = getService("Players"),
	PluginDebugService         = getService("PluginDebugService"),
	PluginGuiService           = getService("PluginGuiService"),
	PointsService              = getService("PointsService"),
	PolicyService              = getService("PolicyService"),
	ProcessInstancePhysicsService = getService("ProcessInstancePhysicsService"),
	ReplicatedFirst            = getService("ReplicatedFirst"),
	ReplicatedStorage          = getService("ReplicatedStorage"),
	RunService                 = getService("RunService"),
	ScriptContext              = getService("ScriptContext"),
	Selection                  = getService("Selection"),
	ServerScriptService        = getService("ServerScriptService"),
	ServerStorage              = getService("ServerStorage"),
	SolidModelContentProvider  = getService("SolidModelContentProvider"),
	SoundService               = getService("SoundService"),
	StarterGui                 = getService("StarterGui"),
	StarterPack                = getService("StarterPack"),
	StarterPlayer              = getService("StarterPlayer"),
	Stats                      = getService("Stats"),
	StudioService              = getService("StudioService"),
	Teams                      = getService("Teams"),
	TeleportService            = getService("TeleportService"),
	TestService                = getService("TestService"),
	TextService                = getService("TextService"),
	TouchInputService          = getService("TouchInputService"),
	TweenService               = getService("TweenService"),
	VRService                  = getService("VRService"),
	VirtualInputManager        = getService("VirtualInputManager"),
	Visit                      = getService("Visit"),
	Workspace                  = getService("Workspace"),
}

-- Short aliases (2-3 letter codes for frequently used services)
Config.ADS  = Config.Services.AdService
Config.AN   = Config.Services.AnalyticsService
Config.AS   = Config.Services.AssetService
Config.BS   = Config.Services.BadgeService
Config.CH   = Config.Services.ChangeHistoryService
Config.CS   = Config.Services.CollectionService
Config.CP   = Config.Services.ContentProvider
Config.CAS  = Config.Services.ContextActionService
Config.COOK = Config.Services.CookiesService
Config.CG   = Config.Services.CoreGui
Config.DB   = Config.Services.Debris
Config.DM   = Config.Services.DebuggerManager
Config.DS   = Config.Services.DraftsService
Config.DR   = Config.Services.DraggerService
Config.FS   = Config.Services.FilteredSelection
Config.FR   = Config.Services.FriendService
Config.GPS  = Config.Services.GamePassService
Config.GPSV = Config.Services.GamepadService
Config.GEO  = Config.Services.Geometry
Config.GS   = Config.Services.GroupService
Config.GUI  = Config.Services.GuiService
Config.HSR  = Config.Services.HSRDataContentProvider
Config.HAP  = Config.Services.HapticService
Config.HRA  = Config.Services.HttpRbxApiService
Config.HS   = Config.Services.HttpService
Config.IS   = Config.Services.InsertService
Config.JS   = Config.Services.JointsService
Config.LANG = Config.Services.LanguageService
Config.LG   = Config.Services.Lighting
Config.LOC  = Config.Services.LocalizationService
Config.LOG  = Config.Services.LogService
Config.MS   = Config.Services.MarketplaceService
Config.MEM  = Config.Services.MemStorageService
Config.MESH = Config.Services.MeshContentProvider
Config.NS   = Config.Services.NotificationService
Config.PERM = Config.Services.PermissionsService
Config.PHYS = Config.Services.PhysicsService
Config.PS   = Config.Services.Players
Config.PDS  = Config.Services.PluginDebugService
Config.PGS  = Config.Services.PluginGuiService
Config.PTS  = Config.Services.PointsService
Config.POL  = Config.Services.PolicyService
Config.PIP  = Config.Services.ProcessInstancePhysicsService
Config.RF   = Config.Services.ReplicatedFirst
Config.RS   = Config.Services.ReplicatedStorage
Config.RUN  = Config.Services.RunService
Config.SC   = Config.Services.ScriptContext
Config.SEL  = Config.Services.Selection
Config.SSS  = Config.Services.ServerScriptService
Config.SS   = Config.Services.ServerStorage
Config.SM   = Config.Services.SolidModelContentProvider
Config.SND  = Config.Services.SoundService
Config.SG   = Config.Services.StarterGui
Config.SP   = Config.Services.StarterPack
Config.SPL  = Config.Services.StarterPlayer
Config.ST   = Config.Services.Stats
Config.STU  = Config.Services.StudioService
Config.TM   = Config.Services.Teams
Config.TP   = Config.Services.TeleportService
Config.TST  = Config.Services.TestService
Config.TXS  = Config.Services.TextService
Config.TIS  = Config.Services.TouchInputService
Config.TS   = Config.Services.TweenService
Config.VR   = Config.Services.VRService
Config.VIM  = Config.Services.VirtualInputManager
Config.VS   = Config.Services.Visit
Config.WS   = Config.Services.Workspace

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
	Bounce = TweenInfo.new(0.50, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
	Elastic = TweenInfo.new(0.50, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

Config.T_FAST    = Config.Tweens.Fast
Config.T_MED     = Config.Tweens.Med
Config.T_SLOW    = Config.Tweens.Slow
Config.T_SPRING  = Config.Tweens.Spring
Config.T_LINEAR  = Config.Tweens.Linear
Config.T_BOUNCE  = Config.Tweens.Bounce
Config.T_ELASTIC = Config.Tweens.Elastic

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

function Config.Folder(path)
	if isfolder and not Config.SafeCall(isfolder, path) then
		Config.SafeCall(makefolder, path)
	end
end

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
Config.VERSION     = "1.0.0"
Config.NAME        = "Celestial"
Config.FOLDER_ROOT = "Celestial"
Config.FOLDER_CFG  = Config.FOLDER_ROOT .. "/Configs"
Config.CFG_EXT     = ".cltl"
Config.IS_STUDIO   = Config.RUN:IsStudio()

------------------------------------------------------------------------
-- Theme Placeholder (populated by main library)
------------------------------------------------------------------------
Config.ActiveTheme = nil

return Config
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
