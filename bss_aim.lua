-- ============================================================================
-- BSS-Aim ULTRA v12.3
-- Mini botón fijo arriba, Car Aim arreglado, No Recoil, ESP HP + WEAPON ICON ESP
-- ============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

-- DECLARAMOS LOS SERVICIOS PRIMERO (Aquí estaba el error de 'nil')
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

pcall(function()
    if gethui then
        for _, v in ipairs(gethui():GetChildren()) do
            if v.Name:match("^BSS_") then v:Destroy() end
        end
    else
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, v in ipairs(pg:GetChildren()) do
                if v.Name:match("^BSS_") then v:Destroy() end
            end
        end
    end
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
end)

getgenv().BSS_Aim_Loaded = true

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_PC = not IS_MOBILE
local ICON_SPLASH = "rbxassetid://96190503453096"

-- ============================================================================
-- WEAPON DATABASE — BlockSpin, con TextureId fallback
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

-- escanea Backpack + Character, devuelve {entry, textureId} del arma de mayor tier
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
                    -- agarra TextureId directamente del Tool — BlockSpin lo setea en el objeto
                    bestTexture = (tool.TextureId and tool.TextureId ~= "") and tool.TextureId or (entry and entry.icon or "")
                end
            end
        end
    end
    scanParent(plr:FindFirstChild("Backpack"))
    scanParent(plr.Character)
    return best, bestTexture
end

-- ============================================================================
-- CONFIG & SAVE
-- ============================================================================
local CONFIG_FOLDER = "BSS_Aim_Ultra"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local HAVE_FILE_IO = (writefile and readfile and isfile and makefolder) and true or false
local CONFIG_VERSION = 13

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
    ESPRefresh = 0.1,
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
    while getgenv().BSS_Aim_Loaded do
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
    if gethui then local ok, r = pcall(gethui); if ok and r then return r end end
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

-- ============================================================================
-- HIDE NAME
-- ============================================================================
local originalDisplayName = nil
local function applyHideName()
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
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then table.insert(f, hum.SeatPart.Parent) end
    end
    rayP.FilterDescendantsInstances = f
end
refreshFilter()
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.4); refreshFilter()
    local hum = char:WaitForChild("Humanoid", 3)
    if hum then hum:GetPropertyChangedSignal("SeatPart"):Connect(function() task.wait(0.1); refreshFilter() end) end
end)

local function sameTeam(plr) if not CFG.TeamCheck then return false end; return plr.Team == LocalPlayer.Team end
local function alive(plr)
    local c = plr.Character; if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid"); return h and h.Health > 0
end
local function visible(target, char)
    if not CFG.WallCheck then return true end
    local o = Camera.CFrame.Position; local d = target.Position - o
    local hit = Workspace:Raycast(o, d, rayP); if not hit then return true end
    return hit.Instance and hit.Instance:IsDescendantOf(char)
end

