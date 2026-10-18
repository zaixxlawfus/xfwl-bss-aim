-- ============================================================================
-- BSS-Aim ULTRA v15.4 — EL ORIGINAL + HARD LOCK
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
    ["M249"] = { tier=5, label="M249", color=Color3.fromRGB(255,50,50), icon="" },
    ["Anaconda"] = { tier=5, label="Anaconda", color=Color3.fromRGB(255,50,50), icon="" },
    ["RPG"] = { tier=4, label="RPG", color=Color3.fromRGB(255,140,0), icon="" },
    ["M16"] = { tier=4, label="M16", color=Color3.fromRGB(255,140,0), icon="" },
    ["AK47"] = { tier=4, label="AK47", color=Color3.fromRGB(255,140,0), icon="" },
    ["AK-47"] = { tier=4, label="AK47", color=Color3.fromRGB(255,140,0), icon="" },
    ["Remington"] = { tier=4, label="Remington", color=Color3.fromRGB(255,140,0), icon="" },
    ["MP5"] = { tier=4, label="MP5", color=Color3.fromRGB(255,140,0), icon="" },
    ["Crossbow"] = { tier=4, label="Crossbow", color=Color3.fromRGB(255,140,0), icon="" },
    ["Tactical Axe"] = { tier=4, label="Tac.Axe", color=Color3.fromRGB(255,140,0), icon="" },
    ["Tactical Shovel"] = { tier=4, label="Tac.Shovel", color=Color3.fromRGB(255,140,0), icon="" },
    ["Tactical Knife"] = { tier=4, label="Tac.Knife", color=Color3.fromRGB(255,140,0), icon="" },
    ["Firework Launcher"] = { tier=4, label="Firework", color=Color3.fromRGB(255,140,0), icon="" },
    ["M24"] = { tier=3, label="M24", color=Color3.fromRGB(160,80,255), icon="" },
    ["Draco"] = { tier=3, label="Draco", color=Color3.fromRGB(160,80,255), icon="" },
    ["Skorpion"] = { tier=3, label="Skorpion", color=Color3.fromRGB(160,80,255), icon="" },
    ["Double Barrel"] = { tier=3, label="Dbl.Barrel", color=Color3.fromRGB(160,80,255), icon="" },
    ["Barbed Baseball Bat"] = { tier=3, label="Barbed Bat", color=Color3.fromRGB(160,80,255), icon="" },
    ["Sledge Hammer"] = { tier=3, label="Sledge", color=Color3.fromRGB(160,80,255), icon="" },
    ["Combat Axe"] = { tier=3, label="Cmbt.Axe", color=Color3.fromRGB(160,80,255), icon="" },
    ["Machete"] = { tier=3, label="Machete", color=Color3.fromRGB(160,80,255), icon="" },
    ["Shovel"] = { tier=3, label="Shovel", color=Color3.fromRGB(160,80,255), icon="" },
    ["Brainrot Slapper"] = { tier=2, label="Brainrot", color=Color3.fromRGB(80,220,120), icon="" },
    ["Hunting Rifle"] = { tier=2, label="Hunt.Rifle", color=Color3.fromRGB(80,220,120), icon="" },
    ["Uzi"] = { tier=2, label="Uzi", color=Color3.fromRGB(80,220,120), icon="" },
    ["Sawnoff"] = { tier=2, label="Sawnoff", color=Color3.fromRGB(80,220,120), icon="" },
    ["P226"] = { tier=2, label="P226", color=Color3.fromRGB(80,220,120), icon="" },
    ["Glock"] = { tier=2, label="Glock", color=Color3.fromRGB(80,220,120), icon="" },
    ["Metal Baseball Bat"] = { tier=2, label="Metal Bat", color=Color3.fromRGB(80,220,120), icon="" },
    ["Wrench"] = { tier=2, label="Wrench", color=Color3.fromRGB(80,220,120), icon="" },
    ["Crowbar"] = { tier=2, label="Crowbar", color=Color3.fromRGB(80,220,120), icon="" },
    ["Axe"] = { tier=2, label="Axe", color=Color3.fromRGB(80,220,120), icon="" },
    ["Frying Pan"] = { tier=2, label="Pan", color=Color3.fromRGB(80,220,120), icon="" },
    ["Butcher Knife"] = { tier=2, label="Butcher", color=Color3.fromRGB(80,220,120), icon="" },
    ["Switchblade"] = { tier=2, label="Switchblade", color=Color3.fromRGB(80,220,120), icon="" },
    ["Baseball Bat"] = { tier=1, label="Baseball Bat", color=Color3.fromRGB(180,180,180), icon="" },
    ["G3"] = { tier=1, label="G3", color=Color3.fromRGB(180,180,180), icon="" },
    ["C9"] = { tier=1, label="C9", color=Color3.fromRGB(180,180,180), icon="" },
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
    local best, bestTier, bestTexture = nil, -1, ""
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
-- CONFIG & SAVE
-- ============================================================================
local CONFIG_FOLDER = "BSS_Aim_Ultra"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local HAVE_FILE_IO = (writefile and readfile and isfile and makefolder) and true or false
local CONFIG_VERSION = 21 -- Subido para forzar reset y agarrar el Hard Lock bueno

