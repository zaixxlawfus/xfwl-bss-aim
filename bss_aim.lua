-- BSS-Aim v2 — panel de control + ESP + FOV circle + aimbot
-- discord.gg/syncrypt
-- RMB apuntar · RShift toggle · panel draggable · minimizable
-- Requiere executor con: gethui (o CoreGui), Drawing (opcional, para ESP y FOV circle)

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().BSS_AimLoaded then
    warn("[BSS-Aim] ya cargado")
    return
end
getgenv().BSS_AimLoaded = true

-- ============================================================
-- SERVICIOS
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UIS              = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local GuiService       = game:GetService("GuiService")
local TweenService     = game:GetService("TweenService")
local LP               = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

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
-- CONFIG GLOBAL
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
    -- ESP
    PlayerESP    = true,
    WeaponESP    = true,
    ItemESP      = true,
    BoxESP       = true,
    MaxESP       = 700,
}
getgenv().BSS_AimConfig = CFG

-- ============================================================
-- FOV CIRCLE (Drawing)
-- ============================================================
local fovCircle
if Drawing then
    local ok, c = pcall(function()
        local circ = Drawing.new("Circle")
        circ.Thickness    = 1
        circ.NumSides     = 72
        circ.Radius       = CFG.FOV
        circ.Filled       = false
        circ.Transparency = 0.75
        circ.Color        = Color3.fromRGB(0, 255, 140)
        circ.Visible      = false
        return circ
    end)
    if ok then fovCircle = c end
end

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
    return hum ~= nil and hum.Health > 0
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

local function visible(target, char)
    if not CFG.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local delta  = target.Position - origin
    local hit = Workspace:Raycast(origin, delta, rayParams)
    if not hit then return true end
    return hit.Instance and hit.Instance:IsDescendantOf(char)
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

        local metric = (CFG.Priority == "dist") and d3 or px
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
    if fovCircle then
        fovCircle.Position = mousePos()
        fovCircle.Radius   = CFG.FOV
        fovCircle.Visible  = CFG.Enabled and CFG.DrawFOV
    end

    if not CFG.Enabled or not holding then return end
    local target = getTarget()
    if not target then return end

    local desired = CFrame.new(Camera.CFrame.Position, target.Position)
    Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(CFG.Smoothness, 0, 1))
end)

-- ============================================================
-- ESP (Drawing)
-- ============================================================
local espActive = Drawing ~= nil
local function newDrawing(kind)
    if not Drawing then return nil end
    local ok, obj = pcall(function() return Drawing.new(kind) end)
    return ok and obj or nil
end

local playerESP = {}    -- [plr] = {box=..., name=..., wep=..., lines={...}}
local itemESP   = {}    -- [model] = {text=...}

local function disposeESP(t)
    if not t then return end
    for k, v in pairs(t) do
        if typeof(v) == "table" then
            disposeESP(v)
        elseif v and v.Remove then
            pcall(function() v:Remove() end)
        end
    end
end

local function ensurePlayerDraws(plr)
    if playerESP[plr] then return playerESP[plr] end
    local t = {
        box  = newDrawing("Square"),
        name = newDrawing("Text"),
        wep  = newDrawing("Text"),
    }
    if t.box then
        t.box.Thickness    = 1
        t.box.Filled       = false
        t.box.Color        = Color3.fromRGB(0, 255, 140)
        t.box.Transparency = 1
        t.box.Visible      = false
    end
    if t.name then
        t.name.Size       = 14
        t.name.Center     = true
        t.name.Outline    = true
        t.name.Color      = Color3.fromRGB(255, 255, 255)
        t.name.OutlineColor = Color3.fromRGB(0, 0, 0)
        t.name.Font       = 2
        t.name.Visible    = false
    end
    if t.wep then
        t.wep.Size        = 13
        t.wep.Center      = true
        t.wep.Outline     = true
        t.wep.Color       = Color3.fromRGB(255, 220, 120)
        t.wep.OutlineColor = Color3.fromRGB(0, 0, 0)
        t.wep.Font        = 2
        t.wep.Visible     = false
    end
    playerESP[plr] = t
    return t
