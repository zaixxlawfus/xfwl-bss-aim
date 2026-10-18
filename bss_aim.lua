-- ============================================================================
-- BSS-Aim ULTRA v12.4
-- Car Aim fixed, No Recoil, Anti-Freeze mira, ESP HP + WEAPON ICON ESP
-- ============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

pcall(function()
    if gethui then
        for _, v in ipairs(gethui():GetChildren()) do
            if v.Name:match("^BSS_") then v:Destroy() end
        end
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, v in ipairs(pg:GetChildren()) do
            if v.Name:match("^BSS_") then v:Destroy() end
        end
    end
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
end)

getgenv().BSS_Aim_Loaded = true
local _scriptActive = true

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_PC = not IS_MOBILE
local ICON_SPLASH = "rbxassetid://96190503453096"

-- ============================================================================
-- WEAPON DATABASE
-- ============================================================================
local WEAPON_DB = {
    ["M249"]              = { tier=5, label="M249",         color=Color3.fromRGB(255,50,50),   icon="" },
    ["Anaconda"]          = { tier=5, label="Anaconda",     color=Color3.fromRGB(255,50,50),   icon="" },
    ["RPG"]               = { tier=4, label="RPG",          color=Color3.fromRGB(255,140,0),   icon="" },
    ["M16"]               = { tier=4, label="M16",          color=Color3.fromRGB(255,140,0),   icon="" },
    ["AK47"]              = { tier=4, label="AK47",         color=Color3.fromRGB(255,140,0),   icon="" },
    ["AK-47"]             = { tier=4, label="AK47",         color=Color3.fromRGB(255,140,0),   icon="" },
    ["Remington"]         = { tier=4, label="Remington",    color=Color3.fromRGB(255,140,0),   icon="" },
    ["MP5"]               = { tier=4, label="MP5",          color=Color3.fromRGB(255,140,0),   icon="" },
    ["Crossbow"]          = { tier=4, label="Crossbow",     color=Color3.fromRGB(255,140,0),   icon="" },
    ["Tactical Axe"]      = { tier=4, label="Tac.Axe",      color=Color3.fromRGB(255,140,0),   icon="" },
    ["Tactical Shovel"]   = { tier=4, label="Tac.Shovel",   color=Color3.fromRGB(255,140,0),   icon="" },
    ["Tactical Knife"]    = { tier=4, label="Tac.Knife",    color=Color3.fromRGB(255,140,0),   icon="" },
    ["Firework Launcher"] = { tier=4, label="Firework",     color=Color3.fromRGB(255,140,0),   icon="" },
    ["M24"]               = { tier=3, label="M24",          color=Color3.fromRGB(160,80,255),  icon="" },
    ["Draco"]             = { tier=3, label="Draco",        color=Color3.fromRGB(160,80,255),  icon="" },
    ["Skorpion"]          = { tier=3, label="Skorpion",     color=Color3.fromRGB(160,80,255),  icon="" },
    ["Double Barrel"]     = { tier=3, label="Dbl.Barrel",   color=Color3.fromRGB(160,80,255),  icon="" },
    ["Barbed Baseball Bat"]={ tier=3, label="Barbed Bat",   color=Color3.fromRGB(160,80,255),  icon="" },
    ["Sledge Hammer"]     = { tier=3, label="Sledge",       color=Color3.fromRGB(160,80,255),  icon="" },
    ["Combat Axe"]        = { tier=3, label="Cmbt.Axe",     color=Color3.fromRGB(160,80,255),  icon="" },
    ["Machete"]           = { tier=3, label="Machete",      color=Color3.fromRGB(160,80,255),  icon="" },
    ["Shovel"]            = { tier=3, label="Shovel",       color=Color3.fromRGB(160,80,255),  icon="" },
    ["Brainrot Slapper"]  = { tier=2, label="Brainrot",     color=Color3.fromRGB(80,220,120),  icon="" },
    ["Hunting Rifle"]     = { tier=2, label="Hunt.Rifle",   color=Color3.fromRGB(80,220,120),  icon="" },
    ["Uzi"]               = { tier=2, label="Uzi",          color=Color3.fromRGB(80,220,120),  icon="" },
    ["Sawnoff"]           = { tier=2, label="Sawnoff",      color=Color3.fromRGB(80,220,120),  icon="" },
    ["P226"]              = { tier=2, label="P226",         color=Color3.fromRGB(80,220,120),  icon="" },
    ["Glock"]             = { tier=2, label="Glock",        color=Color3.fromRGB(80,220,120),  icon="" },
    ["Metal Baseball Bat"]= { tier=2, label="Metal Bat",    color=Color3.fromRGB(80,220,120),  icon="" },
    ["Wrench"]            = { tier=2, label="Wrench",       color=Color3.fromRGB(80,220,120),  icon="" },
    ["Crowbar"]           = { tier=2, label="Crowbar",      color=Color3.fromRGB(80,220,120),  icon="" },
    ["Axe"]               = { tier=2, label="Axe",          color=Color3.fromRGB(80,220,120),  icon="" },
    ["Frying Pan"]        = { tier=2, label="Pan",          color=Color3.fromRGB(80,220,120),  icon="" },
    ["Butcher Knife"]     = { tier=2, label="Butcher",      color=Color3.fromRGB(80,220,120),  icon="" },
    ["Switchblade"]       = { tier=2, label="Switchblade",  color=Color3.fromRGB(80,220,120),  icon="" },
    ["Baseball Bat"]      = { tier=1, label="Baseball Bat", color=Color3.fromRGB(180,180,180), icon="" },
    ["G3"]                = { tier=1, label="G3",           color=Color3.fromRGB(180,180,180), icon="" },
    ["C9"]                = { tier=1, label="C9",           color=Color3.fromRGB(180,180,180), icon="" },
}

local function resolveWeapon(toolName)
    if not toolName then return nil end
    local entry = WEAPON_DB[toolName]
    if entry then return entry end
    local low = toolName:lower()
    for k, v in pairs(WEAPON_DB) do
        if k:lower() == low then return v end
    end
    for k, v in pairs(WEAPON_DB) do
        if low:find(k:lower(), 1, true) or k:lower():find(low, 1, true) then return v end
    end
    return nil
end

local weaponCache = {}
local function getEquippedWeapon(plr)
    local best = nil
    local bestTier = -1
    local bestTexture = ""
    local function scanParent(parent)
        if not parent then return end
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") then
                local entry = resolveWeapon(tool.Name)
                local tier = entry and entry.tier or 0
                if tier > bestTier then
                    bestTier = tier
                    best = entry or { tier=0, label=tool.Name:sub(1,12), color=Color3.fromRGB(200,200,200), icon="" }
                    bestTexture = (tool.TextureId and tool.TextureId ~= "") and tool.TextureId or (entry and entry.icon or "")
                end
            end
        end
    end
    local char = plr.Character
    local equipped = char and char:FindFirstChildOfClass("Tool")
    local toolName = equipped and equipped.Name or "__none__"
    local cached = weaponCache[plr.UserId]
    if cached and cached.lastTool == toolName then
        return cached.entry, cached.texture
    end
    scanParent(plr:FindFirstChild("Backpack"))
    scanParent(char)
    weaponCache[plr.UserId] = { entry=best, texture=bestTexture, lastTool=toolName }
    return best, bestTexture
end

local function hookWeaponCache(plr)
    local function connect(container)
        if not container then return end
        container.ChildAdded:Connect(function(c) if c:IsA("Tool") then weaponCache[plr.UserId] = nil end end)
        container.ChildRemoved:Connect(function(c) if c:IsA("Tool") then weaponCache[plr.UserId] = nil end end)
    end
    if plr:FindFirstChild("Backpack") then connect(plr.Backpack) end
    plr.ChildAdded:Connect(function(c) if c.Name == "Backpack" then connect(c) end end)
    if plr.Character then connect(plr.Character) end
    plr.CharacterAdded:Connect(function(char) weaponCache[plr.UserId] = nil; connect(char) end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then hookWeaponCache(plr) end
end
Players.PlayerAdded:Connect(function(plr) if plr ~= LocalPlayer then hookWeaponCache(plr) end end)
Players.PlayerRemoving:Connect(function(plr) weaponCache[plr.UserId] = nil end)

-- ============================================================================
-- LOCAL HUMANOID CACHE
-- ============================================================================
local _localChar = nil
local _localHum = nil
local _localHRP = nil
local function cacheLocalCharacter()
    _localChar = LocalPlayer.Character
    _localHum = _localChar and _localChar:FindFirstChild("Humanoid")
    _localHRP = _localChar and _localChar:FindFirstChild("HumanoidRootPart")
end
cacheLocalCharacter()
LocalPlayer.CharacterAdded:Connect(function(char)
    _localChar = char
    task.wait(0.3)
    _localHum = char:FindFirstChild("Humanoid")
    _localHRP = char:FindFirstChild("HumanoidRootPart")
end)

-- ============================================================================
-- CONFIG & SAVE
-- ============================================================================
local CONFIG_FOLDER = "BSS_Aim_Ultra"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local HAVE_FILE_IO = (writefile and readfile and isfile and makefolder) and true or false
local CONFIG_VERSION = 14

local function ensureFolder()
    if not HAVE_FILE_IO then return end
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        if not isfolder(CONFIG_FOLDER .. "/profiles") then makefolder(CONFIG_FOLDER .. "/profiles") end
    end)