local function ensureFolder()
    if not HAVE_FILE_IO then return end
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
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
    NoRecoil = true,
    HitboxExpander = false,
    HitboxSize = 10,
    HitboxTransparency = 0.5,
    MaxESP = 400,
    ESPRefresh = 0.1,
    AutoPickup = true,
    PickupRadius = 50,
    PickupDelay = 0.1,
    PickupMoney = true,
    PickupWeapons = true,
    PickupFood = true,
    PickupTools = true,
    HUDWatermark = true,
    HUDFPS = true,
    AutoSaveEnabled = true,
    AutoSaveInterval = 10,
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
        if CFG[k] ~= nil then CFG[k] = v end
    end
else
    CFG.HoldKey = resolveKey("E", Enum.KeyCode.E)
    CFG.PanelKey = resolveKey("L", Enum.KeyCode.L)
    CFG.CloseKey = resolveKey("M", Enum.KeyCode.M)
    saveConfigTo(CONFIG_FILE, CFG)
end

getgenv().BSS_AimConfig = CFG

-- ============================================================================
-- TEMA
-- ============================================================================
local C = {
    bg = Color3.fromRGB(6, 6, 8), bg2 = Color3.fromRGB(12, 12, 16), bg3 = Color3.fromRGB(20, 20, 26), bg4 = Color3.fromRGB(32, 32, 40),
    accent = Color3.fromRGB(255, 255, 255), fg = Color3.fromRGB(245, 245, 250), muted = Color3.fromRGB(140, 140, 155), 
    danger = Color3.fromRGB(255, 70, 90), border = Color3.fromRGB(60, 60, 72),
    hp = Color3.fromRGB(80, 220, 120), aimOn = Color3.fromRGB(255, 80, 90), aimLock = Color3.fromRGB(255, 255, 255),
}

local TIER_COLORS = {
    [5] = Color3.fromRGB(255, 50, 50), [4] = Color3.fromRGB(255, 140, 0), [3] = Color3.fromRGB(160, 80, 255),
    [2] = Color3.fromRGB(80, 220, 120), [1] = Color3.fromRGB(180, 180, 180), [0] = Color3.fromRGB(120, 120, 120),
}
local TIER_LABELS = { [5]="[Ω]", [4]="[L]", [3]="[E]", [2]="[R]", [1]="[U]", [0]="[?]" }

local function getParent() return LocalPlayer:WaitForChild("PlayerGui") end
local function notify(title, text, dur) pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = dur or 4 }) end) end

-- ============================================================================
-- ESTADO
-- ============================================================================
local aimOn = false
local currentTarget = nil
local lastSwitch = 0
local sessionStart = tick()
local sessionKills = 0
local sessionPickups = 0
local lastHealthSnapshot = {}
local isFiring = false
local savedShotRotation = nil
local lastMouseMove = 0

local _localHum = nil
local function cacheLocalCharacter()
    local char = LocalPlayer.Character
    _localHum = char and char:FindFirstChild("Humanoid")
