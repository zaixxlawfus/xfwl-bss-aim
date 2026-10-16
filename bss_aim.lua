-- BSS-Aim v3 — panel + aimbot + ESP (Frames, compatible Xeno)
-- discord.gg/syncrypt
-- RMB apuntar · RShift toggle · panel draggable · minimizable

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().BSS_AimLoaded then
    warn("[BSS-Aim] ya cargado")
    return
end
getgenv().BSS_AimLoaded = true

-- ============================================================
-- SERVICIOS
-- ============================================================
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Workspace    = game:GetService("Workspace")
local GuiService   = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera

local function getGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

-- ============================================================
-- CONFIG
-- ============================================================
local CFG = getgenv().BSS_AimConfig or {
    Enabled      = true,
    HoldKey      = Enum.UserInputType.MouseButton2,
    ToggleKey    = Enum.KeyCode.RightShift,
    FOV          = 140,
    Smoothness   = 0.20,
    MaxDistance  = 600,
    TargetPart   = "Head",
    TeamCheck    = true,
    WallCheck    = true,
    DrawFOV      = true,
    Priority     = "fov",
    PlayerESP    = true,
    WeaponESP    = true,
    ItemESP      = true,
    BoxESP       = true,
    MaxESP       = 700,
}
getgenv().BSS_AimConfig = CFG

local function mousePos()
    local p = UIS:GetMouseLocation()
    local inset = GuiService:GetGuiInset()
    return Vector2.new(p.X - inset.X, p.Y - inset.Y)
end

-- ============================================================
-- AIM CORE
-- ============================================================
local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum.Health > 0
end

local function sameTeam(plr)
    if not CFG.TeamCheck then return false end
    if not plr.Team or not LP.Team then return false end
    return plr.Team == LP.Team
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local function refreshFilter()
    local f = {Camera}
    if LP.Character then table.insert(f, LP.Character) end
    rayParams.FilterDescendantsInstances = f
end
refreshFilter()
if LP.Character then
    LP.CharacterAdded:Connect(function() task.wait(0.4); refreshFilter() end)
end

local function visible(targetPart, char)
    if not CFG.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local delta  = targetPart.Position - origin
    local hit = Workspace:Raycast(origin, delta, rayParams)
    if not hit then return true end
    if not hit.Instance then return true end
    return hit.Instance:IsDescendantOf(char)
end

local function getTarget()
    local best, bestMetric = nil, math.huge
    local center = Camera.ViewportSize * 0.5

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if sameTeam(plr) then continue end
        if not isAlive(plr) then continue end

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
        if px > CFG.FOV then continue end

        if CFG.WallCheck and not visible(part, char) then continue end

        local metric = px
        if CFG.Priority == "dist" then metric = d3 end
        if metric < bestMetric then
            bestMetric = metric
            best = part
        end
    end
    return best
end

local holding = false

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == CFG.HoldKey or input.KeyCode == CFG.HoldKey then
        holding = true
    elseif input.KeyCode == CFG.ToggleKey then
        CFG.Enabled = not CFG.Enabled
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == CFG.HoldKey or input.KeyCode == CFG.HoldKey then
        holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not CFG.Enabled or not holding then return end
    local target = getTarget()
    if not target then return end
    local desired = CFrame.new(Camera.CFrame.Position, target.Position)
    Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(CFG.Smoothness, 0, 1))
end)

-- ============================================================
-- ESP con FRAMES (compatible Xeno)
-- ============================================================
local guiParent = getGuiParent()

local espGui = Instance.new("ScreenGui")
espGui.Name = "BSS_Aim_ESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.DisplayOrder = 99
espGui.Parent = guiParent

-- contenedor para FOV circle (con Frame redondeado no queda perfecto, uso 4 líneas)
local fovGui = Instance.new("Frame")
fovGui.Name = "FOVCircle"
fovGui.BackgroundTransparency = 1
fovGui.Size = UDim2.fromOffset(0, 0)
fovGui.AnchorPoint = Vector2.new(0.5, 0.5)
fovGui.Visible = false
fovGui.ZIndex = 5
fovGui.Parent = espGui

