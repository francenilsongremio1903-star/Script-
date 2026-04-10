--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    OPEN RINGTA SCRIPTS - MEGA PREMIUM v5.0                ║
    ║                         Game: Ugc (ID: 70876832253163)                    ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
    
    Features: 10+ Themes | ESP Pro | Aimbot | Auto-Farm | God Mode | 200+ Remotes
]]

local Players,RS,RunService,TweenService,UIS,Workspace = game:GetService("Players"),game:GetService("ReplicatedStorage"),game:GetService("RunService"),game:GetService("TweenService"),game:GetService("UserInputService"),game:GetService("Workspace")
local LocalPlayer,Camera,Mouse = Players.LocalPlayer,Workspace.CurrentCamera,Players.LocalPlayer:GetMouse()

-- CONFIG
local Config = {Version="5.0 MEGA",Keybind=Enum.KeyCode.F4,CurrentTheme="Discord",
    Themes={
        Discord={Primary=Color3.fromRGB(88,101,242),Background=Color3.fromRGB(30,31,34),Surface=Color3.fromRGB(43,45,49),SurfaceLight=Color3.fromRGB(54,57,63),Text=Color3.fromRGB(255,255,255),TextDark=Color3.fromRGB(185,187,190),Success=Color3.fromRGB(59,165,93),Error=Color3.fromRGB(237,66,69),Warning=Color3.fromRGB(250,168,26)},
        Purple={Primary=Color3.fromRGB(147,112,219),Background=Color3.fromRGB(20,20,30),Surface=Color3.fromRGB(35,35,50),SurfaceLight=Color3.fromRGB(50,50,70),Text=Color3.fromRGB(255,255,255),TextDark=Color3.fromRGB(180,180,180),Success=Color3.fromRGB(0,255,127),Error=Color3.fromRGB(255,69,69),Warning=Color3.fromRGB(255,165,0)},
        Cyberpunk={Primary=Color3.fromRGB(0,255,255),Background=Color3.fromRGB(10,10,20),Surface=Color3.fromRGB(20,20,40),SurfaceLight=Color3.fromRGB(30,30,60),Text=Color3.fromRGB(0,255,255),TextDark=Color3.fromRGB(0,180,180),Success=Color3.fromRGB(0,255,100),Error=Color3.fromRGB(255,0,80),Warning=Color3.fromRGB(255,200,0)},
        Red={Primary=Color3.fromRGB(220,50,50),Background=Color3.fromRGB(30,15,15),Surface=Color3.fromRGB(50,25,25),SurfaceLight=Color3.fromRGB(70,35,35),Text=Color3.fromRGB(255,255,255),TextDark=Color3.fromRGB(220,180,180),Success=Color3.fromRGB(100,255,100),Error=Color3.fromRGB(255,50,50),Warning=Color3.fromRGB(255,150,50)},
        Green={Primary=Color3.fromRGB(50,200,100),Background=Color3.fromRGB(15,30,20),Surface=Color3.fromRGB(25,50,35),SurfaceLight=Color3.fromRGB(35,70,50),Text=Color3.fromRGB(255,255,255),TextDark=Color3.fromRGB(180,220,190),Success=Color3.fromRGB(50,255,100),Error=Color3.fromRGB(255,100,100),Warning=Color3.fromRGB(255,200,50)},
        Midnight={Primary=Color3.fromRGB(100,100,255),Background=Color3.fromRGB(5,5,15),Surface=Color3.fromRGB(15,15,30),SurfaceLight=Color3.fromRGB(25,25,50),Text=Color3.fromRGB(200,200,255),TextDark=Color3.fromRGB(120,120,180),Success=Color3.fromRGB(100,255,150),Error=Color3.fromRGB(255,80,80),Warning=Color3.fromRGB(255,180,50)},
        Sunset={Primary=Color3.fromRGB(255,100,50),Background=Color3.fromRGB(40,20,30),Surface=Color3.fromRGB(60,30,45),SurfaceLight=Color3.fromRGB(80,40,60),Text=Color3.fromRGB(255,220,200),TextDark=Color3.fromRGB(200,150,150),Success=Color3.fromRGB(100,255,150),Error=Color3.fromRGB(255,80,80),Warning=Color3.fromRGB(255,200,50)},
        Ocean={Primary=Color3.fromRGB(0,150,255),Background=Color3.fromRGB(10,25,40),Surface=Color3.fromRGB(20,40,65),SurfaceLight=Color3.fromRGB(30,55,90),Text=Color3.fromRGB(200,230,255),TextDark=Color3.fromRGB(130,170,200),Success=Color3.fromRGB(0,255,150),Error=Color3.fromRGB(255,100,100),Warning=Color3.fromRGB(255,200,50)},
        Matrix={Primary=Color3.fromRGB(0,255,0),Background=Color3.fromRGB(0,10,0),Surface=Color3.fromRGB(0,20,0),SurfaceLight=Color3.fromRGB(0,35,0),Text=Color3.fromRGB(0,255,0),TextDark=Color3.fromRGB(0,180,0),Success=Color3.fromRGB(50,255,50),Error=Color3.fromRGB(255,50,50),Warning=Color3.fromRGB(200,255,0)},
        Gold={Primary=Color3.fromRGB(255,215,0),Background=Color3.fromRGB(30,25,15),Surface=Color3.fromRGB(50,42,25),SurfaceLight=Color3.fromRGB(70,58,35),Text=Color3.fromRGB(255,240,200),TextDark=Color3.fromRGB(200,180,130),Success=Color3.fromRGB(150,255,100),Error=Color3.fromRGB(255,100,100),Warning=Color3.fromRGB(255,200,50)}
    }
}

-- NOTIFICATIONS
local Notif = {Queue={},Active={},Max=5}
function Notif.Show(title,msg,dur,type)
    type=type or "info" dur=dur or 3
    table.insert(Notif.Queue,{Title=title,Message=msg,Duration=dur,Type=type})
    Notif.Process()
end
function Notif.Process()
    while #Notif.Queue>0 and #Notif.Active<Notif.Max do
        local n=table.remove(Notif.Queue,1) Notif.Create(n)
    end
