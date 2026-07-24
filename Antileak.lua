--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                     ANTI-MEMORY LEAK MODULE v5.0                             ║
    ║                    For Roblox - Legit & Unlegit Environments                  ║
    ╚══════════════════════════════════════════════════════════════════════════════╝

    Minimal, correct memory leak prevention. No clever tricks.

    PRINCIPLES:
    • No weak tables (they cause GC races and iteration bugs)
    • No metatable proxies (they break #, pairs, and create cycles)
    • No per-object task.delay (races, accumulation)
    • No polling loops (CPU burn, immortal threads)
    • Centralized heartbeat scanning (single point of truth)
    • Every internal connection stored and disconnectable
    • Per-script instances via AntiLeak.new()

    API:
        local tracker = AntiLeak.new()
        tracker:Init({DebugMode = true})

        -- Connections (auto-tracked, returned as disconnectable objects)
        local conn = tracker:Connect(workspace.ChildAdded, function(child) end)
        conn:Disconnect()  -- or tracker:Disconnect(conn)

        -- One-shot connections
        tracker:Once(signal, callback)

        -- Instances (orphan detection + optional auto-cleanup)
        tracker:TrackInstance(part)
        tracker:DestroyInstance(part)  -- safe destroy

        -- Threads (spawned, not tracked individually — use :IsAlive() in loops)
        tracker:Spawn(function()
            while tracker:IsAlive() do
                task.wait(1)
            end
        end)

        -- Tables (tracked wrapper with explicit API)
        local t = tracker:TrackTable({})
        t:Set("key", "value")
        local v = t:Get("key")
        local n = t:Length()
        for k, v in t:Pairs() do end

        -- Bulk cleanup
        tracker:Cleanup()
--]]

local AntiLeak = {}
AntiLeak.__index = AntiLeak

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Config
-- ═══════════════════════════════════════════════════════════════════════════════

