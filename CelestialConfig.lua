local Config = {}

------------------------------------------------------------------------
-- Services (cached with cloneref support for executors)
------------------------------------------------------------------------
local function getService(name)
	local s = game:GetService(name)
	return if cloneref then cloneref(s) else s
end

Config.Services = {
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
	Smooth = TweenInfo.new(0.20, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	Snap   = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

Config.T_FAST    = Config.Tweens.Fast
Config.T_MED     = Config.Tweens.Med
Config.T_SLOW    = Config.Tweens.Slow
Config.T_SPRING  = Config.Tweens.Spring
Config.T_LINEAR  = Config.Tweens.Linear
Config.T_BOUNCE  = Config.Tweens.Bounce
Config.T_ELASTIC = Config.Tweens.Elastic
Config.T_SMOOTH  = Config.Tweens.Smooth
Config.T_SNAP    = Config.Tweens.Snap

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
-- Player Tracking System (Enhanced)
------------------------------------------------------------------------
Config.Players = {}
Config.PlayerConnections = {}

function Config.TrackPlayer(player)
	if Config.Players[player.UserId] then return end

	local data = {
		UserId = player.UserId,
		Name = player.Name,
		DisplayName = player.DisplayName,
		AccountAge = player.AccountAge,
		MembershipType = tostring(player.MembershipType),
		Team = nil,
		Character = nil,
		RootPart = nil,
		Humanoid = nil,
		Position = Vector3.new(0, 0, 0),
		LastPosition = Vector3.new(0, 0, 0),
		Velocity = Vector3.new(0, 0, 0),
		Speed = 0,
		Health = 100,
		MaxHealth = 100,
		LastHealth = 100,
		HealthHistory = {},
		PositionHistory = {},
		IsAlive = false,
		IsLoaded = false,
		LastSeen = tick(),
		JoinedAt = tick(),
		DeathCount = 0,
	}

	Config.Players[player.UserId] = data

	local function updateCharacter(character)
		if not character then
			data.Character = nil
			data.RootPart = nil
			data.Humanoid = nil
			data.IsAlive = false
			return
		end

		data.Character = character

		local humanoid = character:WaitForChild("Humanoid", 5)
		local rootPart = character:WaitForChild("HumanoidRootPart", 5)

		if humanoid and rootPart then
			data.Humanoid = humanoid
			data.RootPart = rootPart
			data.MaxHealth = humanoid.MaxHealth
			data.IsLoaded = true

			local conn = Config.RUN.Heartbeat:Connect(function()
				if not character.Parent or not rootPart.Parent then return end

				data.LastPosition = data.Position
				data.Position = rootPart.Position
				data.Velocity = rootPart.Velocity
				data.Speed = rootPart.Velocity.Magnitude
				data.LastHealth = data.Health
				data.Health = humanoid.Health
				data.IsAlive = humanoid.Health > 0
				data.Team = player.Team and player.Team.Name or nil
				data.LastSeen = tick()

				table.insert(data.HealthHistory, {
					Time = tick(),
					Health = data.Health,
					Change = data.Health - data.LastHealth,
				})

				if #data.HealthHistory > 100 then
					table.remove(data.HealthHistory, 1)
				end

				table.insert(data.PositionHistory, {
					Time = tick(),
					Position = data.Position,
				})

				if #data.PositionHistory > 60 then
					table.remove(data.PositionHistory, 1)
				end
			end)

			table.insert(Config.PlayerConnections, conn)

			humanoid.Died:Connect(function()
				data.IsAlive = false
				data.LastHealth = data.Health
				data.Health = 0
				data.DeathCount = data.DeathCount + 1
			end)
		end
	end

	if player.Character then
		updateCharacter(player.Character)
	end

	player.CharacterAdded:Connect(updateCharacter)
	player.CharacterRemoving:Connect(function()
		data.IsAlive = false
		data.Character = nil
		data.RootPart = nil
		data.Humanoid = nil
	end)
end

function Config.GetPlayer(userId)
	return Config.Players[userId]
end

function Config.GetPlayerPosition(userId)
	local data = Config.Players[userId]
	return data and data.Position or nil
end

function Config.GetPlayerLastPosition(userId)
	local data = Config.Players[userId]
	return data and data.LastPosition or nil
end

function Config.GetPlayerRootPart(userId)
	local data = Config.Players[userId]
	return data and data.RootPart or nil
end

function Config.GetPlayerHealth(userId)
	local data = Config.Players[userId]
	return data and data.Health or nil
end

function Config.GetPlayerHealthHistory(userId)
	local data = Config.Players[userId]
	return data and data.HealthHistory or nil
end

function Config.GetPlayerPositionHistory(userId)
	local data = Config.Players[userId]
	return data and data.PositionHistory or nil
end

function Config.GetPlayerDistance(userId1, userId2)
	local p1 = Config.GetPlayerPosition(userId1)
	local p2 = Config.GetPlayerPosition(userId2)
	if p1 and p2 then
		return (p1 - p2).Magnitude
	end
	return nil
end

function Config.GetClosestPlayer(userId)
	local myPos = Config.GetPlayerPosition(userId)
	if not myPos then return nil end

	local closest = nil
	local closestDist = math.huge

	for uid, data in pairs(Config.Players) do
		if uid ~= userId and data.IsAlive and data.RootPart then
			local dist = (myPos - data.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closest = data
			end
		end
	end

	return closest, closestDist
end

function Config.GetAlivePlayers()
	local alive = {}
	for userId, data in pairs(Config.Players) do
		if data.IsAlive then
			table.insert(alive, data)
		end
	end
	return alive
end

function Config.GetAllPlayers()
	return Config.Players
end

function Config.InitPlayerTracking()
	for _, player in ipairs(Config.PS:GetPlayers()) do
		Config.TrackPlayer(player)
	end

	Config.PS.PlayerAdded:Connect(Config.TrackPlayer)

	Config.PS.PlayerRemoving:Connect(function(player)
		Config.Players[player.UserId] = nil
	end)
end

------------------------------------------------------------------------
-- Input System
------------------------------------------------------------------------
Config.Input = {
	Mouse = Config.PS.LocalPlayer and Config.PS.LocalPlayer:GetMouse(),
	Keys = {},
	MousePosition = Vector2.new(0, 0),
}

function Config.Input:IsKeyDown(key)
	return self.Keys[key] == true
end

function Config.Input:GetMousePos()
	return self.MousePosition
end

if Config.PS.LocalPlayer then
	local mouse = Config.PS.LocalPlayer:GetMouse()
	Config.Input.Mouse = mouse

	mouse.Move:Connect(function()
		Config.Input.MousePosition = Vector2.new(mouse.X, mouse.Y)
	end)

	Config.RUN.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			Config.Input.Keys[input.KeyCode] = true
		end
	end)

	Config.RUN.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			Config.Input.Keys[input.KeyCode] = false
		end
	end)
end

------------------------------------------------------------------------
-- Camera System
------------------------------------------------------------------------
Config.Camera = {
	Instance = workspace.CurrentCamera,
}

function Config.Camera:GetPosition()
	return self.Instance.CFrame.Position
end

function Config.Camera:GetLookVector()
	return self.Instance.CFrame.LookVector
end

function Config.Camera:GetCFrame()
	return self.Instance.CFrame
end

function Config.Camera:WorldToScreen(pos)
	local screenPos, onScreen = self.Instance:WorldToScreenPoint(pos)
	return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

function Config.Camera:WorldToViewport(pos)
	local screenPos, onScreen = self.Instance:WorldToViewportPoint(pos)
	return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Config.Camera.Instance = workspace.CurrentCamera
end)

