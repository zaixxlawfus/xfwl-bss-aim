-- ============================================================================
-- BSS-Aim ULTRA v11
-- La obra maestra definitiva de Ollie.
-- Aim 100% Sticky, Hitbox Expander, Tracers, Highlight ESP, Car Fix.
-- ============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================================================
-- LIMPIEZA DE INSTANCIAS PREVIAS
-- ============================================================================
pcall(function()
    if gethui then
        for _, v in ipairs(gethui():GetChildren()) do
            if v.Name:match("^BSS_") then v:Destroy() end
        end
    else
        local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, v in ipairs(pg:GetChildren()) do
                if v.Name:match("^BSS_") then v:Destroy() end
            end
        end
    end
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
end)

getgenv().BSS_Aim_Loaded = true

-- ============================================================================
-- SERVICIOS Y VARIABLES GLOBALES
-- ============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_PC = not IS_MOBILE
local ICON_SPLASH = "rbxassetid://96190503453096"

-- ============================================================================
-- SISTEMA DE GUARDADO (FILE IO)
-- ============================================================================
local CONFIG_FOLDER = "BSS_Aim_Ultra"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local HAVE_FILE_IO = (writefile and readfile and isfile and makefolder) and true or false
local CONFIG_VERSION = 11

local function ensureFolder()
    if not HAVE_FILE_IO then return end
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
        if not isfolder(CONFIG_FOLDER .. "/profiles") then
            makefolder(CONFIG_FOLDER .. "/profiles")
        end
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

-- ============================================================================
-- CONFIGURACIÓN POR DEFECTO
-- ============================================================================
local DEFAULTS = {
    ConfigVersion = CONFIG_VERSION,
    
    -- AIM
    Enabled = true,
    HoldKey = "E",
    ToggleKey = "RightShift",
    PanelKey = "F1",
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
    TriggerDelay = 0.05,
    Priority = "fov",
    IgnoreHighHP = false,
    IgnoreHPThreshold = 80,
    
    -- ESP
    PlayerESP = true,
    WeaponIconESP = true,
    ItemESP = true,
    NameESP = true,
    HealthESP = true,
    ChamsESP = true,
    HeadDotESP = false,
    SnaplineESP = false,
    ArmedOnlyESP = false,
    NameColorByHP = true,
    DistanceStuds = false,
    Tracers = true,
    MaxESP = 400,
    ESPRefresh = 0.1,
    ESPColor = {1, 1, 1},
    
    -- HITBOX
    HitboxExpander = false,
    HitboxSize = 10,
    HitboxTransparency = 0.5,
    
    -- PICKUP
    AutoPickup = true,
    PickupRadius = 50,
    PickupDelay = 0.1,
    PickupMoney = true,
    PickupWeapons = true,
    PickupFood = true,
    PickupTools = true,
    PickupWhitelist = "",
    PickupBlacklist = "",
    PickupNotify = false,
    
    -- HUD
    HUDWatermark = true,
    HUDStats = true,
    HUDFPS = true,
    HUDPing = true,
    TargetInfo = true,
    Notifications = true,
    PanelOpacity = 1.0,
    
    -- AUTO-SAVE
    AutoSaveEnabled = true,
    AutoSaveInterval = 10,
    
    -- HIDE NAME
    HideName = false,
    HideNameText = "...",
    HideLeaderboard = false,
}

local function defaultCfg()
    local c = {}
    for k, v in pairs(DEFAULTS) do
        if type(v) == "table" then
            c[k] = {unpack(v)}
        else
            c[k] = v
        end
    end
    return c
end

local function resolveKey(s, default)
    if typeof(s) == "EnumItem" then return s end
    if type(s) == "string" then
        if s:find("MouseButton") then
            local ok, e = pcall(function() return Enum.UserInputType[s] end)
            if ok and e then return e end
        else
            local ok, e = pcall(function() return Enum.KeyCode[s] end)
            if ok and e then return e end
        end
    end
    return default
end

local CFG = defaultCfg()
local saved = loadConfigFrom(CONFIG_FILE)

if saved and saved.ConfigVersion == CONFIG_VERSION then
    for k, v in pairs(saved) do
        if CFG[k] ~= nil or k == "ESPColor" then
            CFG[k] = v
        end
    end
else
    CFG.HoldKey = resolveKey("E", Enum.KeyCode.E)
    CFG.ToggleKey = resolveKey("RightShift", Enum.KeyCode.RightShift)
    CFG.PanelKey = resolveKey("F1", Enum.KeyCode.F1)
    CFG.PanicKey = resolveKey("Delete", Enum.KeyCode.Delete)
    saveConfigTo(CONFIG_FILE, CFG)
end

if type(CFG.ESPColor) == "table" then
    CFG.ESPColor = Color3.new(unpack(CFG.ESPColor))
end

CFG.FOVRadius = CFG.FOV
CFG.PanelOpacity = 1
getgenv().BSS_AimConfig = CFG

-- ============================================================================
-- AUTO-SAVE SYSTEM
-- ============================================================================
local dirtyFlag = false
local lastAutoSave = tick()

local function scheduleSave()
    dirtyFlag = true
end

local function doSave()
    if not HAVE_FILE_IO then return end
    if saveConfigTo(CONFIG_FILE, CFG) then
        dirtyFlag = false
        lastAutoSave = tick()
    end
end

task.spawn(function()
    while getgenv().BSS_Aim_Loaded do
        if CFG.AutoSaveEnabled and dirtyFlag and (tick() - lastAutoSave) >= (CFG.AutoSaveInterval or 10) then
            doSave()
        end
        task.wait(1)
    end
end)

-- ============================================================================
-- TEMA Y COLORES (NEÓN)
-- ============================================================================
local C = {
    bg       = Color3.fromRGB(6, 6, 8),
    bg2      = Color3.fromRGB(12, 12, 16),
    bg3      = Color3.fromRGB(20, 20, 26),
    bg4      = Color3.fromRGB(32, 32, 40),
    accent   = Color3.fromRGB(255, 255, 255),
    accent2  = Color3.fromRGB(220, 220, 230),
    accent3  = Color3.fromRGB(180, 180, 190),
    pink     = Color3.fromRGB(255, 255, 255),
    fg       = Color3.fromRGB(245, 245, 250),
    muted    = Color3.fromRGB(140, 140, 155),
    danger   = Color3.fromRGB(255, 70, 90),
    border   = Color3.fromRGB(60, 60, 72),
    money    = Color3.fromRGB(120, 240, 130),
    weapon   = Color3.fromRGB(255, 130, 130),
    tool     = Color3.fromRGB(120, 180, 255),
    food     = Color3.fromRGB(255, 200, 90),
    hp       = Color3.fromRGB(80, 220, 120),
    stamina  = Color3.fromRGB(255, 210, 60),
    aimOn    = Color3.fromRGB(255, 80, 90),
    aimLock  = Color3.fromRGB(255, 255, 255),
}

