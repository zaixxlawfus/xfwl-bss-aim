-- BSS-Aim v16 — triggerbot, chams, HUD, playerlist, profiles, filtros
-- discord.gg/syncrypt
-- Auto-detect mobile/PC · Compatible: Delta, Xeno, Codex, PC

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().BSS_AimV16 then return end
getgenv().BSS_AimV16 = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer
local Camera = WS.CurrentCamera

local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IS_PC = not IS_MOBILE

-- ============ FILE IO ============
local CONFIG_FOLDER = "BSS_Aim"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local HAVE_FILE_IO = (writefile and readfile and isfile and makefolder) and true or false

local function ensureFolder()
    if not HAVE_FILE_IO then return end
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
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
    if not HAVE_FILE_IO then return end
    pcall(function()
        ensureFolder()
        writefile(path, HttpService:JSONEncode(serializeCfg(cfg)))
    end)
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

-- ============ DEFAULTS ============
local DEFAULTS = {
    -- AIM
    Enabled = true,
    HoldKey = "MouseButton2",
    ToggleKey = "RightShift",
    PanelKey = "F1",
    PanicKey = "Delete",
    FOV = 90,
    FOVRadius = 90,
    LockSnap = 1.0,
    MaxDistance = 500,
    TargetPart = "Head",
    TeamCheck = false,
    WallCheck = true,
    DrawFOV = true,
    FOVLockToTarget = true,
    CameraLock = true,
    SilentAim = true,
    AimOnFireOnly = false,
    AutoFire = false,
    AutoFireDelay = 0.15,
    TriggerBot = false,
    TriggerDelay = 0.05,
    Priority = "fov",            -- "fov" | "dist" | "weak" | "danger"
    IgnoreHighHP = false,
    IgnoreHPThreshold = 80,
    -- ESP
    PlayerESP = true,
    WeaponESP = true,
    ItemESP = true,
    NameESP = true,
    HealthESP = true,
    StaminaESP = true,
    ChamsESP = false,
    HeadDotESP = false,
    SnaplineESP = false,
    ArmedOnlyESP = false,
    NameColorByHP = true,
    DistanceStuds = false,
    Tracers = true,
    Prediction = 0.12,
    MaxESP = 450,
    ESPMinScale = 0.5,
    ESPMaxScale = 1.0,
    ESPRefresh = 0.1,
    ESPColor = {0, 0.94, 0.7},
    ItemOutline = true,
    -- PICKUP
    AutoPickup = true,
    PickupRadius = 40,
    PickupDelay = 0.05,
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
    HUDPlayerList = false,
    HUDFPS = true,
    HUDPing = true,
    -- SAFETY
    Notifications = true,
    PanelOpacity = 1.0,
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

-- ============ CONFIG LOAD ============
local CFG = defaultCfg()
local saved = loadConfigFrom(CONFIG_FILE)
if saved then
    for k, v in pairs(saved) do
        if CFG[k] ~= nil or k == "ESPColor" then CFG[k] = v end
    end
end
if type(CFG.ESPColor) == "table" then CFG.ESPColor = Color3.new(unpack(CFG.ESPColor)) end
CFG.HoldKey = resolveKey(CFG.HoldKey, Enum.UserInputType.MouseButton2)
CFG.ToggleKey = resolveKey(CFG.ToggleKey, Enum.KeyCode.RightShift)
CFG.PanelKey = resolveKey(CFG.PanelKey, Enum.KeyCode.F1)
CFG.PanicKey = resolveKey(CFG.PanicKey, Enum.KeyCode.Delete)
CFG.FOVRadius = CFG.FOV
getgenv().BSS_AimConfig = CFG

local saveScheduled = false
local function scheduleSave()
    if saveScheduled then return end
    saveScheduled = true
    task.delay(0.5, function()
        saveScheduled = false
        saveConfigTo(CONFIG_FILE, CFG)
    end)
end

-- ============ COLORS ============
local C = {
    bg      = Color3.fromRGB(8, 9, 14),
    bg2     = Color3.fromRGB(14, 16, 24),
    bg3     = Color3.fromRGB(22, 25, 36),
    bg4     = Color3.fromRGB(32, 36, 50),
    accent  = Color3.fromRGB(0, 240, 180),
    accent2 = Color3.fromRGB(180, 100, 255),
    accent3 = Color3.fromRGB(0, 180, 255),
    pink    = Color3.fromRGB(255, 100, 200),
    fg      = Color3.fromRGB(240, 242, 250),
    muted   = Color3.fromRGB(110, 118, 138),
    danger  = Color3.fromRGB(255, 70, 90),
    border  = Color3.fromRGB(45, 50, 68),
    money   = Color3.fromRGB(120, 240, 130),
    weapon  = Color3.fromRGB(255, 130, 130),
    tool    = Color3.fromRGB(120, 180, 255),
    food    = Color3.fromRGB(255, 200, 90),
    hp      = Color3.fromRGB(80, 220, 120),
    stamina = Color3.fromRGB(255, 210, 60),
    aimOn   = Color3.fromRGB(255, 80, 90),
    aimLock = Color3.fromRGB(80, 255, 120),
}

local function getParent()
    if gethui then local ok, r = pcall(gethui); if ok and r then return r end end
    local ok, pg = pcall(function() return LP:WaitForChild("PlayerGui") end)
    if ok and pg then return pg end
    return LP:WaitForChild("PlayerGui")
end

local function notify(title, text, dur)
    if not CFG.Notifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 4,
        })
    end)
end

-- ============ STATE ============
local aimOn = false
local currentTarget = nil
local currentTargetPlr = nil
local lastSwitch = 0
local aimBtn, miniBtn = nil, nil
local sessionStart = tick()
local sessionKills = 0
local sessionPickups = 0
local lastHealthSnapshot = {}
local panicMode = false

-- ============ FOV CIRCLE ============
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
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = C.accent
fovStroke.Thickness = 2
fovStroke.Parent = fovCircle

-- ============ DRAWING (PC) ============
local drawSnapline, drawHeadDot
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

-- ============ MOBILE BUTTONS ============
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
    Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(1, 0)
    local bs1 = Instance.new("UIStroke"); bs1.Color = C.accent; bs1.Thickness = 3; bs1.Parent = aimBtn

    local function toggleAim()
        aimOn = not aimOn
        if aimOn then
            bs1.Color = C.aimOn; aimBtn.TextColor3 = C.aimOn
        else
            bs1.Color = C.accent; aimBtn.TextColor3 = C.accent
        end
    end
    aimBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleAim()
        end
    end)
    pcall(function() aimBtn.Activated:Connect(toggleAim) end)
end

-- ============ AIM ============
local rayP = RaycastParams.new()
rayP.FilterType = Enum.RaycastFilterType.Exclude
local function refreshFilter()
    local f = {Camera}
    if LP.Character then table.insert(f, LP.Character) end
    rayP.FilterDescendantsInstances = f
end
refreshFilter()
LP.CharacterAdded:Connect(function() task.wait(0.4); refreshFilter() end)

local function sameTeam(plr)
    if not CFG.TeamCheck then return false end
    if not plr.Team or not LP.Team then return false end
    return plr.Team == LP.Team
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
    local hit = WS:Raycast(o, d, rayP)
    if not hit then return true end
    return hit.Instance and hit.Instance:IsDescendantOf(char)
end

local function predictPos(plr, part, dt)
    if not IS_PC or CFG.Prediction <= 0 then return part.Position end
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return part.Position end
    local vel = hrp.AssemblyLinearVelocity
    if vel.Magnitude < 2 then return part.Position end
    return part.Position + vel * CFG.Prediction
end

-- score según prioridad
local function scoreTarget(plr, char, part, px, d3)
    if CFG.IgnoreHighHP then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health >= CFG.IgnoreHPThreshold then return math.huge end
    end
    if CFG.Priority == "fov" then return px
    elseif CFG.Priority == "dist" then return d3
    elseif CFG.Priority == "weak" then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hp = hum and hum.Health or 100
        return hp -- menor HP = mejor
    elseif CFG.Priority == "danger" then
        -- considera el más cercano + el más armado
        local wep = 0
        for _, c in ipairs(char:GetChildren()) do
            if c:IsA("Tool") then wep += 1 end
        end
        return d3 - wep * 50
    end
    return px
end

