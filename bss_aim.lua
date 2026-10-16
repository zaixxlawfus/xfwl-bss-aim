-- BSS-Aim v5 — panel neón, FOV circle lock, ESP items, fix minimizar
-- discord.gg/syncrypt

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().BSS_AimV5 then return end
getgenv().BSS_AimV5 = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local LP = Players.LocalPlayer
local Camera = WS.CurrentCamera

local function getParent()
    if gethui then local ok, r = pcall(gethui); if ok and r then return r end end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

-- ============ PALETA NEÓN ============
local C = {
    bg       = Color3.fromRGB(10, 10, 16),
    bg2      = Color3.fromRGB(16, 18, 26),
    bg3      = Color3.fromRGB(24, 27, 38),
    bg4      = Color3.fromRGB(34, 38, 52),
    accent   = Color3.fromRGB(0, 240, 180),
    accent2  = Color3.fromRGB(180, 100, 255),
    accent3  = Color3.fromRGB(0, 180, 255),
    fg       = Color3.fromRGB(240, 242, 250),
    muted    = Color3.fromRGB(110, 118, 138),
    danger   = Color3.fromRGB(255, 70, 90),
    border   = Color3.fromRGB(40, 45, 60),
    glow     = Color3.fromRGB(0, 240, 180),
}

-- ============ CONFIG ============
local CFG = getgenv().BSS_AimConfig or {
    Enabled = true,
    HoldKey = Enum.UserInputType.MouseButton2,
    ToggleKey = Enum.KeyCode.RightShift,
    PanelKey = Enum.KeyCode.F1,
    FOV = 140,
    Smoothness = 0.20,
    MaxDistance = 600,
    TargetPart = "Head",
    TeamCheck = false,
    WallCheck = true,
    DrawFOV = true,
    FOVLockToTarget = true,
    Priority = "fov",
    PlayerESP = true,
    WeaponESP = true,
    ItemESP = true,
    BoxESP = true,
    NameESP = true,
    HealthESP = true,
    MaxESP = 700,
    ESPColor = Color3.fromRGB(0, 240, 180),
    ItemColor = Color3.fromRGB(120, 240, 130),
}
getgenv().BSS_AimConfig = CFG

-- ============ FOV CIRCLE ============
local fovCircle, fovGlow
if Drawing then
    local ok, c = pcall(function()
        local ci = Drawing.new("Circle")
        ci.Thickness = 1.5; ci.NumSides = 96; ci.Radius = CFG.FOV
        ci.Filled = false; ci.Transparency = 0.85
        ci.Color = C.accent; ci.Visible = false
        return ci
    end)
    if ok then fovCircle = c end
    local ok2, g = pcall(function()
        local ci = Drawing.new("Circle")
        ci.Thickness = 4; ci.NumSides = 96; ci.Radius = CFG.FOV + 2
        ci.Filled = false; ci.Transparency = 0.15
        ci.Color = C.accent; ci.Visible = false
        return ci
    end)
    if ok2 then fovGlow = g end
end

local function mousePos()
    local p = UIS:GetMouseLocation()
    local i = GuiService:GetGuiInset()
    return Vector2.new(p.X - i.X, p.Y - i.Y)
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

local function getTarget()
    local best, bm = nil, math.huge
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
        if px > CFG.FOV then continue end
        if CFG.WallCheck and not visible(part, char) then continue end
        local m = (CFG.Priority == "dist") and d3 or px
        if m < bm then bm = m; best = part end
    end
    return best
end

local holding = false
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == CFG.HoldKey or i.KeyCode == CFG.HoldKey then holding = true end
    if i.KeyCode == CFG.ToggleKey then CFG.Enabled = not CFG.Enabled end
end)
UIS.InputEnded:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == CFG.HoldKey or i.KeyCode == CFG.HoldKey then holding = false end
end)

-- ============ ESP ============
local function newDraw(kind)
    if not Drawing then return nil end
    local ok, o = pcall(function() return Drawing.new(kind) end)
    return ok and o or nil
end

local pESP, iESP = {}, {}

local function dispose(t)
    if not t then return end
    for _, v in pairs(t) do
        if type(v) == "table" then dispose(v)
        elseif v and v.Remove then pcall(function() v:Remove() end) end
    end
end