end

local function serializeCfg(cfg)
    local clean = {}
    for k, v in pairs(cfg) do
        if type(v) == "number" or type(v) == "string" or type(v) == "boolean" then
            clean[k] = v
        elseif typeof(v) == "EnumItem" then
            clean[k] = tostring(v)
            clean[k .. "__enum"] = v.EnumType.Name
        elseif typeof(v) == "Color3" then
            clean[k] = {v.R, v.G, v.B}
            clean[k .. "__c3"] = true
        end
    end
    return clean
end

local function deserializeCfg(data)
    if not data then return nil end
    for k, v in pairs(data) do
        if type(k) == "string" and k:sub(-7) == "__enum" then
            local realKey = k:sub(1, -8)
            if Enum[v] and data[realKey] then
                local ok2, item = pcall(function() return Enum[v][data[realKey]] end)
                if ok2 then data[realKey] = item end
            end
            data[k] = nil
        elseif type(k) == "string" and k:sub(-4) == "__c3" then
            local realKey = k:sub(1, -5)
            if type(data[realKey]) == "table" then
                local t = data[realKey]
                data[realKey] = Color3.new(t[1], t[2], t[3])
            end
            data[k] = nil
        end
    end
    return data
end

local function saveConfigTo(path, cfg)
    if not HAVE_FILE_IO then return false end
    local ok = pcall(function()
        ensureFolder()
        writefile(path, HttpService:JSONEncode(serializeCfg(cfg)))
    end)
    return ok
end

local function loadConfigFrom(path)
    if not HAVE_FILE_IO then return nil end
    local ok, data = pcall(function()
        if not isfile(path) then return nil end
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or not data then return nil end
    return deserializeCfg(data)
end

local DEFAULTS = {
    ConfigVersion = CONFIG_VERSION,
    Enabled = true,
    HoldKey = "E",
    ToggleKey = "RightShift",
    PanelKey = "L",
    CloseKey = "M",
    PanicKey = "Delete",
    FOV = 130,
    FOVRadius = 130,
    MaxDistance = 500,
    TargetPart = "Head",
    TeamCheck = false,
    WallCheck = true,
    DrawFOV = true,
    CameraLock = true,
    SilentAim = true,
    TriggerBot = false,
    Priority = "fov",
    PlayerESP = true,
    ChamsESP = true,
    NameESP = true,
    HealthESP = true,
    WeaponESP = true,
    ItemESP = true,
    NoRecoil = true,
    HitboxExpander = false,
    HitboxSize = 10,
    HitboxTransparency = 0.5,
    MaxESP = 400,
    ESPRefresh = 0.05,
    ESPColor = {1, 1, 1},
    AutoPickup = true,
    PickupRadius = 50,
    PickupDelay = 0.1,
    PickupMoney = true,
    PickupWeapons = true,
    PickupFood = true,
    PickupTools = true,
    HUDWatermark = true,
    HUDStats = true,
    HUDFPS = true,
    TargetInfo = true,
    AutoSaveEnabled = true,
    AutoSaveInterval = 10,
    HideName = false,
    HideNameText = "...",
    HideLeaderboard = false,
}

local function defaultCfg()
    local c = {}
    for k, v in pairs(DEFAULTS) do
        if type(v) == "table" then c[k] = {unpack(v)} else c[k] = v end
    end
    return c
end

local function resolveKey(s, default)
    if typeof(s) == "EnumItem" then return s end
    if type(s) == "string" then
        local ok, e = pcall(function() return Enum.KeyCode[s] end)
        if ok and e then return e end
    end
    return default
end

local CFG = defaultCfg()
local saved = loadConfigFrom(CONFIG_FILE)
if saved and saved.ConfigVersion == CONFIG_VERSION then
    for k, v in pairs(saved) do
        if CFG[k] ~= nil or k == "ESPColor" then CFG[k] = v end
    end
else
    CFG.HoldKey = resolveKey("E", Enum.KeyCode.E)
    CFG.PanelKey = resolveKey("L", Enum.KeyCode.L)
    CFG.CloseKey = resolveKey("M", Enum.KeyCode.M)
    saveConfigTo(CONFIG_FILE, CFG)
end

if type(CFG.ESPColor) == "table" then CFG.ESPColor = Color3.new(unpack(CFG.ESPColor)) end
CFG.FOVRadius = CFG.FOV
getgenv().BSS_AimConfig = CFG

-- ============================================================================
-- AUTO-SAVE
-- ============================================================================
local dirtyFlag = false
local lastAutoSave = tick()
local function scheduleSave() dirtyFlag = true end
local function doSave()
    if not HAVE_FILE_IO then return end
    if saveConfigTo(CONFIG_FILE, CFG) then dirtyFlag = false; lastAutoSave = tick() end
end
task.spawn(function()
    while _scriptActive do
        if CFG.AutoSaveEnabled and dirtyFlag and (tick() - lastAutoSave) >= (CFG.AutoSaveInterval or 10) then doSave() end
        task.wait(1)
    end
end)

-- ============================================================================
-- TEMA
-- ============================================================================
local C = {
    bg = Color3.fromRGB(6, 6, 8), bg2 = Color3.fromRGB(12, 12, 16), bg3 = Color3.fromRGB(20, 20, 26), bg4 = Color3.fromRGB(32, 32, 40),
    accent = Color3.fromRGB(255, 255, 255), accent2 = Color3.fromRGB(220, 220, 230), accent3 = Color3.fromRGB(180, 180, 190),
    fg = Color3.fromRGB(245, 245, 250), muted = Color3.fromRGB(140, 140, 155), danger = Color3.fromRGB(255, 70, 90), border = Color3.fromRGB(60, 60, 72),
    hp = Color3.fromRGB(80, 220, 120), stamina = Color3.fromRGB(255, 210, 60), aimOn = Color3.fromRGB(255, 80, 90), aimLock = Color3.fromRGB(255, 255, 255),
}

local TIER_COLORS = {
    [5] = Color3.fromRGB(255, 50,  50),
    [4] = Color3.fromRGB(255, 140,  0),
    [3] = Color3.fromRGB(160, 80,  255),
    [2] = Color3.fromRGB(80,  220, 120),
    [1] = Color3.fromRGB(180, 180, 180),
    [0] = Color3.fromRGB(120, 120, 120),
}
local TIER_LABELS = { [5]="[Ω]", [4]="[L]", [3]="[E]", [2]="[R]", [1]="[U]", [0]="[?]" }

local function getParent()
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function notify(title, text, dur)
    pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = dur or 4 }) end)
end

-- ============================================================================
-- ESTADO
-- ============================================================================
local aimOn = false
local currentTarget = nil
local lastSwitch = 0
local lastTargetCheck = 0
local sessionStart = tick()
local sessionKills = 0
local sessionPickups = 0
local lastHealthSnapshot = {}
local isFiring = false
local savedShotRotation = nil
local lastMouseMove = 0
local manualAimOverride = false

-- ============================================================================
-- CACHE GLOBAL
-- ============================================================================
local _uiCache = {
    hideName = nil, hideLeaderboard = nil,
    watermarkVisible = nil, statsVisible = nil,
    fovVisible = nil, fovSize = nil, fovColor = nil,
}
local _hitboxOriginal = setmetatable({}, {__mode = "k"})
local _hitboxApplied  = setmetatable({}, {__mode = "k"})
local _espCache = setmetatable({}, {__mode = "k"})

local _vpCenter = Vector2.new(0, 0)
local function refreshVpCenter()
    local vp = Camera.ViewportSize
    _vpCenter = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
end
refreshVpCenter()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshVpCenter)

local _droppedItemsFolder = nil
local function getDroppedFolder()
    if _droppedItemsFolder and _droppedItemsFolder.Parent then return _droppedItemsFolder end
    _droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
    return _droppedItemsFolder
end

-- ============================================================================
-- CAR CAMERA STATE
-- ============================================================================
local _carAimActive = false
local _savedCamType = nil
local _savedCamSubject = nil
local _carSeat = nil

