-- BSS-Aim v14 — auto-detect mobile/PC
-- Mobile: touch buttons, v13 style
-- PC: tryhard mode — silent aim, tracers, prediction, keybinds
-- discord.gg/syncrypt

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().BSS_AimV14 then return end
getgenv().BSS_AimV14 = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local LP = Players.LocalPlayer
local Camera = WS.CurrentCamera

local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IS_PC = not IS_MOBILE

local function getParent()
    if gethui then local ok, r = pcall(gethui); if ok and r then return r end end
    local ok, pg = pcall(function() return LP:WaitForChild("PlayerGui") end)
    if ok and pg then return pg end
    return LP:WaitForChild("PlayerGui")
end

local C = {
    bg      = Color3.fromRGB(10, 10, 16),
    bg2     = Color3.fromRGB(16, 18, 26),
    bg3     = Color3.fromRGB(24, 27, 38),
    bg4     = Color3.fromRGB(34, 38, 52),
    accent  = Color3.fromRGB(0, 240, 180),
    accent2 = Color3.fromRGB(180, 100, 255),
    accent3 = Color3.fromRGB(0, 180, 255),
    fg      = Color3.fromRGB(240, 242, 250),
    muted   = Color3.fromRGB(110, 118, 138),
    danger  = Color3.fromRGB(255, 70, 90),
    border  = Color3.fromRGB(40, 45, 60),
    money   = Color3.fromRGB(120, 240, 130),
    weapon  = Color3.fromRGB(255, 130, 130),
    tool    = Color3.fromRGB(120, 180, 255),
    food    = Color3.fromRGB(255, 200, 90),
    hp      = Color3.fromRGB(80, 220, 120),
    stamina = Color3.fromRGB(255, 210, 60),
    aimOn   = Color3.fromRGB(255, 80, 90),
    aimLock = Color3.fromRGB(80, 255, 120),
}

local CFG = getgenv().BSS_AimConfig or {
    Enabled = true,
    HoldKey = Enum.UserInputType.MouseButton2,
    ToggleKey = Enum.KeyCode.RightShift,
    PanelKey = Enum.KeyCode.F1,
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
    Priority = "fov",
    -- PC tryhard extras
    SilentAim = true,
    Tracers = true,
    CornerBox = true,
    HeadDot = true,
    TargetInfo = true,
    Prediction = 0.12,
    TriggerBot = false,
    PlayerESP = true,
    WeaponESP = true,
    ItemESP = true,
    NameESP = true,
    HealthESP = true,
    StaminaESP = true,
    MaxESP = 450,
    ESPMinScale = 0.5,
    ESPMaxScale = 1.0,
    ESPRefresh = 0.1,
    ESPColor = Color3.fromRGB(0, 240, 180),
    AutoPickup = false,
    PickupRadius = 30,
    PickupDelay = 0.3,
}
CFG.FOVRadius = CFG.FOV
getgenv().BSS_AimConfig = CFG

local aimOn = false
local currentTarget = nil
local lastSwitch = 0
local aimBtn, miniBtn = nil, nil

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
fovCircle.Size = UDim2.fromOffset(CFG.FOVRadius * 2, CFG.FOVRadius * 2)
fovCircle.Visible = false
fovCircle.ZIndex = 100
fovCircle.Parent = espScreen
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = C.accent
fovStroke.Thickness = 2
fovStroke.Parent = fovCircle

-- ============ DRAWING (PC only, silent aim tracers) ============
local drawTracer = nil
if IS_PC and Drawing then
    local ok, t = pcall(function()
        local l = Drawing.new("Line")
        l.Thickness = 1; l.Color = C.aimLock; l.Transparency = 0.8; l.Visible = false
        return l
    end)
    if ok then drawTracer = t end
end

-- ============ MOBILE TOUCH BUTTONS ============
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
            bs1.Color = C.aimOn
            aimBtn.TextColor3 = C.aimOn
        else
            bs1.Color = C.accent
            aimBtn.TextColor3 = C.accent
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