local function ensureP(plr)
    if pESP[plr] then return pESP[plr] end
    local t = {
        box = newDraw("Square"),
        name = newDraw("Text"),
        wep = newDraw("Text"),
        dist = newDraw("Text"),
        hpBg = newDraw("Square"),
        hpFill = newDraw("Square"),
    }
    if t.box then
        t.box.Thickness = 1.5; t.box.Filled = false; t.box.Transparency = 1
        t.box.Color = CFG.ESPColor; t.box.Visible = false
    end
    for _, k in ipairs({"name", "wep", "dist"}) do
        local d = t[k]
        if d then
            d.Size = 13; d.Center = true; d.Outline = true
            d.OutlineColor = Color3.new(0,0,0)
            d.Color = Color3.fromRGB(255,255,255); d.Visible = false
        end
    end
    if t.wep then t.wep.Color = Color3.fromRGB(255, 220, 120) end
    if t.dist then t.dist.Color = C.muted; t.dist.Size = 11 end
    if t.hpBg then
        t.hpBg.Filled = true; t.hpBg.Color = Color3.fromRGB(30, 30, 35)
        t.hpBg.Transparency = 0.4; t.hpBg.Visible = false
    end
    if t.hpFill then
        t.hpFill.Filled = true; t.hpFill.Color = Color3.fromRGB(80, 220, 120)
        t.hpFill.Transparency = 0.15; t.hpFill.Visible = false
    end
    pESP[plr] = t
    return t
end

local function corners(model)
    local ok, cf, sz = pcall(function()
        local c, s = model:GetBoundingBox(); return c, s
    end)
    if not ok or not cf then return nil end
    local pts = {}
    local h = sz * 0.5
    for x = -1,1,2 do for y = -1,1,2 do for z = -1,1,2 do
        local wp = cf * Vector3.new(h.X*x, h.Y*y, h.Z*z)
        local sp, on = Camera:WorldToViewportPoint(wp)
        if on then table.insert(pts, Vector2.new(sp.X, sp.Y)) end
    end end end
    if #pts < 4 then return nil end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for _, p in ipairs(pts) do
        minX = math.min(minX, p.X); minY = math.min(minY, p.Y)
        maxX = math.max(maxX, p.X); maxY = math.max(maxY, p.Y)
    end
    return Vector2.new(minX, minY), Vector2.new(maxX-minX, maxY-minY)
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

local function hideP(t)
    if not t then return end
    for _, d in pairs(t) do
        if type(d) == "table" then hideP(d)
        elseif d and d.Visible ~= nil then d.Visible = false end
    end
end

local function updatePlayerESP()
    if not Drawing then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or sameTeam(plr) or not alive(plr) then
            hideP(pESP[plr]); continue
        end
        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not (hrp and head and hum) then hideP(pESP[plr]); continue end
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > CFG.MaxESP then hideP(pESP[plr]); continue end

        local t = ensureP(plr)

        if t.box then
            if CFG.PlayerESP and CFG.BoxESP then
                local tl, sz = corners(char)
                if tl and sz then
                    t.box.Position = tl; t.box.Size = sz
                    t.box.Color = CFG.ESPColor
                    t.box.Visible = true
                else t.box.Visible = false end
            else t.box.Visible = false end
        end

        if t.name then
            if CFG.PlayerESP and CFG.NameESP then
                local sp, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.3, 0))
                if on then
                    t.name.Position = Vector2.new(sp.X, sp.Y)
                    t.name.Text = plr.Name
                    t.name.Visible = true
                else t.name.Visible = false end
            else t.name.Visible = false end
        end

        if t.dist then
            if CFG.PlayerESP then
                local sp, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.75, 0))
                if on then
                    t.dist.Position = Vector2.new(sp.X, sp.Y)
                    t.dist.Text = string.format("[%dm]", math.floor(dist))
                    t.dist.Visible = true
                else t.dist.Visible = false end
            else t.dist.Visible = false end
        end

        if t.wep then
            if CFG.PlayerESP and CFG.WeaponESP then
                local sp, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.3, 0))
                if on then
                    t.wep.Position = Vector2.new(sp.X, sp.Y)
                    t.wep.Text = weapons(plr) or "—"
                    t.wep.Visible = true
                else t.wep.Visible = false end
            else t.wep.Visible = false end
        end

        if t.hpBg and t.hpFill then
            if CFG.PlayerESP and CFG.BoxESP and CFG.HealthESP then
                local tl, sz = corners(char)
                if tl and sz then
                    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local barW = 3; local barH = sz.Y
                    local bx = tl.X - 7
                    t.hpBg.Position = Vector2.new(bx, tl.Y)
                    t.hpBg.Size = Vector2.new(barW, barH)
                    t.hpBg.Visible = true
                    t.hpFill.Position = Vector2.new(bx, tl.Y + barH * (1 - hp))
                    t.hpFill.Size = Vector2.new(barW, barH * hp)
                    if hp > 0.6 then
                        t.hpFill.Color = Color3.fromRGB(80, 220, 120)
                    elseif hp > 0.3 then
                        t.hpFill.Color = Color3.fromRGB(240, 200, 80)
                    else
                        t.hpFill.Color = Color3.fromRGB(240, 80, 95)
                    end
                    t.hpFill.Visible = true
                else
                    t.hpBg.Visible = false; t.hpFill.Visible = false
                end
            else
                t.hpBg.Visible = false; t.hpFill.Visible = false
            end
        end
    end
    for plr, _ in pairs(pESP) do
        if not plr.Parent then dispose(pESP[plr]); pESP[plr] = nil end
    end