local function enterCarAim(hum)
    if _carAimActive then return end
    _carAimActive = true
    _savedCamType = Camera.CameraType
    _savedCamSubject = Camera.CameraSubject
    _carSeat = hum and hum.SeatPart
    if Camera.CameraType ~= Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Scriptable
    end
end

local function exitCarAim()
    if not _carAimActive then return end
    _carAimActive = false
    if _savedCamSubject then
        pcall(function() Camera.CameraSubject = _savedCamSubject end)
    end
    local target = _savedCamType or Enum.CameraType.Custom
    if Camera.CameraType ~= target then
        Camera.CameraType = target
    end
    _savedCamType = nil
    _savedCamSubject = nil
    _carSeat = nil
end

-- ============================================================================
-- HIDE NAME
-- ============================================================================
local originalDisplayName = nil
local function applyHideName()
    if _uiCache.hideName == CFG.HideName and _uiCache.hideLeaderboard == CFG.HideLeaderboard then return end
    _uiCache.hideName = CFG.HideName
    _uiCache.hideLeaderboard = CFG.HideLeaderboard
    pcall(function()
        if originalDisplayName == nil then originalDisplayName = LocalPlayer.DisplayName end
        if CFG.HideName then LocalPlayer.DisplayName = CFG.HideNameText or "..." else LocalPlayer.DisplayName = originalDisplayName end
    end)
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not CFG.HideLeaderboard)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not CFG.HideName)
    end)
end

-- ============================================================================
-- FOV CIRCLE
-- ============================================================================
local espScreen = Instance.new("ScreenGui")
espScreen.Name = "BSS_FOV"; espScreen.ResetOnSpawn = false; espScreen.IgnoreGuiInset = true; espScreen.DisplayOrder = 90; espScreen.Parent = getParent()

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOV"; fovCircle.BackgroundTransparency = 1; fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.Size = UDim2.fromOffset(CFG.FOVRadius * 2, CFG.FOVRadius * 2); fovCircle.Visible = false; fovCircle.ZIndex = 100; fovCircle.Parent = espScreen
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke"); fovStroke.Color = C.accent; fovStroke.Thickness = 2; fovStroke.Parent = fovCircle

-- ============================================================================
-- MOBILE AIM
-- ============================================================================
local aimBtn = nil
if IS_MOBILE then
    aimBtn = Instance.new("TextButton")
    aimBtn.Name = "AimBtn"; aimBtn.Size = UDim2.fromOffset(90, 90); aimBtn.Position = UDim2.new(0, 20, 1, -210); aimBtn.BackgroundColor3 = Color3.fromRGB(15, 17, 24); aimBtn.BackgroundTransparency = 0.2
    aimBtn.Text = "AIM"; aimBtn.TextColor3 = C.accent; aimBtn.TextSize = 22; aimBtn.Font = Enum.Font.GothamBold; aimBtn.AutoButtonColor = false; aimBtn.Active = true; aimBtn.Selectable = true; aimBtn.ZIndex = 200; aimBtn.Parent = espScreen
    Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(1, 0)
    local bs1 = Instance.new("UIStroke"); bs1.Color = C.accent; bs1.Thickness = 3; bs1.Parent = aimBtn
    aimBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            aimOn = true; bs1.Color = C.aimOn; aimBtn.TextColor3 = C.aimOn
        end
    end)
    aimBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            aimOn = false; bs1.Color = C.accent; aimBtn.TextColor3 = C.accent
        end
    end)
end

-- ============================================================================
-- AIM CORE
-- ============================================================================
local rayP = RaycastParams.new(); rayP.FilterType = Enum.RaycastFilterType.Exclude
local function refreshFilter()
    local f = {Camera}
    if LocalPlayer.Character then
        table.insert(f, LocalPlayer.Character)
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum.SeatPart then table.insert(f, hum.SeatPart.Parent) end
    end
    rayP.FilterDescendantsInstances = f
end
refreshFilter()
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.4); refreshFilter()
    weaponCache = {}
    local hum = char:WaitForChild("Humanoid", 3)
    if hum then hum:GetPropertyChangedSignal("SeatPart"):Connect(function() task.wait(0.1); refreshFilter() end) end
end)

local function sameTeam(plr) if not CFG.TeamCheck then return false end; return plr.Team == LocalPlayer.Team end
local function alive(plr)
    local c = plr.Character; if not c then return false end
    local h = c:FindFirstChild("Humanoid"); return h and h.Health > 0
end
local function visible(target, char)
    if not CFG.WallCheck then return true end
    local o = Camera.CFrame.Position; local d = target.Position - o
    local hit = Workspace:Raycast(o, d, rayP); if not hit then return true end
    return hit.Instance and hit.Instance:IsDescendantOf(char)
end

local function getTargetWithScore()
    local candidates = {}
    local camPos = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or sameTeam(plr) or not alive(plr) then continue end
        local char = plr.Character
        local part = char:FindFirstChild(CFG.TargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local wp = part.Position; local d3 = (camPos - wp).Magnitude
        if d3 > CFG.MaxDistance then continue end
        local sp, on = Camera:WorldToViewportPoint(wp); if not on then continue end
        local px = (Vector2.new(sp.X, sp.Y) - _vpCenter).Magnitude; if px > CFG.FOVRadius then continue end
        local score = (CFG.Priority == "dist") and d3 or px
        table.insert(candidates, {plr = plr, part = part, score = score})
    end
    table.sort(candidates, function(a, b) return a.score < b.score end)
    for i = 1, math.min(2, #candidates) do
        local c = candidates[i]
        if not CFG.WallCheck or visible(c.part, c.plr.Character) then return c.plr, c.part, c.score end
    end
    return nil, nil, math.huge
end

local function targetDead()
    if not currentTarget or not currentTarget.Parent then return true end
    local char = currentTarget.Parent; local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    if (Camera.CFrame.Position - currentTarget.Position).Magnitude > CFG.MaxDistance then return true end
    return false
end
local function targetPx()
    if not currentTarget then return math.huge end
    local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
    if not on then return math.huge end
    return (Vector2.new(sp.X, sp.Y) - _vpCenter).Magnitude
end

-- ============================================================================
-- INPUT
-- ============================================================================
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if input.Delta.Magnitude > 0.5 then
            lastMouseMove = tick()
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.HoldKey or i.UserInputType == CFG.HoldKey then aimOn = true end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.KeyCode == Enum.KeyCode.ButtonR2 then
        isFiring = true
        if CFG.NoRecoil and Camera.CameraType ~= Enum.CameraType.Scriptable then
            savedShotRotation = Camera.CFrame.Rotation
        end
    end
    if i.KeyCode == CFG.PanicKey then aimOn = false; CFG.Enabled = false; notify("PANIC", "Todo desactivado", 3) end
end)

UserInputService.InputEnded:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.HoldKey or i.UserInputType == CFG.HoldKey then aimOn = false end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.KeyCode == Enum.KeyCode.ButtonR2 then
        isFiring = false; savedShotRotation = nil
    end
end)

-- ============================================================================
-- SILENT AIM
-- ============================================================================
local mt = nil
pcall(function() if getrawmetatable then mt = getrawmetatable(game) end end)

local silentHookInstalled = false
local oldNamecall = nil
if mt then oldNamecall = mt.__namecall end

local function installSilentHook()
    if silentHookInstalled or not mt or not newcclosure or not setreadonly then return end
    silentHookInstalled = true
    pcall(function()
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod and getnamecallmethod()
            if method == "FireServer" and currentTarget and not manualAimOverride then
                local args = {...}
                if #args >= 1 then
                    local first = args[1]
                    if typeof(first) == "Vector3" then
                        local dir = (currentTarget.Position - Camera.CFrame.Position).Unit
                        args[1] = dir * (first.Magnitude > 0 and first.Magnitude or 1000)
                    elseif typeof(first) == "CFrame" then
                        args[1] = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
                    end
                end
                return oldNamecall(self, table.unpack(args))
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local function uninstallSilentHook()
    if not silentHookInstalled or not mt then return end
    silentHookInstalled = false
    pcall(function()
        setreadonly(mt, false)
        mt.__namecall = oldNamecall
        setreadonly(mt, true)
    end)
end

-- ============================================================================
-- HITBOX EXPANDER
-- ============================================================================
local function applyHitbox(char)
    if not CFG.HitboxExpander or not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp and not head then return end

    local orig = _hitboxOriginal[char]
    if not orig then
        orig = {
            hrpSize    = hrp and hrp.Size,
            hrpT       = hrp and hrp.Transparency,
            hrpCollide = hrp and hrp.CanCollide,
            hrpMass    = hrp and hrp.Massless,
            hrpTouch   = hrp and hrp.CanTouch,
            headSize   = head and head.Size,
            headT      = head and head.Transparency,
            headCollide= head and head.CanCollide,
            headMass   = head and head.Massless,
            headTouch  = head and head.CanTouch,
        }
        _hitboxOriginal[char] = orig
    end

    local wantSize = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize)
    local wantT    = CFG.HitboxTransparency
    local cache = _hitboxApplied[char]
    if not cache then cache = {}; _hitboxApplied[char] = cache end

    if hrp then
        if cache.hrpCollide ~= false then hrp.CanCollide = false; cache.hrpCollide = false end
        if cache.hrpMass ~= true     then hrp.Massless   = true;  cache.hrpMass    = true  end
        if cache.hrpTouch ~= false   then hrp.CanTouch   = false; cache.hrpTouch   = false end
        if cache.hrpSize ~= wantSize then hrp.Size       = wantSize; cache.hrpSize = wantSize end
        if cache.hrpT    ~= wantT    then hrp.Transparency = wantT; cache.hrpT     = wantT end
    end
    if head then
        if cache.headCollide ~= false then head.CanCollide = false; cache.headCollide = false end
        if cache.headMass ~= true     then head.Massless   = true;  cache.headMass    = true  end
        if cache.headTouch ~= false   then head.CanTouch   = false; cache.headTouch   = false end
        if cache.headSize ~= wantSize then head.Size       = wantSize; cache.headSize = wantSize end
        if cache.headT    ~= wantT    then head.Transparency = wantT; cache.headT     = wantT end
    end