end

local function clearPlayerESP(plr)
    local t = playerESP[plr]
    if t then disposeESP(t); playerESP[plr] = nil end
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

local function projectCorners(model)
    local ok, cf, size = pcall(function()
        local c, s = model:GetBoundingBox(); return c, s
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
        minX = math.min(minX, p.X); minY = math.min(minY, p.Y)
        maxX = math.max(maxX, p.X); maxY = math.max(maxY, p.Y)
    end
    return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

local function updatePlayerESP()
    if not espActive then return end

    local onScreen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or sameTeam(plr) then
            local t = playerESP[plr]
            if t then
                if t.box then t.box.Visible = false end
                if t.name then t.name.Visible = false end
                if t.wep then t.wep.Visible = false end
            end
            continue
        end
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or hum.Health <= 0 then
            local t = playerESP[plr]
            if t then
                if t.box then t.box.Visible = false end
                if t.name then t.name.Visible = false end
                if t.wep then t.wep.Visible = false end
            end
            continue
        end

        local head = char:FindFirstChild("Head")
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        if not head or not hrp then continue end

        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > CFG.MaxESP then
            local t = playerESP[plr]
            if t then
                if t.box then t.box.Visible = false end
                if t.name then t.name.Visible = false end
                if t.wep then t.wep.Visible = false end
            end
            continue
        end

        local draws = ensurePlayerDraws(plr)
        onScreen[plr] = true

        -- Caja
        if draws.box then
            if CFG.PlayerESP and CFG.BoxESP then
                local tl, size = projectCorners(char)
                if tl and size then
                    draws.box.Position     = tl
                    draws.box.Size         = size
                    draws.box.Color        = Color3.fromRGB(0, 255, 140)
                    draws.box.Transparency = 1
                    draws.box.Visible      = true
                else
                    draws.box.Visible = false
                end
            else
                draws.box.Visible = false
            end
        end

        -- Nombre
        if draws.name then
            if CFG.PlayerESP then
                local sp, on = Camera:WorldToViewportPoint(
                    head.Position + Vector3.new(0, 1.2, 0)
                )
                if on then
                    draws.name.Position = Vector2.new(sp.X, sp.Y)
                    draws.name.Text     = string.format("%s [%dm]", plr.Name, math.floor(dist))
                    draws.name.Visible  = true
                else
                    draws.name.Visible  = false
                end
            else
                draws.name.Visible = false
            end
        end

        -- Armas
        if draws.wep then
            if CFG.PlayerESP and CFG.WeaponESP then
                local sp, on = Camera:WorldToViewportPoint(
                    head.Position + Vector3.new(0, 2.4, 0)
                )
                if on then
                    local w = getWeapons(plr) or "—"
                    draws.wep.Position = Vector2.new(sp.X, sp.Y)
                    draws.wep.Text     = "🔫 " .. w
                    draws.wep.Visible  = true
                else
                    draws.wep.Visible = false
                end
            else
                draws.wep.Visible = false
            end
        end
    end

    -- limpieza de jugadores que se fueron
    for plr, _ in pairs(playerESP) do
        if not plr.Parent then clearPlayerESP(plr) end
    end
end

-- items dropeados
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
    -- tools tirados en workspace
    for _, c in ipairs(Workspace:GetChildren()) do
        if c:IsA("Tool") and c:FindFirstChildWhichIsA("BasePart", true) then
            table.insert(list, c)
        end
    end
    return list
end

local function updateItemESP()
    if not espActive then return end

    local seen = {}
    if CFG.ItemESP then
        for _, m in ipairs(findDropped()) do
            seen[m] = true
            local pos = m:IsA("BasePart") and m.Position
                or (m.PrimaryPart and m.PrimaryPart.Position)
                or (m:FindFirstChildWhichIsA("BasePart", true)
                    and m:FindFirstChildWhichIsA("BasePart", true).Position)
            if not pos then continue end

            local dist = (Camera.CFrame.Position - pos).Magnitude
            if dist > CFG.MaxESP then
                local rec = itemESP[m]
                if rec and rec.text then rec.text.Visible = false end
                continue
            end

            local sp, on = Camera:WorldToViewportPoint(pos)
            local rec = itemESP[m]
            if not rec then
                rec = { text = newDrawing("Text") }
                if rec.text then
                    rec.text.Size        = 13
                    rec.text.Center      = true
                    rec.text.Outline     = true
                    rec.text.Color       = Color3.fromRGB(255, 200, 90)
                    rec.text.OutlineColor = Color3.fromRGB(0, 0, 0)
                    rec.text.Font        = 2
                end
                itemESP[m] = rec
            end

            if rec.text then
                if on then
                    local label = m.Name
                                        local guid = nil
                    local okG, valG = pcall(function() return m:GetAttribute("ItemGUID") end)
                    if okG then guid = valG end
                    if guid then label = label .. " · " .. tostring(guid):sub(1, 6) end
                    rec.text.Position = Vector2.new(sp.X, sp.Y)
                    rec.text.Text     = string.format("📦 %s [%dm]", label, math.floor(dist))
                    rec.text.Visible  = true
                else
                    rec.text.Visible = false
                end
            end
        end
    end

    for m, rec in pairs(itemESP) do
        if not seen[m] or not m.Parent then
            if rec.text then pcall(function() rec.text:Remove() end) end
            itemESP[m] = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not espActive then return end
    pcall(updatePlayerESP)
    pcall(updateItemESP)
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

local function corner(r, p) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function stroke(p, c, t)
    return new("UIStroke", { Color = c or Color3.fromRGB(50, 55, 60), Thickness = t or 1, Parent = p })
end

local guiParent = getGuiParent()
local screen = new("ScreenGui", {
    Name = "BSS_Aim",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 100,
    Parent = guiParent,
})

local ACCENT  = Color3.fromRGB(0, 220, 130)
local BG      = Color3.fromRGB(18, 20, 24)
local BG2     = Color3.fromRGB(24, 27, 32)
local FG      = Color3.fromRGB(235, 238, 242)
local MUTED   = Color3.fromRGB(150, 158, 168)
local DANGER  = Color3.fromRGB(240, 80, 90)

-- ---------- panel principal ----------
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

-- header
local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = BG2,
    BorderSizePixel = 0,
    Parent = panel,
})
corner(14, header)
local headerFix = new("Frame", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = BG2,
    BorderSizePixel = 0,
    Parent = header,
})

