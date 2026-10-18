-- ============================================================================
-- RESTORE CAMERA — helper centralizado
-- ============================================================================

-- Part invisible fija en el mundo que usamos como subject falso
-- así el motor no recalcula la posición de cámara encima del lock
local _fakePart = Instance.new("Part")
_fakePart.Name        = "BSS_FakeCamSubject"
_fakePart.Size        = Vector3.new(0.1, 0.1, 0.1)
_fakePart.Anchored    = true
_fakePart.CanCollide  = false
_fakePart.CanTouch    = false
_fakePart.Massless    = true
_fakePart.Transparency = 1
_fakePart.Parent      = Workspace

-- flag: ¿nosotros pusimos el fake subject?
local _fakeLockActive = false

local function activateLock()
    if _fakeLockActive then return end
    _fakeLockActive     = true
    _origCamSubject     = Camera.CameraSubject
    -- mantenemos Custom, solo cambiamos el subject a la part fija
    -- → el motor deja de mover la posición de cámara cada frame
    Camera.CameraSubject = _fakePart
end

local function restoreCamera()
    if not _fakeLockActive then return end
    _fakeLockActive = false
    pcall(function()
        Camera.CameraSubject = _origCamSubject or (_lHum)
    end)
end

-- ============================================================================
-- INPUT
-- ============================================================================
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        if input.Delta.Magnitude > 0.5 then lastMouseMove = tick() end
    end
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.HoldKey then aimOn = true end
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.KeyCode == Enum.KeyCode.ButtonR2 then
        isFiring = true
        if CFG.NoRecoil and not (CFG.CameraLock and aimOn and curTarget) then
            savedRot = Camera.CFrame.Rotation
        end
    end
    if i.KeyCode == CFG.PanicKey then
        aimOn = false; CFG.Enabled = false
        restoreCamera()
        toast("PANIC", "Todo desactivado", 3)
    end
end)

UserInputService.InputEnded:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == CFG.HoldKey then
        aimOn = false
        restoreCamera()
        curTarget = nil; curPlr = nil
    end
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.KeyCode == Enum.KeyCode.ButtonR2 then
        isFiring = false; savedRot = nil
    end
end)

-- ============================================================================
-- SILENT AIM  (sin cambios)
-- ============================================================================
local _mt     = nil
local _oldNC  = nil
local _silentOn = false
pcall(function() if getrawmetatable then _mt = getrawmetatable(game) end end)
if _mt then _oldNC = rawget(_mt, "__namecall") end

local function enableSilent()
    if _silentOn or not _mt or not newcclosure or not setreadonly then return end
    _silentOn = true
    pcall(function()
        setreadonly(_mt, false)
        _mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod and getnamecallmethod()
            if method == "FireServer" and curTarget and CFG.Enabled and aimOn
            and not manualAimOverride then
                local args = {...}
                if #args >= 1 then
                    local f = args[1]
                    if typeof(f) == "Vector3" then
                        args[1] = (curTarget.Position - Camera.CFrame.Position).Unit
                                  * math.max(f.Magnitude, 1000)
                    elseif typeof(f) == "CFrame" then
                        args[1] = CFrame.new(Camera.CFrame.Position, curTarget.Position)
                    end
                end
                return _oldNC(self, table.unpack(args))
            end
            return _oldNC(self, ...)
        end)
        setreadonly(_mt, true)
    end)
end

local function disableSilent()
    if not _silentOn or not _mt or not _oldNC then return end
    _silentOn = false
    pcall(function()
        setreadonly(_mt, false)
        _mt.__namecall = _oldNC
        setreadonly(_mt, true)
    end)
end