end

local function restoreHitbox(char)
    if not char then return end
    local orig = _hitboxOriginal[char]
    if not orig then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if hrp then
        if orig.hrpCollide ~= nil then hrp.CanCollide = orig.hrpCollide end
        if orig.hrpMass    ~= nil then hrp.Massless   = orig.hrpMass end
        if orig.hrpTouch   ~= nil then hrp.CanTouch   = orig.hrpTouch end
        if orig.hrpSize    then hrp.Size = orig.hrpSize end
        if orig.hrpT       ~= nil then hrp.Transparency = orig.hrpT end
    end
    if head then
        if orig.headCollide ~= nil then head.CanCollide = orig.headCollide end
        if orig.headMass    ~= nil then head.Massless   = orig.headMass end
        if orig.headTouch   ~= nil then head.CanTouch   = orig.headTouch end
        if orig.headSize    then head.Size = orig.headSize end
        if orig.headT       ~= nil then head.Transparency = orig.headT end
    end
    _hitboxOriginal[char] = nil
    _hitboxApplied[char]  = nil
end

local function restoreAllHitboxes()
    for char in pairs(_hitboxOriginal) do restoreHitbox(char) end
end

local function reapplyAllHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then applyHitbox(p.Character) end
    end
end

local function invalidateHitboxSizeCache()
    for _, c in pairs(_hitboxApplied) do c.hrpSize = nil; c.headSize = nil end
end

local function invalidateHitboxTransparencyCache()
    for _, c in pairs(_hitboxApplied) do c.hrpT = nil; c.headT = nil end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if CFG.HitboxExpander then applyHitbox(char) end
    end)
end)

-- ============================================================================
-- ESP SYSTEM
-- ============================================================================
local pESP = {}
local tESP = {}

local function clearESP(plr)
    if pESP[plr] then pcall(function() pESP[plr]:Destroy() end); pESP[plr] = nil end
    if tESP[plr] then pcall(function() tESP[plr]:Destroy() end); tESP[plr] = nil end
    _espCache[plr] = nil
end

local function refreshCharRefs(ec, char)
    ec.char = char
    ec.hrp = char:FindFirstChild("HumanoidRootPart")
    ec.head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    ec.hum = char:FindFirstChild("Humanoid")
end

local function updateHighlights()
    if not CFG.PlayerESP or not CFG.ChamsESP then
        for plr in pairs(pESP) do
            if pESP[plr] then pESP[plr]:Destroy(); pESP[plr] = nil end
        end
        return
    end
    local camPos = Camera.CFrame.Position
    local hlRange = CFG.MaxESP * 0.6
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or sameTeam(plr) then continue end
        local char = plr.Character
        if not char then
            if pESP[plr] then pESP[plr]:Destroy(); pESP[plr] = nil end
            continue
        end
        local ec = _espCache[plr]
        -- FIX: re-scan si falta CUALQUIER parte, no solo si cambió el char
        if not ec or ec.char ~= char or not ec.hrp or not ec.hrp.Parent or not ec.hum or not ec.hum.Parent then
            if not ec then ec = {}; _espCache[plr] = ec end
            refreshCharRefs(ec, char)
        end
        local hrp, hum = ec.hrp, ec.hum
        if not (hrp and hum) or hum.Health <= 0 then
            if pESP[plr] then pESP[plr]:Destroy(); pESP[plr] = nil end
            continue
        end
        local dist = (camPos - hrp.Position).Magnitude
        if dist > hlRange then
            if pESP[plr] then pESP[plr]:Destroy(); pESP[plr] = nil; ec.fillColor = nil; ec.outlineColor = nil end
            continue
        end
        if not pESP[plr] or not pESP[plr].Parent then
            local hl = Instance.new("Highlight")
            hl.Name = "BSS_HL"; hl.FillTransparency = 0.4; hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char; hl.Parent = char
            pESP[plr] = hl
            ec.fillColor = nil; ec.outlineColor = nil
        end
        local hpR = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local fillCol = hpR > 0.6 and C.hp or hpR > 0.3 and Color3.fromRGB(240,200,80) or C.danger
        if ec.fillColor ~= fillCol then pESP[plr].FillColor = fillCol; ec.fillColor = fillCol end
        if not ec.outlineColor then
            local weapEntry = CFG.WeaponESP and getEquippedWeapon(plr) or nil
            local outlineCol = weapEntry and weapEntry.color or Color3.fromRGB(0,0,0)
            pESP[plr].OutlineColor = outlineCol; ec.outlineColor = outlineCol
        end
    end
    for plr in pairs(pESP) do if not plr.Parent then clearESP(plr) end end
end