-- ============================================================================
-- UTILIDADES
-- ============================================================================
local function getParent()
    if gethui then
        local ok, r = pcall(gethui)
        if ok and r then return r end
    end
    local ok, pg = pcall(function() return LocalPlayer:WaitForChild("PlayerGui") end)
    if ok and pg then return pg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function notify(title, text, dur)
    if not CFG.Notifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = dur or 4
        })
    end)
end

-- ============================================================================
-- ESTADO DEL SCRIPT
-- ============================================================================
local aimOn = false
local currentTarget = nil
local lastSwitch = 0
local lastTargetCheck = 0
local aimBtn = nil
local sessionStart = tick()
local sessionKills = 0
local sessionPickups = 0
local lastHealthSnapshot = {}
local originalCameraType = Camera.CameraType
local hitmarkerTime = 0

-- ============================================================================
-- HIDE NAME SYSTEM
-- ============================================================================
local originalDisplayName = nil

local function applyHideName()
    pcall(function()
        if originalDisplayName == nil then
            originalDisplayName = LocalPlayer.DisplayName
        end
        if CFG.HideName then
            LocalPlayer.DisplayName = CFG.HideNameText or "..."
        else
            LocalPlayer.DisplayName = originalDisplayName
        end
    end)

    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not CFG.HideLeaderboard)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not CFG.HideName)
    end)

    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetChildren()) do
                if gui.Name == "Chat" or gui.Name == "Leaderboard" or gui.Name == "PlayerList" then
                    gui.Enabled = not CFG.HideName
                end
            end
        end
    end)
end

-- ============================================================================
-- FOV CIRCLE (UI)
-- ============================================================================
local espScreen = Instance.new("ScreenGui")
espScreen.Name = "BSS_FOV"
espScreen.ResetOnSpawn = false
espScreen.IgnoreGuiInset = true
espScreen.DisplayOrder = 90
espScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espScreen.Parent = getParent()

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOV"
fovCircle.BackgroundTransparency = 1
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.Size = UDim2.fromOffset(CFG.FOVRadius * 2, CFG.FOVRadius * 2)
fovCircle.Visible = false
fovCircle.ZIndex = 100
fovCircle.Parent = espScreen

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = C.accent
fovStroke.Thickness = 2
fovStroke.Parent = fovCircle

-- ============================================================================
-- DRAWING API (TRACERS, HEAD DOTS)
-- ============================================================================
local drawSnapline = nil
local drawHeadDot = nil

if IS_PC and Drawing then
    pcall(function()
        drawSnapline = Drawing.new("Line")
        drawSnapline.Thickness = 1
        drawSnapline.Color = C.accent
        drawSnapline.Transparency = 0.7
        drawSnapline.Visible = false
    end)

    pcall(function()
        drawHeadDot = Drawing.new("Circle")
        drawHeadDot.Thickness = 1
        drawHeadDot.NumSides = 12
        drawHeadDot.Radius = 5
        drawHeadDot.Filled = false
        drawHeadDot.Color = C.accent
        drawHeadDot.Visible = false
    end)
end

-- ============================================================================
-- MOBILE AIM BUTTON
-- ============================================================================
if IS_MOBILE then
    aimBtn = Instance.new("TextButton")
    aimBtn.Name = "AimBtn"
    aimBtn.Size = UDim2.fromOffset(90, 90)
    aimBtn.Position = UDim2.new(0, 20, 1, -210)
    aimBtn.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
    aimBtn.BackgroundTransparency = 0.2
    aimBtn.Text = "AIM"
    aimBtn.TextColor3 = C.accent
    aimBtn.TextSize = 22
    aimBtn.Font = Enum.Font.GothamBold
    aimBtn.AutoButtonColor = false
    aimBtn.Active = true
    aimBtn.Selectable = true
    aimBtn.ZIndex = 200
    aimBtn.Parent = espScreen

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = aimBtn

    local bs1 = Instance.new("UIStroke")
    bs1.Color = C.accent
    bs1.Thickness = 3
    bs1.Parent = aimBtn

    aimBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            aimOn = true
            bs1.Color = C.aimOn
            aimBtn.TextColor3 = C.aimOn
        end
    end)

    aimBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            aimOn = false
            bs1.Color = C.accent
            aimBtn.TextColor3 = C.accent
        end
    end)
end

-- ============================================================================
-- SISTEMA DE AIM (RAYCAST Y TARGETS)
-- ============================================================================
local rayP = RaycastParams.new()
rayP.FilterType = Enum.RaycastFilterType.Exclude

local function refreshFilter()
    local f = {Camera}
    if LocalPlayer.Character then
        table.insert(f, LocalPlayer.Character)
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then
            table.insert(f, hum.SeatPart.Parent)
        end
    end
    rayP.FilterDescendantsInstances = f
end
refreshFilter()

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    refreshFilter()
    local hum = char:WaitForChild("Humanoid", 3)
    if hum then
        hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
            task.wait(0.1)
            refreshFilter()
        end)
    end
end)

local function sameTeam(plr)
    if not CFG.TeamCheck then return false end
    if not plr.Team or not LocalPlayer.Team then return false end
    return plr.Team == LocalPlayer.Team
end

local function alive(plr)
    local c = plr.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function visible(target, char)
    if not CFG.WallCheck then return true end
    local o = Camera.CFrame.Position
    local d = target.Position - o
    local hit = Workspace:Raycast(o, d, rayP)
    if not hit then return true end
    return hit.Instance and hit.Instance:IsDescendantOf(char)
end

