-- ============================================================================
-- BSS-Aim ULTRA v15.0 — COMPLETO | FakePart Camera Lock
-- ============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local StarterGui       = game:GetService("StarterGui")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

pcall(function()
    if gethui then
        for _, v in ipairs(gethui():GetChildren()) do
            if v.Name:match("^BSS_") then v:Destroy() end
        end
    end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, v in ipairs(pg:GetChildren()) do
            if v.Name:match("^BSS_") then v:Destroy() end
        end
    end
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
end)

getgenv().BSS_Aim_Loaded = true
local _alive = true

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_PC     = not IS_MOBILE
local ICON      = "rbxassetid://96190503453096"

local _origCamType    = Camera.CameraType
local _origCamSubject = Camera.CameraSubject

-- ============================================================================
-- WEAPON DB
-- ============================================================================
local WEAPON_DB = {
    ["M249"]              = {tier=5, label="M249",        col=Color3.fromRGB(255,50,50)},
    ["Anaconda"]          = {tier=5, label="Anaconda",    col=Color3.fromRGB(255,50,50)},
    ["RPG"]               = {tier=4, label="RPG",         col=Color3.fromRGB(255,140,0)},
    ["M16"]               = {tier=4, label="M16",         col=Color3.fromRGB(255,140,0)},
    ["AK47"]              = {tier=4, label="AK47",        col=Color3.fromRGB(255,140,0)},
    ["AK-47"]             = {tier=4, label="AK47",        col=Color3.fromRGB(255,140,0)},
    ["Remington"]         = {tier=4, label="Remington",   col=Color3.fromRGB(255,140,0)},
    ["MP5"]               = {tier=4, label="MP5",         col=Color3.fromRGB(255,140,0)},
    ["Crossbow"]          = {tier=4, label="Crossbow",    col=Color3.fromRGB(255,140,0)},
    ["Tactical Axe"]      = {tier=4, label="Tac.Axe",    col=Color3.fromRGB(255,140,0)},
    ["Tactical Shovel"]   = {tier=4, label="Tac.Shovel",  col=Color3.fromRGB(255,140,0)},
    ["Tactical Knife"]    = {tier=4, label="Tac.Knife",   col=Color3.fromRGB(255,140,0)},
    ["Firework Launcher"] = {tier=4, label="Firework",    col=Color3.fromRGB(255,140,0)},
    ["M24"]               = {tier=3, label="M24",         col=Color3.fromRGB(160,80,255)},
    ["Draco"]             = {tier=3, label="Draco",       col=Color3.fromRGB(160,80,255)},
    ["Skorpion"]          = {tier=3, label="Skorpion",    col=Color3.fromRGB(160,80,255)},
    ["Double Barrel"]     = {tier=3, label="Dbl.Barrel",  col=Color3.fromRGB(160,80,255)},
    ["Barbed Baseball Bat"]={tier=3, label="Barbed Bat",  col=Color3.fromRGB(160,80,255)},
    ["Sledge Hammer"]     = {tier=3, label="Sledge",      col=Color3.fromRGB(160,80,255)},
    ["Combat Axe"]        = {tier=3, label="Cmbt.Axe",    col=Color3.fromRGB(160,80,255)},
    ["Machete"]           = {tier=3, label="Machete",     col=Color3.fromRGB(160,80,255)},
    ["Shovel"]            = {tier=3, label="Shovel",      col=Color3.fromRGB(160,80,255)},
    ["Brainrot Slapper"]  = {tier=2, label="Brainrot",    col=Color3.fromRGB(80,220,120)},
    ["Hunting Rifle"]     = {tier=2, label="Hunt.Rifle",  col=Color3.fromRGB(80,220,120)},
    ["Uzi"]               = {tier=2, label="Uzi",         col=Color3.fromRGB(80,220,120)},
    ["Sawnoff"]           = {tier=2, label="Sawnoff",     col=Color3.fromRGB(80,220,120)},
    ["P226"]              = {tier=2, label="P226",        col=Color3.fromRGB(80,220,120)},
    ["Glock"]             = {tier=2, label="Glock",       col=Color3.fromRGB(80,220,120)},
    ["Metal Baseball Bat"]= {tier=2, label="Metal Bat",   col=Color3.fromRGB(80,220,120)},
    ["Wrench"]            = {tier=2, label="Wrench",      col=Color3.fromRGB(80,220,120)},
    ["Crowbar"]           = {tier=2, label="Crowbar",     col=Color3.fromRGB(80,220,120)},
    ["Axe"]               = {tier=2, label="Axe",         col=Color3.fromRGB(80,220,120)},
    ["Frying Pan"]        = {tier=2, label="Pan",         col=Color3.fromRGB(80,220,120)},
    ["Butcher Knife"]     = {tier=2, label="Butcher",     col=Color3.fromRGB(80,220,120)},
    ["Switchblade"]       = {tier=2, label="Switchblade", col=Color3.fromRGB(80,220,120)},
    ["Baseball Bat"]      = {tier=1, label="Baseball Bat",col=Color3.fromRGB(180,180,180)},
    ["G3"]                = {tier=1, label="G3",          col=Color3.fromRGB(180,180,180)},
    ["C9"]                = {tier=1, label="C9",          col=Color3.fromRGB(180,180,180)},
}

local TIER_LABEL = {[5]="[Ω]",[4]="[L]",[3]="[E]",[2]="[R]",[1]="[C]",[0]="[?]"}
local TIER_COL   = {
    [5]=Color3.fromRGB(255,50,50),[4]=Color3.fromRGB(255,140,0),
    [3]=Color3.fromRGB(160,80,255),[2]=Color3.fromRGB(80,220,120),
    [1]=Color3.fromRGB(180,180,180),[0]=Color3.fromRGB(120,120,120),
}

local function resolveWeapon(name)
    if not name then return nil end
    local e = WEAPON_DB[name]; if e then return e end
    local lo = name:lower()
    for k,v in pairs(WEAPON_DB) do if k:lower()==lo then return v end end
    for k,v in pairs(WEAPON_DB) do if lo:find(k:lower(),1,true) then return v end end
    return nil
end

local _wepCache = {}
local function invalidateWep(uid) _wepCache[uid] = nil end

local function getBestWeapon(plr)
    local uid  = plr.UserId
    local char = plr.Character
    local bp   = plr:FindFirstChild("Backpack")
    local eq   = char and char:FindFirstChildOfClass("Tool")
    local key  = eq and eq.Name or "__none__"
    local cached = _wepCache[uid]
    if cached and cached.key == key then return cached.entry, cached.tex end
    local best, bestTier, bestTex = nil, -1, ""
    local function scan(parent)
        if not parent then return end
        for _, t in ipairs(parent:GetChildren()) do
            if t:IsA("Tool") then
                local e    = resolveWeapon(t.Name)
                local tier = e and e.tier or 0
                if tier > bestTier then
                    bestTier = tier
                    best     = e or {tier=0,label=t.Name:sub(1,14),col=Color3.fromRGB(200,200,200)}
                    bestTex  = (t.TextureId and t.TextureId~="") and t.TextureId or ""
                end
            end
        end
    end
    scan(bp); scan(char)
    _wepCache[uid] = {key=key, entry=best, tex=bestTex}
    return best, bestTex
end

local function hookPlayer(plr)
    if plr == LP then return end
    local function onTool(c) if c:IsA("Tool") then invalidateWep(plr.UserId) end end
    local bp = plr:FindFirstChild("Backpack")
    if bp then bp.ChildAdded:Connect(onTool); bp.ChildRemoved:Connect(onTool) end
    plr.ChildAdded:Connect(function(c)
        if c.Name=="Backpack" then c.ChildAdded:Connect(onTool); c.ChildRemoved:Connect(onTool) end
    end)
    if plr.Character then
        plr.Character.ChildAdded:Connect(onTool)
        plr.Character.ChildRemoved:Connect(onTool)
    end
    plr.CharacterAdded:Connect(function(char)
        invalidateWep(plr.UserId)
        char.ChildAdded:Connect(onTool); char.ChildRemoved:Connect(onTool)
    end)