local function updateBillboards()
    if not CFG.PlayerESP or not (CFG.NameESP or CFG.HealthESP or CFG.WeaponESP) then
        for plr in pairs(tESP) do
            if tESP[plr] then tESP[plr]:Destroy(); tESP[plr] = nil end
        end
        return
    end
    local camPos = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or sameTeam(plr) then continue end
        local char = plr.Character
        if not char then
            if tESP[plr] then tESP[plr]:Destroy(); tESP[plr] = nil end
            continue
        end
        local ec = _espCache[plr]
        -- FIX: re-scan si falta CUALQUIER parte
        if not ec or ec.char ~= char or not ec.hrp or not ec.hrp.Parent or not ec.head or not ec.head.Parent or not ec.hum or not ec.hum.Parent then
            if not ec then ec = {}; _espCache[plr] = ec end
            refreshCharRefs(ec, char)
        end
        local hrp, head, hum = ec.hrp, ec.head, ec.hum
        if not (hrp and head and hum) or hum.Health <= 0 then
            if tESP[plr] then tESP[plr]:Destroy(); tESP[plr] = nil end
            continue
        end
        local dist = (camPos - hrp.Position).Magnitude
        if dist > CFG.MaxESP then
            if tESP[plr] then tESP[plr]:Destroy(); tESP[plr] = nil end
            continue
        end

        local weapEntry, weapTexture = nil, ""
        if CFG.WeaponESP then weapEntry, weapTexture = getEquippedWeapon(plr) end

        if not tESP[plr] or not tESP[plr].Parent then
            local bb = Instance.new("BillboardGui")
            bb.Name = "BSS_TXT"; bb.AlwaysOnTop = true
            bb.Adornee = head; bb.Parent = head

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name = "Name"; nameLbl.BackgroundTransparency = 1
            nameLbl.Size = UDim2.new(1, 0, 0, 16); nameLbl.Position = UDim2.new(0, 0, 0, 0)
            nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 14
            nameLbl.TextColor3 = Color3.new(1,1,1); nameLbl.TextStrokeTransparency = 0.3
            nameLbl.Parent = bb

            local hpLbl = Instance.new("TextLabel")
            hpLbl.Name = "HP"; hpLbl.BackgroundTransparency = 1
            hpLbl.Size = UDim2.new(1, 0, 0, 14); hpLbl.Position = UDim2.new(0, 0, 0, 16)
            hpLbl.Font = Enum.Font.GothamBold; hpLbl.TextSize = 12
            hpLbl.TextColor3 = C.hp; hpLbl.TextStrokeTransparency = 0.3
            hpLbl.Parent = bb

            local weapFrame = Instance.new("Frame")
            weapFrame.Name = "WeapFrame"; weapFrame.BackgroundTransparency = 1
            weapFrame.Size = UDim2.new(1, 0, 0, 28); weapFrame.Position = UDim2.new(0, 0, 0, 30)
            weapFrame.Parent = bb

            local weapImg = Instance.new("ImageLabel")
            weapImg.Name = "WeapImg"; weapImg.BackgroundTransparency = 1
            weapImg.Size = UDim2.fromOffset(24, 24)
            weapImg.Position = UDim2.new(0, 0, 0, 2)
            weapImg.ScaleType = Enum.ScaleType.Fit
            weapImg.Image = ""; weapImg.ImageColor3 = Color3.new(1,1,1)
            weapImg.Parent = weapFrame

            local weapNameLbl = Instance.new("TextLabel")
            weapNameLbl.Name = "WeapName"; weapNameLbl.BackgroundTransparency = 1
            weapNameLbl.Size = UDim2.new(1, -28, 0, 24); weapNameLbl.Position = UDim2.new(0, 28, 0, 2)
            weapNameLbl.Font = Enum.Font.GothamBold; weapNameLbl.TextSize = 11
            weapNameLbl.TextColor3 = Color3.fromRGB(255,200,50)
            weapNameLbl.TextStrokeTransparency = 0.3
            weapNameLbl.TextXAlignment = Enum.TextXAlignment.Left
            weapNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            weapNameLbl.Text = ""; weapNameLbl.Parent = weapFrame

            tESP[plr] = bb
            ec.nameLbl = nameLbl; ec.hpLbl = hpLbl
            ec.weapFrame = weapFrame; ec.weapImg = weapImg; ec.weapNameLbl = weapNameLbl
            ec.distBucket = nil; ec.nameText = nil; ec.hpText = nil
            ec.hpColor = nil; ec.weapImgTex = nil; ec.weapImgColor = nil
            ec.weapText = nil; ec.weapTextColor = nil; ec.weapFrameVisible = nil
        end

        local bbg = tESP[plr]
        if ec.distBucket == nil or math.abs(ec.distBucket - dist) > 5 then
            local scale = math.clamp(dist / CFG.MaxESP, 0, 1)
            local sm = 1 + (scale * 1.5)
            bbg.Size = UDim2.fromOffset(160 * sm, 62 * sm)
            bbg.StudsOffsetWorldSpace = Vector3.new(0, 3 * sm, 0)
            ec.distBucket = dist
        end

        if ec.nameLbl then
            if ec.nameVisible ~= CFG.NameESP then ec.nameLbl.Visible = CFG.NameESP; ec.nameVisible = CFG.NameESP end
            if ec.nameText ~= plr.Name then ec.nameLbl.Text = plr.Name; ec.nameText = plr.Name end
        end

        if ec.hpLbl then
            if ec.hpVisible ~= CFG.HealthESP then ec.hpLbl.Visible = CFG.HealthESP; ec.hpVisible = CFG.HealthESP end
            local hpText = string.format("%d HP", math.floor(hum.Health))
            if ec.hpText ~= hpText then ec.hpLbl.Text = hpText; ec.hpText = hpText end
            local hpR = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local hpCol = hpR > 0.6 and C.hp or hpR > 0.3 and Color3.fromRGB(240,200,80) or C.danger
            if ec.hpColor ~= hpCol then ec.hpLbl.TextColor3 = hpCol; ec.hpColor = hpCol end
        end

        if ec.weapFrame then
            if CFG.WeaponESP and weapEntry then
                if ec.weapFrameVisible ~= true then ec.weapFrame.Visible = true; ec.weapFrameVisible = true end
                local tierTag = TIER_LABELS[weapEntry.tier] or "[?]"
                local wText = tierTag .. " " .. weapEntry.label
                local wColor = TIER_COLORS[weapEntry.tier] or Color3.fromRGB(200,200,200)
                if ec.weapImg then
                    if ec.weapImgTex ~= weapTexture then ec.weapImg.Image = weapTexture; ec.weapImgTex = weapTexture end
                    if ec.weapImgColor ~= weapEntry.color then ec.weapImg.ImageColor3 = weapEntry.color; ec.weapImgColor = weapEntry.color end
                    local wv = weapTexture ~= ""
                    if ec.weapImgVisible ~= wv then ec.weapImg.Visible = wv; ec.weapImgVisible = wv end
                end
                if ec.weapNameLbl then
                    if ec.weapText ~= wText then ec.weapNameLbl.Text = wText; ec.weapText = wText end
                    if ec.weapTextColor ~= wColor then ec.weapNameLbl.TextColor3 = wColor; ec.weapTextColor = wColor end
                    if ec.weapTextVisible ~= true then ec.weapNameLbl.Visible = true; ec.weapTextVisible = true end
                end
            else
                if ec.weapFrameVisible ~= false then ec.weapFrame.Visible = false; ec.weapFrameVisible = false end
            end
        end
    end
    for plr in pairs(tESP) do if not plr.Parent then clearESP(plr) end end
end

-- ============================================================================
-- PICKUP
-- ============================================================================
local lastPickup = 0
local function tryPickup()
    if not CFG.AutoPickup then return end
    local now = tick()
    if now - lastPickup < CFG.PickupDelay then return end
    if not _localHRP then return end
    local folder = getDroppedFolder()
    if not folder then return end
    local picked = false
    local hrpPos = _localHRP.Position
    for _, m in ipairs(folder:GetChildren()) do
        local part = m:FindFirstChild("PickUpZone") or m:FindFirstChild("CashPart") or m.PrimaryPart
        if not part then part = m:FindFirstChildWhichIsA("BasePart", true) end
        if not part then continue end
        local d = (hrpPos - part.Position).Magnitude
        if d < CFG.PickupRadius then
            local n = m.Name:lower()
            local ok = false
            if n:find("money") or n:find("cash") then ok = CFG.PickupMoney
            elseif n:find("taser") or n:find("gun") or n:find("ak") or n:find("pistol") then ok = CFG.PickupWeapons
            elseif n:find("food") or n:find("burger") or n:find("pizza") then ok = CFG.PickupFood
            elseif n:find("tool") or n:find("wrench") then ok = CFG.PickupTools
            else ok = true end
            if ok then
                pcall(function()
                    if m:IsA("Model") then m:PivotTo(CFrame.new(hrpPos))
                    elseif part:IsA("BasePart") then part.CFrame = CFrame.new(hrpPos) end
                end)
                picked = true; sessionPickups += 1
            end
        end
    end
    if picked then lastPickup = now end
end

-- ============================================================================
-- TRACK KILLS
-- ============================================================================
local function trackKills()
    local plrs = Players:GetPlayers()
    for i = 1, #plrs do
        local plr = plrs[i]
        if plr == LocalPlayer then continue end
        local char = plr.Character; local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            local last = lastHealthSnapshot[plr]; local cur = hum.Health
            if last and last > 0 and cur <= 0 then sessionKills += 1 end
            lastHealthSnapshot[plr] = cur
        end
    end
end

-- ============================================================================
-- UI LIBRARY
-- ============================================================================
local function new(c, p, ch)
    local i = Instance.new(c)
    for k, v in pairs(p or {}) do i[k] = v end
    for _, x in ipairs(ch or {}) do x.Parent = i end
    return i
end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function neonStroke(p, color) return new("UIStroke", { Color = color or C.accent, Thickness = 1.4, Parent = p }) end

local sg = new("ScreenGui", { Name = "BSS_Aim_Ultra", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = getParent() })
local W, H = 420, 550
local FONT_LABEL = 11; local FONT_SMALL = 10; local ROW_H = 34; local TAB_H = 30

local panel = new("Frame", { Size = UDim2.fromOffset(W, H), Position = UDim2.new(0.5, -W/2, 0.5, -H/2), BackgroundColor3 = C.bg, BackgroundTransparency = 0, BorderSizePixel = 0, Parent = sg })
corner(panel, 16); neonStroke(panel, C.border)