end
function Notif.Create(data)
    local theme=Config.Themes[Config.CurrentTheme]
    local colors={success=theme.Success,error=theme.Error,warning=theme.Warning,info=theme.Info or theme.Primary}
    local icons={success="✓",error="✗",warning="⚠",info="ℹ"}
    local gui=Instance.new("ScreenGui") gui.Name="Notif_"..tick() gui.ResetOnSpawn=false gui.Parent=game.CoreGui
    local frame=Instance.new("Frame") frame.Size=UDim2.new(0,300,0,0) frame.BackgroundColor3=theme.Surface frame.Parent=gui
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,10)
    local stroke=Instance.new("UIStroke") stroke.Color=colors[data.Type] stroke.Thickness=2 stroke.Parent=frame
    local icon=Instance.new("TextLabel") icon.Size=UDim2.new(0,35,0,35) icon.Position=UDim2.new(0,10,0,10) icon.BackgroundColor3=colors[data.Type] icon.Text=icons[data.Type] icon.TextColor3=Color3.new(1,1,1) icon.Font=Enum.Font.GothamBold icon.TextSize=18 icon.Parent=frame Instance.new("UICorner",icon).CornerRadius=UDim.new(0,8)
    local title=Instance.new("TextLabel") title.Size=UDim2.new(1,-60,0,20) title.Position=UDim2.new(0,55,0,8) title.Text=data.Title title.TextColor3=colors[data.Type] title.Font=Enum.Font.GothamBold title.TextSize=13 title.TextXAlignment=Enum.TextXAlignment.Left title.Parent=frame
    local msg=Instance.new("TextLabel") msg.Size=UDim2.new(1,-60,0,40) msg.Position=UDim2.new(0,55,0,28) msg.Text=data.Message msg.TextColor3=theme.Text msg.Font=Enum.Font.Gotham msg.TextSize=11 msg.TextWrapped=true msg.TextXAlignment=Enum.TextXAlignment.Left msg.Parent=frame
    local prog=Instance.new("Frame") prog.Size=UDim2.new(1,0,0,3) prog.Position=UDim2.new(0,0,1,-3) prog.BackgroundColor3=colors[data.Type] prog.Parent=frame
    table.insert(Notif.Active,gui) local yOff=-20-(#Notif.Active-1)*85 gui.Position=UDim2.new(1,-320,1,0)+UDim2.new(0,0,0,yOff)
    TweenService:Create(frame,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Size=UDim2.new(0,300,0,75)}):Play()
    TweenService:Create(prog,TweenInfo.new(data.Duration,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,3)}):Play()
    task.delay(data.Duration,function()
        TweenService:Create(frame,TweenInfo.new(0.3),{Size=UDim2.new(0,300,0,0)}):Play() task.wait(0.3)
        for i,g in ipairs(Notif.Active) do if g==gui then table.remove(Notif.Active,i) break end end
        gui:Destroy() Notif.Repos() Notif.Process()
    end)
end
function Notif.Repos() for i,g in ipairs(Notif.Active) do TweenService:Create(g,TweenInfo.new(0.3),{Position=UDim2.new(1,-320,1,0)+UDim2.new(0,0,0,-20-(i-1)*85)}):Play() end end