end
for _,p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(p) _wepCache[p.UserId]=nil end)

-- ============================================================================
-- CONFIG
-- ============================================================================
local CFG_FOLDER = "BSS_Ultra_v15"
local CFG_FILE   = CFG_FOLDER.."/config.json"
local HAS_IO     = (writefile and readfile and isfile and makefolder) and true or false
local CFG_VER    = 25

local function mkFolder()
    if not HAS_IO then return end
    pcall(function() if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end end)
end

local function saveCfg(path, cfg)
    if not HAS_IO then return end
    local clean = {}
    for k,v in pairs(cfg) do
        if type(v)=="number" or type(v)=="string" or type(v)=="boolean" then clean[k]=v
        elseif typeof(v)=="EnumItem" then clean[k]=tostring(v); clean[k.."__e"]=v.EnumType.Name
        elseif typeof(v)=="Color3"   then clean[k]={v.R,v.G,v.B}; clean[k.."__c"]=true end
    end
    pcall(function() mkFolder(); writefile(path, HttpService:JSONEncode(clean)) end)
end

local function loadCfg(path)
    if not HAS_IO then return nil end
    local ok,data = pcall(function()
        if not isfile(path) then return nil end
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or not data then return nil end
    for k,v in pairs(data) do
        if type(k)=="string" and k:sub(-3)=="__e" then
            local rk=k:sub(1,-4)
            if Enum[v] and data[rk] then
                local ok2,item = pcall(function() return Enum[v][data[rk]] end)
                if ok2 then data[rk]=item end
            end; data[k]=nil
        elseif type(k)=="string" and k:sub(-3)=="__c" then
            local rk=k:sub(1,-4)
            if type(data[rk])=="table" then
                local t=data[rk]; data[rk]=Color3.new(t[1],t[2],t[3])
            end; data[k]=nil
        end
    end
    return data
end

local DEFAULTS = {
    Ver=CFG_VER, Enabled=true,
    HoldKey=Enum.KeyCode.E, PanelKey=Enum.KeyCode.L,
    CloseKey=Enum.KeyCode.M, PanicKey=Enum.KeyCode.Delete,
    FOV=130, MaxDist=500, TargetPart="Head", Priority="fov",
    TeamCheck=false, WallCheck=true, DrawFOV=true, CameraLock=true,
    SilentAim=true, NoRecoil=true,
    PlayerESP=true, ChamsESP=true, NameESP=true, HealthESP=true, WeaponESP=true,
    MaxESP=400, ESPRefresh=0.05,
    HitboxOn=false, HitboxSize=10, HitboxAlpha=0.5,
    PickupOn=true, PickupRadius=50, PickupDelay=0.1,
    PickupMoney=true, PickupWeapons=true, PickupFood=true, PickupTools=true,
    WatermarkOn=true, StatsOn=true,
    HideName=false, HideNameTxt="...", HideBoard=false,
    AutoSave=true, AutoSaveInterval=10,
    LockSmooth=0.25,
}

local CFG = {}
for k,v in pairs(DEFAULTS) do CFG[k]=v end
local saved = loadCfg(CFG_FILE)
if saved and saved.Ver == CFG_VER then
    for k,v in pairs(saved) do if CFG[k]~=nil then CFG[k]=v end end
end
CFG.FOVRadius = CFG.FOV
getgenv().BSS_Cfg = CFG

local dirty = false; local lastSave = tick()
local function markDirty() dirty=true end
task.spawn(function()
    while _alive do
        if CFG.AutoSave and dirty and (tick()-lastSave)>=(CFG.AutoSaveInterval or 10) then
            saveCfg(CFG_FILE,CFG); dirty=false; lastSave=tick()
        end
        task.wait(1)
    end
end)

-- ============================================================================
-- COLORS
-- ============================================================================
local C = {
    bg    = Color3.fromRGB(6,6,8),      bg2   = Color3.fromRGB(12,12,16),
    bg3   = Color3.fromRGB(20,20,26),   bg4   = Color3.fromRGB(30,30,38),
    acc   = Color3.fromRGB(255,255,255),acc2  = Color3.fromRGB(220,220,230),
    fg    = Color3.fromRGB(245,245,250),muted = Color3.fromRGB(130,130,148),
    dng   = Color3.fromRGB(255,65,85),  brd   = Color3.fromRGB(55,55,68),
    hp    = Color3.fromRGB(80,220,120), warn  = Color3.fromRGB(240,200,70),
    aimOn = Color3.fromRGB(255,75,85),  lock  = Color3.fromRGB(255,255,255),
    gold  = Color3.fromRGB(255,200,50),
}

local function gui() return LP:WaitForChild("PlayerGui") end
local function toast(title,txt,dur)
    pcall(function() StarterGui:SetCore("SendNotification",{Title=title,Text=txt,Duration=dur or 4}) end)
end

-- ============================================================================
-- STATE
-- ============================================================================
local aimOn             = false
local curTarget         = nil
local curPlr            = nil
local lastSwitch        = 0
local isFiring          = false
local savedRot          = nil
local sessStart         = tick()
local sessKills         = 0
local sessItems         = 0
local lastHPSnap        = {}
local _inCar            = false
local lastMouseMove     = 0
local manualAimOverride = false

-- ── FAKE PART: subject falso que ancla la posición de cámara ──────────────
-- CameraType queda Custom siempre; solo cambiamos CameraSubject
-- → Roblox deja de recalcular la posición de la cámara encima del lock
-- → el personaje se sigue moviendo con libertad total
local _fakePart = Instance.new("Part")
_fakePart.Name          = "BSS_FakeCamSubject"
_fakePart.Size          = Vector3.new(0.1,0.1,0.1)
_fakePart.Anchored      = true
_fakePart.CanCollide    = false
_fakePart.CanTouch      = false
_fakePart.Massless      = true
_fakePart.Transparency  = 1
_fakePart.CastShadow    = false
_fakePart.Parent        = Workspace

local _fakeLockActive = false

local function activateLock()
    if _fakeLockActive then return end
    _fakeLockActive       = true
    _origCamSubject       = Camera.CameraSubject
    Camera.CameraSubject  = _fakePart
end

local function restoreCamera()
    if not _fakeLockActive then return end
    _fakeLockActive = false
    pcall(function()
        Camera.CameraSubject = _origCamSubject or _lHum
    end)
end

-- ── LOCAL PLAYER REFS ─────────────────────────────────────────────────────
local _lChar, _lHum, _lHRP = nil, nil, nil
local function refreshLocal()
    _lChar = LP.Character
    _lHum  = _lChar and _lChar:FindFirstChildOfClass("Humanoid")
    _lHRP  = _lChar and _lChar:FindFirstChild("HumanoidRootPart")
end
refreshLocal()
LP.CharacterAdded:Connect(function(c)
    _lChar=c; task.wait(0.3)
    _lHum=c:FindFirstChild("Humanoid")
    _lHRP=c:FindFirstChild("HumanoidRootPart")
    -- restaurar subject al nuevo Humanoid si el lock no está activo
    if not _fakeLockActive then
        pcall(function() Camera.CameraSubject = _lHum end)
    end
end)

local _vpC = Vector2.new(0,0)
local function refreshVP()
    local v=Camera.ViewportSize; _vpC=Vector2.new(v.X*.5,v.Y*.5)
end
refreshVP()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshVP)