local function getTargetWithScore()
    local bestPlr, bestPart, bestScore = nil, nil, math.huge
    local center = Camera.ViewportSize * 0.5
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or sameTeam(plr) or not alive(plr) then continue end
        local char = plr.Character
        local part = char:FindFirstChild(CFG.TargetPart)
            or char:FindFirstChild("Head")
            or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local wp = part.Position
        local d3 = (Camera.CFrame.Position - wp).Magnitude
        if d3 > CFG.MaxDistance then continue end
        local sp, on = Camera:WorldToViewportPoint(wp)
        if not on then continue end
        local px = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if px > CFG.FOVRadius then continue end
        if CFG.WallCheck and not visible(part, char) then continue end
        local score = scoreTarget(plr, char, part, px, d3)
        if score < bestScore then
            bestScore = score
            bestPlr = plr
            bestPart = part
        end
    end
    return bestPlr, bestPart, bestScore
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

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == CFG.HoldKey or i.KeyCode == CFG.HoldKey then aimOn = true end
    if i.KeyCode == CFG.ToggleKey then aimOn = not aimOn end
    if i.KeyCode == CFG.PanicKey then
        -- panic: desactivar todo
        aimOn = false
        CFG.Enabled = false
        if drawSnapline then drawSnapline.Visible = false end
        if drawHeadDot then drawHeadDot.Visible = false end
        notify("PANIC", "Todo desactivado", 3)
    end
end)
UIS.InputEnded:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == CFG.HoldKey or i.KeyCode == CFG.HoldKey then aimOn = false end
end)

-- ============ SILENT AIM (PC) ============
if IS_PC and CFG.SilentAim then
    local Mouse = LP:GetMouse()
    local mt = nil
    pcall(function() if getrawmetatable then mt = getrawmetatable(game) end end)
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

-- ============ TRIGGERBOT / AUTO-FIRE ============
local lastFire = 0
local function tryFire()
    if not CFG.Enabled or not currentTarget then return end
    if not (CFG.TriggerBot or CFG.AutoFire) then return end
    local now = tick()
    local delay = CFG.TriggerBot and CFG.TriggerDelay or CFG.AutoFireDelay
    if now - lastFire < delay then return end
    -- verificar que el target esté prácticamente en la mira (px < 8)
    if targetPx() > 8 then return end
    lastFire = now
    pcall(function()
        -- click virtual en PC
        if IS_PC then
            local VIM = game:GetService("VirtualInputManager")
            if VIM then
                VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 1)
                task.wait(0.02)
                VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 1)
            end
        else
            -- en móvil usamos mouse1 click via VirtualUser si existe
            local VIM = game:GetService("VirtualInputManager")
            if VIM then
                VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 1)
                task.wait(0.02)
                VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 1)
            end
        end
    end)
end

-- ============ STAMINA ============
local function getStamina(plr, char, hum)
    if hum then
        local s = hum:GetAttribute("Stamina") or hum:GetAttribute("stamina")
        if s ~= nil then return s, (hum:GetAttribute("MaxStamina") or 100) end
    end
    if char then
        local s = char:GetAttribute("Stamina") or char:GetAttribute("stamina")
        if s ~= nil then return s, (char:GetAttribute("MaxStamina") or 100) end
    end
    local s = plr:GetAttribute("Stamina") or plr:GetAttribute("stamina")
    if s ~= nil then return s, (plr:GetAttribute("MaxStamina") or 100) end
    return nil, nil
end

-- ============ CHAMS ============
local chamsTable = {}
local function ensureChams(plr, char)
    local h = chamsTable[plr]
    if h and h.Parent then return h end
    local ok, hl = pcall(function()
        local x = Instance.new("Highlight")
        x.Name = "BSS_Chams"
        x.FillColor = CFG.ESPColor
        x.OutlineColor = Color3.fromRGB(0, 0, 0)
        x.FillTransparency = 0.5
        x.OutlineTransparency = 0
        x.DepthMode = Enum.HighlightDepthMode.Occluded
        x.Adornee = char
        x.Parent = char
        return x
    end)
    if ok and hl then chamsTable[plr] = hl; return hl end
    return nil
end

local function clearChams(plr)
    local h = chamsTable[plr]
    if h then pcall(function() h:Destroy() end); chamsTable[plr] = nil end
end

-- ============ ESP ============
local pESP = {}
local iESP = {}

local function clearESP(plr)
    local b = pESP[plr]
    if b then pcall(function() b:Destroy() end); pESP[plr] = nil end
    clearChams(plr)
end

local function clearItemESP(m)
    local b = iESP[m]
    if b then pcall(function() b:Destroy() end); iESP[m] = nil end
end

local function ensureP(plr)
    if pESP[plr] and pESP[plr].Parent then return pESP[plr] end
    local char = plr.Character
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    if not head then return nil end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BSS_ESP"
    billboard.Size = UDim2.fromOffset(150, 76)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.6, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.ResetOnSpawn = false
    billboard.MaxDistance = CFG.MaxESP
    billboard.Adornee = head
    billboard.Parent = head

    local bgFrame = Instance.new("Frame")
    bgFrame.Name = "BG"
    bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgFrame.BackgroundTransparency = 0.5
    bgFrame.BorderSizePixel = 0
    bgFrame.Size = UDim2.fromScale(1, 1)
    bgFrame.Parent = billboard
    Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0, 6)
    local bgStroke = Instance.new("UIStroke")
    bgStroke.Color = CFG.ESPColor; bgStroke.Thickness = 1.5; bgStroke.Parent = bgFrame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "Name"; nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0, 6, 0, 3); nameLbl.Size = UDim2.new(1, -12, 0, 14)
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 12
    nameLbl.TextColor3 = C.fg; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextStrokeTransparency = 0.4; nameLbl.Text = ""
    nameLbl.Parent = bgFrame

    local wepLbl = Instance.new("TextLabel")
    wepLbl.Name = "Wep"; wepLbl.BackgroundTransparency = 1
    wepLbl.Position = UDim2.new(0, 6, 0, 17); wepLbl.Size = UDim2.new(1, -12, 0, 12)
    wepLbl.Font = Enum.Font.Gotham; wepLbl.TextSize = 10
    wepLbl.TextColor3 = C.food; wepLbl.TextXAlignment = Enum.TextXAlignment.Left
    wepLbl.TextStrokeTransparency = 0.4; wepLbl.Text = ""
    wepLbl.Parent = bgFrame

    local hpBg = Instance.new("Frame")
    hpBg.Name = "HpBg"; hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    hpBg.BorderSizePixel = 0; hpBg.Position = UDim2.new(0, 6, 0, 33)
    hpBg.Size = UDim2.new(1, -12, 0, 8); hpBg.Parent = bgFrame
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)
    local hpFill = Instance.new("Frame")
    hpFill.Name = "HpFill"; hpFill.BackgroundColor3 = C.hp
    hpFill.BorderSizePixel = 0; hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.Parent = hpBg
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)
    local hpTxt = Instance.new("TextLabel")
    hpTxt.Name = "HpTxt"; hpTxt.BackgroundTransparency = 1
    hpTxt.Position = UDim2.new(0, 10, 0, 33); hpTxt.Size = UDim2.new(1, -20, 0, 8)
    hpTxt.Font = Enum.Font.GothamBold; hpTxt.TextSize = 9
    hpTxt.TextColor3 = Color3.fromRGB(255,255,255); hpTxt.TextStrokeTransparency = 0.5
    hpTxt.TextXAlignment = Enum.TextXAlignment.Left; hpTxt.Text = "HP"; hpTxt.ZIndex = 2
    hpTxt.Parent = bgFrame

    local stBg = Instance.new("Frame")
    stBg.Name = "StBg"; stBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    stBg.BorderSizePixel = 0; stBg.Position = UDim2.new(0, 6, 0, 45)
    stBg.Size = UDim2.new(1, -12, 0, 8); stBg.Parent = bgFrame
    Instance.new("UICorner", stBg).CornerRadius = UDim.new(1, 0)
    local stFill = Instance.new("Frame")
    stFill.Name = "StFill"; stFill.BackgroundColor3 = C.stamina
    stFill.BorderSizePixel = 0; stFill.Size = UDim2.new(1, 0, 1, 0)
    stFill.Parent = stBg
    Instance.new("UICorner", stFill).CornerRadius = UDim.new(1, 0)
    local stTxt = Instance.new("TextLabel")
    stTxt.Name = "StTxt"; stTxt.BackgroundTransparency = 1
    stTxt.Position = UDim2.new(0, 10, 0, 45); stTxt.Size = UDim2.new(1, -20, 0, 8)
    stTxt.Font = Enum.Font.GothamBold; stTxt.TextSize = 9
    stTxt.TextColor3 = Color3.fromRGB(255,255,255); stTxt.TextStrokeTransparency = 0.5
    stTxt.TextXAlignment = Enum.TextXAlignment.Left; stTxt.Text = "ST"; stTxt.ZIndex = 2
    stTxt.Parent = bgFrame

    local distLbl = Instance.new("TextLabel")
    distLbl.Name = "Dist"; distLbl.BackgroundTransparency = 1
    distLbl.Position = UDim2.new(0, 6, 1, -18); distLbl.Size = UDim2.new(1, -12, 0, 14)
    distLbl.Font = Enum.Font.GothamBold; distLbl.TextSize = 11
    distLbl.TextColor3 = CFG.ESPColor; distLbl.TextXAlignment = Enum.TextXAlignment.Center
    distLbl.TextStrokeTransparency = 0.4; distLbl.Text = ""
    distLbl.Parent = bgFrame

    pESP[plr] = billboard
    return billboard