-- ============================================================================
-- HITBOX  (sin cambios)
-- ============================================================================
local function applyHB(char)
    if not CFG.HitboxOn or not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not _hitboxOriginal[char] then
        _hitboxOriginal[char] = {
            hrpSize=hrp and hrp.Size, hrpT=hrp and hrp.Transparency,
            hrpCollide=hrp and hrp.CanCollide, hrpMass=hrp and hrp.Massless,
            hrpTouch=hrp and hrp.CanTouch,
            headSize=head and head.Size, headT=head and head.Transparency,
            headCollide=head and head.CanCollide, headMass=head and head.Massless,
            headTouch=head and head.CanTouch,
        }
    end
    local s = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize)
    local t = CFG.HitboxAlpha
    local cache = _hitboxApplied[char]
    if not cache then cache = {}; _hitboxApplied[char] = cache end
    if hrp then
        if cache.hrpCollide ~= false then hrp.CanCollide=false; cache.hrpCollide=false end
        if cache.hrpMass    ~= true  then hrp.Massless=true;    cache.hrpMass=true    end
        if cache.hrpTouch   ~= false then hrp.CanTouch=false;   cache.hrpTouch=false  end
        if cache.hrpSize    ~= s     then hrp.Size=s;           cache.hrpSize=s       end
        if cache.hrpT       ~= t     then hrp.Transparency=t;   cache.hrpT=t          end
    end
    if head then
        if cache.headCollide ~= false then head.CanCollide=false; cache.headCollide=false end
        if cache.headMass    ~= true  then head.Massless=true;    cache.headMass=true    end
        if cache.headTouch   ~= false then head.CanTouch=false;   cache.headTouch=false  end
        if cache.headSize    ~= s     then head.Size=s;           cache.headSize=s       end
        if cache.headT       ~= t     then head.Transparency=t;   cache.headT=t          end
    end
end

local function restoreHB(char)
    local o = _hitboxOriginal[char]; if not o then return end
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")
    if hrp then
        if o.hrpSize    then hrp.Size=o.hrpSize end
        if o.hrpT       ~= nil then hrp.Transparency=o.hrpT end
        if o.hrpCollide ~= nil then hrp.CanCollide=o.hrpCollide end
        if o.hrpMass    ~= nil then hrp.Massless=o.hrpMass end
        if o.hrpTouch   ~= nil then hrp.CanTouch=o.hrpTouch end
    end
    if head then
        if o.headSize    then head.Size=o.headSize end
        if o.headT       ~= nil then head.Transparency=o.headT end
        if o.headCollide ~= nil then head.CanCollide=o.headCollide end
        if o.headMass    ~= nil then head.Massless=o.headMass end
        if o.headTouch   ~= nil then head.CanTouch=o.headTouch end
    end
    _hitboxOriginal[char] = nil
    _hitboxApplied[char]  = nil
end

local function restoreAllHB()
    for c in pairs(_hitboxOriginal) do restoreHB(c) end
end

local function reapplyAllHB()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then applyHB(p.Character) end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(0.3)
        if CFG.HitboxOn then applyHB(c) end
    end)
end)

-- ============================================================================
-- FOV CIRCLE  (sin cambios)
-- ============================================================================
local fovSG  = Instance.new("ScreenGui")
fovSG.Name          = "BSS_FOV"
fovSG.ResetOnSpawn  = false
fovSG.IgnoreGuiInset = true
fovSG.DisplayOrder  = 9999
fovSG.Parent        = gui()

local fovRing = Instance.new("Frame")
fovRing.BackgroundTransparency = 1
fovRing.AnchorPoint = Vector2.new(.5, .5)
fovRing.Position    = UDim2.fromScale(.5, .5)
fovRing.Visible     = false
fovRing.ZIndex      = 100
fovRing.Parent      = fovSG
Instance.new("UICorner", fovRing).CornerRadius = UDim.new(1, 0)
local fovStk = Instance.new("UIStroke")
fovStk.Color     = C.acc
fovStk.Thickness = 1.5
fovStk.Parent    = fovRing