local function getTargetWithScore()
    local candidates = {}
    local center = Camera.ViewportSize * 0.5

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or sameTeam(plr) or not alive(plr) then continue end
        
        local char = plr.Character
        local part = char:FindFirstChild(CFG.TargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local wp = part.Position
        local d3 = (Camera.CFrame.Position - wp).Magnitude
        if d3 > CFG.MaxDistance then continue end

        local sp, on = Camera:WorldToViewportPoint(wp)
        if not on then continue end

        local px = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if px > CFG.FOVRadius then continue end

        local score = px
        if CFG.Priority == "dist" then
            score = d3
        elseif CFG.Priority == "weak" then
            local hum = char:FindFirstChildOfClass("Humanoid")
            score = hum and hum.Health or 100
        elseif CFG.Priority == "danger" then
            local wep = 0
            for _, c in ipairs(char:GetChildren()) do
                if c:IsA("Tool") then wep += 1 end
            end
            score = d3 - wep * 50
        end

        table.insert(candidates, {plr = plr, part = part, score = score})
    end

    table.sort(candidates, function(a, b) return a.score < b.score end)

    for i = 1, math.min(3, #candidates) do
        local c = candidates[i]
        if not CFG.WallCheck or visible(c.part, c.plr.Character) then
            return c.plr, c.part, c.score
        end
    end

    return nil, nil, math.huge
end

local function targetDead()
    if not currentTarget or not currentTarget.Parent then return true end
    local char = currentTarget.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    local d3 = (Camera.CFrame.Position - currentTarget.Position).Magnitude
    if d3 > CFG.MaxDistance then return true end
    return false
end

local function targetPx()
    if not currentTarget then return math.huge end
    local center = Camera.ViewportSize * 0.5
    local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
    if not on then return math.huge end
    return (Vector2.new(sp.X, sp.Y) - center).Magnitude
end

-- ============================================================================
-- INPUT Y CONTROLES
-- ============================================================================
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end

    -- Toggle aim en PC
    if i.KeyCode == CFG.HoldKey or i.UserInputType == CFG.HoldKey then
        aimOn = true
    end

    -- Panic Key
    if i.KeyCode == CFG.PanicKey then
        aimOn = false
        CFG.Enabled = false
        if drawSnapline then drawSnapline.Visible = false end
        if drawHeadDot then drawHeadDot.Visible = false end
        notify("PANIC", "Todo desactivado", 3)
    end
end)

UserInputService.InputEnded:Connect(function(i, gp)
    if gp then return end

    -- Soltar tecla
    if i.KeyCode == CFG.HoldKey or i.UserInputType == CFG.HoldKey then
        aimOn = false
    end
end)

-- ============================================================================
-- SILENT AIM (PC ONLY)
-- ============================================================================
if IS_PC and CFG.SilentAim then
    local Mouse = LocalPlayer:GetMouse()
    local mt = nil

    pcall(function()
        if getrawmetatable then
            mt = getrawmetatable(game)
        end
    end)

    if mt and newcclosure and setreadonly then
        local oldIndex = mt.__index
        local oldNamecall = mt.__namecall

        pcall(function()
            setreadonly(mt, false)

            mt.__index = newcclosure(function(self, key)
                if self == Mouse and currentTarget and CFG.Enabled and aimOn then
                    if key == "Hit" then
                        return CFrame.new(Camera.CFrame.Position, currentTarget.Position)
                    elseif key == "Target" then
                        return currentTarget
                    elseif key == "UnitRay" then
                        return Ray.new(Camera.CFrame.Position, currentTarget.Position - Camera.CFrame.Position)
                    end
                end
                return oldIndex(self, key)
            end)

            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod and getnamecallmethod()
                local args = {...}

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
    
    if hrp then
        hrp.Size = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize)
        hrp.Transparency = CFG.HitboxTransparency
        hrp.CanCollide = false
        hrp.Massless = true
    end

    if head then
        head.Size = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize)
        head.Transparency = CFG.HitboxTransparency
        head.CanCollide = false
        head.Massless = true
    end
end

local function applyHitboxAll()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if plr.Character then
            applyHitbox(plr.Character)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        applyHitbox(char)
    end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and plr.Character then
        applyHitbox(plr.Character)
    end
end

-- ============================================================================
-- HELPERS ESP (WEAPONS, STAMINA)
-- ============================================================================
local function getEquippedTool(plr)
    local c = plr.Character
    if not c then return nil end
    for _, x in ipairs(c:GetChildren()) do
        if x:IsA("Tool") then return x end
    end
    return nil
end

local function getToolIcon(tool)
    if not tool then return nil end
    local ok, tex = pcall(function() return tool.TextureId end)
    if ok and tex and type(tex) == "string" and tex ~= "" then
        return tex
    end
    return nil
end

local function hasWeapon(plr)
    local c = plr.Character
    if c then
        for _, x in ipairs(c:GetChildren()) do
            if x:IsA("Tool") then return true end
        end
    end
    return false
end

-- ============================================================================
-- HIGHLIGHT ESP SYSTEM (BODY ILLUMINATED)
-- ============================================================================
local chamsTable = {}

local function ensureChams(plr, char)
    local h = chamsTable[plr]
    if h and h.Parent then return h end

    local ok, hl = pcall(function()
        local x = Instance.new("Highlight")
        x.Name = "BSS_Chams"
        x.FillColor = CFG.ESPColor
        x.OutlineColor = Color3.fromRGB(0, 0, 0)
        x.FillTransparency = 0.3
        x.OutlineTransparency = 0
        x.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        x.Adornee = char
        x.Parent = char
        return x
    end)

    if ok and hl then
        chamsTable[plr] = hl
        return hl
    end
    return nil
end

local function clearChams(plr)
    local h = chamsTable[plr]
    if h then
        pcall(function() h:Destroy() end)
        chamsTable[plr] = nil
    end
end

-- ============================================================================
-- PICKUP SYSTEM
-- ============================================================================
local lastPickup = 0