local _uiCache         = {}
local _hitboxOriginal  = setmetatable({},{__mode="k"})
local _hitboxApplied   = setmetatable({},{__mode="k"})
local _espCache        = setmetatable({},{__mode="k"})
local _espHL           = {}
local _espBB           = {}
local _espRef          = setmetatable({},{__mode="k"})

-- ============================================================================
-- HIDE NAME
-- ============================================================================
local _origName = nil
local function applyHideName()
    if _uiCache.hideName == CFG.HideName then return end
    _uiCache.hideName = CFG.HideName
    pcall(function()
        if not _origName then _origName = LP.DisplayName end
        LP.DisplayName = CFG.HideName and (CFG.HideNameTxt or "...") or _origName
    end)
end

-- ============================================================================
-- RAYCAST FILTER
-- ============================================================================
local rayP = RaycastParams.new()
rayP.FilterType = Enum.RaycastFilterType.Exclude
local function updateFilter()
    local f = {Camera}
    if _lChar then table.insert(f,_lChar) end
    if _lHum and _lHum.SeatPart then table.insert(f,_lHum.SeatPart.Parent) end
    rayP.FilterDescendantsInstances = f
end
updateFilter()
LP.CharacterAdded:Connect(function() task.wait(0.4); updateFilter() end)

-- ============================================================================
-- AIM HELPERS
-- ============================================================================
local function isAlive(plr)
    local c=plr.Character; if not c then return false end
    local h=c:FindFirstChildOfClass("Humanoid"); return h and h.Health>0
end

local function isVisible(part,char)
    if not CFG.WallCheck then return true end
    local o=Camera.CFrame.Position
    local hit=Workspace:Raycast(o,part.Position-o,rayP)
    if not hit then return true end
    return hit.Instance and hit.Instance:IsDescendantOf(char)
end

local function getAimPart(plr)
    local c=plr.Character; if not c then return nil end
    return c:FindFirstChild(CFG.TargetPart)
        or c:FindFirstChild("Head")
        or c:FindFirstChild("HumanoidRootPart")
end

local function screenDist(part)
    local sp,on=Camera:WorldToViewportPoint(part.Position)
    if not on then return math.huge end
    return (Vector2.new(sp.X,sp.Y)-_vpC).Magnitude
end

local function findBestTarget()
    local best,bestPart,bestPlr = math.huge,nil,nil
    local camPos = Camera.CFrame.Position
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        if CFG.TeamCheck and plr.Team==LP.Team then continue end
        if not isAlive(plr) then continue end
        local part=getAimPart(plr); if not part then continue end
        local d3=(camPos-part.Position).Magnitude
        if d3>CFG.MaxDist then continue end
        local px=screenDist(part)
        if px>CFG.FOVRadius then continue end
        local score=(CFG.Priority=="dist") and d3 or px
        if score<best then
            if not CFG.WallCheck or isVisible(part,plr.Character) then
                best=score; bestPart=part; bestPlr=plr
            end
        end
    end
    return bestPlr,bestPart
end

local function targetGone()
    if not curTarget or not curTarget.Parent then return true end
    local hum=curTarget.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return true end
    return (Camera.CFrame.Position-curTarget.Position).Magnitude>CFG.MaxDist*1.1
end

-- ============================================================================
-- INPUT
-- ============================================================================
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement
    or input.UserInputType==Enum.UserInputType.Touch then
        if input.Delta.Magnitude>0.5 then lastMouseMove=tick() end
    end
end)

UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==CFG.HoldKey then aimOn=true end
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.KeyCode==Enum.KeyCode.ButtonR2 then
        isFiring=true
        if CFG.NoRecoil and not (CFG.CameraLock and aimOn and curTarget) then
            savedRot=Camera.CFrame.Rotation
        end
    end
    if i.KeyCode==CFG.PanicKey then
        aimOn=false; CFG.Enabled=false
        restoreCamera()
        toast("PANIC","Todo desactivado",3)
    end
end)

UserInputService.InputEnded:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==CFG.HoldKey then
        aimOn=false
        restoreCamera()
        curTarget=nil; curPlr=nil
    end
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.KeyCode==Enum.KeyCode.ButtonR2 then
        isFiring=false; savedRot=nil
    end
end)

-- ============================================================================
-- SILENT AIM
-- ============================================================================
local _mt=nil; local _oldNC=nil; local _silentOn=false
pcall(function() if getrawmetatable then _mt=getrawmetatable(game) end end)
if _mt then _oldNC=rawget(_mt,"__namecall") end

local function enableSilent()
    if _silentOn or not _mt or not newcclosure or not setreadonly then return end
    _silentOn=true
    pcall(function()
        setreadonly(_mt,false)
        _mt.__namecall=newcclosure(function(self,...)
            local method=getnamecallmethod and getnamecallmethod()
            if method=="FireServer" and curTarget and CFG.Enabled and aimOn
            and not manualAimOverride then
                local args={...}
                if #args>=1 then
                    local f=args[1]
                    if typeof(f)=="Vector3" then
                        args[1]=(curTarget.Position-Camera.CFrame.Position).Unit
                                *math.max(f.Magnitude,1000)
                    elseif typeof(f)=="CFrame" then
                        args[1]=CFrame.new(Camera.CFrame.Position,curTarget.Position)
                    end
                end
                return _oldNC(self,table.unpack(args))
            end
            return _oldNC(self,...)
        end)
        setreadonly(_mt,true)
    end)
end

local function disableSilent()
    if not _silentOn or not _mt or not _oldNC then return end
    _silentOn=false
    pcall(function()
        setreadonly(_mt,false); _mt.__namecall=_oldNC; setreadonly(_mt,true)
    end)
end

-- ============================================================================
-- HITBOX
-- ============================================================================
local function applyHB(char)
    if not CFG.HitboxOn or not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local head=char:FindFirstChild("Head")
    if not _hitboxOriginal[char] then
        _hitboxOriginal[char]={
            hrpSize=hrp and hrp.Size,hrpT=hrp and hrp.Transparency,
            hrpCollide=hrp and hrp.CanCollide,hrpMass=hrp and hrp.Massless,
            hrpTouch=hrp and hrp.CanTouch,
            headSize=head and head.Size,headT=head and head.Transparency,
            headCollide=head and head.CanCollide,headMass=head and head.Massless,
            headTouch=head and head.CanTouch,
        }
    end
    local s=Vector3.new(CFG.HitboxSize,CFG.HitboxSize,CFG.HitboxSize)
    local t=CFG.HitboxAlpha
    local cache=_hitboxApplied[char]
    if not cache then cache={}; _hitboxApplied[char]=cache end
    if hrp then
        if cache.hrpCollide~=false then hrp.CanCollide=false;cache.hrpCollide=false end
        if cache.hrpMass~=true     then hrp.Massless=true;   cache.hrpMass=true    end
        if cache.hrpTouch~=false   then hrp.CanTouch=false;  cache.hrpTouch=false  end
        if cache.hrpSize~=s        then hrp.Size=s;           cache.hrpSize=s       end
        if cache.hrpT~=t           then hrp.Transparency=t;  cache.hrpT=t          end
    end
    if head then
        if cache.headCollide~=false then head.CanCollide=false;cache.headCollide=false end
        if cache.headMass~=true     then head.Massless=true;   cache.headMass=true    end
        if cache.headTouch~=false   then head.CanTouch=false;  cache.headTouch=false  end
        if cache.headSize~=s        then head.Size=s;           cache.headSize=s       end
        if cache.headT~=t           then head.Transparency=t;  cache.headT=t          end
    end
end