-- ============================================================================
-- MOBILE AIM  (sin cambios salvo restoreCamera al soltar)
-- ============================================================================
local aimBtn = nil
if IS_MOBILE then
    aimBtn = Instance.new("TextButton")
    aimBtn.Name                 = "BSS_AimBtn"
    aimBtn.Size                 = UDim2.fromOffset(88, 88)
    aimBtn.Position             = UDim2.new(0, 20, 1, -210)
    aimBtn.BackgroundColor3     = Color3.fromRGB(10, 12, 18)
    aimBtn.BackgroundTransparency = 0.15
    aimBtn.Text                 = "AIM"
    aimBtn.TextColor3           = C.acc
    aimBtn.TextSize             = 20
    aimBtn.Font                 = Enum.Font.GothamBold
    aimBtn.AutoButtonColor      = false
    aimBtn.Active               = true
    aimBtn.ZIndex               = 200
    aimBtn.Parent               = fovSG
    Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(1, 0)
    local abStk = Instance.new("UIStroke")
    abStk.Thickness = 2; abStk.Color = C.acc; abStk.Parent = aimBtn
    aimBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            aimOn = true
            abStk.Color = C.aimOn; aimBtn.TextColor3 = C.aimOn
        end
    end)
    aimBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            aimOn = false
            restoreCamera()
            curTarget = nil; curPlr = nil
            abStk.Color = C.acc; aimBtn.TextColor3 = C.acc
        end
    end)
end

-- ============================================================================
-- ESP  (sin cambios)
-- ============================================================================
local function clearEspPlayer(plr)
    if _espHL[plr] then pcall(function() _espHL[plr]:Destroy() end); _espHL[plr] = nil end
    if _espBB[plr] then pcall(function() _espBB[plr]:Destroy() end); _espBB[plr] = nil end
    _espRef[plr]   = nil
    _espCache[plr] = nil
end

local function makeHL(char)
    local hl = Instance.new("Highlight")
    hl.Name              = "BSS_HL"
    hl.FillTransparency  = 0.45
    hl.OutlineTransparency = 0
    hl.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee           = char
    hl.Parent            = char
    return hl
end

local function makeBB(head)
    local bb = Instance.new("BillboardGui")
    bb.Name                    = "BSS_BB"
    bb.AlwaysOnTop             = true
    bb.Adornee                 = head
    bb.Parent                  = head
    bb.StudsOffsetWorldSpace   = Vector3.new(0, 3.2, 0)
    bb.Size                    = UDim2.fromOffset(160, 70)

    local function lbl(name, yPos, sz, col)
        local l = Instance.new("TextLabel")
        l.Name                  = name
        l.BackgroundTransparency = 1
        l.Size                  = UDim2.new(1, 0, 0, sz + 2)
        l.Position              = UDim2.new(0, 0, 0, yPos)
        l.Font                  = Enum.Font.GothamBold
        l.TextSize              = sz
        l.TextColor3            = col
        l.TextStrokeTransparency = 0.2
        l.TextXAlignment        = Enum.TextXAlignment.Center
        l.TextTruncate          = Enum.TextTruncate.AtEnd
        l.Parent                = bb
        return l
    end

    local nameLbl = lbl("Name", 0,  13, Color3.new(1,1,1))
    local hpLbl   = lbl("HP",   15, 11, C.hp)
    local wepLbl  = lbl("Wep",  28, 11, C.gold)

    local wepImg = Instance.new("ImageLabel")
    wepImg.Name                 = "WepImg"
    wepImg.BackgroundTransparency = 1
    wepImg.Size                 = UDim2.fromOffset(20, 20)
    wepImg.Position             = UDim2.new(0, 4, 0, 27)
    wepImg.ScaleType            = Enum.ScaleType.Fit
    wepImg.Image                = ""
    wepImg.Parent               = bb

    return bb, {name=nameLbl, hp=hpLbl, wep=wepLbl, img=wepImg}
end