-- REMOTES
local Remotes={All={},ByName={},ByCategory={Weapon={},Train={},Class={},Economy={},Combat={},Social={},System={}}}
function Remotes.Scan()
    local function Scan(folder)
        for _,obj in pairs(folder:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("UnreliableRemoteEvent") then
                local data={Object=obj,Name=obj.Name,Path=obj:GetFullName(),Type=obj:IsA("UnreliableRemoteEvent") and "Unreliable" or "Reliable"}
                table.insert(Remotes.All,data) Remotes.ByName[obj.Name]=data
                local n,pn=obj.Name,obj.Parent and obj.Parent.Name or ""
                if n=="Shoot" or n=="Reload" or n=="ReplicateShot" then table.insert(Remotes.ByCategory.Weapon,data)
                elseif n:find("Train") then table.insert(Remotes.ByCategory.Train,data)
                elseif n:find("Class") then table.insert(Remotes.ByCategory.Class,data)
                elseif n:find("Money") or n:find("Buy") or n:find("Bonds") then table.insert(Remotes.ByCategory.Economy,data)
                elseif n:find("Hit") or n:find("Hurt") or n:find("Melee") then table.insert(Remotes.ByCategory.Combat,data)
                elseif n:find("Party") then table.insert(Remotes.ByCategory.Social,data)
                else table.insert(Remotes.ByCategory.System,data) end
            end
        end
    end
    Scan(RS) Scan(Workspace)
end
function Remotes.Fire(name,...) local r=Remotes.ByName[name] if r then pcall(function() r.Object:FireServer(...) end) end end

-- ESP
local ESP={Enabled=false,Players=true,NPCs=false,Boxes=true,Names=true,Distance=true,Health=true,HealthBar=true,Tracers=false,TeamCheck=false,MaxDistance=1000,Objects={}}
function ESP.Create(obj,typ)
    if not obj or ESP.Objects[obj] then return end
    local e={Object=obj,Type=typ,Components={}}
    local c=typ=="player" and Color3.fromRGB(255,50,50) or Color3.fromRGB(255,165,0)
    e.Components.Box=Drawing.new("Square") e.Components.Box.Visible=false e.Components.Box.Thickness=2 e.Components.Box.Color=c
    e.Components.BoxFill=Drawing.new("Square") e.Components.BoxFill.Visible=false e.Components.BoxFill.Filled=true e.Components.BoxFill.Transparency=0.1 e.Components.BoxFill.Color=c
    e.Components.Name=Drawing.new("Text") e.Components.Name.Visible=false e.Components.Name.Size=13 e.Components.Name.Color=Color3.new(1,1,1) e.Components.Name.Center=true e.Components.Name.Outline=true
    e.Components.Dist=Drawing.new("Text") e.Components.Dist.Visible=false e.Components.Dist.Size=11 e.Components.Dist.Color=Color3.fromRGB(200,200,200) e.Components.Dist.Center=true e.Components.Dist.Outline=true
    e.Components.Health=Drawing.new("Text") e.Components.Health.Visible=false e.Components.Health.Size=11 e.Components.Health.Color=Color3.fromRGB(0,255,0) e.Components.Health.Center=true e.Components.Health.Outline=true
    e.Components.HpBg=Drawing.new("Square") e.Components.HpBg.Visible=false e.Components.HpBg.Filled=true e.Components.HpBg.Color=Color3.fromRGB(50,50,50)
    e.Components.HpBar=Drawing.new("Square") e.Components.HpBar.Visible=false e.Components.HpBar.Filled=true
    e.Components.Tracer=Drawing.new("Line") e.Components.Tracer.Visible=false e.Components.Tracer.Thickness=1 e.Components.Tracer.Color=c e.Components.Tracer.Transparency=0.7
    ESP.Objects[obj]=e
end
function ESP.Update()
    if not ESP.Enabled then for _,e in pairs(ESP.Objects) do for _,c in pairs(e.Components) do c.Visible=false end end return end
    for obj,e in pairs(ESP.Objects) do
        if not obj or not obj.Parent then ESP.Objects[obj]=nil for _,c in pairs(e.Components) do c:Remove() end continue end
        local hum,hrp,head=obj:FindFirstChild("Humanoid"),obj:FindFirstChild("HumanoidRootPart"),obj:FindFirstChild("Head")
        if hrp then
            local pos=hrp.Position local sp,on=Camera:WorldToViewportPoint(pos) local dist=(Camera.CFrame.Position-pos).Magnitude
            if on and dist<=ESP.MaxDistance and (not hum or hum.Health>0) then
                local size=Vector3.new(4,6,0) local tp=Camera:WorldToViewportPoint((hrp.CFrame*CFrame.new(0,size.Y/2,0)).Position) local bp=Camera:WorldToViewportPoint((hrp.CFrame*CFrame.new(0,-size.Y/2,0)).Position)
                local h=math.abs(tp.Y-bp.Y) local w=h/2 local bs=Vector2.new(w,h) local bp2=Vector2.new(sp.X-w/2,sp.Y-h/2)
                e.Components.Box.Visible=true e.Components.Box.Size=bs e.Components.Box.Position=bp2
                e.Components.BoxFill.Visible=true e.Components.BoxFill.Size=bs e.Components.BoxFill.Position=bp2
                e.Components.Name.Visible=true e.Components.Name.Position=Vector2.new(sp.X,bp2.Y-18) e.Components.Name.Text=obj.Name
                e.Components.Dist.Visible=true e.Components.Dist.Position=Vector2.new(sp.X,bp2.Y+bs.Y+5) e.Components.Dist.Text=math.floor(dist).."m"
                if hum then
                    local hp=hum.Health/hum.MaxHealth
                    e.Components.Health.Visible=true e.Components.Health.Position=Vector2.new(sp.X,bp2.Y+bs.Y+18) e.Components.Health.Text=math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) e.Components.Health.Color=Color3.fromRGB(255*(1-hp),255*hp,0)
                    e.Components.HpBg.Visible=true e.Components.HpBg.Size=Vector2.new(4,bs.Y) e.Components.HpBg.Position=Vector2.new(bp2.X-10,bp2.Y)
                    e.Components.HpBar.Visible=true e.Components.HpBar.Size=Vector2.new(4,bs.Y*hp) e.Components.HpBar.Position=Vector2.new(bp2.X-10,bp2.Y+bs.Y-bs.Y*hp) e.Components.HpBar.Color=Color3.fromRGB(255*(1-hp),255*hp,0)
                end
                if ESP.Tracers then e.Components.Tracer.Visible=true e.Components.Tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y) e.Components.Tracer.To=Vector2.new(sp.X,bp2.Y+bs.Y) end
            else for _,c in pairs(e.Components) do c.Visible=false end end
        end
    end
end
function ESP.ScanP() for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then if not ESP.TeamCheck or p.Team~=LocalPlayer.Team then ESP.Create(p.Character,"player") end end end end
function ESP.ScanN() for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(o) then ESP.Create(o,"npc") end end end
function ESP.Clear() for o,_ in pairs(ESP.Objects) do local e=ESP.Objects[o] for _,c in pairs(e.Components) do c:Remove() end end ESP.Objects={} end

-- AIMBOT
local Aimbot={Enabled=false,Mode="Closest",Part="Head",FOV=100,Smoothness=0.5,TeamCheck=true,ShowFOV=true}
function Aimbot.GetTarget()
    local closest,minScore=nil,math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            if Aimbot.TeamCheck and p.Team==LocalPlayer.Team then continue end
            local part=p.Character:FindFirstChild(Aimbot.Part) local hum=p.Character:FindFirstChild("Humanoid")
            if part and hum and hum.Health>0 then
                local sp=Camera:WorldToViewportPoint(part.Position) local dist=(part.Position-Camera.CFrame.Position).Magnitude
                if sp.Z>0 then
                    local score=Aimbot.Mode=="Closest" and dist or (Aimbot.Mode=="Mouse" and (Vector2.new(sp.X,sp.Y)-Vector2.new(Mouse.X,Mouse.Y)).Magnitude or hum.Health)
                    if score<minScore and (Aimbot.Mode~="Mouse" or score<=Aimbot.FOV) then minScore,closest=score,part end
                end
            end
        end
    end
    return closest
end
function Aimbot.Aim(t) if t then Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,t.Position),Aimbot.Smoothness) end end