local function restoreHB(char)
    local o=_hitboxOriginal[char]; if not o then return end
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local head=char and char:FindFirstChild("Head")
    if hrp then
        if o.hrpSize    then hrp.Size=o.hrpSize end
        if o.hrpT~=nil  then hrp.Transparency=o.hrpT end
        if o.hrpCollide~=nil then hrp.CanCollide=o.hrpCollide end
        if o.hrpMass~=nil    then hrp.Massless=o.hrpMass end
        if o.hrpTouch~=nil   then hrp.CanTouch=o.hrpTouch end
    end
    if head then
        if o.headSize    then head.Size=o.headSize end
        if o.headT~=nil  then head.Transparency=o.headT end
        if o.headCollide~=nil then head.CanCollide=o.headCollide end
        if o.headMass~=nil    then head.Massless=o.headMass end
        if o.headTouch~=nil   then head.CanTouch=o.headTouch end
    end
    _hitboxOriginal[char]=nil; _hitboxApplied[char]=nil
end

local function restoreAllHB()
    for c in pairs(_hitboxOriginal) do restoreHB(c) end
end
local function reapplyAllHB()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then applyHB(p.Character) end
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(0.3); if CFG.HitboxOn then applyHB(c) end
    end)
end)

-- ============================================================================
-- FOV CIRCLE
-- ============================================================================
local fovSG=Instance.new("ScreenGui")
fovSG.Name="BSS_FOV"; fovSG.ResetOnSpawn=false
fovSG.IgnoreGuiInset=true; fovSG.DisplayOrder=9999; fovSG.Parent=gui()

local fovRing=Instance.new("Frame")
fovRing.BackgroundTransparency=1; fovRing.AnchorPoint=Vector2.new(.5,.5)
fovRing.Position=UDim2.fromScale(.5,.5); fovRing.Visible=false
fovRing.ZIndex=100; fovRing.Parent=fovSG
Instance.new("UICorner",fovRing).CornerRadius=UDim.new(1,0)
local fovStk=Instance.new("UIStroke")
fovStk.Color=C.acc; fovStk.Thickness=1.5; fovStk.Parent=fovRing

-- ============================================================================
-- MOBILE AIM
-- ============================================================================
local aimBtn=nil
if IS_MOBILE then
    aimBtn=Instance.new("TextButton")
    aimBtn.Name="BSS_AimBtn"; aimBtn.Size=UDim2.fromOffset(88,88)
    aimBtn.Position=UDim2.new(0,20,1,-210)
    aimBtn.BackgroundColor3=Color3.fromRGB(10,12,18)
    aimBtn.BackgroundTransparency=0.15; aimBtn.Text="AIM"
    aimBtn.TextColor3=C.acc; aimBtn.TextSize=20
    aimBtn.Font=Enum.Font.GothamBold; aimBtn.AutoButtonColor=false
    aimBtn.Active=true; aimBtn.ZIndex=200; aimBtn.Parent=fovSG
    Instance.new("UICorner",aimBtn).CornerRadius=UDim.new(1,0)
    local abStk=Instance.new("UIStroke")
    abStk.Thickness=2; abStk.Color=C.acc; abStk.Parent=aimBtn
    aimBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch
        or i.UserInputType==Enum.UserInputType.MouseButton1 then
            aimOn=true; abStk.Color=C.aimOn; aimBtn.TextColor3=C.aimOn
        end
    end)
    aimBtn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch
        or i.UserInputType==Enum.UserInputType.MouseButton1 then
            aimOn=false; restoreCamera()
            curTarget=nil; curPlr=nil
            abStk.Color=C.acc; aimBtn.TextColor3=C.acc
        end
    end)
end

-- ============================================================================
-- ESP
-- ============================================================================
local function clearEspPlayer(plr)
    if _espHL[plr] then pcall(function() _espHL[plr]:Destroy() end); _espHL[plr]=nil end
    if _espBB[plr] then pcall(function() _espBB[plr]:Destroy() end); _espBB[plr]=nil end
    _espRef[plr]=nil; _espCache[plr]=nil
end

local function makeHL(char)
    local hl=Instance.new("Highlight")
    hl.Name="BSS_HL"; hl.FillTransparency=0.45; hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee=char; hl.Parent=char; return hl
end

local function makeBB(head)
    local bb=Instance.new("BillboardGui")
    bb.Name="BSS_BB"; bb.AlwaysOnTop=true; bb.Adornee=head; bb.Parent=head
    bb.StudsOffsetWorldSpace=Vector3.new(0,3.2,0); bb.Size=UDim2.fromOffset(160,70)
    local function lbl(name,yPos,sz,col)
        local l=Instance.new("TextLabel")
        l.Name=name; l.BackgroundTransparency=1
        l.Size=UDim2.new(1,0,0,sz+2); l.Position=UDim2.new(0,0,0,yPos)
        l.Font=Enum.Font.GothamBold; l.TextSize=sz; l.TextColor3=col
        l.TextStrokeTransparency=0.2; l.TextXAlignment=Enum.TextXAlignment.Center
        l.TextTruncate=Enum.TextTruncate.AtEnd; l.Parent=bb; return l
    end
    local nameLbl=lbl("Name",0,13,Color3.new(1,1,1))
    local hpLbl=lbl("HP",15,11,C.hp)
    local wepLbl=lbl("Wep",28,11,C.gold)
    local wepImg=Instance.new("ImageLabel")
    wepImg.Name="WepImg"; wepImg.BackgroundTransparency=1
    wepImg.Size=UDim2.fromOffset(20,20); wepImg.Position=UDim2.new(0,4,0,27)
    wepImg.ScaleType=Enum.ScaleType.Fit; wepImg.Image=""; wepImg.Parent=bb
    return bb,{name=nameLbl,hp=hpLbl,wep=wepLbl,img=wepImg}
end

