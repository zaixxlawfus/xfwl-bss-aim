-- ============================================================================
-- BSS LAUNCHER v2.1 — DUAL PANEL FIXED (strong integrado)
-- Selector + DISIMULATED (BSS-Aim ULTRA v13.7) + STRONG (SuperHub BlockSpin)
-- ============================================================================
-- ============================================================================
-- BSS LAUNCHER v2.0 — DUAL PANEL COMPLETO (PARTE 1/3)
-- Panel selector + DISIMULATED completo
-- ============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

pcall(function()
    local parent=(gethui and gethui()) or game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if parent then for _,v in ipairs(parent:GetChildren()) do if tostring(v.Name):match("^BSS_") or tostring(v.Name)=="zhXUI" or tostring(v.Name)=="BSS_LAUNCHER" then v:Destroy() end end end
    pcall(function() game:GetService("RunService"):UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
end)

local Players=game:GetService("Players"); local TweenService=game:GetService("TweenService"); local LocalPlayer=Players.LocalPlayer
local function getParentGui() if gethui then local ok,r=pcall(gethui); if ok and r then return r end end return LocalPlayer:WaitForChild("PlayerGui") end

-- SELECTOR UI
local selGui=Instance.new("ScreenGui"); selGui.Name="BSS_LAUNCHER"; selGui.ResetOnSpawn=false; selGui.IgnoreGuiInset=true; selGui.DisplayOrder=999; selGui.Parent=getParentGui()
local bg=Instance.new("Frame"); bg.Size=UDim2.fromOffset(500,240); bg.AnchorPoint=Vector2.new(0.5,0.5); bg.Position=UDim2.fromScale(0.5,0.5); bg.BackgroundColor3=Color3.fromRGB(6,6,8); bg.BackgroundTransparency=0; bg.BorderSizePixel=0; bg.Parent=selGui
Instance.new("UICorner",bg).CornerRadius=UDim.new(0,18)
local bgStroke=Instance.new("UIStroke"); bgStroke.Color=Color3.fromRGB(80,80,100); bgStroke.Thickness=1.8; bgStroke.Parent=bg
local titleLbl=Instance.new("TextLabel"); titleLbl.Size=UDim2.new(1,0,0,36); titleLbl.Position=UDim2.new(0,0,0,14); titleLbl.BackgroundTransparency=1; titleLbl.Text="BSS LAUNCHER  ·  elige tu build"; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextSize=16; titleLbl.TextColor3=Color3.fromRGB(220,220,230); titleLbl.Parent=bg
local subLbl=Instance.new("TextLabel"); subLbl.Size=UDim2.new(1,0,0,16); subLbl.Position=UDim2.new(0,0,0,50); subLbl.BackgroundTransparency=1; subLbl.Text="Disimulated = stealth aimbot/ESP  ·  Strong = superhub completo"; subLbl.Font=Enum.Font.Gotham; subLbl.TextSize=10; subLbl.TextColor3=Color3.fromRGB(120,120,140); subLbl.Parent=bg

local function makePanelBtn(label,sublabel,xPos,accentCol)
    local card=Instance.new("Frame"); card.Size=UDim2.fromOffset(210,118); card.Position=UDim2.new(0,xPos,0,78); card.BackgroundColor3=Color3.fromRGB(14,14,18); card.BorderSizePixel=0; card.Parent=bg
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
    local cs=Instance.new("UIStroke"); cs.Color=accentCol; cs.Thickness=1.6; cs.Parent=card
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,28); lbl.Position=UDim2.new(0,0,0,14); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=15; lbl.TextColor3=accentCol; lbl.Parent=card
    local sub=Instance.new("TextLabel"); sub.Size=UDim2.new(1,-16,0,36); sub.Position=UDim2.new(0,8,0,42); sub.BackgroundTransparency=1; sub.Text=sublabel; sub.Font=Enum.Font.Gotham; sub.TextSize=10; sub.TextColor3=Color3.fromRGB(140,140,160); sub.TextWrapped=true; sub.Parent=card
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,-20,0,26); btn.Position=UDim2.new(0,10,1,-34); btn.BackgroundColor3=accentCol; btn.BorderSizePixel=0; btn.Text="CARGAR"; btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.TextColor3=Color3.fromRGB(6,6,8); btn.AutoButtonColor=false; btn.Parent=card
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
    return btn
end

local disimBtn=makePanelBtn("DISIMULATED","BSS-Aim ULTRA v13.7 STEALTH\naimbot · ESP · pickup · lerp cam",35,Color3.fromRGB(255,255,255))
local strongBtn=makePanelBtn("STRONG","SuperHub BlockSpin COMPLETO\nkill all · god gun · anti kill · ESP · inf stamina",265,Color3.fromRGB(160,80,255))

bg.Size=UDim2.fromOffset(1,1)
TweenService:Create(bg,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(500,240)}):Play()

local function closeSel()
    local tw=TweenService:Create(bg,TweenInfo.new(0.18,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.fromOffset(1,1),BackgroundTransparency=1})
    tw:Play(); tw.Completed:Connect(function() selGui:Destroy() end)