local function canPickup(m)
    local n = m.Name:lower()
    local kind = "other"

    if n == "money" or n:find("cash") then
        kind = "money"
    elseif n:find("taser") or n:find("gun") or n:find("weapon") or n:find("ak") or n:find("pistol") or n:find("rifle") then
        kind = "weapon"
    elseif n:find("food") or n:find("burger") or n:find("pizza") or n:find("drink") then
        kind = "food"
    elseif n:find("tool") or n:find("wrench") or n:find("hammer") then
        kind = "tool"
    end

    if CFG.PickupWhitelist ~= "" then
        local found = false
        for token in CFG.PickupWhitelist:gmatch("[^,]+") do
            token = token:gsub("^%s+", ""):gsub("%s+$", ""):lower()
            if token ~= "" and n:find(token, 1, true) then
                found = true
                break
            end
        end
        if not found then return false end
    end

    if CFG.PickupBlacklist ~= "" then
        for token in CFG.PickupBlacklist:gmatch("[^,]+") do
            token = token:gsub("^%s+", ""):gsub("%s+$", ""):lower()
            if token ~= "" and n:find(token, 1, true) then
                return false
            end
        end
    end

    if kind == "money" and not CFG.PickupMoney then return false end
    if kind == "weapon" and not CFG.PickupWeapons then return false end
    if kind == "food" and not CFG.PickupFood then return false end
    if kind == "tool" and not CFG.PickupTools then return false end
    
    return true
end

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
        if d < CFG.PickupRadius and canPickup(m) then
            pcall(function()
                if m:IsA("Model") then
                    m:PivotTo(CFrame.new(hrp.Position))
                elseif part:IsA("BasePart") then
                    part.CFrame = CFrame.new(hrp.Position)
                end

                if firetouchinterest then
                    firetouchinterest(hrp, part, 0)
                    firetouchinterest(hrp, part, 1)
                end
            end)
            picked = true
            sessionPickups += 1
        end
    end

    if picked then lastPickup = now end
end

-- ============================================================================
-- TRACK KILLS SYSTEM
-- ============================================================================
local function trackKills()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local last = lastHealthSnapshot[plr]
            local cur = hum.Health
            if last and last > 0 and cur <= 0 then
                sessionKills += 1
            end
            lastHealthSnapshot[plr] = cur
        end
    end
end

-- ============================================================================
-- UI LIBRARY (PANEL)
-- ============================================================================
local function new(c, p, ch)
    local i = Instance.new(c)
    for k, v in pairs(p or {}) do i[k] = v end
    for _, x in ipairs(ch or {}) do x.Parent = i end
    return i
end

local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function pad(p, t, b, l, r) return new("UIPadding", { PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0), Parent = p }) end
local function neonStroke(p, color) return new("UIStroke", { Color = color or C.accent, Thickness = 1.4, Parent = p }) end

local sg = new("ScreenGui", {
    Name = "BSS_Aim_Ultra",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = getParent()
})

local W, H = 420, 550
local FONT_TITLE = 14
local FONT_LABEL = 11
local FONT_SMALL = 10
local ROW_H = 34
local TAB_H = 30

-- PANEL
local panel = new("Frame", {
    Size = UDim2.fromOffset(W, H),
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = C.bg,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    Parent = sg
})
corner(panel, 16)
neonStroke(panel, C.border)

-- GRADIENTE SUPERIOR
local grad = new("Frame", {
    Size = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
    Parent = panel
})
corner(grad, 16)
new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 180, 190)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }),
    Parent = grad
})

-- HEADER
local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 44),
    Position = UDim2.new(0, 0, 0, 4),
    BackgroundColor3 = Color3.fromRGB(10, 10, 12),
    BorderSizePixel = 0,
    Parent = panel
})

local logo = new("Frame", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(0, 12, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Parent = header
})
corner(logo, 9)
new("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 0.2, Parent = logo })

local logoIcon = Instance.new("ImageLabel")
logoIcon.Name = "Icon"
logoIcon.AnchorPoint = Vector2.new(0.5, 0.5)
logoIcon.Position = UDim2.fromScale(0.5, 0.5)
logoIcon.Size = UDim2.fromScale(0.72, 0.72)
logoIcon.BackgroundTransparency = 1
logoIcon.Image = ICON_SPLASH
logoIcon.ImageColor3 = Color3.fromRGB(10, 10, 12)
logoIcon.ScaleType = Enum.ScaleType.Fit
logoIcon.Parent = logo

new("TextLabel", {
    Size = UDim2.new(0, 220, 0, 16),
    Position = UDim2.new(0, 52, 0, 5),
    BackgroundTransparency = 1,
    Text = "BSS-AIM ULTRA",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = FONT_TITLE,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header
})

new("TextLabel", {
    Size = UDim2.new(0, 220, 0, 12),
    Position = UDim2.new(0, 52, 0, 21),
    BackgroundTransparency = 1,
    Text = (IS_PC and "PC tryhard" or "Mobile") .. "  ·  v11",
    TextColor3 = C.accent,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header
})

local function iconBtn(txt, xOff)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, xOff, 0.5, -15),
        BackgroundColor3 = C.bg3,
        BorderSizePixel = 0,
        Text = txt,
        TextColor3 = C.accent,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Active = true,
        Parent = header,
        ZIndex = 2
    })
    corner(b, 9)
    neonStroke(b, C.border)
    return b
end

local minBtn = iconBtn("-", -76)
local closeBtn = iconBtn("x", -40)

-- TABS
local tabsFrame = new("Frame", {
    Size = UDim2.new(1, -24, 0, TAB_H),
    Position = UDim2.new(0, 12, 0, 56),
    BackgroundColor3 = C.bg2,
    BorderSizePixel = 0,
    Parent = panel
})
corner(tabsFrame, 10)
neonStroke(tabsFrame, C.border)

new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = tabsFrame
})

local content = new("Frame", {
    Size = UDim2.new(1, -24, 1, -140),
    Position = UDim2.new(0, 12, 0, 94),
    BackgroundTransparency = 1,
    Parent = panel
})

local pages = {}
local tabBtns = {}

local tabUnderline = new("Frame", {
    Size = UDim2.new(0, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -3),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
    Parent = tabsFrame
})
corner(tabUnderline, 2)

local function selectTab(name)
    for k, p in pairs(pages) do
        p.Visible = (k == name)
    end

    for k, b in pairs(tabBtns) do
        local on = (k == name)
        TweenService:Create(b, TweenInfo.new(0.15), {
            TextColor3 = on and C.accent or C.muted
        }):Play()
    end

    local active = tabBtns[name]
    if active then
        TweenService:Create(tabUnderline, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, active.AbsolutePosition.X - tabsFrame.AbsolutePosition.X, 1, -3),
            Size = UDim2.new(0, active.AbsoluteSize.X, 0, 2)
        }):Play()
    end
end

local TAB_LIST = {"AIM", "ESP", "HITBOX", "PICKUP", "HUD", "SAFE"}