-- dibujo un círculo aproximado con 2 líneas horizontales (top + bottom del círculo)
-- es una aproximación barata; si querés círculo real necesitás Drawing
local fovMarker = Instance.new("Frame")
fovMarker.Name = "Marker"
fovMarker.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
fovMarker.BorderSizePixel = 0
fovMarker.Size = UDim2.new(1, 0, 0, 1)
fovMarker.Position = UDim2.new(0, 0, 0, 0)
fovMarker.Parent = fovGui
local fovMarker2 = fovMarker:Clone()
fovMarker2.Position = UDim2.new(0, 0, 1, -1)
fovMarker2.Parent = fovGui

local playerESP = {}
local itemESP   = {}

local function newESPForPlayer(plr)
    local container = Instance.new("Frame")
    container.Name = "ESP_" .. plr.Name
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Visible = false
    container.ZIndex = 6
    container.Parent = espGui

    -- caja (4 líneas)
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.ZIndex = 6
    box.Parent = container
    local function edge(name, pos, size)
        local e = Instance.new("Frame")
        e.Name = name
        e.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
        e.BorderSizePixel = 0
        e.Position = pos
        e.Size = size
        e.ZIndex = 6
        e.Parent = box
        return e
    end
    edge("Top",    UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1))
    edge("Bottom", UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1))
    edge("Left",   UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0))
    edge("Right",  UDim2.new(1, -1, 0, 0), UDim2.new(0, 1, 1, 0))

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "Name"
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 14
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.TextStrokeTransparency = 0
    nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLbl.Size = UDim2.fromOffset(200, 16)
    nameLbl.AnchorPoint = Vector2.new(0.5, 0.5)
    nameLbl.Visible = false
    nameLbl.ZIndex = 7
    nameLbl.Parent = espGui

    local wepLbl = Instance.new("TextLabel")
    wepLbl.Name = "Weapons"
    wepLbl.BackgroundTransparency = 1
    wepLbl.Font = Enum.Font.Gotham
    wepLbl.TextSize = 13
    wepLbl.TextColor3 = Color3.fromRGB(255, 220, 120)
    wepLbl.TextStrokeTransparency = 0
    wepLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    wepLbl.Size = UDim2.fromOffset(260, 16)
    wepLbl.AnchorPoint = Vector2.new(0.5, 0.5)
    wepLbl.Visible = false
    wepLbl.ZIndex = 7
    wepLbl.Parent = espGui

    return {
        container = container,
        box       = box,
        name      = nameLbl,
        wep       = wepLbl,
    }
end

local function destroyPlayerESP(plr)
    local t = playerESP[plr]
    if not t then return end
    if t.container then t.container:Destroy() end
    if t.name then t.name:Destroy() end
    if t.wep then t.wep:Destroy() end
    playerESP[plr] = nil
end

local function getWeapons(plr)
    local list = {}
    local char = plr.Character
    if char then
        for _, c in ipairs(char:GetChildren()) do
            if c:IsA("Tool") then table.insert(list, c.Name) end
        end
    end
    local bp = plr:FindFirstChildOfClass("Backpack")
    if bp then
        for _, c in ipairs(bp:GetChildren()) do
            if c:IsA("Tool") and not table.find(list, c.Name) then
                table.insert(list, c.Name)
            end
        end
    end
    if #list == 0 then return nil end
    return table.concat(list, ", ")
end

local function projectBoundingBox(model)
    local ok, cf, size = pcall(function()
        local c, s = model:GetBoundingBox()
        return c, s
    end)
    if not ok or not cf then return nil end

    local corners = {}
    local hs = size * 0.5
    for xi = -1, 1, 2 do
        for yi = -1, 1, 2 do
            for zi = -1, 1, 2 do
                local wp = cf * Vector3.new(hs.X * xi, hs.Y * yi, hs.Z * zi)
                local sp, on = Camera:WorldToViewportPoint(wp)
                if on then table.insert(corners, Vector2.new(sp.X, sp.Y)) end
            end
        end
    end
    if #corners < 4 then return nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for _, p in ipairs(corners) do
        if p.X < minX then minX = p.X end
        if p.Y < minY then minY = p.Y end
        if p.X > maxX then maxX = p.X end
        if p.Y > maxY then maxY = p.Y end
    end
    return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