local header = new("Frame", { Size = UDim2.new(1, 0, 0, 44), Position = UDim2.new(0, 0, 0, 4), BackgroundColor3 = Color3.fromRGB(10, 10, 12), BorderSizePixel = 0, Parent = panel })
local logo = new("Frame", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(0, 12, 0.5, -15), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Parent = header })
corner(logo, 9); new("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 0.2, Parent = logo })
local logoIcon = Instance.new("ImageLabel"); logoIcon.Name = "Icon"; logoIcon.AnchorPoint = Vector2.new(0.5, 0.5); logoIcon.Position = UDim2.fromScale(0.5, 0.5)
logoIcon.Size = UDim2.fromScale(0.72, 0.72); logoIcon.BackgroundTransparency = 1; logoIcon.Image = ICON_SPLASH; logoIcon.ImageColor3 = Color3.fromRGB(10, 10, 12); logoIcon.ScaleType = Enum.ScaleType.Fit; logoIcon.Parent = logo

new("TextLabel", { Size = UDim2.new(0, 220, 0, 16), Position = UDim2.new(0, 52, 0, 5), BackgroundTransparency = 1, Text = "BSS-AIM ULTRA", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
new("TextLabel", { Size = UDim2.new(0, 220, 0, 12), Position = UDim2.new(0, 52, 0, 21), BackgroundTransparency = 1, Text = (IS_PC and "PC tryhard" or "Mobile") .. "  ·  v12.4", TextColor3 = C.accent, TextSize = 9, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })

local function iconBtn(txt, xOff)
    local b = new("TextButton", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, xOff, 0.5, -15), BackgroundColor3 = C.bg3, BorderSizePixel = 0, Text = txt, TextColor3 = C.accent, TextSize = 16, Font = Enum.Font.GothamBold, AutoButtonColor = false, Active = true, Parent = header, ZIndex = 2 })
    corner(b, 9); neonStroke(b, C.border); return b
end
local minBtn = iconBtn("-", -76); local closeBtn = iconBtn("x", -40)

local tabsFrame = new("Frame", { Size = UDim2.new(1, -24, 0, TAB_H), Position = UDim2.new(0, 12, 0, 56), BackgroundColor3 = C.bg2, BorderSizePixel = 0, Parent = panel })
corner(tabsFrame, 10); neonStroke(tabsFrame, C.border)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabsFrame })

local content = new("Frame", { Size = UDim2.new(1, -24, 1, -140), Position = UDim2.new(0, 12, 0, 94), BackgroundTransparency = 1, Parent = panel })
local pages = {}; local tabBtns = {}
local tabUnderline = new("Frame", { Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0, 0, 1, -3), BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = tabsFrame })
corner(tabUnderline, 2)

local function selectTab(name)
    for k, p in pairs(pages) do p.Visible = (k == name) end
    for k, b in pairs(tabBtns) do TweenService:Create(b, TweenInfo.new(0.15), { TextColor3 = (k == name) and C.accent or C.muted }):Play() end
    local active = tabBtns[name]
    if active then
        TweenService:Create(tabUnderline, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, active.AbsolutePosition.X - tabsFrame.AbsolutePosition.X, 1, -3),
            Size = UDim2.new(0, active.AbsoluteSize.X, 0, 2)
        }):Play()
    end
end

for i, tname in ipairs({"AIM", "ESP", "HITBOX", "PICKUP", "HUD", "SAFE"}) do
    local btn = new("TextButton", { Size = UDim2.new(1/6, 0, 1, 0), BackgroundTransparency = 1, Text = tname, TextColor3 = C.muted, TextSize = FONT_SMALL, Font = Enum.Font.GothamBold, AutoButtonColor = false, Active = true, LayoutOrder = i, Parent = tabsFrame })
    tabBtns[tname] = btn
    btn.MouseButton1Click:Connect(function() selectTab(tname) end)
    local page = new("ScrollingFrame", { Name = tname .. "_Page", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = content })
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    new("UIPadding", { PaddingTop = UDim.new(0, 0), PaddingBottom = UDim.new(0, 0), PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 6), Parent = page })
    pages[tname] = page
end

local order = 0
local function nextOrder() order = order + 1; return order end
local function section(page, label)
    local wrap = new("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = page })
    local bar = new("Frame", { Size = UDim2.new(0, 3, 0, 14), Position = UDim2.new(0, 0, 0.5, -7), BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = wrap })
    corner(bar, 2)
    new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 11, 0, 0), Size = UDim2.new(1, -11, 1, 0), Font = Enum.Font.GothamBold, Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL, TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap })
end

local function toggle(page, label, key, onChange)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, ROW_H), BackgroundColor3 = C.bg2, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page })
    corner(row, 9); local rowStroke = neonStroke(row, C.border)
    new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), Font = Enum.Font.GothamMedium, Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local track = new("Frame", { Size = UDim2.fromOffset(38, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = C.bg4, BorderSizePixel = 0, Parent = row })
    corner(track, 10); local knob = new("Frame", { Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = C.fg, BorderSizePixel = 0, Parent = track })
    corner(knob, 7)
    local function render(anim)
        local on = CFG[key]; local x = on and (38-14-3) or 3; local col = on and C.accent or C.bg4
        if anim then
            TweenService:Create(track, TweenInfo.new(0.18), { BackgroundColor3 = col }):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), { Position = UDim2.new(0, x, 0.5, -7) }):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.18), { Color = on and C.accent or C.border }):Play()
        else track.BackgroundColor3 = col; knob.Position = UDim2.new(0, x, 0.5, -7); rowStroke.Color = on and C.accent or C.border end
    end
    local btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Active = true, Parent = row })
    btn.MouseButton1Click:Connect(function() CFG[key] = not CFG[key]; render(true); scheduleSave(); if onChange then onChange(CFG[key]) end end)
    render(false)
end

local function slider(page, label, key, minV, maxV, isFloat, onChange)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = C.bg2, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page })
    corner(row, 9); neonStroke(row, C.border)
    new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -76, 0, 13), Font = Enum.Font.GothamMedium, Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local valLbl = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(1, -76, 0, 6), Size = UDim2.new(0, 64, 0, 13), Font = Enum.Font.GothamBold, Text = "", TextColor3 = C.accent, TextSize = FONT_LABEL, TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
    local track = new("Frame", { Size = UDim2.new(1, -24, 0, 5), Position = UDim2.new(0, 12, 1, -16), BackgroundColor3 = C.bg4, BorderSizePixel = 0, Parent = row })
    corner(track, 3); local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = track })
    corner(fill, 3); local knob = new("Frame", { Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 0, 0.5, -6), BackgroundColor3 = C.fg, BorderSizePixel = 0, Parent = track })
    corner(knob, 6)
    local function render()
        local v = CFG[key]; local a = math.clamp((v-minV)/(maxV-minV), 0, 1)
        fill.Size = UDim2.new(a,0,1,0); knob.Position = UDim2.new(a,-6,0.5,-6)
        valLbl.Text = isFloat and string.format("%.2f",v) or tostring(math.floor(v))
    end
    local dragging = false
    local function setFromX(x)
        local tl = track.AbsolutePosition.X; local tw = track.AbsoluteSize.X; if tw <= 0 then return end
        local a = math.clamp((x-tl)/tw, 0, 1); local v = minV+(maxV-minV)*a
        if not isFloat then v = math.floor(v+0.5) end
        CFG[key] = v; render(); scheduleSave(); if onChange then onChange(v) end
    end
    local hit = new("TextButton", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Active = true, Parent = row })
    hit.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true; setFromX(inp.Position.X) end end)
    UserInputService.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then setFromX(inp.Position.X) end end)
    UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    render()
end

local function keybindRow(page, label, key)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.bg2, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page })
    corner(row, 9); neonStroke(row, C.border)
    new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -116, 1, 0), Font = Enum.Font.GothamMedium, Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local btn = new("TextButton", { Size = UDim2.fromOffset(96, 26), Position = UDim2.new(1, -104, 0.5, -13), BackgroundColor3 = C.bg3, BorderSizePixel = 0, Text = "", TextColor3 = C.accent, TextSize = FONT_SMALL, Font = Enum.Font.GothamBold, AutoButtonColor = false, Active = true, Parent = row })
    corner(btn, 7); neonStroke(btn, C.border)
    local capturing = false
    local function render()
        local cur = CFG[key]; local name = "?"
        if typeof(cur) == "EnumItem" then name = cur.Name end
        btn.Text = capturing and "..." or name; btn.TextColor3 = capturing and C.accent2 or C.accent
    end
    btn.MouseButton1Click:Connect(function() capturing = not capturing; render() end)
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or not capturing then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then CFG[key] = inp.KeyCode end
        capturing = false; render(); scheduleSave()
    end)
    render()
end

local function actionBtn(page, label, color, onClick)
    local b = new("TextButton", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = color or C.bg3, BorderSizePixel = 0, Font = Enum.Font.GothamBold, Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL, AutoButtonColor = false, Active = true, LayoutOrder = nextOrder(), Parent = page })
    corner(b, 9); neonStroke(b, color or C.border)
    b.MouseButton1Click:Connect(onClick)
end

-- ============================================================================
-- BODY PART SELECTOR
-- ============================================================================
local BODY_PARTS = {
    "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg",
}