------------------------------------------------------------------------
-- Raycasting
------------------------------------------------------------------------
function Config.Raycast(origin, direction, params)
	return workspace:Raycast(origin, direction, params)
end

function Config.RaycastToPlayer(targetUserId, maxDist)
	local localPlayer = Config.PS.LocalPlayer
	if not localPlayer or not localPlayer.Character then return false end

	local myRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetData = Config.Players[targetUserId]
	if not myRoot or not targetData or not targetData.RootPart then return false end

	local origin = myRoot.Position
	local targetPos = targetData.RootPart.Position
	local direction = (targetPos - origin).Unit * (maxDist or 500)

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {localPlayer.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(origin, direction, params)
	if result then
		local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
		if hitModel and hitModel == targetData.Character then
			return true, result
		end
	end

	return false, nil
end

------------------------------------------------------------------------
-- ESP / Visual Helpers
------------------------------------------------------------------------
Config.ESP = {
	Objects = {},
}

function Config.ESP:AddBox(player, color)
	if not player or not player.Character then return end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local box = Drawing.new("Square")
	box.Visible = false
	box.Thickness = 1
	box.Color = color or Color3.new(1, 1, 1)
	box.Filled = false
	box.Transparency = 1

	Config.ESP.Objects[player.UserId] = {
		Box = box,
		Player = player,
	}

	return box
end

function Config.ESP:Remove(userId)
	local obj = Config.ESP.Objects[userId]
	if obj then
		obj.Box:Remove()
		Config.ESP.Objects[userId] = nil
	end
end

function Config.ESP:Update()
	for userId, obj in pairs(Config.ESP.Objects) do
		local data = Config.Players[userId]
		if data and data.RootPart and data.IsAlive then
			local pos, onScreen = Config.Camera:WorldToViewport(data.RootPart.Position)
			if onScreen then
				obj.Box.Visible = true
				obj.Box.Position = pos - Vector2.new(50, 50)
				obj.Box.Size = Vector2.new(100, 100)
			else
				obj.Box.Visible = false
			end
		else
			obj.Box.Visible = false
		end
	end
end

------------------------------------------------------------------------
-- Notification System
------------------------------------------------------------------------
Config.Notifications = {}

function Config.Notify(title, text, duration)
	duration = duration or 3

	if Config.NS then
		Config.SafeCall(function()
			Config.NS:SendNotification(title, text, "", duration)
		end)
	end

	table.insert(Config.Notifications, {
		Title = title,
		Text = text,
		Time = tick(),
		Duration = duration,
	})
end

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
Config.VERSION     = "2.0.0"
Config.NAME        = "Celestial"
Config.FOLDER_ROOT = "Celestial"
Config.FOLDER_CFG  = Config.FOLDER_ROOT .. "/Configs"
Config.CFG_EXT     = ".cltl"
Config.IS_STUDIO   = Config.RUN:IsStudio()

------------------------------------------------------------------------
-- Theme Placeholder
------------------------------------------------------------------------
Config.ActiveTheme = nil

------------------------------------------------------------------------
-- Auto-Initialize
------------------------------------------------------------------------
Config.InitPlayerTracking()

return Config