local function getTargetWithScore()
    local candidates = {}; local center = Camera.ViewportSize * 0.5
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or sameTeam(plr) or not alive(plr) then continue end
        local char = plr.Character
        local part = char:FindFirstChild(CFG.TargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local wp = part.Position; local d3 = (Camera.CFrame.Position - wp).Magnitude
        if d3 > CFG.MaxDistance then continue end
        local sp, on = Camera:WorldToViewportPoint(wp); if not on then continue end
        local px = (Vector2.new(sp.X, sp.Y) - center).Magnitude; if px > CFG.FOVRadius then continue end
        local score = (CFG.Priority == "dist") and d3 or px
        table.insert(candidates, {plr = plr, part = part, score = score})
    end
    table.sort(candidates, function(a, b) return a.score < b.score end)
    for i = 1, math.min(3, #candidates) do
        local c = candidates[i]
        if not CFG.WallCheck or visible(c.part, c.plr.Character) then return c.plr, c.part, c.score end
    end
    return nil, nil, math.huge
end

local function targetDead()
    if not currentTarget or not currentTarget.Parent then return true end
    local char = currentTarget.Parent; local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    if (Camera.CFrame.Position - currentTarget.Position).Magnitude > CFG.MaxDistance then return true end
    return false
end
local function targetPx()
    if not currentTarget then return math.huge end
    local center = Camera.ViewportSize * 0.5; local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
    if not on then return math.huge end
    return (Vector2.new(sp.X, sp.Y) - center).Magnitude
end

-- ============================================================================
-- INPUT
-- ============================================================================
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
if IS_PC and CFG.SilentAim then
    local Mouse = LocalPlayer:GetMouse(); local mt = nil
    pcall(function() if getrawmetatable then mt = getrawmetatable(game) end end)
    if mt and newcclosure and setreadonly then
        local oldIndex = mt.__index; local oldNamecall = mt.__namecall
        pcall(function()
            setreadonly(mt, false)
            mt.__index = newcclosure(function(self, key)
                if self == Mouse and currentTarget and CFG.Enabled and aimOn then
                    if key == "Hit" then return CFrame.new(Camera.CFrame.Position, currentTarget.Position)
                    elseif key == "Target" then return currentTarget
                    elseif key == "UnitRay" then return Ray.new(Camera.CFrame.Position, currentTarget.Position - Camera.CFrame.Position) end
                end
                return oldIndex(self, key)
            end)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod and getnamecallmethod(); local args = {...}
                if method == "FireServer" and currentTarget and CFG.Enabled and aimOn then
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
end

-- ============================================================================
-- HITBOX EXPANDER
-- ============================================================================
local function applyHitbox(char)
    if not CFG.HitboxExpander then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if hrp then hrp.Size = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize); hrp.Transparency = CFG.HitboxTransparency; hrp.CanCollide = false; hrp.Massless = true end
    if head then head.Size = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize); head.Transparency = CFG.HitboxTransparency; head.CanCollide = false; head.Massless = true end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char) task.wait(0.5); applyHitbox(char) end)
end)

-- ============================================================================
-- ESP SYSTEM — Highlight + Name + HP + WEAPON ICON
-- ============================================================================
local pESP = {}
local tESP = {}

local function clearESP(plr)
    if pESP[plr] then pcall(function() pESP[plr]:Destroy() end); pESP[plr] = nil end
    if tESP[plr] then pcall(function() tESP[plr]:Destroy() end); tESP[plr] = nil end
end