end

local function updateItemESP()
    if not Drawing or not CFG.ItemESP then return end
    local seen = {}
    local folder = WS:FindFirstChild("DroppedItems")
    if not folder then return end

    for _, m in ipairs(folder:GetChildren()) do
        if not m:IsA("Model") then continue end

        local part = m:FindFirstChild("PickUpZone")
            or m:FindFirstChild("CashPart")
            or m.PrimaryPart
        if not part then
            part = m:FindFirstChildWhichIsA("BasePart", true)
        end
        if not part then continue end

        seen[m] = true
        local pos = part.Position
        local dist = (Camera.CFrame.Position - pos).Magnitude
        if dist > CFG.MaxESP then
            local r = iESP[m]
            if r and r.text then r.text.Visible = false end
            continue
        end

        local amount = nil
        local bb = m:FindFirstChild("AmountBillboardGui", true)
        if bb then
            local tl = bb:FindFirstChild("TextLabel")
            if tl then amount = tl.Text end
        end

        local label = m.Name
        if amount and amount ~= "" then
            label = m.Name .. " · " .. amount
        end

        local color = Color3.fromRGB(255, 200, 90)
        if m.Name == "Money" then
            color = Color3.fromRGB(120, 230, 130)
        elseif m.Name == "Taser" then
            color = Color3.fromRGB(120, 180, 255)
        elseif m.Name:lower():find("weapon") or m.Name:lower():find("gun") then
            color = Color3.fromRGB(255, 120, 120)
        end

        local rec = iESP[m]
        if not rec then
            rec = { text = newDraw("Text") }
            if rec.text then
                rec.text.Size = 13
                rec.text.Center = true
                rec.text.Outline = true
                rec.text.OutlineColor = Color3.new(0, 0, 0)
                rec.text.Font = 2
            end
            iESP[m] = rec
        end

        if rec.text then
            rec.text.Color = color
            local sp, on = Camera:WorldToViewportPoint(pos + Vector3.new(0, 1.5, 0))
            if on then
                rec.text.Position = Vector2.new(sp.X, sp.Y)
                rec.text.Text = string.format("📦 %s [%dm]", label, math.floor(dist))
                rec.text.Visible = true
            else
                rec.text.Visible = false
            end
        end
    end

    for m, rec in pairs(iESP) do
        if not seen[m] or not m.Parent then
            if rec.text then pcall(function() rec.text:Remove() end) end
            iESP[m] = nil
        end
    end
end