local title = new("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
    Font = Enum.Font.GothamBold,
    Text = "BSS-AIM  ·  panel",
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
    Text = "—",
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
    Text = "×",
    TextColor3 = FG,
    TextSize = 18,
    AutoButtonColor = false,
    Parent = header,
})
corner(8, closeBtn)

-- scroll
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

-- ---------- helpers ----------
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
        local targetX = on and (38 - 14 - 3) or 3
        local col = on and ACCENT or Color3.fromRGB(45, 50, 58)
        TweenService:Create(track, TweenInfo.new(0.15), { BackgroundColor3 = col }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(0, targetX, 0.5, -7) }):Play()
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

    local nameLbl = new("TextLabel", {
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
        a = math.clamp(a, 0, 1)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, -7, 0.5, -7)
        valLbl.Text = fmt(v)
    end

    local dragging = false
    local function setFromX(x)
        local tl = track.AbsolutePosition.X
        local tw = track.AbsoluteSize.X
        local a = math.clamp((x - tl) / tw, 0, 1)
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

    local parts = { "Head", "Neck", "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart" }
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
            local on = CFG.TargetPart == part
            b.BackgroundColor3 = on and ACCENT or Color3.fromRGB(38, 42, 50)
            b.TextColor3       = on and Color3.fromRGB(10, 14, 12) or FG
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

local function makeButton(order, label, color, onClick)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = color or Color3.fromRGB(35, 40, 48),
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
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12),
            { BackgroundColor3 = color and color:Lerp(Color3.new(1,1,1), 0.15) or Color3.fromRGB(45, 50, 60) }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12),
            { BackgroundColor3 = color or Color3.fromRGB(35, 40, 48) }):Play()
    end)
    b.MouseButton1Click:Connect(onClick)
    return b