end
cacheLocalCharacter()
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    cacheLocalCharacter()
end)

local _vpCenter = Vector2.new(0, 0)
local function refreshVpCenter()
    local vp = Camera.ViewportSize
    _vpCenter = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
end
refreshVpCenter()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshVpCenter)

local _espCache = setmetatable({}, {__mode = "k"})
local _hitboxOriginal = setmetatable({}, {__mode = "k"})

-- ============================================================================
-- FOV CIRCLE
-- ============================================================================
local espScreen = Instance.new("ScreenGui")
espScreen.Name = "BSS_FOV"; espScreen.ResetOnSpawn = false; espScreen.IgnoreGuiInset = true; espScreen.DisplayOrder = 90; espScreen.Parent = getParent()

local fovCircle = Instance.new("Frame")
fovCircle.BackgroundTransparency = 1; fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.Size = UDim2.fromOffset(CFG.FOVRadius * 2, CFG.FOVRadius * 2); fovCircle.Visible = false; fovCircle.ZIndex = 100; fovCircle.Parent = espScreen
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke"); fovStroke.Color = C.accent; fovStroke.Thickness = 2; fovStroke.Parent = fovCircle

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
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.4); refreshFilter() end)

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
        if input.Delta.Magnitude > 0.5 then lastMouseMove = tick() end
    end
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.HoldKey then aimOn = true end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.KeyCode == Enum.KeyCode.ButtonR2 then
        isFiring = true
        if CFG.NoRecoil and Camera.CameraType ~= Enum.CameraType.Scriptable then
            savedShotRotation = Camera.CFrame.Rotation
        end
    end
    if i.KeyCode == CFG.PanicKey then aimOn = false; CFG.Enabled = false; notify("PANIC", "OFF", 3) end
end)

UserInputService.InputEnded:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.HoldKey then aimOn = false end
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
local oldNamecall = mt and mt.__namecall

local function installSilentHook()
    if silentHookInstalled or not mt or not newcclosure or not setreadonly then return end
    silentHookInstalled = true
    pcall(function()
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            if getnamecallmethod() == "FireServer" and currentTarget then
                local args = {...}
                if #args >= 1 and typeof(args[1]) == "Vector3" then
                    local dir = (currentTarget.Position - Camera.CFrame.Position).Unit
                    args[1] = dir * (args[1].Magnitude > 0 and args[1].Magnitude or 1000)
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
        orig = { hrpSize=hrp and hrp.Size, hrpT=hrp and hrp.Transparency, hrpCollide=hrp and hrp.CanCollide, hrpMass=hrp and hrp.Massless, hrpTouch=hrp and hrp.CanTouch, headSize=head and head.Size, headT=head and head.Transparency, headCollide=head and head.CanCollide, headMass=head and head.Massless, headTouch=head and head.CanTouch }
        _hitboxOriginal[char] = orig
    end

    local wantSize = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize)
    local wantT = CFG.HitboxTransparency
    if hrp then
        hrp.CanCollide = false; hrp.Massless = true; hrp.CanTouch = false; hrp.Size = wantSize; hrp.Transparency = wantT
    end
    if head then
        head.CanCollide = false; head.Massless = true; head.CanTouch = false; head.Size = wantSize; head.Transparency = wantT
    end
end

local function restoreAllHitboxes()
    for char, orig in pairs(_hitboxOriginal) do
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if hrp then hrp.CanCollide=orig.hrpCollide; hrp.Massless=orig.hrpMass; hrp.CanTouch=orig.hrpTouch; hrp.Size=orig.hrpSize; hrp.Transparency=orig.hrpT end
        if head then head.CanCollide=orig.headCollide; head.Massless=orig.headMass; head.CanTouch=orig.headTouch; head.Size=orig.headSize; head.Transparency=orig.headT end
        _hitboxOriginal[char] = nil
    end
end

local function reapplyAllHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then applyHitbox(p.Character) end end
end

-- ============================================================================
-- ESP SYSTEM (HIGHLIGHT)
-- ============================================================================
local pESP = {}
local tESP = {}
local _cachedColors = setmetatable({}, {__mode="k"})