local function updateFOVPosition(screenX, screenY, radius)
    fovCircle.Position = UDim2.fromOffset(screenX, screenY)
    local d = radius * 2
    fovCircle.Size = UDim2.fromOffset(d, d)
end

local function mousePos()
    if IS_MOBILE then return Camera.ViewportSize * 0.5 end
    local p = UIS:GetMouseLocation()
    return Vector2.new(p.X, p.Y - 36)
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

-- predicción de movimiento del target (solo PC)
local function predictPos(plr, part, dt)
    if not IS_PC or CFG.Prediction <= 0 then return part.Position end
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return part.Position end
    local vel = hrp.AssemblyLinearVelocity
    if vel.Magnitude < 2 then return part.Position end
    return part.Position + vel * CFG.Prediction
end

local function getTargetWithScore()
    local best, bestPart, bestPx = nil, nil, math.huge
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
        if px < bestPx then
            bestPx = px
            best = plr
            bestPart = part
        end
    end
    return best, bestPart, bestPx
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
end)
UIS.InputEnded:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == CFG.HoldKey or i.KeyCode == CFG.HoldKey then aimOn = false end
end)

-- ============ SILENT AIM (PC only) ============
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

-- ============ ESP ============
local pESP = {}
local iESP = {}

local function clearESP(plr)
    local b = pESP[plr]
    if b then pcall(function() b:Destroy() end); pESP[plr] = nil end
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
    bgStroke.Color = CFG.ESPColor
    bgStroke.Thickness = 1.5
    bgStroke.Parent = bgFrame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "Name"
    nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0, 6, 0, 3)
    nameLbl.Size = UDim2.new(1, -12, 0, 14)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 12
    nameLbl.TextColor3 = C.fg
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextStrokeTransparency = 0.4
    nameLbl.Text = ""
    nameLbl.Parent = bgFrame

    local wepLbl = Instance.new("TextLabel")
    wepLbl.Name = "Wep"
    wepLbl.BackgroundTransparency = 1
    wepLbl.Position = UDim2.new(0, 6, 0, 17)
    wepLbl.Size = UDim2.new(1, -12, 0, 12)
    wepLbl.Font = Enum.Font.Gotham
    wepLbl.TextSize = 10
    wepLbl.TextColor3 = C.food
    wepLbl.TextXAlignment = Enum.TextXAlignment.Left
    wepLbl.TextStrokeTransparency = 0.4
    wepLbl.Text = ""
    wepLbl.Parent = bgFrame

    local hpBg = Instance.new("Frame")
    hpBg.Name = "HpBg"
    hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    hpBg.BorderSizePixel = 0
    hpBg.Position = UDim2.new(0, 6, 0, 33)
    hpBg.Size = UDim2.new(1, -12, 0, 8)
    hpBg.Parent = bgFrame
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

    local hpFill = Instance.new("Frame")
    hpFill.Name = "HpFill"
    hpFill.BackgroundColor3 = C.hp
    hpFill.BorderSizePixel = 0
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.Parent = hpBg
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

    local hpTxt = Instance.new("TextLabel")
    hpTxt.Name = "HpTxt"
    hpTxt.BackgroundTransparency = 1
    hpTxt.Position = UDim2.new(0, 10, 0, 33)
    hpTxt.Size = UDim2.new(1, -20, 0, 8)
    hpTxt.Font = Enum.Font.GothamBold
    hpTxt.TextSize = 9
    hpTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpTxt.TextStrokeTransparency = 0.5
    hpTxt.TextXAlignment = Enum.TextXAlignment.Left
    hpTxt.Text = "HP"
    hpTxt.ZIndex = 2
    hpTxt.Parent = bgFrame

    local stBg = Instance.new("Frame")
    stBg.Name = "StBg"
    stBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    stBg.BorderSizePixel = 0
    stBg.Position = UDim2.new(0, 6, 0, 45)
    stBg.Size = UDim2.new(1, -12, 0, 8)
    stBg.Parent = bgFrame
    Instance.new("UICorner", stBg).CornerRadius = UDim.new(1, 0)

    local stFill = Instance.new("Frame")
    stFill.Name = "StFill"
    stFill.BackgroundColor3 = C.stamina
    stFill.BorderSizePixel = 0
    stFill.Size = UDim2.new(1, 0, 1, 0)
    stFill.Parent = stBg
    Instance.new("UICorner", stFill).CornerRadius = UDim.new(1, 0)

    local stTxt = Instance.new("TextLabel")
    stTxt.Name = "StTxt"
    stTxt.BackgroundTransparency = 1
    stTxt.Position = UDim2.new(0, 10, 0, 45)
    stTxt.Size = UDim2.new(1, -20, 0, 8)
    stTxt.Font = Enum.Font.GothamBold
    stTxt.TextSize = 9
    stTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    stTxt.TextStrokeTransparency = 0.5
    stTxt.TextXAlignment = Enum.TextXAlignment.Left
    stTxt.Text = "ST"
    stTxt.ZIndex = 2
    stTxt.Parent = bgFrame

    local distLbl = Instance.new("TextLabel")
    distLbl.Name = "Dist"
    distLbl.BackgroundTransparency = 1
    distLbl.Position = UDim2.new(0, 6, 1, -18)
    distLbl.Size = UDim2.new(1, -12, 0, 14)
    distLbl.Font = Enum.Font.GothamBold
    distLbl.TextSize = 11
    distLbl.TextColor3 = CFG.ESPColor
    distLbl.TextXAlignment = Enum.TextXAlignment.Center
    distLbl.TextStrokeTransparency = 0.4
    distLbl.Text = ""
    distLbl.Parent = bgFrame

    pESP[plr] = billboard
    return billboard