-- AUTOFARM
local Farm={Enabled=false,Mode="NPC",Range=100,AutoShoot=true,AutoAim=true,InstantKill=false,AutoCollect=true,SmartTarget=true,Loop=false,Stats={Kills=0,Money=0,Start=0}}
function Farm.GetTarget()
    local targets={}
    if Farm.Mode=="NPC" then
        for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") and o:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(o) and o.Humanoid.Health>0 then local d=(LocalPlayer.Character.HumanoidRootPart.Position-o.HumanoidRootPart.Position).Magnitude if d<=Farm.Range then table.insert(targets,{Object=o,Distance=d,Health=o.Humanoid.Health}) end end end
    else
        for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local hum=p.Character:FindFirstChild("Humanoid") if hum and hum.Health>0 and (not ESP.TeamCheck or p.Team~=LocalPlayer.Team) then local d=(LocalPlayer.Character.HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude if d<=Farm.Range then table.insert(targets,{Object=p.Character,Distance=d,Health=hum.Health}) end end end end
    end
    table.sort(targets,Farm.SmartTarget and function(a,b) return a.Distance<b.Distance end or function(a,b) return a.Health<b.Health end)
    return targets[1] and targets[1].Object or nil
end
function Farm.Shoot(t)
    if not t or not LocalPlayer.Character then return end
    local tp=t:FindFirstChild("Head") or t:FindFirstChild("HumanoidRootPart")
    if tp and Farm.AutoAim and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position,Vector3.new(tp.Position.X,LocalPlayer.Character.HumanoidRootPart.Position.Y,tp.Position.Z)) end
    for _,r in pairs(Remotes.ByCategory.Weapon) do if r.Name=="Shoot" then pcall(function() r.Object:FireServer(tp.Position,tp) end) end end
end
function Farm.Start()
    if Farm.Loop then return end Farm.Loop=true Farm.Stats.Start=tick()
    Notif.Show("Auto-Farm","Started: "..Farm.Mode.." mode",3,"success")
    task.spawn(function() while Farm.Enabled and Farm.Loop do if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then local t=Farm.GetTarget() if t then if Farm.AutoShoot then Farm.Shoot(t) end if Farm.InstantKill then local hum=t:FindFirstChild("Humanoid") if hum and hum.Health>0 then hum.Health=0 Farm.Stats.Kills=Farm.Stats.Kills+1 end end end if Farm.AutoCollect then for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("BasePart") and (o.Name:lower():find("money") or o.Name:lower():find("drop")) then if (LocalPlayer.Character.HumanoidRootPart.Position-o.Position).Magnitude<=50 then pcall(function() o.CFrame=LocalPlayer.Character.HumanoidRootPart.CFrame end) end end end end end task.wait(0.05) end Farm.Loop=false end)
end
function Farm.Stop() Farm.Enabled=false Notif.Show("Auto-Farm","Stopped. Kills: "..Farm.Stats.Kills,3,"warning") end

-- GODMODE
local God={Enabled=false,InfiniteHealth=true,NoRagdoll=true,AutoRevive=true,Connections={}}
function God.Enable()
    if not LocalPlayer.Character then return end local hum=LocalPlayer.Character:FindFirstChild("Humanoid") if not hum then return end
    if God.InfiniteHealth then table.insert(God.Connections,hum.HealthChanged:Connect(function(h) if God.Enabled and h<hum.MaxHealth then hum.Health=hum.MaxHealth end end)) end
    if God.AutoRevive then table.insert(God.Connections,hum.Died:Connect(function() if God.Enabled then task.wait(2) Remotes.Fire("RevivePlayer") end end)) end
    Notif.Show("God Mode","All protections active",3,"success")
end
function God.Disable() God.Enabled=false for _,c in pairs(God.Connections) do c:Disconnect() end God.Connections={} end

-- TELEPORT
local Tele={History={},Max=10}
function Tele.To(pos) if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end table.insert(Tele.History,1,LocalPlayer.Character.HumanoidRootPart.CFrame) if #Tele.History>Tele.Max then table.remove(Tele.History) end LocalPlayer.Character.HumanoidRootPart.CFrame=typeof(pos)=="CFrame" and pos or CFrame.new(pos) end
function Tele.ToPlayer(p) if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then Tele.To(p.Character.HumanoidRootPart.CFrame) Notif.Show("Teleport","Teleported to "..p.Name,2,"success") end end
function Tele.Undo() if #Tele.History>0 then Tele.To(table.remove(Tele.History,1)) Notif.Show("Teleport","Undo successful",2,"info") end end

-- WEAPON MODS
local Wep={InfiniteAmmo=false,RapidFire=false,NoRecoil=false,NoSpread=false,InstantReload=false,DamageMult=1}
function Wep.Apply() if not LocalPlayer.Character then return end for _,t in pairs(LocalPlayer.Character:GetChildren()) do if t:IsA("Tool") then local cfg=t:FindFirstChild("Configuration") or t:FindFirstChild("Config") or t:FindFirstChild("Settings") if cfg then for _,s in pairs(cfg:GetChildren()) do local n=s.Name:lower() if Wep.InfiniteAmmo and (n:find("ammo") or n:find("bullet")) and (s:IsA("IntValue") or s:IsA("NumberValue")) then s.Value=9999 end if Wep.NoRecoil and n:find("recoil") and s:IsA("NumberValue") then s.Value=0 end if Wep.NoSpread and n:find("spread") and s:IsA("NumberValue") then s.Value=0 end if Wep.InstantReload and n:find("reload") and s:IsA("NumberValue") then s.Value=0.01 end if n:find("damage") and (s:IsA("IntValue") or s:IsA("NumberValue")) then s.Value=s.Value*Wep.DamageMult end end end end end end