-- ============ LOOP PRINCIPAL ============
RunService.RenderStepped:Connect(function(dt)
    local target = nil
    if CFG.Enabled and holding then
        target = getTarget()
    end

    -- FOV circle: pegado a la cabeza del target si hay uno, si no en el mouse
    if fovCircle then
        if CFG.FOVLockToTarget and target then
            local sp, on = Camera:WorldToViewportPoint(target.Position)
            if on then
                fovCircle.Position = Vector2.new(sp.X, sp.Y)
                fovCircle.Radius = math.min(CFG.FOV, 60)
                fovCircle.Visible = CFG.DrawFOV
                if fovGlow then
                    fovGlow.Position = Vector2.new(sp.X, sp.Y)
                    fovGlow.Radius = math.min(CFG.FOV, 60) + 2
                    fovGlow.Visible = CFG.DrawFOV
                end
            end
        else
            local mp = mousePos()
            fovCircle.Position = mp
            fovCircle.Radius = CFG.FOV
            fovCircle.Visible = CFG.Enabled and CFG.DrawFOV
            if fovGlow then
                fovGlow.Position = mp
                fovGlow.Radius = CFG.FOV + 2
                fovGlow.Visible = CFG.Enabled and CFG.DrawFOV
            end
        end
    end

    if CFG.Enabled and holding and target then
        local d = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(d, math.clamp(CFG.Smoothness, 0, 1))
    end

    pcall(updatePlayerESP)
    pcall(updateItemESP)
end)

-- ============ UI (panel rediseñado) ============
local function new(c, p, ch)
    local i = Instance.new(c)
    for k, v in pairs(p or {}) do i[k] = v end
    for _, x in ipairs(ch or {}) do x.Parent = i end
    return i
end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function pad(p, t, b, l, r)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        Parent = p,
    })
end

local sg = new("ScreenGui", {
    Name = "BSS_Aim_V5",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = getParent(),
})

local W, H = 480, 620
local panel = new("Frame", {
    Size = UDim2.fromOffset(W, H),
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Parent = sg,
})
corner(panel, 16)
new("UIStroke", { Color = C.border, Thickness = 1.5, Parent = panel })

-- barra de gradiente superior
local grad = new("Frame", {
    Size = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
    Parent = panel,
})
corner(grad, 16)
new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.accent),
        ColorSequenceKeypoint.new(0.3, C.accent3),
        ColorSequenceKeypoint.new(0.6, C.accent2),
        ColorSequenceKeypoint.new(1, C.accent),
    }),
    Parent = grad,
})

-- header
local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 56),
    Position = UDim2.new(0, 0, 0, 4),
    BackgroundColor3 = C.bg2,
    BorderSizePixel = 0,
    Parent = panel,
})

local logo = new("Frame", {
    Size = UDim2.fromOffset(36, 36),
    Position = UDim2.new(0, 16, 0.5, -18),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
    Parent = header,
})
corner(logo, 10)
new("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "⌖",
    TextColor3 = C.bg,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    Parent = logo,
})

new("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 62, 0, 0),
    BackgroundTransparency = 1,
    Text = "BSS-AIM",
    TextColor3 = C.fg,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header,
})
new("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 62, 0, 18),
    BackgroundTransparency = 1,
    Text = "v5 · neón",
    TextColor3 = C.accent,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header,
})

local function iconBtn(txt, xOff)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.new(1, xOff, 0.5, -17),
        BackgroundColor3 = C.bg3,
        BorderSizePixel = 0,
        Text = txt,
        TextColor3 = C.fg,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = header,
    })
    corner(b, 9)
    return b
end
local minBtn = iconBtn("—", -84)
local closeBtn = iconBtn("×", -46)

minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.bg4 }):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.bg3 }):Play()
end)
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.danger }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.bg3 }):Play()
end)

-- tabs
local tabsFrame = new("Frame", {
    Size = UDim2.new(1, -32, 0, 38),
    Position = UDim2.new(0, 16, 0, 68),
    BackgroundColor3 = C.bg2,
    BorderSizePixel = 0,
    Parent = panel,
})
corner(tabsFrame, 10)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = tabsFrame,
})

local content = new("Frame", {
    Size = UDim2.new(1, -32, 1, -160),
    Position = UDim2.new(0, 16, 0, 114),
    BackgroundTransparency = 1,
    Parent = panel,
})