for i, tname in ipairs(TAB_LIST) do
    local btn = new("TextButton", {
        Size = UDim2.new(1/#TAB_LIST, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = tname,
        TextColor3 = C.muted,
        TextSize = FONT_SMALL,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Active = true,
        LayoutOrder = i,
        Parent = tabsFrame
    })
    tabBtns[tname] = btn
    btn.MouseButton1Click:Connect(function() selectTab(tname) end)

    local page = new("ScrollingFrame", {
        Name = tname .. "_Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = content
    })

    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page
    })
    pad(page, 0, 0, 0, 6)
    pages[tname] = page
end

local order = 0
local function nextOrder() order = order + 1; return order end

local function section(page, label)
    local wrap = new("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(),
        Parent = page
    })

    local bar = new("Frame", {
        Size = UDim2.new(0, 3, 0, 14),
        Position = UDim2.new(0, 0, 0.5, -7),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Parent = wrap
    })
    corner(bar, 2)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 11, 0, 0),
        Size = UDim2.new(1, -11, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = label,
        TextColor3 = C.fg,
        TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wrap
    })
end

local function toggle(page, label, key, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundColor3 = C.bg2,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
        Parent = page
    })
    corner(row, 9)
    local rowStroke = neonStroke(row, C.border)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = C.fg,
        TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    local track = new("Frame", {
        Size = UDim2.fromOffset(38, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Parent = row
    })
    corner(track, 10)

    local knob = new("Frame", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = C.fg,
        BorderSizePixel = 0,
        Parent = track
    })
    corner(knob, 7)

    local function render(anim)
        local on = CFG[key] and true or false
        local x = on and (38 - 14 - 3) or 3
        local col = on and C.accent or C.bg4
        local sCol = on and C.accent or C.border

        if anim then
            TweenService:Create(track, TweenInfo.new(0.18), { BackgroundColor3 = col }):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), { Position = UDim2.new(0, x, 0.5, -7) }):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.18), { Color = sCol }):Play()
        else
            track.BackgroundColor3 = col
            knob.Position = UDim2.new(0, x, 0.5, -7)
            rowStroke.Color = sCol
        end
    end

    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Active = true,
        Parent = row
    })

    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        render(true)
        scheduleSave()
        if onChange then onChange(CFG[key]) end
    end)
    
    render(false)
end

local function slider(page, label, key, minV, maxV, isFloat, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.bg2,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
        Parent = page
    })
    corner(row, 9)
    neonStroke(row, C.border)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -76, 0, 13),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = C.fg,
        TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    local valLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -76, 0, 6),
        Size = UDim2.new(0, 64, 0, 13),
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = C.accent,
        TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row
    })

    local track = new("Frame", {
        Size = UDim2.new(1, -24, 0, 5),
        Position = UDim2.new(0, 12, 1, -16),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Parent = row
    })
    corner(track, 3)

    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Parent = track
    })
    corner(fill, 3)

    local knob = new("Frame", {
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.new(0, 0, 0.5, -6),
        BackgroundColor3 = C.fg,
        BorderSizePixel = 0,
        Parent = track
    })
    corner(knob, 6)

    local function render()
        local v = CFG[key]
        local a = math.clamp((v - minV) / (maxV - minV), 0, 1)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, -6, 0.5, -6)
        valLbl.Text = isFloat and string.format("%.2f", v) or tostring(math.floor(v))
    end

    local dragging = false

    local function setFromX(x)
        local tl = track.AbsolutePosition.X
        local tw = track.AbsoluteSize.X
        if tw <= 0 then return end

        local a = math.clamp((x - tl) / tw, 0, 1)
        local v = minV + (maxV - minV) * a
        
        if not isFloat then
            v = math.floor(v + 0.5)
        end

        CFG[key] = v
        render()
        scheduleSave()
        
        if onChange then onChange(v) end
    end

    local hit = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Active = true,
        Parent = row
    })

    hit.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(inp.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            setFromX(inp.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    render()
end

local function keybindRow(page, label, key)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = C.bg2,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
        Parent = page
    })
    corner(row, 9)
    neonStroke(row, C.border)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -116, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = C.fg,
        TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    local btn = new("TextButton", {
        Size = UDim2.fromOffset(96, 26),
        Position = UDim2.new(1, -104, 0.5, -13),
        BackgroundColor3 = C.bg3,
        BorderSizePixel = 0,
        Text = "",
        TextColor3 = C.accent,
        TextSize = FONT_SMALL,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Active = true,
        Parent = row
    })
    corner(btn, 7)
    neonStroke(btn, C.border)

    local capturing = false

    local function render()
        local cur = CFG[key]
        local name = "?"
        if typeof(cur) == "EnumItem" then
            if cur.EnumType == Enum.KeyCode then
                name = cur.Name
            elseif cur.EnumType == Enum.UserInputType then
                name = cur.Name:gsub("MouseButton", "Mouse")
            end
        end
        btn.Text = capturing and "..." or name
        btn.TextColor3 = capturing and C.accent2 or C.accent
    end

    btn.MouseButton1Click:Connect(function()
        capturing = not capturing
        render()
    end)

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or not capturing then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            CFG[key] = inp.KeyCode
        elseif inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.MouseButton2 then
            CFG[key] = inp.UserInputType
        end
        capturing = false
        render()
        scheduleSave()
    end)

    render()
end

local function actionBtn(page, label, color, onClick)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = color or C.bg3,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = label,
        TextColor3 = C.fg,
        TextSize = FONT_LABEL,
        AutoButtonColor = false,
        Active = true,
        LayoutOrder = nextOrder(),
        Parent = page
    })
    corner(b, 9)
    neonStroke(b, color or C.border)

    local base = color or C.bg3

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = base:Lerp(Color3.new(1,1,1), 0.12)
        }):Play()
    end)

    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = base
        }):Play()
    end)

    b.MouseButton1Click:Connect(onClick)
end

-- ============================================================================
-- PÁGINA AIM
-- ============================================================================
local aimPage = pages["AIM"]

section(aimPage, "AIMBOT")
toggle(aimPage, "Activar", "Enabled")
toggle(aimPage, "Camera lock", "CameraLock")
slider(aimPage, "FOV", "FOV", 30, 400, false, function(v)
    CFG.FOVRadius = v
end)
slider(aimPage, "Dist. max", "MaxDistance", 100, 1500, false)
keybindRow(aimPage, "Apuntar (Hold)", "HoldKey")