local _espSubframe = 0
local function updateESP()
    _espSubframe = (_espSubframe + 1) % 2

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if CFG.TeamCheck and plr.Team == LP.Team then clearEspPlayer(plr); continue end

        local char = plr.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not (char and hrp and head and hum) or hum.Health <= 0 then
            clearEspPlayer(plr); continue
        end

        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > CFG.MaxESP then clearEspPlayer(plr); continue end

        if CFG.PlayerESP and CFG.ChamsESP then
            if not _espHL[plr] or not _espHL[plr].Parent then
                _espHL[plr] = makeHL(char)
            end
            if _espSubframe == 0 then
                local hpR     = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local fillCol = hpR > 0.6 and C.hp or hpR > 0.3 and C.warn or C.dng
                _espHL[plr].FillColor = fillCol
                if CFG.WeaponESP then
                    local we = getBestWeapon(plr)
                    _espHL[plr].OutlineColor = we and we.col or Color3.fromRGB(0,0,0)
                else
                    _espHL[plr].OutlineColor = Color3.fromRGB(0,0,0)
                end
            end
        else
            if _espHL[plr] then _espHL[plr]:Destroy(); _espHL[plr] = nil end
        end

        if CFG.PlayerESP and (CFG.NameESP or CFG.HealthESP or CFG.WeaponESP) then
            local refs = _espRef[plr]
            if not _espBB[plr] or not _espBB[plr].Parent or not refs then
                local bb, r = makeBB(head)
                _espBB[plr] = bb; _espRef[plr] = r; refs = r
            end

            local sm = math.clamp(1 + (dist / CFG.MaxESP) * 1.2, 1, 2.2)
            _espBB[plr].Size                  = UDim2.fromOffset(160*sm, 70*sm)
            _espBB[plr].StudsOffsetWorldSpace  = Vector3.new(0, 3.2*sm, 0)

            if refs.name then
                refs.name.Visible = CFG.NameESP
                if CFG.NameESP then refs.name.Text = plr.Name end
            end

            if refs.hp and _espSubframe == 0 then
                refs.hp.Visible = CFG.HealthESP
                if CFG.HealthESP then
                    refs.hp.Text = string.format(
                        "%d❤  %.0f%%",
                        math.floor(hum.Health),
                        math.clamp(hum.Health / hum.MaxHealth * 100, 0, 100)
                    )
                    local hpR = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    refs.hp.TextColor3 = hpR > 0.6 and C.hp or hpR > 0.3 and C.warn or C.dng
                end
            end

            if refs.wep and CFG.WeaponESP and _espSubframe == 0 then
                local we, tex = getBestWeapon(plr)
                if we then
                    refs.wep.Visible    = true
                    refs.wep.Text       = (TIER_LABEL[we.tier] or "[?]") .. "  " .. we.label
                    refs.wep.TextColor3 = TIER_COL[we.tier] or C.acc
                    if refs.img then
                        refs.img.Image        = tex or ""
                        refs.img.ImageColor3  = we.col
                        refs.img.Visible      = (tex and tex ~= "") and true or false
                        refs.wep.Position     = (tex and tex ~= "")
                            and UDim2.new(0, 26, 0, 28)
                            or  UDim2.new(0,  0, 0, 28)
                    end
                else
                    refs.wep.Visible = false
                    if refs.img then refs.img.Visible = false end
                end
            end
        else
            if _espBB[plr] then _espBB[plr]:Destroy(); _espBB[plr]=nil; _espRef[plr]=nil end
        end
    end

    for plr in pairs(_espHL) do if not plr.Parent then clearEspPlayer(plr) end end
    for plr in pairs(_espBB) do if not plr.Parent then clearEspPlayer(plr) end end
end