end

local function hideP(plr)
    local b = pESP[plr]
    if b and b.Parent then b.Enabled = false end
    local h = chamsTable[plr]
    if h and h.Parent then h.Enabled = false end
end

local function weapons(plr)
    local list = {}
    local c = plr.Character
    if c then for _, x in ipairs(c:GetChildren()) do
        if x:IsA("Tool") then table.insert(list, x.Name) end
    end end
    local bp = plr:FindFirstChildOfClass("Backpack")
    if bp then for _, x in ipairs(bp:GetChildren()) do
        if x:IsA("Tool") and not table.find(list, x.Name) then
            table.insert(list, x.Name)
        end
    end end
    if #list == 0 then return nil end
    return table.concat(list, ", ")
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

local function updateScale(b, dist)
    local maxD = CFG.MaxESP
    local minS = CFG.ESPMinScale
    local maxS = CFG.ESPMaxScale
    local t = math.clamp(dist / maxD, 0, 1)
    local s = maxS + (minS - maxS) * t
    b.Size = UDim2.fromOffset(150 * s, 76 * s)
end

local function updatePlayerESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or sameTeam(plr) or not alive(plr) then
            hideP(plr); continue
        end
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (head and hrp and hum) then hideP(plr); continue end
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > CFG.MaxESP then hideP(plr); continue end
        if CFG.ArmedOnlyESP and not hasWeapon(plr) then hideP(plr); continue end

        local b = ensureP(plr)
        if not b then continue end
        b.Enabled = true
        b.MaxDistance = CFG.MaxESP
        updateScale(b, dist)

        -- chams
        if CFG.ChamsESP then
            local ch = ensureChams(plr, char)
            if ch then
                ch.Enabled = true
                ch.FillColor = CFG.ESPColor
            end
        else
            clearChams(plr)
        end

        local bgFrame = b:FindFirstChild("BG")
        if not bgFrame then continue end
        local nameLbl = bgFrame:FindFirstChild("Name")
        if nameLbl then
            nameLbl.Visible = CFG.PlayerESP and CFG.NameESP
            if nameLbl.Visible then
                nameLbl.Text = plr.Name
                if CFG.NameColorByHP then
                    local hpR = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    if hpR > 0.6 then nameLbl.TextColor3 = C.hp
                    elseif hpR > 0.3 then nameLbl.TextColor3 = Color3.fromRGB(240, 200, 80)
                    else nameLbl.TextColor3 = C.danger end
                else
                    nameLbl.TextColor3 = C.fg
                end
            end
        end
        local wepLbl = bgFrame:FindFirstChild("Wep")
        if wepLbl then
            wepLbl.Visible = CFG.PlayerESP and CFG.WeaponESP
            if wepLbl.Visible then wepLbl.Text = weapons(plr) or "—" end
        end
        local hpBg = bgFrame:FindFirstChild("HpBg")
        local hpFill = hpBg and hpBg:FindFirstChild("HpFill")
        local hpTxt = bgFrame:FindFirstChild("HpTxt")
        if hpBg and hpFill and hpTxt then
            if CFG.PlayerESP and CFG.HealthESP then
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                hpFill.Size = UDim2.new(hp, 0, 1, 0)
                if hp > 0.6 then hpFill.BackgroundColor3 = C.hp
                elseif hp > 0.3 then hpFill.BackgroundColor3 = Color3.fromRGB(240, 200, 80)
                else hpFill.BackgroundColor3 = C.danger end
                hpTxt.Text = string.format("HP %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
                hpBg.Visible = true; hpTxt.Visible = true
            else hpBg.Visible = false; hpTxt.Visible = false end
        end
        local stBg = bgFrame:FindFirstChild("StBg")
        local stFill = stBg and stBg:FindFirstChild("StFill")
        local stTxt = bgFrame:FindFirstChild("StTxt")
        if stBg and stFill and stTxt then
            if CFG.PlayerESP and CFG.StaminaESP then
                local sv, sm = getStamina(plr, char, hum)
                if sv and sm then
                    local r = math.clamp(sv / sm, 0, 1)
                    stFill.Size = UDim2.new(r, 0, 1, 0)
                    stTxt.Text = string.format("ST %d/%d", math.floor(sv), math.floor(sm))
                    stBg.Visible = true; stTxt.Visible = true
                else stBg.Visible = false; stTxt.Visible = false end
            else stBg.Visible = false; stTxt.Visible = false end
        end
        local distLbl = bgFrame:FindFirstChild("Dist")
        if distLbl then
            if CFG.DistanceStuds then
                distLbl.Text = string.format("%d studs", math.floor(dist * 3.28))
            else
                distLbl.Text = string.format("%dm", math.floor(dist))
            end
        end
        local stroke = bgFrame:FindFirstChildOfClass("UIStroke")
        if stroke then
            local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            if hp > 0.6 then stroke.Color = CFG.ESPColor
            elseif hp > 0.3 then stroke.Color = Color3.fromRGB(240, 200, 80)
            else stroke.Color = C.danger end
        end
    end
    for plr in pairs(pESP) do
        if not plr.Parent then clearESP(plr) end
    end
end

-- ============ ITEMS ============
local function classifyItem(name)
    local n = name:lower()
    if n == "money" or n:find("cash") then return C.money, "$"
    elseif n:find("taser") or n:find("gun") or n:find("weapon") or n:find("ak") or n:find("pistol") or n:find("rifle") then return C.weapon, "[G]"
    elseif n:find("food") or n:find("burger") or n:find("pizza") or n:find("drink") then return C.food, "[F]"
    elseif n:find("tool") or n:find("wrench") or n:find("hammer") then return C.tool, "[T]"
    end
    return Color3.fromRGB(255, 200, 90), "[I]"
end

local function readItemAmount(model)
    local bb = model:FindFirstChild("AmountBillboardGui", true)
    if not bb then return nil end
    local tl = bb:FindFirstChild("TextLabel")
    if not tl then return nil end
    return tl.Text
end

local function ensureItemESP(m, part)
    if iESP[m] and iESP[m].Parent then return iESP[m] end
    local b = Instance.new("BillboardGui")
    b.Name = "BSS_ItemESP"
    b.Size = UDim2.fromOffset(110, 20)
    b.StudsOffsetWorldSpace = Vector3.new(0, 1.5, 0)
    b.AlwaysOnTop = true
    b.LightInfluence = 0
    b.ResetOnSpawn = false
    b.MaxDistance = CFG.MaxESP
    b.Adornee = part
    b.Parent = part

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    lbl.BackgroundTransparency = 0.55
    lbl.BorderSizePixel = 0
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = C.money
    lbl.Text = ""
    lbl.Parent = b
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 4)
    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(0, 0, 0)
    st.Thickness = 2
    st.Parent = lbl
    iESP[m] = b
    return b
end