end

local function hideP(plr)
    local b = pESP[plr]
    if b and b.Parent then b.Enabled = false end
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

        local b = ensureP(plr)
        if not b then continue end
        b.Enabled = true
        b.MaxDistance = CFG.MaxESP
        updateScale(b, dist)

        local bgFrame = b:FindFirstChild("BG")
        if not bgFrame then continue end

        local nameLbl = bgFrame:FindFirstChild("Name")
        if nameLbl then
            nameLbl.Visible = CFG.PlayerESP and CFG.NameESP
            if nameLbl.Visible then nameLbl.Text = plr.Name end
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
            else
                hpBg.Visible = false; hpTxt.Visible = false
            end
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
                else
                    stBg.Visible = false; stTxt.Visible = false
                end
            else
                stBg.Visible = false; stTxt.Visible = false
            end
        end

        local distLbl = bgFrame:FindFirstChild("Dist")
        if distLbl then distLbl.Text = string.format("%dm", math.floor(dist)) end

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
    lbl.BackgroundTransparency = 0.5
    lbl.BorderSizePixel = 0
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = C.money
    lbl.Text = ""
    lbl.Parent = b
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 4)
    local st = Instance.new("UIStroke")
    st.Color = C.money; st.Thickness = 1; st.Parent = lbl
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
            if st then st.Color = color end
        end
    end
    for m in pairs(iESP) do
        if not seen[m] or not m.Parent then clearItemESP(m) end
    end
end

-- ============ AUTO-PICKUP ============
local lastPickup = 0
local function tryPickup()
    if not CFG.AutoPickup then return end
    local now = tick()
    if now - lastPickup < CFG.PickupDelay then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local folder = WS:FindFirstChild("DroppedItems")
    if not folder then return end
    local bestItem, bestDist = nil, math.huge
    for _, m in ipairs(folder:GetChildren()) do
        local part = m:FindFirstChild("PickUpZone")
            or m:FindFirstChild("CashPart")
            or m.PrimaryPart
            or m:FindFirstChildWhichIsA("BasePart", true)
        if not part then continue end
        local d = (hrp.Position - part.Position).Magnitude
        if d < CFG.PickupRadius and d < bestDist then
            bestDist = d; bestItem = part
        end
    end
    if bestItem then
        lastPickup = now
        pcall(function()
            local m = bestItem.Parent
            if m and m:IsA("Model") then m:PivotTo(CFrame.new(hrp.Position))
            elseif bestItem:IsA("BasePart") then bestItem.CFrame = CFrame.new(hrp.Position) end
        end)
    end