end
local function launchDisimulated()
    closeSel(); task.wait(0.2)
    pcall(function() local p=getParentGui(); if p then for _,v in ipairs(p:GetChildren()) do if tostring(v.Name):match("^BSS_") then v:Destroy() end end end end)
    pcall(function() game:GetService("RunService"):UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
    getgenv().BSS_Aim_Loaded=true

    local RunService=game:GetService("RunService"); local UserInputService=game:GetService("UserInputService")
    local Workspace=game:GetService("Workspace"); local HttpService=game:GetService("HttpService")
    local StarterGui=game:GetService("StarterGui"); local LocalPlayer2=Players.LocalPlayer
    local Camera=Workspace.CurrentCamera
    local IS_MOBILE=UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local IS_PC=not IS_MOBILE; local ICON_SPLASH="rbxassetid://96190503453096"

    local WEAPON_DB={
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
    local function resolveWeapon(n2) if not n2 then return nil end local e=WEAPON_DB[n2]; if e then return e end local lo=n2:lower(); for k,v in pairs(WEAPON_DB) do if k:lower()==lo then return v end end; for k,v in pairs(WEAPON_DB) do if lo:find(k:lower(),1,true) then return v end end return nil end
    local _wepCache={}
    local function invalidateWep(uid) _wepCache[uid]=nil end
    local function getBestWeapon(plr) local uid=plr.UserId; local char=plr.Character; local bp=plr:FindFirstChild("Backpack"); local eq=char and char:FindFirstChildOfClass("Tool"); local key=eq and eq.Name or "__none__"; local cached=_wepCache[uid]; if cached and cached.key==key then return cached.entry,cached.tex end; local best,bestTier,bestTex=nil,-1,""; local function ct(t) if t:IsA("Tool") then local e=resolveWeapon(t.Name); if e and e.tier>bestTier then bestTier=e.tier; best=e; bestTex=(t.TextureId and t.TextureId~="") and t.TextureId or "" end end end; if bp then for _,t in ipairs(bp:GetDescendants()) do ct(t) end end; if char then for _,t in ipairs(char:GetDescendants()) do ct(t) end end; _wepCache[uid]={key=key,entry=best,tex=bestTex}; return best,bestTex end
    local function hwc(plr) if plr==LocalPlayer2 then return end; local function ot(c) if c:IsA("Tool") then invalidateWep(plr.UserId) end end; local bp=plr:FindFirstChild("Backpack"); if bp then bp.ChildAdded:Connect(ot); bp.ChildRemoved:Connect(ot) end; plr.ChildAdded:Connect(function(c) if c.Name=="Backpack" then c.ChildAdded:Connect(ot); c.ChildRemoved:Connect(ot) end end); if plr.Character then plr.Character.ChildAdded:Connect(ot); plr.Character.ChildRemoved:Connect(ot) end; plr.CharacterAdded:Connect(function(char) invalidateWep(plr.UserId); char.ChildAdded:Connect(ot); char.ChildRemoved:Connect(ot) end) end
    for _,p in ipairs(Players:GetPlayers()) do hwc(p) end; Players.PlayerAdded:Connect(hwc); Players.PlayerRemoving:Connect(function(p) _wepCache[p.UserId]=nil end)

    local CONFIG_FOLDER="BSS_Aim_Ultra"; local CONFIG_FILE=CONFIG_FOLDER.."/config.json"
    local HAVE_FILE_IO=(writefile and readfile and isfile and makefolder) and true or false; local CONFIG_VERSION=27
    local function ensureFolder() if not HAVE_FILE_IO then return end pcall(function() if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end end) end
    local function serializeCfg(cfg) local c={}; for k,v in pairs(cfg) do if type(v)=="number" or type(v)=="string" or type(v)=="boolean" then c[k]=v elseif typeof(v)=="EnumItem" then c[k]=tostring(v); c[k.."__enum"]=v.EnumType.Name elseif typeof(v)=="Color3" then c[k]={v.R,v.G,v.B}; c[k.."__c3"]=true end end return c end
    local function deserializeCfg(data) if not data then return nil end; for k,v in pairs(data) do if type(k)=="string" and k:sub(-7)=="__enum" then local rk=k:sub(1,-8); if Enum[v] and data[rk] then local ok2,item=pcall(function() return Enum[v][data[rk]] end); if ok2 then data[rk]=item end end; data[k]=nil elseif type(k)=="string" and k:sub(-4)=="__c3" then local rk=k:sub(1,-5); if type(data[rk])=="table" then local t=data[rk]; data[rk]=Color3.new(t[1],t[2],t[3]) end; data[k]=nil end end return data end
    local function saveConfigTo(path,cfg) if not HAVE_FILE_IO then return false end return pcall(function() ensureFolder(); writefile(path,HttpService:JSONEncode(serializeCfg(cfg))) end) end
    local function loadConfigFrom(path) if not HAVE_FILE_IO then return nil end local ok,data=pcall(function() if not isfile(path) then return nil end return HttpService:JSONDecode(readfile(path)) end); if not ok or not data then return nil end return deserializeCfg(data) end
    local DEFAULTS={ConfigVersion=CONFIG_VERSION,Enabled=true,HoldKey="E",PanelKey="L",CloseKey="M",PanicKey="Delete",FOV=130,FOVRadius=130,MaxDistance=500,TargetPart="Head",TeamCheck=false,WallCheck=true,DrawFOV=true,CameraLock=true,CameraLerpSpeed=0.18,SilentAim=true,TriggerBot=false,Priority="fov",PlayerESP=true,ChamsESP=true,NameESP=true,HealthESP=true,WeaponESP=true,NoRecoil=true,MaxESP=5000,TextDist=600,ESPColor={1,1,1},AutoPickup=true,PickupRadius=30,PickupDelay=0.15,PickupMoney=true,PickupWeapons=true,PickupFood=true,PickupTools=true,HUDWatermark=true,HUDFPS=true,HideName=false,HideNameText="...",HideLeaderboard=false}
    local function defaultCfg() local c={}; for k,v in pairs(DEFAULTS) do if type(v)=="table" then c[k]={unpack(v)} else c[k]=v end end return c end
    local function resolveKey(s,default) if typeof(s)=="EnumItem" then return s end if type(s)=="string" then local ok,e=pcall(function() return Enum.KeyCode[s] end); if ok and e then return e end end return default end
    local CFG=defaultCfg(); local saved=loadConfigFrom(CONFIG_FILE)
    if saved and saved.ConfigVersion==CONFIG_VERSION then for k,v in pairs(saved) do if CFG[k]~=nil or k=="ESPColor" then CFG[k]=v end end else CFG.HoldKey=resolveKey("E",Enum.KeyCode.E); CFG.PanelKey=resolveKey("L",Enum.KeyCode.L); CFG.CloseKey=resolveKey("M",Enum.KeyCode.M); saveConfigTo(CONFIG_FILE,CFG) end
    if type(CFG.ESPColor)=="table" then CFG.ESPColor=Color3.new(unpack(CFG.ESPColor)) end
    CFG.PickupRadius=math.min(CFG.PickupRadius,30); CFG.FOVRadius=CFG.FOV; getgenv().BSS_AimConfig=CFG
    local dirtyFlag=false; local lastAutoSave=tick()
    local function scheduleSave() dirtyFlag=true end
    local function doSave() if not HAVE_FILE_IO then return end if saveConfigTo(CONFIG_FILE,CFG) then dirtyFlag=false; lastAutoSave=tick() end end
    task.spawn(function() while getgenv().BSS_Aim_Loaded do if dirtyFlag and (tick()-lastAutoSave)>=10 then doSave() end task.wait(1) end end)

    local C={bg=Color3.fromRGB(6,6,8),bg2=Color3.fromRGB(12,12,16),bg3=Color3.fromRGB(20,20,26),bg4=Color3.fromRGB(32,32,40),accent=Color3.fromRGB(255,255,255),accent2=Color3.fromRGB(220,220,230),fg=Color3.fromRGB(245,245,250),muted=Color3.fromRGB(140,140,155),danger=Color3.fromRGB(255,70,90),border=Color3.fromRGB(60,60,72),hp=Color3.fromRGB(80,220,120),aimOn=Color3.fromRGB(255,80,90),aimLock=Color3.fromRGB(255,255,255),gold=Color3.fromRGB(255,200,50)}
    local function notify(title,text,dur) pcall(function() StarterGui:SetCore("SendNotification",{Title=title,Text=text,Duration=dur or 4}) end) end

    local aimOn=false; local currentTarget=nil; local lastSwitch=0; local lastTargetCheck=0
    local sessionStart=tick(); local sessionKills=0; local sessionPickups=0
    local lastHealthSnapshot={}; local isFiring=false; local savedShotRotation=nil; local originalDisplayName=nil

    task.spawn(function() while getgenv().BSS_Aim_Loaded do if CFG.HideName then pcall(function() if originalDisplayName==nil then originalDisplayName=LocalPlayer2.DisplayName end; LocalPlayer2.DisplayName=CFG.HideNameText or "..."; local char=LocalPlayer2.Character; if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.DisplayName=CFG.HideNameText or "..."; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end end end) else pcall(function() if originalDisplayName then LocalPlayer2.DisplayName=originalDisplayName; local char=LocalPlayer2.Character; if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.DisplayName=originalDisplayName; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer end end end end) end; task.wait(0.1) end end)

    local espScreenD=Instance.new("ScreenGui"); espScreenD.Name="BSS_FOV"; espScreenD.ResetOnSpawn=false; espScreenD.IgnoreGuiInset=true; espScreenD.DisplayOrder=90; espScreenD.Parent=getParentGui()
    local fovCircle=Instance.new("Frame"); fovCircle.Name="FOV"; fovCircle.BackgroundTransparency=1; fovCircle.AnchorPoint=Vector2.new(0.5,0.5); fovCircle.Position=UDim2.fromScale(0.5,0.5); fovCircle.Size=UDim2.fromOffset(CFG.FOVRadius*2,CFG.FOVRadius*2); fovCircle.Visible=false; fovCircle.ZIndex=100; fovCircle.Parent=espScreenD
    Instance.new("UICorner",fovCircle).CornerRadius=UDim.new(1,0)
    local fovStroke=Instance.new("UIStroke"); fovStroke.Color=C.accent; fovStroke.Thickness=2; fovStroke.Parent=fovCircle
    local hlContainer=Instance.new("ScreenGui"); hlContainer.Name="BSS_HL_Container"; hlContainer.ResetOnSpawn=false; hlContainer.IgnoreGuiInset=true; hlContainer.DisplayOrder=85; hlContainer.Parent=getParentGui()

    if IS_MOBILE then
        local ab=Instance.new("TextButton"); ab.Name="AimBtn"; ab.Size=UDim2.fromOffset(90,90); ab.Position=UDim2.new(0,20,1,-210); ab.BackgroundColor3=Color3.fromRGB(15,17,24); ab.BackgroundTransparency=0.2; ab.Text="AIM"; ab.TextColor3=C.accent; ab.TextSize=22; ab.Font=Enum.Font.GothamBold; ab.AutoButtonColor=false; ab.Active=true; ab.ZIndex=200; ab.Parent=espScreenD
        Instance.new("UICorner",ab).CornerRadius=UDim.new(1,0)
        local bs2=Instance.new("UIStroke"); bs2.Color=C.accent; bs2.Thickness=3; bs2.Parent=ab
        ab.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then aimOn=true; bs2.Color=C.aimOn; ab.TextColor3=C.aimOn end end)
        ab.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then aimOn=false; bs2.Color=C.accent; ab.TextColor3=C.accent end end)
    end

    local rayP=RaycastParams.new(); rayP.FilterType=Enum.RaycastFilterType.Exclude
    local function refreshFilter() local f={Camera}; if LocalPlayer2.Character then table.insert(f,LocalPlayer2.Character) end; rayP.FilterDescendantsInstances=f end
    refreshFilter(); LocalPlayer2.CharacterAdded:Connect(function() task.wait(0.4); refreshFilter() end)
    local function sameTeam(plr) if not CFG.TeamCheck then return false end return plr.Team==LocalPlayer2.Team end
    local function alive(plr) local c=plr.Character; if not c then return false end local h=c:FindFirstChildOfClass("Humanoid"); return h and h.Health>0 end
    local function visible(target,char) if not CFG.WallCheck then return true end local o=Camera.CFrame.Position; local d=target.Position-o; local hit=Workspace:Raycast(o,d,rayP); if not hit then return true end return hit.Instance and hit.Instance:IsDescendantOf(char) end
    local function getTargetWithScore() local candidates={}; local center=Camera.ViewportSize*0.5; for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer2 and not sameTeam(plr) and alive(plr) then local char=plr.Character; local part=char:FindFirstChild(CFG.TargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"); if part then local wp=part.Position; local d3=(Camera.CFrame.Position-wp).Magnitude; if d3<=CFG.MaxDistance then local sp,on=Camera:WorldToViewportPoint(wp); if on then local px=(Vector2.new(sp.X,sp.Y)-center).Magnitude; if px<=CFG.FOVRadius then table.insert(candidates,{plr=plr,part=part,score=(CFG.Priority=="dist") and d3 or px}) end end end end end end; table.sort(candidates,function(a,b) return a.score<b.score end); for i=1,math.min(3,#candidates) do local c=candidates[i]; if not CFG.WallCheck or visible(c.part,c.plr.Character) then return c.plr,c.part,c.score end end; return nil,nil,math.huge end
    local function targetDead() if not currentTarget or not currentTarget.Parent then return true end local char=currentTarget.Parent; local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then return true end if (Camera.CFrame.Position-currentTarget.Position).Magnitude>CFG.MaxDistance then return true end return false end
    local function targetPx() if not currentTarget then return math.huge end local center=Camera.ViewportSize*0.5; local sp,on=Camera:WorldToViewportPoint(currentTarget.Position); if not on then return math.huge end return (Vector2.new(sp.X,sp.Y)-center).Magnitude end

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

    UserInputService.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==CFG.HoldKey then aimOn=true end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.KeyCode==Enum.KeyCode.ButtonR2 then isFiring=true; if CFG.NoRecoil then savedShotRotation=Camera.CFrame.Rotation end end if i.KeyCode==CFG.PanicKey then aimOn=false; CFG.Enabled=false; notify("PANIC","Todo desactivado",3) end end)
    UserInputService.InputEnded:Connect(function(i,gp) if gp then return end if i.KeyCode==CFG.HoldKey then aimOn=false end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.KeyCode==Enum.KeyCode.ButtonR2 then isFiring=false; savedShotRotation=nil end end)

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
                        if not pESP[plr] or not pESP[plr].Parent then local hl=Instance.new("Highlight"); hl.Name="BSS_HL_"..plr.UserId; hl.FillTransparency=0.6; hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=char; hl.Parent=hlContainer; pESP[plr]=hl end
                        local hpR=math.clamp(hum.Health/hum.MaxHealth,0,1); pESP[plr].FillColor=hpR>0.6 and Color3.fromRGB(0,255,127) or hpR>0.3 and Color3.fromRGB(255,215,0) or Color3.fromRGB(255,0,0)
                        if CFG.WeaponESP then local we=getBestWeapon(plr); pESP[plr].OutlineColor=we and we.col or Color3.fromRGB(255,255,255) else pESP[plr].OutlineColor=Color3.fromRGB(255,255,255) end
                    else if pESP[plr] then pESP[plr]:Destroy(); pESP[plr]=nil end end
                    if dist<=CFG.TextDist and CFG.PlayerESP and (CFG.NameESP or CFG.HealthESP or CFG.WeaponESP) then
                        local refs=_espRef[plr]; if not tESP[plr] or not tESP[plr].Parent or not refs then local bb,r=makeBB(head); tESP[plr]=bb; _espRef[plr]=r; refs=r end
                        local sM=1+(math.clamp(dist/CFG.TextDist,0,1)*0.5); tESP[plr].Size=UDim2.fromOffset(160*sM,50*sM); tESP[plr].StudsOffsetWorldSpace=Vector3.new(0,3*sM,0)
                        if refs.name then refs.name.Visible=CFG.NameESP; refs.name.Text=plr.Name end
                        if refs.hp and _espSub==0 then refs.hp.Visible=CFG.HealthESP; if CFG.HealthESP then refs.hp.Text=string.format("%d HP",math.floor(hum.Health)); local hpR=math.clamp(hum.Health/hum.MaxHealth,0,1); refs.hp.TextColor3=hpR>0.6 and Color3.fromRGB(0,255,127) or hpR>0.3 and Color3.fromRGB(255,215,0) or Color3.fromRGB(255,0,0) end end
                        if refs.wep and CFG.WeaponESP then local we=getBestWeapon(plr); if we then refs.frame.Visible=true; refs.wep.Text=string.format("[%s]",string.upper(we.label or "?")); refs.wep.TextColor3=we.col or C.gold else refs.frame.Visible=false end elseif refs.frame then refs.frame.Visible=false end
                    else if tESP[plr] then tESP[plr]:Destroy(); tESP[plr]=nil; _espRef[plr]=nil end end
                else clearESP(plr) end
            else clearESP(plr) end
        end
    end

    local lastPickup=0
    local function grabItem(m) local char=LocalPlayer2.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end local part=m:FindFirstChild("PickUpZone") or m:FindFirstChild("CashPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart",true); if not part then return false end local d=(hrp.Position-part.Position).Magnitude; if d>math.min(CFG.PickupRadius*2,60) then return false end local n=m.Name:lower(); local ok2=false; if n:find("money") or n:find("cash") then ok2=CFG.PickupMoney elseif n:find("taser") or n:find("gun") or n:find("ak") or n:find("pistol") or n:find("rifle") then ok2=CFG.PickupWeapons elseif n:find("food") or n:find("burger") or n:find("pizza") then ok2=CFG.PickupFood elseif n:find("tool") or n:find("wrench") then ok2=CFG.PickupTools else ok2=true end; if ok2 then pcall(function() if firetouchinterest then firetouchinterest(hrp,part,0); task.defer(function() firetouchinterest(hrp,part,1) end) end end); return true end return false end
    task.spawn(function() local folder=Workspace:WaitForChild("DroppedItems",10); if folder then folder.ChildAdded:Connect(function(m) if getgenv().BSS_Aim_Loaded and CFG.AutoPickup then task.wait(math.random(5,20)*0.01); if grabItem(m) then sessionPickups+=1 end end end) end end)
    local function tryPickupLoop() if not CFG.AutoPickup then return end local now=tick(); if now-lastPickup<(CFG.PickupDelay or 0.15) then return end local char=LocalPlayer2.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end local folder=Workspace:FindFirstChild("DroppedItems"); if not folder then return end local picked=false; for _,m in ipairs(folder:GetChildren()) do local part=m:FindFirstChild("PickUpZone") or m:FindFirstChild("CashPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart",true); if part then local d=(hrp.Position-part.Position).Magnitude; if d<math.min(CFG.PickupRadius,30) then if grabItem(m) then picked=true; sessionPickups+=1 end end end end; if picked then lastPickup=now end end
    local function trackKills() for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer2 then local char=plr.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then local last=lastHealthSnapshot[plr]; local cur=hum.Health; if last and last>0 and cur<=0 then sessionKills+=1 end; lastHealthSnapshot[plr]=cur end end end end

    local function newI(c,p,ch) local i=Instance.new(c); for k,v in pairs(p or {}) do i[k]=v end; for _,x in ipairs(ch or {}) do x.Parent=i end; return i end
    local function cornerI(p,r) return newI("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p}) end
    local function strokeI(p,col) return newI("UIStroke",{Color=col or C.accent,Thickness=1.4,Parent=p}) end

    local sgD=newI("ScreenGui",{Name="BSS_Aim_Ultra",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=getParentGui()})
    local W,H=420,560; local FL=11; local FS=10; local RH=34; local TH=30
    local panelD=newI("Frame",{Size=UDim2.fromOffset(W,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2),BackgroundColor3=C.bg,BorderSizePixel=0,Parent=sgD}); cornerI(panelD,16); strokeI(panelD,C.border)
    local headerD=newI("Frame",{Size=UDim2.new(1,0,0,44),Position=UDim2.new(0,0,0,4),BackgroundColor3=Color3.fromRGB(10,10,12),BorderSizePixel=0,Parent=panelD})
    local logoD=newI("Frame",{Size=UDim2.fromOffset(30,30),Position=UDim2.new(0,12,0.5,-15),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Parent=headerD}); cornerI(logoD,9)
    local li=Instance.new("ImageLabel"); li.AnchorPoint=Vector2.new(0.5,0.5); li.Position=UDim2.fromScale(0.5,0.5); li.Size=UDim2.fromScale(0.72,0.72); li.BackgroundTransparency=1; li.Image=ICON_SPLASH; li.ImageColor3=Color3.fromRGB(10,10,12); li.ScaleType=Enum.ScaleType.Fit; li.Parent=logoD
    newI("TextLabel",{Size=UDim2.new(0,220,0,16),Position=UDim2.new(0,52,0,5),BackgroundTransparency=1,Text="BSS-AIM ULTRA · DISIMULATED",TextColor3=Color3.fromRGB(255,255,255),TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=headerD})
    newI("TextLabel",{Size=UDim2.new(0,220,0,12),Position=UDim2.new(0,52,0,21),BackgroundTransparency=1,Text=(IS_PC and "PC" or "Mobile").."  ·  v13.7 STEALTH",TextColor3=C.accent,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=headerD})
    local function iconBtnD(txt,xOff) local b=newI("TextButton",{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,xOff,0.5,-15),BackgroundColor3=C.bg3,BorderSizePixel=0,Text=txt,TextColor3=C.accent,TextSize=16,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,Parent=headerD,ZIndex=2}); cornerI(b,9); strokeI(b,C.border); return b end
    local minBtnD=iconBtnD("-",-76); local closeBtnD=iconBtnD("x",-40)
    local tabsFrameD=newI("Frame",{Size=UDim2.new(1,-24,0,TH),Position=UDim2.new(0,12,0,56),BackgroundColor3=C.bg2,BorderSizePixel=0,Parent=panelD}); cornerI(tabsFrameD,10); strokeI(tabsFrameD,C.border)
    newI("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Parent=tabsFrameD})
    local contentD=newI("Frame",{Size=UDim2.new(1,-24,1,-140),Position=UDim2.new(0,12,0,94),BackgroundTransparency=1,Parent=panelD})
    local pagesD={}; local tabBtnsD={}
    local tabUnderlineD=newI("Frame",{Size=UDim2.new(0,0,0,2),Position=UDim2.new(0,0,1,-3),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=tabsFrameD}); cornerI(tabUnderlineD,2)
    local function selectTabD(name) for k,p in pairs(pagesD) do p.Visible=(k==name) end; for k,b in pairs(tabBtnsD) do TweenService:Create(b,TweenInfo.new(0.15),{TextColor3=(k==name) and C.accent or C.muted}):Play() end; local active=tabBtnsD[name]; if active then TweenService:Create(tabUnderlineD,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,active.AbsolutePosition.X-tabsFrameD.AbsolutePosition.X,1,-3),Size=UDim2.new(0,active.AbsoluteSize.X,0,2)}):Play() end end
    for i,tname in ipairs({"AIM","ESP","PICKUP","HUD","SAFE"}) do
        local btn=newI("TextButton",{Size=UDim2.new(1/5,0,1,0),BackgroundTransparency=1,Text=tname,TextColor3=C.muted,TextSize=FS,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,LayoutOrder=i,Parent=tabsFrameD}); tabBtnsD[tname]=btn; btn.MouseButton1Click:Connect(function() selectTabD(tname) end)
        local page=newI("ScrollingFrame",{Name=tname.."_Page",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=contentD})
        newI("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=page}); newI("UIPadding",{PaddingBottom=UDim.new(0,0),PaddingRight=UDim.new(0,6),Parent=page})
        pagesD[tname]=page
    end
    local orderD=0; local function nextOrderD() orderD=orderD+1; return orderD end
    local function sectionD(page,label) local wrap=newI("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=nextOrderD(),Parent=page}); local bar=newI("Frame",{Size=UDim2.new(0,3,0,14),Position=UDim2.new(0,0,0.5,-7),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=wrap}); cornerI(bar,2); newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,11,0,0),Size=UDim2.new(1,-11,1,0),Font=Enum.Font.GothamBold,Text=label,TextColor3=C.fg,TextSize=FL,TextXAlignment=Enum.TextXAlignment.Left,Parent=wrap}) end
    local function toggleD(page,label,key,onChange) local row=newI("Frame",{Size=UDim2.new(1,0,0,RH),BackgroundColor3=C.bg2,BorderSizePixel=0,LayoutOrder=nextOrderD(),Parent=page}); cornerI(row,9); local rs=strokeI(row,C.border); newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-60,1,0),Font=Enum.Font.GothamMedium,Text=label,TextColor3=C.fg,TextSize=FL,TextXAlignment=Enum.TextXAlignment.Left,Parent=row}); local track=newI("Frame",{Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-50,0.5,-10),BackgroundColor3=C.bg4,BorderSizePixel=0,Parent=row}); cornerI(track,10); local knob=newI("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.new(0,3,0.5,-7),BackgroundColor3=C.fg,BorderSizePixel=0,Parent=track}); cornerI(knob,7); local function rd(anim) local on=CFG[key]; local x=on and 21 or 3; local col=on and C.accent or C.bg4; if anim then TweenService:Create(track,TweenInfo.new(0.18),{BackgroundColor3=col}):Play(); TweenService:Create(knob,TweenInfo.new(0.18),{Position=UDim2.new(0,x,0.5,-7)}):Play(); TweenService:Create(rs,TweenInfo.new(0.18),{Color=on and C.accent or C.border}):Play() else track.BackgroundColor3=col; knob.Position=UDim2.new(0,x,0.5,-7); rs.Color=on and C.accent or C.border end end; local b2=newI("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Active=true,Parent=row}); b2.MouseButton1Click:Connect(function() CFG[key]=not CFG[key]; rd(true); scheduleSave(); if onChange then onChange(CFG[key]) end end); rd(false) end
    local function sliderD(page,label,key,minV,maxV,isFloat,onChange) local row=newI("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.bg2,BorderSizePixel=0,LayoutOrder=nextOrderD(),Parent=page}); cornerI(row,9); strokeI(row,C.border); newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,6),Size=UDim2.new(1,-76,0,13),Font=Enum.Font.GothamMedium,Text=label,TextColor3=C.fg,TextSize=FL,TextXAlignment=Enum.TextXAlignment.Left,Parent=row}); local vl=newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(1,-76,0,6),Size=UDim2.new(0,64,0,13),Font=Enum.Font.GothamBold,Text="",TextColor3=C.accent,TextSize=FL,TextXAlignment=Enum.TextXAlignment.Right,Parent=row}); local t2=newI("Frame",{Size=UDim2.new(1,-24,0,5),Position=UDim2.new(0,12,1,-16),BackgroundColor3=C.bg4,BorderSizePixel=0,Parent=row}); cornerI(t2,3); local f2=newI("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=t2}); cornerI(f2,3); local k2=newI("Frame",{Size=UDim2.fromOffset(12,12),Position=UDim2.new(0,0,0.5,-6),BackgroundColor3=C.fg,BorderSizePixel=0,Parent=t2}); cornerI(k2,6); local function rs2() local v=CFG[key]; local a=math.clamp((v-minV)/(maxV-minV),0,1); f2.Size=UDim2.new(a,0,1,0); k2.Position=UDim2.new(a,-6,0.5,-6); vl.Text=isFloat and string.format("%.2f",v) or tostring(math.floor(v)) end; local drg=false; local function sfx(x) local tl=t2.AbsolutePosition.X; local tw=t2.AbsoluteSize.X; if tw<=0 then return end local a=math.clamp((x-tl)/tw,0,1); local v=minV+(maxV-minV)*a; if not isFloat then v=math.floor(v+0.5) end CFG[key]=v; rs2(); scheduleSave(); if onChange then onChange(v) end end; local h2=newI("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Active=true,Parent=row}); h2.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drg=true; sfx(inp.Position.X) end end); UserInputService.InputChanged:Connect(function(inp) if drg and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then sfx(inp.Position.X) end end); UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drg=false end end); rs2() end
    local function keybindRowD(page,label,key) local row=newI("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.bg2,BorderSizePixel=0,LayoutOrder=nextOrderD(),Parent=page}); cornerI(row,9); strokeI(row,C.border); newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-116,1,0),Font=Enum.Font.GothamMedium,Text=label,TextColor3=C.fg,TextSize=FL,TextXAlignment=Enum.TextXAlignment.Left,Parent=row}); local b3=newI("TextButton",{Size=UDim2.fromOffset(96,26),Position=UDim2.new(1,-104,0.5,-13),BackgroundColor3=C.bg3,BorderSizePixel=0,Text="",TextColor3=C.accent,TextSize=FS,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,Parent=row}); cornerI(b3,7); strokeI(b3,C.border); local cap=false; local function rk() local cur=CFG[key]; local nm="?"; if typeof(cur)=="EnumItem" then nm=cur.Name end b3.Text=cap and "..." or nm; b3.TextColor3=cap and C.accent2 or C.accent end; b3.MouseButton1Click:Connect(function() cap=not cap; rk() end); UserInputService.InputBegan:Connect(function(inp,gp) if gp or not cap then return end if inp.UserInputType==Enum.UserInputType.Keyboard then CFG[key]=inp.KeyCode end cap=false; rk(); scheduleSave() end); rk() end
    local function actionBtnD(page,label,color,onClick) local b=newI("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=color or C.bg3,BorderSizePixel=0,Font=Enum.Font.GothamBold,Text=label,TextColor3=C.fg,TextSize=FL,AutoButtonColor=false,Active=true,LayoutOrder=nextOrderD(),Parent=page}); cornerI(b,9); strokeI(b,color or C.border); b.MouseButton1Click:Connect(onClick) end
    local BPARTS={"Head","HumanoidRootPart","UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}
    local function partPickerD(page) local row=newI("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=C.bg2,BorderSizePixel=0,LayoutOrder=nextOrderD(),Parent=page}); cornerI(row,9); strokeI(row,C.border); newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(.42,0,1,0),Font=Enum.Font.GothamMedium,Text="Objetivo",TextColor3=C.fg,TextSize=FL,TextXAlignment=Enum.TextXAlignment.Left,Parent=row}); local pvD=newI("TextButton",{Size=UDim2.fromOffset(22,22),Position=UDim2.new(.42,0,.5,-11),BackgroundColor3=C.bg3,Text="‹",TextColor3=C.accent,TextSize=14,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,BorderSizePixel=0,Parent=row}); cornerI(pvD,6); local plD=newI("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(.42,26,0,0),Size=UDim2.new(0,105,1,0),Font=Enum.Font.GothamBold,Text=CFG.TargetPart,TextColor3=C.accent,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row}); local nxD=newI("TextButton",{Size=UDim2.fromOffset(22,22),Position=UDim2.new(1,-32,.5,-11),BackgroundColor3=C.bg3,Text="›",TextColor3=C.accent,TextSize=14,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,BorderSizePixel=0,Parent=row}); cornerI(nxD,6); local function ciD() for i,v in ipairs(BPARTS) do if v==CFG.TargetPart then return i end end return 1 end; local function siD(i) i=((i-1)%#BPARTS)+1; CFG.TargetPart=BPARTS[i]; plD.Text=CFG.TargetPart; currentTarget=nil; scheduleSave() end; pvD.MouseButton1Click:Connect(function() siD(ciD()-1) end); nxD.MouseButton1Click:Connect(function() siD(ciD()+1) end) end

    -- TABS DISIMULATED
    local aP=pagesD["AIM"]; sectionD(aP,"AIMBOT"); toggleD(aP,"Activar","Enabled"); toggleD(aP,"Camera Lock (LERP)","CameraLock"); toggleD(aP,"No Recoil","NoRecoil"); sliderD(aP,"FOV","FOV",30,400,false,function(v) CFG.FOVRadius=v end); sliderD(aP,"Dist. max","MaxDistance",100,1500,false); sliderD(aP,"Lerp speed","CameraLerpSpeed",0.05,1.0,true); keybindRowD(aP,"Apuntar (Hold)","HoldKey"); sectionD(aP,"FILTROS"); toggleD(aP,"Wall check","WallCheck"); if IS_PC then toggleD(aP,"Silent aim","SilentAim") end; sectionD(aP,"OBJETIVO"); partPickerD(aP)
    local eP=pagesD["ESP"]; sectionD(eP,"VISUAL"); toggleD(eP,"ESP Players","PlayerESP"); toggleD(eP,"Cuerpo","ChamsESP"); toggleD(eP,"Nombre","NameESP"); toggleD(eP,"HP","HealthESP"); toggleD(eP,"Arma","WeaponESP"); sliderD(eP,"Rango ESP","MaxESP",50,10000,false); sliderD(eP,"Rango Texto","TextDist",100,5000,false)
    local pkP=pagesD["PICKUP"]; sectionD(pkP,"STEALTH PICKUP"); toggleD(pkP,"Activar","AutoPickup"); sliderD(pkP,"Radio (máx 30)","PickupRadius",5,30,false); sliderD(pkP,"Delay","PickupDelay",0.05,0.5,true); sectionD(pkP,"CATEGORIAS"); toggleD(pkP,"Money","PickupMoney"); toggleD(pkP,"Armas","PickupWeapons"); toggleD(pkP,"Comida","PickupFood"); toggleD(pkP,"Herramientas","PickupTools")
    local hP=pagesD["HUD"]; sectionD(hP,"HUD"); toggleD(hP,"Watermark","HUDWatermark"); toggleD(hP,"Stats","HUDFPS"); sectionD(hP,"PRIVACIDAD"); toggleD(hP,"Ocultar nombre","HideName"); toggleD(hP,"Ocultar leaderboard","HideLeaderboard")
    local sP=pagesD["SAFE"]; sectionD(sP,"CONFIG"); actionBtnD(sP,"Config RECOMENDADA",C.accent,function() local d=defaultCfg(); for k,v in pairs(d) do CFG[k]=v end; CFG.HoldKey=resolveKey("E",Enum.KeyCode.E); CFG.PanelKey=resolveKey("L",Enum.KeyCode.L); CFG.CloseKey=resolveKey("M",Enum.KeyCode.M); saveConfigTo(CONFIG_FILE,CFG); notify("Config","Recomendada cargada",4) end)
    sectionD(sP,"PANEL"); keybindRowD(sP,"Abrir","PanelKey"); keybindRowD(sP,"Cerrar","CloseKey")
    actionBtnD(sP,"Reiniciar",C.danger,function() pcall(function() if originalDisplayName then LocalPlayer2.DisplayName=originalDisplayName end end); pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end); espScreenD:Destroy(); sgD:Destroy(); hlContainer:Destroy(); for plr in pairs(pESP) do clearESP(plr) end; getgenv().BSS_Aim_Loaded=false end)
    selectTabD("AIM")

    -- DRAG
    local function makeDragD(f,h) local d,s,p; h.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true; s=i.Position; p=f.Position end end); UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local dl=i.Position-s; f.Position=UDim2.new(p.X.Scale,p.X.Offset+dl.X,p.Y.Scale,p.Y.Offset+dl.Y) end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end) end
    makeDragD(panelD,headerD)

    local mBD=newI("TextButton",{Size=UDim2.fromOffset(56,56),Position=UDim2.new(0.5,-28,0,20),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Text="",AutoButtonColor=false,Active=true,Visible=false,ZIndex=200,Parent=sgD}); cornerI(mBD,28)
    local mID=Instance.new("ImageLabel"); mID.AnchorPoint=Vector2.new(0.5,0.5); mID.Position=UDim2.fromScale(0.5,0.5); mID.Size=UDim2.fromScale(0.72,0.72); mID.BackgroundTransparency=1; mID.Image=ICON_SPLASH; mID.ImageColor3=Color3.fromRGB(10,10,12); mID.ScaleType=Enum.ScaleType.Fit; mID.Parent=mBD
    mBD.MouseButton1Click:Connect(function() panelD.Visible=true; panelD.Size=UDim2.fromOffset(1,1); panelD.Position=UDim2.new(0.5,-W/2,0.5,-H/2); TweenService:Create(panelD,TweenInfo.new(0.24,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(W,H)}):Play(); mBD.Visible=false end)
    local function openPanelD() if not panelD.Visible then mBD.Visible=false; panelD.Visible=true; panelD.Size=UDim2.fromOffset(1,1); panelD.Position=UDim2.new(0.5,-W/2,0.5,-H/2); TweenService:Create(panelD,TweenInfo.new(0.24,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(W,H)}):Play() end end
    local function closePanelD() if panelD.Visible then local tw=TweenService:Create(panelD,TweenInfo.new(0.16,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.fromOffset(1,1)}); tw:Play(); tw.Completed:Connect(function() panelD.Visible=false; panelD.Size=UDim2.fromOffset(W,H); mBD.Visible=true; mBD.Size=UDim2.fromOffset(1,1); TweenService:Create(mBD,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(56,56)}):Play() end) end end
    minBtnD.MouseButton1Click:Connect(closePanelD)
    closeBtnD.MouseButton1Click:Connect(function() pcall(function() if originalDisplayName then LocalPlayer2.DisplayName=originalDisplayName end end); pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end); espScreenD:Destroy(); sgD:Destroy(); hlContainer:Destroy(); for plr in pairs(pESP) do clearESP(plr) end; getgenv().BSS_Aim_Loaded=false end)
    UserInputService.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==CFG.PanelKey then openPanelD() end if i.KeyCode==CFG.CloseKey then closePanelD() end end)

    -- HUD
    local hudScreenD=Instance.new("ScreenGui"); hudScreenD.Name="BSS_HUD_Ultra"; hudScreenD.ResetOnSpawn=false; hudScreenD.IgnoreGuiInset=true; hudScreenD.DisplayOrder=95; hudScreenD.Parent=getParentGui()
    local wmD=Instance.new("Frame"); wmD.Size=UDim2.fromOffset(260,26); wmD.Position=UDim2.new(0,20,0,20); wmD.BackgroundColor3=C.bg; wmD.BackgroundTransparency=0.25; wmD.BorderSizePixel=0; wmD.ZIndex=150; wmD.Parent=hudScreenD; Instance.new("UICorner",wmD).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",wmD).Color=C.accent
    local wmLblD=Instance.new("TextLabel"); wmLblD.Size=UDim2.new(1,-16,1,0); wmLblD.Position=UDim2.new(0,10,0,0); wmLblD.BackgroundTransparency=1; wmLblD.Font=Enum.Font.GothamBold; wmLblD.TextSize=12; wmLblD.TextColor3=C.accent; wmLblD.TextXAlignment=Enum.TextXAlignment.Left; wmLblD.Text="BSS-Aim ULTRA v13.7 DISIMULATED"; wmLblD.Parent=wmD
    local stHUD=Instance.new("Frame"); stHUD.Size=UDim2.fromOffset(180,80); stHUD.Position=UDim2.new(1,-200,0,60); stHUD.BackgroundColor3=C.bg; stHUD.BackgroundTransparency=0.25; stHUD.BorderSizePixel=0; stHUD.ZIndex=150; stHUD.Parent=hudScreenD; Instance.new("UICorner",stHUD).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",stHUD).Color=C.accent2
    local stLblD=Instance.new("TextLabel"); stLblD.Size=UDim2.new(1,-16,1,-12); stLblD.Position=UDim2.new(0,10,0,6); stLblD.BackgroundTransparency=1; stLblD.Font=Enum.Font.Code; stLblD.TextSize=12; stLblD.TextColor3=C.fg; stLblD.TextXAlignment=Enum.TextXAlignment.Left; stLblD.TextYAlignment=Enum.TextYAlignment.Top; stLblD.TextWrapped=true; stLblD.Text=""; stLblD.Parent=stHUD
    local fpsCountD=0; local fpsTimerD=tick(); local currentFPSD=60

    task.spawn(function() while getgenv().BSS_Aim_Loaded do pcall(updateESP); pcall(tryPickupLoop); pcall(trackKills); task.wait(0.1) end end)
    task.spawn(function() while getgenv().BSS_Aim_Loaded do if CFG.HUDWatermark then wmD.Visible=true else wmD.Visible=false end task.wait(0.5) end end)

    pcall(function() RunService:UnbindFromRenderStep("BSS_Aim_Ultra_Loop") end)
    RunService:BindToRenderStep("BSS_Aim_Ultra_Loop",Enum.RenderPriority.Camera.Value+1,function(dt)
        fpsCountD+=1; if tick()-fpsTimerD>=0.5 then currentFPSD=math.floor(fpsCountD/(tick()-fpsTimerD)); fpsCountD=0; fpsTimerD=tick() end
        if CFG.HUDFPS then
            stHUD.Visible=true
            stLblD.Text=string.format("FPS: %d\nKills: %d\nPickups: %d\nTarget: %s",currentFPSD,sessionKills,sessionPickups,currentTarget and currentTarget.Parent and currentTarget.Parent.Name or "none")
        else stHUD.Visible=false end
        fovCircle.Visible=CFG.DrawFOV and CFG.Enabled
        fovCircle.Size=UDim2.fromOffset(CFG.FOVRadius*2,CFG.FOVRadius*2)
        if not CFG.Enabled then currentTarget=nil; return end
        if tick()-lastTargetCheck>=0.05 then
            lastTargetCheck=tick()
            if not currentTarget or targetDead() or targetPx()>CFG.FOVRadius then
                local plr,part=getTargetWithScore()
                if plr and part then currentTarget=part else currentTarget=nil end
            end
        end
        if currentTarget and aimOn and CFG.CameraLock then
            local goal=CFrame.new(Camera.CFrame.Position,currentTarget.Position)
            Camera.CFrame=Camera.CFrame:Lerp(goal,CFG.CameraLerpSpeed or 0.18)
        end
        if CFG.NoRecoil and isFiring and savedShotRotation then
            Camera.CFrame=CFrame.new(Camera.CFrame.Position)*savedShotRotation
        end
    end)