local function bodyPartSelector(page)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, ROW_H), BackgroundColor3 = C.bg2, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page })
    corner(row, 9); neonStroke(row, C.border)
    new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.45, 0, 1, 0), Font = Enum.Font.GothamMedium, Text = "Parte objetivo", TextColor3 = C.fg, TextSize = FONT_LABEL, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local prevBtn = new("TextButton", { Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0.45, 0, 0.5, -12), BackgroundColor3 = C.bg3, BorderSizePixel = 0, Text = "<", TextColor3 = C.accent, TextSize = FONT_LABEL, Font = Enum.Font.GothamBold, AutoButtonColor = false, Active = true, Parent = row })
    corner(prevBtn, 6); neonStroke(prevBtn, C.border)
    local partLbl = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0.45, 28, 0, 0), Size = UDim2.new(0, 110, 1, 0), Font = Enum.Font.GothamBold, Text = CFG.TargetPart, TextColor3 = C.accent, TextSize = FONT_SMALL, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
    local nextBtn = new("TextButton", { Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -36, 0.5, -12), BackgroundColor3 = C.bg3, BorderSizePixel = 0, Text = ">", TextColor3 = C.accent, TextSize = FONT_LABEL, Font = Enum.Font.GothamBold, AutoButtonColor = false, Active = true, Parent = row })
    corner(nextBtn, 6); neonStroke(nextBtn, C.border)
    local function currentIdx() for i, v in ipairs(BODY_PARTS) do if v == CFG.TargetPart then return i end end; return 1 end
    local function setIdx(i)
        i = ((i-1) % #BODY_PARTS) + 1
        CFG.TargetPart = BODY_PARTS[i]; partLbl.Text = CFG.TargetPart; currentTarget = nil; scheduleSave()
    end
    prevBtn.MouseButton1Click:Connect(function() setIdx(currentIdx() - 1) end)
    nextBtn.MouseButton1Click:Connect(function() setIdx(currentIdx() + 1) end)
end

-- ============================================================================
-- PAGES POPULATE
-- ============================================================================
local aimPage = pages["AIM"]
section(aimPage, "AIMBOT")
toggle(aimPage, "Activar", "Enabled")
toggle(aimPage, "Camera lock", "CameraLock")
toggle(aimPage, "No Recoil (frena el arma)", "NoRecoil")
slider(aimPage, "FOV", "FOV", 30, 400, false, function(v) CFG.FOVRadius = v end)
slider(aimPage, "Dist. max", "MaxDistance", 100, 1500, false)
keybindRow(aimPage, "Apuntar (Hold)", "HoldKey")
section(aimPage, "FILTROS")
toggle(aimPage, "Wall check", "WallCheck")
if IS_PC then toggle(aimPage, "Silent aim", "SilentAim") end
section(aimPage, "OBJETIVO")
bodyPartSelector(aimPage)

local espPage = pages["ESP"]
section(espPage, "VISUAL")
toggle(espPage, "Activar ESP", "PlayerESP")
toggle(espPage, "Cuerpo iluminado", "ChamsESP")
toggle(espPage, "Nombre", "NameESP")
toggle(espPage, "Vida (HP)", "HealthESP")
toggle(espPage, "Arma equipada", "WeaponESP")
slider(espPage, "Rango ESP", "MaxESP", 50, 1500, false)

local hitboxPage = pages["HITBOX"]
section(hitboxPage, "EXPANDER")
toggle(hitboxPage, "Activar Hitbox", "HitboxExpander", function(v)
    if v then reapplyAllHitboxes() else restoreAllHitboxes() end
end)
slider(hitboxPage, "Tamaño", "HitboxSize", 2, 30, false, function(v)
    if CFG.HitboxExpander then invalidateHitboxSizeCache(); reapplyAllHitboxes() end
end)
slider(hitboxPage, "Transparencia", "HitboxTransparency", 0, 1, true, function(v)
    if CFG.HitboxExpander then invalidateHitboxTransparencyCache(); reapplyAllHitboxes() end
end)

local pickPage = pages["PICKUP"]
section(pickPage, "AUTO PICKUP")
toggle(pickPage, "Activar pickup", "AutoPickup")
slider(pickPage, "Radio", "PickupRadius", 5, 100, false)
slider(pickPage, "Delay", "PickupDelay", 0.02, 0.5, true)
section(pickPage, "CATEGORIAS")
toggle(pickPage, "Money", "PickupMoney")
toggle(pickPage, "Armas", "PickupWeapons")
toggle(pickPage, "Comida", "PickupFood")
toggle(pickPage, "Herramientas", "PickupTools")

local hudPage = pages["HUD"]
section(hudPage, "HUD")
toggle(hudPage, "Watermark", "HUDWatermark")
toggle(hudPage, "Stats (FPS/Ping)", "HUDFPS")
section(hudPage, "HIDE NAME")
toggle(hudPage, "Ocultar mi nombre", "HideName")
toggle(hudPage, "Ocultar leaderboard", "HideLeaderboard")

local safePage = pages["SAFE"]
section(safePage, "CONFIG")
actionBtn(safePage, "Cargar config RECOMENDADA", C.accent, function()
    local d = defaultCfg()
    for k, v in pairs(d) do CFG[k] = v end
    CFG.HoldKey = resolveKey("E", Enum.KeyCode.E)
    CFG.PanelKey = resolveKey("L", Enum.KeyCode.L)
    CFG.CloseKey = resolveKey("M", Enum.KeyCode.M)
    saveConfigTo(CONFIG_FILE, CFG)
    notify("Config", "Recomendada cargada", 4)
end)
section(safePage, "PANEL")
keybindRow(safePage, "Abrir Panel", "PanelKey")
keybindRow(safePage, "Cerrar Panel", "CloseKey")
actionBtn(safePage, "Reiniciar script", C.danger, function()
    uninstallSilentHook()
    _scriptActive = false
    pcall(function() if originalDisplayName then LocalPlayer.DisplayName = originalDisplayName end end)
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
    restoreAllHitboxes()
    espScreen:Destroy(); sg:Destroy()
    for plr in pairs(pESP) do clearESP(plr) end
    getgenv().BSS_Aim_Loaded = false
end)

selectTab("AIM")

-- ============================================================================
-- DRAG / MINIMIZE
-- ============================================================================
local function makeDrag(f, h)
    local d, s, p
    h.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; s = i.Position; p = f.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local dl = i.Position - s; f.Position = UDim2.new(p.X.Scale, p.X.Offset+dl.X, p.Y.Scale, p.Y.Offset+dl.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)
end
makeDrag(panel, header)

local miniBtn = new("TextButton", { Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0.5, -28, 0, 20), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0, Text = "", AutoButtonColor = false, Active = true, Visible = false, ZIndex = 200, Parent = sg })
corner(miniBtn, 28); neonStroke(miniBtn, Color3.fromRGB(255,255,255))
local miniIcon = Instance.new("ImageLabel"); miniIcon.AnchorPoint = Vector2.new(0.5,0.5); miniIcon.Position = UDim2.fromScale(0.5,0.5)
miniIcon.Size = UDim2.fromScale(0.72,0.72); miniIcon.BackgroundTransparency = 1
miniIcon.Image = ICON_SPLASH; miniIcon.ImageColor3 = Color3.fromRGB(10,10,12); miniIcon.ScaleType = Enum.ScaleType.Fit; miniIcon.Parent = miniBtn

miniBtn.MouseButton1Click:Connect(function()
    panel.Visible = true; panel.Size = UDim2.fromOffset(1,1); panel.Position = UDim2.new(0.5,-W/2,0.5,-H/2)
    TweenService:Create(panel, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(W,H) }):Play()
    miniBtn.Visible = false
end)

local function openPanel()
    if not panel.Visible then
        miniBtn.Visible = false; panel.Visible = true; panel.Size = UDim2.fromOffset(1,1); panel.Position = UDim2.new(0.5,-W/2,0.5,-H/2)
        TweenService:Create(panel, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(W,H) }):Play()
    end
end

local function closePanel()
    if panel.Visible then
        local tw = TweenService:Create(panel, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Size = UDim2.fromOffset(1,1) })
        tw:Play()
        tw.Completed:Connect(function()
            panel.Visible = false; panel.Size = UDim2.fromOffset(W,H)
            miniBtn.Visible = true; miniBtn.Size = UDim2.fromOffset(1,1)
            TweenService:Create(miniBtn, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(56,56) }):Play()
        end)
    end
end

minBtn.MouseButton1Click:Connect(closePanel)
closeBtn.MouseButton1Click:Connect(function()
    uninstallSilentHook()
    _scriptActive = false
    pcall(function() if originalDisplayName then LocalPlayer.DisplayName = originalDisplayName end end)
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
    restoreAllHitboxes()
    espScreen:Destroy(); sg:Destroy()
    for plr in pairs(pESP) do clearESP(plr) end
    getgenv().BSS_Aim_Loaded = false
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.PanelKey then openPanel() end
    if i.KeyCode == CFG.CloseKey then closePanel() end
end)