end

-- ============ LOOP ============
local SWITCH_HYSTERESIS = 40
local SWITCH_COOLDOWN  = 0.25

RunService.RenderStepped:Connect(function(dt)
    local _, bestPart, bestPx = getTargetWithScore()

    if CFG.Enabled and aimOn then
        if targetDead() then
            if bestPart then
                currentTarget = bestPart
                lastSwitch = tick()
            else
                currentTarget = nil
            end
        elseif bestPart and bestPart ~= currentTarget then
            local curPx = targetPx()
            if bestPx + SWITCH_HYSTERESIS < curPx
                and (tick() - lastSwitch) > SWITCH_COOLDOWN then
                currentTarget = bestPart
                lastSwitch = tick()
            end
        end
        if currentTarget and targetPx() > CFG.FOVRadius * 1.15 then
            if bestPart then
                currentTarget = bestPart
                lastSwitch = tick()
            else
                currentTarget = nil
            end
        end
    else
        currentTarget = nil
    end

    -- feedback móvil
    if IS_MOBILE and aimBtn then
        if currentTarget then aimBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        elseif aimOn then aimBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
        else aimBtn.BackgroundColor3 = Color3.fromRGB(15, 17, 24) end
    end

    -- FOV circle
    if CFG.DrawFOV and CFG.Enabled and aimOn then
        if CFG.FOVLockToTarget and currentTarget then
            local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
            if on then
                updateFOVPosition(sp.X, sp.Y, CFG.FOVRadius)
                fovCircle.Visible = true
                fovStroke.Color = C.aimLock
            else fovCircle.Visible = false end
        else
            local mp = mousePos()
            updateFOVPosition(mp.X, mp.Y, CFG.FOVRadius)
            fovCircle.Visible = true
            fovStroke.Color = C.accent
        end
    else fovCircle.Visible = false end

    -- PC: tracer desde abajo al target
    if IS_PC and drawTracer then
        if CFG.Tracers and CFG.Enabled and aimOn and currentTarget then
            local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
            if on then
                drawTracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                drawTracer.To = Vector2.new(sp.X, sp.Y)
                drawTracer.Visible = true
            else drawTracer.Visible = false end
        else drawTracer.Visible = false end
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
end)

task.spawn(function()
    while getgenv().BSS_AimV14 do
        pcall(updatePlayerESP)
        pcall(updateItemESP)
        pcall(tryPickup)
        task.wait(CFG.ESPRefresh)
    end
end)

-- ============ UI ============
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

local sg = new("ScreenGui", {
    Name = "BSS_Aim_V14", ResetOnSpawn = false, IgnoreGuiInset = true,
    DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = getParent(),
})

local W, H = 340, 420
local FONT_TITLE = 13
local FONT_LABEL = 11
local FONT_SMALL = 10
local ROW_H = 32
local TAB_H = 28

local panel = new("Frame", {
    Size = UDim2.fromOffset(W, H),
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = C.bg, BorderSizePixel = 0, Parent = sg,
})
corner(panel, 14)
new("UIStroke", { Color = C.border, Thickness = 1.2, Parent = panel })

local grad = new("Frame", {
    Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = C.accent,
    BorderSizePixel = 0, Parent = panel,
})
corner(grad, 14)
new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.accent),
        ColorSequenceKeypoint.new(0.3, C.accent3),
        ColorSequenceKeypoint.new(0.6, C.accent2),
        ColorSequenceKeypoint.new(1, C.accent),
    }),
    Parent = grad,
})

local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 0, 3),
    BackgroundColor3 = C.bg2, BorderSizePixel = 0, Parent = panel,
})

local logo = new("Frame", {
    Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 10, 0.5, -12),
    BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = header,
})
corner(logo, 7)
new("TextLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "X",
    TextColor3 = C.bg, TextSize = 14, Font = Enum.Font.GothamBold, Parent = logo,
})