local _playerCache = {}
local function updateESP()
    _playerCache = Players:GetPlayers()
    for _, plr in ipairs(_playerCache) do
        if plr == LocalPlayer or sameTeam(plr) or not alive(plr) then clearESP(plr); continue end
        local char = plr.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not (hrp and head and hum) then clearESP(plr); continue end

        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > CFG.MaxESP then clearESP(plr); continue end

        local weapEntry, weapTexture = nil, ""
        if CFG.WeaponESP then
            weapEntry, weapTexture = getEquippedWeapon(plr)
        end

        -- 1. Highlight
        if CFG.PlayerESP and CFG.ChamsESP then
            if not pESP[plr] or not pESP[plr].Parent then
                local hl = Instance.new("Highlight")
                hl.Name = "BSS_HL"; hl.FillTransparency = 0.4; hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = char; hl.Parent = char
                pESP[plr] = hl
            end
            local hpR = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            pESP[plr].FillColor = hpR > 0.6 and C.hp or hpR > 0.3 and Color3.fromRGB(240,200,80) or C.danger
            pESP[plr].OutlineColor = (CFG.WeaponESP and weapEntry) and weapEntry.color or Color3.fromRGB(0,0,0)
        else
            if pESP[plr] then pESP[plr]:Destroy(); pESP[plr] = nil end
        end

        -- 2. BillboardGui — Name + HP + Weapon Icon
        if CFG.PlayerESP and (CFG.NameESP or CFG.HealthESP or CFG.WeaponESP) then
            if not tESP[plr] or not tESP[plr].Parent then
                local bb = Instance.new("BillboardGui")
                bb.Name = "BSS_TXT"; bb.AlwaysOnTop = true
                bb.Adornee = head; bb.Parent = head

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Name = "Name"; nameLbl.BackgroundTransparency = 1
                nameLbl.Size = UDim2.new(1, 0, 0, 16); nameLbl.Position = UDim2.new(0, 0, 0, 0)
                nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 14
                nameLbl.TextColor3 = Color3.new(1,1,1); nameLbl.TextStrokeTransparency = 0
                nameLbl.Parent = bb

                local hpLbl = Instance.new("TextLabel")
                hpLbl.Name = "HP"; hpLbl.BackgroundTransparency = 1
                hpLbl.Size = UDim2.new(1, 0, 0, 14); hpLbl.Position = UDim2.new(0, 0, 0, 16)
                hpLbl.Font = Enum.Font.GothamBold; hpLbl.TextSize = 12
                hpLbl.TextColor3 = C.hp; hpLbl.TextStrokeTransparency = 0
                hpLbl.Parent = bb

                -- weapon row: icono a la izquierda + nombre a la derecha
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
                weapNameLbl.TextStrokeTransparency = 0
                weapNameLbl.TextXAlignment = Enum.TextXAlignment.Left
                weapNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                weapNameLbl.Text = ""; weapNameLbl.Parent = weapFrame

                tESP[plr] = bb
            end

            local bbg = tESP[plr]
            local scale = math.clamp(dist / CFG.MaxESP, 0, 1)
            local sm = 1 + (scale * 1.5)
            bbg.Size = UDim2.fromOffset(160 * sm, 62 * sm)
            bbg.StudsOffsetWorldSpace = Vector3.new(0, 3 * sm, 0)

            local nameLbl = bbg:FindFirstChild("Name")
            if nameLbl then nameLbl.Visible = CFG.NameESP; nameLbl.Text = plr.Name end

            local hpLbl = bbg:FindFirstChild("HP")
            if hpLbl then
                hpLbl.Visible = CFG.HealthESP
                hpLbl.Text = string.format("%d HP", math.floor(hum.Health))
                local hpR = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                hpLbl.TextColor3 = hpR > 0.6 and C.hp or hpR > 0.3 and Color3.fromRGB(240,200,80) or C.danger
            end

            local weapFrame = bbg:FindFirstChild("WeapFrame")
            if weapFrame then
                local weapImg = weapFrame:FindFirstChild("WeapImg")
                local weapNameLbl = weapFrame:FindFirstChild("WeapName")
                if CFG.WeaponESP and weapEntry then
                    weapFrame.Visible = true
                    local tierTag = TIER_LABELS[weapEntry.tier] or "[?]"
                    if weapImg then
                        weapImg.Image = weapTexture
                        weapImg.ImageColor3 = weapEntry.color
                        weapImg.Visible = weapTexture ~= ""
                    end
                    if weapNameLbl then
                        weapNameLbl.Text = tierTag .. " " .. weapEntry.label
                        weapNameLbl.TextColor3 = TIER_COLORS[weapEntry.tier] or Color3.fromRGB(200,200,200)
                        weapNameLbl.Visible = true
                    end
                else
                    weapFrame.Visible = false
                end
            end
        else
            if tESP[plr] then tESP[plr]:Destroy(); tESP[plr] = nil end
        end
    end
    for plr, _ in pairs(pESP) do if not plr.Parent or not alive(plr) then clearESP(plr) end end
end

-- ============================================================================
-- PICKUP
-- ============================================================================
local lastPickup = 0
local function tryPickup()
    if not CFG.AutoPickup then return end
    local now = tick()
    if now - lastPickup < CFG.PickupDelay then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local folder = Workspace:FindFirstChild("DroppedItems")
    if not folder then return end
    local picked = false
    for _, m in ipairs(folder:GetChildren()) do
        local part = m:FindFirstChild("PickUpZone") or m:FindFirstChild("CashPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
        if not part then continue end
        local d = (hrp.Position - part.Position).Magnitude
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
                    if m:IsA("Model") then m:PivotTo(CFrame.new(hrp.Position))
                    elseif part:IsA("BasePart") then part.CFrame = CFrame.new(hrp.Position) end
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
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
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
new("TextLabel", { Size = UDim2.new(0, 220, 0, 12), Position = UDim2.new(0, 52, 0, 21), BackgroundTransparency = 1, Text = (IS_PC and "PC tryhard" or "Mobile") .. "  ·  v12.3", TextColor3 = C.accent, TextSize = 9, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })

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
toggle(hitboxPage, "Activar Hitbox", "HitboxExpander", function(v) if v then for _,p in ipairs(Players:GetPlayers()) do if p.Character then applyHitbox(p.Character) end end end end)
slider(hitboxPage, "Tamaño", "HitboxSize", 2, 30, false, function(v) if CFG.HitboxExpander then for _,p in ipairs(Players:GetPlayers()) do if p.Character then applyHitbox(p.Character) end end end end)
slider(hitboxPage, "Transparencia", "HitboxTransparency", 0, 1, true)

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
    pcall(function() if originalDisplayName then LocalPlayer.DisplayName = originalDisplayName end end)
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
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
    pcall(function() if originalDisplayName then LocalPlayer.DisplayName = originalDisplayName end end)
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
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
wmLabel.Text = "BSS-Aim Ultra"; wmLabel.Parent = watermark

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
    while getgenv().BSS_Aim_Loaded do pcall(updateESP); task.wait(CFG.ESPRefresh or 0.1) end
end)
task.spawn(function()
    while getgenv().BSS_Aim_Loaded do pcall(tryPickup); pcall(trackKills); task.wait(0.2) end
end)
task.spawn(function()
    while getgenv().BSS_Aim_Loaded do pcall(applyHideName); task.wait(1.5) end
end)
task.spawn(function()
    while getgenv().BSS_Aim_Loaded do
        if CFG.HitboxExpander then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then applyHitbox(plr.Character) end
            end
        end
        task.wait(1)
    end
end)