-- ============================================================================
-- PICKUP / KILLS / LOOPS  (sin cambios)
-- ============================================================================
local _lastPick = 0
local function tryPickup()
    if not CFG.PickupOn or not _lHRP then return end
    local now = tick()
    if now - _lastPick < CFG.PickupDelay then return end
    local folder = Workspace:FindFirstChild("DroppedItems")
    if not folder then return end
    local hrpPos = _lHRP.Position
    local picked = false
    for _, m in ipairs(folder:GetChildren()) do
        local part = m:FindFirstChild("PickUpZone") or m:FindFirstChild("CashPart")
                  or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
        if not part then continue end
        if (hrpPos - part.Position).Magnitude > CFG.PickupRadius then continue end
        local n = m.Name:lower(); local ok = false
        if     n:find("money") or n:find("cash")   then ok = CFG.PickupMoney
        elseif n:find("gun") or n:find("ak") or n:find("pistol")
            or n:find("rifle") or n:find("taser")
            or n:find("uzi")  or n:find("glock")   then ok = CFG.PickupWeapons
        elseif n:find("food") or n:find("burger")
            or n:find("pizza") or n:find("drink")  then ok = CFG.PickupFood
        elseif n:find("tool") or n:find("wrench")
            or n:find("hammer")                    then ok = CFG.PickupTools
        else ok = true end
        if ok then
            pcall(function()
                if m:IsA("Model") then
                    m:PivotTo(CFrame.new(hrpPos))
                elseif part:IsA("BasePart") then
                    part.CFrame = CFrame.new(hrpPos)
                end
                if firetouchinterest then
                    firetouchinterest(_lHRP, part, 0)
                    task.defer(function() firetouchinterest(_lHRP, part, 1) end)
                end
            end)
            picked = true; sessItems += 1
        end
    end
    if picked then _lastPick = now end
end

local function trackKills()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local prev = lastHPSnap[plr]; local cur = hum.Health
            if prev and prev > 0 and cur <= 0 then sessKills += 1 end
            lastHPSnap[plr] = cur
        end
    end
end

task.spawn(function() while _alive do pcall(updateESP);    task.wait(CFG.ESPRefresh or 0.05) end end)
task.spawn(function() while _alive do pcall(tryPickup);    task.wait(0.12)  end end)
task.spawn(function() while _alive do pcall(trackKills);   task.wait(0.25)  end end)
task.spawn(function() while _alive do pcall(applyHideName);task.wait(2)     end end)
task.spawn(function()
    while _alive do
        if CFG.HitboxOn then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and not _hitboxOriginal[p.Character] then
                    applyHB(p.Character)
                end
            end
        end
        task.wait(1)
    end
end)

-- ============================================================================
-- TARGET SCAN — Heartbeat
-- ============================================================================
local _scanT = 0
RunService.Heartbeat:Connect(function()
    if not _alive then return end
    manualAimOverride = (tick() - lastMouseMove) < 0.15
    if manualAimOverride then
        curTarget = nil; curPlr = nil; return
    end
    if not (CFG.Enabled and aimOn) then
        if curTarget then curTarget = nil; curPlr = nil end
        return
    end
    local now = tick()
    if now - _scanT < 0.016 then return end
    _scanT = now

    local p, part = findBestTarget()

    if not curTarget or targetGone() then
        curTarget = part; curPlr = p; lastSwitch = now
    elseif part and part ~= curTarget then
        local curPx = screenDist(curTarget)
        local newPx = part and screenDist(part) or math.huge
        if newPx + 10 < curPx and (now - lastSwitch) > 0.05 then
            curTarget = part; curPlr = p; lastSwitch = now
        end
    end
end)

-- ============================================================================
-- MAIN LOOP — CAMERA LOCK SIN SCRIPTABLE
-- ============================================================================
pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)