local function updateItemESP()
    if not CFG.ItemESP then
        for m in pairs(iESP) do clearItemESP(m) end
        return
    end
    local seen = {}
    local folder = WS:FindFirstChild("DroppedItems")
    if not folder then return end
    for _, m in ipairs(folder:GetChildren()) do
        if not (m:IsA("Model") or m:IsA("BasePart")) then continue end
        local part
        if m:IsA("BasePart") then part = m
        else
            part = m:FindFirstChild("PickUpZone")
                or m:FindFirstChild("CashPart")
                or m.PrimaryPart
            if not part then part = m:FindFirstChildWhichIsA("BasePart", true) end
        end
        if not part then continue end
        seen[m] = true
        local dist = (Camera.CFrame.Position - part.Position).Magnitude
        if dist > CFG.MaxESP then
            local b = iESP[m]
            if b and b.Parent then b.Enabled = false end
            continue
        end
        local amount = readItemAmount(m)
        local color, icon = classifyItem(m.Name)
        local label = m.Name
        if amount and amount ~= "" then label = m.Name .. " " .. amount end
        local b = ensureItemESP(m, part)
        if not b then continue end
        b.Enabled = true
        b.MaxDistance = CFG.MaxESP
        local t = math.clamp(dist / CFG.MaxESP, 0, 1)
        local s = CFG.ESPMaxScale + (CFG.ESPMinScale - CFG.ESPMaxScale) * t
        b.Size = UDim2.fromOffset(110 * s, 20 * s)
        local lbl = b:FindFirstChild("Label")
        if lbl then
            lbl.Text = string.format("%s %s [%dm]", icon, label, math.floor(dist))
            lbl.TextColor3 = color
            local st = lbl:FindFirstChildOfClass("UIStroke")
            if st then
                if CFG.ItemOutline then
                    st.Color = Color3.fromRGB(0, 0, 0)
                    st.Thickness = 2
                else
                    st.Color = color
                    st.Thickness = 1
                end
            end
        end
    end
    for m in pairs(iESP) do
        if not seen[m] or not m.Parent then clearItemESP(m) end
    end
end

-- ============ AUTO-PICKUP ============
local lastPickup = 0

local function canPickup(m)
    local n = m.Name:lower()
    local kind = "other"
    if n == "money" or n:find("cash") then kind = "money"
    elseif n:find("taser") or n:find("gun") or n:find("weapon") or n:find("ak") or n:find("pistol") or n:find("rifle") then kind = "weapon"
    elseif n:find("food") or n:find("burger") or n:find("pizza") or n:find("drink") then kind = "food"
    elseif n:find("tool") or n:find("wrench") or n:find("hammer") then kind = "tool"
    end
    -- whitelist
    if CFG.PickupWhitelist ~= "" then
        local found = false
        for token in CFG.PickupWhitelist:gmatch("[^,]+") do
            token = token:gsub("^%s+", ""):gsub("%s+$", ""):lower()
            if token ~= "" and n:find(token, 1, true) then found = true; break end
        end
        if not found then return false end
    end
    -- blacklist
    if CFG.PickupBlacklist ~= "" then
        for token in CFG.PickupBlacklist:gmatch("[^,]+") do
            token = token:gsub("^%s+", ""):gsub("%s+$", ""):lower()
            if token ~= "" and n:find(token, 1, true) then return false end
        end
    end
    -- categorías
    if kind == "money" and not CFG.PickupMoney then return false end
    if kind == "weapon" and not CFG.PickupWeapons then return false end
    if kind == "food" and not CFG.PickupFood then return false end
    if kind == "tool" and not CFG.PickupTools then return false end
    return true
end

local function pickItem(part)
    pcall(function()
        local m = part.Parent
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if m and m:IsA("Model") then
            m:PivotTo(CFrame.new(hrp.Position))
        elseif part:IsA("BasePart") then
            part.CFrame = CFrame.new(hrp.Position)
        end
    end)
    pcall(function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if firetouchinterest and part then
            firetouchinterest(hrp, part, 0)
            task.wait()
            firetouchinterest(hrp, part, 1)
        end
    end)
end

local function tryPickup()
    if not CFG.AutoPickup then return end
    local now = tick()
    if now - lastPickup < CFG.PickupDelay then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local folder = WS:FindFirstChild("DroppedItems")
    if not folder then return end
    local picked = false
    for _, m in ipairs(folder:GetChildren()) do
        local part = m:FindFirstChild("PickUpZone")
            or m:FindFirstChild("CashPart")
            or m.PrimaryPart
            or m:FindFirstChildWhichIsA("BasePart", true)
        if not part then continue end
        local d = (hrp.Position - part.Position).Magnitude
        if d < CFG.PickupRadius and canPickup(m) then
            pickItem(part)
            picked = true
            sessionPickups += 1
            if CFG.PickupNotify then
                local color, icon = classifyItem(m.Name)
                local amount = readItemAmount(m)
                local label = m.Name
                if amount and amount ~= "" then label = m.Name .. " " .. amount end
                notify("Pickup", icon .. " " .. label, 2)
            end
        end
    end
    if picked then lastPickup = now end
end

-- ============ TRACK KILLS ============
local function trackKills()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local last = lastHealthSnapshot[plr]
            local cur = hum.Health
            if last and last > 0 and cur <= 0 then sessionKills += 1 end
            lastHealthSnapshot[plr] = cur
        end
    end
end

-- ============ HUD ============
local hudScreen = Instance.new("ScreenGui")
hudScreen.Name = "BSS_HUD"
hudScreen.ResetOnSpawn = false
hudScreen.IgnoreGuiInset = true
hudScreen.DisplayOrder = 95
hudScreen.Parent = getParent()

-- watermark
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
local wmStroke = Instance.new("UIStroke"); wmStroke.Color = C.accent; wmStroke.Thickness = 1.2; wmStroke.Parent = watermark
local wmLabel = Instance.new("TextLabel")
wmLabel.Size = UDim2.new(1, -16, 1, 0)
wmLabel.Position = UDim2.new(0, 10, 0, 0)
wmLabel.BackgroundTransparency = 1
wmLabel.Font = Enum.Font.GothamBold
wmLabel.TextSize = 12
wmLabel.TextColor3 = C.fg
wmLabel.TextXAlignment = Enum.TextXAlignment.Left
wmLabel.Text = "BSS-Aim v16"
wmLabel.Parent = watermark

-- stats HUD (derecha abajo)
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
local stStroke = Instance.new("UIStroke"); stStroke.Color = C.accent2; stStroke.Thickness = 1.2; stStroke.Parent = statsHUD
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

-- ping (via GetNetworkPing)
local function getPing()
    local ok, ping = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and type(ping) == "number" then return math.floor(ping) end
    return 0
end

-- fps
local fpsCount = 0
local fpsTimer = tick()
local currentFPS = 60

-- playerlist
local playerListFrame = Instance.new("Frame")
playerListFrame.Name = "PlayerList"
playerListFrame.Size = UDim2.fromOffset(200, 280)
playerListFrame.Position = UDim2.new(1, -220, 0, 20)
playerListFrame.BackgroundColor3 = C.bg
playerListFrame.BackgroundTransparency = 0.15
playerListFrame.BorderSizePixel = 0
playerListFrame.Visible = false
playerListFrame.ZIndex = 150
playerListFrame.Parent = hudScreen
Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 10)
local plStroke = Instance.new("UIStroke"); plStroke.Color = C.accent; plStroke.Thickness = 1.2; plStroke.Parent = playerListFrame
local plTitle = Instance.new("TextLabel")
plTitle.Size = UDim2.new(1, -20, 0, 20)
plTitle.Position = UDim2.new(0, 10, 0, 6)
plTitle.BackgroundTransparency = 1
plTitle.Font = Enum.Font.GothamBold
plTitle.TextSize = 13
plTitle.TextColor3 = C.accent
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.Text = "JUGADORES"
plTitle.Parent = playerListFrame
local plScroll = Instance.new("ScrollingFrame")
plScroll.Size = UDim2.new(1, -14, 1, -34)
plScroll.Position = UDim2.new(0, 7, 0, 28)
plScroll.BackgroundTransparency = 1
plScroll.BorderSizePixel = 0
plScroll.ScrollBarThickness = 3
plScroll.ScrollBarImageColor3 = C.accent
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
plScroll.Parent = playerListFrame
local plLayout = Instance.new("UIListLayout")
plLayout.Padding = UDim.new(0, 3)
plLayout.SortOrder = Enum.SortOrder.LayoutOrder
plLayout.Parent = plScroll

-- ============ UI HELPERS ============
local function new(c, p, ch)
    local i = Instance.new(c)
    for k, v in pairs(p or {}) do i[k] = v end
    for _, x in ipairs(ch or {}) do x.Parent = i end
    return i
end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function pad(p, t, b, l, r)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
        Parent = p,
    })
end
local function neonStroke(p, color)
    return new("UIStroke", { Color = color or C.accent, Thickness = 1.4, Parent = p })