local function clearESP(plr)
    if pESP[plr] then pcall(function() pESP[plr]:Destroy() end); pESP[plr] = nil end
    if tESP[plr] then pcall(function() tESP[plr]:Destroy() end); tESP[plr] = nil end
    _espCache[plr] = nil
end

local function updateHighlights()
    if not CFG.PlayerESP or not CFG.ChamsESP then
        for plr in pairs(pESP) do if pESP[plr] then pESP[plr]:Destroy(); pESP[plr] = nil end end
        return
    end
    local camPos = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or sameTeam(plr) then
            if pESP[plr] then pESP[plr]:Destroy(); pESP[plr] = nil end
            continue
        end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if not (hrp and hum) or hum.Health <= 0 or (camPos - hrp.Position).Magnitude > CFG.MaxESP then
            if pESP[plr] then pESP[plr]:Destroy(); pESP[plr] = nil end
            continue
        end
        if not pESP[plr] or not pESP[plr].Parent then
            local hl = Instance.new("Highlight")
            hl.Name = "BSS_HL"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char; hl.Parent = char
            pESP[plr] = hl
            _cachedColors[plr] = nil
        end
        local hpR = hum.Health / math.max(hum.MaxHealth, 1)
        local targetColor = hpR > 0.5 and C.hp or C.danger
        if _cachedColors[plr] ~= targetColor then
            pESP[plr].FillColor = targetColor
            _cachedColors[plr] = targetColor
        end
    end
end

-- ============================================================================
-- UI LIBRARY
-- ============================================================================
local function new(c, p, ch) local i = Instance.new(c); for k, v in pairs(p or {}) do i[k] = v end; for _, x in ipairs(ch or {}) do x.Parent = i end; return i end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function neonStroke(p, color) return new("UIStroke", { Color = color or C.accent, Thickness = 1.4, Parent = p }) end

local sg = new("ScreenGui", { Name = "BSS_Aim_Ultra", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = getParent() })
local W, H = 420, 550

local panel = new("Frame", { Size = UDim2.fromOffset(W, H), Position = UDim2.new(0.5, -W/2, 0.5, -H/2), BackgroundColor3 = C.bg, Parent = sg })
corner(panel, 16); neonStroke(panel, C.border)

local header = new("Frame", { Size = UDim2.new(1, 0, 0, 44), Position = UDim2.new(0, 0, 0, 4), BackgroundColor3 = C.bg3, Parent = panel })
corner(header, 9)
new("TextLabel", { Size = UDim2.new(0, 220, 0, 16), Position = UDim2.new(0, 16, 0, 14), BackgroundTransparency = 1, Text = "BSS-AIM ULTRA v15.4", TextColor3 = C.accent, TextSize = 14, Font = Enum.Font.GothamBold, Parent = header })

local minBtn = new("TextButton", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -76, 0.5, -15), BackgroundColor3 = C.bg4, Text = "-", TextColor3 = C.accent, TextSize = 16, Font = Enum.Font.GothamBold, Parent = header })
corner(minBtn, 9)
local closeBtn = new("TextButton", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -40, 0.5, -15), BackgroundColor3 = C.bg4, Text = "x", TextColor3 = C.accent, TextSize = 16, Font = Enum.Font.GothamBold, Parent = header })
corner(closeBtn, 9)

local tabsFrame = new("Frame", { Size = UDim2.new(1, -24, 0, 30), Position = UDim2.new(0, 12, 0, 56), BackgroundColor3 = C.bg2, Parent = panel })
corner(tabsFrame, 10); neonStroke(tabsFrame, C.border)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabsFrame })

local content = new("Frame", { Size = UDim2.new(1, -24, 1, -140), Position = UDim2.new(0, 12, 0, 94), BackgroundTransparency = 1, Parent = panel })
local pages, tabBtns = {}, {}

local function selectTab(name)
    for k, p in pairs(pages) do p.Visible = (k == name) end
    for k, b in pairs(tabBtns) do b.TextColor3 = (k == name) and C.accent or C.muted end
end