local function updatePlayerESP()
    local seen = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        seen[plr] = true

        if plr == LP or sameTeam(plr) then
            local t = playerESP[plr]
            if t then
                t.container.Visible = false
                t.name.Visible = false
                t.wep.Visible = false
            end
        else
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local valid = char and hum and hum.Health > 0

            if not valid then
                local t = playerESP[plr]
                if t then
                    t.container.Visible = false
                    t.name.Visible = false
                    t.wep.Visible = false
                end
            else
                local head = char:FindFirstChild("Head")
                local hrp  = char:FindFirstChild("HumanoidRootPart")
                if head and hrp then
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    if dist <= CFG.MaxESP and CFG.PlayerESP then
                        if not playerESP[plr] then
                            playerESP[plr] = newESPForPlayer(plr)
                        end
                        local t = playerESP[plr]

                        -- box
                        if CFG.BoxESP then
                            local tl, sz = projectBoundingBox(char)
                            if tl and sz then
                                t.container.Position = UDim2.fromOffset(tl.X, tl.Y)
                                t.container.Size = UDim2.fromOffset(sz.X, sz.Y)
                                t.container.Visible = true
                            else
                                t.container.Visible = false
                            end
                        else
                            t.container.Visible = false
                        end

                        -- name
                        local spN, onN = Camera:WorldToViewportPoint(
                            head.Position + Vector3.new(0, 1.2, 0))
                        if onN then
                            t.name.Position = UDim2.fromOffset(spN.X, spN.Y)
                            t.name.Text = string.format("%s [%dm]", plr.Name, math.floor(dist))
                            t.name.Visible = true
                        else
                            t.name.Visible = false
                        end

                        -- weapons
                        if CFG.WeaponESP then
                            local spW, onW = Camera:WorldToViewportPoint(
                                head.Position + Vector3.new(0, 2.4, 0))
                            if onW then
                                local w = getWeapons(plr) or "-"
                                t.wep.Position = UDim2.fromOffset(spW.X, spW.Y)
                                t.wep.Text = "Arma: " .. w
                                t.wep.Visible = true
                            else
                                t.wep.Visible = false
                            end
                        else
                            t.wep.Visible = false
                        end
                    else
                        local t = playerESP[plr]
                        if t then
                            t.container.Visible = false
                            t.name.Visible = false
                            t.wep.Visible = false
                        end
                    end
                end
            end
        end
    end

    for plr, _ in pairs(playerESP) do
        if not plr.Parent or not seen[plr] then
            destroyPlayerESP(plr)
        end
    end
end

local function findDropped()
    local list = {}
    local folder = Workspace:FindFirstChild("DroppedItems")
    if folder then
        for _, m in ipairs(folder:GetChildren()) do
            if m:IsA("Model") and m.PrimaryPart then
                table.insert(list, m)
            elseif m:IsA("BasePart") then
                table.insert(list, m)
            end
        end
    end
    for _, c in ipairs(Workspace:GetChildren()) do
        if c:IsA("Tool") then
            local part = c:FindFirstChildWhichIsA("BasePart", true)
            if part then table.insert(list, c) end
        end
    end
    return list
end

local function newItemESP(obj)
    local lbl = Instance.new("TextLabel")
    lbl.Name = "ItemESP"
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(255, 200, 90)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.Size = UDim2.fromOffset(240, 16)
    lbl.AnchorPoint = Vector2.new(0.5, 0.5)
    lbl.Visible = false
    lbl.ZIndex = 7
    lbl.Parent = espGui
    return lbl
end