end

-- ============================================================================
-- STRONG — SuperHub BlockSpin COMPLETO (inlined)
-- ============================================================================
local function launchStrong()
    closeSel(); task.wait(0.25)
    pcall(function() local p=getParentGui(); if p then for _,v in ipairs(p:GetChildren()) do if tostring(v.Name):match("^BSS_") or tostring(v.Name)=="zhXUI" then v:Destroy() end end end end)

do
    local _Players = game:GetService("Players")
    local _TweenService = game:GetService("TweenService")
    local _ReplicatedStorage = game:GetService("ReplicatedStorage")
    local _player = _Players.LocalPlayer
    local _playerGui = _player:WaitForChild("PlayerGui")
    local _Net = require(_ReplicatedStorage.Modules.Core.Net)

    local FONT = Enum.Font.GothamBold

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "zhXUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = _playerGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,320,0,120)
    main.Position = UDim2.fromScale(0.5,0.5)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = Color3.fromRGB(120,0,255)
    main.BackgroundTransparency = 0.2
    main.BorderSizePixel = 0
    main.Parent = screenGui
    Instance.new("UICorner",main).CornerRadius = UDim.new(0,14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(155,55,255)
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,34)
    title.Position = UDim2.new(0,0,0,4)
    title.BackgroundTransparency = 1
    title.Text = "Ez tset god mode"
    title.Font = FONT
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Parent = main

    local function makeButton(txt,x)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,130,0,38)
        btn.Position = UDim2.new(0,x,0,62)
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        btn.BackgroundTransparency = 0.35
        btn.Text = txt
        btn.Font = FONT
        btn.TextSize = 16
        btn.TextColor3 = Color3.fromRGB(30,30,30)
        btn.AutoButtonColor = false
        btn.Parent = main
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,10)
        return btn
    end

    local normalBtn = makeButton("Normal mode", 20)
    local godBtn = makeButton("God mode", 170)

    local Done = false

    local function destroyUI()
        local tw = _TweenService:Create(main, TweenInfo.new(0.22), {
            Size = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Wait()
        screenGui:Destroy()
    end

    local function pressButton(guiObject)
        if not guiObject then return end
        pcall(function() firesignal(guiObject.MouseButton1Click) end)
        pcall(function() firesignal(guiObject.Activated) end)
    end

    normalBtn.MouseButton1Click:Connect(function()
        destroyUI()
        task.spawn(function()
            task.wait(0.5)
            local splashGui = _playerGui:FindFirstChild("SplashScreenGui")
            if splashGui then
                local frame = splashGui:FindFirstChild("Frame")
                local playButton = frame and frame:FindFirstChild("PlayButton")
                pressButton(playButton)
            end
            Done = true
            local characterCreator = _playerGui:FindFirstChild("CharacterCreator")
            if characterCreator then
                local menuFrame = characterCreator:FindFirstChild("MenuFrame")
                local skipButton = menuFrame and menuFrame:FindFirstChild("AvatarMenuSkipButton")
                pressButton(skipButton)
            end
        end)
    end)

    godBtn.MouseButton1Click:Connect(function()
        destroyUI()
        task.spawn(function()
            pcall(function()
                if not _G.Bypass then
                    local func = getupvalue(_Net.get, 2)
                    if func then
                        setconstant(func, 3, "KUYIENGOKUYIENGO")
                        setconstant(func, 4, "KUYIENGOKUYIENGO")
                    end
                    _G.Bypass = true
                end
            end)

            pcall(function()
                local old
                old = hookfunction(_Net.send, function(...)
                    local d = {...}
                    if d[1] == "leave_character_creator" or d[1] == "player_created_outfit" then
                        return nil
                    end
                    return old(...)
                end)
            end)

            task.wait(0.5)
            local splashGui = _playerGui:FindFirstChild("SplashScreenGui")
            if splashGui then
                local frame = splashGui:FindFirstChild("Frame")
                local playButton = frame and frame:FindFirstChild("PlayButton")
                pressButton(playButton)
            end

            task.wait(0.5)
            local characterCreator = _playerGui:FindFirstChild("CharacterCreator")
            if characterCreator then
                local menuFrame = characterCreator:FindFirstChild("MenuFrame")
                local skipButton = menuFrame and menuFrame:FindFirstChild("AvatarMenuSkipButton")
                pressButton(skipButton)
            end

            task.wait(2.5)
            pcall(function()
                replicatesignal(game.Players.LocalPlayer.Kill)
            end)
            task.wait(7)
            pcall(function()
                _Net.send("death_screen_request_respawn")
            end)
            Done = true
        end)
    end)

    repeat task.wait() until Done
end

local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local UserInputService    = game:GetService("UserInputService")
local TweenService        = game:GetService("TweenService")
local Debris              = game:GetService("Debris")
local Workspace           = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")

local Remotes, Util, BuyPromptUI, EmotesUI, EmotesList, CoreUI, CharModule, Items, MeleeItems
pcall(function() Remotes = ReplicatedStorage:WaitForChild("Remotes", 5) end)
pcall(function() Util = require(ReplicatedStorage.Modules.Core.Util) end)
pcall(function() BuyPromptUI = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI) end)
pcall(function() EmotesUI = require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI) end)
pcall(function() EmotesList = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList) end)
pcall(function() CoreUI = require(ReplicatedStorage.Modules.Core.UI) end)
pcall(function() CharModule = require(ReplicatedStorage.Modules.Core.Char) end)
pcall(function()
    Items = ReplicatedStorage:WaitForChild("Items", 5)
    MeleeItems = Items and Items:WaitForChild("melee", 5)
end)