local DEFAULT_CONFIG = {
    DebugMode = false,
    AutoCleanup = true,
    ScanInterval = 30,
    OrphanTimeout = 60,
    StaleConnectionTimeout = 300,
    AbandonedTableTimeout = 600,
    AlertThresholdMB = 100,
    MaxTracked = 5000,
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- Constructor
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak.new()
    return setmetatable({
        -- State
        Alive = false,
        Config = {},
        NextScan = 0,

        -- Connections we created (for cleanup)
        InternalConnections = {},

        -- User connections we track
        Connections = {},
        ConnCount = 0,

        -- User instances we track
        Instances = {},
        InstCount = 0,

        -- User tables we track
        Tables = {},
        TableCount = 0,

        -- Stats
        Stats = {
            LeaksDetected = 0,
            LeaksCleaned = 0,
            ConnectionsClosed = 0,
            InstancesDestroyed = 0,
            TablesCleared = 0,
            PeakMemoryMB = 0,
        },

        -- ID generation
        IdSeq = 0,
    }, AntiLeak)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Internal Helpers
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak:_Id()
    self.IdSeq += 1
    return self.IdSeq
end

function AntiLeak:_Dbg(...)
    if self.Config.DebugMode then
        print(string.format("[AntiLeak:%s]", tostring(self):sub(8, 15)), ...)
    end
end

function AntiLeak:_Warn(...)
    warn(string.format("[AntiLeak:%s]", tostring(self):sub(8, 15)), ...)
end

function AntiLeak:_Mem()
    return collectgarbage("count") / 1024
end

-- Store an internal connection so Cleanup() can disconnect it
function AntiLeak:_StoreInternal(conn)
    table.insert(self.InternalConnections, conn)
    return conn
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Lifecycle
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak:Init(config)
    if self.Alive then
        self:_Warn("Already initialized")
        return self
    end

    -- Validate and merge config
    for k, v in pairs(DEFAULT_CONFIG) do
        local userVal = config and config[k]
        if userVal ~= nil then
            -- Basic validation
            if type(userVal) == "number" and userVal < 0 then
                self:_Warn("Invalid config value for", k, ": must be >= 0, using default")
                self.Config[k] = v
            else
                self.Config[k] = userVal
            end
        else
            self.Config[k] = v
        end
    end

    self.Alive = true
    self.NextScan = os.clock() + self.Config.ScanInterval

    -- Centralized heartbeat scanner — single scan point
    self:_StoreInternal(RunService.Heartbeat:Connect(function()
        if not self.Alive then return end

        local now = os.clock()
        if now >= self.NextScan then
            self.NextScan = now + self.Config.ScanInterval
            self:_Scan()
        end
    end))

    -- Player cleanup
    self:_StoreInternal(Players.PlayerRemoving:Connect(function(player)
        if not self.Alive then return end
        self:_OnPlayerRemoved(player)
    end))

    self:_Dbg("Initialized")
    return self
end

function AntiLeak:IsAlive()
    return self.Alive
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Connection API
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak:Connect(signal, callback, metadata)
    if not self.Alive then
        self:_Warn("Connect called after Cleanup")
        return nil
    end

    local id = self:_Id()
    local conn = signal:Connect(callback)

    self.Connections[id] = {
        Id = id,
        Connection = conn,
        Signal = signal,
        Callback = callback,
        Created = tick(),
        LastFired = tick(),
        Fires = 0,
        Errors = 0,
        Meta = metadata or {},
    }
    self.ConnCount += 1

    self:_Dbg("Connected", id, tostring(signal))

    -- Return a lightweight disconnect handle
    return {
        Id = id,
        Disconnect = function()
            self:Disconnect(id)
        end,
    }
end

function AntiLeak:Once(signal, callback, metadata)
    if not self.Alive then
        self:_Warn("Once called after Cleanup")
        return nil
    end

    local id = self:_Id()
    local fired = false
    local conn = nil

    conn = signal:Connect(function(...)
        if fired then return end
        fired = true
        conn:Disconnect()

        -- Remove from tracking
        if self.Connections[id] then
            self.Connections[id] = nil
            self.ConnCount = math.max(0, self.ConnCount - 1)
            self.Stats.ConnectionsClosed += 1
        end

        local ok, err = pcall(callback, ...)
        if not ok then
            self:_Warn("Once callback error:", err)
        end
    end)

    self.Connections[id] = {
        Id = id,
        Connection = conn,
        Signal = signal,
        Created = tick(),
        LastFired = tick(),
        Fires = 0,
        IsOnce = true,
        Meta = metadata or {},
    }
    self.ConnCount += 1

    self:_Dbg("Connected (Once)", id)

    return {
        Id = id,
        Disconnect = function()
            self:Disconnect(id)
        end,
    }
end

function AntiLeak:Disconnect(handleOrId)
    local id = typeof(handleOrId) == "table" and handleOrId.Id or handleOrId
    local info = self.Connections[id]
    if not info then return end

    if info.Connection then
        info.Connection:Disconnect()
    end

    self.Connections[id] = nil
    self.ConnCount = math.max(0, self.ConnCount - 1)
    self.Stats.ConnectionsClosed += 1

    self:_Dbg("Disconnected", id)
end

function AntiLeak:DisconnectAll(signal)
    local toRemove = {}
    for id, info in pairs(self.Connections) do
        if info.Signal == signal then
            table.insert(toRemove, id)
        end
    end
    for _, id in ipairs(toRemove) do
        self:Disconnect(id)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Thread API
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak:Spawn(func, ...)
    if not self.Alive then
        self:_Warn("Spawn called after Cleanup")
        return nil
    end

    local args = {...}
    local n = select("#", ...)

    -- Just spawn it. We don't track individual threads because:
    -- 1. We can't kill threads in Luau
    -- 2. Polling loops burn CPU
    -- 3. coroutine.create + resume has edge cases with yields
    -- User should use :IsAlive() in their loop for cooperative cancellation
    return task.spawn(function()
        local ok, err = pcall(func, table.unpack(args, 1, n))
        if not ok then
            self:_Warn("Thread error:", err)
        end
    end)
end

function AntiLeak:Delay(seconds, func, ...)
    if not self.Alive then
        self:_Warn("Delay called after Cleanup")
        return nil
    end

    local args = {...}
    local n = select("#", ...)

    return task.delay(seconds, function()
        if not self.Alive then return end
        local ok, err = pcall(func, table.unpack(args, 1, n))
        if not ok then
            self:_Warn("Delayed thread error:", err)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Instance API
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak:TrackInstance(instance, metadata)
    if not self.Alive then
        self:_Warn("TrackInstance called after Cleanup")
        return nil
    end
    if not instance or typeof(instance) ~= "Instance" then
        self:_Warn("TrackInstance: expected Instance, got", typeof(instance))
        return nil
    end

    -- Check if already tracked
    for id, info in pairs(self.Instances) do
        if info.Instance == instance then
            return id
        end
    end

    -- Evict oldest if at limit
    if self.InstCount >= self.Config.MaxTracked then
        local oldestId, oldestTime = nil, math.huge
        for id, info in pairs(self.Instances) do
            if info.Created < oldestTime then
                oldestTime = info.Created
                oldestId = id
            end
        end
        if oldestId then
            self:_Warn("Max instances reached, evicting oldest:", oldestId)
            self:DestroyInstance(oldestId)
        end
    end

    local id = self:_Id()

    self.Instances[id] = {
        Id = id,
        Instance = instance,
        Created = tick(),
        Orphaned = nil,  -- nil = not orphaned, number = tick() when orphaned
        Whitelisted = metadata and metadata.Whitelisted == true,
        Meta = metadata or {},
    }
    self.InstCount += 1

    self:_Dbg("Tracking instance", id, instance.Name)
    return id
end

function AntiLeak:DestroyInstance(idOrInstance)
    local id, info

    if typeof(idOrInstance) == "number" then
        id = idOrInstance
        info = self.Instances[id]
    else
        -- Find by instance reference
        for cid, cinfo in pairs(self.Instances) do
            if cinfo.Instance == idOrInstance then
                id = cid
                info = cinfo
                break
            end
        end
    end

    if not info then return end

    local inst = info.Instance

    -- Only destroy if still exists and parented
    if inst and inst.Parent ~= nil then
        local ok, err = pcall(function()
            inst:Destroy()
        end)
        if not ok then
            self:_Warn("Destroy failed:", err)
        end
    end

    self.Instances[id] = nil
    self.InstCount = math.max(0, self.InstCount - 1)
    self.Stats.InstancesDestroyed += 1

    self:_Dbg("Destroyed instance", id)
end

function AntiLeak:WhitelistInstance(id)
    local info = self.Instances[id]
    if info then
        info.Whitelisted = true
        self:_Dbg("Whitelisted instance", id)
    end
end

function AntiLeak:IsTrackedInstance(instance)
    for _, info in pairs(self.Instances) do
        if info.Instance == instance then
            return true
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Table API (explicit wrapper, no metatable magic)
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak:TrackTable(rawTable, name)
    if not self.Alive then
        self:_Warn("TrackTable called after Cleanup")
        return nil
    end
    if typeof(rawTable) ~= "table" then
        rawTable = {}
    end

    -- Check if already tracked
    for id, info in pairs(self.Tables) do
        if info.Raw == rawTable then
            return info.Wrapper, id
        end
    end

    -- Evict oldest if at limit
    if self.TableCount >= self.Config.MaxTracked then
        local oldestId, oldestTime = nil, math.huge
        for id, info in pairs(self.Tables) do
            if info.Created < oldestTime then
                oldestTime = info.Created
                oldestId = id
            end
        end
        if oldestId then
            self:_Warn("Max tables reached, evicting oldest:", oldestId)
            self:ClearTable(oldestId)
        end
    end

    local id = self:_Id()
    local now = tick()

    local info = {
        Id = id,
        Raw = rawTable,
        Name = name or "Untitled",
        Created = now,
        Accessed = now,
    }

    -- Explicit wrapper object — no metatables, no magic
    local wrapper = {
        _antiLeakId = id,
        _antiLeakTracker = self,
    }

    function wrapper:Get(key)
        info.Accessed = tick()
        return rawTable[key]
    end

    function wrapper:Set(key, value)
        info.Accessed = tick()
        rawTable[key] = value
    end

    function wrapper:Remove(key)
        info.Accessed = tick()
        rawTable[key] = nil
    end

    function wrapper:Length()
        info.Accessed = tick()
        return #rawTable
    end

    function wrapper:Pairs()
        info.Accessed = tick()
        return pairs(rawTable)
    end

    function wrapper:IPairs()
        info.Accessed = tick()
        return ipairs(rawTable)
    end

    function wrapper:Keys()
        info.Accessed = tick()
        local keys = {}
        for k in pairs(rawTable) do
            table.insert(keys, k)
        end
        return keys
    end

    function wrapper:Size()
        info.Accessed = tick()
        local count = 0
        for _ in pairs(rawTable) do
            count += 1
        end
        return count
    end

    function wrapper:Raw()
        return rawTable
    end

    function wrapper:Clear()
        for k in pairs(rawTable) do
            rawTable[k] = nil
        end
    end

    info.Wrapper = wrapper
    self.Tables[id] = info
    self.TableCount += 1

    self:_Dbg("Tracking table", id, name)
    return wrapper, id
end

function AntiLeak:ClearTable(idOrWrapper)
    local id, info

    if typeof(idOrWrapper) == "number" then
        id = idOrWrapper
        info = self.Tables[id]
    elseif typeof(idOrWrapper) == "table" and idOrWrapper._antiLeakId then
        id = idOrWrapper._antiLeakId
        info = self.Tables[id]
    else
        -- Find by raw table
        for cid, cinfo in pairs(self.Tables) do
            if cinfo.Raw == idOrWrapper then
                id = cid
                info = cinfo
                break
            end
        end
    end

    if not info then return end

    for k in pairs(info.Raw) do
        info.Raw[k] = nil
    end

    self.Tables[id] = nil
    self.TableCount = math.max(0, self.TableCount - 1)
    self.Stats.TablesCleared += 1

    self:_Dbg("Cleared table", id)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Scanning & Cleanup
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak:_Scan()
    local now = tick()
    local leaks = {Instances = {}, Connections = {}, Tables = {}}

    -- Scan instances
    for id, info in pairs(self.Instances) do
        local inst = info.Instance
        if not inst then
            -- Instance was GC'd (shouldn't happen with strong refs, but handle)
            table.insert(leaks.Instances, id)
        else
            local ok, parent = pcall(function() return inst.Parent end)
            if ok and parent == nil and not info.Whitelisted then
                local orphanedFor = info.Orphaned and (now - info.Orphaned) or 0
                if orphanedFor >= self.Config.OrphanTimeout then
                    table.insert(leaks.Instances, id)
                elseif not info.Orphaned then
                    -- Just became orphaned
                    info.Orphaned = now
                end
            elseif ok and parent ~= nil then
                -- No longer orphaned
                info.Orphaned = nil
            end
        end
    end

    -- Scan connections
    for id, info in pairs(self.Connections) do
        if not info.Meta.LongLived then
            local idle = now - info.LastFired
            if idle >= self.Config.StaleConnectionTimeout then
                table.insert(leaks.Connections, id)
            end
        end
    end

    -- Scan tables
    for id, info in pairs(self.Tables) do
        local idle = now - info.Accessed
        if idle >= self.Config.AbandonedTableTimeout then
            table.insert(leaks.Tables, id)
        end
    end

    local totalLeaks = #leaks.Instances + #leaks.Connections + #leaks.Tables
    self.Stats.LeaksDetected += totalLeaks

    if self.Config.AutoCleanup then
        self:_Clean(leaks)
    end

    -- Memory check
    self:_CheckMemory()
end

function AntiLeak:_Clean(leaks)
    for _, id in ipairs(leaks.Instances) do
        self:DestroyInstance(id)
    end
    for _, id in ipairs(leaks.Connections) do
        self:Disconnect(id)
    end
    for _, id in ipairs(leaks.Tables) do
        self:ClearTable(id)
    end
    self.Stats.LeaksCleaned += (#leaks.Instances + #leaks.Connections + #leaks.Tables)
end

function AntiLeak:_CheckMemory()
    local mem = self:_Mem()
    if mem > self.Stats.PeakMemoryMB then
        self.Stats.PeakMemoryMB = mem
    end

    if mem > self.Config.AlertThresholdMB then
        self:_Warn(string.format("MEMORY ALERT: %.2f MB > %.2f MB threshold", mem, self.Config.AlertThresholdMB))

        if self.Config.DeferredGC then
            task.defer(collectgarbage, "collect")
        else
            collectgarbage("collect")
        end
    end
end

function AntiLeak:_OnPlayerRemoved(player)
    -- Clean player-related instances
    local toRemove = {}
    for id, info in pairs(self.Instances) do
        local inst = info.Instance
        if inst then
            local ok, isDesc = pcall(function()
                return inst == player or inst:IsDescendantOf(player)
            end)
            if ok and isDesc then
                table.insert(toRemove, id)
            end
        end
    end
    for _, id in ipairs(toRemove) do
        self:DestroyInstance(id)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Cleanup
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak:Cleanup()
    if not self.Alive then return end
    self.Alive = false

    self:_Dbg("Starting cleanup...")

    -- Disconnect all user connections
    local connIds = {}
    for id in pairs(self.Connections) do
        table.insert(connIds, id)
    end
    for _, id in ipairs(connIds) do
        self:Disconnect(id)
    end

    -- Destroy instances (deepest first)
    local instList = {}
    for id, info in pairs(self.Instances) do
        local depth = 0
        local inst = info.Instance
        if inst then
            local ok, parent = pcall(function() return inst.Parent end)
            while ok and parent do
                depth += 1
                ok, parent = pcall(function() return parent.Parent end)
            end
        end
        table.insert(instList, {Id = id, Depth = depth, Created = info.Created})
    end

    table.sort(instList, function(a, b)
        if a.Depth ~= b.Depth then
            return a.Depth > b.Depth
        end
        return a.Created < b.Created
    end)

    for _, item in ipairs(instList) do
        self:DestroyInstance(item.Id)
    end

    -- Clear tables
    local tableIds = {}
    for id in pairs(self.Tables) do
        table.insert(tableIds, id)
    end
    for _, id in ipairs(tableIds) do
        self:ClearTable(id)
    end

    -- Disconnect all internal connections
    for _, conn in ipairs(self.InternalConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    self.InternalConnections = {}

    self:_Dbg("Cleanup complete")
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Stats & Config
-- ═══════════════════════════════════════════════════════════════════════════════

function AntiLeak:GetStats()
    return {
        LeaksDetected = self.Stats.LeaksDetected,
        LeaksCleaned = self.Stats.LeaksCleaned,
        ConnectionsClosed = self.Stats.ConnectionsClosed,
        InstancesDestroyed = self.Stats.InstancesDestroyed,
        TablesCleared = self.Stats.TablesCleared,
        PeakMemoryMB = self.Stats.PeakMemoryMB,
        CurrentMemoryMB = self:_Mem(),
        ActiveConnections = self.ConnCount,
        ActiveInstances = self.InstCount,
        ActiveTables = self.TableCount,
    }
end

function AntiLeak:SetConfig(key, value)
    if DEFAULT_CONFIG[key] == nil then
        self:_Warn("Unknown config key:", key)
        return
    end
    if type(value) == "number" and value < 0 then
        self:_Warn("Invalid value for", key, ": must be >= 0")
        return
    end
    self.Config[key] = value
    self:_Dbg("Config", key, "=", value)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Environment (module-level, read-only, lazy)
-- ═══════════════════════════════════════════════════════════════════════════════

local Environment = nil

function AntiLeak.GetEnvironment()
    if Environment then return Environment end

    Environment = {IsUnlegit = false}
    local indicators = {"getgenv", "getrawmetatable", "hookfunction", "getconnections", "getgc"}
    for _, ind in ipairs(indicators) do
        local ok, exists = pcall(function()
            return typeof(_G[ind]) == "function"
        end)
        if ok and exists then
            Environment.IsUnlegit = true
            break
        end
    end
    return Environment
end

return AntiLeak