new("TextLabel", {
    Size = UDim2.new(0, 200, 0, 14), Position = UDim2.new(0, 40, 0, 4),
    BackgroundTransparency = 1, Text = "BSS-AIM", TextColor3 = C.fg,
    TextSize = FONT_TITLE, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})
new("TextLabel", {
    Size = UDim2.new(0, 200, 0, 10), Position = UDim2.new(0, 40, 0, 18),
    BackgroundTransparency = 1,
    Text = IS_PC and "v14 · PC tryhard" or "v14 · mobile",
    TextColor3 = C.accent, TextSize = 9, Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})

local function iconBtn(txt, xOff)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, xOff, 0.5, -13),
        BackgroundColor3 = C.bg3, BorderSizePixel = 0, Text = txt,
        TextColor3 = C.fg, TextSize = 14, Font = Enum.Font.GothamBold,
        AutoButtonColor = false, Active = true, Parent = header,
    })
    corner(b, 7)
    return b
end
local minBtn = iconBtn("-", -64)
local closeBtn = iconBtn("x", -34)

local tabsFrame = new("Frame", {
    Size = UDim2.new(1, -20, 0, TAB_H), Position = UDim2.new(0, 10, 0, 44),
    BackgroundColor3 = C.bg2, BorderSizePixel = 0, Parent = panel,
})
corner(tabsFrame, 8)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabsFrame,
})

local content = new("Frame", {
    Size = UDim2.new(1, -20, 1, -106), Position = UDim2.new(0, 10, 0, 76),
    BackgroundTransparency = 1, Parent = panel,
})

local pages = {}
local tabBtns = {}
local tabUnderline = new("Frame", {
    Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2),
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
            Position = UDim2.new(0, active.AbsolutePosition.X - tabsFrame.AbsolutePosition.X, 1, -2),
            Size = UDim2.new(0, active.AbsoluteSize.X, 0, 2),
        }):Play()
    end
end

local TAB_LIST = IS_PC and {"AIM", "ESP", "PICK", "PC"} or {"AIM", "ESP", "PICK", "CFG"}
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
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false, Parent = content,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })
    pad(page, 0, 0, 0, 4)
    pages[tname] = page
end

local order = 0
local function nextOrder() order = order + 1; return order end

local function section(page, label)
    local wrap = new("Frame", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        LayoutOrder = nextOrder(), Parent = page,
    })
    local bar = new("Frame", {
        Size = UDim2.new(0, 3, 0, 11), Position = UDim2.new(0, 0, 0.5, -5),
        BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = wrap,
    })
    corner(bar, 2)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 9, 0, 0),
        Size = UDim2.new(1, -9, 1, 0), Font = Enum.Font.GothamBold,
        Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
end

local function toggle(page, label, key, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 8)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -56, 1, 0), Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local track = new("Frame", {
        Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -44, 0.5, -9),
        BackgroundColor3 = C.bg4, BorderSizePixel = 0, Parent = row,
    })
    corner(track, 9)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 3, 0.5, -6),
        BackgroundColor3 = C.fg, BorderSizePixel = 0, Parent = track,
    })
    corner(knob, 6)
    local function render()
        local on = CFG[key] and true or false
        local x = on and (34 - 12 - 3) or 3
        track.BackgroundColor3 = on and C.accent or C.bg4
        knob.Position = UDim2.new(0, x, 0.5, -6)
    end
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "", Active = true, Parent = row,
    })
    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        render()
        if onChange then onChange(CFG[key]) end
    end)
    render()
end