RunService:BindToRenderStep("BSS_Aim_Ultra_Loop", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not _alive then return end

    fpsCount += 1
    if tick() - fpsTimer >= 1 then curFPS = fpsCount; fpsCount = 0; fpsTimer = tick() end

    _inCar = _lHum and _lHum.SeatPart ~= nil

    local wantSilent = IS_PC and CFG.SilentAim and CFG.Enabled
                       and aimOn and curTarget ~= nil and not manualAimOverride
    if wantSilent and not _silentOn then enableSilent()
    elseif not wantSilent and _silentOn then disableSilent() end

    if CFG.DrawFOV and CFG.Enabled and aimOn then
        fovRing.Size    = UDim2.fromOffset(CFG.FOVRadius*2, CFG.FOVRadius*2)
        fovStk.Color    = curTarget and C.lock or C.acc
        fovRing.Visible = true
    else
        fovRing.Visible = false
    end

    local lockActive = CFG.Enabled and aimOn and curTarget
                       and CFG.CameraLock and not manualAimOverride

    if lockActive then
        local camPos   = Camera.CFrame.Position
        local ok, tPos = pcall(function() return curTarget.Position end)

        if ok and tPos then
            -- Activar fake subject para que Roblox no mueva la posición
            activateLock()

            -- ── DIRECCIÓN ────────────────────────────────────────────────
            local lookDir = tPos - camPos
            if lookDir.Magnitude < 0.01 then return end
            lookDir = lookDir.Unit

            -- upVec estable: si el target está casi vertical usamos
            -- el rightVector actual de la cámara para no tener gimbal flip
            local upVec
            if math.abs(lookDir.Y) > 0.98 then
                local right = Camera.CFrame.RightVector
                upVec = right:Cross(lookDir)
                if upVec.Magnitude < 0.001 then upVec = Vector3.new(1,0,0) end
                upVec = upVec.Unit
            else
                upVec = Vector3.new(0,1,0)
            end

            -- ── MOVER LA FAKE PART AL MISMO SITIO QUE LA CÁMARA ─────────
            -- mantiene la posición fija; solo la rotación cambia
            _fakePart.CFrame = CFrame.new(camPos)

            -- ── ESCRIBIR EL CFRAME FINAL ──────────────────────────────────
            -- CFrame.lookAt preserva la posición exacta de la cámara
            -- y solo rota hacia el target; el personaje sigue libre
            local alpha = math.clamp(CFG.LockSmooth * (1 + dt * 30), 0.05, 1)
            local targetCF = CFrame.lookAt(camPos, tPos, upVec)
            Camera.CFrame  = Camera.CFrame:Lerp(targetCF, alpha)

        else
            curTarget = nil; curPlr = nil
            restoreCamera()
        end

    else
        -- Lock inactivo: restaurar subject si lo cambiamos nosotros
        if _fakeLockActive then
            restoreCamera()
        end

        -- No Recoil (solo cuando lock off)
        if CFG.NoRecoil and isFiring and savedRot and not _inCar then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * savedRot
        end
    end

    -- ── HUD ──────────────────────────────────────────────────────────────
    if _uiCache.wmVisible ~= CFG.WatermarkOn then
        wm.Visible = CFG.WatermarkOn; _uiCache.wmVisible = CFG.WatermarkOn
    end
    if _uiCache.statsVisible ~= CFG.StatsOn then
        stats.Visible = CFG.StatsOn; _uiCache.statsVisible = CFG.StatsOn
    end
    if CFG.StatsOn then
        local mins = math.floor((tick() - sessStart) / 60)
        if sessKills~=_stK or sessItems~=_stI or mins~=_stM or curFPS~=_stF then
            _stK=sessKills; _stI=sessItems; _stM=mins; _stF=curFPS
            statsLbl.Text = string.format(
                "Kills:    %d\nPickups:  %d\nSesión:   %dm\nFPS:      %d",
                sessKills, sessItems, mins, curFPS
            )
            stats.Size = UDim2.fromOffset(175, 78)
        end
    end
end)

toast("BSS-Aim ULTRA v15.0", "FakePart lock activo — sin Scriptable", 5)
print("[BSS-Aim ULTRA v15.0] OK | Custom + FakePart subject + LookAt")