local _espSubframe=0
local function updateESP()
    _espSubframe=(_espSubframe+1)%2
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        if CFG.TeamCheck and plr.Team==LP.Team then clearEspPlayer(plr); continue end
        local char=plr.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local head=char and char:FindFirstChild("Head")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hrp and head and hum) or hum.Health<=0 then
            clearEspPlayer(plr); continue
        end
        local dist=(Camera.CFrame.Position-hrp.Position).Magnitude
        if dist>CFG.MaxESP then clearEspPlayer(plr); continue end
        if CFG.PlayerESP and CFG.ChamsESP then
            if not _espHL[plr] or not _espHL[plr].Parent then
                _espHL[plr]=makeHL(char)
            end
            if _espSubframe==0 then
                local hpR=math.clamp(hum.Health/hum.MaxHealth,0,1)
                _espHL[plr].FillColor=hpR>0.6 and C.hp or hpR>0.3 and C.warn or C.dng
                if CFG.WeaponESP then
                    local we=getBestWeapon(plr)
                    _espHL[plr].OutlineColor=we and we.col or Color3.fromRGB(0,0,0)
                else _espHL[plr].OutlineColor=Color3.fromRGB(0,0,0) end
            end
        else
            if _espHL[plr] then _espHL[plr]:Destroy(); _espHL[plr]=nil end
        end
        if CFG.PlayerESP and (CFG.NameESP or CFG.HealthESP or CFG.WeaponESP) then
            local refs=_espRef[plr]
            if not _espBB[plr] or not _espBB[plr].Parent or not refs then
                local bb,r=makeBB(head); _espBB[plr]=bb; _espRef[plr]=r; refs=r
            end
            local sm=math.clamp(1+(dist/CFG.MaxESP)*1.2,1,2.2)
            _espBB[plr].Size=UDim2.fromOffset(160*sm,70*sm)
            _espBB[plr].StudsOffsetWorldSpace=Vector3.new(0,3.2*sm,0)
            if refs.name then
                refs.name.Visible=CFG.NameESP
                if CFG.NameESP then refs.name.Text=plr.Name end
            end
            if refs.hp and _espSubframe==0 then
                refs.hp.Visible=CFG.HealthESP
                if CFG.HealthESP then
                    refs.hp.Text=string.format("%d❤  %.0f%%",
                        math.floor(hum.Health),
                        math.clamp(hum.Health/hum.MaxHealth*100,0,100))
                    local hpR=math.clamp(hum.Health/hum.MaxHealth,0,1)
                    refs.hp.TextColor3=hpR>0.6 and C.hp or hpR>0.3 and C.warn or C.dng
                end
            end
            if refs.wep and CFG.WeaponESP and _espSubframe==0 then
                local we,tex=getBestWeapon(plr)
                if we then
                    refs.wep.Visible=true
                    refs.wep.Text=(TIER_LABEL[we.tier] or "[?]").."  "..we.label
                    refs.wep.TextColor3=TIER_COL[we.tier] or C.acc
                    if refs.img then
                        refs.img.Image=tex or ""; refs.img.ImageColor3=we.col
                        refs.img.Visible=(tex and tex~="") and true or false
                        refs.wep.Position=(tex and tex~="")
                            and UDim2.new(0,26,0,28) or UDim2.new(0,0,0,28)
                    end
                else
                    refs.wep.Visible=false
                    if refs.img then refs.img.Visible=false end
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
-- PICKUP
-- ============================================================================
local _lastPick=0
local function tryPickup()
    if not CFG.PickupOn or not _lHRP then return end
    local now=tick(); if now-_lastPick<CFG.PickupDelay then return end
    local folder=Workspace:FindFirstChild("DroppedItems"); if not folder then return end
    local hrpPos=_lHRP.Position; local picked=false
    for _,m in ipairs(folder:GetChildren()) do
        local part=m:FindFirstChild("PickUpZone") or m:FindFirstChild("CashPart")
                 or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart",true)
        if not part then continue end
        if (hrpPos-part.Position).Magnitude>CFG.PickupRadius then continue end
        local n=m.Name:lower(); local ok=false
        if     n:find("money") or n:find("cash")  then ok=CFG.PickupMoney
        elseif n:find("gun") or n:find("ak") or n:find("pistol")
            or n:find("rifle") or n:find("taser")
            or n:find("uzi") or n:find("glock")   then ok=CFG.PickupWeapons
        elseif n:find("food") or n:find("burger")
            or n:find("pizza") or n:find("drink") then ok=CFG.PickupFood
        elseif n:find("tool") or n:find("wrench")
            or n:find("hammer")                   then ok=CFG.PickupTools
        else ok=true end
        if ok then
            pcall(function()
                if m:IsA("Model") then m:PivotTo(CFrame.new(hrpPos))
                elseif part:IsA("BasePart") then part.CFrame=CFrame.new(hrpPos) end
                if firetouchinterest then
                    firetouchinterest(_lHRP,part,0)
                    task.defer(function() firetouchinterest(_lHRP,part,1) end)
                end
            end)
            picked=true; sessItems+=1
        end
    end
    if picked then _lastPick=now end
end

-- ============================================================================
-- TRACK KILLS
-- ============================================================================
local function trackKills()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        local hum=plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local prev=lastHPSnap[plr]; local cur=hum.Health
            if prev and prev>0 and cur<=0 then sessKills+=1 end
            lastHPSnap[plr]=cur
        end
    end
end

-- ============================================================================
-- UI HELPERS
-- ============================================================================
local function mk(cls,props,children)
    local i=Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    for _,c in ipairs(children or {}) do c.Parent=i end
    return i
end
local function rnd(p,r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r or 8) end
local function stk(p,col,th)
    local s=Instance.new("UIStroke",p); s.Color=col or C.brd; s.Thickness=th or 1.4; return s
end
local function pad(p,t,b,l,r)
    local u=Instance.new("UIPadding",p)
    u.PaddingTop=UDim.new(0,t or 0); u.PaddingBottom=UDim.new(0,b or 0)
    u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r or 0)
end

-- ============================================================================
-- PANEL PRINCIPAL
-- ============================================================================
local sg=mk("ScreenGui",{Name="BSS_UI",ResetOnSpawn=false,IgnoreGuiInset=true,
    DisplayOrder=9999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=gui()})
local PW,PH=430,560

local panel=mk("Frame",{Size=UDim2.fromOffset(PW,PH),
    Position=UDim2.new(.5,-PW/2,.5,-PH/2),
    BackgroundColor3=C.bg,BorderSizePixel=0,Parent=sg})
rnd(panel,14); stk(panel,C.brd,1.2)

local topBar=mk("Frame",{Size=UDim2.new(1,0,0,3),
    BackgroundColor3=C.acc,BorderSizePixel=0,Parent=panel})
rnd(topBar,14)
mk("UIGradient",{Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(120,100,255)),
    ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(80,200,255))}),Parent=topBar})

local hdr=mk("Frame",{Size=UDim2.new(1,0,0,46),Position=UDim2.new(0,0,0,3),
    BackgroundColor3=Color3.fromRGB(8,8,10),BorderSizePixel=0,Parent=panel})

local logoF=mk("Frame",{Size=UDim2.fromOffset(32,32),
    Position=UDim2.new(0,12,0.5,-16),
    BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Parent=hdr})
rnd(logoF,10); stk(logoF,Color3.fromRGB(255,255,255),1.5)
mk("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromScale(.72,.72),BackgroundTransparency=1,Image=ICON,
    ImageColor3=Color3.fromRGB(8,8,10),ScaleType=Enum.ScaleType.Fit,Parent=logoF})

mk("TextLabel",{Size=UDim2.new(0,200,0,18),Position=UDim2.new(0,52,0,4),
    BackgroundTransparency=1,Text="BSS-AIM ULTRA",
    TextColor3=Color3.fromRGB(255,255,255),TextSize=15,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,Parent=hdr})
mk("TextLabel",{Size=UDim2.new(0,240,0,13),Position=UDim2.new(0,52,0,22),
    BackgroundTransparency=1,
    Text="PRO EDITION · v15.0 · "..(IS_PC and "PC" or "Mobile"),
    TextColor3=C.muted,TextSize=10,Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left,Parent=hdr})

local function hdrBtn(txt,xOff)
    local b=mk("TextButton",{Size=UDim2.fromOffset(28,28),
        Position=UDim2.new(1,xOff,0.5,-14),BackgroundColor3=C.bg3,
        BorderSizePixel=0,Text=txt,TextColor3=C.acc,TextSize=14,
        Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,
        Parent=hdr,ZIndex=2})
    rnd(b,8); stk(b,C.brd); return b
end
local minBtn  =hdrBtn("−",-74)
local closeBtn=hdrBtn("×",-40)

local TABS={"AIM","ESP","HITBOX","PICKUP","HUD","SAFE"}
local tabFrame=mk("Frame",{Size=UDim2.new(1,-20,0,32),Position=UDim2.new(0,10,0,57),
    BackgroundColor3=C.bg2,BorderSizePixel=0,Parent=panel})
rnd(tabFrame,10); stk(tabFrame,C.brd,1)
mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,
    SortOrder=Enum.SortOrder.LayoutOrder,Parent=tabFrame})

local pages={}; local tabBtns={}
local tabLine=mk("Frame",{Size=UDim2.new(0,0,0,2),Position=UDim2.new(0,0,1,-2),
    BackgroundColor3=C.acc,BorderSizePixel=0,Parent=tabFrame})
rnd(tabLine,2)

local function selectTab(name)
    for k,p in pairs(pages) do p.Visible=(k==name) end
    for k,b in pairs(tabBtns) do
        TweenService:Create(b,TweenInfo.new(0.15),
            {TextColor3=(k==name) and C.acc or C.muted}):Play()
    end
    local ab=tabBtns[name]
    if ab then
        TweenService:Create(tabLine,TweenInfo.new(0.18,Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out),{
            Position=UDim2.new(0,ab.AbsolutePosition.X-tabFrame.AbsolutePosition.X,1,-2),
            Size=UDim2.new(0,ab.AbsoluteSize.X,0,2)
        }):Play()
    end