section(aimPage, "FILTROS")
toggle(aimPage, "Wall check", "WallCheck")
toggle(aimPage, "Team check", "TeamCheck")

if IS_PC then
    section(aimPage, "PC SETTINGS")
    toggle(aimPage, "Silent aim (hook mouse)", "SilentAim")
end

-- ============================================================================
-- PÁGINA ESP
-- ============================================================================
local espPage = pages["ESP"]

section(espPage, "VISUAL")
toggle(espPage, "ESP jugadores", "PlayerESP")
toggle(espPage, "Cuerpo iluminado", "ChamsESP")
toggle(espPage, "Snapline al target", "SnaplineESP")
toggle(espPage, "Head dot", "HeadDotESP")

section(espPage, "ITEMS")
toggle(espPage, "Items dropeados", "ItemESP")

section(espPage, "CONFIG")
slider(espPage, "Rango ESP", "MaxESP", 50, 1000, false)
toggle(espPage, "Distancia en studs", "DistanceStuds")

-- ============================================================================
-- PÁGINA HITBOX
-- ============================================================================
local hitboxPage = pages["HITBOX"]

section(hitboxPage, "EXPANDER")
toggle(hitboxPage, "Activar Hitbox", "HitboxExpander", function(v)
    if v then
        applyHitboxAll()
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                if hrp then hrp.Size = Vector3.new(2, 2, 1) end
                if head then head.Size = Vector3.new(2, 1, 1) end
            end
        end
    end
end)
slider(hitboxPage, "Tamaño", "HitboxSize", 2, 30, false, function(v)
    if CFG.HitboxExpander then applyHitboxAll() end
end)
slider(hitboxPage, "Transparencia", "HitboxTransparency", 0, 1, true, function(v)
    if CFG.HitboxExpander then applyHitboxAll() end
end)

-- ============================================================================
-- PÁGINA PICKUP
-- ============================================================================
local pickPage = pages["PICKUP"]

section(pickPage, "AUTO PICKUP")
toggle(pickPage, "Activar pickup", "AutoPickup")
slider(pickPage, "Radio", "PickupRadius", 5, 100, false)
slider(pickPage, "Delay", "PickupDelay", 0.02, 0.5, true)

section(pickPage, "CATEGORIAS")
toggle(pickPage, "Money / Cash", "PickupMoney")
toggle(pickPage, "Armas", "PickupWeapons")
toggle(pickPage, "Comida", "PickupFood")
toggle(pickPage, "Herramientas", "PickupTools")

-- ============================================================================
-- PÁGINA HUD
-- ============================================================================
local hudPage = pages["HUD"]

section(hudPage, "HUD")
toggle(hudPage, "Watermark", "HUDWatermark")
toggle(hudPage, "FPS / Ping", "HUDFPS")
toggle(hudPage, "Target Info", "TargetInfo")

section(hudPage, "HIDE NAME (Grabar)")
toggle(hudPage, "Ocultar mi nombre (...)", "HideName")
toggle(hudPage, "Ocultar leaderboard", "HideLeaderboard")

section(hudPage, "PANEL")
slider(hudPage, "Opacidad panel", "PanelOpacity", 0.5, 1, true, function(v)
    panel.BackgroundTransparency = math.clamp(1 - v, 0, 0.5)
end)

-- ============================================================================
-- PÁGINA SAFE
-- ============================================================================
local safePage = pages["SAFE"]

section(safePage, "CONFIG RAPIDA")
actionBtn(safePage, "Cargar config RECOMENDADA", C.accent, function()
    local d = defaultCfg()
    for k, v in pairs(d) do
        CFG[k] = v
    end
    CFG.ESPColor = Color3.new(unpack(DEFAULTS.ESPColor))
    CFG.FOVRadius = CFG.FOV
    CFG.HoldKey = resolveKey("E", Enum.KeyCode.E)
    saveConfigTo(CONFIG_FILE, CFG)
    notify("Config", "Recomendada cargada - recarga script", 4)
end)

section(safePage, "PANEL")
actionBtn(safePage, "Centrar panel", C.bg3, function()
    panel.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
end)

actionBtn(safePage, "Reiniciar script", C.danger, function()
    pcall(function()
        if originalDisplayName then
            LocalPlayer.DisplayName = originalDisplayName
        end
    end)
    pcall(function()
        RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop")
    end)
    espScreen:Destroy()
    sg:Destroy()
    for plr in pairs(chamsTable) do
        clearChams(plr)
    end
    getgenv().BSS_Aim_Loaded = false
end)

selectTab("AIM")

-- ============================================================================
-- LÓGICA DE DRAG Y MINIMIZAR
-- ============================================================================
local function makeDrag(f, h)
    local d, s, p
    
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true
            s = i.Position
            p = f.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local dl = i.Position - s
            f.Position = UDim2.new(p.X.Scale, p.X.Offset + dl.X, p.Y.Scale, p.Y.Offset + dl.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = false
        end
    end)
end

makeDrag(panel, header)

local miniBtn = new("TextButton", {
    Size = UDim2.fromOffset(56, 56),
    Position = UDim2.new(0, 20, 0, 100),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Active = true,
    Selectable = true,
    Visible = true,
    ZIndex = 200,
    Parent = sg
})
corner(miniBtn, 28)
neonStroke(miniBtn, Color3.fromRGB(255, 255, 255))

local miniIcon = Instance.new("ImageLabel")
miniIcon.Name = "Icon"
miniIcon.AnchorPoint = Vector2.new(0.5, 0.5)
miniIcon.Position = UDim2.fromScale(0.5, 0.5)
miniIcon.Size = UDim2.fromScale(0.72, 0.72)
miniIcon.BackgroundTransparency = 1
miniIcon.Image = ICON_SPLASH
miniIcon.ImageColor3 = Color3.fromRGB(10, 10, 12)
miniIcon.ScaleType = Enum.ScaleType.Fit
miniIcon.Parent = miniBtn

local miniDragging, miniMoved, miniStartMouse, miniStartPos = false, false, nil, nil

miniBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniMoved = false
        miniStartMouse = i.Position
        miniStartPos = miniBtn.Position
        task.wait(0.08)
        if not miniMoved then
            panel.Visible = true
            panel.Size = UDim2.fromOffset(1, 1)
            local mp = miniBtn.AbsolutePosition
            panel.Position = UDim2.new(0, mp.X - W/2 + 28, 0, mp.Y)
            TweenService:Create(panel, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(W, H)
            }):Play()
            miniBtn.Visible = false
        end
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if miniDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local dl = i.Position - miniStartMouse
        if math.abs(dl.X) > 15 or math.abs(dl.Y) > 15 then
            miniMoved = true
        end
        if miniMoved then
            miniBtn.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + dl.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + dl.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
    end
end)

pcall(function()
    miniBtn.Activated:Connect(function()
        if miniMoved then return end
        panel.Visible = true
        panel.Size = UDim2.fromOffset(1, 1)
        local mp = miniBtn.AbsolutePosition
        panel.Position = UDim2.new(0, mp.X - W/2 + 28, 0, mp.Y)
        TweenService:Create(panel, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(W, H)
        }):Play()
        miniBtn.Visible = false
    end)
end)

local function togglePanel()
    if panel.Visible then
        local fromP = panel.AbsolutePosition
        local tw = TweenService:Create(panel, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(1, 1)
        })
        tw:Play()
        tw.Completed:Connect(function()
            panel.Visible = false
            panel.Size = UDim2.fromOffset(W, H)
            miniBtn.Position = UDim2.new(0, fromP.X + W - 56, 0, fromP.Y + 4)
            miniBtn.Size = UDim2.fromOffset(1, 1)
            miniBtn.Visible = true
            miniBtn.ZIndex = 200
            TweenService:Create(miniBtn, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(56, 56)
            }):Play()
        end)
    else
        miniBtn.Visible = false
        panel.Visible = true
        panel.Size = UDim2.fromOffset(1, 1)
        TweenService:Create(panel, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(W, H)
        }):Play()
    end
end

minBtn.MouseButton1Click:Connect(togglePanel)

closeBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if originalDisplayName then
            LocalPlayer.DisplayName = originalDisplayName
        end
    end)
    pcall(function()
        RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop")
    end)
    espScreen:Destroy()
    sg:Destroy()
    for plr in pairs(chamsTable) do
        clearChams(plr)
    end
    getgenv().BSS_Aim_Loaded = false
end)

-- ============================================================================
-- HUD (WATERMARK Y TARGET INFO)
-- ============================================================================
local hudScreen = Instance.new("ScreenGui")
hudScreen.Name = "BSS_HUD_Ultra"
hudScreen.ResetOnSpawn = false
hudScreen.IgnoreGuiInset = true
hudScreen.DisplayOrder = 95
hudScreen.Parent = getParent()

local watermark = Instance.new("Frame")
watermark.Name = "Watermark"
watermark.Size = UDim2.fromOffset(240, 26)
watermark.Position = UDim2.new(0, 20, 0, 20)
watermark.BackgroundColor3 = C.bg
watermark.BackgroundTransparency = 0.25
watermark.BorderSizePixel = 0
watermark.ZIndex = 150
watermark.Parent = hudScreen
Instance.new("UICorner", watermark).CornerRadius = UDim.new(0, 8)

local wmStroke = Instance.new("UIStroke")
wmStroke.Color = C.accent
wmStroke.Thickness = 1.2
wmStroke.Parent = watermark

local wmLabel = Instance.new("TextLabel")
wmLabel.Size = UDim2.new(1, -16, 1, 0)
wmLabel.Position = UDim2.new(0, 10, 0, 0)
wmLabel.BackgroundTransparency = 1
wmLabel.Font = Enum.Font.GothamBold
wmLabel.TextSize = 12
wmLabel.TextColor3 = C.accent
wmLabel.TextXAlignment = Enum.TextXAlignment.Left
wmLabel.Text = "BSS-Aim Ultra"
wmLabel.Parent = watermark

local statsHUD = Instance.new("Frame")
statsHUD.Name = "Stats"
statsHUD.Size = UDim2.fromOffset(180, 90)
statsHUD.Position = UDim2.new(1, -200, 0, 60)
statsHUD.BackgroundColor3 = C.bg
statsHUD.BackgroundTransparency = 0.25
statsHUD.BorderSizePixel = 0
statsHUD.ZIndex = 150
statsHUD.Parent = hudScreen
Instance.new("UICorner", statsHUD).CornerRadius = UDim.new(0, 8)

local stStroke = Instance.new("UIStroke")
stStroke.Color = C.accent2
stStroke.Thickness = 1.2
stStroke.Parent = statsHUD

local stLabel = Instance.new("TextLabel")
stLabel.Size = UDim2.new(1, -16, 1, -12)
stLabel.Position = UDim2.new(0, 10, 0, 6)
stLabel.BackgroundTransparency = 1
stLabel.Font = Enum.Font.Code
stLabel.TextSize = 12
stLabel.TextColor3 = C.fg
stLabel.TextXAlignment = Enum.TextXAlignment.Left
stLabel.TextYAlignment = Enum.TextYAlignment.Top
stLabel.TextWrapped = true
stLabel.Text = ""
stLabel.Parent = statsHUD

-- Target Info Panel
local targetInfo = Instance.new("Frame")
targetInfo.Name = "TargetInfo"
targetInfo.Size = UDim2.fromOffset(240, 34)
targetInfo.Position = UDim2.new(0.5, -120, 1, -60)
targetInfo.BackgroundColor3 = C.bg
targetInfo.BackgroundTransparency = 0.2
targetInfo.BorderSizePixel = 0
targetInfo.Visible = false
targetInfo.ZIndex = 150
targetInfo.Parent = hudScreen
Instance.new("UICorner", targetInfo).CornerRadius = UDim.new(0, 8)

local tiStroke = Instance.new("UIStroke")
tiStroke.Color = C.danger
tiStroke.Thickness = 1.5
tiStroke.Parent = targetInfo

local tiLabel = Instance.new("TextLabel")
tiLabel.Size = UDim2.new(1, -20, 1, 0)
tiLabel.Position = UDim2.new(0, 10, 0, 0)
tiLabel.BackgroundTransparency = 1
tiLabel.Font = Enum.Font.GothamBold
tiLabel.TextSize = 13
tiLabel.TextColor3 = C.fg
tiLabel.TextXAlignment = Enum.TextXAlignment.Center
tiLabel.Text = "LOCKED: ..."
tiLabel.Parent = targetInfo

local function getPing()
    local ok, ping = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and type(ping) == "number" then return math.floor(ping) end
    return 0