local pages = {}
local tabBtns = {}
local tabUnderline = new("Frame", {
    Size = UDim2.new(0, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
    Parent = tabsFrame,
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

local TAB_LIST = {"AIM", "ESP", "VISUAL", "CONFIG"}
for i, tname in ipairs(TAB_LIST) do
    local btn = new("TextButton", {
        Size = UDim2.new(1/#TAB_LIST, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = tname,
        TextColor3 = C.muted,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        LayoutOrder = i,
        Parent = tabsFrame,
    })
    tabBtns[tname] = btn
    btn.MouseButton1Click:Connect(function() selectTab(tname) end)
    btn.MouseEnter:Connect(function()
        if pages[tname] and not pages[tname].Visible then
            TweenService:Create(btn, TweenInfo.new(0.15), { TextColor3 = C.fg }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if pages[tname] and not pages[tname].Visible then
            TweenService:Create(btn, TweenInfo.new(0.15), { TextColor3 = C.muted }):Play()
        end
    end)

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
        Parent = content,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })
    pad(page, 0, 0, 0, 6)
    pages[tname] = page
end

local order = 0
local function nextOrder() order = order + 1; return order end

local function section(page, label)
    local wrap = new("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(),
        Parent = page,
    })
    local bar = new("Frame", {
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Parent = wrap,
    })
    corner(bar, 2)
    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = label,
        TextColor3 = C.fg,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wrap,
    })
end

local function toggle(page, label, key, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = C.bg2,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
        Parent = page,
    })
    corner(row, 10)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = C.fg,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local track = new("Frame", {
        Size = UDim2.fromOffset(46, 24),
        Position = UDim2.new(1, -60, 0.5, -12),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(track, 12)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = C.fg,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(knob, 9)

    local function render(anim)
        local on = CFG[key] and true or false
        local x = on and (46 - 18 - 3) or 3
        local col = on and C.accent or C.bg4
        local tInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if anim then
            TweenService:Create(track, tInfo, { BackgroundColor3 = col }):Play()
            TweenService:Create(knob, tInfo, { Position = UDim2.new(0, x, 0.5, -9) }):Play()
        else
            track.BackgroundColor3 = col
            knob.Position = UDim2.new(0, x, 0.5, -9)
        end
    end

    local btn = new("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        render(true)
        if onChange then onChange(CFG[key]) end
    end)
    render(false)
end

local function slider(page, label, key, minV, maxV, isFloat, fmt, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = C.bg2,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
        Parent = page,
    })
    corner(row, 10)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -100, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = C.fg,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local valLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -94, 0, 8),
        Size = UDim2.new(0, 80, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = C.accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local track = new("Frame", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 1, -20),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(track, 3)
    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(fill, 3)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = C.fg,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(knob, 8)

    local function render()
        local v = CFG[key]
        local a = math.clamp((v - minV) / (maxV - minV), 0, 1)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, -8, 0.5, -8)
        valLbl.Text = fmt and fmt(v) or (isFloat and string.format("%.2f", v) or tostring(math.floor(v)))
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
    hit.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(inp.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch) then
            setFromX(inp.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    render()
end

local function partSelector(page)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 76),
        BackgroundColor3 = C.bg2,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
        Parent = page,
    })
    corner(row, 10)
    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -28, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = "Parte objetivo",
        TextColor3 = C.fg,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local parts = {"Head", "Neck", "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart"}
    local holder = new("Frame", {
        Position = UDim2.new(0, 10, 0, 32),
        Size = UDim2.new(1, -20, 0, 34),
        BackgroundTransparency = 1,
        Parent = row,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder,
    })

    local buttons = {}
    local function refresh()
        for p, b in pairs(buttons) do
            local on = CFG.TargetPart == p
            TweenService:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = on and C.accent or C.bg3,
                TextColor3 = on and C.bg or C.fg,
            }):Play()
        end
    end

    for i, p in ipairs(parts) do
        local b = new("TextButton", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = C.bg3,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamMedium,
            Text = " " .. p .. " ",
            TextColor3 = C.fg,
            TextSize = 11,
            LayoutOrder = i,
            AutoButtonColor = false,
            Parent = holder,
        })
        corner(b, 7)
        buttons[p] = b
        b.MouseButton1Click:Connect(function()
            CFG.TargetPart = p
            refresh()
        end)
    end
    refresh()
end

