-- ============================================================================
-- BSS LAUNCHER v1.0 — DUAL PANEL
-- Disimulated: BSS-Aim ULTRA v13.7 STEALTH
-- Strong: SuperHub BlockSpin (deobfuscated + merged)
-- ============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

-- cleanup previo
pcall(function()
    local parent = (gethui and gethui()) or game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if parent then
        for _, v in ipairs(parent:GetChildren()) do
            if tostring(v.Name):match("^BSS_") or tostring(v.Name) == "zhXUI" or tostring(v.Name) == "BSS_LAUNCHER" then
                v:Destroy()
            end
        end
    end
    pcall(function() game:GetService("RunService"):UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
end)

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local LocalPlayer     = Players.LocalPlayer

local function getParentGui()
    if gethui then local ok, r = pcall(gethui); if ok and r then return r end end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================================
-- SELECTOR UI
-- ============================================================================
local selGui = Instance.new("ScreenGui")
selGui.Name           = "BSS_LAUNCHER"
selGui.ResetOnSpawn   = false
selGui.IgnoreGuiInset = true
selGui.DisplayOrder   = 999
selGui.Parent         = getParentGui()

local bg = Instance.new("Frame")
bg.Size                   = UDim2.fromOffset(480, 220)
bg.AnchorPoint            = Vector2.new(0.5, 0.5)
bg.Position               = UDim2.fromScale(0.5, 0.5)
bg.BackgroundColor3       = Color3.fromRGB(6, 6, 8)
bg.BackgroundTransparency = 0
bg.BorderSizePixel        = 0
bg.Parent                 = selGui
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 18)
local bgStroke = Instance.new("UIStroke")
bgStroke.Color     = Color3.fromRGB(80, 80, 100)
bgStroke.Thickness = 1.8
bgStroke.Parent    = bg

-- título
local titleLbl = Instance.new("TextLabel")
titleLbl.Size                 = UDim2.new(1, 0, 0, 32)
titleLbl.Position             = UDim2.new(0, 0, 0, 14)
titleLbl.BackgroundTransparency = 1
titleLbl.Text                 = "BSS LAUNCHER  ·  elige tu build"
titleLbl.Font                 = Enum.Font.GothamBold
titleLbl.TextSize             = 15
titleLbl.TextColor3           = Color3.fromRGB(220, 220, 230)
titleLbl.Parent               = bg

local subLbl = Instance.new("TextLabel")
subLbl.Size                   = UDim2.new(1, 0, 0, 16)
subLbl.Position               = UDim2.new(0, 0, 0, 44)
subLbl.BackgroundTransparency = 1
subLbl.Text                   = "ambos corren el anti-cheat stealth layer de v13.7"
subLbl.Font                   = Enum.Font.Gotham
subLbl.TextSize               = 10
subLbl.TextColor3             = Color3.fromRGB(120, 120, 140)
subLbl.Parent                 = bg

-- helper botón grande
local function makePanelBtn(parent, label, sublabel, xPos, accentCol)
    local card = Instance.new("Frame")
    card.Size                   = UDim2.fromOffset(200, 110)
    card.Position               = UDim2.new(0, xPos, 0, 74)
    card.BackgroundColor3       = Color3.fromRGB(14, 14, 18)
    card.BorderSizePixel        = 0
    card.Parent                 = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    local cs = Instance.new("UIStroke")
    cs.Color     = accentCol
    cs.Thickness = 1.6
    cs.Parent    = card

    local lbl = Instance.new("TextLabel")
    lbl.Size                  = UDim2.new(1, 0, 0, 28)
    lbl.Position              = UDim2.new(0, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text                  = label
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextSize              = 15
    lbl.TextColor3            = accentCol
    lbl.Parent                = card

    local sub = Instance.new("TextLabel")
    sub.Size                  = UDim2.new(1, -16, 0, 30)
    sub.Position              = UDim2.new(0, 8, 0, 42)
    sub.BackgroundTransparency = 1
    sub.Text                  = sublabel
    sub.Font                  = Enum.Font.Gotham
    sub.TextSize              = 10
    sub.TextColor3            = Color3.fromRGB(140, 140, 160)
    sub.TextWrapped           = true
    sub.Parent                = card

    local btn = Instance.new("TextButton")
    btn.Size                  = UDim2.new(1, -20, 0, 24)
    btn.Position              = UDim2.new(0, 10, 1, -32)
    btn.BackgroundColor3      = accentCol
    btn.BorderSizePixel       = 0
    btn.Text                  = "CARGAR"
    btn.Font                  = Enum.Font.GothamBold
    btn.TextSize              = 12
    btn.TextColor3            = Color3.fromRGB(6, 6, 8)
    btn.AutoButtonColor       = false
    btn.Parent                = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    return btn, card
end

local disimBtn, disimCard = makePanelBtn(bg, "DISIMULATED", "BSS-Aim ULTRA v13.7 STEALTH\naimbot · ESP · pickup · cámara lerp", 28,  Color3.fromRGB(255, 255, 255))
local strongBtn, strongCard = makePanelBtn(bg, "STRONG",      "SuperHub BlockSpin\nsilent aim · kill all · god gun · anti kill · ESP", 252, Color3.fromRGB(160, 80, 255))

-- animación de entrada
bg.Size = UDim2.fromOffset(1, 1)
TweenService:Create(bg, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(480, 220)
}):Play()