end

-- ---------- contenido ----------
section("AIMBOT", 1)
makeToggle(2, "Activar aimbot", "Enabled")
makeSlider(3, "FOV", "FOV", 30, 400, false, function(v)
    if fovCircle then fovCircle.Radius = v end
end)
makeSlider(4, "Suavizado", "Smoothness", 0, 1, true)
makeSlider(5, "Distancia máxima", "MaxDistance", 100, 1500, false)
makePartSelector(6)
makeToggle(7, "Team check", "TeamCheck")
makeToggle(8, "Wall check", "WallCheck")
makeToggle(9, "Dibujar círculo FOV", "DrawFOV")

section("ESP", 10)
makeToggle(11, "ESP de jugadores", "PlayerESP")
makeToggle(12, "Caja", "BoxESP")
makeToggle(13, "Mostrar armas", "WeaponESP")
makeToggle(14, "Items dropeados", "ItemESP")
makeSlider(15, "Rango ESP", "MaxESP", 100, 2000, false)

section("ACCIONES", 16)
makeButton(17, "Restaurar posición del panel", nil, function()
    panel.Position = UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2)
end)
makeButton(18, "Reiniciar valores", nil, function()
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
    screen:Destroy()
    getgenv().BSS_AimLoaded = false
    warn("[BSS-Aim] valores reseteados — recargá el script para reconstruir el panel")
end)

-- footer keybind info
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
    Text = "RMB apuntar  ·  RShift toggle  ·  arrastrá el header para mover",
    TextColor3 = MUTED,
    TextSize = 12,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = info,
})

-- ---------- botón minimizado ----------
local mini = new("TextButton", {
    Size = UDim2.fromOffset(56, 56),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    Text = "🎯",
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Visible = false,
    Parent = screen,
})
corner(28, mini)
stroke(mini, ACCENT, 2)

-- ============================================================
-- DRAG (panel + mini)
-- ============================================================
local function makeDraggable(frame, handle, onRelease)
    local dragging = false
    local dragStart, startPos
    local moved = false
    local downTime = 0

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            downTime = tick()
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then moved = true end
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved and (tick() - downTime) < 0.35 then
                if onRelease then onRelease() end
            end
            dragging = false
        end
    end)
end

makeDraggable(panel, header)

-- mini: draggable + click abre panel
local miniDragStart, miniStartPos, miniMoved, miniDownTime
local miniDragging = false

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
            -- abrir panel
            panel.Visible = true
            panel.Size = UDim2.fromOffset(1, 1)
            local targetPos = UDim2.new(
                mini.Position.X.Scale, mini.Position.X.Offset - PANEL_W/2 + 28,
                mini.Position.Y.Scale, mini.Position.Y.Offset
            )
            panel.Position = targetPos
            TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(PANEL_W, PANEL_H) }):Play()
            mini.Visible = false
        end
        miniDragging = false
    end
end)

-- minimizar
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

-- cerrar todo
closeBtn.MouseButton1Click:Connect(function()
    if fovCircle then fovCircle.Visible = false end
    for plr, t in pairs(playerESP) do disposeESP(t) end
    playerESP = {}
    for m, rec in pairs(itemESP) do
        if rec.text then pcall(function() rec.text:Remove() end) end
    end
    itemESP = {}
    screen:Destroy()
    getgenv().BSS_AimLoaded = false
    warn("[BSS-Aim] cerrado")
end)

-- hover header
minBtn.MouseEnter:Connect(function() minBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 62) end)
minBtn.MouseLeave:Connect(function() minBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 44) end)
closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = DANGER end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 44) end)

-- notify al cargar
pcall(function()
    LP.PlayerGui:SetCore("SendNotification", {
        Title = "BSS-Aim v2",
        Text = "Panel listo · RMB apuntar · RShift toggle",
        Duration = 5,
    })
end)

print("[BSS-Aim v2] cargado — panel abierto en pantalla")