local function keybindRow(page, label, key)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.bg2,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
        Parent = page,
    })
    corner(row, 10)
    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -140, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = C.fg,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local btn = new("TextButton", {
        Size = UDim2.fromOffset(120, 32),
        Position = UDim2.new(1, -132, 0.5, -16),
        BackgroundColor3 = C.bg3,
        BorderSizePixel = 0,
        Text = "",
        TextColor3 = C.accent,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = row,
    })
    corner(btn, 8)

    local capturing = false
    local function render()
        local cur = CFG[key]
        local name = "?"
        if typeof(cur) == "EnumItem" then
            if cur.EnumType == Enum.KeyCode then name = cur.Name
            elseif cur.EnumType == Enum.UserInputType then
                name = cur.Name:gsub("MouseButton", "Mouse") end
        end
        btn.Text = capturing and "presioná tecla..." or name
        btn.TextColor3 = capturing and C.accent2 or C.accent
    end

    btn.MouseButton1Click:Connect(function()
        capturing = not capturing
        render()
    end)

    UIS.InputBegan:Connect(function(inp, gp)
        if gp or not capturing then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            CFG[key] = inp.KeyCode
        elseif inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.MouseButton2 then
            CFG[key] = inp.UserInputType
        end
        capturing = false
        render()
    end)
    render()
end

local function colorRow(page, label, key)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.bg2,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
        Parent = page,
    })
    corner(row, 10)
    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = C.fg,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local swatch = new("TextButton", {
        Size = UDim2.fromOffset(56, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        BackgroundColor3 = CFG[key],
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })
    corner(swatch, 8)
    new("UIStroke", { Color = C.border, Thickness = 1, Parent = swatch })

    local idx = 0
    local presets = {
        Color3.fromRGB(0, 240, 180),
        Color3.fromRGB(180, 100, 255),
        Color3.fromRGB(0, 180, 255),
        Color3.fromRGB(255, 100, 150),
        Color3.fromRGB(255, 220, 100),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 70, 90),
    }
    swatch.MouseButton1Click:Connect(function()
        idx = (idx % #presets) + 1
        CFG[key] = presets[idx]
        swatch.BackgroundColor3 = CFG[key]
        if fovCircle then fovCircle.Color = CFG[key] end
        if fovGlow then fovGlow.Color = CFG[key] end
    end)
end

local function actionBtn(page, label, color, onClick)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = color or C.bg3,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = label,
        TextColor3 = C.fg,
        TextSize = 13,
        AutoButtonColor = false,
        LayoutOrder = nextOrder(),
        Parent = page,
    })
    corner(b, 10)
    local base = color or C.bg3
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15),
            { BackgroundColor3 = base:Lerp(Color3.new(1,1,1), 0.12) }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15),
            { BackgroundColor3 = base }):Play()
    end)
    b.MouseButton1Click:Connect(onClick)
end

-- ============ POBLAR PÁGINAS ============
local aimPage = pages["AIM"]
section(aimPage, "AIMBOT")
toggle(aimPage, "Activar aimbot", "Enabled")
slider(aimPage, "FOV", "FOV", 30, 400, false, nil, function(v)
    if fovCircle then fovCircle.Radius = v end
    if fovGlow then fovGlow.Radius = v + 2 end
end)
slider(aimPage, "Suavizado", "Smoothness", 0, 1, true)
slider(aimPage, "Distancia máxima", "MaxDistance", 100, 1500, false)
partSelector(aimPage)
section(aimPage, "LOCK")
toggle(aimPage, "FOV pegado a la cabeza", "FOVLockToTarget")
section(aimPage, "FILTROS")
toggle(aimPage, "Team check (off — no hay teams)", "TeamCheck")
toggle(aimPage, "Wall check", "WallCheck")

local espPage = pages["ESP"]
section(espPage, "JUGADORES")
toggle(espPage, "ESP jugadores", "PlayerESP")
toggle(espPage, "Caja", "BoxESP")
toggle(espPage, "Nombre", "NameESP")
toggle(espPage, "Armas", "WeaponESP")
toggle(espPage, "Barra de vida", "HealthESP")
section(espPage, "ITEMS")
toggle(espPage, "Items dropeados", "ItemESP")
slider(espPage, "Rango ESP", "MaxESP", 100, 2000, false)

local visPage = pages["VISUAL"]
section(visPage, "FOV CIRCLE")
toggle(visPage, "Mostrar círculo FOV", "DrawFOV")
colorRow(visPage, "Color ESP / FOV", "ESPColor")
section(visPage, "PRIORIDAD")
actionBtn(visPage, "Más cercano a la mira", C.bg3, function() CFG.Priority = "fov" end)
actionBtn(visPage, "Más cercano 3D", C.bg3, function() CFG.Priority = "dist" end)