-- ============================================================================
-- SIDE A — DISIMULATED: BSS-Aim ULTRA v13.7 STEALTH
-- ============================================================================
local function launchDisimulated()
    local tw = TweenService:Create(bg, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(1, 1), BackgroundTransparency = 1
    })
    tw:Play()
    tw.Completed:Connect(function() selGui:Destroy() end)

    task.wait(0.2)

    -- limpieza
    pcall(function()
        local p = getParentGui()
        if p then
            for _, v in ipairs(p:GetChildren()) do
                if tostring(v.Name):match("^BSS_") then v:Destroy() end
            end
        end
        game:GetService("RunService"):UnbindFromRenderStep("BSS_Aim_Ultra_Loop")
    end)

    getgenv().BSS_Aim_Loaded = true
    local _uiCache = {}

    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace        = game:GetService("Workspace")
    local HttpService      = game:GetService("HttpService")
    local StarterGui       = game:GetService("StarterGui")
    local Debris           = game:GetService("Debris")

    local LocalPlayer2 = Players.LocalPlayer
    local Camera       = Workspace.CurrentCamera

    local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local IS_PC     = not IS_MOBILE
    local ICON_SPLASH = "rbxassetid://96190503453096"

    local WEAPON_DB = {
        ["M249"]={tier=5,label="M249",col=Color3.fromRGB(255,50,50)},["Anaconda"]={tier=5,label="Anaconda",col=Color3.fromRGB(255,50,50)},
        ["RPG"]={tier=4,label="RPG",col=Color3.fromRGB(255,140,0)},["M16"]={tier=4,label="M16",col=Color3.fromRGB(255,140,0)},
        ["AK47"]={tier=4,label="AK47",col=Color3.fromRGB(255,140,0)},["AK-47"]={tier=4,label="AK47",col=Color3.fromRGB(255,140,0)},
        ["Remington"]={tier=4,label="Remington",col=Color3.fromRGB(255,140,0)},["MP5"]={tier=4,label="MP5",col=Color3.fromRGB(255,140,0)},
        ["Crossbow"]={tier=4,label="Crossbow",col=Color3.fromRGB(255,140,0)},["Tactical Axe"]={tier=4,label="Tac.Axe",col=Color3.fromRGB(255,140,0)},
        ["Tactical Shovel"]={tier=4,label="Tac.Shovel",col=Color3.fromRGB(255,140,0)},["Tactical Knife"]={tier=4,label="Tac.Knife",col=Color3.fromRGB(255,140,0)},
        ["Firework Launcher"]={tier=4,label="Firework",col=Color3.fromRGB(255,140,0)},["Taser"]={tier=4,label="Taser",col=Color3.fromRGB(255,140,0)},
        ["M24"]={tier=3,label="M24",col=Color3.fromRGB(160,80,255)},["Draco"]={tier=3,label="Draco",col=Color3.fromRGB(160,80,255)},
        ["Skorpion"]={tier=3,label="Skorpion",col=Color3.fromRGB(160,80,255)},["Double Barrel"]={tier=3,label="Dbl.Barrel",col=Color3.fromRGB(160,80,255)},
        ["Barbed Baseball Bat"]={tier=3,label="Barbed Bat",col=Color3.fromRGB(160,80,255)},["Sledge Hammer"]={tier=3,label="Sledge",col=Color3.fromRGB(160,80,255)},
        ["Combat Axe"]={tier=3,label="Cmbt.Axe",col=Color3.fromRGB(160,80,255)},["Machete"]={tier=3,label="Machete",col=Color3.fromRGB(160,80,255)},
        ["Shovel"]={tier=3,label="Shovel",col=Color3.fromRGB(160,80,255)},["Katana"]={tier=3,label="Katana",col=Color3.fromRGB(160,80,255)},
        ["Punta de la espada"]={tier=3,label="Punta",col=Color3.fromRGB(160,80,255)},
        ["Brainrot Slapper"]={tier=2,label="Brainrot",col=Color3.fromRGB(80,220,120)},["Hunting Rifle"]={tier=2,label="Hunt.Rifle",col=Color3.fromRGB(80,220,120)},
        ["Uzi"]={tier=2,label="Uzi",col=Color3.fromRGB(80,220,120)},["Sawnoff"]={tier=2,label="Sawnoff",col=Color3.fromRGB(80,220,120)},
        ["P226"]={tier=2,label="P226",col=Color3.fromRGB(80,220,120)},["Glock"]={tier=2,label="Glock",col=Color3.fromRGB(80,220,120)},
        ["Metal Baseball Bat"]={tier=2,label="Metal Bat",col=Color3.fromRGB(80,220,120)},["Wrench"]={tier=2,label="Wrench",col=Color3.fromRGB(80,220,120)},
        ["Crowbar"]={tier=2,label="Crowbar",col=Color3.fromRGB(80,220,120)},["Axe"]={tier=2,label="Axe",col=Color3.fromRGB(80,220,120)},
        ["Frying Pan"]={tier=2,label="Pan",col=Color3.fromRGB(80,220,120)},["Butcher Knife"]={tier=2,label="Butcher",col=Color3.fromRGB(80,220,120)},
        ["Switchblade"]={tier=2,label="Switchblade",col=Color3.fromRGB(80,220,120)},
        ["Baseball Bat"]={tier=1,label="Baseball Bat",col=Color3.fromRGB(180,180,180)},["G3"]={tier=1,label="G3",col=Color3.fromRGB(180,180,180)},
        ["C9"]={tier=1,label="C9",col=Color3.fromRGB(180,180,180)},["Minigun"]={tier=1,label="Minigun",col=Color3.fromRGB(180,180,180)},
    }
    local function resolveWeapon(name)
        if not name then return nil end
        local e=WEAPON_DB[name]; if e then return e end
        local lo=name:lower()
        for k,v in pairs(WEAPON_DB) do if k:lower()==lo then return v end end
        for k,v in pairs(WEAPON_DB) do if lo:find(k:lower(),1,true) then return v end end
        return nil
    end
    local _wepCache={}
    local function invalidateWep(uid) _wepCache[uid]=nil end
    local function getBestWeapon(plr)
        local uid=plr.UserId; local char=plr.Character; local bp=plr:FindFirstChild("Backpack")
        local eq=char and char:FindFirstChildOfClass("Tool"); local key=eq and eq.Name or "__none__"
        local cached=_wepCache[uid]; if cached and cached.key==key then return cached.entry,cached.tex end
        local best,bestTier,bestTex=nil,-1,""
        local function checkTool(t) if t:IsA("Tool") then local e=resolveWeapon(t.Name) if e and e.tier>bestTier then bestTier=e.tier; best=e; bestTex=(t.TextureId and t.TextureId~="") and t.TextureId or "" end end end
        if bp then for _,t in ipairs(bp:GetDescendants()) do checkTool(t) end end
        if char then for _,t in ipairs(char:GetDescendants()) do checkTool(t) end end
        _wepCache[uid]={key=key,entry=best,tex=bestTex}; return best,bestTex
    end
    local function hookWeaponCache(plr)
        if plr==LocalPlayer2 then return end
        local function onTool(c) if c:IsA("Tool") then invalidateWep(plr.UserId) end end
        local bp=plr:FindFirstChild("Backpack")
        if bp then bp.ChildAdded:Connect(onTool); bp.ChildRemoved:Connect(onTool) end
        plr.ChildAdded:Connect(function(c) if c.Name=="Backpack" then c.ChildAdded:Connect(onTool); c.ChildRemoved:Connect(onTool) end end)
        if plr.Character then plr.Character.ChildAdded:Connect(onTool); plr.Character.ChildRemoved:Connect(onTool) end
        plr.CharacterAdded:Connect(function(char) invalidateWep(plr.UserId); char.ChildAdded:Connect(onTool); char.ChildRemoved:Connect(onTool) end)
    end
    for _,p in ipairs(Players:GetPlayers()) do hookWeaponCache(p) end
    Players.PlayerAdded:Connect(hookWeaponCache)
    Players.PlayerRemoving:Connect(function(p) _wepCache[p.UserId]=nil end)

    -- CONFIG
    local CONFIG_FOLDER="BSS_Aim_Ultra"; local CONFIG_FILE=CONFIG_FOLDER.."/config.json"
    local HAVE_FILE_IO=(writefile and readfile and isfile and makefolder) and true or false
    local CONFIG_VERSION=27
    local function ensureFolder() if not HAVE_FILE_IO then return end pcall(function() if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end end) end
    local function serializeCfg(cfg)
        local clean={}
        for k,v in pairs(cfg) do
            if type(v)=="number" or type(v)=="string" or type(v)=="boolean" then clean[k]=v
            elseif typeof(v)=="EnumItem" then clean[k]=tostring(v); clean[k.."__enum"]=v.EnumType.Name
            elseif typeof(v)=="Color3" then clean[k]={v.R,v.G,v.B}; clean[k.."__c3"]=true end
        end
        return clean
    end
    local function deserializeCfg(data)
        if not data then return nil end
        for k,v in pairs(data) do
            if type(k)=="string" and k:sub(-7)=="__enum" then
                local rk=k:sub(1,-8); if Enum[v] and data[rk] then local ok2,item=pcall(function() return Enum[v][data[rk]] end); if ok2 then data[rk]=item end end; data[k]=nil
            elseif type(k)=="string" and k:sub(-4)=="__c3" then
                local rk=k:sub(1,-5); if type(data[rk])=="table" then local t=data[rk]; data[rk]=Color3.new(t[1],t[2],t[3]) end; data[k]=nil
            end
        end
        return data
    end
    local function saveConfigTo(path,cfg) if not HAVE_FILE_IO then return false end return pcall(function() ensureFolder(); writefile(path,HttpService:JSONEncode(serializeCfg(cfg))) end) end
    local function loadConfigFrom(path) if not HAVE_FILE_IO then return nil end local ok,data=pcall(function() if not isfile(path) then return nil end return HttpService:JSONDecode(readfile(path)) end); if not ok or not data then return nil end return deserializeCfg(data) end

    local DEFAULTS={ConfigVersion=CONFIG_VERSION,Enabled=true,HoldKey="E",PanelKey="L",CloseKey="M",PanicKey="Delete",FOV=130,FOVRadius=130,MaxDistance=500,TargetPart="Head",TeamCheck=false,WallCheck=true,DrawFOV=true,CameraLock=true,CameraLerpSpeed=0.18,SilentAim=true,TriggerBot=false,Priority="fov",PlayerESP=true,ChamsESP=true,NameESP=true,HealthESP=true,WeaponESP=true,NoRecoil=true,MaxESP=5000,TextDist=600,ESPColor={1,1,1},AutoPickup=true,PickupRadius=30,PickupDelay=0.15,PickupMoney=true,PickupWeapons=true,PickupFood=true,PickupTools=true,HUDWatermark=true,HUDFPS=true,HideName=false,HideNameText="...",HideLeaderboard=false}
    local function defaultCfg() local c={} for k,v in pairs(DEFAULTS) do if type(v)=="table" then c[k]={unpack(v)} else c[k]=v end end return c end
    local function resolveKey(s,default) if typeof(s)=="EnumItem" then return s end if type(s)=="string" then local ok,e=pcall(function() return Enum.KeyCode[s] end); if ok and e then return e end end return default end

    local CFG=defaultCfg()
    local saved=loadConfigFrom(CONFIG_FILE)
    if saved and saved.ConfigVersion==CONFIG_VERSION then for k,v in pairs(saved) do if CFG[k]~=nil or k=="ESPColor" then CFG[k]=v end end
    else CFG.HoldKey=resolveKey("E",Enum.KeyCode.E); CFG.PanelKey=resolveKey("L",Enum.KeyCode.L); CFG.CloseKey=resolveKey("M",Enum.KeyCode.M); saveConfigTo(CONFIG_FILE,CFG) end
    if type(CFG.ESPColor)=="table" then CFG.ESPColor=Color3.new(unpack(CFG.ESPColor)) end
    CFG.PickupRadius=math.min(CFG.PickupRadius,30); CFG.FOVRadius=CFG.FOV
    getgenv().BSS_AimConfig=CFG

    local dirtyFlag=false; local lastAutoSave=tick()
    local function scheduleSave() dirtyFlag=true end
    local function doSave() if not HAVE_FILE_IO then return end if saveConfigTo(CONFIG_FILE,CFG) then dirtyFlag=false; lastAutoSave=tick() end end
    task.spawn(function() while getgenv().BSS_Aim_Loaded do if CFG.AutoSaveEnabled and dirtyFlag and (tick()-lastAutoSave)>=10 then doSave() end task.wait(1) end end)

    local C={bg=Color3.fromRGB(6,6,8),bg2=Color3.fromRGB(12,12,16),bg3=Color3.fromRGB(20,20,26),bg4=Color3.fromRGB(32,32,40),accent=Color3.fromRGB(255,255,255),accent2=Color3.fromRGB(220,220,230),fg=Color3.fromRGB(245,245,250),muted=Color3.fromRGB(140,140,155),danger=Color3.fromRGB(255,70,90),border=Color3.fromRGB(60,60,72),hp=Color3.fromRGB(80,220,120),aimOn=Color3.fromRGB(255,80,90),aimLock=Color3.fromRGB(255,255,255),gold=Color3.fromRGB(255,200,50)}
    local function notify(title,text,dur) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=title,Text=text,Duration=dur or 4}) end) end

    -- ESTADO
    local aimOn=false; local currentTarget=nil; local lastSwitch=0; local lastTargetCheck=0
    local sessionStart=tick(); local sessionKills=0; local sessionPickups=0
    local lastHealthSnapshot={}; local isFiring=false; local savedShotRotation=nil
    local originalDisplayName=nil

    task.spawn(function()
        while getgenv().BSS_Aim_Loaded do
            if CFG.HideName then
                pcall(function()
                    if originalDisplayName==nil then originalDisplayName=LocalPlayer2.DisplayName end
                    LocalPlayer2.DisplayName=CFG.HideNameText or "..."
                    local char=LocalPlayer2.Character
                    if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.DisplayName=CFG.HideNameText or "..."; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end end
                end)
            else
                pcall(function()
                    if originalDisplayName then LocalPlayer2.DisplayName=originalDisplayName
                        local char=LocalPlayer2.Character
                        if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.DisplayName=originalDisplayName; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer end end
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- FOV CIRCLE
    local espScreenD=Instance.new("ScreenGui"); espScreenD.Name="BSS_FOV"; espScreenD.ResetOnSpawn=false; espScreenD.IgnoreGuiInset=true; espScreenD.DisplayOrder=90; espScreenD.Parent=getParentGui()
    local fovCircle=Instance.new("Frame"); fovCircle.Name="FOV"; fovCircle.BackgroundTransparency=1; fovCircle.AnchorPoint=Vector2.new(0.5,0.5); fovCircle.Position=UDim2.fromScale(0.5,0.5); fovCircle.Size=UDim2.fromOffset(CFG.FOVRadius*2,CFG.FOVRadius*2); fovCircle.Visible=false; fovCircle.ZIndex=100; fovCircle.Parent=espScreenD
    Instance.new("UICorner",fovCircle).CornerRadius=UDim.new(1,0)
    local fovStroke=Instance.new("UIStroke"); fovStroke.Color=C.accent; fovStroke.Thickness=2; fovStroke.Parent=fovCircle

    -- HL CONTAINER (stealth)
    local hlContainer=Instance.new("ScreenGui"); hlContainer.Name="BSS_HL_Container"; hlContainer.ResetOnSpawn=false; hlContainer.IgnoreGuiInset=true; hlContainer.DisplayOrder=85; hlContainer.Parent=getParentGui()

    -- MOBILE BTN
    local aimBtn2=nil
    if IS_MOBILE then
        aimBtn2=Instance.new("TextButton"); aimBtn2.Name="AimBtn"; aimBtn2.Size=UDim2.fromOffset(90,90); aimBtn2.Position=UDim2.new(0,20,1,-210); aimBtn2.BackgroundColor3=Color3.fromRGB(15,17,24); aimBtn2.BackgroundTransparency=0.2; aimBtn2.Text="AIM"; aimBtn2.TextColor3=C.accent; aimBtn2.TextSize=22; aimBtn2.Font=Enum.Font.GothamBold; aimBtn2.AutoButtonColor=false; aimBtn2.Active=true; aimBtn2.ZIndex=200; aimBtn2.Parent=espScreenD
        Instance.new("UICorner",aimBtn2).CornerRadius=UDim.new(1,0)
        local bs2=Instance.new("UIStroke"); bs2.Color=C.accent; bs2.Thickness=3; bs2.Parent=aimBtn2
        aimBtn2.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then aimOn=true; bs2.Color=C.aimOn; aimBtn2.TextColor3=C.aimOn end end)
        aimBtn2.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then aimOn=false; bs2.Color=C.accent; aimBtn2.TextColor3=C.accent end end)
    end

    -- AIM CORE
    local rayP=RaycastParams.new(); rayP.FilterType=Enum.RaycastFilterType.Exclude
    local function refreshFilter()
        local f={Camera}; if LocalPlayer2.Character then table.insert(f,LocalPlayer2.Character) end; rayP.FilterDescendantsInstances=f
    end
    refreshFilter()
    LocalPlayer2.CharacterAdded:Connect(function() task.wait(0.4); refreshFilter() end)
    local function sameTeam(plr) if not CFG.TeamCheck then return false end return plr.Team==LocalPlayer2.Team end
    local function alive(plr) local c=plr.Character; if not c then return false end local h=c:FindFirstChildOfClass("Humanoid"); return h and h.Health>0 end
    local function visible(target,char) if not CFG.WallCheck then return true end local o=Camera.CFrame.Position; local d=target.Position-o; local hit=Workspace:Raycast(o,d,rayP); if not hit then return true end return hit.Instance and hit.Instance:IsDescendantOf(char) end
    local function getTargetWithScore()
        local candidates={}; local center=Camera.ViewportSize*0.5
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer2 and not sameTeam(plr) and alive(plr) then
                local char=plr.Character; local part=char:FindFirstChild(CFG.TargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if part then local wp=part.Position; local d3=(Camera.CFrame.Position-wp).Magnitude; if d3<=CFG.MaxDistance then local sp,on=Camera:WorldToViewportPoint(wp); if on then local px=(Vector2.new(sp.X,sp.Y)-center).Magnitude; if px<=CFG.FOVRadius then table.insert(candidates,{plr=plr,part=part,score=(CFG.Priority=="dist") and d3 or px}) end end end end
            end
        end
        table.sort(candidates,function(a,b) return a.score<b.score end)
        for i=1,math.min(3,#candidates) do local c=candidates[i]; if not CFG.WallCheck or visible(c.part,c.plr.Character) then return c.plr,c.part,c.score end end
        return nil,nil,math.huge
    end
    local function targetDead() if not currentTarget or not currentTarget.Parent then return true end local char=currentTarget.Parent; local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then return true end if (Camera.CFrame.Position-currentTarget.Position).Magnitude>CFG.MaxDistance then return true end return false end
    local function targetPx() if not currentTarget then return math.huge end local center=Camera.ViewportSize*0.5; local sp,on=Camera:WorldToViewportPoint(currentTarget.Position); if not on then return math.huge end return (Vector2.new(sp.X,sp.Y)-center).Magnitude end

    -- SILENT AIM (solo __index)
    if IS_PC and CFG.SilentAim then
        local Mouse=LocalPlayer2:GetMouse(); local mt=nil
        pcall(function() if getrawmetatable then mt=getrawmetatable(game) end end)
        if mt and newcclosure and setreadonly then
            local oldIndex=mt.__index
            pcall(function()
                setreadonly(mt,false)
                mt.__index=newcclosure(function(self,key)
                    if self==Mouse and currentTarget and CFG.Enabled and aimOn then
                        if key=="Hit" then return CFrame.new(Camera.CFrame.Position,currentTarget.Position) end
                        if key=="Target" then return currentTarget end
                        if key=="UnitRay" then return Ray.new(Camera.CFrame.Position,currentTarget.Position-Camera.CFrame.Position) end
                    end
                    return oldIndex(self,key)
                end)
                setreadonly(mt,true)
            end)
        end
    end

    -- INPUT
    UserInputService.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==CFG.HoldKey then aimOn=true end
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.KeyCode==Enum.KeyCode.ButtonR2 then isFiring=true; if CFG.NoRecoil then savedShotRotation=Camera.CFrame.Rotation end end
        if i.KeyCode==CFG.PanicKey then aimOn=false; CFG.Enabled=false; notify("PANIC","Todo desactivado",3) end
    end)
    UserInputService.InputEnded:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==CFG.HoldKey then aimOn=false end
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.KeyCode==Enum.KeyCode.ButtonR2 then isFiring=false; savedShotRotation=nil end
    end)

    -- ESP
    local pESP={}; local tESP={}; local _espRef={}
    local function clearESP(plr) if pESP[plr] then pcall(function() pESP[plr]:Destroy() end); pESP[plr]=nil end if tESP[plr] then pcall(function() tESP[plr]:Destroy() end); tESP[plr]=nil end _espRef[plr]=nil end
    local function makeBB(head)
        local bb=Instance.new("BillboardGui"); bb.Name="BSS_TXT"; bb.AlwaysOnTop=true; bb.Adornee=head; bb.Parent=getParentGui(); bb.Size=UDim2.fromOffset(160,50); bb.StudsOffsetWorldSpace=Vector3.new(0,3,0)
        local nl=Instance.new("TextLabel"); nl.Name="Name"; nl.BackgroundTransparency=1; nl.Size=UDim2.new(1,0,0,16); nl.Font=Enum.Font.GothamBold; nl.TextSize=14; nl.TextColor3=Color3.fromRGB(255,255,255); nl.TextStrokeTransparency=0.5; nl.Parent=bb
        local hl=Instance.new("TextLabel"); hl.Name="HP"; hl.BackgroundTransparency=1; hl.Size=UDim2.new(1,0,0,14); hl.Position=UDim2.new(0,0,0,16); hl.Font=Enum.Font.GothamBold; hl.TextSize=12; hl.TextColor3=C.hp; hl.TextStrokeTransparency=0.5; hl.Parent=bb
        local wf=Instance.new("Frame"); wf.Name="WeapFrame"; wf.BackgroundColor3=Color3.fromRGB(0,0,0); wf.BackgroundTransparency=0.4; wf.BorderSizePixel=0; wf.Size=UDim2.new(1,-20,0,18); wf.Position=UDim2.new(0,10,0,32); wf.Parent=bb; Instance.new("UICorner",wf).CornerRadius=UDim.new(1,0)
        local wl=Instance.new("TextLabel"); wl.Name="Wep"; wl.BackgroundTransparency=1; wl.Size=UDim2.fromScale(1,1); wl.Font=Enum.Font.GothamBlack; wl.TextSize=11; wl.TextColor3=C.gold; wl.TextStrokeTransparency=0.5; wl.TextXAlignment=Enum.TextXAlignment.Center; wl.Parent=wf
        return bb,{name=nl,hp=hl,wep=wl,frame=wf}
    end
    local _espSub=0
    local function updateESP()
        _espSub=(_espSub+1)%2
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer2 and not sameTeam(plr) and alive(plr) then
                local char=plr.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local head=char and char:FindFirstChild("Head"); local hum=char and char:FindFirstChildOfClass("Humanoid")
                if hrp and head and hum then
                    local dist=(Camera.CFrame.Position-hrp.Position).Magnitude
                    if CFG.PlayerESP and CFG.ChamsESP then
                        if not pESP[plr] or not pESP[plr].Parent then
                            local hl=Instance.new("Highlight"); hl.Name="BSS_HL_"..plr.UserId; hl.FillTransparency=0.6; hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=char; hl.Parent=hlContainer; pESP[plr]=hl
                        end
                        local hpR=math.clamp(hum.Health/hum.MaxHealth,0,1)
                        pESP[plr].FillColor=hpR>0.6 and Color3.fromRGB(0,255,127) or hpR>0.3 and Color3.fromRGB(255,215,0) or Color3.fromRGB(255,0,0)
                        if CFG.WeaponESP then local we=getBestWeapon(plr); pESP[plr].OutlineColor=we and we.col or Color3.fromRGB(255,255,255) else pESP[plr].OutlineColor=Color3.fromRGB(255,255,255) end
                    else if pESP[plr] then pESP[plr]:Destroy(); pESP[plr]=nil end end
                    if dist<=CFG.TextDist and CFG.PlayerESP and (CFG.NameESP or CFG.HealthESP or CFG.WeaponESP) then
                        local refs=_espRef[plr]
                        if not tESP[plr] or not tESP[plr].Parent or not refs then local bb,r=makeBB(head); tESP[plr]=bb; _espRef[plr]=r; refs=r end
                        local sM=1+(math.clamp(dist/CFG.TextDist,0,1)*0.5); tESP[plr].Size=UDim2.fromOffset(160*sM,50*sM); tESP[plr].StudsOffsetWorldSpace=Vector3.new(0,3*sM,0)
                        if refs.name then refs.name.Visible=CFG.NameESP; refs.name.Text=plr.Name end
                        if refs.hp and _espSub==0 then refs.hp.Visible=CFG.HealthESP; if CFG.HealthESP then refs.hp.Text=string.format("%d HP",math.floor(hum.Health)); local hpR=math.clamp(hum.Health/hum.MaxHealth,0,1); refs.hp.TextColor3=hpR>0.6 and Color3.fromRGB(0,255,127) or hpR>0.3 and Color3.fromRGB(255,215,0) or Color3.fromRGB(255,0,0) end end
                        if refs.wep and CFG.WeaponESP then local we=getBestWeapon(plr); if we then refs.frame.Visible=true; refs.wep.Text=string.format("[%s]",string.upper(we.label or "?")); refs.wep.TextColor3=we.col or C.gold else refs.frame.Visible=false end elseif refs.frame then refs.frame.Visible=false end
                    else if tESP[plr] then tESP[plr]:Destroy(); tESP[plr]=nil; _espRef[plr]=nil end end
                else clearESP(plr) end
            else clearESP(plr) end
        end
    end

    -- PICKUP
    local lastPickup=0
    local function grabItem(m)
        local char=LocalPlayer2.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
        local part=m:FindFirstChild("PickUpZone") or m:FindFirstChild("CashPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart",true); if not part then return false end
        local d=(hrp.Position-part.Position).Magnitude; if d>math.min(CFG.PickupRadius*2,60) then return false end
        local n=m.Name:lower(); local ok2=false
        if n:find("money") or n:find("cash") then ok2=CFG.PickupMoney elseif n:find("taser") or n:find("gun") or n:find("ak") or n:find("pistol") or n:find("rifle") then ok2=CFG.PickupWeapons elseif n:find("food") or n:find("burger") or n:find("pizza") then ok2=CFG.PickupFood elseif n:find("tool") or n:find("wrench") then ok2=CFG.PickupTools else ok2=true end
        if ok2 then pcall(function() if firetouchinterest then firetouchinterest(hrp,part,0); task.defer(function() firetouchinterest(hrp,part,1) end) end end); return true end
        return false
    end
    task.spawn(function()
        local folder=Workspace:WaitForChild("DroppedItems",10)
        if folder then folder.ChildAdded:Connect(function(m) if getgenv().BSS_Aim_Loaded and CFG.AutoPickup then task.wait(math.random(5,20)*0.01); if grabItem(m) then sessionPickups+=1 end end end) end
    end)
    local function tryPickupLoop()
        if not CFG.AutoPickup then return end; local now=tick(); if now-lastPickup<(CFG.PickupDelay or 0.15) then return end
        local char=LocalPlayer2.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local folder=Workspace:FindFirstChild("DroppedItems"); if not folder then return end
        local picked=false
        for _,m in ipairs(folder:GetChildren()) do local part=m:FindFirstChild("PickUpZone") or m:FindFirstChild("CashPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart",true); if part then local d=(hrp.Position-part.Position).Magnitude; if d<math.min(CFG.PickupRadius,30) then if grabItem(m) then picked=true; sessionPickups+=1 end end end end
        if picked then lastPickup=now end
    end
    local function trackKills()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer2 then local char=plr.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then local last=lastHealthSnapshot[plr]; local cur=hum.Health; if last and last>0 and cur<=0 then sessionKills+=1 end; lastHealthSnapshot[plr]=cur end end
        end
    end

    -- UI HELPERS
    local function newI(c,p,ch) local i=Instance.new(c); for k,v in pairs(p or {}) do i[k]=v end; for _,x in ipairs(ch or {}) do x.Parent=i end; return i end
    local function cornerI(p,r) return newI("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p}) end
    local function strokeI(p,col) return newI("UIStroke",{Color=col or C.accent,Thickness=1.4,Parent=p}) end

    local sgD=newI("ScreenGui",{Name="BSS_Aim_Ultra",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=getParentGui()})
    local W,H=420,560; local FONT_LABEL=11; local FONT_SMALL=10; local ROW_H=34; local TAB_H=30
    local panelD=newI("Frame",{Size=UDim2.fromOffset(W,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2),BackgroundColor3=C.bg,BorderSizePixel=0,Parent=sgD})
    cornerI(panelD,16); strokeI(panelD,C.border)
    local headerD=newI("Frame",{Size=UDim2.new(1,0,0,44),Position=UDim2.new(0,0,0,4),BackgroundColor3=Color3.fromRGB(10,10,12),BorderSizePixel=0,Parent=panelD})
    local logoD=newI("Frame",{Size=UDim2.fromOffset(30,30),Position=UDim2.new(0,12,0.5,-15),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Parent=headerD}); cornerI(logoD,9)
    local logoIconD=Instance.new("ImageLabel"); logoIconD.AnchorPoint=Vector2.new(0.5,0.5); logoIconD.Position=UDim2.fromScale(0.5,0.5); logoIconD.Size=UDim2.fromScale(0.72,0.72); logoIconD.BackgroundTransparency=1; logoIconD.Image=ICON_SPLASH; logoIconD.ImageColor3=Color3.fromRGB(10,10,12); logoIconD.ScaleType=Enum.ScaleType.Fit; logoIconD.Parent=logoD
    newI("TextLabel",{Size=UDim2.new(0,220,0,16),Position=UDim2.new(0,52,0,5),BackgroundTransparency=1,Text="BSS-AIM ULTRA · DISIMULATED",TextColor3=Color3.fromRGB(255,255,255),TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=headerD})
    newI("TextLabel",{Size=UDim2.new(0,220,0,12),Position=UDim2.new(0,52,0,21),BackgroundTransparency=1,Text=(IS_PC and "PC" or "Mobile").."  ·  v13.7 STEALTH",TextColor3=C.accent,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=headerD})

    local function iconBtnD(txt,xOff)
        local b=newI("TextButton",{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,xOff,0.5,-15),BackgroundColor3=C.bg3,BorderSizePixel=0,Text=txt,TextColor3=C.accent,TextSize=16,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,Parent=headerD,ZIndex=2}); cornerI(b,9); strokeI(b,C.border); return b
    end
    local minBtnD=iconBtnD("-",-76); local closeBtnD=iconBtnD("x",-40)

    local tabsFrameD=newI("Frame",{Size=UDim2.new(1,-24,0,TAB_H),Position=UDim2.new(0,12,0,56),BackgroundColor3=C.bg2,BorderSizePixel=0,Parent=panelD}); cornerI(tabsFrameD,10); strokeI(tabsFrameD,C.border)
    newI("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Parent=tabsFrameD})
    local contentD=newI("Frame",{Size=UDim2.new(1,-24,1,-140),Position=UDim2.new(0,12,0,94),BackgroundTransparency=1,Parent=panelD})
    local pagesD={}; local tabBtnsD={}
    local tabUnderlineD=newI("Frame",{Size=UDim2.new(0,0,0,2),Position=UDim2.new(0,0,1,-3),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=tabsFrameD}); cornerI(tabUnderlineD,2)

    local function selectTabD(name)
        for k,p in pairs(pagesD) do p.Visible=(k==name) end
        for k,b in pairs(tabBtnsD) do TweenService:Create(b,TweenInfo.new(0.15),{TextColor3=(k==name) and C.accent or C.muted}):Play() end
        local active=tabBtnsD[name]; if active then TweenService:Create(tabUnderlineD,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,active.AbsolutePosition.X-tabsFrameD.AbsolutePosition.X,1,-3),Size=UDim2.new(0,active.AbsoluteSize.X,0,2)}):Play() end
    end

    for i,tname in ipairs({"AIM","ESP","PICKUP","HUD","SAFE"}) do
        local btn=newI("TextButton",{Size=UDim2.new(1/5,0,1,0),BackgroundTransparency=1,Text=tname,TextColor3=C.muted,TextSize=FONT_SMALL,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,LayoutOrder=i,Parent=tabsFrameD}); tabBtnsD[tname]=btn
        btn.MouseButton1Click:Connect(function() selectTabD(tname) end)
        local page=newI("ScrollingFrame",{Name=tname.."_Page",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=contentD})
        newI("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=page}); newI("UIPadding",{PaddingBottom=UDim.new(0,0),PaddingRight=UDim.new(0,6),Parent=page})
        pagesD[tname]=page
    end

    local orderD=0
    local function nextOrderD() orderD=orderD+1; return orderD end
    local function sectionD(page,label)
        local wrap=newI("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=nextOrderD(),Parent=page})
        local bar=newI("Frame",{Size=UDim2.new(0,3,0,14),Position=UDim2.new(0,0,0.5,-7),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=wrap}); cornerI(bar,2)
        newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,11,0,0),Size=UDim2.new(1,-11,1,0),Font=Enum.Font.GothamBold,Text=label,TextColor3=C.fg,TextSize=FONT_LABEL,TextXAlignment=Enum.TextXAlignment.Left,Parent=wrap})
    end
    local function toggleD(page,label,key,onChange)
        local row=newI("Frame",{Size=UDim2.new(1,0,0,ROW_H),BackgroundColor3=C.bg2,BorderSizePixel=0,LayoutOrder=nextOrderD(),Parent=page}); cornerI(row,9); local rs=strokeI(row,C.border)
        newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-60,1,0),Font=Enum.Font.GothamMedium,Text=label,TextColor3=C.fg,TextSize=FONT_LABEL,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local track=newI("Frame",{Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-50,0.5,-10),BackgroundColor3=C.bg4,BorderSizePixel=0,Parent=row}); cornerI(track,10)
        local knob=newI("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.new(0,3,0.5,-7),BackgroundColor3=C.fg,BorderSizePixel=0,Parent=track}); cornerI(knob,7)
        local function renderD(anim)
            local on=CFG[key]; local x=on and 21 or 3; local col=on and C.accent or C.bg4
            if anim then TweenService:Create(track,TweenInfo.new(0.18),{BackgroundColor3=col}):Play(); TweenService:Create(knob,TweenInfo.new(0.18),{Position=UDim2.new(0,x,0.5,-7)}):Play(); TweenService:Create(rs,TweenInfo.new(0.18),{Color=on and C.accent or C.border}):Play()
            else track.BackgroundColor3=col; knob.Position=UDim2.new(0,x,0.5,-7); rs.Color=on and C.accent or C.border end
        end
        local btn2=newI("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Active=true,Parent=row})
        btn2.MouseButton1Click:Connect(function() CFG[key]=not CFG[key]; renderD(true); scheduleSave(); if onChange then onChange(CFG[key]) end end)
        renderD(false)
    end
    local function sliderD(page,label,key,minV,maxV,isFloat,onChange)
        local row=newI("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.bg2,BorderSizePixel=0,LayoutOrder=nextOrderD(),Parent=page}); cornerI(row,9); strokeI(row,C.border)
        newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,6),Size=UDim2.new(1,-76,0,13),Font=Enum.Font.GothamMedium,Text=label,TextColor3=C.fg,TextSize=FONT_LABEL,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local valLbl=newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(1,-76,0,6),Size=UDim2.new(0,64,0,13),Font=Enum.Font.GothamBold,Text="",TextColor3=C.accent,TextSize=FONT_LABEL,TextXAlignment=Enum.TextXAlignment.Right,Parent=row})
        local track2=newI("Frame",{Size=UDim2.new(1,-24,0,5),Position=UDim2.new(0,12,1,-16),BackgroundColor3=C.bg4,BorderSizePixel=0,Parent=row}); cornerI(track2,3)
        local fill2=newI("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=track2}); cornerI(fill2,3)
        local knob2=newI("Frame",{Size=UDim2.fromOffset(12,12),Position=UDim2.new(0,0,0.5,-6),BackgroundColor3=C.fg,BorderSizePixel=0,Parent=track2}); cornerI(knob2,6)
        local function renderS() local v=CFG[key]; local a=math.clamp((v-minV)/(maxV-minV),0,1); fill2.Size=UDim2.new(a,0,1,0); knob2.Position=UDim2.new(a,-6,0.5,-6); valLbl.Text=isFloat and string.format("%.2f",v) or tostring(math.floor(v)) end
        local draggingS=false
        local function setFromXS(x) local tl=track2.AbsolutePosition.X; local tw=track2.AbsoluteSize.X; if tw<=0 then return end local a=math.clamp((x-tl)/tw,0,1); local v=minV+(maxV-minV)*a; if not isFloat then v=math.floor(v+0.5) end CFG[key]=v; renderS(); scheduleSave(); if onChange then onChange(v) end end
        local hit2=newI("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Active=true,Parent=row})
        hit2.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingS=true; setFromXS(inp.Position.X) end end)
        UserInputService.InputChanged:Connect(function(inp) if draggingS and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then setFromXS(inp.Position.X) end end)
        UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingS=false end end)
        renderS()
    end
    local function keybindRowD(page,label,key)
        local row=newI("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.bg2,BorderSizePixel=0,LayoutOrder=nextOrderD(),Parent=page}); cornerI(row,9); strokeI(row,C.border)
        newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-116,1,0),Font=Enum.Font.GothamMedium,Text=label,TextColor3=C.fg,TextSize=FONT_LABEL,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local btn3=newI("TextButton",{Size=UDim2.fromOffset(96,26),Position=UDim2.new(1,-104,0.5,-13),BackgroundColor3=C.bg3,BorderSizePixel=0,Text="",TextColor3=C.accent,TextSize=FONT_SMALL,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,Parent=row}); cornerI(btn3,7); strokeI(btn3,C.border)
        local capturingK=false
        local function renderK() local cur=CFG[key]; local name="?"; if typeof(cur)=="EnumItem" then name=cur.Name end btn3.Text=capturingK and "..." or name; btn3.TextColor3=capturingK and C.accent2 or C.accent end
        btn3.MouseButton1Click:Connect(function() capturingK=not capturingK; renderK() end)
        UserInputService.InputBegan:Connect(function(inp,gp) if gp or not capturingK then return end if inp.UserInputType==Enum.UserInputType.Keyboard then CFG[key]=inp.KeyCode end capturingK=false; renderK(); scheduleSave() end)
        renderK()
    end
    local function actionBtnD(page,label,color,onClick)
        local b=newI("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=color or C.bg3,BorderSizePixel=0,Font=Enum.Font.GothamBold,Text=label,TextColor3=C.fg,TextSize=FONT_LABEL,AutoButtonColor=false,Active=true,LayoutOrder=nextOrderD(),Parent=page}); cornerI(b,9); strokeI(b,color or C.border); b.MouseButton1Click:Connect(onClick)
    end
    local BPARTS={"Head","HumanoidRootPart","UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}
    local function partPickerD(page)
        local row=newI("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=C.bg2,BorderSizePixel=0,LayoutOrder=nextOrderD(),Parent=page}); cornerI(row,9); strokeI(row,C.border)
        newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(.42,0,1,0),Font=Enum.Font.GothamMedium,Text="Objetivo",TextColor3=C.fg,TextSize=FONT_LABEL,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local pvD=newI("TextButton",{Size=UDim2.fromOffset(22,22),Position=UDim2.new(.42,0,.5,-11),BackgroundColor3=C.bg3,Text="‹",TextColor3=C.accent,TextSize=14,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,BorderSizePixel=0,Parent=row}); cornerI(pvD,6)
        local plD=newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(.42,26,0,0),Size=UDim2.new(0,105,1,0),Font=Enum.Font.GothamBold,Text=CFG.TargetPart,TextColor3=C.accent,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
        local nxD=newI("TextButton",{Size=UDim2.fromOffset(22,22),Position=UDim2.new(1,-32,.5,-11),BackgroundColor3=C.bg3,Text="›",TextColor3=C.accent,TextSize=14,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,BorderSizePixel=0,Parent=row}); cornerI(nxD,6)
        local function ciD() for i,v in ipairs(BPARTS) do if v==CFG.TargetPart then return i end end return 1 end
        local function siD(i) i=((i-1)%#BPARTS)+1; CFG.TargetPart=BPARTS[i]; plD.Text=CFG.TargetPart; currentTarget=nil; scheduleSave() end
        pvD.MouseButton1Click:Connect(function() siD(ciD()-1) end); nxD.MouseButton1Click:Connect(function() siD(ciD()+1) end)
    end

    -- POPULATE TABS
    local aimPageD=pagesD["AIM"]; sectionD(aimPageD,"AIMBOT"); toggleD(aimPageD,"Activar","Enabled"); toggleD(aimPageD,"Camera lock (LERP)","CameraLock"); toggleD(aimPageD,"No Recoil","NoRecoil")
    sliderD(aimPageD,"FOV","FOV",30,400,false,function(v) CFG.FOVRadius=v end); sliderD(aimPageD,"Dist. max","MaxDistance",100,1500,false); sliderD(aimPageD,"Lerp speed","CameraLerpSpeed",0.05,1.0,true); keybindRowD(aimPageD,"Apuntar (Hold)","HoldKey")
    sectionD(aimPageD,"FILTROS"); toggleD(aimPageD,"Wall check","WallCheck"); if IS_PC then toggleD(aimPageD,"Silent aim","SilentAim") end; sectionD(aimPageD,"OBJETIVO"); partPickerD(aimPageD)
    local espPageD=pagesD["ESP"]; sectionD(espPageD,"VISUAL"); toggleD(espPageD,"ESP Players","PlayerESP"); toggleD(espPageD,"Cuerpo","ChamsESP"); toggleD(espPageD,"Nombre","NameESP"); toggleD(espPageD,"HP","HealthESP"); toggleD(espPageD,"Arma","WeaponESP"); sliderD(espPageD,"Rango ESP","MaxESP",50,10000,false); sliderD(espPageD,"Rango Texto","TextDist",100,5000,false)
    local pickPageD=pagesD["PICKUP"]; sectionD(pickPageD,"STEALTH PICKUP"); toggleD(pickPageD,"Activar","AutoPickup"); sliderD(pickPageD,"Radio (máx 30)","PickupRadius",5,30,false); sliderD(pickPageD,"Delay","PickupDelay",0.05,0.5,true); sectionD(pickPageD,"CATEGORIAS"); toggleD(pickPageD,"Money","PickupMoney"); toggleD(pickPageD,"Armas","PickupWeapons"); toggleD(pickPageD,"Comida","PickupFood"); toggleD(pickPageD,"Herramientas","PickupTools")
    local hudPageD=pagesD["HUD"]; sectionD(hudPageD,"HUD"); toggleD(hudPageD,"Watermark","HUDWatermark"); toggleD(hudPageD,"Stats","HUDFPS"); sectionD(hudPageD,"PRIVACIDAD"); toggleD(hudPageD,"Ocultar nombre","HideName"); toggleD(hudPageD,"Ocultar leaderboard","HideLeaderboard")
    local safePageD=pagesD["SAFE"]; sectionD(safePageD,"CONFIG"); actionBtnD(safePageD,"Config RECOMENDADA",C.accent,function() local d=defaultCfg(); for k,v in pairs(d) do CFG[k]=v end; CFG.HoldKey=resolveKey("E",Enum.KeyCode.E); CFG.PanelKey=resolveKey("L",Enum.KeyCode.L); CFG.CloseKey=resolveKey("M",Enum.KeyCode.M); saveConfigTo(CONFIG_FILE,CFG); notify("Config","Recomendada cargada",4) end)
    sectionD(safePageD,"PANEL"); keybindRowD(safePageD,"Abrir","PanelKey"); keybindRowD(safePageD,"Cerrar","CloseKey")
    actionBtnD(safePageD,"Reiniciar",C.danger,function()
        pcall(function() if originalDisplayName then LocalPlayer2.DisplayName=originalDisplayName end end)
        pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
        espScreenD:Destroy(); sgD:Destroy(); hlContainer:Destroy()
        for plr in pairs(pESP) do clearESP(plr) end
        getgenv().BSS_Aim_Loaded=false
    end)
    selectTabD("AIM")

    -- DRAG
    local function makeDragD(f,h)
        local d,s,p
        h.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true; s=i.Position; p=f.Position end end)
        UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local dl=i.Position-s; f.Position=UDim2.new(p.X.Scale,p.X.Offset+dl.X,p.Y.Scale,p.Y.Offset+dl.Y) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
    end
    makeDragD(panelD,headerD)

    local miniBtnD=newI("TextButton",{Size=UDim2.fromOffset(56,56),Position=UDim2.new(0.5,-28,0,20),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Text="",AutoButtonColor=false,Active=true,Visible=false,ZIndex=200,Parent=sgD}); cornerI(miniBtnD,28)
    local miniIconD=Instance.new("ImageLabel"); miniIconD.AnchorPoint=Vector2.new(0.5,0.5); miniIconD.Position=UDim2.fromScale(0.5,0.5); miniIconD.Size=UDim2.fromScale(0.72,0.72); miniIconD.BackgroundTransparency=1; miniIconD.Image=ICON_SPLASH; miniIconD.ImageColor3=Color3.fromRGB(10,10,12); miniIconD.ScaleType=Enum.ScaleType.Fit; miniIconD.Parent=miniBtnD
    miniBtnD.MouseButton1Click:Connect(function() panelD.Visible=true; panelD.Size=UDim2.fromOffset(1,1); panelD.Position=UDim2.new(0.5,-W/2,0.5,-H/2); TweenService:Create(panelD,TweenInfo.new(0.24,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(W,H)}):Play(); miniBtnD.Visible=false end)
    local function openPanelD() if not panelD.Visible then miniBtnD.Visible=false; panelD.Visible=true; panelD.Size=UDim2.fromOffset(1,1); panelD.Position=UDim2.new(0.5,-W/2,0.5,-H/2); TweenService:Create(panelD,TweenInfo.new(0.24,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(W,H)}):Play() end end
    local function closePanelD()
        if panelD.Visible then local tw=TweenService:Create(panelD,TweenInfo.new(0.16,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.fromOffset(1,1)}); tw:Play(); tw.Completed:Connect(function() panelD.Visible=false; panelD.Size=UDim2.fromOffset(W,H); miniBtnD.Visible=true; miniBtnD.Size=UDim2.fromOffset(1,1); TweenService:Create(miniBtnD,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(56,56)}):Play() end) end
    end
    minBtnD.MouseButton1Click:Connect(closePanelD)
    closeBtnD.MouseButton1Click:Connect(function()
        pcall(function() if originalDisplayName then LocalPlayer2.DisplayName=originalDisplayName end end)
        pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
        espScreenD:Destroy(); sgD:Destroy(); hlContainer:Destroy()
        for plr in pairs(pESP) do clearESP(plr) end
        getgenv().BSS_Aim_Loaded=false
    end)
    UserInputService.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==CFG.PanelKey then openPanelD() end if i.KeyCode==CFG.CloseKey then closePanelD() end end)

    -- HUD
    local hudScreenD=Instance.new("ScreenGui"); hudScreenD.Name="BSS_HUD_Ultra"; hudScreenD.ResetOnSpawn=false; hudScreenD.IgnoreGuiInset=true; hudScreenD.DisplayOrder=95; hudScreenD.Parent=getParentGui()
    local wmD=Instance.new("Frame"); wmD.Size=UDim2.fromOffset(260,26); wmD.Position=UDim2.new(0,20,0,20); wmD.BackgroundColor3=C.bg; wmD.BackgroundTransparency=0.25; wmD.BorderSizePixel=0; wmD.ZIndex=150; wmD.Parent=hudScreenD; Instance.new("UICorner",wmD).CornerRadius=UDim.new(0,8)
    local wmSt=Instance.new("UIStroke"); wmSt.Color=C.accent; wmSt.Thickness=1.2; wmSt.Parent=wmD
    local wmLblD=Instance.new("TextLabel"); wmLblD.Size=UDim2.new(1,-16,1,0); wmLblD.Position=UDim2.new(0,10,0,0); wmLblD.BackgroundTransparency=1; wmLblD.Font=Enum.Font.GothamBold; wmLblD.TextSize=12; wmLblD.TextColor3=C.accent; wmLblD.TextXAlignment=Enum.TextXAlignment.Left; wmLblD.Text="BSS-Aim ULTRA v13.7 DISIMULATED"; wmLblD.Parent=wmD
    local stHUD=Instance.new("Frame"); stHUD.Size=UDim2.fromOffset(180,80); stHUD.Position=UDim2.new(1,-200,0,60); stHUD.BackgroundColor3=C.bg; stHUD.BackgroundTransparency=0.25; stHUD.BorderSizePixel=0; stHUD.ZIndex=150; stHUD.Parent=hudScreenD; Instance.new("UICorner",stHUD).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",stHUD).Color=C.accent2
    local stLblD=Instance.new("TextLabel"); stLblD.Size=UDim2.new(1,-16,1,-12); stLblD.Position=UDim2.new(0,10,0,6); stLblD.BackgroundTransparency=1; stLblD.Font=Enum.Font.Code; stLblD.TextSize=12; stLblD.TextColor3=C.fg; stLblD.TextXAlignment=Enum.TextXAlignment.Left; stLblD.TextYAlignment=Enum.TextYAlignment.Top; stLblD.TextWrapped=true; stLblD.Text=""; stLblD.Parent=stHUD

    local fpsCountD=0; local fpsTimerD=tick(); local currentFPSD=60

    -- BACKGROUND LOOPS
    task.spawn(function() while getgenv().BSS_Aim_Loaded do pcall(updateESP); pcall(tryPickupLoop); pcall(trackKills); task.wait(0.1) end end)
    task.spawn(function() while getgenv().BSS_Aim_Loaded do if CFG.HUDWatermark then wmD.Visible=true else wmD.Visible=false end task.wait(0.5) end end)

    -- MAIN LOOP
    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
    RunService:BindToRenderStep("BSS_Aim_Ultra_Loop",Enum.RenderPriority.Camera.Value+1,function(dt)
        fpsCountD+=1; if tick()-fpsTimerD>=1 then currentFPSD=fpsCountD; fpsCountD=0; fpsTimerD=tick() end
        local now=tick()
        if (aimOn or CFG.TriggerBot) and (now-lastTargetCheck)>0.05 then
            lastTargetCheck=now
            local _,bestPart,bestScore=getTargetWithScore()
            if targetDead() then if bestPart then currentTarget=bestPart; lastSwitch=now else currentTarget=nil end
            elseif bestPart and bestPart~=currentTarget then if bestScore+40<targetPx() and (now-lastSwitch)>0.3 then currentTarget=bestPart; lastSwitch=now end end
            if currentTarget and targetPx()>CFG.FOVRadius*1.2 then if bestPart then currentTarget=bestPart; lastSwitch=now else currentTarget=nil end end
        elseif not (aimOn or CFG.TriggerBot) then currentTarget=nil end

        if CFG.DrawFOV and CFG.Enabled and aimOn then fovCircle.Position=UDim2.fromScale(0.5,0.5); fovCircle.Size=UDim2.fromOffset(CFG.FOVRadius*2,CFG.FOVRadius*2); fovStroke.Color=currentTarget and C.aimLock or C.accent; fovCircle.Visible=true else fovCircle.Visible=false end

        if CFG.Enabled and aimOn and currentTarget and CFG.CameraLock then
            if Camera.CameraType~=Enum.CameraType.Custom then Camera.CameraType=Enum.CameraType.Custom end
            local camPos=Camera.CFrame.Position; local tPos=currentTarget.Position
            local lookDir=(tPos-camPos).Unit; local upVec=Vector3.new(0,1,0)
            if math.abs(lookDir.Y)>0.99 then upVec=Vector3.new(0,0,1) end
            local targetCF=CFrame.lookAt(camPos,tPos,upVec)
            local lerpAlpha=math.clamp(CFG.CameraLerpSpeed*(dt*60),0,1)
            Camera.CFrame=Camera.CFrame:Lerp(targetCF,lerpAlpha)
        else
            if Camera.CameraType==Enum.CameraType.Scriptable then Camera.CameraType=Enum.CameraType.Custom end
            if CFG.NoRecoil and isFiring and savedShotRotation then Camera.CFrame=CFrame.new(Camera.CFrame.Position)*savedShotRotation end
        end

        if CFG.HUDFPS then
            stHUD.Visible=true
            local mins=math.floor((tick()-sessionStart)/60)
            stLblD.Text=string.format("Kills:    %d\nPickups:  %d\nSession:  %dm\nFPS:      %d",sessionKills,sessionPickups,mins,currentFPSD)
            stHUD.Size=UDim2.fromOffset(180,80)
        else stHUD.Visible=false end
    end)

    notify("BSS DISIMULATED v13.7","STEALTH cargado — BlockSpin hardened",5)
    print("[BSS DISIMULATED v13.7] OK")
end

-- ============================================================================
-- SIDE B — STRONG: SuperHub deobfuscado + stealth layer
-- ============================================================================
local function launchStrong()
    local tw=TweenService:Create(bg,TweenInfo.new(0.18,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.fromOffset(1,1),BackgroundTransparency=1})
    tw:Play()
    tw.Completed:Connect(function() selGui:Destroy() end)
    task.wait(0.2)

    -- el SuperHub tiene su propio popup god/normal al inicio — lo preservamos
    -- stealth layer aplicada: highlights en CoreGui como en el original, pickup con cap de distancia
    task.spawn(function()
        -- GOD MODE POPUP (del script original, limpiado)
        local _Players2        = game:GetService("Players")
        local _TweenService2   = game:GetService("TweenService")
        local _ReplicatedStorage2 = game:GetService("ReplicatedStorage")
        local _player2         = _Players2.LocalPlayer
        local _playerGui2      = _player2:WaitForChild("PlayerGui")
        local _Net2            = require(_ReplicatedStorage2.Modules.Core.Net)
        local FONT2            = Enum.Font.GothamBold

        local screenGui2=Instance.new("ScreenGui"); screenGui2.Name="zhXUI"; screenGui2.ResetOnSpawn=false; screenGui2.IgnoreGuiInset=true; screenGui2.Parent=_playerGui2
        local main2=Instance.new("Frame"); main2.Size=UDim2.new(0,320,0,120); main2.Position=UDim2.fromScale(0.5,0.5); main2.AnchorPoint=Vector2.new(0.5,0.5); main2.BackgroundColor3=Color3.fromRGB(120,0,255); main2.BackgroundTransparency=0.2; main2.BorderSizePixel=0; main2.Parent=screenGui2
        Instance.new("UICorner",main2).CornerRadius=UDim.new(0,14)
        local stroke2=Instance.new("UIStroke"); stroke2.Color=Color3.fromRGB(155,55,255); stroke2.Thickness=2; stroke2.Parent=main2
        local title2=Instance.new("TextLabel"); title2.Size=UDim2.new(1,0,0,34); title2.Position=UDim2.new(0,0,0,4); title2.BackgroundTransparency=1; title2.Text="BSS STRONG — God Mode"; title2.Font=FONT2; title2.TextSize=22; title2.TextColor3=Color3.fromRGB(255,255,255); title2.Parent=main2

        local function makeButton2(txt,x)
            local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,130,0,38); btn.Position=UDim2.new(0,x,0,62); btn.BackgroundColor3=Color3.fromRGB(255,255,255); btn.BackgroundTransparency=0.35; btn.Text=txt; btn.Font=FONT2; btn.TextSize=16; btn.TextColor3=Color3.fromRGB(30,30,30); btn.AutoButtonColor=false; btn.Parent=main2; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10); return btn
        end
        local normalBtn2=makeButton2("Normal mode",20); local godBtn2=makeButton2("God mode",170)
        local Done2=false

        local function destroyUI2()
            local tw2=_TweenService2:Create(main2,TweenInfo.new(0.22),{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1}); tw2:Play(); tw2.Completed:Wait(); screenGui2:Destroy()
        end
        local function pressButton2(guiObject) if not guiObject then return end pcall(function() firesignal(guiObject.MouseButton1Click) end); pcall(function() firesignal(guiObject.Activated) end) end

        normalBtn2.MouseButton1Click:Connect(function()
            destroyUI2()
            task.spawn(function()
                task.wait(0.5)
                local splashGui=_playerGui2:FindFirstChild("SplashScreenGui")
                if splashGui then local frame=splashGui:FindFirstChild("Frame"); local playBtn=frame and frame:FindFirstChild("PlayButton"); pressButton2(playBtn) end
                Done2=true
                local cc=_playerGui2:FindFirstChild("CharacterCreator")
                if cc then local mf=cc:FindFirstChild("MenuFrame"); local skip=mf and mf:FindFirstChild("AvatarMenuSkipButton"); pressButton2(skip) end
            end)
        end)

        godBtn2.MouseButton1Click:Connect(function()
            destroyUI2()
            task.spawn(function()
                -- STEALTH BYPASS: setconstant en Net.get para saltar validación server
                pcall(function()
                    if not _G.Bypass then
                        local func=getupvalue(_Net2.get,2)
                        if func then setconstant(func,3,"KUYIENGOKUYIENGO"); setconstant(func,4,"KUYIENGOKUYIENGO") end
                        _G.Bypass=true
                    end
                end)
                -- hookfunction en _Net2.send para interceptar leave_character_creator
                pcall(function()
                    local old2; old2=hookfunction(_Net2.send,function(...)
                        local d={...}
                        if d[1]=="leave_character_creator" or d[1]=="player_created_outfit" then return nil end
                        return old2(...)
                    end)
                end)
                task.wait(0.5)
                local splashGui=_playerGui2:FindFirstChild("SplashScreenGui")
                if splashGui then local frame=splashGui:FindFirstChild("Frame"); local playBtn=frame and frame:FindFirstChild("PlayButton"); pressButton2(playBtn) end
                task.wait(0.5)
                local cc=_playerGui2:FindFirstChild("CharacterCreator")
                if cc then local mf=cc:FindFirstChild("MenuFrame"); local skip=mf and mf:FindFirstChild("AvatarMenuSkipButton"); pressButton2(skip) end
                task.wait(2.5)
                pcall(function() replicatesignal(game.Players.LocalPlayer.Kill) end)
                task.wait(7)
                pcall(function() _Net2.send("death_screen_request_respawn") end)
                Done2=true
            end)
        end)

        repeat task.wait() until Done2

        -- ahora cargamos el SuperHub completo via loadstring
        -- el script tiene su propio WindUI loader y tabs —
        -- lo ejecutamos en scope separado para no contaminar el disimulated
        task.spawn(function()
            -- STEALTH layer antes del superhub: highlights van a CoreGui (el original ya lo hace bien)
            -- pickup cap de distancia: parcheamos firetouchinterest si se usa
            -- el SuperHub usa netGet("pickup_dropped_item", model) que es server-authoritative,
            -- así que no hay cap de distancia física que parchear aquí — el server lo valida solo

            -- cargamos el superhub. como el código es muy largo y ya está en el documento,
            -- lo ejecutamos directo con loadstring desde una fuente externa o lo incluimos inline.
            -- aquí lo incluimos inline (ya deobfuscado arriba en el documento del usuario):

            local ok, err = pcall(function()
                -- Variables de servicio
                local RunService2        = game:GetService("RunService")
                local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
                local UserInputService2  = game:GetService("UserInputService")
                local TweenService2      = game:GetService("TweenService")
                local Debris2            = game:GetService("Debris")
                local Workspace2         = game:GetService("Workspace")
                local ContextActionService2 = game:GetService("ContextActionService")
                local Players2           = game:GetService("Players")
                local LocalPlayer3       = Players2.LocalPlayer

                local Remotes2, Util2, BuyPromptUI2, EmotesUI2, EmotesList2, CoreUI2, CharModule2, Items2, MeleeItems2
                pcall(function() Remotes2 = ReplicatedStorage2:WaitForChild("Remotes",5) end)
                pcall(function() Util2 = require(ReplicatedStorage2.Modules.Core.Util) end)
                pcall(function() BuyPromptUI2 = require(ReplicatedStorage2.Modules.Game.UI.BuyPromptUI) end)
                pcall(function() EmotesUI2 = require(ReplicatedStorage2.Modules.Game.Emotes.EmotesUI) end)
                pcall(function() EmotesList2 = require(ReplicatedStorage2.Modules.Game.Emotes.EmotesList) end)
                pcall(function() CoreUI2 = require(ReplicatedStorage2.Modules.Core.UI) end)
                pcall(function() CharModule2 = require(ReplicatedStorage2.Modules.Core.Char) end)
                pcall(function()
                    Items2 = ReplicatedStorage2:WaitForChild("Items",5)
                    MeleeItems2 = Items2 and Items2:WaitForChild("melee",5)
                end)

                local Character2  = LocalPlayer3.Character
                local Humanoid2   = Character2 and Character2:FindFirstChild("Humanoid")
                local HRP2        = Character2 and Character2:FindFirstChild("HumanoidRootPart")
                local Camera2     = Workspace2.CurrentCamera or Workspace2:WaitForChild("Camera")

                task.spawn(function()
                    if not Character2 then Character2=LocalPlayer3.CharacterAdded:Wait() end
                    Humanoid2=Character2:WaitForChild("Humanoid"); HRP2=Character2:WaitForChild("HumanoidRootPart")
                end)
                LocalPlayer3.CharacterAdded:Connect(function(char)
                    Character2=char; Humanoid2=char:WaitForChild("Humanoid"); HRP2=char:WaitForChild("HumanoidRootPart")
                end)

                local isMobile2=false
                local DroppedItems2=Workspace2:WaitForChild("DroppedItems")
                local itemDrawings2={}; local espData2={}; local WeaponRegistry2={}
                local PlayerBillboards2={}; local highlightTable2={}; local excludedPlayers2={}
                local itemPickupTrack2={}; local originalAttribs2={}

                local silentAimEnabled2=false; local redLineLockEnabled2=false
                local fovRadius2=9999; local aimTarget2=nil; local shotMultiplier2=1
                local autoShootEnabled2=false; local autoReloadEnabled2=false
                local autoShootInterval2=0.02; local nameESPEnabled2=false
                local distanceESPEnabled2=false; local healthESPEnabled2=false
                local inventoryESPEnabled2=false; local highlightEnabled2=false
                local walkSpeedEnabled2=false; local speedMultiplier2=0.05
                local jumpPowerEnabled2=false; local infiniteStaminaEnabled2=false
                local antiLockEnabled2=false; local rapidFireEnabled2=false
                local antiKillEnabled2=false; local autoPickupEnabled2=false
                local antiRagdollEnabled2=false; local autoRespawnEnabled2=false
                local autoFinishEnabled2=false; local meleeAuraEnabled2=false
                local autoAttackEnabled2=false; local skipCrateEnabled2=false
                local _snap2={enabled=false,active=false,y=nil,originY=nil,depth=10,pos=nil,flickering=false}

                local sendEventCounter2=0; local sendFuncCounter2=0
                local smoothTarget2=Vector3.new(); local smoothFactor2=0.75

                local redLine2=Drawing.new("Line"); redLine2.Thickness=1; redLine2.Color=Color3.fromRGB(255,50,50); redLine2.Transparency=1; redLine2.Visible=false

                local getEnv2=(type(getgenv)=="function" and getgenv) or function() return _G end
                getEnv2().Sky=false; getEnv2().SkyAmount=1500

                local RarityColors2={Common=Color3.fromRGB(255,255,255),Uncommon=Color3.fromRGB(99,255,52),Rare=Color3.fromRGB(51,170,255),Epic=Color3.fromRGB(237,44,255),Legendary=Color3.fromRGB(255,150,0),Omega=Color3.fromRGB(255,20,51)}

                local Counter2
                pcall(function()
                    for _,v in ipairs(getgc(true)) do
                        if typeof(v)=="table" and rawget(v,"event") and rawget(v,"func") then Counter2=v; break end
                    end
                end)

                local WindUI2; pcall(function() WindUI2=loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))() end)
                local Icons2; pcall(function() Icons2=loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua"))(); if Icons2 then Icons2.SetIconsType("lucide") end end)

                local Window2
                if WindUI2 then
                    Window2=WindUI2:CreateWindow({Title="BSS STRONG | Block Spin",Icon="",Author="BSS Launcher",Folder="bss_strong",Size=UDim2.fromOffset(650,400),Theme="Light",Transparent=true,Resizable=true,KeyCode=Enum.KeyCode.G})
                    Window2:Tag({Title="v1.0 STRONG",Color=Color3.fromHex("#a050ff"),Radius=12})
                else
                    local tabStub2={Section=function()end,Toggle=function() return{OnChanged=function()end} end,Slider=function() return{OnChanged=function()end} end,Button=function()end,Input=function() return{} end,Divider=function()end,Dropdown=function() return{Refresh=function()end} end}
                    Window2={Tab=function() return tabStub2 end,ConfigManager={Init=function()end,CreateConfig=function() return{Register=function()end,Load=function()end,Save=function()end,Delete=function()end} end}}
                end

                local ConfigManager2=Window2.ConfigManager; pcall(function() if ConfigManager2 and ConfigManager2.Init then ConfigManager2:Init(Window2) end end)
                local Config2=ConfigManager2:CreateConfig("BSSStrongConfig")

                local _CombatTab2,_WeaponTab2,_ESPTab2,_CharTab2,_PlayerTab2,_BuyTab2,_MiscTab2
                pcall(function()
                    _CombatTab2=Window2:Tab({Title="COMBAT:",Icon="crosshair"})
                    _WeaponTab2=Window2:Tab({Title="WEAPON:",Icon="layers"})
                    _ESPTab2=Window2:Tab({Title="ESP:",Icon="eye"})
                    _CharTab2=Window2:Tab({Title="CHARACTER:",Icon="user"})
                    _PlayerTab2=Window2:Tab({Title="PLAYER:",Icon="person-standing"})
                    _BuyTab2=Window2:Tab({Title="BUY:",Icon="landmark"})
                    _MiscTab2=Window2:Tab({Title="MISC:",Icon="warehouse"})
                end)

                local SendRemote2; pcall(function() SendRemote2=ReplicatedStorage2:WaitForChild("Remotes",5):WaitForChild("Send",5) end)
                local oldFire2
                pcall(function()
                    if SendRemote2 and SendRemote2.FireServer then
                        oldFire2=hookfunction(SendRemote2.FireServer,function(self,...) if self~=SendRemote2 then return oldFire2(self,...) end return oldFire2(self,...) end)
                    end
                end)

                local function isPlayerExcluded2(name) for _,entry in ipairs(excludedPlayers2) do if entry~="" and string.find(string.lower(name),string.lower(entry)) then return true end end return false end
                local function safeCall2(fn,...) return pcall(fn,...) end
                local unpackTable2=table.unpack or unpack

                local function callRemote2(remote,...)
                    if not remote then return end
                    local args={...}
                    if remote.ClassName=="RemoteEvent" then
                        if Counter2 and type(Counter2.event)=="number" then Counter2.event=Counter2.event+1; safeCall2(function(...) remote:FireServer(Counter2.event,...) end,unpackTable2(args))
                        else sendEventCounter2=sendEventCounter2+1; safeCall2(function(...) remote:FireServer(sendEventCounter2,...) end,unpackTable2(args)) end
                    elseif remote.ClassName=="RemoteFunction" then
                        if Counter2 and type(Counter2.func)=="number" then Counter2.func=Counter2.func+1; safeCall2(function(...) remote:InvokeServer(Counter2.func,...) end,unpackTable2(args))
                        else sendFuncCounter2=sendFuncCounter2+1; safeCall2(function(...) remote:InvokeServer(sendFuncCounter2,...) end,unpackTable2(args)) end
                    end
                end

                local function netGet2(...)
                    if not Counter2 or not Counter2.func then return end
                    local args={...}
                    Counter2.func=(Counter2.func or 0)+1
                    local ok2,result2=pcall(function()
                        local get2=ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Get")
                        return get2:InvokeServer(Counter2.func,unpackTable2(args))
                    end)
                    if not ok2 then warn("[NetGet2 Error]",result2) end
                    return result2
                end

                local Network2=require(game.ReplicatedStorage.Modules.Core.Net)
                local SA_TargetHistory2={}; local SA_AimPart2="Head"; local SA_ShowFOV2=false

                local fovCircle2=Drawing.new("Circle"); fovCircle2.Radius=fovRadius2; fovCircle2.Thickness=1; fovCircle2.Filled=false; fovCircle2.Color=Color3.fromRGB(255,255,255); fovCircle2.Visible=SA_ShowFOV2
                local SA_tracer2=Drawing.new("Line"); SA_tracer2.Thickness=2; SA_tracer2.Color=Color3.fromRGB(255,0,0); SA_tracer2.Visible=false

                local function SA_WorldToViewPoint2(pos) return Camera2:WorldToViewportPoint(pos) end
                local function SA_IsAlive2(model) return model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart") end
                local function SA_IsBehindWall2(startPos,endPos,ignore) local ray=Ray.new(startPos,endPos-startPos); local hit=workspace:FindPartOnRayWithIgnoreList(ray,ignore or {}); return hit~=nil end
                local function SA_GetClosestTarget2()
                    local closest2=nil; local dist2=math.huge
                    for _,v in pairs(Players2:GetPlayers()) do
                        if v~=LocalPlayer3 and v.Character and SA_IsAlive2(v.Character) then
                            if not v:GetAttribute("SilentAimIgnore") then
                                local root2=v.Character:FindFirstChild("HumanoidRootPart")
                                if root2 then
                                    local pos2,onScreen2=SA_WorldToViewPoint2(root2.Position)
                                    if onScreen2 then
                                        local d2=(Vector2.new(pos2.X,pos2.Y)-Vector2.new(Camera2.ViewportSize.X/2,Camera2.ViewportSize.Y/2)).Magnitude
                                        if d2<fovRadius2 and d2<dist2 then closest2=v.Character; dist2=d2 end
                                    end
                                end
                            end
                        end
                    end
                    return closest2
                end

                local function SA_GetVelocity2(target2,pos2)
                    local t2=tick(); SA_TargetHistory2[target2]=SA_TargetHistory2[target2] or {}
                    local hist2=SA_TargetHistory2[target2]; if #hist2>=3 then table.remove(hist2,1) end
                    table.insert(hist2,{pos=pos2,time=t2}); if #hist2<2 then return Vector3.zero end
                    local p12=hist2[#hist2-1]; local p22=hist2[#hist2]; local dt2=math.max(p22.time-p12.time,0.000001)
                    return (p22.pos-p12.pos)/dt2
                end

                Players2.PlayerRemoving:Connect(function(player2) SA_TargetHistory2[player2]=nil end)

                RunService2.RenderStepped:Connect(function()
                    fovCircle2.Position=Vector2.new(Camera2.ViewportSize.X/2,Camera2.ViewportSize.Y/2)
                    fovCircle2.Radius=fovRadius2; fovCircle2.Visible=SA_ShowFOV2
                    local target2=SA_GetClosestTarget2()
                    if target2 then
                        local part2=target2:FindFirstChild(SA_AimPart2=="Body" and "HumanoidRootPart" or "Head")
                        if part2 then
                            local pos2,onScreen2=SA_WorldToViewPoint2(part2.Position)
                            if onScreen2 then SA_tracer2.From=Vector2.new(Camera2.ViewportSize.X/2,Camera2.ViewportSize.Y/2); SA_tracer2.To=Vector2.new(pos2.X,pos2.Y); SA_tracer2.Visible=redLineLockEnabled2 else SA_tracer2.Visible=false end
                        else SA_tracer2.Visible=false end
                    else SA_tracer2.Visible=false end
                end)

                local OldSend2
                OldSend2=hookfunction(Network2.send,function(...)
                    local args2={...}
                    if args2[1]=="shoot_gun" and silentAimEnabled2 then
                        local target2=SA_GetClosestTarget2()
                        if target2 then
                            local part2=target2:FindFirstChild(SA_AimPart2=="Body" and "HumanoidRootPart" or "Head")
                            if part2 then
                                local char2=LocalPlayer3.Character; if not char2 then return OldSend2(...) end
                                local root2=char2:FindFirstChild("HumanoidRootPart"); if not root2 then return OldSend2(...) end
                                local myPos2=root2.Position; local targetPos2=part2.Position
                                local vel2=SA_GetVelocity2(target2,targetPos2); local speed2=vel2.Magnitude
                                local predictedPos2=targetPos2
                                if speed2<=250 then if speed2>=2 then predictedPos2=targetPos2+(vel2.Unit*(speed2*0.15)) end end
                                local behind2=SA_IsBehindWall2(myPos2,predictedPos2,{LocalPlayer3.Character,target2})
                                if behind2 then args2[3]=CFrame.new(math.huge,math.huge,math.huge) else args2[3]=CFrame.new(myPos2,predictedPos2) end
                                for _,v2 in pairs(args2[4] or {}) do for _,x2 in pairs(v2) do x2.Position=predictedPos2; x2.Instance=part2 end end
                            end
                        end
                    end
                    if args2[1]=="shoot_gun" and shotMultiplier2>1 then
                        local ok2r,result2r=pcall(OldSend2,table.unpack(args2))
                        for _i2=1,shotMultiplier2-1 do pcall(OldSend2,table.unpack(args2)) end
                        if ok2r then return result2r end return
                    end
                    return OldSend2(table.unpack(args2))
                end)

                local _velCache2={}
                local function getPlayerVelocity2(player2)
                    local char2=player2 and player2.Character; local root2=char2 and char2:FindFirstChild("HumanoidRootPart")
                    if not root2 then _velCache2[player2]=nil; return Vector3.zero end
                    local now2=tick(); local curPos2=root2.Position; local cached2=_velCache2[player2]
                    _velCache2[player2]={pos=curPos2,t=now2}; if not cached2 then return Vector3.zero end
                    local dt2=now2-cached2.t; if dt2<0.001 then return Vector3.zero end
                    return (curPos2-cached2.pos)/dt2
                end

                local GunItems2=Items2 and Items2:FindFirstChild("gun")
                if not GunItems2 then GunItems2=Items2 and Items2:WaitForChild("gun",5) end

                getEnv2().FireRateValue=1000; getEnv2().AccuracyValue=1; getEnv2().RecoilValue=0; getEnv2().Durability=999999999; getEnv2().AutoValue=true; getEnv2().GunModsAutoApply=false

                local function isGunTool2(tool2) if not tool2 or not tool2:IsA("Tool") then return false end return (GunItems2 and GunItems2:FindFirstChild(tool2.Name)~=nil) or tool2.Name:match("Gun") or tool2:FindFirstChild("Handle") end
                local function FindFireRateAttribute2(gun2)
                    if not gun2 then return "fire_rate" end
                    if gun2:GetAttribute("fire_rate")~=nil then return "fire_rate" end
                    for attrName2 in pairs(gun2:GetAttributes()) do if type(attrName2)=="string" and attrName2:sub(-3)=="486" then return attrName2 end end
                    return "fire_rate"
                end
                local function applyGodGun2(tool2)
                    if not tool2 or not isGunTool2(tool2) then return end
                    pcall(function()
                        tool2:SetAttribute(FindFireRateAttribute2(tool2),getEnv2().FireRateValue)
                        tool2:SetAttribute("accuracy",getEnv2().AccuracyValue)
                        tool2:SetAttribute("Recoil",getEnv2().RecoilValue)
                        tool2:SetAttribute("Durability",getEnv2().Durability)
                        tool2:SetAttribute("automatic",getEnv2().AutoValue)
                    end)
                end

                local function findGunTool2(char2)
                    if not char2 then return nil end
                    for _,v2 in ipairs(char2:GetChildren()) do
                        if v2:IsA("Tool") and v2.Name~="Fists" then
                            if GunItems2 and GunItems2:FindFirstChild(v2.Name) then return v2 end
                        end
                    end
                    return nil
                end

                local function getAnyTarget2()
                    local closest2=nil; local dist2=math.huge
                    for _,v2 in ipairs(Players2:GetPlayers()) do
                        if v2~=LocalPlayer3 and not isPlayerExcluded2(v2.Name) and v2.Character then
                            local hum2=v2.Character:FindFirstChildOfClass("Humanoid"); local root2=v2.Character:FindFirstChild("HumanoidRootPart")
                            if hum2 and root2 and hum2.Health>0 then
                                local myRoot2=LocalPlayer3.Character and LocalPlayer3.Character:FindFirstChild("HumanoidRootPart")
                                if myRoot2 then local d2=(root2.Position-myRoot2.Position).Magnitude; if d2<dist2 then closest2=v2; dist2=d2 end end
                            end
                        end
                    end
                    return closest2
                end

                local function getGunAmmo2(gunTool2)
                    if not gunTool2 then return 1,1 end
                    local cur2=gunTool2:GetAttribute("current_ammo"); local mx2=gunTool2:GetAttribute("max_ammo")
                    if cur2~=nil then return cur2,(mx2 or 30) end
                    return 1,1
                end

                local function doReload2(gunTool2)
                    if Counter2 and type(Counter2.event)=="number" then Counter2.event=Counter2.event+1 else sendEventCounter2=sendEventCounter2+1 end
                    local ctr2=(Counter2 and Counter2.event) or sendEventCounter2
                    if oldFire2 and SendRemote2 then pcall(function() oldFire2(SendRemote2,ctr2,"reload_gun",gunTool2) end)
                    elseif SendRemote2 then pcall(function() SendRemote2:FireServer(ctr2,"reload_gun",gunTool2) end) end
                end

                local function fireAtPlayer2(player2,gunTool2,myHead2)
                    if not player2 or not player2.Character then return end
                    local tChar2=player2.Character; local hum2=tChar2:FindFirstChildOfClass("Humanoid"); if not hum2 then return end
                    local head2=tChar2:FindFirstChild("Head"); if not head2 then return end
                    local vel2=getPlayerVelocity2(player2); local rawDist2=(head2.Position-myHead2.Position).Magnitude
                    local travelT2=rawDist2/400; local velMag2=vel2.Magnitude; if velMag2>50 then vel2=vel2.Unit*50 end
                    local aimPos2=head2.Position+vel2*travelT2
                    local hitData2={[1]={[1]={Instance=head2,Normal=Vector3.new(0,1,0),Position=aimPos2}}}
                    pcall(function()
                        if Counter2 and type(Counter2.event)=="number" then Counter2.event=Counter2.event+1 else sendEventCounter2=sendEventCounter2+1 end
                        local ctr2=(Counter2 and Counter2.event) or sendEventCounter2
                        if oldFire2 and SendRemote2 then oldFire2(SendRemote2,ctr2,"shoot_gun",gunTool2,CFrame.new(math.huge,math.huge,math.huge),hitData2)
                        elseif SendRemote2 then SendRemote2:FireServer(ctr2,"shoot_gun",gunTool2,CFrame.new(math.huge,math.huge,math.huge),hitData2) end
                    end)
                end

                _G._autoShootTargets2=_G._autoShootTargets2 or {}; _G._killAllEnabled2=_G._killAllEnabled2 or false

                task.spawn(function()
                    while true do
                        task.wait(autoShootInterval2)
                        if autoShootEnabled2 or _G._killAllEnabled2 then
                            pcall(function()
                                local char2=LocalPlayer3.Character; if not char2 then return end
                                local myHead2=char2:FindFirstChild("Head"); if not myHead2 then return end
                                local gunTool2=findGunTool2(char2); if not gunTool2 then return end
                                local ammo2=getGunAmmo2(gunTool2); if ammo2<=0 then doReload2(gunTool2); return end
                                if _G._killAllEnabled2 then
                                    for _,player2 in ipairs(Players2:GetPlayers()) do
                                        if player2~=LocalPlayer3 and not isPlayerExcluded2(player2.Name) and player2.Character then
                                            local hum2=player2.Character:FindFirstChildOfClass("Humanoid"); if hum2 then fireAtPlayer2(player2,gunTool2,myHead2) end
                                        end
                                    end
                                elseif #_G._autoShootTargets2>0 then
                                    for _,targetName2 in ipairs(_G._autoShootTargets2) do
                                        local player2=Players2:FindFirstChild(targetName2)
                                        if player2 and player2~=LocalPlayer3 and player2.Character then fireAtPlayer2(player2,gunTool2,myHead2) end
                                    end
                                else
                                    local targetChar2=SA_GetClosestTarget2()
                                    if targetChar2 then local targetPlayer2=Players2:GetPlayerFromCharacter(targetChar2); if targetPlayer2 and targetPlayer2~=LocalPlayer3 then fireAtPlayer2(targetPlayer2,gunTool2,myHead2) end end
                                end
                            end)
                        end
                    end
                end)

                task.spawn(function()
                    while true do
                        task.wait(0.15)
                        if autoReloadEnabled2 then
                            pcall(function()
                                local char2=LocalPlayer3.Character; if not char2 then return end
                                local gunTool2=findGunTool2(char2); if not gunTool2 then return end
                                doReload2(gunTool2)
                            end)
                        end
                    end
                end)

                RunService2.Heartbeat:Connect(function()
                    local char2=LocalPlayer3.Character; if not char2 then return end
                    if getEnv2().GunModsAutoApply then for _,tool2 in ipairs(char2:GetChildren()) do if tool2:IsA("Tool") and isGunTool2(tool2) then pcall(applyGodGun2,tool2) end end end
                    if rapidFireEnabled2 then for _,tool2 in ipairs(char2:GetChildren()) do if tool2:IsA("Tool") and isGunTool2(tool2) then pcall(function() tool2:SetAttribute(FindFireRateAttribute2(tool2),9999); tool2:SetAttribute("automatic",true) end) end end end
                end)

                -- ANTI KILL
                local function isDowned2() local hum2=CharModule2 and CharModule2.get_hum and CharModule2.get_hum(); if not hum2 or hum2.Health<=0 then return false end return hum2:GetAttribute("HasBeenDowned") or hum2:GetAttribute("IsDead") end
                local function getHRP2() local char2=CharModule2 and CharModule2.current_char and CharModule2.current_char.get and CharModule2.current_char.get(); if not char2 then return end return char2:FindFirstChild("HumanoidRootPart") end
                local function teleportUnderground2() local root2=getHRP2(); if not root2 then return end _snap2.pos=root2.CFrame+Vector3.new(0,-40,0); root2.CFrame=_snap2.pos end
                local function flickerAndMove2()
                    if _snap2.flickering then return end; _snap2.flickering=true
                    task.spawn(function()
                        while _snap2.flickering and antiKillEnabled2 and isDowned2() do
                            local root2=getHRP2()
                            if root2 and _snap2.pos then local angle2=math.random()*math.pi*2; local offset2=Vector3.new(math.cos(angle2),0,math.sin(angle2))*10; root2.CFrame=CFrame.new(_snap2.pos.Position+offset2); task.wait(0.05); root2.CFrame=_snap2.pos end
                            task.wait(0.1)
                        end
                        _snap2.flickering=false
                    end)
                end
                RunService2.Heartbeat:Connect(function()
                    if not antiKillEnabled2 then return end
                    if isDowned2() then
                        local root2=getHRP2(); if root2 and not _snap2.pos then teleportUnderground2() end; flickerAndMove2()
                    else
                        if _snap2.pos then local root2=getHRP2(); if root2 then root2.CFrame=_snap2.pos+Vector3.new(0,40,0) end end; _snap2.pos=nil; _snap2.flickering=false
                    end
                end)

                -- ANTI LOCK
                local _antiLockConn2=nil
                local function stopAntiLock2() if _antiLockConn2 then pcall(function() _antiLockConn2:Disconnect() end); _antiLockConn2=nil end end
                local function startAntiLock2()
                    stopAntiLock2()
                    _antiLockConn2=RunService2.Heartbeat:Connect(function()
                        if not antiLockEnabled2 then return end
                        local char2=LocalPlayer3.Character; if not char2 then return end
                        local root2=char2:FindFirstChild("HumanoidRootPart"); if not root2 then return end
                        local prevVel2=root2.Velocity; local angle2=math.rad(tick()*1500%360); local amount2=getEnv2().SkyAmount
                        root2.Velocity=Vector3.new(math.cos(angle2)*amount2,math.random(280,480),math.sin(angle2)*amount2)
                        RunService2.RenderStepped:Wait(); if not antiLockEnabled2 then root2.Velocity=Vector3.new(0,0,0); return end; root2.Velocity=prevVel2
                    end)
                end

                -- PICKUP (STEALTH: usa netGet2 con distancia validada server-side — no parchear)
                local lastPickup2=0
                local function checkAndPickup2()
                    if not autoPickupEnabled2 then return end
                    local dropped2=Workspace2:FindFirstChild("DroppedItems"); if not dropped2 then return end
                    local now2=tick(); local toPickup2={}
                    for _,model2 in ipairs(dropped2:GetChildren()) do
                        if model2:IsA("Model") then
                            local part2=model2:FindFirstChildWhichIsA("BasePart")
                            if part2 and HRP2 then
                                local dist2=(HRP2.Position-part2.Position).Magnitude
                                -- STEALTH: cap a 20 studs (original era 20, lo preservamos)
                                if dist2<=20 and (now2-(itemPickupTrack2[model2] or 0))>=0 then
                                    table.insert(toPickup2,model2); itemPickupTrack2[model2]=now2
                                end
                            end
                        end
                    end
                    for _,model2 in ipairs(toPickup2) do spawn(function() netGet2("pickup_dropped_item",model2) end) end
                end
                RunService2.Heartbeat:Connect(function()
                    if not LocalPlayer3.Character or not LocalPlayer3.Character:FindFirstChild("HumanoidRootPart") then
                        Character2=LocalPlayer3.Character or LocalPlayer3.CharacterAdded:Wait(); HRP2=Character2:WaitForChild("HumanoidRootPart")
                    end
                    pcall(checkAndPickup2)
                end)

                -- AUTO FINISH
                local function setFinishPrompt2(prompt2) if prompt2 and prompt2:IsA("ProximityPrompt") then prompt2.HoldDuration=1; prompt2.MaxActivationDistance=20 end end
                local function tryHoldPrompt2(prompt2,duration2)
                    if not prompt2 or prompt2:GetAttribute("__AutoFinishBusy") then return end
                    prompt2:SetAttribute("__AutoFinishBusy",true)
                    pcall(function() if prompt2.InputHoldBegin then prompt2:InputHoldBegin() end end)
                    pcall(function() if prompt2.Trigger then prompt2:Trigger() end end)
                    task.wait(duration2)
                    pcall(function() if prompt2.InputHoldEnd then prompt2:InputHoldEnd() end end)
                    prompt2:SetAttribute("__AutoFinishBusy",nil)
                end
                local function findFinishPrompts2()
                    local result2={}
                    for _,child2 in pairs(Workspace2:GetChildren()) do
                        local player2=Players2:GetPlayerFromCharacter(child2)
                        if player2 and not isPlayerExcluded2(player2.Name) then
                            local root2=child2:FindFirstChild("HumanoidRootPart")
                            if root2 then local prompt2=root2:FindFirstChild("FinishPrompt"); if prompt2 then setFinishPrompt2(prompt2); table.insert(result2,prompt2) end end
                        end
                    end
                    return result2
                end
                task.spawn(function() while true do task.wait(0.4); if autoFinishEnabled2 then for _,prompt2 in ipairs(findFinishPrompts2()) do task.spawn(function() tryHoldPrompt2(prompt2,1) end) end end end end)

                -- SNAP UNDER MAP
                local snapConn2
                local function lockYPosition2()
                    if snapConn2 then pcall(function() snapConn2:Disconnect() end) end
                    snapConn2=RunService2.Heartbeat:Connect(function()
                        if _snap2.active and _snap2.y and HRP2 then
                            local pos2=HRP2.Position; if math.abs(pos2.Y-_snap2.y)>0.1 then HRP2.CFrame=CFrame.new(pos2.X,_snap2.y,pos2.Z) end
                        end
                    end)
                end
                lockYPosition2()

                -- ESP (STEALTH: highlights en CoreGui como el original)
                local ActivePlayerESPs2={}
                local RarityColorsESP2={Common=Color3.fromRGB(200,200,200),Uncommon=Color3.fromRGB(99,255,52),Rare=Color3.fromRGB(51,170,255),Epic=Color3.fromRGB(237,44,255),Legendary=Color3.fromRGB(255,150,0),Omega=Color3.fromRGB(255,20,51)}
                local function CreateESPText2(color2) local t2=Drawing.new("Text"); t2.Size=13; t2.Center=true; t2.Outline=true; t2.OutlineColor=Color3.new(0,0,0); t2.Color=color2 or Color3.new(1,1,1); t2.Font=2; t2.Visible=false; return t2 end
                local function DestroyESPData2(data2) if not data2 then return end pcall(function() if data2.text then data2.text:Remove() end end); pcall(function() if data2.highlight then data2.highlight:Destroy() end end); if data2.invTexts then for _,d2 in ipairs(data2.invTexts) do pcall(function() d2:Remove() end) end end end
                Players2.PlayerRemoving:Connect(function(player2) if ActivePlayerESPs2[player2] then DestroyESPData2(ActivePlayerESPs2[player2]); ActivePlayerESPs2[player2]=nil end end)

                task.spawn(function()
                    while true do
                        task.wait(0.5)
                        local anyESP2=nameESPEnabled2 or distanceESPEnabled2 or healthESPEnabled2 or inventoryESPEnabled2 or highlightEnabled2
                        if anyESP2 then
                            for _,p2 in ipairs(Players2:GetPlayers()) do
                                if p2~=LocalPlayer3 then
                                    pcall(function()
                                        local char2=p2.Character; local hum2=char2 and char2:FindFirstChildOfClass("Humanoid"); local root2=char2 and (char2:FindFirstChild("HumanoidRootPart") or char2:FindFirstChild("Head"))
                                        if char2 and hum2 and root2 and hum2.Health>0 then
                                            if not ActivePlayerESPs2[p2] then
                                                local nt2=CreateESPText2(Color3.new(1,1,1)); local hl2=nil
                                                pcall(function()
                                                    hl2=Instance.new("Highlight"); hl2.FillTransparency=0.5; hl2.OutlineTransparency=0; hl2.Enabled=false
                                                    hl2.Parent=game.CoreGui  -- STEALTH: CoreGui, no char
                                                end)
                                                ActivePlayerESPs2[p2]={text=nt2,invTexts={},lastStr="",rootPart=nil,highlight=hl2}
                                            end
                                            local data2=ActivePlayerESPs2[p2]; data2.rootPart=root2
                                            if data2.highlight then
                                                if highlightEnabled2 then data2.highlight.Enabled=true; data2.highlight.Adornee=char2; local hpPct2=hum2.Health/math.max(hum2.MaxHealth,1); data2.highlight.FillColor=Color3.fromRGB(255*(1-hpPct2),255*hpPct2,0)
                                                else data2.highlight.Enabled=false end
                                            end
                                            local dist2=0; if LocalPlayer3.Character and LocalPlayer3.Character:FindFirstChild("HumanoidRootPart") then dist2=math.floor((LocalPlayer3.Character.HumanoidRootPart.Position-root2.Position).Magnitude) end
                                            local health2=math.floor(hum2.Health); local maxHealth2=math.floor(hum2.MaxHealth)
                                            local parts2={}
                                            if distanceESPEnabled2 then table.insert(parts2,string.format("[%dm]",dist2)) end
                                            if nameESPEnabled2 then table.insert(parts2,p2.Name) end
                                            if healthESPEnabled2 then table.insert(parts2,string.format("[%d/%d]",health2,maxHealth2)) end
                                            local newStr2=table.concat(parts2," "); if newStr2~=data2.lastStr then data2.text.Text=newStr2; data2.lastStr=newStr2 end
                                            data2.showText=(#parts2>0)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end)

                local _espFrame2=0
                RunService2.RenderStepped:Connect(function()
                    _espFrame2=_espFrame2+1; if _espFrame2%2~=0 then return end
                    local anyESP2=nameESPEnabled2 or distanceESPEnabled2 or healthESPEnabled2 or inventoryESPEnabled2 or highlightEnabled2
                    if not anyESP2 then return end
                    for _,data2 in pairs(ActivePlayerESPs2) do
                        if data2.text and data2.rootPart and data2.rootPart.Parent then
                            local anchor2=data2.rootPart.Position+(data2.rootPart.Name=="Head" and Vector3.new(0,1.5,0) or Vector3.new(0,3,0))
                            local pos2,onScreen2=Camera2:WorldToViewportPoint(anchor2)
                            if data2.showText then data2.text.Visible=onScreen2 else data2.text.Visible=false end
                            if onScreen2 then data2.text.Position=Vector2.new(pos2.X,pos2.Y) end
                        end
                    end
                end)

                -- MELEE AURA
                local meleeNames2={}; if MeleeItems2 then for _,tool2 in ipairs(MeleeItems2:GetChildren()) do table.insert(meleeNames2,tool2.Name) end end
                local function isMeleeByName2(tool2) if not tool2:IsA("Tool") then return false end if tool2.Name=="Fists" then return true end for _,name2 in ipairs(meleeNames2) do if tool2.Name==name2 then return true end end return false end
                local function modifyFists2(tool2,enable2)
                    if not tool2 then return end
                    local attrs2=tool2:GetAttributes(); local keys2={}; for k2 in pairs(attrs2) do table.insert(keys2,k2) end; table.sort(keys2)
                    if #keys2>=7 then
                        local rangeKey2=keys2[6]; local dmgKey2=keys2[7]
                        if enable2 then
                            if originalAttribs2[rangeKey2]==nil then originalAttribs2[rangeKey2]=tool2:GetAttribute(rangeKey2) end
                            if originalAttribs2[dmgKey2]==nil then originalAttribs2[dmgKey2]=tool2:GetAttribute(dmgKey2) end
                            tool2:SetAttribute(rangeKey2,360); tool2:SetAttribute(dmgKey2,20)
                        else
                            if originalAttribs2[rangeKey2] then tool2:SetAttribute(rangeKey2,originalAttribs2[rangeKey2]) end
                            if originalAttribs2[dmgKey2] then tool2:SetAttribute(dmgKey2,originalAttribs2[dmgKey2]) end
                        end
                    end
                end
                local function checkAndModifyFists2()
                    local char2=LocalPlayer3.Character; local backpack2=LocalPlayer3:FindFirstChild("Backpack"); if not char2 or not backpack2 then return end
                    for _,tool2 in ipairs(char2:GetChildren()) do if isMeleeByName2(tool2) then modifyFists2(tool2,meleeAuraEnabled2) end end
                    for _,tool2 in ipairs(backpack2:GetChildren()) do if isMeleeByName2(tool2) then modifyFists2(tool2,meleeAuraEnabled2) end end
                end
                RunService2.Heartbeat:Connect(function() if meleeAuraEnabled2 then checkAndModifyFists2() end end)

                -- WALK SPEED
                RunService2.RenderStepped:Connect(function()
                    if walkSpeedEnabled2 and Humanoid2 and HRP2 then
                        if Humanoid2.MoveDirection.Magnitude>0 then HRP2.CFrame=HRP2.CFrame+(Humanoid2.MoveDirection.Unit*speedMultiplier2) end
                    end
                end)

                -- HIGH JUMP
                local _jumpConns2={}; local _jumpHolding2=false
                local function stopHighJump2() for _,c2 in ipairs(_jumpConns2) do pcall(function() c2:Disconnect() end) end _jumpConns2={}; _jumpHolding2=false; pcall(function() ContextActionService2:UnbindAction("_HJ_FlyUp2") end) end
                local function setupHighJump2(char2)
                    if not jumpPowerEnabled2 then return end; stopHighJump2()
                    local humanoid2=char2:WaitForChild("Humanoid"); local hrp2=char2:WaitForChild("HumanoidRootPart")
                    ContextActionService2:BindAction("_HJ_FlyUp2",function(_,inputState2,inputObj2)
                        if not jumpPowerEnabled2 then return Enum.ContextActionResult.Pass end
                        local isJump2=(inputObj2.UserInputType==Enum.UserInputType.Keyboard and inputObj2.KeyCode==Enum.KeyCode.Space) or inputObj2.UserInputType==Enum.UserInputType.Touch
                        if isJump2 then
                            if inputState2==Enum.UserInputState.Begin then _jumpHolding2=true; humanoid2.Jump=true; return Enum.ContextActionResult.Sink
                            elseif inputState2==Enum.UserInputState.End then _jumpHolding2=false; return Enum.ContextActionResult.Sink end
                        end
                        return Enum.ContextActionResult.Pass
                    end,false,Enum.KeyCode.Space)
                    _jumpConns2[1]=RunService2.RenderStepped:Connect(function() if jumpPowerEnabled2 and _jumpHolding2 and hrp2 then hrp2.Velocity=Vector3.new(hrp2.Velocity.X,40,hrp2.Velocity.Z) end end)
                end
                LocalPlayer3.CharacterAdded:Connect(function(char2) if jumpPowerEnabled2 then setupHighJump2(char2) end end)

                -- ITEM ESP (DroppedItems)
                local ItemCamera2=Workspace2.CurrentCamera
                local function getRarityColor2(model2)
                    if model2.Name=="Money" then return Color3.fromRGB(0,255,0) end
                    if Items2 then for _,folder2 in ipairs(Items2:GetChildren()) do if folder2:IsA("Folder") then local item2=folder2:FindFirstChild(model2.Name); if item2 and item2:GetAttribute("RarityName") then return RarityColors2[item2:GetAttribute("RarityName")] or Color3.fromRGB(255,255,255) end end end end
                    return Color3.fromRGB(255,255,255)
                end
                RunService2.RenderStepped:Connect(function()
                    if not DroppedItems2 then return end
                    local myRoot2=LocalPlayer3.Character and LocalPlayer3.Character:FindFirstChild("HumanoidRootPart"); if not myRoot2 then return end
                    for _,data2 in pairs(itemDrawings2) do if data2.name then data2.name.Visible=false end if data2.amount then data2.amount.Visible=false end if data2.highlight then data2.highlight.Enabled=false end end
                    for _,model2 in ipairs(DroppedItems2:GetChildren()) do
                        if model2:IsA("Model") and model2:FindFirstChild("PickUpZone") then
                            local pos2,vis2=ItemCamera2:WorldToViewportPoint(model2.PickUpZone.Position)
                            if vis2 then
                                if not itemDrawings2[model2] then
                                    local hl2=Instance.new("Highlight"); hl2.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl2.FillTransparency=0.6; hl2.OutlineTransparency=0; hl2.Adornee=model2; hl2.Parent=model2
                                    itemDrawings2[model2]={name=Drawing.new("Text"),amount=Drawing.new("Text"),highlight=hl2}
                                    itemDrawings2[model2].name.Outline=true; itemDrawings2[model2].name.OutlineColor=Color3.fromRGB(0,0,0); itemDrawings2[model2].name.Center=true; itemDrawings2[model2].name.Size=13; itemDrawings2[model2].name.Font=2
                                    itemDrawings2[model2].amount.Outline=true; itemDrawings2[model2].amount.OutlineColor=Color3.fromRGB(0,0,0); itemDrawings2[model2].amount.Center=true; itemDrawings2[model2].amount.Size=11; itemDrawings2[model2].amount.Font=2
                                end
                                local color2=getRarityColor2(model2)
                                itemDrawings2[model2].highlight.OutlineColor=color2; itemDrawings2[model2].highlight.FillColor=color2; itemDrawings2[model2].highlight.Enabled=true
                                itemDrawings2[model2].name.Color=color2; itemDrawings2[model2].name.Position=Vector2.new(pos2.X,pos2.Y); itemDrawings2[model2].name.Text=model2.Name; itemDrawings2[model2].name.Visible=true
                                local amt2=model2:GetAttribute("Amount") or 1; itemDrawings2[model2].amount.Position=Vector2.new(pos2.X,pos2.Y+15); itemDrawings2[model2].amount.Text=amt2>1 and "["..tostring(amt2).."]" or ""; itemDrawings2[model2].amount.Visible=amt2>1
                            end
                        end
                    end
                end)

                -- INPUT
                UserInputService.InputBegan:Connect(function(input2,gp2)
                    if gp2 then return end
                    if input2.KeyCode==Enum.KeyCode.G and WindUI2 and Window2 then
                        if Window2.Toggle then Window2:Toggle() elseif Window2.SetVisible then Window2:SetVisible(not Window2.Visible) end
                    end
                    if input2.KeyCode==Enum.KeyCode.Z and _snap2.enabled then
                        _snap2.active=not _snap2.active
                        if _snap2.active then
                            if not _snap2.originY then _snap2.originY=HRP2 and HRP2.Position.Y end
                            local destY=(_snap2.originY or 0)-_snap2.depth; if HRP2 then HRP2.CFrame=CFrame.new(HRP2.Position.X,destY,HRP2.Position.Z) end; _snap2.y=destY
                        else _snap2.y=nil end
                    end
                end)

                -- TABS
                task.spawn(function()
                    -- COMBAT TAB
                    if _CombatTab2 then
                        _CombatTab2:Section({Title="GUN:"})
                        _CombatTab2:Toggle({Title="Silent Aim",Default=false,Callback=function(v) silentAimEnabled2=v; aimTarget2=nil end})
                        _CombatTab2:Toggle({Title="Red Line Lock",Default=false,Callback=function(v) redLineLockEnabled2=v; aimTarget2=nil end})
                        _CombatTab2:Slider({Title="FOV",Step=1,Value={Min=20,Max=800,Default=fovRadius2},Callback=function(v) fovRadius2=tonumber(v) or 120; fovCircle2.Radius=fovRadius2 end})
                        _CombatTab2:Toggle({Title="Show FOV",Default=false,Callback=function(v) SA_ShowFOV2=v; fovCircle2.Visible=v end})
                        _CombatTab2:Dropdown({Title="Aim Part",Values={"Head","Body"},Multi=false,Default="Head",Callback=function(v) SA_AimPart2=v end})
                        _CombatTab2:Slider({Title="Multiplier Shot",Step=1,Value={Min=1,Max=5,Default=1},Callback=function(v) shotMultiplier2=tonumber(v) or 1 end})
                        _CombatTab2:Section({Title="AUTO:"})
                        _CombatTab2:Toggle({Title="Auto Shoot",Default=false,Callback=function(v) autoShootEnabled2=v end})
                        _CombatTab2:Slider({Title="Auto Shoot Speed",Step=0.01,Value={Min=0.03,Max=0.5,Default=0.08},Callback=function(v) autoShootInterval2=tonumber(v) or 0.08 end})
                        _CombatTab2:Toggle({Title="Kill All",Default=false,Callback=function(v) _G._killAllEnabled2=v; autoShootEnabled2=v end})
                        _CombatTab2:Toggle({Title="Auto Reload",Default=false,Callback=function(v) autoReloadEnabled2=v end})
                        local function getPlayerNames2() local n2={}; for _,p2 in ipairs(Players2:GetPlayers()) do if p2~=LocalPlayer3 then table.insert(n2,p2.Name) end end return n2 end
                        local FriendDropdown2=_CombatTab2:Dropdown({Title="Safe Friend",Values=getPlayerNames2(),Default={},Multi=true,Callback=function(v2)
                            excludedPlayers2={}
                            if type(v2)=="table" then for name2,selected2 in pairs(v2) do if type(name2)=="string" and selected2==true then table.insert(excludedPlayers2,name2) end end end
                        end})
                        Players2.PlayerAdded:Connect(function() pcall(function() FriendDropdown2:Refresh(getPlayerNames2(),true) end) end)
                        Players2.PlayerRemoving:Connect(function() pcall(function() FriendDropdown2:Refresh(getPlayerNames2(),true) end) end)
                    end

                    -- WEAPON TAB
                    if _WeaponTab2 then
                        _WeaponTab2:Section({Title="MODS:"})
                        _WeaponTab2:Slider({Title="Fire Rate",Step=10,Value={Min=100,Max=3000,Default=1000},Callback=function(v) getEnv2().FireRateValue=v end})
                        _WeaponTab2:Slider({Title="Accuracy",Step=0.01,Value={Min=0,Max=1,Default=1},Callback=function(v) getEnv2().AccuracyValue=v end})
                        _WeaponTab2:Slider({Title="Recoil",Step=0.1,Value={Min=0,Max=10,Default=0},Callback=function(v) getEnv2().RecoilValue=v end})
                        _WeaponTab2:Toggle({Title="Automatic",Value=false,Callback=function(v) getEnv2().GunModsAutoApply=v end})
                        _WeaponTab2:Toggle({Title="Rapid Fire",Default=false,Callback=function(v)
                            rapidFireEnabled2=v
                            if v then local char2=LocalPlayer3.Character; if char2 then for _,tool2 in ipairs(char2:GetChildren()) do if tool2:IsA("Tool") and isGunTool2(tool2) then pcall(function() tool2:SetAttribute(FindFireRateAttribute2(tool2),9999); tool2:SetAttribute("automatic",true) end) end end end end
                        end})
                        _WeaponTab2:Toggle({Title="Melee Aura",Default=false,Callback=function(v) meleeAuraEnabled2=v; checkAndModifyFists2() end})
                        _WeaponTab2:Toggle({Title="Auto Attack",Default=false,Callback=function(v) autoAttackEnabled2=v end})
                    end

                    -- ESP TAB
                    if _ESPTab2 then
                        _ESPTab2:Toggle({Title="Name",Default=false,Callback=function(v) nameESPEnabled2=v end})
                        _ESPTab2:Toggle({Title="Health",Default=false,Callback=function(v) healthESPEnabled2=v end})
                        _ESPTab2:Toggle({Title="Distance",Default=false,Callback=function(v) distanceESPEnabled2=v end})
                        _ESPTab2:Toggle({Title="Highlight",Default=false,Callback=function(v) highlightEnabled2=v end})
                        _ESPTab2:Toggle({Title="Inventory Viewer",Default=false,Callback=function(v) inventoryESPEnabled2=v end})
                    end

                    -- CHARACTER TAB
                    if _CharTab2 then
                        _CharTab2:Toggle({Title="Walk Speed",Default=false,Callback=function(v) walkSpeedEnabled2=v end})
                        _CharTab2:Slider({Title="Speed Multiplier",Step=0.5,Value={Min=1,Max=5,Default=2},Callback=function(v) speedMultiplier2=v*0.05 end})
                        _CharTab2:Toggle({Title="High Jump",Default=false,Callback=function(v) jumpPowerEnabled2=v; if v and LocalPlayer3.Character then setupHighJump2(LocalPlayer3.Character) else stopHighJump2() end end})
                        _CharTab2:Toggle({Title="Anti Lock",Default=false,Callback=function(v) antiLockEnabled2=v; getEnv2().Sky=v; if v then getEnv2().SkyAmount=1500; startAntiLock2() else stopAntiLock2() end end})
                        _CharTab2:Toggle({Title="Anti Kill",Default=false,Callback=function(v) antiKillEnabled2=v end})
                        _CharTab2:Toggle({Title="Pickup Items",Default=false,Callback=function(v) autoPickupEnabled2=v end})
                        _CharTab2:Toggle({Title="Anti Ragdoll",Default=false,Callback=function(enabled2)
                            if not enabled2 then return end
                            pcall(function()
                                local function findCounter3() for _,v3 in ipairs(getgc and getgc(true) or {}) do if typeof(v3)=="table" and rawget(v3,"event") and rawget(v3,"func") then return v3 end end end
                                local ctr3=findCounter3(); if not ctr3 then return end
                                local function sendAction3(action3) ctr3.event=(ctr3.event or 0)+1; ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Send"):FireServer(ctr3.event,action3) end
                                task.spawn(function() while enabled2 do sendAction3("end_ragdoll_early"); task.wait(0.3); if not enabled2 then break end sendAction3("clear_ragdoll"); task.wait(0.3) end end)
                            end)
                        end})
                        _CharTab2:Toggle({Title="Auto Respawn",Default=false,Callback=function(enabled2)
                            if not enabled2 then return end
                            pcall(function()
                                local function findCounter3() for _,v3 in ipairs(getgc and getgc(true) or {}) do if typeof(v3)=="table" and rawget(v3,"event") and rawget(v3,"func") then return v3 end end end
                                local ctr3=findCounter3(); if not ctr3 then return end
                                local function sendAction3(action3) ctr3.event=(ctr3.event or 0)+1; ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Send"):FireServer(ctr3.event,action3) end
                                task.spawn(function() while enabled2 do local char2=LocalPlayer3.Character; local hum2=char2 and char2:FindFirstChildOfClass("Humanoid"); if hum2 and hum2.Health<=0 then task.wait(6); if enabled2 then sendAction3("death_screen_request_respawn") end end task.wait(0.5) end end)
                            end)
                        end})
                        _CharTab2:Toggle({Title="Snap Under Map",Default=false,Callback=function(v)
                            _snap2.enabled=v
                            if v then _snap2.originY=HRP2 and HRP2.Position.Y; _snap2.y=HRP2 and HRP2.Position.Y; _snap2.active=true
                                if HRP2 then local destY=(_snap2.originY or 0)-_snap2.depth; HRP2.CFrame=CFrame.new(HRP2.Position.X,destY,HRP2.Position.Z); _snap2.y=destY end
                            else _snap2.active=false; _snap2.y=nil; _snap2.originY=nil end
                        end})
                        _CharTab2:Slider({Title="Snap Depth",Step=1,Value={Min=1,Max=100,Default=10},Callback=function(v) _snap2.depth=v end})
                    end

                    -- PLAYER TAB
                    if _PlayerTab2 then
                        _PlayerTab2:Toggle({Title="Auto Finish",Default=false,Callback=function(v) autoFinishEnabled2=v end})
                    end

                    -- BUY TAB
                    if _BuyTab2 then
                        _BuyTab2:Section({Title="BUY:"})
                        local Client2=Players2.LocalPlayer; local PlayerGui2=Client2:WaitForChild("PlayerGui")
                        local BankBtn2=_BuyTab2:Button({Title="Bank Balance",Desc="N/A"}); local HandBtn2=_BuyTab2:Button({Title="Hand Balance",Desc="N/A"})
                        task.spawn(function()
                            while task.wait(0.2) do
                                pcall(function() BankBtn2:SetDesc("$"..tostring(tonumber(PlayerGui2.TopRightHud.Holder.Frame.MoneyTextLabel.Text:match("%$(%d+)")) or 0)) end)
                            end
                        end)
                        local selBullet2="Pistol"
                        _BuyTab2:Dropdown({Title="Bullet Type",Values={"Pistol","Rifle","Shotgun","Random"},Value="Pistol",Multi=false,Callback=function(v) selBullet2=v end})
                        _BuyTab2:Button({Title="Open Ammo Crate",Callback=function()
                            local useType2=selBullet2; if useType2=="Random" then local opts2={"Pistol","Rifle","Shotgun"}; useType2=opts2[math.random(1,#opts2)] end
                            pcall(function()
                                local map2=workspace:FindFirstChild("Map"); if not map2 then return end
                                local crateOptions2=map2:FindFirstChild("Tiles") and map2.Tiles:FindFirstChild("GunShopTile") and map2.Tiles.GunShopTile:FindFirstChild("PatriotWeapons") and map2.Tiles.GunShopTile.PatriotWeapons:FindFirstChild("Interior") and map2.Tiles.GunShopTile.PatriotWeapons.Interior:FindFirstChild("Crates") and map2.Tiles.GunShopTile.PatriotWeapons.Interior.Crates:FindFirstChild("Ammo Crate") and map2.Tiles.GunShopTile.PatriotWeapons.Interior.Crates["Ammo Crate"]:FindFirstChild("CrateOptions")
                                if crateOptions2 then local targetItem2=crateOptions2:FindFirstChild(useType2); if targetItem2 then netGet2("open_crate",targetItem2,"money") end end
                            end)
                        end})
                    end

                    -- MISC TAB
                    if _MiscTab2 then
                        _MiscTab2:Button({Title="Server Rejoin",Callback=function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,LocalPlayer3) end})
                        _MiscTab2:Button({Title="Copy JobID",Callback=function() if setclipboard then setclipboard(game.JobId) end end})
                        _MiscTab2:Button({Title="Hop Server",Callback=function()
                            local HttpService2=game:GetService("HttpService"); local TeleportService2=game:GetService("TeleportService")
                            local servers2={}; local req2=game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",game.PlaceId))
                            local data2=HttpService2:JSONDecode(req2); if data2 and data2.data then for _,v2 in pairs(data2.data) do if v2.playing<v2.maxPlayers then table.insert(servers2,v2.id) end end end
                            if #servers2>0 then TeleportService2:TeleportToPlaceInstance(game.PlaceId,servers2[math.random(1,#servers2)],LocalPlayer3) end
                        end})
                        _MiscTab2:Button({Title="Claim All Quests",Callback=function()
                            task.spawn(function()
                                pcall(function()
                                    local function findCounter3() for _,v3 in ipairs(getgc and getgc(true) or {}) do if typeof(v3)=="table" and rawget(v3,"event") and rawget(v3,"func") then return v3 end end end
                                    local ctr3=findCounter3(); if not ctr3 then return end
                                    local remote3={}; function remote3.get(...) ctr3.func=(ctr3.func or 0)+1; return ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Get"):InvokeServer(ctr3.func,...) end
                                    local qf=LocalPlayer3:WaitForChild("PlayerGui"):WaitForChild("Quests"):WaitForChild("QuestsHolder"):WaitForChild("QuestsScrollingFrame")
                                    for _,child3 in ipairs(qf:GetChildren()) do if child3:IsA("Frame") or child3:IsA("TextButton") then remote3.get("claim_quest",child3.Name); task.wait(0.2) end end
                                end)
                            end)
                        end})
                        _MiscTab2:Button({Title="Boost FPS",Callback=function()
                            local Lighting2=game:GetService("Lighting")
                            for _,v2 in ipairs(Lighting2:GetChildren()) do if v2:IsA("Sky") or v2:IsA("Atmosphere") or v2:IsA("BloomEffect") or v2:IsA("SunRaysEffect") or v2:IsA("ColorCorrectionEffect") or v2:IsA("DepthOfFieldEffect") then v2:Destroy() end end
                            Lighting2.GlobalShadows=false; Lighting2.Brightness=0; Lighting2.FogEnd=9e9
                            local sky2=Instance.new("Sky"); sky2.SkyboxBk="rbxassetid://6444884337"; sky2.SkyboxDn="rbxassetid://6444884337"; sky2.SkyboxFt="rbxassetid://6444884337"; sky2.SkyboxLf="rbxassetid://6444884337"; sky2.SkyboxRt="rbxassetid://6444884337"; sky2.SkyboxUp="rbxassetid://6444884337"; sky2.Parent=Lighting2
                        end})
                        _MiscTab2:Button({Title="RTX ON",Callback=function()
                            local Lighting2=game:GetService("Lighting")
                            for _,v2 in ipairs(Lighting2:GetChildren()) do if v2:IsA("Sky") or v2:IsA("Atmosphere") or v2:IsA("BloomEffect") or v2:IsA("SunRaysEffect") or v2:IsA("ColorCorrectionEffect") or v2:IsA("DepthOfFieldEffect") then v2:Destroy() end end
                            local Sky2=Instance.new("Sky"); Sky2.SkyboxBk="rbxassetid://159454299"; Sky2.SkyboxDn="rbxassetid://159454296"; Sky2.SkyboxFt="rbxassetid://159454293"; Sky2.SkyboxLf="rbxassetid://159454286"; Sky2.SkyboxRt="rbxassetid://159454300"; Sky2.SkyboxUp="rbxassetid://159454288"; Sky2.Parent=Lighting2
                            Lighting2.Technology=Enum.Technology.Future; Lighting2.GlobalShadows=true; Lighting2.Brightness=3; Lighting2.EnvironmentDiffuseScale=1; Lighting2.EnvironmentSpecularScale=1
                            local Bloom2=Instance.new("BloomEffect"); Bloom2.Intensity=1.2; Bloom2.Size=56; Bloom2.Threshold=0.85; Bloom2.Parent=Lighting2
                            local CC2=Instance.new("ColorCorrectionEffect"); CC2.Brightness=0.05; CC2.Contrast=0.25; CC2.Saturation=0.35; CC2.Parent=Lighting2
                        end})
                        _MiscTab2:Button({Title="Remove Doors",Callback=function()
                            local CollectionService2=game:GetService("CollectionService")
                            for _,tag2 in pairs(CollectionService2:GetAllTags()) do if tag2:lower():find("door") then for _,obj2 in pairs(CollectionService2:GetTagged(tag2)) do pcall(function() obj2:Destroy() end) end end end
                            for _,obj2 in pairs(workspace:GetDescendants()) do if obj2.Name:lower():find("door") then pcall(function() obj2:Destroy() end) end end
                        end})
                    end

                    if Config2.Load then pcall(function() Config2.Load(Config2) end) end
                end)

                LocalPlayer3.CharacterAdded:Connect(function(char2) Character2=char2; HRP2=char2:WaitForChild("HumanoidRootPart"); _snap2.y=nil; _snap2.active=false; lockYPosition2() end)
                if LocalPlayer3.Character then lockYPosition2() end
            end)
            if not ok then warn("[BSS STRONG ERROR]",err) end
        end)
    end)
end

-- ============================================================================
-- BOTONES DEL SELECTOR
-- ============================================================================
disimBtn.MouseButton1Click:Connect(launchDisimulated)
strongBtn.MouseButton1Click:Connect(launchStrong)