for i, tname in ipairs({"AIM", "ESP", "SAFE"}) do
    local btn = new("TextButton", { Size = UDim2.new(1/3, 0, 1, 0), BackgroundTransparency = 1, Text = tname, TextColor3 = C.muted, TextSize = 10, Font = Enum.Font.GothamBold, Parent = tabsFrame })
    tabBtns[tname] = btn
    btn.MouseButton1Click:Connect(function() selectTab(tname) end)
    local page = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 4, AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = content })
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    pages[tname] = page
end

local order = 0
local function nextOrder() order = order + 1; return order end
local function section(page, label)
    local wrap = new("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = page })
    new("Frame", { Size = UDim2.new(0, 3, 0, 14), Position = UDim2.new(0, 0, 0.5, -7), BackgroundColor3 = C.accent, Parent = wrap })
    new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 11, 0, 0), Size = UDim2.new(1, -11, 1, 0), Font = Enum.Font.GothamBold, Text = label, TextColor3 = C.fg, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap })
end

local function toggle(page, label, key, onChange)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.bg2, LayoutOrder = nextOrder(), Parent = page })
    corner(row, 9); neonStroke(row, C.border)
    new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), Font = Enum.Font.GothamMedium, Text = label, TextColor3 = C.fg, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local track = new("Frame", { Size = UDim2.fromOffset(38, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = CFG[key] and C.accent or C.bg4, Parent = row })
    corner(track, 10)
    local knob = new("Frame", { Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, CFG[key] and 21 or 3, 0.5, -7), BackgroundColor3 = C.fg, Parent = track })
    corner(knob, 7)
    local btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = row })
    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        track.BackgroundColor3 = CFG[key] and C.accent or C.bg4
        knob.Position = UDim2.new(0, CFG[key] and 21 or 3, 0.5, -7)
        if onChange then onChange(CFG[key]) end
    end)
end

local function slider(page, label, key, minV, maxV, isFloat, onChange)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = C.bg2, LayoutOrder = nextOrder(), Parent = page })
    corner(row, 9); neonStroke(row, C.border)
    new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -76, 0, 13), Font = Enum.Font.GothamMedium, Text = label, TextColor3 = C.fg, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local valLbl = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(1, -76, 0, 6), Size = UDim2.new(0, 64, 0, 13), Font = Enum.Font.GothamBold, Text = tostring(CFG[key]), TextColor3 = C.accent, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
    local track = new("Frame", { Size = UDim2.new(1, -24, 0, 5), Position = UDim2.new(0, 12, 1, -16), BackgroundColor3 = C.bg4, Parent = row })
    corner(track, 3)
    local fill = new("Frame", { Size = UDim2.new((CFG[key]-minV)/(maxV-minV), 0, 1, 0), BackgroundColor3 = C.accent, Parent = track })
    corner(fill, 3)
    local btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = row })
    local dragging = false
    local function update(x)
        local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = minV + (maxV - minV) * a
        if not isFloat then v = math.floor(v + 0.5) end
        CFG[key] = v
        fill.Size = UDim2.new(a, 0, 1, 0)
        valLbl.Text = isFloat and string.format("%.2f", v) or tostring(v)
        if onChange then onChange(v) end
    end
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; update(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

local aimPage = pages["AIM"]
section(aimPage, "AIMBOT")
toggle(aimPage, "Activar", "Enabled")
toggle(aimPage, "Camera lock (Pegado a la cabeza)", "CameraLock")
slider(aimPage, "FOV", "FOV", 30, 400, false, function(v) CFG.FOVRadius = v end)
toggle(aimPage, "Wall check", "WallCheck")
toggle(aimPage, "Silent aim", "SilentAim")
toggle(aimPage, "No Recoil", "NoRecoil")

local espPage = pages["ESP"]
section(espPage, "VISUAL")
toggle(espPage, "Activar ESP", "PlayerESP")
toggle(espPage, "Cuerpo iluminado (Chams)", "ChamsESP")
toggle(espPage, "Nombre", "NameESP")
toggle(espPage, "Arma", "WeaponESP")
slider(espPage, "Rango ESP", "MaxESP", 50, 1500, false)

local safePage = pages["SAFE"]
section(safePage, "PANEL")
new("TextButton", { Size = UDim2.new(1,0,0,34), BackgroundColor3 = C.bg3, Text = "Cerrar Script", TextColor3 = C.danger, Parent = safePage })
selectTab("AIM")

-- ============================================================================
-- DRAG / MINIMIZE / CLOSE
-- ============================================================================
local function makeDrag(f, h)
    local d, s, p
    h.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; s = i.Position; p = f.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local dl = i.Position - s; f.Position = UDim2.new(p.X.Scale, p.X.Offset+dl.X, p.Y.Scale, p.Y.Offset+dl.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)
end
makeDrag(panel, header)

local miniBtn = new("TextButton", { Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0.5, -28, 0, 20), BackgroundColor3 = Color3.fromRGB(255,255,255), Text = "", Visible = false, ZIndex = 200, Parent = sg })
corner(miniBtn, 28); neonStroke(miniBtn, Color3.fromRGB(255,255,255))
miniBtn.MouseButton1Click:Connect(function() panel.Visible = true; panel.Size = UDim2.fromOffset(W,H); miniBtn.Visible = false end)