end

local content=mk("Frame",{Size=UDim2.new(1,-20,1,-148),
    Position=UDim2.new(0,10,0,97),BackgroundTransparency=1,Parent=panel})

for i,tname in ipairs(TABS) do
    local b=mk("TextButton",{Size=UDim2.new(1/#TABS,0,1,0),BackgroundTransparency=1,
        Text=tname,TextColor3=C.muted,TextSize=10,Font=Enum.Font.GothamBold,
        AutoButtonColor=false,Active=true,LayoutOrder=i,Parent=tabFrame})
    tabBtns[tname]=b; b.MouseButton1Click:Connect(function() selectTab(tname) end)
    local pg=mk("ScrollingFrame",{Name=tname.."_pg",Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,
        ScrollBarImageColor3=C.acc,CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=content})
    mk("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder,Parent=pg})
    pad(pg,2,4,0,4); pages[tname]=pg
end

local footer=mk("Frame",{Size=UDim2.new(1,-20,0,26),
    Position=UDim2.new(0,10,1,-34),BackgroundColor3=C.bg2,BorderSizePixel=0,Parent=panel})
rnd(footer,8); stk(footer,C.brd)
mk("TextLabel",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,10,0,0),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextColor3=C.muted,TextSize=9,
    TextXAlignment=Enum.TextXAlignment.Left,
    Text=IS_PC and "[L] panel  ·  [E] hold aim  ·  [Delete] panic" or "AIM = hold  ·  [M] cerrar",
    Parent=footer})

-- ============================================================================
-- COMPONENTS
-- ============================================================================
local _ord=0; local function nxt() _ord+=1; return _ord end

local function sec(page,txt)
    local w=mk("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,
        LayoutOrder=nxt(),Parent=page})
    local bar=mk("Frame",{Size=UDim2.new(0,3,0,15),Position=UDim2.new(0,0,.5,-7),
        BackgroundColor3=C.acc,BorderSizePixel=0,Parent=w})
    rnd(bar,2)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,10,0,0),
        Size=UDim2.new(1,-10,1,0),Font=Enum.Font.GothamBold,Text=txt,
        TextColor3=C.fg,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=w})
end

local function tog(page,lbl,key,cb)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=C.bg2,
        BorderSizePixel=0,LayoutOrder=nxt(),Parent=page})
    rnd(row,9); local rs=stk(row,C.brd)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),
        Size=UDim2.new(1,-58,1,0),Font=Enum.Font.GothamMedium,Text=lbl,
        TextColor3=C.fg,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
    local tr=mk("Frame",{Size=UDim2.fromOffset(38,20),
        Position=UDim2.new(1,-48,.5,-10),BackgroundColor3=C.bg4,BorderSizePixel=0,Parent=row})
    rnd(tr,10)
    local kn=mk("Frame",{Size=UDim2.fromOffset(14,14),
        Position=UDim2.new(0,3,.5,-7),BackgroundColor3=C.fg,BorderSizePixel=0,Parent=tr})
    rnd(kn,7)
    local function rr(anim)
        local on=CFG[key]; local x=on and 21 or 3; local col=on and C.acc or C.bg4
        if anim then
            TweenService:Create(tr,TweenInfo.new(0.16),{BackgroundColor3=col}):Play()
            TweenService:Create(kn,TweenInfo.new(0.16),{Position=UDim2.new(0,x,.5,-7)}):Play()
            TweenService:Create(rs,TweenInfo.new(0.16),{Color=on and C.acc or C.brd}):Play()
        else tr.BackgroundColor3=col; kn.Position=UDim2.new(0,x,.5,-7); rs.Color=on and C.acc or C.brd end
    end
    mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",
        Active=true,Parent=row}).MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]; rr(true); markDirty(); if cb then cb(CFG[key]) end
    end)
    rr(false)
end

local function sld(page,lbl,key,mn,mx,isFloat,cb)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=C.bg2,
        BorderSizePixel=0,LayoutOrder=nxt(),Parent=page})
    rnd(row,9); stk(row,C.brd)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,6),
        Size=UDim2.new(1,-78,0,14),Font=Enum.Font.GothamMedium,Text=lbl,
        TextColor3=C.fg,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
    local vl=mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(1,-76,0,6),
        Size=UDim2.new(0,64,0,14),Font=Enum.Font.GothamBold,Text="",
        TextColor3=C.acc,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,Parent=row})
    local tr=mk("Frame",{Size=UDim2.new(1,-24,0,5),Position=UDim2.new(0,12,1,-16),
        BackgroundColor3=C.bg4,BorderSizePixel=0,Parent=row})
    rnd(tr,3)
    local fi=mk("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.acc,
        BorderSizePixel=0,Parent=tr}); rnd(fi,3)
    local kn=mk("Frame",{Size=UDim2.fromOffset(12,12),Position=UDim2.new(0,0,.5,-6),
        BackgroundColor3=C.fg,BorderSizePixel=0,Parent=tr}); rnd(kn,6)
    local function rr()
        local v=CFG[key]; local a=math.clamp((v-mn)/(mx-mn),0,1)
        fi.Size=UDim2.new(a,0,1,0); kn.Position=UDim2.new(a,-6,.5,-6)
        vl.Text=isFloat and string.format("%.2f",v) or tostring(math.floor(v))
    end
    local drag=false
    local function fx(x)
        local tl=tr.AbsolutePosition.X; local tw=tr.AbsoluteSize.X; if tw<=0 then return end
        local v=mn+(mx-mn)*math.clamp((x-tl)/tw,0,1)
        if not isFloat then v=math.floor(v+.5) end
        CFG[key]=v; rr(); markDirty(); if cb then cb(v) end
    end
    local hit=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="",Active=true,Parent=row})
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=true; fx(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then fx(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    rr()
end

local function kbRow(page,lbl,key)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=C.bg2,
        BorderSizePixel=0,LayoutOrder=nxt(),Parent=page})
    rnd(row,9); stk(row,C.brd)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),
        Size=UDim2.new(1,-110,1,0),Font=Enum.Font.GothamMedium,Text=lbl,
        TextColor3=C.fg,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
    local btn=mk("TextButton",{Size=UDim2.fromOffset(90,24),
        Position=UDim2.new(1,-98,.5,-12),BackgroundColor3=C.bg3,BorderSizePixel=0,
        Text="",TextColor3=C.acc,TextSize=10,Font=Enum.Font.GothamBold,
        AutoButtonColor=false,Active=true,Parent=row})
    rnd(btn,7); stk(btn,C.brd)
    local cap=false
    local function rr()
        local cur=CFG[key]; local nm="?"
        if typeof(cur)=="EnumItem" then nm=cur.Name end
        btn.Text=cap and "..." or nm; btn.TextColor3=cap and C.acc2 or C.acc
    end
    btn.MouseButton1Click:Connect(function() cap=not cap; rr() end)
    UserInputService.InputBegan:Connect(function(i,gp)
        if gp or not cap then return end
        if i.UserInputType==Enum.UserInputType.Keyboard then CFG[key]=i.KeyCode end
        cap=false; rr(); markDirty()
    end)
    rr()
end

local function actBtn(page,lbl,col,fn)
    local b=mk("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=col or C.bg3,
        BorderSizePixel=0,Font=Enum.Font.GothamBold,Text=lbl,
        TextColor3=col and Color3.new(1,1,1) or C.fg,TextSize=11,
        AutoButtonColor=false,Active=true,LayoutOrder=nxt(),Parent=page})
    rnd(b,9); stk(b,col or C.brd)
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.12),
            {BackgroundColor3=(col or C.bg3):Lerp(Color3.new(1,1,1),.12)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=col or C.bg3}):Play()
    end)
    b.MouseButton1Click:Connect(fn)