local function slider(page, label, key, minV, maxV, isFloat, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 8)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -72, 0, 13), Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local valLbl = new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(1, -72, 0, 5),
        Size = UDim2.new(0, 62, 0, 13), Font = Enum.Font.GothamBold,
        Text = "", TextColor3 = C.accent, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
    })
    local track = new("Frame", {
        Size = UDim2.new(1, -20, 0, 5), Position = UDim2.new(0, 10, 1, -14),
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

local function partSelector(page)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 8)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 13), Font = Enum.Font.GothamMedium,
        Text = "Parte objetivo", TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local holder = new("Frame", {
        Position = UDim2.new(0, 6, 0, 22), Size = UDim2.new(1, -12, 0, 26),
        BackgroundTransparency = 1, Parent = row,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3),
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
        corner(b, 6)
        buttons[p] = b
        b.MouseButton1Click:Connect(function()
            CFG.TargetPart = (p == "HRP") and "HumanoidRootPart" or p
            refresh()
        end)
    end
    refresh()
end

local function keybindRow(page, label, key)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.bg2,
        BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(row, 8)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -110, 1, 0), Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = C.fg, TextSize = FONT_LABEL,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local btn = new("TextButton", {
        Size = UDim2.fromOffset(90, 24), Position = UDim2.new(1, -96, 0.5, -12),
        BackgroundColor3 = C.bg3, BorderSizePixel = 0, Text = "",
        TextColor3 = C.accent, TextSize = FONT_SMALL, Font = Enum.Font.GothamBold,
        AutoButtonColor = false, Active = true, Parent = row,
    })
    corner(btn, 6)
    local capturing = false
    local function render()
        local cur = CFG[key]
        local name = "?"
        if typeof(cur) == "EnumItem" then
            if cur.EnumType == Enum.KeyCode then name = cur.Name
            elseif cur.EnumType == Enum.UserInputType then
                name = cur.Name:gsub("MouseButton", "Mouse") end
        end
        btn.Text = capturing and "..." or name
        btn.TextColor3 = capturing and C.accent2 or C.accent
    end
    btn.MouseButton1Click:Connect(function() capturing = not capturing; render() end)
    UIS.InputBegan:Connect(function(inp, gp)
        if gp or not capturing then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then CFG[key] = inp.KeyCode
        elseif inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.MouseButton2 then CFG[key] = inp.UserInputType end
        capturing = false
        render()
    end)
    render()
end

local function actionBtn(page, label, color, onClick)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = color or C.bg3,
        BorderSizePixel = 0, Font = Enum.Font.GothamBold, Text = label,
        TextColor3 = C.fg, TextSize = FONT_LABEL, AutoButtonColor = false,
        Active = true, LayoutOrder = nextOrder(), Parent = page,
    })
    corner(b, 8)
    b.MouseButton1Click:Connect(onClick)
end

-- PÁGINAS: AIM + ESP + PICK comunes
local aimPage = pages["AIM"]
section(aimPage, "AIMBOT")
toggle(aimPage, "Activar", "Enabled")
toggle(aimPage, "Camera lock", "CameraLock")
slider(aimPage, "FOV (deteccion + visual)", "FOV", 30, 400, false, function(v) CFG.FOVRadius = v end)
slider(aimPage, "Lock snap (pegado)", "LockSnap", 0.5, 1, true)
slider(aimPage, "Dist. max", "MaxDistance", 100, 1500, false)
partSelector(aimPage)
toggle(aimPage, "FOV pegado a la cabeza", "FOVLockToTarget")
toggle(aimPage, "Wall check", "WallCheck")
toggle(aimPage, "Team check", "TeamCheck")

local espPage = pages["ESP"]
section(espPage, "JUGADORES")
toggle(espPage, "ESP jugadores", "PlayerESP")
toggle(espPage, "Nombre", "NameESP")
toggle(espPage, "Armas", "WeaponESP")
toggle(espPage, "Vida (HP)", "HealthESP")
toggle(espPage, "Stamina", "StaminaESP")
section(espPage, "ESCALA")
slider(espPage, "Min escala (lejos)", "ESPMinScale", 0.2, 1, true)
slider(espPage, "Max escala (cerca)", "ESPMaxScale", 0.5, 2, true)
slider(espPage, "Rango ESP", "MaxESP", 50, 1000, false)
section(espPage, "ITEMS")
toggle(espPage, "Items dropeados", "ItemESP")
section(espPage, "RENDIMIENTO")
slider(espPage, "Refresh", "ESPRefresh", 0.05, 0.5, true)