local LocalPlayer  = Players.LocalPlayer
local Character    = LocalPlayer.Character
local Humanoid     = Character and Character:FindFirstChild("Humanoid")
local HRP          = Character and Character:FindFirstChild("HumanoidRootPart")
local Camera       = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")

task.spawn(function()
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    Humanoid = Character:WaitForChild("Humanoid")
    HRP = Character:WaitForChild("HumanoidRootPart")
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart")
end)

local isMobile        = false
local DroppedItems    = Workspace:WaitForChild("DroppedItems")
local itemDrawings    = {}
local espData         = {}
local WeaponRegistry  = {}
local PlayerBillboards = {}
local highlightTable  = {}
local excludedPlayers = {}
local itemPickupTrack = {}
local originalAttribs = {}

local silentAimEnabled    = false
local redLineLockEnabled  = false
local fovRadius           = 9999
local aimTarget           = nil
local shotMultiplier      = 1
local autoShootEnabled    = false
local autoReloadEnabled   = false
local autoShootInterval   = 0.02
local autoShootBurst      = 3
local nameESPEnabled      = false
local distanceESPEnabled  = false
local healthESPEnabled    = false
local inventoryESPEnabled = false
local highlightEnabled    = false
local walkSpeedEnabled    = false
local speedMultiplier     = 0.05
local jumpPowerEnabled    = false
local infiniteStaminaEnabled = false
local antiLockEnabled     = false
local rapidFireEnabled    = false
local rapidFireRate       = 0.01
local _rapidFireRunning   = false
local antiKillEnabled     = false
local autoPickupEnabled   = false
local antiRagdollEnabled  = false
local autoRespawnEnabled  = false
local autoFinishEnabled   = false
local meleeAuraEnabled    = false
local autoAttackEnabled   = false
local skipCrateEnabled    = false
local _snap = { enabled = false, active = false, y = nil, originY = nil, depth = 10, pos = nil, flickering = false }


function isInCameraView(camera, object)
    if object:IsA("BasePart") then
        local objectPosition = object.Position
        local screenPosition, isOnScreen = camera:WorldToViewportPoint(objectPosition)
        return isOnScreen
    end
    return false
end

function loadVisibleObjects(camera, objects)
    for _, object in pairs(objects) do
        if isInCameraView(camera, object) then
            object.Transparency = 0
        else
            object.Transparency = 1
        end
    end
end

local Objects = workspace:GetDescendants()

local function IsAlive(model)
    if not model then return false end
    local Humanoids = model:FindFirstChildOfClass('Humanoid')
    if not Humanoids then return false end
    local RootParts = model:FindFirstChild('HumanoidRootPart')
    if not RootParts then return false end
    return Humanoids.Health > 0
end

local sendEventCounter = 0
local sendFuncCounter  = 0
local smoothTarget    = Vector3.new()
local smoothFactor    = 0.75
local fovCircle       = nil
local redLine         = Drawing.new("Line")
redLine.Thickness     = 1
redLine.Color         = Color3.fromRGB(255, 50, 50)
redLine.Transparency  = 1
redLine.Visible       = false

local getEnv = (type(getgenv) == "function" and getgenv) or function() return _G end

getEnv().Sky        = false
getEnv().SkyAmount  = 1500

local RarityColors = {
    Common    = Color3.fromRGB(255, 255, 255),
    Uncommon  = Color3.fromRGB(99,  255, 52),
    Rare      = Color3.fromRGB(51,  170, 255),
    Epic      = Color3.fromRGB(237, 44,  255),
    Legendary = Color3.fromRGB(255, 150, 0),
    Omega     = Color3.fromRGB(255, 20,  51),
}

local Counter
pcall(function()
    for _, v in ipairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "event") and rawget(v, "func") then
            Counter = v
            break
        end
    end
end)

local WindUI
pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

local Icons
pcall(function()
    Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua"))()
    if Icons then
        Icons.SetIconsType("lucide")
    end
end)

local Window
if WindUI then
    Window = WindUI:CreateWindow({
        Title      = "SUPER HUB |  Block Spin",
        Icon = "",
        Author     = "Block spin | Paid",
        Folder     = "superhub",
        Size       = UDim2.fromOffset(650, 400),
        Theme      = "Light",
        Transparent = true,
        Resizable  = true,
        KeyCode    = Enum.KeyCode.G,
    })

    Window:Tag({
        Title  = "v1.0",
        Color  = Color3.fromHex("#30ff6a"),
        Radius = 12,
    })
else
    local tabStub = {
        Section  = function() end,
        Toggle   = function() return { OnChanged = function() end } end,
        Slider   = function() return { OnChanged = function() end } end,
        Button   = function() end,
        Input    = function() return {} end,
        Divider  = function() end,
        Dropdown = function() return { Refresh = function() end } end,
    }
    Window = {
        Tab = function()
            return tabStub
        end,
        ConfigManager = {
            Init = function() end,
            CreateConfig = function()
                return {
                    Register = function() end,
                    Load = function() end,
                    Save = function() end,
                    Delete = function() end,
                }
            end
        }
    }
end

local ConfigManager = Window.ConfigManager
pcall(function()
    if ConfigManager and ConfigManager.Init then
        ConfigManager:Init(Window)
    end
end)
local Config        = ConfigManager:CreateConfig("CathubConfig")

local _CombatTab, _WeaponTab, _ESPTab, _CharTab, _PlayerTab, _BuyTab, _MiscTab
pcall(function()
    _CombatTab = Window:Tab({ Title = "COMBAT:", Icon = "crosshair" })
    _WeaponTab = Window:Tab({ Title = "WEAPON:", Icon = "layers" })
    _ESPTab    = Window:Tab({ Title = "ESP:", Icon = "eye" })
    _CharTab   = Window:Tab({ Title = "CHARACTER:", Icon = "user" })
    _PlayerTab = Window:Tab({ Title = "PLAYER:", Icon = "person-standing" })
    _BuyTab    = Window:Tab({ Title = "BUY:", Icon = "landmark" })
    _MiscTab   = Window:Tab({ Title = "MISC:", Icon = "warehouse" })
end)

local SendRemote
pcall(function()
    SendRemote = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("Send", 5)
end)

local oldFire
pcall(function()
    if SendRemote and SendRemote.FireServer then
        oldFire = hookfunction(SendRemote.FireServer, function(self, ...)
            if self ~= SendRemote then
                return oldFire(self, ...)
            end
            return oldFire(self, ...)
        end)
    end
end)


local function getPing()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 0.2 end
    local stats = gui:FindFirstChild("NetworkStats")
    if not stats then return 0.2 end
    local label = stats:FindFirstChild("PingLabel")
    if not label then return 0.2 end
    local num = tonumber(tostring(label.Text):match("%d+"))
    if not num then return 0.2 end
    local ping = num / 1000
    return (ping < 0 or ping > 2) and 0.2 or ping
end

local function isPlayerExcluded(name)
    for _, entry in ipairs(excludedPlayers) do
        if entry ~= "" and string.find(string.lower(name), string.lower(entry)) then
            return true
        end
    end
    return false
end

local function safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    return ok, result
end

local unpackTable = table.unpack or unpack

local function callRemote(remote, ...)
    if not remote then return end
    local args = { ... }

    if remote.ClassName == "RemoteEvent" then
        if Counter and type(Counter.event) == "number" then
            Counter.event = Counter.event + 1
            safeCall(function(...) remote:FireServer(Counter.event, ...) end, unpackTable(args))
        else
            sendEventCounter = sendEventCounter + 1
            safeCall(function(...) remote:FireServer(sendEventCounter, ...) end, unpackTable(args))
        end
    elseif remote.ClassName == "RemoteFunction" then
        if Counter and type(Counter.func) == "number" then
            Counter.func = Counter.func + 1
            safeCall(function(...) remote:InvokeServer(Counter.func, ...) end, unpackTable(args))
        else
            sendFuncCounter = sendFuncCounter + 1
            safeCall(function(...) remote:InvokeServer(sendFuncCounter, ...) end, unpackTable(args))
        end
    else
        safeCall(function(...)
            if remote.FireServer   then remote:FireServer(...)   end
            if remote.InvokeServer then remote:InvokeServer(...) end
        end, unpackTable(args))
    end
end

local function netGet(...)
    if not Counter or not Counter.func then return end
    local args = { ... }
    for i, v in ipairs(args) do
        if typeof(v) == "Instance" then
            if v:IsA("Model") and #v:GetChildren() == 0 then
                local dropped = Workspace:FindFirstChild("DroppedItems")
                if dropped then
                    local model = dropped:FindFirstChildWhichIsA("Model")
                    if model then args[i] = model else return end
                else return end
            end
        end
    end
    Counter.func = (Counter.func or 0) + 1
    local ok, result = pcall(function()
        local get = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Get")
        return get:InvokeServer(Counter.func, unpackTable(args))
    end)
    if not ok then warn("[NetGet Error]", result) end
    return result
end

local Send = {}
function Send.send(...)
    local args = { ... }
    Counter.event = Counter.event + 1
    pcall(function()
        Remotes.Send:FireServer(Counter.event, unpackTable(args))
    end)
end


local Network = require(game.ReplicatedStorage.Modules.Core.Net)

local SA_TargetHistory = {}
local SA_AimPart = "Head"
local SA_ShowFOV = false

local fovCircle = Drawing.new("Circle")
fovCircle.Radius = fovRadius
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255,255,255)
fovCircle.Visible = SA_ShowFOV

local SA_tracer = Drawing.new("Line")
SA_tracer.Thickness = 2
SA_tracer.Color = Color3.fromRGB(255,0,0)
SA_tracer.Visible = false

local function SA_CreateTracer(startPos,endPos)
	local dist = (endPos - startPos).Magnitude
	local part = Instance.new("Part")
	part.Size = Vector3.new(0.05,0.05,dist)
	part.CFrame = CFrame.new(startPos,endPos) * CFrame.new(0,0,-dist/2)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255,0,0)
	part.Transparency = 0
	part.Parent = workspace
	Debris:AddItem(part,0.15)
end

local function SA_WorldToViewPoint(pos)
	local vp,onScreen = Camera:WorldToViewportPoint(pos)
	return vp,onScreen
end