end

-- ============ MAIN PANEL ============
local sg = new("ScreenGui", {
    Name = "BSS_Aim_V16", ResetOnSpawn = false, IgnoreGuiInset = true,
    DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = getParent(),
})

local W, H = 380, 500
local FONT_TITLE = 14
local FONT_LABEL = 11
local FONT_SMALL = 10
local ROW_H = 34
local TAB_H = 30

local panel = new("Frame", {
    Size = UDim2.fromOffset(W, H),
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = C.bg, BackgroundTransparency = 1 - CFG.PanelOpacity,
    BorderSizePixel = 0, Parent = sg,
})
corner(panel, 16)
neonStroke(panel, C.border)

local grad = new("Frame", {
    Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = C.accent,
    BorderSizePixel = 0, Parent = panel,
})
corner(grad, 16)
new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.accent),
        ColorSequenceKeypoint.new(0.33, C.accent3),
        ColorSequenceKeypoint.new(0.66, C.accent2),
        ColorSequenceKeypoint.new(1, C.pink),
    }),
    Parent = grad,
})

local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 44), Position = UDim2.new(0, 0, 0, 4),
    BackgroundColor3 = C.bg2, BorderSizePixel = 0, Parent = panel,
})
local logo = new("Frame", {
    Size = UDim2.fromOffset(30, 30), Position = UDim2.new(0, 12, 0.5, -15),
    BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = header,
})
corner(logo, 9)
new("UIStroke", { Color = C.accent, Thickness = 2, Transparency = 0.3, Parent = logo })
new("TextLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "⌖",
    TextColor3 = C.bg, TextSize = 18, Font = Enum.Font.GothamBold, Parent = logo,
})
new("TextLabel", {
    Size = UDim2.new(0, 220, 0, 16), Position = UDim2.new(0, 52, 0, 5),
    BackgroundTransparency = 1, Text = "BSS-AIM",
    TextColor3 = C.fg, TextSize = FONT_TITLE, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})
new("TextLabel", {
    Size = UDim2.new(0, 220, 0, 12), Position = UDim2.new(0, 52, 0, 21),
    BackgroundTransparency = 1,
    Text = (IS_PC and "v16 · tryhard pack" or "v16 · mobile"),
    TextColor3 = C.accent, TextSize = 9, Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})

local function iconBtn(txt, xOff)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, xOff, 0.5, -15),
        BackgroundColor3 = C.bg3, BorderSizePixel = 0, Text = txt,
        TextColor3 = C.fg, TextSize = 16, Font = Enum.Font.GothamBold,
        AutoButtonColor = false, Active = true, Parent = header, ZIndex = 2,
    })
    corner(b, 9)
    neonStroke(b, C.border)
    return b
end
local minBtn = iconBtn("—", -76)
local closeBtn = iconBtn("×", -40)

-- tabs
local tabsFrame = new("Frame", {
    Size = UDim2.new(1, -24, 0, TAB_H), Position = UDim2.new(0, 12, 0, 56),
    BackgroundColor3 = C.bg2, BorderSizePixel = 0, Parent = panel,
})
corner(tabsFrame, 10)
neonStroke(tabsFrame, C.border)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabsFrame,
})

local content = new("Frame", {
    Size = UDim2.new(1, -24, 1, -130), Position = UDim2.new(0, 12, 0, 94),
    BackgroundTransparency = 1, Parent = panel,
})

local pages = {}
local tabBtns = {}
local tabUnderline = new("Frame", {
    Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0, 0, 1, -3),
    BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = tabsFrame,
})
corner(tabUnderline, 2)

local function selectTab(name)
    for k, p in pairs(pages) do p.Visible = (k == name) end
    for k, b in pairs(tabBtns) do
        local on = (k == name)
        TweenService:Create(b, TweenInfo.new(0.15),
            { TextColor3 = on and C.accent or C.muted }):Play()
    end
    local active = tabBtns[name]
    if active then
        TweenService:Create(tabUnderline, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, active.AbsolutePosition.X - tabsFrame.AbsolutePosition.X, 1, -3),
            Size = UDim2.new(0, active.AbsoluteSize.X, 0, 2),
        }):Play()
    end
end

local TAB_LIST = IS_PC and {"AIM", "ESP", "PICKUP", "HUD", "SAFE"} or {"AIM", "ESP", "PICKUP", "HUD", "SAFE"}
for i, tname in ipairs(TAB_LIST) do
    local btn = new("TextButton", {
        Size = UDim2.new(1/#TAB_LIST, 0, 1, 0), BackgroundTransparency = 1,
        Text = tname, TextColor3 = C.muted, TextSize = FONT_SMALL,
        Font = Enum.Font.GothamBold, AutoButtonColor = false, Active = true,
        LayoutOrder = i, Parent = tabsFrame,
    })
    tabBtns[tname] = btn
    btn.MouseButton1Click:Connect(function() selectTab(tname) end)
    local page = new("ScrollingFrame", {
        Name = tname .. "_Page", Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false, Parent = content,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })
    pad(page, 0, 0, 0, 6)
    pages[tname] = page
end

local order = 0
local function nextOrder() order = order + 1; return order end

local function section(page, label)
    local wrap = new("Frame", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
        LayoutOrder = nextOrder(), Parent = page,
    })
    local bar = new("Frame", {
        Size = UDim2.new(0, 3, 0, 14), Position = UDim2.new(0, 0, 0.5, -7),
        BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = wrap,
    })
    corner(bar, 2)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 11, 0, 0),
        Size = UDim2.new(1, -11, 1, 0), Font = Enum.Font.GothamBold,
        Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
end

local function toggle(page, label, key, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 9)
    local rowStroke = neonStroke(row, C.border)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -60, 1, 0), Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local track = new("Frame", {
        Size = UDim2.fromOffset(38, 20), Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = C.bg4, BorderSizePixel = 0, Parent = row,
    })
    corner(track, 10)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = C.fg, BorderSizePixel = 0, Parent = track,
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
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "", Active = true, Parent = row,
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
        Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 9)
    neonStroke(row, C.border)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -76, 0, 13), Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local valLbl = new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(1, -76, 0, 6),
        Size = UDim2.new(0, 64, 0, 13), Font = Enum.Font.GothamBold,
        Text = "", TextColor3 = C.accent, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
    })
    local track = new("Frame", {
        Size = UDim2.new(1, -24, 0, 5), Position = UDim2.new(0, 12, 1, -16),
        BackgroundColor3 = C.bg4, BorderSizePixel = 0, Parent = row,
    })
    corner(track, 3)
    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.accent,
        BorderSizePixel = 0, Parent = track,
    })
    corner(fill, 3)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 0, 0.5, -6),
        BackgroundColor3 = C.fg, BorderSizePixel = 0, Parent = track,
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
        if not isFloat then v = math.floor(v + 0.5) end
        CFG[key] = v
        render()
        scheduleSave()
        if onChange then onChange(v) end
    end
    local hit = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "", Active = true, Parent = row,
    })
    hit.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; setFromX(inp.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch) then setFromX(inp.Position.X) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    render()
end

local function textRow(page, label, key, placeholder)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 9)
    neonStroke(row, C.border)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -130, 1, 0), Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local tb = new("TextBox", {
        Size = UDim2.fromOffset(110, 26), Position = UDim2.new(1, -122, 0.5, -13),
        BackgroundColor3 = C.bg3, BorderSizePixel = 0,
        Font = Enum.Font.Gotham, Text = CFG[key] or "",
        PlaceholderText = placeholder or "..." ,
        TextColor3 = C.accent, PlaceholderColor3 = C.muted,
        TextSize = 11, ClearTextOnFocus = false, Active = true,
        Parent = row,
    })
    corner(tb, 7)
    neonStroke(tb, C.border)
    tb.FocusLost:Connect(function()
        CFG[key] = tb.Text
        scheduleSave()
    end)
end