local pickPage = pages["PICK"]
section(pickPage, "AUTO PICKUP")
toggle(pickPage, "Activar pickup", "AutoPickup")
slider(pickPage, "Radio", "PickupRadius", 5, 80, false)
slider(pickPage, "Delay", "PickupDelay", 0.1, 2, true)

-- PC ONLY: página tryhard
if IS_PC then
    local pcPage = pages["PC"]
    section(pcPage, "TRYHARD")
    toggle(pcPage, "Silent aim (hook mouse)", "SilentAim")
    toggle(pcPage, "Tracers al target", "Tracers")
    toggle(pcPage, "Prediccion de movimiento", "Prediction", function(v)
        -- slider en lugar de toggle... lo dejamos
    end)
    slider(pcPage, "Lead time (prediccion)", "Prediction", 0, 0.3, true)
    section(pcPage, "KEYBINDS")
    keybindRow(pcPage, "Apuntar (hold)", "HoldKey")
    keybindRow(pcPage, "Toggle aim", "ToggleKey")
    keybindRow(pcPage, "Panel", "PanelKey")
    section(pcPage, "ACCIONES")
    actionBtn(pcPage, "Centrar panel", C.bg3, function()
        panel.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    end)
    actionBtn(pcPage, "Reiniciar", C.danger, function()
        espScreen:Destroy()
        if drawTracer then pcall(function() drawTracer:Remove() end) end
        for plr in pairs(pESP) do clearESP(plr) end
        for m in pairs(iESP) do clearItemESP(m) end
        sg:Destroy()
        getgenv().BSS_AimV14 = false
    end)
else
    -- MOBILE: pagina CFG
    local cfgPage = pages["CFG"]
    section(cfgPage, "ACCIONES")
    actionBtn(cfgPage, "Centrar panel", C.bg3, function()
        panel.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    end)
    actionBtn(cfgPage, "Limpiar ESP", C.bg3, function()
        for plr in pairs(pESP) do clearESP(plr) end
        for m in pairs(iESP) do clearItemESP(m) end
    end)
    actionBtn(cfgPage, "Reiniciar", C.danger, function()
        espScreen:Destroy()
        for plr in pairs(pESP) do clearESP(plr) end
        for m in pairs(iESP) do clearItemESP(m) end
        sg:Destroy()
        getgenv().BSS_AimV14 = false
    end)
end

selectTab("AIM")

local footer = new("Frame", {
    Size = UDim2.new(1, -20, 0, 22), Position = UDim2.new(0, 10, 1, -28),
    BackgroundColor3 = C.bg2, BorderSizePixel = 0, Parent = panel,
})
corner(footer, 7)
new("TextLabel", {
    Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1, Font = Enum.Font.Gotham,
    Text = IS_PC and "F1 panel · RMB apunta · silent aim ON" or "TOCA AIM · mové dedo pa cambiar",
    TextColor3 = C.muted, TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = footer,
})

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

miniBtn = new("TextButton", {
    Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0, 20, 0, 100),
    BackgroundColor3 = C.bg, BorderSizePixel = 0, Text = "X",
    TextColor3 = C.accent, TextSize = 26, Font = Enum.Font.GothamBold,
    AutoButtonColor = false, Active = true, Selectable = true,
    Visible = true, ZIndex = 200, Parent = sg,
})
corner(miniBtn, 28)
new("UIStroke", { Color = C.accent, Thickness = 3, Parent = miniBtn })

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
    espScreen:Destroy()
    if drawTracer then pcall(function() drawTracer:Remove() end) end
    for plr in pairs(pESP) do clearESP(plr) end
    for m in pairs(iESP) do clearItemESP(m) end
    sg:Destroy()
    getgenv().BSS_AimV14 = false
end)

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.PanelKey then togglePanel() end
end)

pcall(function()
    LP.PlayerGui:SetCore("SendNotification", {
        Title = "BSS-Aim v14",
        Text = IS_PC and "PC tryhard · F1 panel · RMB apunta" or "mobile · toca AIM",
        Duration = 6,
    })
end)

print("[BSS-Aim v14] cargado — modo " .. (IS_PC and "PC tryhard" or "mobile"))