local function SA_IsAlive(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	return hum and root
end

local function SA_IsBehindWall(startPos,endPos,ignore)
	local ray = Ray.new(startPos,endPos-startPos)
	local hit = workspace:FindPartOnRayWithIgnoreList(ray,ignore or {})
	return hit ~= nil
end

local function SA_GetClosestTarget()
	local closest = nil
	local dist = math.huge
	for _,v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and SA_IsAlive(v.Character) then
			if not v:GetAttribute("SilentAimIgnore") then
				local root = v.Character:FindFirstChild("HumanoidRootPart")
				if root then
					local pos,onScreen = SA_WorldToViewPoint(root.Position)
					if onScreen then
						local d = (Vector2.new(pos.X,pos.Y) - Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude
						if d < fovRadius and d < dist then
							closest = v.Character
							dist = d
						end
					end
				end
			end
		end
	end
	return closest
end

local function SA_GetVelocity(target,pos)
	local t = tick()
	SA_TargetHistory[target] = SA_TargetHistory[target] or {}
	local hist = SA_TargetHistory[target]
	if #hist >= 3 then table.remove(hist,1) end
	table.insert(hist,{ pos = pos, time = t })
	if #hist < 2 then return Vector3.zero end
	local p1 = hist[#hist - 1]
	local p2 = hist[#hist]
	local dt = math.max(p2.time - p1.time,0.000001)
	return (p2.pos - p1.pos) / dt
end

Players.PlayerRemoving:Connect(function(player)
	SA_TargetHistory[player] = nil
end)

RunService.RenderStepped:Connect(function()
	fovCircle.Position = Vector2.new(
		Camera.ViewportSize.X/2,
		Camera.ViewportSize.Y/2
	)
	fovCircle.Radius = fovRadius
	fovCircle.Visible = SA_ShowFOV

	local target = SA_GetClosestTarget()
	if target then
		local part = target:FindFirstChild(
			SA_AimPart == "Body" and "HumanoidRootPart" or "Head"
		)
		if part then
			local pos,onScreen = SA_WorldToViewPoint(part.Position)
			if onScreen then
				SA_tracer.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
				SA_tracer.To = Vector2.new(pos.X,pos.Y)
				SA_tracer.Visible = redLineLockEnabled
			else
				SA_tracer.Visible = false
			end
		else
			SA_tracer.Visible = false
		end
	else
		SA_tracer.Visible = false
	end
end)

local OldSend

OldSend = hookfunction(Network.send,function(...)
	local args = {...}

	if args[1] == "shoot_gun" and silentAimEnabled then
		local target = SA_GetClosestTarget()

		if target then
			local part = target:FindFirstChild(
				SA_AimPart == "Body" and "HumanoidRootPart" or "Head"
			)

			if part then
				local char = LocalPlayer.Character
				if not char then return OldSend(...) end
				local root = char:FindFirstChild("HumanoidRootPart")
				if not root then return OldSend(...) end

				local myPos = root.Position
				local targetPos = part.Position

				local vel = SA_GetVelocity(target,targetPos)
				local speed = vel.Magnitude
				local predictedPos = targetPos

				if speed <= 250 then
					if speed >= 2 then
						local moveDir = vel.Unit
						predictedPos = targetPos + (moveDir * (speed * 0.15))
					end
				end

				local ignore = {
					LocalPlayer.Character,
					target
				}

				local behind = SA_IsBehindWall(
					myPos,
					predictedPos,
					ignore
				)

				if behind then
					args[3] = CFrame.new(
						math.huge,
						math.huge,
						math.huge
					)
				else
					args[3] = CFrame.new(
						myPos,
						predictedPos
					)
				end

				for _,v in pairs(args[4] or {}) do
					for _,x in pairs(v) do
						x.Position = predictedPos
						x.Instance = part
					end
				end

				SA_CreateTracer(
					myPos,
					predictedPos
				)
			end
		end
	end

	if args[1] == "shoot_gun" and rapidFireEnabled then
		return OldSend(table.unpack(args))
	end

	if args[1] == "shoot_gun" and shotMultiplier > 1 then
		local ok, result = pcall(OldSend, table.unpack(args))
		for _i = 1, shotMultiplier - 1 do
			pcall(OldSend, table.unpack(args))
		end
		if ok then return result end
		return
	end

	return OldSend(table.unpack(args))
end)

_G._autoShootTargets = _G._autoShootTargets or {}
_G._killAllEnabled   = _G._killAllEnabled or false

local function findGunTool(char)
    if not char then return nil end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") and v.Name ~= "Fists" then
            local items = ReplicatedStorage:FindFirstChild("Items")
            if items then
                local gunFolder = items:FindFirstChild("gun")
                if gunFolder and gunFolder:FindFirstChild(v.Name) then
                    return v
                end
            end
        end
    end
    return nil
end

local cachedClosest = nil

local function isShotgunTool(char)
    if not char then return false end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local ammoType = tool:GetAttribute("AmmoType")
            if ammoType == "shotgun" or ammoType == "shootgun" then
                return true
            end
        end
    end
    return false
end

local function getAnyTarget()
    local closest = nil
    local dist = math.huge
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and not isPlayerExcluded(v.Name) and v.Character then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            local root = v.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local d = (root.Position - myRoot.Position).Magnitude
                    if d < dist then
                        closest = v
                        dist = d
                    end
                end
            end
        end
    end
    return closest
end

local _velCache = {}

local function getPlayerVelocity(player)
    local char = player and player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then _velCache[player] = nil; return Vector3.zero end
    local now = tick()
    local curPos = root.Position
    local cached = _velCache[player]
    _velCache[player] = {pos = curPos, t = now}
    if not cached then return Vector3.zero end
    local dt = now - cached.t
    if dt < 0.001 then return Vector3.zero end
    return (curPos - cached.pos) / dt
end

local function fireAtPlayer(player, gunTool, myHead)
    if not player or not player.Character then return end
    local tChar = player.Character
    local hum = tChar:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local head = tChar:FindFirstChild("Head")
    if not head then return end

    local vel      = getPlayerVelocity(player)
    local rawDist  = (head.Position - myHead.Position).Magnitude
    local travelT  = rawDist / 400
    local velMag = vel.Magnitude
    if velMag > 50 then vel = vel.Unit * 50 end
    local aimPos = head.Position + vel * travelT

    local shootCFrame = CFrame.new(math.huge, math.huge, math.huge)

    local hitData = {
        [1] = {
            [1] = {
                Instance = head,
                Normal   = Vector3.new(0, 1, 0),
                Position = aimPos,
            }
        }
    }

    pcall(function()
        if Counter and type(Counter.event) == "number" then
            Counter.event = Counter.event + 1
        else
            sendEventCounter = sendEventCounter + 1
        end
        local ctr = (Counter and Counter.event) or sendEventCounter
        if oldFire and SendRemote then
            oldFire(SendRemote, ctr, "shoot_gun", gunTool, shootCFrame, hitData)
        elseif SendRemote then
            SendRemote:FireServer(ctr, "shoot_gun", gunTool, shootCFrame, hitData)
        elseif Remotes and Remotes.Send then
            Remotes.Send:FireServer(ctr, "shoot_gun", gunTool, shootCFrame, hitData)
        end
    end)
end

local function getGunAmmo(gunTool)
    if not gunTool then return 1, 1 end
    local cur = gunTool:GetAttribute("current_ammo")
    local mx  = gunTool:GetAttribute("max_ammo")
    if cur ~= nil then return cur, (mx or 30) end
    local attrs = gunTool:GetAttributes()
    local keys = {}
    for k in pairs(attrs) do table.insert(keys, k) end
    table.sort(keys)
    for _, k in ipairs(keys) do
        local v = attrs[k]
        if type(v) == "number" and v >= 0 and v <= 500 then
            return v, 30
        end
    end
    return 1, 1 
end

local function doReload(gunTool)
    if Counter and type(Counter.event) == "number" then
        Counter.event = Counter.event + 1
    else
        sendEventCounter = sendEventCounter + 1
    end
    local ctr = (Counter and Counter.event) or sendEventCounter
    if oldFire and SendRemote then
        pcall(function() oldFire(SendRemote, ctr, "reload_gun", gunTool) end)
    elseif SendRemote then
        pcall(function() SendRemote:FireServer(ctr, "reload_gun", gunTool) end)
    elseif Remotes and Remotes.Send then
        pcall(function() Remotes.Send:FireServer(ctr, "reload_gun", gunTool) end)
    end
end

task.spawn(function()
    while true do
        task.wait(autoShootInterval)
        if (autoShootEnabled or _G._killAllEnabled) then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local myHead = char:FindFirstChild("Head")
                if not myHead then return end
                local gunTool = findGunTool(char)
                if not gunTool then return end

                local ammo = getGunAmmo(gunTool)
                if ammo <= 0 then
                    doReload(gunTool)
                    return 
                end

                if _G._killAllEnabled then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and not isPlayerExcluded(player.Name) and player.Character then
                            local hum = player.Character:FindFirstChildOfClass("Humanoid")
                            if hum then
                                fireAtPlayer(player, gunTool, myHead)
                            end
                        end
                    end
                elseif #_G._autoShootTargets > 0 then
                    for _, targetName in ipairs(_G._autoShootTargets) do
                        local player = Players:FindFirstChild(targetName)
                        if player and player ~= LocalPlayer and player.Character then
                            fireAtPlayer(player, gunTool, myHead)
                        end
                    end
                else
                    local targetChar = SA_GetClosestTarget()
                    if targetChar then
                        local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
                        if targetPlayer and targetPlayer ~= LocalPlayer then
                            fireAtPlayer(targetPlayer, gunTool, myHead)
                        end
                    end
                end
            end)
        end
    end
end)

local _rapidFireConn = nil

local function startRapidFire()
    if _rapidFireConn then pcall(function() _rapidFireConn:Disconnect() end) end
    _rapidFireConn = RunService.Heartbeat:Connect(function()
        if not rapidFireEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and isGunTool(tool) then
                pcall(function()
                    tool:SetAttribute(FindFireRateAttribute(tool), 9999)
                    tool:SetAttribute("automatic", true)
                end)
            end
        end
    end)
end
startRapidFire()

task.spawn(function()
    while true do
        task.wait(0.15)
        if autoReloadEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local gunTool = findGunTool(char)
                if not gunTool then return end
                local ok, parent = pcall(function() return gunTool.Parent end)
                if not ok or parent ~= char then return end
                if Counter and type(Counter.event) == "number" then
                    Counter.event = Counter.event + 1
                else
                    sendEventCounter = sendEventCounter + 1
                end
                local ctr = (Counter and Counter.event) or sendEventCounter
                if oldFire and SendRemote then
                    oldFire(SendRemote, ctr, "reload_gun", gunTool)
                elseif Remotes and Remotes.Send then
                    Remotes.Send:FireServer(ctr, "reload_gun", gunTool)
                end
            end)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(function()

        local closestPlayer = cachedClosest
        aimTarget = (silentAimEnabled or redLineLockEnabled) and closestPlayer or nil

        if fovCircle then
            if silentAimEnabled then
                if isMobile then
                    fovCircle.Visible = true
                    fovCircle.Position = UDim2.fromScale(0.5, 0.5)
                    fovCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
                else
                    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local t = tick()

                    for i = 1, fovCircle._segments do
                        local angle1 = math.rad((i - 1) * (360 / fovCircle._segments))
                        local angle2 = math.rad(i * (360 / fovCircle._segments))

                        fovCircle._lines[i].From = Center + Vector2.new(math.cos(angle1) * fovRadius, math.sin(angle1) * fovRadius)
                        fovCircle._lines[i].To   = Center + Vector2.new(math.cos(angle2) * fovRadius, math.sin(angle2) * fovRadius)

                        fovCircle._lines[i].Color = Color3.fromHSV(((i / fovCircle._segments) + t * 0.5) % 1, 1, 1)
                        fovCircle._lines[i].Visible = true
                    end
                end
            elseif not isMobile then
                for i = 1, fovCircle._segments do
                    fovCircle._lines[i].Visible = false
                end
            elseif isMobile then
                fovCircle.Visible = false
            end
        end

        if closestPlayer and closestPlayer.Character and (silentAimEnabled or redLineLockEnabled) then
            local head = getAimPart(closestPlayer.Character)
            if head then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local targetPos = head.Position

                if smoothTarget.Magnitude < 1 then
                    smoothTarget = targetPos
                else
                    smoothTarget = smoothTarget:Lerp(targetPos, smoothFactor)
                end

                local screenPos, visible = Camera:WorldToViewportPoint(smoothTarget)
                if visible then
                    redLine.Visible = true
                    redLine.From = center
                    redLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    redLine.Color = Color3.fromRGB(255, 50, 50)
                    redLine.Thickness = 1.3
                else
                    redLine.Visible = false
                    smoothTarget = Vector3.new()
                end
            else
                redLine.Visible = false
                smoothTarget = Vector3.new()
            end
        else
            redLine.Visible = false
            smoothTarget = Vector3.new()
        end

    end)
end)

local jumpConn
local function setupCharacter(char)
    Character = char
    Humanoid  = char:WaitForChild("Humanoid")
    HRP       = char:WaitForChild("HumanoidRootPart")
    if jumpConn then pcall(function() jumpConn:Disconnect() end) end
    jumpConn = RunService.RenderStepped:Connect(function()
        if walkSpeedEnabled and Humanoid and HRP then
            if Humanoid.MoveDirection.Magnitude > 0 then
                HRP.CFrame = HRP.CFrame + (Humanoid.MoveDirection.Unit * speedMultiplier)
            end
        end
    end)
end

local function isDowned()
    local hum = CharModule.get_hum()
    if not hum or hum.Health <= 0 then return false end
    return hum:GetAttribute("HasBeenDowned") or hum:GetAttribute("IsDead")
end

local function getHRP()
    local char = CharModule.current_char.get()
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleportUnderground()
    local root = getHRP()
    if not root then return end
    _snap.pos = root.CFrame + Vector3.new(0, -40, 0)
    root.CFrame = _snap.pos
end

local function flickerAndMove()
    if _snap.flickering then return end
    _snap.flickering = true
    task.spawn(function()
        while _snap.flickering and antiKillEnabled and isDowned() do
            local hum = CharModule.get_hum()
            if hum and hum.Health <= 0 then break end
            local root = getHRP()
            if root and _snap.pos then
                local angle = math.random() * math.pi * 2
                local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * 10
                root.CFrame = CFrame.new(_snap.pos.Position + offset)
                task.wait(0.05)
                root.CFrame = _snap.pos
            end
            task.wait(0.1)
        end
        _snap.flickering = false
    end)
end

RunService.Heartbeat:Connect(function()
    if not antiKillEnabled then return end
    if isDowned() then
        local root = getHRP()
        if root and not _snap.pos then
            teleportUnderground()
        end
        flickerAndMove()
    else
        if _snap.pos then
            local root = getHRP()
            if root then root.CFrame = _snap.pos + Vector3.new(0, 40, 0) end
        end
        _snap.pos = nil
        _snap.flickering = false
    end
end)

local _antiLockConn = nil

local function stopAntiLock()
    if _antiLockConn then
        pcall(function() _antiLockConn:Disconnect() end)
        _antiLockConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, 0, 0)
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = 50
        end
    end
end

local function startAntiLock()
    stopAntiLock()
    _antiLockConn = RunService.Heartbeat:Connect(function()
        if not antiLockEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local prevVel = root.Velocity
        local angle   = math.rad(tick() * 1500 % 360)
        local amount  = getEnv().SkyAmount
        root.Velocity = Vector3.new(math.cos(angle) * amount, math.random(280, 480), math.sin(angle) * amount)
        RunService.RenderStepped:Wait()
        if not antiLockEnabled then
            root.Velocity = Vector3.new(0, 0, 0)
            return
        end
        root.Velocity = prevVel
    end)
end


local function checkAndPickup()
    if not autoPickupEnabled then return end
    local dropped = Workspace:FindFirstChild("DroppedItems")
    if not dropped then return end
    local now  = tick()
    local toPickup = {}
    for _, model in ipairs(dropped:GetChildren()) do
        if model:IsA("Model") then
            local part = model:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (HRP.Position - part.Position).Magnitude
                if dist <= 20 and (now - (itemPickupTrack[model] or 0)) >= 0 then
                    table.insert(toPickup, model)
                    itemPickupTrack[model] = now
                end
            end
        end
    end
    for _, model in ipairs(toPickup) do
        spawn(function() netGet("pickup_dropped_item", model) end)
    end
end

RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HRP = Character:WaitForChild("HumanoidRootPart")
    end
    pcall(checkAndPickup)
end)

local function getPlayersInRange(range)
    local result = {}
    local myChar = LocalPlayer.Character
    if not myChar or not myChar.PrimaryPart then return result end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.PrimaryPart then
            local ok, dist = pcall(function()
                return (player.Character.PrimaryPart.Position - myChar.PrimaryPart.Position).Magnitude
            end)
            if ok and dist and dist <= 20 then
                table.insert(result, player)
            end
        end
    end
    return result
end

local function getActiveTool()
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if pcall(function() return v:IsA("Tool") end) and v:IsA("Tool") then
                return v
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if pcall(function() return v:IsA("Tool") end) and v:IsA("Tool") then
                return v
            end
        end
    end
    return nil
end

local function isMeleeToolCheck(tool)
    if not tool then return false end
    if tool.Name == "Fists" then return true end
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if not itemsFolder then return false end
    local meleeFolder    = itemsFolder:FindFirstChild("melee")
    local throwableFolder = itemsFolder:FindFirstChild("throwable")
    if not meleeFolder or not throwableFolder then return false end
    return meleeFolder:FindFirstChild(tool.Name) and not throwableFolder:FindFirstChild(tool.Name)
end

local function attackNearby()
    if not SendRemote then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar.PrimaryPart then return end
    local tool = getActiveTool()
    if not tool or not isMeleeToolCheck(tool) then return end
    local ok, parent = pcall(function() return tool.Parent end)
    if not ok or parent ~= LocalPlayer.Character then return end
    local nearby = getPlayersInRange(20)
    if #nearby == 0 then return end
    local ok2, myPos = pcall(function() return myChar.PrimaryPart.Position end)
    if not ok2 or not myPos then return end
    local targets, positions = {}, {}
    for _, player in pairs(nearby) do
        if player and player.Character and player.Character.PrimaryPart then
            local head = player.Character:FindFirstChild("Head")
            local root = player.Character.PrimaryPart
            if head and root then
                local aimPos = sirenAimPos(head, player.Character)
                table.insert(targets, player)
                table.insert(positions, aimPos)
            end
        end
    end
    if #targets == 0 then return end
    local lookAt = CFrame.lookAt(myPos, positions[1])
    pcall(function()
        callRemote(SendRemote, unpackTable({ "melee_attack", tool, targets, lookAt, 0.75 }))
    end)