end

local BPARTS={"Head","HumanoidRootPart","UpperTorso","LowerTorso",
              "LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}
local function partPicker(page)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=C.bg2,
        BorderSizePixel=0,LayoutOrder=nxt(),Parent=page})
    rnd(row,9); stk(row,C.brd)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),
        Size=UDim2.new(.42,0,1,0),Font=Enum.Font.GothamMedium,Text="Objetivo",
        TextColor3=C.fg,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
    local pv=mk("TextButton",{Size=UDim2.fromOffset(22,22),
        Position=UDim2.new(.42,0,.5,-11),BackgroundColor3=C.bg3,Text="‹",
        TextColor3=C.acc,TextSize=14,Font=Enum.Font.GothamBold,
        AutoButtonColor=false,Active=true,BorderSizePixel=0,Parent=row}); rnd(pv,6)
    local pl=mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(.42,26,0,0),Size=UDim2.new(0,105,1,0),
        Font=Enum.Font.GothamBold,Text=CFG.TargetPart,TextColor3=C.acc,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Center,
        TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
    local nx=mk("TextButton",{Size=UDim2.fromOffset(22,22),
        Position=UDim2.new(1,-32,.5,-11),BackgroundColor3=C.bg3,Text="›",
        TextColor3=C.acc,TextSize=14,Font=Enum.Font.GothamBold,
        AutoButtonColor=false,Active=true,BorderSizePixel=0,Parent=row}); rnd(nx,6)
    local function ci()
        for i,v in ipairs(BPARTS) do if v==CFG.TargetPart then return i end end; return 1
    end
    local function si(i)
        i=((i-1)%#BPARTS)+1; CFG.TargetPart=BPARTS[i]; pl.Text=CFG.TargetPart
        curTarget=nil; markDirty()
    end
    pv.MouseButton1Click:Connect(function() si(ci()-1) end)
    nx.MouseButton1Click:Connect(function() si(ci()+1) end)
end

-- ============================================================================
-- PAGES
-- ============================================================================
local ap=pages["AIM"]
sec(ap,"AIMBOT")
tog(ap,"Activar script","Enabled")
tog(ap,"Camera Lock (seguir target)","CameraLock")
tog(ap,"No Recoil","NoRecoil")
sld(ap,"FOV","FOV",30,400,false,function(v) CFG.FOVRadius=v end)
sld(ap,"Distancia máx","MaxDist",100,1500,false)
sld(ap,"Lock Smooth","LockSmooth",0.05,1,true)
kbRow(ap,"Hold aim (teclado)","HoldKey")
sec(ap,"FILTROS")
tog(ap,"Wall check","WallCheck")
tog(ap,"Team check","TeamCheck")
if IS_PC then tog(ap,"Silent aim","SilentAim") end
sec(ap,"OBJETIVO")
partPicker(ap)

local ep=pages["ESP"]
sec(ep,"JUGADORES")
tog(ep,"Activar ESP","PlayerESP")
tog(ep,"Highlight (chams)","ChamsESP")
tog(ep,"Nombre","NameESP")
tog(ep,"Vida","HealthESP")
tog(ep,"Arma + tier","WeaponESP")
sld(ep,"Rango ESP","MaxESP",50,1200,false)

local hp=pages["HITBOX"]
sec(hp,"HITBOX EXPANDER")
tog(hp,"Activar hitbox","HitboxOn",function(v)
    if v then reapplyAllHB() else restoreAllHB() end
end)
sld(hp,"Tamaño","HitboxSize",2,28,false,function()
    if CFG.HitboxOn then reapplyAllHB() end
end)
sld(hp,"Transparencia","HitboxAlpha",0,1,true,function()
    if CFG.HitboxOn then reapplyAllHB() end
end)

local pp=pages["PICKUP"]
sec(pp,"AUTO PICKUP")
tog(pp,"Activar pickup","PickupOn")
sld(pp,"Radio (studs)","PickupRadius",5,120,false)
sld(pp,"Delay","PickupDelay",0.02,0.5,true)
sec(pp,"CATEGORÍAS")
tog(pp,"Money / Cash","PickupMoney")
tog(pp,"Armas","PickupWeapons")
tog(pp,"Comida","PickupFood")
tog(pp,"Herramientas","PickupTools")

local hup=pages["HUD"]
sec(hup,"HUD")
tog(hup,"Watermark","WatermarkOn")
tog(hup,"Stats (kills/fps)","StatsOn")
sec(hup,"PRIVACIDAD")
tog(hup,"Ocultar mi nombre","HideName")
tog(hup,"Ocultar leaderboard","HideBoard")

local sp=pages["SAFE"]
sec(sp,"KEYBINDS")
kbRow(sp,"Panel (abrir)","PanelKey")
kbRow(sp,"Panel (cerrar)","CloseKey")
kbRow(sp,"Panic (desactivar todo)","PanicKey")
sec(sp,"CONFIG")
actBtn(sp,"Guardar config ahora",nil,function()
    saveCfg(CFG_FILE,CFG); dirty=false; lastSave=tick()
    toast("BSS","Config guardada",2)
end)
actBtn(sp,"Resetear config",C.dng,function()
    for k,v in pairs(DEFAULTS) do CFG[k]=v end; CFG.FOVRadius=CFG.FOV
    saveCfg(CFG_FILE,CFG); toast("BSS","Config reseteada",2)
end)
actBtn(sp,"Reiniciar script",Color3.fromRGB(80,20,20),function()
    disableSilent(); restoreAllHB(); restoreCamera()
    if _origName then pcall(function() LP.DisplayName=_origName end) end
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
    _alive=false
    pcall(function() _fakePart:Destroy() end)
    fovSG:Destroy(); sg:Destroy()
    for plr in pairs(_espHL) do clearEspPlayer(plr) end
    getgenv().BSS_Aim_Loaded=false
end)

selectTab("AIM")

-- ============================================================================
-- DRAG + MINIMIZE
-- ============================================================================
local function mkDrag(frame,handle)
    local d,s,p
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            d=true; s=i.Position; p=frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local dl=i.Position-s
            frame.Position=UDim2.new(p.X.Scale,p.X.Offset+dl.X,p.Y.Scale,p.Y.Offset+dl.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then d=false end
    end)
end
mkDrag(panel,hdr)

local mini=mk("TextButton",{Size=UDim2.fromOffset(54,54),
    Position=UDim2.new(.5,-27,0,18),
    BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,
    Text="",AutoButtonColor=false,Active=true,Visible=false,ZIndex=200,Parent=sg})
rnd(mini,27); stk(mini,Color3.fromRGB(255,255,255),1.5)
mk("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromScale(.7,.7),BackgroundTransparency=1,Image=ICON,
    ImageColor3=Color3.fromRGB(8,8,10),ScaleType=Enum.ScaleType.Fit,Parent=mini})

local function openPanel()
    if panel.Visible then return end
    mini.Visible=false; panel.Visible=true; panel.Size=UDim2.fromOffset(1,1)
    panel.Position=UDim2.new(.5,-PW/2,.5,-PH/2)
    TweenService:Create(panel,TweenInfo.new(0.22,Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out),{Size=UDim2.fromOffset(PW,PH)}):Play()
end
local function closePanel()
    if not panel.Visible then return end
    local tw=TweenService:Create(panel,TweenInfo.new(0.16,Enum.EasingStyle.Quart,
        Enum.EasingDirection.In),{Size=UDim2.fromOffset(1,1)})
    tw:Play(); tw.Completed:Connect(function()
        panel.Visible=false; panel.Size=UDim2.fromOffset(PW,PH)
        mini.Position=UDim2.new(.5,-27,0,18); mini.Size=UDim2.fromOffset(1,1)
        mini.Visible=true
        TweenService:Create(mini,TweenInfo.new(0.2,Enum.EasingStyle.Back,
            Enum.EasingDirection.Out),{Size=UDim2.fromOffset(54,54)}):Play()
    end)