local cfgPage = pages["CONFIG"]
section(cfgPage, "KEYBINDS")
keybindRow(cfgPage, "Apuntar (hold)", "HoldKey")
keybindRow(cfgPage, "Toggle aimbot", "ToggleKey")
keybindRow(cfgPage, "Abrir/cerrar panel", "PanelKey")
section(cfgPage, "ACCIONES")
actionBtn(cfgPage, "Restaurar posición del panel", C.bg3, function()
    panel.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
end)
actionBtn(cfgPage, "Reiniciar todo", C.danger, function()
    if fovCircle then fovCircle:Remove() end
    if fovGlow then fovGlow:Remove() end
    for _, t in pairs(pESP) do dispose(t) end
    for _, r in pairs(iESP) do
        if r.text then pcall(function() r.text:Remove() end) end
    end
    sg:Destroy()
    getgenv().BSS_AimV5 = false
    warn("[BSS-Aim v5] reiniciado")
end)

selectTab("AIM")

local footer = new("Frame", {
    Size = UDim2.new(1, -32, 0, 34),
    Position = UDim2.new(0, 16, 1, -46),
    BackgroundColor3 = C.bg2,
    BorderSizePixel = 0,
    Parent = panel,
})
corner(footer, 9)
new("TextLabel", {
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "F1 abre/cierra · RMB apunta · soltá RMB y el lock se suelta",
    TextColor3 = C.muted,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = footer,
})

-- drag panel
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

-- ============ MINIMIZAR (ARREGLADO) ============
local mini = new("TextButton", {
    Size = UDim2.fromOffset(52, 52),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Text = "⌖",
    TextColor3 = C.accent,
    TextSize = 26,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Visible = false,
    Parent = sg,
})
corner(mini, 26)
new("UIStroke", { Color = C.accent, Thickness = 2, Parent = mini })

-- drag del mini
local miniDragging, miniStartPos, miniStartMouse, miniMoved
mini.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniMoved = false
        miniStartMouse = i.Position
        miniStartPos = mini.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if miniDragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
        local dl = i.Position - miniStartMouse
        if math.abs(dl.X) > 4 or math.abs(dl.Y) > 4 then miniMoved = true end
        mini.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + dl.X,
                                    miniStartPos.Y.Scale, miniStartPos.Y.Offset + dl.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
    end
end)

-- click del mini para reabrir (con umbral de 4px para distinguir de drag)
mini.MouseButton1Click:Connect(function()
    if miniMoved then return end
    -- restaurar panel
    panel.Visible = true
    panel.Size = UDim2.fromOffset(1, 1)
    local miniPos = mini.AbsolutePosition
    panel.Position = UDim2.new(0, miniPos.X - W/2 + 26, 0, miniPos.Y)
    TweenService:Create(panel,
        TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Size = UDim2.fromOffset(W, H) }):Play()
    mini.Visible = false
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
            mini.Position = UDim2.new(0, fromP.X + W - 46, 0, fromP.Y + 8)
            mini.Size = UDim2.fromOffset(1, 1)
            mini.Visible = true
            TweenService:Create(mini,
                TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(52, 52) }):Play()
        end)
    else
        mini.Visible = false
        panel.Visible = true
        panel.Size = UDim2.fromOffset(1, 1)
        TweenService:Create(panel,
            TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(W, H) }):Play()
    end
end

minBtn.MouseButton1Click:Connect(togglePanel)
closeBtn.MouseButton1Click:Connect(function()
    if fovCircle then fovCircle:Remove() end
    if fovGlow then fovGlow:Remove() end
    for _, t in pairs(pESP) do dispose(t) end
    for _, r in pairs(iESP) do
        if r.text then pcall(function() r.text:Remove() end) end
    end
    sg:Destroy()
    getgenv().BSS_AimV5 = false
end)

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.PanelKey then togglePanel() end
end)

pcall(function()
    LP.PlayerGui:SetCore("SendNotification", {
        Title = "BSS-Aim v5",
        Text = "F1 panel · RMB apunta · FOV lock activado",
        Duration = 5,
    })
end)

print("[BSS-Aim v5] cargado — FOV lock + panel neón")