end

local autoAttackRunning = false
local function startAutoAttack()
    if autoAttackRunning then return end
    autoAttackRunning = true
    task.spawn(function()
        while autoAttackRunning do
            task.wait(0.4)
            if autoAttackEnabled and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                pcall(attackNearby)
            end
        end
    end)
end

local function performTeleport()
    if not HRP then return end
    local pos = HRP.Position
    if not _snap.originY then
        _snap.originY = pos.Y
    end
    local destY = _snap.originY - _snap.depth
    local dest = Vector3.new(pos.X, destY, pos.Z)
    HRP.CFrame = CFrame.new(dest)
    _snap.y = destY
    local sound = Instance.new("Sound")
    sound.SoundId     = "rbxassetid://95298029662868"
    sound.Volume      = 1
    sound.PlayOnRemove = true
    sound.Parent      = HRP
    sound:Destroy()
end

local function toggleSnap()
    if not _snap.enabled then return end
    _snap.active = not _snap.active
    if _snap.active then
        performTeleport()
    else
        _snap.y = nil
    end
end

local snapConn
local function lockYPosition()
    if snapConn then pcall(function() snapConn:Disconnect() end) end
    snapConn = RunService.Heartbeat:Connect(function()
        if _snap.active and _snap.y and HRP then
            local pos = HRP.Position
				if math.abs(pos.Y - _snap.y) > 0.1 then
                HRP.CFrame = CFrame.new(pos.X, _snap.y, pos.Z)
            end
        end
    end)
end

local function setFinishPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 1
        prompt.MaxActivationDistance = 20
    end
end

local function tryHoldPrompt(prompt, duration)
    if not prompt or prompt:GetAttribute("__AutoFinishBusy") then return end
    prompt:SetAttribute("__AutoFinishBusy", true)
    pcall(function() if prompt.InputHoldBegin then prompt:InputHoldBegin() end end)
    pcall(function() if prompt.HoldBegin      then prompt:HoldBegin()      end end)
    pcall(function() if prompt.Trigger        then prompt:Trigger()        end end)
    task.wait(duration)
    pcall(function() if prompt.InputHoldEnd then prompt:InputHoldEnd() end end)
    pcall(function() if prompt.HoldEnd      then prompt:HoldEnd()      end end)
    prompt:SetAttribute("__AutoFinishBusy", nil)
end

local function findFinishPrompts()
    local result = {}
    for _, child in pairs(Workspace:GetChildren()) do
        local player = Players:GetPlayerFromCharacter(child)
        if player and not isPlayerExcluded(player.Name) then
            local root = child:FindFirstChild("HumanoidRootPart")
            if root then
                local prompt = root:FindFirstChild("FinishPrompt")
                if prompt then
                    setFinishPrompt(prompt)
                    table.insert(result, prompt)
                end
            end
        end
    end
    return result
end

local function applyToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local prompt = root:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end
    end
end

local function setupFastFinishForPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        char.DescendantAdded:Connect(function(inst)
            if autoFinishEnabled and inst.Name == "FinishPrompt"
                and inst:IsA("ProximityPrompt")
                and inst.Parent and inst.Parent.Name == "HumanoidRootPart" then
                setFinishPrompt(inst)
            end
        end)
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if root and autoFinishEnabled then
            local prompt = root:FindFirstChild("FinishPrompt")
            if prompt then setFinishPrompt(prompt) end
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do setupFastFinishForPlayer(player) end
Players.PlayerAdded:Connect(setupFastFinishForPlayer)

task.spawn(function()
    while true do
        task.wait(0.4)
        if autoFinishEnabled then
            for _, prompt in ipairs(findFinishPrompts()) do
                task.spawn(function() tryHoldPrompt(prompt, 1) end)
            end
        end
    end
end)

local CrateController
pcall(function() CrateController = require(ReplicatedStorage.Modules.Game.CrateSystem.Crate) end)
task.spawn(function()
    while true do
        if skipCrateEnabled and CrateController then
            pcall(function()
                for _, crate in pairs(CrateController.class.objects) do
                    crate.states.open.set(true)
                    CrateController.skipping.set(true)
                end
            end)
        end
        task.wait(0.05)
    end
end)

local ActivePlayerESPs = {}

local MeshDB = {}
local MeshDBLoaded = false
local function LoadMeshDB()
    if MeshDBLoaded then return end
    MeshDBLoaded = true
    if not Items then return end
    local function scan(folder)
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") then
                local handle = item:FindFirstChild("Handle")
                local dName = item:GetAttribute("DisplayName") or item:GetAttribute("ItemName") or item.Name
                if tonumber(dName) then
                    for _, cd in ipairs(item:GetChildren()) do
                        if cd:IsA("StringValue") and (cd.Name == "ItemName" or cd.Name == "WeaponName" or cd.Name == "DisplayName") then
                            dName = cd.Value; break
                        end
                    end
                end
                if handle then
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh and mesh.MeshId ~= "" then
                        MeshDB[mesh.MeshId] = dName
                        if mesh.TextureId ~= "" then MeshDB[mesh.MeshId .. mesh.TextureId] = dName end
                    elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                        MeshDB[handle.MeshId] = dName
                        if handle.TextureID ~= "" then MeshDB[handle.MeshId .. handle.TextureID] = dName end
                    end
                end
            elseif item:IsA("Folder") then
                scan(item)
            end
        end
    end
    pcall(function() scan(Items) end)
end

local ItemNameCache = setmetatable({}, {__mode = "k"})
local function GetItemRealName(tool)
    if ItemNameCache[tool] then return ItemNameCache[tool] end
    local name = tostring(tool.Name)
    local attr = tool:GetAttribute("ItemName") or tool:GetAttribute("DisplayName")
    if attr then name = tostring(attr) end
    if tonumber(name) and tool:IsA("Tool") and tool.ToolTip and tool.ToolTip ~= "" then
        name = tool.ToolTip
    end
    if tonumber(name) then
        LoadMeshDB()
        local handle = tool:FindFirstChild("Handle") or tool
        if handle then
            local mesh = handle:FindFirstChildOfClass("SpecialMesh")
            if mesh and mesh.MeshId ~= "" then
                local res = MeshDB[mesh.MeshId .. (mesh.TextureId or "")] or MeshDB[mesh.MeshId]
                if res then name = res end
            elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                local res = MeshDB[handle.MeshId .. (handle.TextureID or "")] or MeshDB[handle.MeshId]
                if res then name = res end
            end
        end
    end
    if tonumber(name) then
        for _, child in ipairs(tool:GetChildren()) do
            if child:IsA("StringValue") and (child.Name == "ItemName" or child.Name == "WeaponName" or child.Name == "DisplayName") then
                name = child.Value; break
            end
        end
    end
    local cleaned = string.gsub(tostring(name), "[Ii][Tt][Ee][Mm]", "")
    cleaned = string.match(cleaned, "^%s*(.-)%s*$")
    local finalName = (cleaned ~= "" and cleaned) or name
    ItemNameCache[tool] = finalName
    return finalName
end

local RarityColorsESP = {
    ["Common"]    = Color3.fromRGB(200, 200, 200),
    ["Uncommon"]  = Color3.fromRGB(99, 255, 52),
    ["Rare"]      = Color3.fromRGB(51, 170, 255),
    ["Epic"]      = Color3.fromRGB(237, 44, 255),
    ["Legendary"] = Color3.fromRGB(255, 150, 0),
    ["Omega"]     = Color3.fromRGB(255, 20, 51),
}

local function CreateESPText(color)
    local t = Drawing.new("Text")
    t.Size = 13
    t.Center = true
    t.Outline = true
    t.OutlineColor = Color3.new(0, 0, 0)
    t.Color = color or Color3.new(1, 1, 1)
    t.Font = 2
    t.Visible = false
    return t
end

local function DestroyESPData(data)
    if not data then return end
    pcall(function() if data.text then data.text:Remove() end end)
    pcall(function() if data.highlight then data.highlight:Destroy() end end)
    if data.invTexts then
        for _, d in ipairs(data.invTexts) do pcall(function() d:Remove() end) end
    end
end

local function TrimInvDraw(data, keepCount)
    if not data.invTexts then return end
    for i = #data.invTexts, keepCount + 1, -1 do
        pcall(function() data.invTexts[i]:Remove() end)
        data.invTexts[i] = nil
    end
end

local function GetPlayerTools(player)
    local out = {}
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and item.Name ~= "Fists" then out[#out + 1] = item end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and item.Name ~= "Fists" then out[#out + 1] = item end
        end
    end
    return out
end

Players.PlayerRemoving:Connect(function(player)
    if ActivePlayerESPs[player] then
        DestroyESPData(ActivePlayerESPs[player])
        ActivePlayerESPs[player] = nil
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        local anyESP = nameESPEnabled or distanceESPEnabled or healthESPEnabled or inventoryESPEnabled or highlightEnabled
        if not anyESP then
            for _, data in pairs(ActivePlayerESPs) do
                if data.text then data.text.Visible = false end
                if data.invTexts then for _, d in ipairs(data.invTexts) do d.Visible = false end end
                if data.highlight then data.highlight.Enabled = false end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    pcall(function()
                        local char = p.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))

                        if char and hum and root and hum.Health > 0 then
                            if not ActivePlayerESPs[p] then
                                local nameText = CreateESPText(Color3.new(1, 1, 1))
                                local hl = nil
                                pcall(function()
                                    hl = Instance.new("Highlight")
                                    hl.FillTransparency = 0.5
                                    hl.OutlineTransparency = 0
                                    hl.Enabled = false
                                    hl.Parent = game.CoreGui
                                end)
                                ActivePlayerESPs[p] = {text = nameText, invTexts = {}, lastStr = "", rootPart = nil, highlight = hl}
                            end

                            local data = ActivePlayerESPs[p]
                            data.rootPart = root

                            if data.highlight then
                                if highlightEnabled then
                                    data.highlight.Enabled = true
                                    data.highlight.Adornee = char
                                    local hpPct = hum.Health / math.max(hum.MaxHealth, 1)
                                    data.highlight.FillColor = Color3.fromRGB(255 * (1 - hpPct), 255 * hpPct, 0)
                                else
                                    data.highlight.Enabled = false
                                end
                            end

                            local dist = 0
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                            end
                            local health = math.floor(hum.Health)
                            local maxHealth = math.floor(hum.MaxHealth)

                            local espColor = Color3.new(1, 1, 1)
                            local inSafe = p:GetAttribute("IsInSafeZone") or (char and char:GetAttribute("IsInSafeZone"))
                            local inSplash = p:GetAttribute("InSplashScreen") or (char and char:GetAttribute("InSplashScreen"))
                            if inSplash then espColor = Color3.fromRGB(0, 200, 255)
                            elseif inSafe then espColor = Color3.fromRGB(0, 255, 0)
                            elseif isPlayerExcluded(p.Name) then espColor = Color3.fromRGB(0, 255, 0)
                            elseif aimTarget == p then espColor = Color3.fromRGB(255, 0, 0) end

                            local parts = {}
                            if distanceESPEnabled then table.insert(parts, string.format("[%dm]", dist)) end
                            if nameESPEnabled then table.insert(parts, p.Name) end
                            if healthESPEnabled then table.insert(parts, string.format("[%d/%d]", health, maxHealth)) end

                            local newStr = table.concat(parts, " ")
                            if newStr ~= data.lastStr then
                                data.text.Text = newStr
                                data.lastStr = newStr
                            end
                            data.text.Color = espColor
                            data.showText = (#parts > 0)

                            if inventoryESPEnabled then
                                local tools = GetPlayerTools(p)
                                for i = 1, #tools do
                                    if not data.invTexts[i] then
                                        local draw = CreateESPText(Color3.fromRGB(200, 200, 200))
                                        draw.Size = 11
                                        data.invTexts[i] = draw
                                    end
                                    local invDraw = data.invTexts[i]
                                    local rarity = tools[i]:GetAttribute("RarityName") or "Common"
                                    local color = RarityColorsESP[rarity] or Color3.fromRGB(200, 200, 200)
                                    local equipped = tools[i].Parent == char and " [E]" or ""
                                    local itemText = "[" .. GetItemRealName(tools[i]) .. equipped .. "]"
                                    if invDraw.Text ~= itemText then invDraw.Text = itemText end
                                    invDraw.Color = color
                                end
                                TrimInvDraw(data, #tools)
                            else
                                if data.invTexts then
                                    for _, d in ipairs(data.invTexts) do d.Visible = false end
                                end
                            end
                        elseif ActivePlayerESPs[p] then
                            ActivePlayerESPs[p].text.Visible = false
                            if ActivePlayerESPs[p].invTexts then
                                for _, d in ipairs(ActivePlayerESPs[p].invTexts) do d.Visible = false end
                            end
                            if ActivePlayerESPs[p].highlight then ActivePlayerESPs[p].highlight.Enabled = false end
                        end
                    end)
                end
            end
        end

        for pl, _ in pairs(ActivePlayerESPs) do
            if not pl or not pl.Parent then
                DestroyESPData(ActivePlayerESPs[pl])
                ActivePlayerESPs[pl] = nil
            end
        end
    end
end)

local _espFrame = 0
RunService.RenderStepped:Connect(function()
    _espFrame = _espFrame + 1
    if _espFrame % 2 ~= 0 then return end
    local anyESP = nameESPEnabled or distanceESPEnabled or healthESPEnabled or inventoryESPEnabled or highlightEnabled
    if not anyESP then return end

    for _, data in pairs(ActivePlayerESPs) do
        if data.text and data.rootPart and data.rootPart.Parent then
            local anchor = data.rootPart.Position + (data.rootPart.Name == "Head" and Vector3.new(0, 1.5, 0) or Vector3.new(0, 3, 0))
            local pos, onScreen = Camera:WorldToViewportPoint(anchor)
            if data.showText then
                data.text.Visible = onScreen
            else
                data.text.Visible = false
            end
            if onScreen then
                data.text.Position = Vector2.new(pos.X, pos.Y)
                if data.invTexts and inventoryESPEnabled then
                    for i, invDraw in ipairs(data.invTexts) do
                        invDraw.Visible = true
                        invDraw.Position = Vector2.new(pos.X, pos.Y + 14 + ((i - 1) * 13))
                    end
                elseif data.invTexts then
                    for _, invDraw in ipairs(data.invTexts) do invDraw.Visible = false end
                end
            else
                if data.invTexts then
                    for _, invDraw in ipairs(data.invTexts) do invDraw.Visible = false end
                end
            end
        end
    end
end)

local ItemCamera
repeat task.wait() until Workspace.CurrentCamera
ItemCamera = Workspace.CurrentCamera

local function getRarityColor(model)
    if model.Name == "Money" then
        return Color3.fromRGB(0, 255, 0)
    end

    for _, folder in ipairs(Items:GetChildren()) do
        if folder:IsA("Folder") then
            local item = folder:FindFirstChild(model.Name)

            if item and item:GetAttribute("RarityName") then
                return RarityColors[item:GetAttribute("RarityName")] or Color3.fromRGB(255,255,255)
            end
        end
    end

    return Color3.fromRGB(255,255,255)
end

local function cleanupItemDrawings()
    for model, data in pairs(itemDrawings) do
        if not model or not model.Parent then
            pcall(function() data.name:Remove() end)
            pcall(function() data.amount:Remove() end)
            pcall(function() data.highlight:Remove() end)

            itemDrawings[model] = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    cleanupItemDrawings()

    if not DroppedItems then return end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for _, data in pairs(itemDrawings) do
        data.name.Visible = false
        data.amount.Visible = false
        data.highlight.Enabled = false
    end

    local visible = {}

    for _, model in ipairs(DroppedItems:GetChildren()) do
        if model:IsA("Model")
        and model:FindFirstChild("PickUpZone")
        and not model:GetAttribute("Locked") then

            local ok, zonePos = pcall(function()
                return model.PickUpZone.Position
            end)

            if ok and zonePos then
                table.insert(visible, {
                    item = model,
                    dist = (zonePos - myRoot.Position).Magnitude
                })
            end
        end
    end

    table.sort(visible, function(a, b)
        return a.dist < b.dist
    end)

    for i = 1, math.min(20, #visible) do
        local model = visible[i].item
        local data = itemDrawings[model]

        if not data then
            local hl = Instance.new("Highlight")
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillTransparency = 0.6
            hl.OutlineTransparency = 0
            hl.Adornee = model
            hl.Parent = model

            data = {
                name      = Drawing.new("Text"),
                amount    = Drawing.new("Text"),
                highlight = hl
            }

            data.name.Outline      = true
            data.name.OutlineColor = Color3.fromRGB(0, 0, 0)
            data.name.Center       = true
            data.name.Size         = 13
            data.name.Font         = 2

            data.amount.Outline      = true
            data.amount.OutlineColor = Color3.fromRGB(0, 0, 0)
            data.amount.Center       = true
            data.amount.Size         = 11
            data.amount.Font         = 2
            data.amount.Color        = Color3.fromRGB(200, 200, 200)

            itemDrawings[model] = data
        end

        local pos, vis = ItemCamera:WorldToViewportPoint(model.PickUpZone.Position)

        if vis then
            local color = getRarityColor(model)

            data.highlight.OutlineColor = color
            data.highlight.FillColor    = color
            data.highlight.Enabled      = true

            data.name.Color    = color
            data.name.Position = Vector2.new(pos.X, pos.Y)
            data.name.Text     = model.Name
            data.name.Visible  = true

            local amt = model:GetAttribute("Amount") or 1
            data.amount.Position = Vector2.new(pos.X, pos.Y + 15)
            data.amount.Text     = amt > 1 and "["..tostring(amt).."]" or ""
            data.amount.Visible  = amt > 1
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for _, data in pairs(itemDrawings) do
            pcall(function() data.name:Remove() end)
            pcall(function() data.amount:Remove() end)
            pcall(function() data.highlight:Remove() end)
        end

        itemDrawings = {}
    end
end)

local GunItems = Items and Items:FindFirstChild("gun")
if not GunItems then
    GunItems = Items and Items:WaitForChild("gun", 5)
end

getEnv().FireRateValue  = 1000
getEnv().AccuracyValue  = 1
getEnv().RecoilValue    = 0
getEnv().Durability     = 999999999
getEnv().AutoValue      = true
getEnv().GunModsAutoApply = false

local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return (GunItems and GunItems:FindFirstChild(tool.Name) ~= nil) or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end

local function forceSetAttr(tool, attr, val)
    if tool and tool.SetAttribute then
        pcall(function() tool:SetAttribute(attr, val) end)
    end
end

local function FindFireRateAttribute(gun)
    if not gun then return "fire_rate" end
    if gun:GetAttribute("fire_rate") ~= nil then return "fire_rate" end
    for attrName in pairs(gun:GetAttributes()) do
        if type(attrName) == "string" and attrName:sub(-3) == "486" then
            return attrName
        end
    end
    return "fire_rate"
end

local function applyGodGun(tool)
    if not tool or not isGunTool(tool) then return end
    pcall(function()
        tool:SetAttribute(FindFireRateAttribute(tool), getEnv().FireRateValue)
        tool:SetAttribute("accuracy",   getEnv().AccuracyValue)
        tool:SetAttribute("Recoil",     getEnv().RecoilValue)
        tool:SetAttribute("Durability", getEnv().Durability)
        tool:SetAttribute("automatic",  getEnv().AutoValue)
    end)
    task.spawn(function()
        for _ = 1, 20 do
            local attrs = tool:GetAttributes()
            local keys = {}
            for k in pairs(attrs) do table.insert(keys, k) end
            table.sort(keys)
            if #keys >= 11 then
                local targetKey = keys[11]
                for _ = 1, 5 do forceSetAttr(tool, targetKey, true); task.wait(0.01) end
            end
            task.wait(0.1)
        end
    end)
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    if getEnv().GunModsAutoApply then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and isGunTool(tool) then pcall(applyGodGun, tool) end
        end
    end
    if rapidFireEnabled then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and isGunTool(tool) then
                pcall(function()
                    tool:SetAttribute(FindFireRateAttribute(tool), 9999)
                    tool:SetAttribute("automatic", true)
                end)
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    repeat
        task.wait(0.1)
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and isGunTool(tool) then task.spawn(applyGodGun, tool) end
        end
    until not getEnv().GunModsAutoApply
end)