local function openPanel() if not panel.Visible then panel.Visible = true; miniBtn.Visible = false end end
local function closePanel() if panel.Visible then panel.Visible = false; miniBtn.Visible = true end end

minBtn.MouseButton1Click:Connect(closePanel)
closeBtn.MouseButton1Click:Connect(function()
    uninstallSilentHook(); _scriptActive = false; restoreAllHitboxes(); espScreen:Destroy(); sg:Destroy()
    getgenv().BSS_Aim_Loaded = false
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.PanelKey then openPanel() end
    if i.KeyCode == CFG.CloseKey then closePanel() end
end)

-- ============================================================================
-- LOOPS
-- ============================================================================
task.spawn(function() while _scriptActive do pcall(updateHighlights); task.wait(0.15) end end)

local _lastScan = 0
RunService.Heartbeat:Connect(function()
    if not _scriptActive then return end
    if not (CFG.Enabled and aimOn) then currentTarget = nil; return end
    local now = tick()
    if now - _lastScan < 0.02 then return end
    _lastScan = now

    local _, bestPart, bestScore = getTargetWithScore()
    if not bestPart then currentTarget = nil; return end
    if targetDead() then currentTarget = bestPart; lastSwitch = now; return end

    if bestPart ~= currentTarget then
        if bestScore < targetPx() and (now - lastSwitch) > 0.05 then
            currentTarget = bestPart; lastSwitch = now
        end
    end
    if currentTarget and targetPx() > CFG.FOVRadius * 1.1 then
        currentTarget = bestPart; lastSwitch = now
    end
end)

-- ============================================================================
-- MAIN RENDER (HARD LOCK REAL)
-- ============================================================================
pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
RunService:BindToRenderStep("BSS_Aim_Ultra_Loop", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not _scriptActive then return end

    local wantHook = CFG.SilentAim and aimOn and currentTarget and IS_PC
    if wantHook and not silentHookInstalled then installSilentHook() elseif not wantHook and silentHookInstalled then uninstallSilentHook() end

    if CFG.DrawFOV and CFG.Enabled and aimOn then
        fovCircle.Size = UDim2.fromOffset(CFG.FOVRadius*2, CFG.FOVRadius*2); fovCircle.Visible = true
        fovStroke.Color = currentTarget and C.aimLock or C.accent
    else fovCircle.Visible = false end

    if CFG.Enabled and aimOn and currentTarget and CFG.CameraLock then
        -- PA' QUE SEA PEGADO DE VERDAD Y NO SE MUEVA
        if Camera.CameraType ~= Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Scriptable
        end
        -- CFrame.new con posicion de camara y lookAt al enemigo
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
    else
        if Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Custom
        end
        if CFG.NoRecoil and isFiring and savedShotRotation then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * savedShotRotation
        end
    end
end)

notify("BSS-Aim ULTRA v15.4", "El original + Hard Lock", 6)
print("[BSS-Aim ULTRA v15.4] cargado — Hard Lock")