-- ============================================================================
-- MAIN LOOP
-- ============================================================================
local _lastKills = -1; local _lastPickups = -1; local _lastMinutes = -1; local _lastFPS = -1

pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
RunService:BindToRenderStep("BSS_Aim_Ultra_Loop", Enum.RenderPriority.Camera.Value + 1, function(dt)
    fpsCount += 1
    if tick() - fpsTimer >= 1 then currentFPS = fpsCount; fpsCount = 0; fpsTimer = tick() end
    local now = tick()

    if (aimOn or CFG.TriggerBot) and (now - lastTargetCheck) > 0.05 then
        lastTargetCheck = now
        local _, bestPart, bestScore = getTargetWithScore()
        if targetDead() then
            if bestPart then currentTarget = bestPart; lastSwitch = now else currentTarget = nil end
        elseif bestPart and bestPart ~= currentTarget then
            if bestScore + 40 < targetPx() and (now - lastSwitch) > 0.3 then currentTarget = bestPart; lastSwitch = now end
        end
        if currentTarget and targetPx() > CFG.FOVRadius * 1.2 then
            if bestPart then currentTarget = bestPart; lastSwitch = now else currentTarget = nil end
        end
    elseif not (aimOn or CFG.TriggerBot) then currentTarget = nil end

    if CFG.DrawFOV and CFG.Enabled and aimOn then
        fovCircle.Position = UDim2.fromScale(0.5, 0.5); fovCircle.Size = UDim2.fromOffset(CFG.FOVRadius*2, CFG.FOVRadius*2)
        fovStroke.Color = currentTarget and C.aimLock or C.accent; fovCircle.Visible = true
    else fovCircle.Visible = false end

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local inCar = hum and hum.SeatPart ~= nil

    if CFG.Enabled and aimOn and currentTarget and CFG.CameraLock then
        if inCar then
            if Camera.CameraType ~= Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Scriptable end
        else
            if Camera.CameraType == Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Custom end
        end
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, currentTarget.Position)
    else
        if Camera.CameraType == Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Custom end
        if CFG.NoRecoil and isFiring and savedShotRotation then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * savedShotRotation
        end
    end

    watermark.Visible = CFG.HUDWatermark

    if CFG.HUDFPS then
        statsHUD.Visible = true
        local minutes = math.floor((now - sessionStart) / 60)
        if sessionKills ~= _lastKills or sessionPickups ~= _lastPickups or minutes ~= _lastMinutes or currentFPS ~= _lastFPS then
            _lastKills = sessionKills; _lastPickups = sessionPickups; _lastMinutes = minutes; _lastFPS = currentFPS
            stLabel.Text = string.format("Kills:    %d\nPickups:  %d\nSession:  %dm\nFPS:      %d", sessionKills, sessionPickups, minutes, currentFPS)
            statsHUD.Size = UDim2.fromOffset(180, 76)
        end
    else statsHUD.Visible = false end
end)

notify("BSS-Aim ULTRA v12.3", "Car Fix, Mini Arriba, No Recoil, Weapon Icon ESP", 6)
print("[BSS-Aim ULTRA v12.3] cargado")