if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and getEnv().GunModsAutoApply then
            task.wait(0.2)
            applyGodGun(child)
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and getEnv().GunModsAutoApply then
            task.wait(0.2)
            applyGodGun(child)
        end
    end)
end)

local meleeNames = {}
if MeleeItems then
    for _, tool in ipairs(MeleeItems:GetChildren()) do table.insert(meleeNames, tool.Name) end
end

local function isMeleeByName(tool)
    if not tool:IsA("Tool") then return false end
    if tool.Name == "Fists" then return true end
    for _, name in ipairs(meleeNames) do
        if tool.Name == name then return true end
    end
    return false
end

local function modifyFists(tool, enable)
    if not tool then return end
    local attrs = tool:GetAttributes()
    local keys  = {}
    for k in pairs(attrs) do table.insert(keys, k) end
    table.sort(keys)
    if #keys >= 7 then
        local rangeKey = keys[6]
        local dmgKey   = keys[7]
        if enable then
            if originalAttribs[rangeKey] == nil then originalAttribs[rangeKey] = tool:GetAttribute(rangeKey) end
            if originalAttribs[dmgKey]   == nil then originalAttribs[dmgKey]   = tool:GetAttribute(dmgKey)   end
            tool:SetAttribute(rangeKey, 360)
            tool:SetAttribute(dmgKey,   20)
        else
            if originalAttribs[rangeKey] then tool:SetAttribute(rangeKey, originalAttribs[rangeKey]) end
            if originalAttribs[dmgKey]   then tool:SetAttribute(dmgKey,   originalAttribs[dmgKey])   end
        end
    end
end

local function checkAndModifyFists()
    local char    = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end
    for _, tool in ipairs(char:GetChildren()) do
        if isMeleeByName(tool) then modifyFists(tool, meleeAuraEnabled) end
    end
    for _, tool in ipairs(backpack:GetChildren()) do
        if isMeleeByName(tool) then modifyFists(tool, meleeAuraEnabled) end
    end
end

RunService.Heartbeat:Connect(function()
    if meleeAuraEnabled then checkAndModifyFists() end
end)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if meleeAuraEnabled then checkAndModifyFists() end
end)

local _jumpHolding = false
local _jumpFlySpeed = 40
local _jumpConns = {}

local function stopHighJump()
    for _, c in ipairs(_jumpConns) do
        pcall(function() c:Disconnect() end)
    end
    _jumpConns = {}
    _jumpHolding = false
    pcall(function() ContextActionService:UnbindAction("_HJ_FlyUp") end)
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        end
    end
end

local function setupHighJump(char)
    if not jumpPowerEnabled then return end
    stopHighJump()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")

    ContextActionService:BindAction("_HJ_FlyUp", function(_, inputState, inputObj)
        if not jumpPowerEnabled then return Enum.ContextActionResult.Pass end
        local isJumpKey = false
        if inputObj.UserInputType == Enum.UserInputType.Keyboard and inputObj.KeyCode == Enum.KeyCode.Space then
            isJumpKey = true
        end
        if inputObj.UserInputType == Enum.UserInputType.Touch then
            isJumpKey = true
        end
        if isJumpKey then
            if inputState == Enum.UserInputState.Begin then
                _jumpHolding = true
                humanoid.Jump = true
                return Enum.ContextActionResult.Sink
            elseif inputState == Enum.UserInputState.End then
                _jumpHolding = false
                return Enum.ContextActionResult.Sink
            end
        end
        return Enum.ContextActionResult.Pass
    end, false, Enum.KeyCode.Space)

    _jumpConns[1] = RunService.RenderStepped:Connect(function()
        if jumpPowerEnabled and _jumpHolding and hrp then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, _jumpFlySpeed, hrp.Velocity.Z)
        end
    end)

    _jumpConns[2] = humanoid:GetPropertyChangedSignal("Jumping"):Connect(function()
        if jumpPowerEnabled and humanoid.Jumping then
            _jumpHolding = true
        else
            _jumpHolding = false
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if jumpPowerEnabled then setupHighJump(char) end
end)

local function lockTool(tool)
    if tool and tool:IsA("Tool") then
        pcall(function() tool:SetAttribute("Locked", true) end)
    end
end

local function setupBackpack(backpack)
    if not backpack then return end
    for _, tool in ipairs(backpack:GetChildren()) do lockTool(tool) end
    backpack.ChildAdded:Connect(lockTool)
end

local function initBackpack()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        setupBackpack(backpack)
    else
        LocalPlayer.ChildAdded:Connect(function(child)
            if child:IsA("Backpack") then setupBackpack(child) end
        end)
    end
end

initBackpack()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    initBackpack()
end)

task.wait(2)
print("Bypass hotbar inf")

local ok, sellBtn = pcall(function() return BuyPromptUI.get("SellPromptSellButton") end)
if ok and sellBtn then
    local holdStroke = sellBtn:FindFirstChild("HoldStroke", true)
    if holdStroke then
        holdStroke.Enabled = false
        local grad = holdStroke:FindFirstChildOfClass("UIGradient")
        if grad then grad.Enabled = false end
    end
    for _, v in pairs(sellBtn:GetDescendants()) do
        if v:IsA("NumberValue") then v.Value = 1 end
    end
end

task.wait(2)
print("Bypass")

if Util and Util.tween then
    local origTween = Util.tween
    Util.tween = function(obj, info, target)
        if obj and obj:IsA("NumberValue") and target and target.Value ~= nil then
            obj.Value = target.Value
            return { Cancel = function() end }
        end
        return origTween(obj, info, target)
    end
end

local function hookButton(btn)
    if not btn then return end
    if btn:FindFirstChild("UnlocksAtText") then btn.UnlocksAtText.Visible = false end
    if btn:FindFirstChild("EmoteName")     then btn.EmoteName.Visible = true      end
    CoreUI.on_click(btn, function()
        local hum = CharModule.get_hum()
        if not hum or hum.Health <= 0 then return end
        if EmotesUI.current_emote_playing.get() == btn then
            EmotesUI.current_emote_playing.set(nil)
        else
            EmotesUI.current_emote_playing.set(btn)
        end
        task.wait(0.12)
        EmotesUI.enabled.set(false)
    end)
    EmotesUI.current_emote_playing.hook(function(current)
        if btn:FindFirstChild("EmoteEquipped") then
            btn.EmoteEquipped.Visible = (current == btn)
        end
    end)
end

local function hookAllEmotes()
    if not EmotesList or not CoreUI then return end
    pcall(function()
        for _, emote in pairs(EmotesList) do
            local template = CoreUI.get("EmoteTemplate")
            if template and template.Parent then
                local btn = template.Parent:FindFirstChild(emote.name)
                hookButton(btn)
            end
        end
    end)
end

pcall(hookAllEmotes)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    hookAllEmotes()
end)

LocalPlayer.CharacterAdded:Connect(setupCharacter)
if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
    _snap.y   = nil
    _snap.active = false
    lockYPosition()
end)
lockYPosition()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    autoAttackRunning = false
    task.wait(0.1)
    startAutoAttack()
end)
startAutoAttack()

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
end)

LocalPlayer.CharacterAdded:Connect(function(char) Character = char end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G and WindUI and Window then
        if Window.Toggle then Window:Toggle()
        elseif Window.SetVisible then Window:SetVisible(not Window.Visible) end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z and _snap.enabled then
        toggleSnap()
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if inventoryESPEnabled then
            wait(0.2)
            pcall(function() createBillboardForPlayer(player) end)
        end
        if espData[player] and espData[player].drawings then
            local nameDraw = espData[player].drawings[1]
            nameDraw.Color = isPlayerExcluded(player.Name)
                and Color3.fromRGB(0, 255, 0)
                or  Color3.fromRGB(255, 255, 255)
        end
    end)
end)


task.spawn(function()

do
    local CombatTab = _CombatTab
    CombatTab:Section({ Title = "GUN:" })

    local SilentAimToggle = CombatTab:Toggle({
        Title   = "Silent Aim",
        Default = false,
        Callback = function(v)
            silentAimEnabled = v
            aimTarget = nil
        end,
    })
    Config:Register("SilentAim", SilentAimToggle)

    local RedLineToggle = CombatTab:Toggle({
        Title   = "Red Line Lock",
        Default = false,
        Callback = function(v)
            redLineLockEnabled = v
            aimTarget = nil
        end,
    })
    Config:Register("SilentAimAttach", RedLineToggle)

    local FOVSlider = CombatTab:Slider({
        Title = "FOV: ",
        Step  = 1,
        Value = { Min = 20, Max = 800, Default = fovRadius },
        Callback = function(v)
            fovRadius = tonumber(v) or 120
            SA_FOV = fovRadius
            fovCircle.Radius = fovRadius
        end,
    })
    Config:Register("FOVRadius", FOVSlider)

    CombatTab:Toggle({
        Title = "Show FOV",
        Default = false,
        Callback = function(v)
            SA_ShowFOV = v
            fovCircle.Visible = v
        end,
    })

    CombatTab:Dropdown({
        Title = "Aim Part",
        Values = {"Head","Body"},
        Multi = false,
        Default = "Head",
        Callback = function(v)
            SA_AimPart = v
        end
    })

    CombatTab:Dropdown({
        Title = "Save Friend",
        Values = (function()
            local t = {}
            for _,plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then table.insert(t,plr.Name) end
            end
            return t
        end)(),
        Multi = true,
        Default = {},
        Callback = function(selected)
            for _,plr in pairs(Players:GetPlayers()) do
                plr:SetAttribute("SilentAimIgnore",false)
            end
            for _,name in pairs(selected) do
                local plr = Players:FindFirstChild(name)
                if plr then plr:SetAttribute("SilentAimIgnore",true) end
            end
        end
    })

    local MultiplierSlider = CombatTab:Slider({
        Title = "Multiplier Shot",
        Step  = 1,
        Value = { Min = 1, Max = 5, Default = 1 },
        Callback = function(v)
            shotMultiplier = tonumber(v) or 1
        end,
    })
    Config:Register("MultiplierShot", MultiplierSlider)

    CombatTab:Section({ Title = "RAPID FIRE:" })

    local RapidFireToggle = CombatTab:Toggle({
        Title   = "Rapid Fire (No Limit)",
        Desc    = "เธขเธดเธเธฃเธฑเธง",
        Default = false,
        Callback = function(v)
            rapidFireEnabled = v
            if v then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") and isGunTool(tool) then
                                pcall(function()
                                    tool:SetAttribute(FindFireRateAttribute(tool), 9999)
                                    tool:SetAttribute("automatic", true)
                                end)
                            end
                        end
                    end
                end)
                if WindUI then WindUI:Notify({ Title = "open", Duration = 3 }) end
            else
                if WindUI then WindUI:Notify({ Title = "off", Duration = 2 }) end
            end
        end,
    })
    Config:Register("RapidFire", RapidFireToggle)

    CombatTab:Section({ Title = "AUTO:" })

    local AutoShootToggle = CombatTab:Toggle({
        Title   = "Auto Shoot",
        Desc    = "เธขเธดเธเธเธทเธเธญเธฑเธ•เนเธเธกเธฑเธ•เธดเนเธชเนเน€เธเนเธฒเธซเธกเธฒเธขเธ—เธตเนเนเธเธฅเนเธชเธธเธ”",
        Default = false,
        Callback = function(v)
            autoShootEnabled = v
        end,
    })
    Config:Register("AutoShoot", AutoShootToggle)

    local AutoShootSpeedSlider = CombatTab:Slider({
        Title = "Auto Shoot Speed",
        Step  = 0.01,
        Value = { Min = 0.03, Max = 0.5, Default = 0.08 },
        Callback = function(v)
            autoShootInterval = tonumber(v) or 0.08
        end,
    })
    Config:Register("AutoShootSpeed", AutoShootSpeedSlider)

    local TargetDropdown = CombatTab:Dropdown({
        Title  = "Auto Shoot Targets",
        Desc   = "เน€เธฅเธทเธญเธเธเธเธขเธดเธ (เน€เธฅเธทเธญเธเธซเธฅเธฒเธขเธเธเนเธ”เน) เธ–เนเธฒเนเธกเนเน€เธฅเธทเธญเธ = เธขเธดเธเธเธเนเธเธฅเนเธชเธธเธ”",
        Values = (function()
            local n = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then table.insert(n, p.Name) end
            end
            return n
        end)(),
        Multi    = true,
        Callback = function(selected)
            _G._autoShootTargets = {}
            if type(selected) == "table" then
                for name, on in pairs(selected) do
                    if on then table.insert(_G._autoShootTargets, name) end
                end
            end
        end,
    })
    Config:Register("AutoShootTargets", TargetDropdown)

    local KillAllToggle = CombatTab:Toggle({
        Title   = "Kill All",
        Desc    = "เธขเธดเธเธ—เธธเธเธเธเนเธเน€เธเธดเธฃเนเธเธญเธฑเธ•เนเธเธกเธฑเธ•เธดเธเธเธ•เธฒเธขเธซเธกเธ”",
        Default = false,
        Callback = function(v)
            _G._killAllEnabled = v
            if v then
                autoShootEnabled = true
                if WindUI then WindUI:Notify({ Title = "เธขเธดเธเธ—เธธเธเธเธ! Kill All ON", Duration = 3 }) end
            else
                autoShootEnabled = false
                if WindUI then WindUI:Notify({ Title = "Kill All OFF", Duration = 2 }) end
            end
        end,
    })
    Config:Register("KillAll", KillAllToggle)

    local AutoReloadToggle = CombatTab:Toggle({
        Title   = "Auto Reload",
        Desc    = "เธเธฑเธเนเธกเนเธเธญเธฑเธ•เนเธเธกเธฑเธ•เธด (เน€เธฃเนเธงเธกเธฒเธ)",
        Default = false,
        Callback = function(v)
            autoReloadEnabled = v
        end,
    })
    Config:Register("AutoReload", AutoReloadToggle)

    local function getPlayerNames()
        local names = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(names, player.Name)
            end
        end
        return names
    end

    local FriendDropdown = CombatTab:Dropdown({
        Title    = "Safe Friend",
        Desc     = "Select players to whitelist",
        Values   = getPlayerNames(),
        Default  = {},
        Multi    = true,
        Callback = function(v)
            excludedPlayers = {}
            if type(v) == "table" then
                for name, selected in pairs(v) do
                    if type(name) == "string" and selected == true then
                        table.insert(excludedPlayers, name)
                    end
                end
                if #excludedPlayers == 0 then
                    for _, name in ipairs(v) do
                        if type(name) == "string" then
                            table.insert(excludedPlayers, name)
                        end
                    end
                end
            end
            for _, player in pairs(Players:GetPlayers()) do
                if espData[player] and espData[player].drawings then
                    espData[player].drawings[1].Color =
                        isPlayerExcluded(player.Name) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
                end
            end
        end,
    })
    Config:Register("FriendsList", FriendDropdown)

    Players.PlayerAdded:Connect(function()
        pcall(function() FriendDropdown:Refresh(getPlayerNames(), true) end)
    end)
    Players.PlayerRemoving:Connect(function()
        pcall(function() FriendDropdown:Refresh(getPlayerNames(), true) end)
    end)

    pcall(function() CombatTab:Divider() end)