end

local fpsCount = 0
local fpsTimer = tick()
local currentFPS = 60

-- ============================================================================
-- BACKGROUND LOOPS (HIGHLIGHT Y PICKUP)
-- ============================================================================
task.spawn(function()
    while getgenv().BSS_Aim_Loaded do
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer or sameTeam(plr) or not alive(plr) then
                clearChams(plr)
                continue
            end
            
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                clearChams(plr)
                continue
            end
            
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            
            if CFG.PlayerESP and CFG.ChamsESP and dist <= CFG.MaxESP then
                local hl = ensureChams(plr, char)
                if hl then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if CFG.NameColorByHP and hum then
                        local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        if hp > 0.6 then
                            hl.FillColor = C.hp
                        elseif hp > 0.3 then
                            hl.FillColor = Color3.fromRGB(240, 200, 80)
                        else
                            hl.FillColor = C.danger
                        end
                    else
                        hl.FillColor = CFG.ESPColor
                    end
                end
            else
                clearChams(plr)
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while getgenv().BSS_Aim_Loaded do
        pcall(tryPickup)
        pcall(trackKills)
        task.wait(CFG.PickupDelay)
    end
end)

task.spawn(function()
    while getgenv().BSS_Aim_Loaded do
        pcall(applyHideName)
        task.wait(1.5)
    end
end)

-- ============================================================================
-- MAIN LOOP (AIM Y DRAWINGS)
-- ============================================================================
pcall(function()
    RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop")
end)

RunService:BindToRenderStep("BSS_Aim_Ultra_Loop", Enum.RenderPriority.Camera.Value + 1, function(dt)
    fpsCount += 1
    if tick() - fpsTimer >= 1 then
        currentFPS = fpsCount
        fpsCount = 0
        fpsTimer = tick()
    end

    local now = tick()
    
    -- Target Selection
    if (aimOn or CFG.TriggerBot) and (now - lastTargetCheck) > 0.05 then
        lastTargetCheck = now
        if not (CFG.AimOnFireOnly and not aimOn) then
            local _, bestPart, bestScore = getTargetWithScore()
            if targetDead() then
                if bestPart then
                    currentTarget = bestPart
                    lastSwitch = now
                else
                    currentTarget = nil
                end
            elseif bestPart and bestPart ~= currentTarget then
                local curPx = targetPx()
                if bestScore + 40 < curPx and (now - lastSwitch) > 0.3 then
                    currentTarget = bestPart
                    lastSwitch = now
                end
            end
            if currentTarget and targetPx() > CFG.FOVRadius * 1.2 then
                if bestPart then
                    currentTarget = bestPart
                    lastSwitch = now
                else
                    currentTarget = nil
                end
            end
        end
    elseif not (aimOn or CFG.TriggerBot) then
        currentTarget = nil
    end

    -- FOV Circle
    if CFG.DrawFOV and CFG.Enabled and aimOn then
        fovCircle.Position = UDim2.fromScale(0.5, 0.5)
        fovCircle.Size = UDim2.fromOffset(CFG.FOVRadius * 2, CFG.FOVRadius * 2)
        fovStroke.Color = currentTarget and C.aimLock or C.accent
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end

    -- Drawing API (Snapline, Head Dot)
    if IS_PC then
        if CFG.HeadDotESP and CFG.Enabled and currentTarget then
            local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
            if on and drawHeadDot then
                drawHeadDot.Position = Vector2.new(sp.X, sp.Y)
                drawHeadDot.Radius = 6
                drawHeadDot.Color = C.aimLock
                drawHeadDot.Visible = true
            elseif drawHeadDot then
                drawHeadDot.Visible = false
            end
        elseif drawHeadDot then
            drawHeadDot.Visible = false
        end

        if CFG.SnaplineESP and CFG.Enabled and currentTarget and drawSnapline then
            local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
            if on then
                drawSnapline.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                drawSnapline.To = Vector2.new(sp.X, sp.Y)
                drawSnapline.Color = CFG.ESPColor
                drawSnapline.Visible = true
            else
                drawSnapline.Visible = false
            end
        elseif drawSnapline then
            drawSnapline.Visible = false
        end
    end

    -- Camera Lock Logic
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local inCar = hum and hum.SeatPart ~= nil

    if CFG.Enabled and aimOn and currentTarget and CFG.CameraLock then
        if inCar then
            if Camera.CameraType ~= Enum.CameraType.Scriptable then
                Camera.CameraType = Enum.CameraType.Scriptable
            end
        else
            if Camera.CameraType == Enum.CameraType.Scriptable then
                Camera.CameraType = originalCameraType
            end
        end

        local camPos = Camera.CFrame.Position
        local tPos = currentTarget.Position
        
        -- Snap 100% Instantaneo
        Camera.CFrame = CFrame.lookAt(camPos, tPos)
    else
        if Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = originalCameraType
        end
    end

    -- HUD Update
    if CFG.TargetInfo then
        if currentTarget then
            local plr = Players:GetPlayerFromCharacter(currentTarget.Parent)
            if plr then
                targetInfo.Visible = true
                tiLabel.Text = string.format("LOCKED: %s", plr.Name)
                tiLabel.TextColor3 = C.danger
            else
                targetInfo.Visible = false
            end
        else
            targetInfo.Visible = false
        end
    else
        targetInfo.Visible = false
    end

    if CFG.HUDWatermark then
        watermark.Visible = true
    else
        watermark.Visible = false
    end

    if CFG.HUDFPS then
        statsHUD.Visible = true
        local minutes = math.floor((tick() - sessionStart) / 60)
        local lines = {}
        lines[#lines+1] = string.format("Kills:    %d", sessionKills)
        lines[#lines+1] = string.format("Pickups:  %d", sessionPickups)
        lines[#lines+1] = string.format("Session:  %dm", minutes)
        lines[#lines+1] = string.format("FPS:      %d", currentFPS)
        lines[#lines+1] = string.format("Ping:     %dms", getPing())
        stLabel.Text = table.concat(lines, "\n")
        statsHUD.Size = UDim2.fromOffset(180, 20 + #lines * 16)
    else
        statsHUD.Visible = false
    end
end)

notify("BSS-Aim ULTRA v11", "Cargado con Hitbox, Tracers y Snap 100%", 6)
print("[BSS-Aim ULTRA v11] cargado")