local function partSelector(page)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 9)
    neonStroke(row, C.border)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -24, 0, 13), Font = Enum.Font.GothamMedium,
        Text = "Parte objetivo", TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local holder = new("Frame", {
        Position = UDim2.new(0, 8, 0, 24), Size = UDim2.new(1, -16, 0, 28),
        BackgroundTransparency = 1, Parent = row,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder,
    })
    local buttons = {}
    local function refresh()
        for p, b in pairs(buttons) do
            local on = CFG.TargetPart == p or (p == "HRP" and CFG.TargetPart == "HumanoidRootPart")
            b.BackgroundColor3 = on and C.accent or C.bg3
            b.TextColor3 = on and C.bg or C.fg
        end
    end
    for i, p in ipairs({"Head", "Neck", "UpperTorso", "Torso", "LowerTorso", "HRP"}) do
        local b = new("TextButton", {
            Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = C.bg3, BorderSizePixel = 0,
            Font = Enum.Font.GothamMedium, Text = " " .. p .. " ",
            TextColor3 = C.fg, TextSize = FONT_SMALL, LayoutOrder = i,
            AutoButtonColor = false, Active = true, Parent = holder,
        })
        corner(b, 7)
        buttons[p] = b
        b.MouseButton1Click:Connect(function()
            CFG.TargetPart = (p == "HRP") and "HumanoidRootPart" or p
            refresh(); scheduleSave()
        end)
    end
    refresh()
end

local function prioritySelector(page)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 9)
    neonStroke(row, C.border)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -24, 0, 13), Font = Enum.Font.GothamMedium,
        Text = "Prioridad de target", TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local holder = new("Frame", {
        Position = UDim2.new(0, 8, 0, 24), Size = UDim2.new(1, -16, 0, 28),
        BackgroundTransparency = 1, Parent = row,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder,
    })
    local buttons = {}
    local opts = {
        {id = "fov", label = "Cerca mira"},
        {id = "dist", label = "Cerca 3D"},
        {id = "weak", label = "Mas debil"},
        {id = "danger", label = "Mas peligro"},
    }
    local function refresh()
        for id, b in pairs(buttons) do
            local on = CFG.Priority == id
            b.BackgroundColor3 = on and C.accent or C.bg3
            b.TextColor3 = on and C.bg or C.fg
        end
    end
    for i, o in ipairs(opts) do
        local b = new("TextButton", {
            Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = C.bg3, BorderSizePixel = 0,
            Font = Enum.Font.GothamMedium, Text = " " .. o.label .. " ",
            TextColor3 = C.fg, TextSize = FONT_SMALL, LayoutOrder = i,
            AutoButtonColor = false, Active = true, Parent = holder,
        })
        corner(b, 7)
        buttons[o.id] = b
        b.MouseButton1Click:Connect(function()
            CFG.Priority = o.id
            refresh(); scheduleSave()
        end)
    end
    refresh()
end

local function keybindRow(page, label, key)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 9)
    neonStroke(row, C.border)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -116, 1, 0), Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local btn = new("TextButton", {
        Size = UDim2.fromOffset(96, 26), Position = UDim2.new(1, -104, 0.5, -13),
        BackgroundColor3 = C.bg3, BorderSizePixel = 0, Text = "",
        TextColor3 = C.accent, TextSize = FONT_SMALL, Font = Enum.Font.GothamBold,
        AutoButtonColor = false, Active = true, Parent = row,
    })
    corner(btn, 7)
    neonStroke(btn, C.border)
    local capturing = false
    local function render()
        local cur = CFG[key]
        local name = "?"
        if typeof(cur) == "EnumItem" then
            if cur.EnumType == Enum.KeyCode then name = cur.Name
            elseif cur.EnumType == Enum.UserInputType then
                name = cur.Name:gsub("MouseButton", "Mouse") end
        end
        btn.Text = capturing and "presioná..." or name
        btn.TextColor3 = capturing and C.pink or C.accent
    end
    btn.MouseButton1Click:Connect(function() capturing = not capturing; render() end)
    UIS.InputBegan:Connect(function(inp, gp)
        if gp or not capturing then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            CFG[key] = inp.KeyCode
        elseif inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.MouseButton2 then
            CFG[key] = inp.UserInputType
        end
        capturing = false
        render(); scheduleSave()
    end)
    render()
end

local function actionBtn(page, label, color, onClick)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = color or C.bg3,
        BorderSizePixel = 0, Font = Enum.Font.GothamBold, Text = label,
        TextColor3 = C.fg, TextSize = FONT_LABEL, AutoButtonColor = false,
        Active = true, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(b, 9)
    neonStroke(b, color or C.border)
    local base = color or C.bg3
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15),
            { BackgroundColor3 = base:Lerp(Color3.new(1,1,1), 0.12) }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = base }):Play()
    end)
    b.MouseButton1Click:Connect(onClick)
end

-- ============ PÁGINAS ============
-- AIM
local aimPage = pages["AIM"]
section(aimPage, "AIMBOT")
toggle(aimPage, "Activar", "Enabled")
toggle(aimPage, "Camera lock", "CameraLock")
toggle(aimPage, "Solo al disparar", "AimOnFireOnly")
slider(aimPage, "FOV", "FOV", 30, 400, false, function(v) CFG.FOVRadius = v end)
slider(aimPage, "Lock snap (pegado)", "LockSnap", 0.5, 1, true)
slider(aimPage, "Dist. max", "MaxDistance", 100, 1500, false)
partSelector(aimPage)
prioritySelector(aimPage)
section(aimPage, "TRIGGER / AUTO-FIRE")
toggle(aimPage, "Trigger bot", "TriggerBot")
slider(aimPage, "Trigger delay", "TriggerDelay", 0.02, 0.5, true)
toggle(aimPage, "Auto-fire al lockear", "AutoFire")
slider(aimPage, "Auto-fire delay", "AutoFireDelay", 0.05, 1, true)
section(aimPage, "FILTROS")
toggle(aimPage, "FOV pegado a la cabeza", "FOVLockToTarget")
toggle(aimPage, "Wall check", "WallCheck")
toggle(aimPage, "Team check", "TeamCheck")
toggle(aimPage, "Ignorar HP alto", "IgnoreHighHP")
slider(aimPage, "HP minimo (ignora arriba)", "IgnoreHPThreshold", 20, 100, false)
if IS_PC then
    section(aimPage, "PC")
    toggle(aimPage, "Silent aim (hook mouse)", "SilentAim")
    slider(aimPage, "Prediccion (lead)", "Prediction", 0, 0.3, true)
end

-- ESP
local espPage = pages["ESP"]
section(espPage, "JUGADORES")
toggle(espPage, "ESP jugadores", "PlayerESP")
toggle(espPage, "Nombre", "NameESP")
toggle(espPage, "Nombre por HP", "NameColorByHP")
toggle(espPage, "Armas", "WeaponESP")
toggle(espPage, "Vida (HP)", "HealthESP")
toggle(espPage, "Stamina", "StaminaESP")
toggle(espPage, "Solo armados", "ArmedOnlyESP")
section(espPage, "VISUAL")
toggle(espPage, "Chams (highlight solido)", "ChamsESP")
toggle(espPage, "Head dot", "HeadDotESP")
toggle(espPage, "Snapline al target", "SnaplineESP")
toggle(espPage, "Distancia en studs", "DistanceStuds")
section(espPage, "ESCALA")
slider(espPage, "Min escala (lejos)", "ESPMinScale", 0.2, 1, true)
slider(espPage, "Max escala (cerca)", "ESPMaxScale", 0.5, 2, true)
slider(espPage, "Rango ESP", "MaxESP", 50, 1000, false)
section(espPage, "ITEMS")
toggle(espPage, "Items dropeados", "ItemESP")
toggle(espPage, "Borde negro en items", "ItemOutline")
section(espPage, "RENDIMIENTO")
slider(espPage, "Refresh", "ESPRefresh", 0.05, 0.5, true)

-- PICKUP
local pickPage = pages["PICKUP"]
section(pickPage, "AUTO PICKUP")
toggle(pickPage, "Activar pickup", "AutoPickup")
slider(pickPage, "Radio", "PickupRadius", 5, 100, false)
slider(pickPage, "Delay", "PickupDelay", 0.02, 0.5, true)
toggle(pickPage, "Notificar pickup", "PickupNotify")
section(pickPage, "CATEGORIAS")
toggle(pickPage, "Money / Cash", "PickupMoney")
toggle(pickPage, "Armas", "PickupWeapons")
toggle(pickPage, "Comida", "PickupFood")
toggle(pickPage, "Herramientas", "PickupTools")
section(pickPage, "LISTAS")
textRow(pickPage, "Whitelist", "PickupWhitelist", "ej: money,ak,taser")
textRow(pickPage, "Blacklist", "PickupBlacklist", "ej: shovel,food")
new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.bg2,
    BorderSizePixel = 0, Font = Enum.Font.Gotham,
    Text = "Whitelist: solo agarra si el nombre contiene una palabra.\nBlacklist: nunca agarra si contiene una palabra.",
    TextColor3 = C.muted, TextSize = FONT_SMALL, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
    LayoutOrder = nextOrder(), Parent = pickPage,
})
local wlNote = pickPage:FindFirstChildWhichIsA("TextLabel")
if wlNote then
    corner(wlNote, 9)
    neonStroke(wlNote, C.border)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
        Parent = wlNote,
    })