end

do
    local WeaponTab = _WeaponTab
    WeaponTab:Section({ Title = "MODS:" })

    WeaponTab:Slider({
        Title = "Fire Rate",
        Step  = 10,
        Value = { Min = 100, Max = 3000, Default = 1000 },
        Callback = function(v) getEnv().FireRateValue = v end,
    })

    WeaponTab:Slider({
        Title = "Accuracy",
        Step  = 0.01,
        Value = { Min = 0, Max = 1, Default = 1 },
        Callback = function(v) getEnv().AccuracyValue = v end,
    })

    WeaponTab:Slider({
        Title = "Recoil",
        Step  = 0.1,
        Value = { Min = 0, Max = 10, Default = 0 },
        Callback = function(v) getEnv().RecoilValue = v end,
    })

    WeaponTab:Slider({
        Title = "Reload Time",
        Step  = 0.1,
        Value = { Min = 0.1, Max = 10, Default = 0.1 },
        Callback = function(v) getEnv().ReloadValue = v end,
    })

    WeaponTab:Toggle({
        Title = "Automatic",
        Icon  = "check",
        Type  = "Checkbox",
        Value = false,
        Callback = function(v)
            getEnv().automatic         = v
            getEnv().GunModsAutoApply  = v
            if v and WindUI then WindUI:Notify({ Title = "โ… Auto Modify", Duration = 2 }) end
        end,
    })

    WeaponTab:Section({ Title = "COMBAT" })

    Config:Register("Fists Modifier", WeaponTab:Toggle({
        Title   = "Melee Aura",
        Desc    = "WideFists",
        Default = false,
        Callback = function(v)
            meleeAuraEnabled = v
            checkAndModifyFists()
        end,
    }))

    local AutoAttackToggle = WeaponTab:Toggle({
        Title   = "Auto Attack",
        Default = false,
        Callback = function(v) autoAttackEnabled = v end,
    })
    Config:Register("AutoAttack_Enabled", AutoAttackToggle)
end

do
    local ESPTab = _ESPTab
    ESPTab:Section({ Title = "Visual:" })

    local InventoryESPToggle = ESPTab:Toggle({
        Title   = "Inventory Viewer",
        Default = false,
        Callback = function(v)
            inventoryESPEnabled = v
            if v then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        pcall(function() createBillboardForPlayer(player) end)
                    end
                end
                _G.inventoryConn = RunService.Heartbeat:Connect(function()
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            pcall(function() createBillboardForPlayer(player) end)
                        end
                    end
                end)
                if WindUI then WindUI:Notify({ Title = "โ… ESP Items Enabled", Duration = 3 }) end
            else
                if _G.inventoryConn then _G.inventoryConn:Disconnect(); _G.inventoryConn = nil end
                for _, gui in pairs(PlayerBillboards) do gui:Destroy() end
                PlayerBillboards = {}
                if WindUI then WindUI:Notify({ Title = "โ ESP Items Disabled", Duration = 3 }) end
            end
        end,
    })
    Config:Register("ItemsESP", InventoryESPToggle)

    local NameESPToggle = ESPTab:Toggle({
        Title   = "Name",
        Default = false,
        Callback = function(v) nameESPEnabled = v end,
    })
    Config:Register("NameESP", NameESPToggle)

    local HealthESPToggle = ESPTab:Toggle({
        Title   = "Health",
        Default = false,
        Callback = function(v) healthESPEnabled = v end,
    })
    Config:Register("HealthESP", HealthESPToggle)

    local DistanceESPToggle = ESPTab:Toggle({
        Title   = "Distance",
        Default = false,
        Callback = function(v) distanceESPEnabled = v end,
    })
    Config:Register("DistanceESP", DistanceESPToggle)

    local HighlightESPToggle = ESPTab:Toggle({
        Title   = "Highlight",
        Default = false,
        Callback = function(v)
            highlightEnabled = v
            for _, player in pairs(Players:GetPlayers()) do
                pcall(function() updateHighlight(player) end)
            end
        end,
    })
    Config:Register("HighlightESP", HighlightESPToggle)
end

do
    local CharTab = _CharTab
    CharTab:Section({ Title = "CHARACTER:" })

    local WalkSpeedToggle = CharTab:Toggle({
        Title   = "Walk Speed",
        Default = false,
        Callback = function(v) walkSpeedEnabled = v end,
    })
    Config:Register("WalkSpeed", WalkSpeedToggle)

    local SpeedSlider = CharTab:Slider({
        Title = "Speed Multiplier",
        Step  = 0.5,
        Value = { Min = 1, Max = 5, Default = 2 },
        Callback = function(v) speedMultiplier = v * 0.05 end,
    })
    Config:Register("SpeedMultiplier", SpeedSlider)

    local JumpToggle = CharTab:Toggle({
        Title   = "High Jump",
        Default = false,
        Callback = function(v)
            jumpPowerEnabled = v
            if v then
                if LocalPlayer.Character then setupHighJump(LocalPlayer.Character) end
            else
                stopHighJump()
            end
        end,
    })
    Config:Register("JumpPower", JumpToggle)

    local AutoSprintToggle = CharTab:Toggle({
        Title   = "Infinite Stamina",
        Default = false,
        Callback = function(v)
            infiniteStaminaEnabled = v
            if v then
                local ok, SprintModule = pcall(function() return require(ReplicatedStorage.Modules.Game.Sprint) end)
                if ok and SprintModule then
                    local sprintBar = getupvalue(SprintModule.consume_stamina, 2).sprint_bar
                    if sprintBar then
                        local origUpdate = sprintBar.update
                        sprintBar.update = function(...) return origUpdate(function() return 1 end) end
                        getEnv().OriginalSprintUpdate = origUpdate
                        getEnv().AutoSprintLoop = task.spawn(function()
                            while infiniteStaminaEnabled do
                                pcall(function()
                                    Send.send("set_sprinting_1", true)
                                    task.wait(0.5)
                                    Send.send("set_sprinting_1", false)
                                end)
                                task.wait(0.1)
                            end
                            pcall(function() Send.send("set_sprinting_1", false) end)
                        end)
                        if WindUI then WindUI:Notify({ Title = "โ… INF STAMINA", Duration = 3 }) end
                    else
                        infiniteStaminaEnabled = false
                        AutoSprintToggle:Set(false)
                    end
                else
                    infiniteStaminaEnabled = false
                    AutoSprintToggle:Set(false)
                end
            else
                if getEnv().AutoSprintLoop then
                    task.cancel(getEnv().AutoSprintLoop)
                    getEnv().AutoSprintLoop = nil
                end
                pcall(function() Send.send("set_sprinting_1", false) end)
                local ok, SprintModule = pcall(function() return require(ReplicatedStorage.Modules.Game.Sprint) end)
                if ok and SprintModule then
                    local sprintBar = getupvalue(SprintModule.consume_stamina, 2).sprint_bar
                    if sprintBar and getEnv().OriginalSprintUpdate then
                        sprintBar.update = getEnv().OriginalSprintUpdate
                        getEnv().OriginalSprintUpdate = nil
                    end
                end
                if WindUI then WindUI:Notify({ Title = "โ Auto Sprint Disabled", Duration = 3 }) end
            end
        end,
    })
    Config:Register("AutoSprint", AutoSprintToggle)

    local AntiLockToggle = CharTab:Toggle({
        Title   = "Anti Lock",
        Default = false,
        Callback = function(v)
            antiLockEnabled = v
            getEnv().Sky = v
            if v then
                getEnv().SkyAmount = 1500
                startAntiLock()
            else
                stopAntiLock()
                if jumpPowerEnabled and LocalPlayer.Character then
                    setupHighJump(LocalPlayer.Character)
                end
            end
        end,
    })
    Config:Register("AntiLock", AntiLockToggle)



    local AntiKillToggle = CharTab:Toggle({
        Title   = "Anti Kill",
        Default = false,
        Callback = function(v)
            antiKillEnabled = v
            if WindUI then
                WindUI:Notify({ Title = v and " Anti Kill Enabled" or "โ Anti Kill Disabled", Duration = 3 })
            end
        end,
    })
    Config:Register("AntiKill", AntiKillToggle)

    pcall(function() if CharTab and typeof(CharTab.Divider) == "function" then CharTab:Divider() end end)
    pcall(function() if CharTab and typeof(CharTab.Section) == "function" then CharTab:Section({ Title = "Att:" }) end end)

    local PickupToggle = CharTab:Toggle({
        Title   = "Pickup items",
        Default = false,
        Callback = function(v) autoPickupEnabled = v end,
    })
    Config:Register("PickupItems", PickupToggle)

    local AntiRagdollToggle = CharTab:Toggle({
        Title   = "Anti Ragdoll",
        Default = false,
        Callback = function(enabled)
            if not enabled then return end
            pcall(function()
                local rs = game:GetService("ReplicatedStorage")
                local pl = game:GetService("Players").LocalPlayer
                local function findCounter2()
                    for _, v in ipairs(getgc and getgc(true) or {}) do
                        if typeof(v) == "table" and rawget(v, "event") and rawget(v, "func") then return v end
                    end
                end
                local ctr = findCounter2()
                if not ctr then return end
                local function sendAction(action)
                    ctr.event = (ctr.event or 0) + 1
                    rs:WaitForChild("Remotes"):WaitForChild("Send"):FireServer(ctr.event, action)
                end
                task.spawn(function()
                    while enabled do
                        sendAction("end_ragdoll_early")
                        task.wait(0.3)
                        if not enabled then break end
                        sendAction("clear_ragdoll")
                        task.wait(0.3)
                    end
                end)
            end)
        end,
    })
    Config:Register("AntiRagdoll", AntiRagdollToggle)

    local HideNameToggle = CharTab:Toggle({
        Title   = "Hide Name",
        Default = false,
        Callback = function(v)
            pcall(function()
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local root = char:WaitForChild("HumanoidRootPart")
                local billboard = root:FindFirstChild("CharacterBillboardGui")
                if billboard then
                    local nameLabel = billboard:FindFirstChild("PlayerName")
                    if nameLabel and nameLabel:IsA("TextLabel") then
                        nameLabel.Visible = not v
                    end
                end
            end)
        end,
    })
    Config:Register("HideName", HideNameToggle)

    local AutoRespawnToggle = CharTab:Toggle({
        Title   = "Auto Respawn",
        Default = false,
        Callback = function(enabled)
            if not enabled then return end
            pcall(function()
                local rs = game:GetService("ReplicatedStorage")
                local pl = game:GetService("Players").LocalPlayer
                local function findCounter2()
                    for _, v in ipairs(getgc and getgc(true) or {}) do
                        if typeof(v) == "table" and rawget(v, "event") and rawget(v, "func") then return v end
                    end
                end
                local ctr = findCounter2()
                if not ctr then return end
                local function sendAction(action)
                    ctr.event = (ctr.event or 0) + 1
                    rs:WaitForChild("Remotes"):WaitForChild("Send"):FireServer(ctr.event, action)
                end
                task.spawn(function()
                    while enabled do
                        local char = pl.Character
                        local hum  = char and char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health <= 0 then
                            task.wait(6)
                            if enabled then sendAction("death_screen_request_respawn") end
                        end
                        task.wait(0.5)
                    end
                end)
            end)
        end,
    })
    Config:Register("AutoRespawn", AutoRespawnToggle)

    CharTab:Divider()
    CharTab:Section({ Title = "PC HOLD (Z)" })

    local SnapToggle = CharTab:Toggle({
        Title   = "Snap Under Map",
        Default = false,
        Callback = function(v)
            _snap.enabled = v
            if v then
                _snap.originY = HRP and HRP.Position.Y or nil
                _snap.y = HRP and HRP.Position.Y or nil
                _snap.active = true
                performTeleport()
            else
                _snap.active = false
                _snap.y = nil
                _snap.originY = nil
            end
        end,
    })
    Config:Register("SnapUnderMap", SnapToggle)

    local SnapSlider = CharTab:Slider({
        Title = "Snap:",
        Step  = 1,
        Value = { Min = 1, Max = 100, Default = 10 },
        Callback = function(v)
            _snap.depth = v
            if _snap.active and HRP and _snap.originY then
                local destY = _snap.originY - v
                local newPos = Vector3.new(HRP.Position.X, destY, HRP.Position.Z)
                HRP.CFrame = CFrame.new(newPos)
                _snap.y = destY
            end
        end,
    })
    Config:Register("SnapHeight", SnapSlider)
end

do
    local PlayerTab = _PlayerTab
    PlayerTab:Section({ Title = "PLAYER:" })

    local AutoFinishToggle = PlayerTab:Toggle({
        Title   = "Auto Finish",
        Default = false,
        Callback = function(v)
            autoFinishEnabled = v
        end,
    })
    pcall(function() Config:Register("AutoFinish", AutoFinishToggle) end)
end

-- ============================================================================
-- STRONG — AUTO-CLOSE del cuerpo truncado del superhub original
-- (el bfbf929b fue cortado a 2844 líneas; estos end cierran la pila restante)
-- ============================================================================
pcall(function() if Window and Window.Toggle then Window:Toggle(true) end end)
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end)
end -- end launchStrong

-- ============================================================================
-- WIRE BUTTONS
-- ============================================================================
disimBtn.MouseButton1Click:Connect(launchDisimulated)
strongBtn.MouseButton1Click:Connect(launchStrong)