local function updateItemESP()
    local seen = {}

    if CFG.ItemESP then
        for _, m in ipairs(findDropped()) do
            seen[m] = true

            local pos = nil
            if m:IsA("BasePart") then
                pos = m.Position
            else
                if m.PrimaryPart then
                    pos = m.PrimaryPart.Position
                else
                    local bp = m:FindFirstChildWhichIsA("BasePart", true)
                    if bp then pos = bp.Position end
                end
            end

            if pos then
                local dist = (Camera.CFrame.Position - pos).Magnitude
                if dist <= CFG.MaxESP then
                    if not itemESP[m] then
                        itemESP[m] = newItemESP(m)
                    end
                    local lbl = itemESP[m]
                    local sp, on = Camera:WorldToViewportPoint(pos)
                    if on then
                        local guid = nil
                        local okG, valG = pcall(function() return m:GetAttribute("ItemGUID") end)
                        if okG then guid = valG end

                        local label = m.Name
                        if guid then
                            label = label .. " [" .. tostring(guid):sub(1, 6) .. "]"
                        end

                        lbl.Position = UDim2.fromOffset(sp.X, sp.Y)
                        lbl.Text = string.format("%s (%dm)", label, math.floor(dist))
                        lbl.Visible = true
                    else
                        lbl.Visible = false
                    end
                else
                    local lbl = itemESP[m]
                    if lbl then lbl.Visible = false end
                end
            end
        end
    end

    for m, lbl in pairs(itemESP) do
        if not seen[m] or not m.Parent then
            if lbl then lbl:Destroy() end
            itemESP[m] = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    pcall(updatePlayerESP)
    pcall(updateItemESP)

    if fovGui then
        local mp = mousePos()
        fovGui.Position = UDim2.fromOffset(mp.X, mp.Y)
        fovGui.Size = UDim2.fromOffset(CFG.FOV * 2, CFG.FOV * 2)
        fovGui.Visible = CFG.Enabled and CFG.DrawFOV
    end
end)

-- ============================================================
-- UI — PANEL
-- ============================================================
local function new(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, c, t)
    local s = Instance.new("UIStroke")
    s.Color = c or Color3.fromRGB(50, 55, 60)
    s.Thickness = t or 1
    s.Parent = p
    return s
end

local screen = new("ScreenGui", {
    Name = "BSS_Aim",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 100,
    Parent = guiParent,
})

local ACCENT = Color3.fromRGB(0, 220, 130)
local BG     = Color3.fromRGB(18, 20, 24)
local BG2    = Color3.fromRGB(24, 27, 32)
local FG     = Color3.fromRGB(235, 238, 242)
local MUTED  = Color3.fromRGB(150, 158, 168)
local DANGER = Color3.fromRGB(240, 80, 90)

local PANEL_W, PANEL_H = 380, 560

local panel = new("Frame", {
    Name = "Panel",
    Size = UDim2.fromOffset(PANEL_W, PANEL_H),
    Position = UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    Parent = screen,
})
corner(14, panel)
stroke(panel, Color3.fromRGB(45, 50, 58), 1.5)

local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = BG2,
    BorderSizePixel = 0,
    Parent = panel,
})
corner(14, header)

new("Frame", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = BG2,
    BorderSizePixel = 0,
    Parent = header,
})

new("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
    Font = Enum.Font.GothamBold,
    Text = "BSS-AIM  -  panel",
    TextColor3 = FG,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header,
})

local minBtn = new("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -72, 0, 8),
    BackgroundColor3 = Color3.fromRGB(35, 38, 44),
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "-",
    TextColor3 = FG,
    TextSize = 18,
    AutoButtonColor = false,
    Parent = header,
})
corner(8, minBtn)

local closeBtn = new("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -40, 0, 8),
    BackgroundColor3 = Color3.fromRGB(35, 38, 44),
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "X",
    TextColor3 = FG,
    TextSize = 18,
    AutoButtonColor = false,
    Parent = header,
})
corner(8, closeBtn)

local scroll = new("ScrollingFrame", {
    Position = UDim2.new(0, 0, 0, 44),
    Size = UDim2.new(1, 0, 1, -44),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = ACCENT,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = panel,
})
new("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 14),
    PaddingRight = UDim.new(0, 14),
    Parent = scroll,
})
new("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = scroll,
})

local function section(label, order)
    local wrap = new("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = scroll,
    })
    local bar = new("Frame", {
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
        Parent = wrap,
    })
    corner(2, bar)
    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = label,
        TextColor3 = ACCENT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wrap,
    })
    return wrap
end