end

mini.MouseButton1Click:Connect(openPanel)
minBtn.MouseButton1Click:Connect(closePanel)
closeBtn.MouseButton1Click:Connect(function()
    disableSilent(); restoreAllHB(); restoreCamera()
    if _origName then pcall(function() LP.DisplayName=_origName end) end
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
    _alive=false
    pcall(function() _fakePart:Destroy() end)
    fovSG:Destroy(); sg:Destroy()
    for plr in pairs(_espHL) do clearEspPlayer(plr) end
    getgenv().BSS_Aim_Loaded=false
end)
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==CFG.PanelKey then openPanel() end
    if i.KeyCode==CFG.CloseKey  then closePanel() end
end)

-- ============================================================================
-- HUD
-- ============================================================================
local hudSG=mk("ScreenGui",{Name="BSS_HUD",ResetOnSpawn=false,
    IgnoreGuiInset=true,DisplayOrder=9999,Parent=gui()})

local wm=mk("Frame",{Size=UDim2.fromOffset(230,26),Position=UDim2.new(0,18,0,18),
    BackgroundColor3=C.bg,BackgroundTransparency=0.2,BorderSizePixel=0,
    ZIndex=150,Parent=hudSG})
rnd(wm,8); stk(wm,C.acc,1)
mk("TextLabel",{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,8,0,0),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=11,
    TextColor3=C.acc,TextXAlignment=Enum.TextXAlignment.Left,
    Text="BSS-Aim ULTRA v15.0",Parent=wm})

local stats=mk("Frame",{Size=UDim2.fromOffset(175,82),
    Position=UDim2.new(1,-193,0,52),BackgroundColor3=C.bg,
    BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=150,Parent=hudSG})
rnd(stats,8); stk(stats,C.acc2,1)
local statsLbl=mk("TextLabel",{Size=UDim2.new(1,-12,1,-10),
    Position=UDim2.new(0,8,0,5),BackgroundTransparency=1,Font=Enum.Font.Code,
    TextSize=11,TextColor3=C.fg,TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,Text="",Parent=stats})

local fpsCount=0; local fpsTimer=tick(); local curFPS=60
local _stK=-1; local _stI=-1; local _stM=-1; local _stF=-1

-- ============================================================================
-- LOOPS
-- ============================================================================
task.spawn(function() while _alive do pcall(updateESP);     task.wait(CFG.ESPRefresh or 0.05) end end)
task.spawn(function() while _alive do pcall(tryPickup);     task.wait(0.12) end end)
task.spawn(function() while _alive do pcall(trackKills);    task.wait(0.25) end end)
task.spawn(function() while _alive do pcall(applyHideName); task.wait(2)    end end)
task.spawn(function()
    while _alive do
        if CFG.HitboxOn then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and p.Character and not _hitboxOriginal[p.Character] then
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
local _scanT=0
RunService.Heartbeat:Connect(function()
    if not _alive then return end
    manualAimOverride=(tick()-lastMouseMove)<0.15
    if manualAimOverride then curTarget=nil; curPlr=nil; return end
    if not (CFG.Enabled and aimOn) then
        if curTarget then curTarget=nil; curPlr=nil end
        return
    end
    local now=tick()
    if now-_scanT<0.016 then return end
    _scanT=now
    local p,part=findBestTarget()
    if not curTarget or targetGone() then
        curTarget=part; curPlr=p; lastSwitch=now
    elseif part and part~=curTarget then
        local curPx=screenDist(curTarget)
        local newPx=part and screenDist(part) or math.huge
        if newPx+10<curPx and (now-lastSwitch)>0.05 then
            curTarget=part; curPlr=p; lastSwitch=now
        end
    end
end)

-- ============================================================================
-- MAIN LOOP — CAMERA LOCK (Custom + FakePart, sin Scriptable)
-- ============================================================================
pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)

RunService:BindToRenderStep("BSS_Aim_Ultra_Loop",
    Enum.RenderPriority.Camera.Value+1, function(dt)

    if not _alive then return end

    fpsCount+=1
    if tick()-fpsTimer>=1 then curFPS=fpsCount; fpsCount=0; fpsTimer=tick() end

    _inCar=_lHum and _lHum.SeatPart~=nil

    local wantSilent=IS_PC and CFG.SilentAim and CFG.Enabled
                    and aimOn and curTarget~=nil and not manualAimOverride
    if wantSilent and not _silentOn then enableSilent()
    elseif not wantSilent and _silentOn then disableSilent() end

    if CFG.DrawFOV and CFG.Enabled and aimOn then
        fovRing.Size=UDim2.fromOffset(CFG.FOVRadius*2,CFG.FOVRadius*2)
        fovStk.Color=curTarget and C.lock or C.acc
        fovRing.Visible=true
    else fovRing.Visible=false end

    local lockActive=CFG.Enabled and aimOn and curTarget
                     and CFG.CameraLock and not manualAimOverride

    if lockActive then
        local camPos=Camera.CFrame.Position
        local ok,tPos=pcall(function() return curTarget.Position end)

        if ok and tPos then
            -- anclamos el subject para que Roblox no mueva la cámara
            activateLock()
            -- sincronizamos la fakePart a la posición actual de la cámara
            _fakePart.CFrame=CFrame.new(camPos)

            local lookDir=(tPos-camPos)
            if lookDir.Magnitude<0.01 then return end
            lookDir=lookDir.Unit

            local upVec
            if math.abs(lookDir.Y)>0.98 then
                local right=Camera.CFrame.RightVector
                upVec=right:Cross(lookDir)
                if upVec.Magnitude<0.001 then upVec=Vector3.new(1,0,0) end
                upVec=upVec.Unit
            else
                upVec=Vector3.new(0,1,0)
            end

            local targetCF=CFrame.lookAt(camPos,tPos,upVec)
            local alpha=math.clamp(CFG.LockSmooth*(1+dt*30),0.05,1)
            Camera.CFrame=Camera.CFrame:Lerp(targetCF,alpha)
        else
            curTarget=nil; curPlr=nil
            restoreCamera()
        end
    else
        if _fakeLockActive then restoreCamera() end
        if CFG.NoRecoil and isFiring and savedRot and not _inCar then
            Camera.CFrame=CFrame.new(Camera.CFrame.Position)*savedRot
        end
    end

    -- HUD
    if _uiCache.wmVisible~=CFG.WatermarkOn then
        wm.Visible=CFG.WatermarkOn; _uiCache.wmVisible=CFG.WatermarkOn
    end
    if _uiCache.statsVisible~=CFG.StatsOn then
        stats.Visible=CFG.StatsOn; _uiCache.statsVisible=CFG.StatsOn
    end
    if CFG.StatsOn then
        local mins=math.floor((tick()-sessStart)/60)
        if sessKills~=_stK or sessItems~=_stI or mins~=_stM or curFPS~=_stF then
            _stK=sessKills; _stI=sessItems; _stM=mins; _stF=curFPS
            statsLbl.Text=string.format(
                "Kills:    %d\nPickups:  %d\nSesión:   %dm\nFPS:      %d",
                sessKills,sessItems,mins,curFPS)
            stats.Size=UDim2.fromOffset(175,78)
        end
    end
end)

toast("BSS-Aim ULTRA v15.0","FakePart lock — Custom sin Scriptable",5)
print("[BSS-Aim ULTRA v15.0] OK | FakePart subject + CFrame.lookAt + Lerp")