-- ============================================================================
-- HUD
-- ============================================================================
local hudScreen = Instance.new("ScreenGui")
hudScreen.Name = "BSS_HUD_Ultra"; hudScreen.ResetOnSpawn = false; hudScreen.IgnoreGuiInset = true; hudScreen.DisplayOrder = 95; hudScreen.Parent = getParent()

local watermark = Instance.new("Frame")
watermark.Size = UDim2.fromOffset(240,26); watermark.Position = UDim2.new(0,20,0,20)
watermark.BackgroundColor3 = C.bg; watermark.BackgroundTransparency = 0.25; watermark.BorderSizePixel = 0; watermark.ZIndex = 150; watermark.Parent = hudScreen
Instance.new("UICorner", watermark).CornerRadius = UDim.new(0,8)
local wmStroke = Instance.new("UIStroke"); wmStroke.Color = C.accent; wmStroke.Thickness = 1.2; wmStroke.Parent = watermark
local wmLabel = Instance.new("TextLabel")
wmLabel.Size = UDim2.new(1,-16,1,0); wmLabel.Position = UDim2.new(0,10,0,0); wmLabel.BackgroundTransparency = 1
wmLabel.Font = Enum.Font.GothamBold; wmLabel.TextSize = 12; wmLabel.TextColor3 = C.accent; wmLabel.TextXAlignment = Enum.TextXAlignment.Left
wmLabel.Text = "BSS-Aim Ultra v12.4"; wmLabel.Parent = watermark

local statsHUD = Instance.new("Frame")
statsHUD.Size = UDim2.fromOffset(180,90); statsHUD.Position = UDim2.new(1,-200,0,60)
statsHUD.BackgroundColor3 = C.bg; statsHUD.BackgroundTransparency = 0.25; statsHUD.BorderSizePixel = 0; statsHUD.ZIndex = 150; statsHUD.Parent = hudScreen
Instance.new("UICorner", statsHUD).CornerRadius = UDim.new(0,8)
local stStroke = Instance.new("UIStroke"); stStroke.Color = C.accent2; stStroke.Thickness = 1.2; stStroke.Parent = statsHUD
local stLabel = Instance.new("TextLabel")
stLabel.Size = UDim2.new(1,-16,1,-12); stLabel.Position = UDim2.new(0,10,0,6); stLabel.BackgroundTransparency = 1
stLabel.Font = Enum.Font.Code; stLabel.TextSize = 12; stLabel.TextColor3 = C.fg; stLabel.TextXAlignment = Enum.TextXAlignment.Left
stLabel.TextYAlignment = Enum.TextYAlignment.Top; stLabel.TextWrapped = true; stLabel.Text = ""; stLabel.Parent = statsHUD

local fpsCount = 0; local fpsTimer = tick(); local currentFPS = 60

-- ============================================================================
-- BACKGROUND LOOPS
-- ============================================================================
task.spawn(function()
    while _scriptActive do pcall(updateHighlights); task.wait(0.25) end
end)
task.spawn(function()
    while _scriptActive do pcall(updateBillboards); task.wait(CFG.ESPRefresh or 0.05) end
end)
task.spawn(function()
    while _scriptActive do pcall(tryPickup); task.wait(0.2) end
end)
task.spawn(function()
    while _scriptActive do pcall(trackKills); task.wait(0.25) end
end)
task.spawn(function()
    while _scriptActive do pcall(applyHideName); task.wait(1.5) end
end)
task.spawn(function()
    while _scriptActive do
        if CFG.HitboxExpander then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and not _hitboxOriginal[plr.Character] then
                    applyHitbox(plr.Character)
                end
            end
        end
        task.wait(1)
    end
end)

-- ============================================================================
-- TARGET SCAN
-- ============================================================================
local _lastScan = 0
RunService.Heartbeat:Connect(function()
    if not _scriptActive then return end

    -- FIX SWITCH: si el usuario mueve el mouse, rompe lock y no escanea
    manualAimOverride = (tick() - lastMouseMove) < 0.15
    if manualAimOverride then
        currentTarget = nil
        return
    end

    if not (CFG.Enabled and (aimOn or CFG.TriggerBot)) then
        currentTarget = nil
        return
    end
    local now = tick()
    local scanInterval = aimOn and 0.05 or 0.1
    if now - _lastScan < scanInterval then return end
    _lastScan = now

    local _, bestPart, bestScore = getTargetWithScore()

    if not bestPart then
        currentTarget = nil
        return
    end

    if targetDead() then
        currentTarget = bestPart
        lastSwitch = now
        return
    end

    if bestPart ~= currentTarget then
        local currentPx = targetPx()
        if (now - lastSwitch) > 0.05 and bestScore + 10 < currentPx then
            currentTarget = bestPart
            lastSwitch = now
        end
    end

    if currentTarget and targetPx() > CFG.FOVRadius * 1.1 then
        currentTarget = bestPart
        lastSwitch = now
    end
end)

-- ============================================================================
-- MAIN LOOP
-- ============================================================================
local _lastKills = -1; local _lastPickups = -1; local _lastMinutes = -1; local _lastFPS = -1

pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
RunService:BindToRenderStep("BSS_Aim_Ultra_Loop", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not _scriptActive then return end

    fpsCount += 1
    if tick() - fpsTimer >= 1 then currentFPS = fpsCount; fpsCount = 0; fpsTimer = tick() end

    local wantHook = CFG.SilentAim and aimOn and currentTarget and IS_PC and not manualAimOverride
    if wantHook and not silentHookInstalled then installSilentHook()
    elseif not wantHook and silentHookInstalled then uninstallSilentHook() end

    local aimActive = CFG.Enabled and aimOn
    local lockActive = aimActive and currentTarget and CFG.CameraLock and not manualAimOverride

    if CFG.DrawFOV and aimActive then
        local wantSize = UDim2.fromOffset(CFG.FOVRadius*2, CFG.FOVRadius*2)
        local wantColor = currentTarget and C.aimLock or C.accent
        if _uiCache.fovVisible ~= true then fovCircle.Visible = true; _uiCache.fovVisible = true end
        if _uiCache.fovSize ~= wantSize then fovCircle.Size = wantSize; _uiCache.fovSize = wantSize end
        if _uiCache.fovColor ~= wantColor then fovStroke.Color = wantColor; _uiCache.fovColor = wantColor end
    else
        if _uiCache.fovVisible ~= false then fovCircle.Visible = false; _uiCache.fovVisible = false end
    end

    if lockActive then
        local inCar = _localHum and _localHum.SeatPart ~= nil
        if inCar then
            enterCarAim(_localHum)
            local camPos = Camera.CFrame.Position
            local toTarget = currentTarget.Position - camPos
            if toTarget.Magnitude > 2 then
                local upVec = Vector3.new(0, 1, 0)
                if math.abs(upVec:Dot(toTarget.Unit)) > 0.97 then
                    upVec = Vector3.new(0, 0, 1)
                end
                Camera.CFrame = CFrame.lookAt(camPos, currentTarget.Position, upVec)
            end
        else
            if _carAimActive then exitCarAim() end
            if Camera.CameraType ~= Enum.CameraType.Scriptable then
                Camera.CameraType = Enum.CameraType.Scriptable
            end
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, currentTarget.Position)
        end
    else
        if _carAimActive then exitCarAim() end
        if _localHum and not _localHum.SeatPart and Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Custom
        end
        if CFG.NoRecoil and isFiring and savedShotRotation and _localHum and not _localHum.SeatPart then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * savedShotRotation
        end
    end

    if _uiCache.watermarkVisible ~= CFG.HUDWatermark then watermark.Visible = CFG.HUDWatermark; _uiCache.watermarkVisible = CFG.HUDWatermark end

    if CFG.HUDFPS then
        if _uiCache.statsVisible ~= true then statsHUD.Visible = true; _uiCache.statsVisible = true end
        local now = tick()
        local minutes = math.floor((now - sessionStart) / 60)
        if sessionKills ~= _lastKills or sessionPickups ~= _lastPickups or minutes ~= _lastMinutes or currentFPS ~= _lastFPS then
            _lastKills = sessionKills; _lastPickups = sessionPickups; _lastMinutes = minutes; _lastFPS = currentFPS
            stLabel.Text = string.format("Kills:    %d\nPickups:  %d\nSession:  %dm\nFPS:      %d", sessionKills, sessionPickups, minutes, currentFPS)
            statsHUD.Size = UDim2.fromOffset(180, 76)
        end
    else
        if _uiCache.statsVisible ~= false then statsHUD.Visible = false; _uiCache.statsVisible = false end
    end
end)

notify("BSS-Aim ULTRA v12.4", "Switch fluido + ESP fix", 6)
print("[BSS-Aim ULTRA v12.4] cargado — mouse override activo") 