-- GUI
local function CreateGUI()
    local theme=Config.Themes[Config.CurrentTheme]
    local gui=Instance.new("ScreenGui") gui.Name="RingtaMega" gui.ResetOnSpawn=false gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=game.CoreGui
    local wm=Instance.new("TextLabel") wm.Size=UDim2.new(0,280,0,25) wm.Position=UDim2.new(0,10,0,10) wm.BackgroundTransparency=1 wm.Text="⚡ OPEN RINGTA MEGA v"..Config.Version wm.TextColor3=theme.Primary wm.Font=Enum.Font.GothamBold wm.TextSize=14 wm.Parent=gui
    local mf=Instance.new("Frame") mf.Name="Main" mf.Size=UDim2.new(0,950,0,600) mf.Position=UDim2.new(0.5,-475,0.5,-300) mf.BackgroundColor3=theme.Background mf.BorderSizePixel=0 mf.ClipsDescendants=true mf.Parent=gui Instance.new("UICorner",mf).CornerRadius=UDim.new(0,14)
    local sh=Instance.new("ImageLabel") sh.Size=UDim2.new(1,60,1,60) sh.Position=UDim2.new(0,-30,0,-30) sh.BackgroundTransparency=1 sh.Image="rbxassetid://5554236805" sh.ImageColor3=Color3.new(0,0,0) sh.ImageTransparency=0.5 sh.ScaleType=Enum.ScaleType.Slice sh.SliceCenter=Rect.new(23,23,277,277) sh.ZIndex=-1 sh.Parent=mf
    local tb=Instance.new("Frame") tb.Size=UDim2.new(1,0,0,48) tb.BackgroundColor3=theme.Surface tb.Parent=mf Instance.new("UICorner",tb).CornerRadius=UDim.new(0,14)
    local tl=Instance.new("TextLabel") tl.Size=UDim2.new(0,300,1,0) tl.Position=UDim2.new(0,18,0,0) tl.BackgroundTransparency=1 tl.Text="⚡ OPEN RINGTA MEGA" tl.TextColor3=theme.Primary tl.Font=Enum.Font.GothamBold tl.TextSize=18 tl.TextXAlignment=Enum.TextXAlignment.Left tl.Parent=tb
    local cb=Instance.new("TextButton") cb.Size=UDim2.new(0,32,0,32) cb.Position=UDim2.new(1,-45,0.5,-16) cb.BackgroundColor3=theme.Error cb.Text="×" cb.TextColor3=Color3.new(1,1,1) cb.Font=Enum.Font.GothamBold cb.TextSize=18 cb.Parent=tb Instance.new("UICorner",cb).CornerRadius=UDim.new(0,8)
    cb.MouseButton1Click:Connect(function() gui:Destroy() Farm.Stop() ESP.Clear() God.Disable() end)
    local sb=Instance.new("Frame") sb.Size=UDim2.new(0,200,1,-48) sb.Position=UDim2.new(0,0,0,48) sb.BackgroundColor3=theme.Surface sb.Parent=mf
    local cf=Instance.new("Frame") cf.Size=UDim2.new(1,-200,1,-48) cf.Position=UDim2.new(0,200,0,48) cf.BackgroundTransparency=1 cf.Parent=mf
    local con=Instance.new("Frame") con.Size=UDim2.new(1,-220,0,160) con.Position=UDim2.new(0,210,1,-170) con.BackgroundColor3=theme.Surface con.Parent=mf Instance.new("UICorner",con).CornerRadius=UDim.new(0,10)
    local ct=Instance.new("TextLabel") ct.Size=UDim2.new(1,0,0,26) ct.BackgroundColor3=theme.SurfaceLight ct.Text="  📋 Console" ct.TextColor3=theme.Text ct.Font=Enum.Font.GothamBold ct.TextSize=12 ct.TextXAlignment=Enum.TextXAlignment.Left ct.Parent=con Instance.new("UICorner",ct).CornerRadius=UDim.new(0,10)
    local cs=Instance.new("ScrollingFrame") cs.Size=UDim2.new(1,-10,1,-32) cs.Position=UDim2.new(0,5,0,30) cs.BackgroundTransparency=1 cs.ScrollBarThickness=3 cs.Parent=con
    local logs={} function Log(msg,type) type=type or "info" table.insert(logs,1,{m=msg,t=type,time=os.date("%H:%M:%S")}) if #logs>50 then table.remove(logs) end for _,c in pairs(cs:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end for _,l in pairs(logs) do local tl=Instance.new("TextLabel") tl.Size=UDim2.new(1,0,0,16) tl.BackgroundTransparency=1 tl.Text="["..l.time.."] "..l.m tl.TextColor3=l.t=="error" and theme.Error or l.t=="success" and theme.Success or l.t=="warning" and theme.Warning or theme.Text tl.Font=Enum.Font.Code tl.TextSize=10 tl.TextXAlignment=Enum.TextXAlignment.Left tl.Parent=cs end cs.CanvasPosition=Vector2.new(0,cs.AbsoluteCanvasSize.Y) end
    local tabs={{N="Main",I="🏠",D="Quick Actions"},{N="Combat",I="⚔️",D="God & Weapons"},{N="ESP",I="👁️",D="Visuals"},{N="Aimbot",I="🎯",D="Auto-Aim"},{N="Farm",I="🤖",D="Auto-Farm"},{N="Tele",I="🌀",D="Teleport"},{N="Train",I="🚂",D="Train/Class"},{N="Misc",I="⚙️",D="Misc"}}
    local tbs,tcs,cur={},{} nil
    for _,ti in pairs(tabs) do local tc=Instance.new("ScrollingFrame") tc.Size=UDim2.new(1,-20,1,-180) tc.Position=UDim2.new(0,10,0,10) tc.BackgroundTransparency=1 tc.ScrollBarThickness=3 tc.AutomaticCanvasSize=Enum.AutomaticSize.Y tc.Visible=false tc.Parent=cf Instance.new("UIListLayout",tc).Padding=UDim.new(0,10) tcs[ti.N]=tc end
    for i,ti in pairs(tabs) do local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,-16,0,42) btn.Position=UDim2.new(0,8,0,8+(i-1)*50) btn.BackgroundColor3=i==1 and theme.Primary or theme.SurfaceLight btn.Text="" btn.Parent=sb Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
        local ic=Instance.new("TextLabel") ic.Size=UDim2.new(0,26,0,26) ic.Position=UDim2.new(0,10,0.5,-13) ic.BackgroundTransparency=1 ic.Text=ti.I ic.TextSize=16 ic.Parent=btn
        local nm=Instance.new("TextLabel") nm.Size=UDim2.new(1,-45,0,18) nm.Position=UDim2.new(0,40,0,4) nm.BackgroundTransparency=1 nm.Text=ti.N nm.TextColor3=i==1 and Color3.new(1,1,1) or theme.Text nm.Font=Enum.Font.GothamBold nm.TextSize=13 nm.TextXAlignment=Enum.TextXAlignment.Left nm.Parent=btn
        local dc=Instance.new("TextLabel") dc.Size=UDim2.new(1,-45,0,14) dc.Position=UDim2.new(0,40,0,22) dc.BackgroundTransparency=1 dc.Text=ti.D dc.TextColor3=i==1 and Color3.fromRGB(220,220,220) or theme.TextDark dc.Font=Enum.Font.Gotham dc.TextSize=9 dc.TextXAlignment=Enum.TextXAlignment.Left dc.Parent=btn
        tbs[ti.N]={B=btn,N=nm,D=dc}
        btn.MouseButton1Click:Connect(function() if cur==ti.N then return end for n,d in pairs(tbs) do TweenService:Create(d.B,TweenInfo.new(0.2),{BackgroundColor3=theme.SurfaceLight}):Play() d.N.TextColor3=theme.Text d.D.TextColor3=theme.TextDark tcs[n].Visible=false end TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3=theme.Primary}):Play() nm.TextColor3=Color3.new(1,1,1) dc.TextColor3=Color3.fromRGB(220,220,220) tcs[ti.N].Visible=true cur=ti.N end)
    end
    cur="Main" tcs["Main"].Visible=true
    local function Sec(p,t,i) local s=Instance.new("Frame") s.Size=UDim2.new(1,0,0,0) s.AutomaticSize=Enum.AutomaticSize.Y s.BackgroundColor3=theme.Surface s.Parent=p Instance.new("UICorner",s).CornerRadius=UDim.new(0,10)
        local tf=Instance.new("Frame") tf.Size=UDim2.new(1,0,0,32) tf.BackgroundColor3=theme.SurfaceLight tf.Parent=s Instance.new("UICorner",tf).CornerRadius=UDim.new(0,10)
        local ttl=Instance.new("TextLabel") ttl.Size=UDim2.new(1,-20,1,0) ttl.Position=UDim2.new(0,12,0,0) ttl.BackgroundTransparency=1 ttl.Text=(i or "").." "..t ttl.TextColor3=theme.Primary ttl.Font=Enum.Font.GothamBold ttl.TextSize=13 ttl.TextXAlignment=Enum.TextXAlignment.Left ttl.Parent=tf
        local c=Instance.new("Frame") c.Name="C" c.Size=UDim2.new(1,-16,0,0) c.Position=UDim2.new(0,8,0,36) c.AutomaticSize=Enum.AutomaticSize.Y c.BackgroundTransparency=1 c.Parent=s Instance.new("UIListLayout",c).Padding=UDim.new(0,6) Instance.new("UIPadding",s).PaddingBottom=UDim.new(0,10) return s,c
    end
    local function Tog(p,t,cb,d) local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,34) f.BackgroundTransparency=1 f.Parent=p
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-65,1,0) l.BackgroundTransparency=1 l.Text=t l.TextColor3=theme.Text l.Font=Enum.Font.Gotham l.TextSize=12 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=f
        local b=Instance.new("Frame") b.Size=UDim2.new(0,50,0,26) b.Position=UDim2.new(1,-50,0.5,-13) b.BackgroundColor3=d and theme.Success or theme.Error b.Parent=f Instance.new("UICorner",b).CornerRadius=UDim.new(0,13)
        local c=Instance.new("Frame") c.Size=UDim2.new(0,20,0,20) c.Position=d and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10) c.BackgroundColor3=Color3.new(1,1,1) c.Parent=b Instance.new("UICorner",c).CornerRadius=UDim.new(1,0)
        local e=d or false local ca=Instance.new("TextButton") ca.Size=UDim2.new(1,0,1,0) ca.BackgroundTransparency=1 ca.Text="" ca.Parent=f
        ca.MouseButton1Click:Connect(function() e=not e TweenService:Create(b,TweenInfo.new(0.2),{BackgroundColor3=e and theme.Success or theme.Error}):Play() TweenService:Create(c,TweenInfo.new(0.2),{Position=e and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}):Play() cb(e) end)
    end
    local function Btn(p,t,cb,c) local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,0,36) b.BackgroundColor3=c or theme.Primary b.Text=t b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.GothamBold b.TextSize=12 b.Parent=p Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
        b.MouseButton1Click:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{Size=UDim2.new(0.98,0,0,36)}):Play() task.wait(0.1) TweenService:Create(b,TweenInfo.new(0.1),{Size=UDim2.new(1,0,0,36)}):Play() cb() end)
    end
    local function Sld(p,t,min,max,def,cb) local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,48) f.BackgroundTransparency=1 f.Parent=p
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-50,0,18) l.BackgroundTransparency=1 l.Text=t l.TextColor3=theme.Text l.Font=Enum.Font.Gotham l.TextSize=12 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=f
        local vl=Instance.new("TextLabel") vl.Size=UDim2.new(0,40,0,18) vl.Position=UDim2.new(1,-40,0,0) vl.BackgroundTransparency=1 vl.Text=tostring(def) vl.TextColor3=theme.Primary vl.Font=Enum.Font.GothamBold vl.TextSize=12 vl.Parent=f
        local bg=Instance.new("Frame") bg.Size=UDim2.new(1,0,0,8) bg.Position=UDim2.new(0,0,0,28) bg.BackgroundColor3=theme.SurfaceLight bg.Parent=f Instance.new("UICorner",bg).CornerRadius=UDim.new(0,4)
        local fl=Instance.new("Frame") fl.Size=UDim2.new((def-min)/(max-min),0,1,0) fl.BackgroundColor3=theme.Primary fl.Parent=bg Instance.new("UICorner",fl).CornerRadius=UDim.new(0,4)
        local v,drg=def,false
        bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drg=true end end)
        UIS.InputChanged:Connect(function(i) if drg and i.UserInputType==Enum.UserInputType.MouseMovement then local pos=math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1) v=math.floor(min+(max-min)*pos) vl.Text=tostring(v) fl.Size=UDim2.new(pos,0,1,0) cb(v) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drg=false end end)
    end
    local function Drd(p,t,opts,cb) local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,40) f.BackgroundColor3=theme.SurfaceLight f.Parent=p Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-35,1,0) l.Position=UDim2.new(0,12,0,0) l.BackgroundTransparency=1 l.Text=t..": "..opts[1] l.TextColor3=theme.Text l.Font=Enum.Font.Gotham l.TextSize=12 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=f
        local a=Instance.new("TextLabel") a.Size=UDim2.new(0,20,1,0) a.Position=UDim2.new(1,-25,0,0) a.BackgroundTransparency=1 a.Text="▼" a.TextColor3=theme.TextDark a.Font=Enum.Font.Gotham a.TextSize=11 a.Parent=f
        local ex,of=false,nil
        f.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ex=not ex if ex then of=Instance.new("Frame") of.Size=UDim2.new(1,0,0,#opts*28) of.Position=UDim2.new(0,0,1,4) of.BackgroundColor3=theme.SurfaceLight of.ZIndex=10 of.Parent=f Instance.new("UICorner",of).CornerRadius=UDim.new(0,6)
            for i,o in pairs(opts) do local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,0,28) b.Position=UDim2.new(0,0,0,(i-1)*28) b.BackgroundTransparency=1 b.Text=o b.TextColor3=theme.Text b.Font=Enum.Font.Gotham b.TextSize=11 b.ZIndex=11 b.Parent=of b.MouseButton1Click:Connect(function() l.Text=t..": "..o cb(o) ex=false if of then of:Destroy() end a.Text="▼" end) end a.Text="▲"
            else if of then of:Destroy() end a.Text="▼" end end end)
    end
    -- MAIN TAB
    local ms,mc=Sec(tcs["Main"],"Quick Actions","⚡")
    Btn(mc,"▶ Start Auto-Farm NPC",function() Farm.Mode="NPC" Farm.Enabled=true Farm.Start() end,theme.Success)
    Btn(mc,"▶ Start Auto-Farm Players",function() Farm.Mode="Player" Farm.Enabled=true Farm.Start() end,theme.Warning)
    Btn(mc,"⏹ Stop Auto-Farm",function() Farm.Stop() end,theme.Error)
    Tog(mc,"Enable ESP",function(e) ESP.Enabled=e if e then ESP.ScanP() Notif.Show("ESP","Enabled",2,"success") end end,false)
    Tog(mc,"God Mode",function(e) God.Enabled=e if e then God.Enable() else God.Disable() end end,false)
    Tog(mc,"Aimbot",function(e) Aimbot.Enabled=e Notif.Show("Aimbot",e and "Enabled" or "Disabled",2,e and "success" or "warning") end,false)
    local ss,sc=Sec(tcs["Main"],"Statistics","📊")
    local st=Instance.new("TextLabel") st.Size=UDim2.new(1,0,0,80) st.BackgroundTransparency=1 st.Text="Kills: 0\nSession: 0s\nRemotes: 0" st.TextColor3=theme.Text st.Font=Enum.Font.Code st.TextSize=11 st.TextYAlignment=Enum.TextYAlignment.Top st.Parent=sc
    task.spawn(function() while gui.Parent do st.Text=string.format("Kills: %d\nSession: %ds\nRemotes: %d",Farm.Stats.Kills,Farm.Stats.Start>0 and math.floor(tick()-Farm.Stats.Start) or 0,#Remotes.All) task.wait(1) end end)
    -- COMBAT TAB
    local gs,gc=Sec(tcs["Combat"],"God Mode","🛡️")
    Tog(gc,"Infinite Health",function(e) God.InfiniteHealth=e end,true)
    Tog(gc,"Auto Revive",function(e) God.AutoRevive=e end,true)
    local ws,wc=Sec(tcs["Combat"],"Weapon Mods","🔫")
    Tog(wc,"Infinite Ammo",function(e) Wep.InfiniteAmmo=e Wep.Apply() end,false)
    Tog(wc,"No Recoil",function(e) Wep.NoRecoil=e Wep.Apply() end,false)
    Tog(wc,"No Spread",function(e) Wep.NoSpread=e Wep.Apply() end,false)
    Tog(wc,"Instant Reload",function(e) Wep.InstantReload=e Wep.Apply() end,false)
    Sld(wc,"Damage Multiplier",1,10,1,function(v) Wep.DamageMult=v Wep.Apply() end)
    -- ESP TAB
    local es,ec=Sec(tcs["ESP"],"ESP Settings","👁️")
    Tog(ec,"Enable ESP",function(e) ESP.Enabled=e if e then ESP.ScanP() end end,false)
    Tog(ec,"Show Players",function(e) ESP.Players=e if e then ESP.ScanP() end end,true)
    Tog(ec,"Show NPCs",function(e) ESP.NPCs=e if e then ESP.ScanN() end end,false)
    Tog(ec,"Boxes",function(e) ESP.Boxes=e end,true)
    Tog(ec,"Names",function(e) ESP.Names=e end,true)
    Tog(ec,"Distance",function(e) ESP.Distance=e end,true)
    Tog(ec,"Health Bar",function(e) ESP.HealthBar=e end,true)
    Tog(ec,"Tracers",function(e) ESP.Tracers=e end,false)
    Tog(ec,"Team Check",function(e) ESP.TeamCheck=e end,false)
    Sld(ec,"Max Distance",100,5000,1000,function(v) ESP.MaxDistance=v end)
    Btn(ec,"🔄 Refresh ESP",function() ESP.Clear() ESP.ScanP() if ESP.NPCs then ESP.ScanN() end Notif.Show("ESP","Refreshed",2,"success") end)
    -- AIMBOT TAB
    local as,ac=Sec(tcs["Aimbot"],"Aimbot Settings","🎯")
    Tog(ac,"Enable Aimbot",function(e) Aimbot.Enabled=e Notif.Show("Aimbot",e and "Enabled" or "Disabled",2,e and "success" or "warning") end,false)
    Drd(ac,"Target Mode",{"Closest","Mouse","Health"},function(o) Aimbot.Mode=o end)
    Drd(ac,"Target Part",{"Head","Torso","HumanoidRootPart"},function(o) Aimbot.Part=o end)
    Tog(ac,"Show FOV",function(e) Aimbot.ShowFOV=e end,true)
    Tog(ac,"Team Check",function(e) Aimbot.TeamCheck=e end,true)
    Sld(ac,"FOV Size",50,500,100,function(v) Aimbot.FOV=v end)
    Sld(ac,"Smoothness",1,100,50,function(v) Aimbot.Smoothness=v/100 end)
    -- FARM TAB
    local fs,fc=Sec(tcs["Farm"],"Auto-Farm","🤖")
    Drd(fc,"Target Mode",{"NPC","Player"},function(o) Farm.Mode=o end)
    Tog(fc,"Auto Shoot",function(e) Farm.AutoShoot=e end,true)
    Tog(fc,"Auto Aim",function(e) Farm.AutoAim=e end,true)
    Tog(fc,"Instant Kill",function(e) Farm.InstantKill=e end,false)
    Tog(fc,"Auto Collect",function(e) Farm.AutoCollect=e end,true)
    Sld(fc,"Farm Range",50,500,100,function(v) Farm.Range=v end)
    -- TELE TAB
    local ts,tc=Sec(tcs["Tele"],"Teleport","🌀")
    Btn(tc,"🎯 Teleport to Nearest",function() local c,d=nil,math.huge for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local dist=(LocalPlayer.Character.HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude if dist<d then d,c=dist,p end end end if c then Tele.ToPlayer(c) end end)
    Btn(tc,"🎲 Teleport to Random",function() local v={} for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then table.insert(v,p) end end if #v>0 then Tele.ToPlayer(v[math.random(1,#v)]) end end)
    Btn(tc,"↩️ Undo",function() Tele.Undo() end,theme.Warning)
    local ps,pc=Sec(tcs["Tele"],"Player List","👥")
    local pl=Instance.new("ScrollingFrame") pl.Size=UDim2.new(1,0,0,120) pl.BackgroundColor3=theme.SurfaceLight pl.ScrollBarThickness=3 pl.AutomaticCanvasSize=Enum.AutomaticSize.Y pl.Parent=pc Instance.new("UICorner",pl).CornerRadius=UDim.new(0,6) Instance.new("UIListLayout",pl).Padding=UDim.new(0,2)
    local function UpdP() for _,c in pairs(pl:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then local b=Instance.new("TextButton") b.Size=UDim2.new(1,-8,0,28) b.Position=UDim2.new(0,4,0,0) b.BackgroundColor3=theme.Surface b.Text=p.Name b.TextColor3=theme.Text b.Font=Enum.Font.Gotham b.TextSize=11 b.Parent=pl Instance.new("UICorner",b).CornerRadius=UDim.new(0,4) b.MouseButton1Click:Connect(function() Tele.ToPlayer(p) end) end end end
    UpdP() Players.PlayerAdded:Connect(UpdP) Players.PlayerRemoving:Connect(UpdP)
    -- TRAIN TAB
    local trs,trc=Sec(tcs["Train"],"Train System","🚂")
    Btn(trc,"🔓 Unlock All Trains",function() Remotes.Fire("GetTrains") Notif.Show("Train","Unlocking...",3,"info") end)
    Btn(trc,"🔓 Unlock All Classes",function() Remotes.Fire("GetClasses") Notif.Show("Class","Unlocking...",3,"info") end)
    -- MISC TAB
    local mis,mic=Sec(tcs["Misc"],"Miscellaneous","⚙️")
    Tog(mic,"Anti-AFK",function(e) if e then LocalPlayer.Idled:Connect(function() game:GetService("VirtualUser"):CaptureController() game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end) end end,false)
    Btn(mic,"🌧️ Toggle Weather",function() Remotes.Fire("ToggleWeather") end)
    Btn(mic,"🛸 Spawn UFO",function() Remotes.Fire("SpawnUFO") end)
    Btn(mic,"🏠 Return to Lobby",function() Remotes.Fire("ReturnToLooby") end,theme.Error)
    Btn(mic,"🗑️ Clear Console",function() logs={} for _,c in pairs(cs:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end end)
    -- DRAG
    local drg,ds,dp=false,nil,nil
    tb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drg=true ds=i.Position dp=mf.Position end end)
    UIS.InputChanged:Connect(function(i) if drg and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds mf.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drg=false end end)
    -- KEYBIND
    UIS.InputBegan:Connect(function(i,g) if not g and i.KeyCode==Config.Keybind then mf.Visible=not mf.Visible end end)
    -- ANIM
    mf.Size=UDim2.new(0,0,0,0) TweenService:Create(mf,TweenInfo.new(0.6,Enum.EasingStyle.Back),{Size=UDim2.new(0,950,0,600)}):Play()
    Log("Open Ringta Mega v"..Config.Version.." loaded!","success") Log("Game: Ugc (70876832253163)","info") Log("Press F4 to toggle UI","info")
    Notif.Show("Open Ringta Mega","Welcome! Press F4 to toggle UI",5,"success")
    return gui
end

-- INIT
Remotes.Scan()
CreateGUI()
RunService.RenderStepped:Connect(function() ESP.Update() if Aimbot.Enabled then Aimbot.Aim(Aimbot.GetTarget()) end end)
local fovCircle=Drawing.new("Circle") fovCircle.Thickness=1.5 fovCircle.Color=Color3.new(1,1,1) fovCircle.Transparency=0.5 fovCircle.Filled=false fovCircle.NumSides=64
RunService.RenderStepped:Connect(function() if Aimbot.ShowFOV then fovCircle.Visible=true fovCircle.Position=Vector2.new(Mouse.X,Mouse.Y) fovCircle.Radius=Aimbot.FOV else fovCircle.Visible=false end end)
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(c) if ESP.Enabled and ESP.Players then ESP.Create(c,"player") end end) end)
task.spawn(function() while true do if Wep.InfiniteAmmo or Wep.NoRecoil then Wep.Apply() end task.wait(1) end end)
print("╔═══════════════════════════════════════════════════════════════════════════╗")
print("║              OPEN RINGTA MEGA v"..Config.Version.." - LOADED SUCCESSFULLY              ║")
print("╚═══════════════════════════════════════════════════════════════════════════╝")