local function makeToggle(order, label, key, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = scroll,
    })
    corner(8, row)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Font = Enum.Font.Gotham,
        Text = label,
        TextColor3 = FG,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local track = new("Frame", {
        Size = UDim2.fromOffset(38, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(45, 50, 58),
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(10, track)

    local knob = new("Frame", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = FG,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(7, knob)

    local function render()
        local on = CFG[key] and true or false
        local targetX = 3
        if on then targetX = 38 - 14 - 3 end
        local col = Color3.fromRGB(45, 50, 58)
        if on then col = ACCENT end
        TweenService:Create(track, TweenInfo.new(0.15), { BackgroundColor3 = col }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = UDim2.new(0, targetX, 0.5, -7)
        }):Play()
    end

    local btn = new("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        render()
        if onChange then onChange(CFG[key]) end
    end)
    render()
    return row
end

local function makeSlider(order, label, key, minV, maxV, isFloat, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = scroll,
    })
    corner(8, row)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -80, 0, 16),
        Font = Enum.Font.Gotham,
        Text = label,
        TextColor3 = FG,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -80, 0, 6),
        Size = UDim2.new(0, 68, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = "",
        TextColor3 = ACCENT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local track = new("Frame", {
        Size = UDim2.new(1, -24, 0, 8),
        Position = UDim2.new(0, 12, 1, -18),
        BackgroundColor3 = Color3.fromRGB(40, 44, 52),
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(4, track)

    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(4, fill)

    local knob = new("Frame", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 0, 0.5, -7),
        BackgroundColor3 = FG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = track,
    })
    corner(7, knob)

    local function fmt(v)
        if isFloat then return string.format("%.2f", v) end
        return tostring(math.floor(v))
    end

    local function render()
        local v = CFG[key]
        local a = (v - minV) / (maxV - minV)
        if a < 0 then a = 0 end
        if a > 1 then a = 1 end
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, -7, 0.5, -7)
        valLbl.Text = fmt(v)
    end

    local dragging = false
    local function setFromX(x)
        local tl = track.AbsolutePosition.X
        local tw = track.AbsoluteSize.X
        if tw <= 0 then return end
        local a = (x - tl) / tw
        if a < 0 then a = 0 end
        if a > 1 then a = 1 end
        local v = minV + (maxV - minV) * a
        if not isFloat then v = math.floor(v + 0.5) end
        CFG[key] = v
        render()
        if onChange then onChange(v) end
    end

    local hit = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    render()
    return row
end

local function makePartSelector(order)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = scroll,
    })
    corner(8, row)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -24, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "Parte objetivo",
        TextColor3 = FG,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local parts = { "Head", "Neck", "UpperTorso", "LowerTorso", "HumanoidRootPart" }
    local holder = new("Frame", {
        Position = UDim2.new(0, 8, 0, 24),
        Size = UDim2.new(1, -16, 0, 32),
        BackgroundTransparency = 1,
        Parent = row,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder,
    })

    local buttons = {}
    local function refresh()
        for part, b in pairs(buttons) do
            if CFG.TargetPart == part then
                b.BackgroundColor3 = ACCENT
                b.TextColor3 = Color3.fromRGB(10, 14, 12)
            else
                b.BackgroundColor3 = Color3.fromRGB(38, 42, 50)
                b.TextColor3 = FG
            end
        end
    end

    for i, part in ipairs(parts) do
        local btn = new("TextButton", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Color3.fromRGB(38, 42, 50),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamMedium,
            Text = " " .. part .. " ",
            TextColor3 = FG,
            TextSize = 12,
            LayoutOrder = i,
            AutoButtonColor = false,
            Parent = holder,
        })
        corner(6, btn)
        buttons[part] = btn
        btn.MouseButton1Click:Connect(function()
            CFG.TargetPart = part
            refresh()
        end)
    end
    refresh()
    return row
end

local function makeButton(order, label, onClick)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(35, 40, 48),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = FG,
        TextSize = 13,
        AutoButtonColor = false,
        LayoutOrder = order,
        Parent = scroll,
    })
    corner(8, b)
    b.MouseButton1Click:Connect(onClick)
    return b
end

-- CONTENIDO
section("AIMBOT", 1)
makeToggle(2, "Activar aimbot", "Enabled")
makeSlider(3, "FOV", "FOV", 30, 400, false)
makeSlider(4, "Suavizado", "Smoothness", 0, 1, true)
makeSlider(5, "Distancia maxima", "MaxDistance", 100, 1500, false)
makePartSelector(6)
makeToggle(7, "Team check", "TeamCheck")
makeToggle(8, "Wall check", "WallCheck")
makeToggle(9, "Mostrar FOV circle", "DrawFOV")