end

-- HUD
local hudPage = pages["HUD"]
section(hudPage, "HUD")
toggle(hudPage, "Watermark", "HUDWatermark")
toggle(hudPage, "Stats (kills, pickups, tiempo)", "HUDStats")
toggle(hudPage, "FPS", "HUDFPS")
toggle(hudPage, "Ping", "HUDPing")
toggle(hudPage, "Playerlist", "HUDPlayerList")
section(hudPage, "PANEL")
slider(hudPage, "Opacidad panel", "PanelOpacity", 0.5, 1, true, function(v)
    panel.BackgroundTransparency = 1 - v
end)
toggle(hudPage, "Notificaciones", "Notifications")

-- SAFE
local safePage = pages["SAFE"]
section(safePage, "PROFILES")
actionBtn(safePage, "Guardar perfil 1", C.accent3, function()
    saveConfigTo(CONFIG_FOLDER .. "/profiles/p1.json", CFG)
    notify("Perfil", "Perfil 1 guardado", 3)
end)
actionBtn(safePage, "Cargar perfil 1", C.bg3, function()
    local data = loadConfigFrom(CONFIG_FOLDER .. "/profiles/p1.json")
    if data then
        for k, v in pairs(data) do if CFG[k] ~= nil or k == "ESPColor" then CFG[k] = v end end
        if type(CFG.ESPColor) == "table" then CFG.ESPColor = Color3.new(unpack(CFG.ESPColor)) end
        saveConfigTo(CONFIG_FILE, CFG)
        notify("Perfil", "Perfil 1 cargado (recargá el script)", 4)
    else
        notify("Perfil", "No existe el perfil 1", 3)
    end
end)
actionBtn(safePage, "Guardar perfil 2", C.accent3, function()
    saveConfigTo(CONFIG_FOLDER .. "/profiles/p2.json", CFG)
    notify("Perfil", "Perfil 2 guardado", 3)
end)
actionBtn(safePage, "Cargar perfil 2", C.bg3, function()
    local data = loadConfigFrom(CONFIG_FOLDER .. "/profiles/p2.json")
    if data then
        for k, v in pairs(data) do if CFG[k] ~= nil or k == "ESPColor" then CFG[k] = v end end
        if type(CFG.ESPColor) == "table" then CFG.ESPColor = Color3.new(unpack(CFG.ESPColor)) end
        saveConfigTo(CONFIG_FILE, CFG)
        notify("Perfil", "Perfil 2 cargado (recargá el script)", 4)
    else
        notify("Perfil", "No existe el perfil 2", 3)
    end
end)
section(safePage, "KEYBINDS")
keybindRow(safePage, "Apuntar (hold)", "HoldKey")
keybindRow(safePage, "Toggle aim", "ToggleKey")
keybindRow(safePage, "Panel", "PanelKey")
keybindRow(safePage, "Panic (desactiva todo)", "PanicKey")
section(safePage, "CONFIG")
actionBtn(safePage, "Guardar config ahora", C.accent3, function() saveConfigTo(CONFIG_FILE, CFG) end)
actionBtn(safePage, "Resetear config", C.danger, function()
    local d = defaultCfg()
    for k, v in pairs(d) do CFG[k] = v end
    CFG.ESPColor = Color3.new(unpack(DEFAULTS.ESPColor))
    CFG.FOVRadius = CFG.FOV
    CFG.HoldKey = resolveKey("MouseButton2", Enum.UserInputType.MouseButton2)
    CFG.ToggleKey = resolveKey("RightShift", Enum.KeyCode.RightShift)
    CFG.PanelKey = resolveKey("F1", Enum.KeyCode.F1)
    CFG.PanicKey = resolveKey("Delete", Enum.KeyCode.Delete)
    saveConfigTo(CONFIG_FILE, CFG)
    notify("Config", "Reseteada", 3)
end)
section(safePage, "PANEL")
actionBtn(safePage, "Centrar panel", C.bg3, function()
    panel.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
end)
actionBtn(safePage, "Limpiar ESP", C.bg3, function()
    for plr in pairs(pESP) do clearESP(plr) end
    for m in pairs(iESP) do clearItemESP(m) end
end)
actionBtn(safePage, "Reiniciar script", C.danger, function()
    espScreen:Destroy(); hudScreen:Destroy()
    if drawSnapline then pcall(function() drawSnapline:Remove() end) end
    if drawHeadDot then pcall(function() drawHeadDot:Remove() end) end
    for plr in pairs(pESP) do clearESP(plr) end
    for m in pairs(iESP) do clearItemESP(m) end
    sg:Destroy()
    getgenv().BSS_AimV16 = false
end)

selectTab("AIM")

-- footer
local footer = new("Frame", {
    Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 12, 1, -32),
    BackgroundColor3 = C.bg2, BorderSizePixel = 0, Parent = panel,
})
corner(footer, 8)
neonStroke(footer, C.border)
new("TextLabel", {
    Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1, Font = Enum.Font.Gotham,
    Text = IS_PC and "F1 panel · RMB apunta · panic = DELETE · auto-save ON" or "X = panel · AIM = toggle · panic = DELETE",
    TextColor3 = C.muted, TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = footer,
})

-- drag
local function makeDrag(f, h)
    local d, s, p
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            d = true; s = i.Position; p = f.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local dl = i.Position - s
            f.Position = UDim2.new(p.X.Scale, p.X.Offset + dl.X, p.Y.Scale, p.Y.Offset + dl.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then d = false end
    end)
end
makeDrag(panel, header)

-- mini
miniBtn = new("TextButton", {
    Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0, 20, 0, 100),
    BackgroundColor3 = C.bg, BorderSizePixel = 0, Text = "X",
    TextColor3 = C.accent, TextSize = 26, Font = Enum.Font.GothamBold,
    AutoButtonColor = false, Active = true, Selectable = true,
    Visible = true, ZIndex = 200, Parent = sg,
})
corner(miniBtn, 28)
neonStroke(miniBtn, C.accent)

local miniDragging, miniMoved, miniStartMouse, miniStartPos = false, false, nil, nil

miniBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true; miniMoved = false
        miniStartMouse = i.Position; miniStartPos = miniBtn.Position
        task.wait(0.08)
        if not miniMoved then
            panel.Visible = true
            panel.Size = UDim2.fromOffset(1, 1)
            local mp = miniBtn.AbsolutePosition
            panel.Position = UDim2.new(0, mp.X - W/2 + 28, 0, mp.Y)
            TweenService:Create(panel,
                TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(W, H) }):Play()
            miniBtn.Visible = false
        end
    end
end)
UIS.InputChanged:Connect(function(i)
    if miniDragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
        local dl = i.Position - miniStartMouse
        if math.abs(dl.X) > 15 or math.abs(dl.Y) > 15 then miniMoved = true end
        if miniMoved then
            miniBtn.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + dl.X,
                                          miniStartPos.Y.Scale, miniStartPos.Y.Offset + dl.Y)
        end
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then miniDragging = false end
end)

pcall(function()
    miniBtn.Activated:Connect(function()
        if miniMoved then return end
        panel.Visible = true
        panel.Size = UDim2.fromOffset(1, 1)
        local mp = miniBtn.AbsolutePosition
        panel.Position = UDim2.new(0, mp.X - W/2 + 28, 0, mp.Y)
        TweenService:Create(panel,
            TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(W, H) }):Play()
        miniBtn.Visible = false
    end)
end)

local function togglePanel()
    if panel.Visible then
        local fromP = panel.AbsolutePosition
        local tw = TweenService:Create(panel,
            TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            { Size = UDim2.fromOffset(1, 1) })
        tw:Play()
        tw.Completed:Connect(function()
            panel.Visible = false
            panel.Size = UDim2.fromOffset(W, H)
            miniBtn.Position = UDim2.new(0, fromP.X + W - 56, 0, fromP.Y + 4)
            miniBtn.Size = UDim2.fromOffset(1, 1)
            miniBtn.Visible = true
            miniBtn.ZIndex = 200
            TweenService:Create(miniBtn,
                TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(56, 56) }):Play()
        end)
    else
        miniBtn.Visible = false
        panel.Visible = true
        panel.Size = UDim2.fromOffset(1, 1)
        TweenService:Create(panel,
            TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(W, H) }):Play()
    end