section("ESP", 10)
makeToggle(11, "ESP de jugadores", "PlayerESP")
makeToggle(12, "Caja", "BoxESP")
makeToggle(13, "Mostrar armas", "WeaponESP")
makeToggle(14, "Items dropeados", "ItemESP")
makeSlider(15, "Rango ESP", "MaxESP", 100, 2000, false)

section("ACCIONES", 16)
makeButton(17, "Restaurar posicion del panel", function()
    panel.Position = UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2)
end)
makeButton(18, "Reiniciar valores", function()
    CFG.FOV         = 140
    CFG.Smoothness  = 0.20
    CFG.MaxDistance = 600
    CFG.TargetPart  = "Head"
    CFG.MaxESP      = 700
    CFG.TeamCheck   = true
    CFG.WallCheck   = true
    CFG.PlayerESP   = true
    CFG.WeaponESP   = true
    CFG.ItemESP     = true
    CFG.BoxESP      = true
    CFG.DrawFOV     = true
end)

local info = new("Frame", {
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = Color3.fromRGB(22, 25, 30),
    BorderSizePixel = 0,
    LayoutOrder = 19,
    Parent = scroll,
})
corner(8, info)
new("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    Font = Enum.Font.Gotham,
    Text = "RMB apuntar  ·  RShift toggle  ·  arrastra el header para mover",
    TextColor3 = MUTED,
    TextSize = 12,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = info,
})

local mini = new("TextButton", {
    Size = UDim2.fromOffset(56, 56),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    Text = "AIM",
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextColor3 = ACCENT,
    AutoButtonColor = false,
    Visible = false,
    Parent = screen,
})
corner(28, mini)
stroke(mini, ACCENT, 2)

-- DRAG
local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(panel, header)

-- mini drag + click
local miniDragStart, miniStartPos, miniMoved, miniDownTime, miniDragging = nil, nil, false, 0, false

mini.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniMoved = false
        miniDownTime = tick()
        miniDragStart = input.Position
        miniStartPos = mini.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - miniDragStart
        if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then miniMoved = true end
        mini.Position = UDim2.new(
            miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X,
            miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        if miniDragging and not miniMoved and (tick() - miniDownTime) < 0.35 then
            panel.Visible = true
            panel.Size = UDim2.fromOffset(1, 1)
            panel.Position = mini.Position
            TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(PANEL_W, PANEL_H) }):Play()
            mini.Visible = false
        end
        miniDragging = false
    end
end)

minBtn.MouseButton1Click:Connect(function()
    local fromPos = panel.AbsolutePosition
    local tw = TweenService:Create(panel,
        TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        { Size = UDim2.fromOffset(1, 1) })
    tw:Play()
    tw.Completed:Connect(function()
        panel.Visible = false
        panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
        mini.Position = UDim2.new(0, fromPos.X + PANEL_W - 40, 0, fromPos.Y + 4)
        mini.Visible = true
        mini.Size = UDim2.fromOffset(1, 1)
        TweenService:Create(mini, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(56, 56) }):Play()
    end)
end)

closeBtn.MouseButton1Click:Connect(function()
    for plr, _ in pairs(playerESP) do destroyPlayerESP(plr) end
    for m, lbl in pairs(itemESP) do
        if lbl then lbl:Destroy() end
    end
    itemESP = {}
    if espGui then espGui:Destroy() end
    screen:Destroy()
    getgenv().BSS_AimLoaded = false
    warn("[BSS-Aim] cerrado")
end)

minBtn.MouseEnter:Connect(function() minBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 62) end)
minBtn.MouseLeave:Connect(function() minBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 44) end)
closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = DANGER end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 44) end)

pcall(function()
    LP.PlayerGui:SetCore("SendNotification", {
        Title = "BSS-Aim v3",
        Text = "Panel listo · RMB apuntar · RShift toggle",
        Duration = 5,
    })
end)

print("[BSS-Aim v3] cargado")