end

minBtn.MouseButton1Click:Connect(togglePanel)

closeBtn.MouseButton1Click:Connect(function()
    espScreen:Destroy(); hudScreen:Destroy()
    if drawSnapline then pcall(function() drawSnapline:Remove() end) end
    if drawHeadDot then pcall(function() drawHeadDot:Remove() end) end
    for plr in pairs(pESP) do clearESP(plr) end
    for m in pairs(iESP) do clearItemESP(m) end
    sg:Destroy()
    getgenv().BSS_AimV16 = false
end)

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.PanelKey then togglePanel() end
end)

-- ============ PLAYERLIST RENDER ============
local playerRows = {}
local function refreshPlayerList()
    if not CFG.HUDPlayerList then
        for _, r in pairs(playerRows) do r:Destroy() end
        playerRows = {}
        playerListFrame.Visible = false
        return
    end
    playerListFrame.Visible = true
    local current = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        current[plr] = true
        if not playerRows[plr] then
            local r = Instance.new("Frame")
            r.Size = UDim2.new(1, 0, 0, 26)
            r.BackgroundColor3 = C.bg3
            r.BorderSizePixel = 0
            r.Parent = plScroll
            Instance.new("UICorner", r).CornerRadius = UDim.new(0, 6)
            local nameL = Instance.new("TextLabel")
            nameL.Name = "Name"
            nameL.Size = UDim2.new(1, -8, 1, 0)
            nameL.Position = UDim2.new(0, 6, 0, 0)
            nameL.BackgroundTransparency = 1
            nameL.Font = Enum.Font.GothamBold
            nameL.TextSize = 11
            nameL.TextColor3 = C.fg
            nameL.TextXAlignment = Enum.TextXAlignment.Left
            nameL.Text = ""
            nameL.Parent = r
            playerRows[plr] = r
        end
        local row = playerRows[plr]
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hpStr = hum and string.format("%d", math.floor(hum.Health)) or "—"
        local dStr = hrp and string.format("%dm", math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)) or "—"
        local nl = row:FindFirstChild("Name")
        if nl then
            nl.Text = string.format("%s  ·  HP %s  ·  %s", plr.Name, hpStr, dStr)
            if hum then
                local r2 = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                if r2 > 0.6 then nl.TextColor3 = C.hp
                elseif r2 > 0.3 then nl.TextColor3 = Color3.fromRGB(240, 200, 80)
                else nl.TextColor3 = C.danger end
            end
        end
    end
    for plr, r in pairs(playerRows) do
        if not current[plr] then r:Destroy(); playerRows[plr] = nil end
    end
end

-- ============ MAIN LOOP ============
local SWITCH_HYSTERESIS = 40
local SWITCH_COOLDOWN = 0.25

RunService.RenderStepped:Connect(function(dt)
    -- FPS
    fpsCount += 1
    if tick() - fpsTimer >= 1 then
        currentFPS = fpsCount
        fpsCount = 0
        fpsTimer = tick()
    end

    -- RENDER (throttle) — solo si estamos listos
    local alive = CFG.Enabled and (aimOn or CFG.TriggerBot or CFG.AutoFire)
    -- auto-target
    if aimOn or CFG.TriggerBot or CFG.AutoFire then
        if CFG.AimOnFireOnly and not aimOn then
            -- no cambiar
        else
            local _, bestPart = getTargetWithScore()
            if targetDead() then
                if bestPart then currentTarget = bestPart; lastSwitch = tick()
                else currentTarget = nil end
            elseif bestPart and bestPart ~= currentTarget then
                local curPx = targetPx()
                local _, _, bestScore = getTargetWithScore()
                if bestScore + SWITCH_HYSTERESIS < curPx
                    and (tick() - lastSwitch) > SWITCH_COOLDOWN then
                    currentTarget = bestPart
                    lastSwitch = tick()
                end
            end
        end
    else
        if not (CFG.TriggerBot or CFG.AutoFire) then
            currentTarget = nil
        end
    end

    if IS_MOBILE and aimBtn then
        if currentTarget then aimBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        elseif aimOn then aimBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
        else aimBtn.BackgroundColor3 = Color3.fromRGB(15, 17, 24) end
    end

    -- FOV
    if CFG.DrawFOV and CFG.Enabled and aimOn then
        fovCircle.Position = UDim2.fromScale(0.5, 0.5)
        fovCircle.Size = UDim2.fromOffset(CFG.FOVRadius * 2, CFG.FOVRadius * 2)
        fovStroke.Color = currentTarget and C.aimLock or C.accent
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end

    -- Head dot + snapline (PC)
    if IS_PC then
        if CFG.HeadDotESP and CFG.Enabled and currentTarget then
            local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
            if on and drawHeadDot then
                drawHeadDot.Position = Vector2.new(sp.X, sp.Y)
                drawHeadDot.Radius = 6
                drawHeadDot.Color = C.aimLock
                drawHeadDot.Visible = true
            elseif drawHeadDot then drawHeadDot.Visible = false end
        elseif drawHeadDot then drawHeadDot.Visible = false end

        if CFG.SnaplineESP and CFG.Enabled and currentTarget and drawSnapline then
            local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
            if on then
                drawSnapline.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                drawSnapline.To = Vector2.new(sp.X, sp.Y)
                drawSnapline.Color = CFG.ESPColor
                drawSnapline.Visible = true
            else drawSnapline.Visible = false end
        elseif drawSnapline then drawSnapline.Visible = false end
    end

    -- CAMERA LOCK
    if CFG.Enabled and aimOn and currentTarget and CFG.CameraLock then
        local camPos = Camera.CFrame.Position
        local tPos
        if IS_PC and CFG.Prediction > 0 then
            local plr = Players:GetPlayerFromCharacter(currentTarget.Parent)
            if plr then tPos = predictPos(plr, currentTarget, dt) else tPos = currentTarget.Position end
        else
            tPos = currentTarget.Position
        end
        local desired = CFrame.lookAt(camPos, tPos)
        Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(CFG.LockSnap, 0, 1))
    end

    pcall(tryFire)
end)

-- loops throttled
task.spawn(function()
    while getgenv().BSS_AimV16 do
        pcall(updatePlayerESP)
        pcall(updateItemESP)
        pcall(tryPickup)
        pcall(trackKills)
        task.wait(CFG.ESPRefresh)
    end
end)

task.spawn(function()
    while getgenv().BSS_AimV16 do
        pcall(refreshPlayerList)
        task.wait(0.5)
    end
end)

-- HUD refresh
task.spawn(function()
    while getgenv().BSS_AimV16 do
        -- watermark
        watermark.Visible = CFG.HUDWatermark
        if CFG.HUDWatermark then
            wmLabel.Text = string.format("BSS-Aim v16 · %s", IS_PC and "PC" or "Mobile")
        end
        -- stats
        statsHUD.Visible = CFG.HUDStats or CFG.HUDFPS or CFG.HUDPing
        if statsHUD.Visible then
            local minutes = math.floor((tick() - sessionStart) / 60)
            local lines = {}
            if CFG.HUDStats then
                lines[#lines+1] = string.format("Kills:    %d", sessionKills)
                lines[#lines+1] = string.format("Pickups:  %d", sessionPickups)
                lines[#lines+1] = string.format("Session:  %dm", minutes)
            end
            if CFG.HUDFPS then lines[#lines+1] = string.format("FPS:      %d", currentFPS) end
            if CFG.HUDPing then lines[#lines+1] = string.format("Ping:     %dms", getPing()) end
            stLabel.Text = table.concat(lines, "\n")
            local h = 20 + #lines * 16
            statsHUD.Size = UDim2.fromOffset(180, h)
        end
        task.wait(0.5)
    end
end)

notify("BSS-Aim v16", (IS_PC and "PC tryhard" or "Mobile") ..
    " · auto-save " .. (HAVE_FILE_IO and "ON" or "OFF"), 6)

print("[BSS-Aim v16] cargado — " .. (IS_PC and "PC tryhard" or "mobile") ..
      " · auto-save " .. (HAVE_FILE_IO and "ON" or "OFF"))
