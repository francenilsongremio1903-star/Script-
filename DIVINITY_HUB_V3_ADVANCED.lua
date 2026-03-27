--[[
  DIVINITY HUB v3.0 — ADVANCED EDITION
  Rayfield • Delta Mobile Universal
  ─────────────────────────────────────
  MÓDULOS:
    ⚡ Remote Spy       — hook em todos RemoteEvents/Functions em tempo real
    💻 Lua Executor     — roda código Lua direto pelo hub
    🛡 Anti-Kick HX     — hook no kick + auto rejoin imediato
    ♾ Infinite Yield   — carrega IY integrado via chat
    🔍 Instance Explorer— navega o workspace pelo hub
    👥 Decoy Clone      — duplica seu personagem como isca
    + todas as features da v2
--]]

-- ════════════════════════════════════════════════════════════
--  SERVIÇOS
-- ════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ════════════════════════════════════════════════════════════
--  ESTADO GLOBAL
-- ════════════════════════════════════════════════════════════
local G = {
    Aimbot        = false,
    SilentAim     = false,
    HitboxExp     = false,
    ESP           = false,
    Chams         = false,
    Fly           = false,
    NoClip        = false,
    InfJump       = false,
    AntiAFK       = false,
    FakeLag       = false,
    ChatSpy       = false,
    ShowFOV       = false,
    ShowCrosshair = false,
    AntiKick      = false,
    RemoteSpy     = false,
    IYLoaded      = false,
    WalkSpeed     = 16,
    FlySpeed      = 60,
    JumpPower     = 50,
    AimbotFOV     = 120,
    HitboxSize    = 8,
    FakeLagPing   = 200,
    Conn          = {},
    ESPObj        = {},
    FlyBodies     = nil,
    FOVCircle     = nil,
    Crosshair     = {h = nil, v = nil},
    AimbotTarget  = nil,
    RemoteLog     = {},   -- {time, type, name, args}
    ExplorerPath  = {},   -- pilha de instances navegadas
}

-- ════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════
local function Char()  return LP.Character end
local function HRP()   local c = Char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum()   local c = Char(); return c and c:FindFirstChildOfClass("Humanoid") end
local function Kill(k) if G.Conn[k] then G.Conn[k]:Disconnect(); G.Conn[k] = nil end end

local function SafeExec(code)
    local fn, err = loadstring(code)
    if not fn then return false, err end
    local ok, res = pcall(fn)
    if not ok then return false, res end
    return true, tostring(res or "OK")
end

-- ════════════════════════════════════════════════════════════
--  FOV + CROSSHAIR
-- ════════════════════════════════════════════════════════════
local function InitFOV()
    if G.FOVCircle then G.FOVCircle:Remove() end
    local c = Drawing.new("Circle")
    c.Thickness = 1.5; c.Color = Color3.fromRGB(200,100,255)
    c.Filled = false; c.NumSides = 64; c.Transparency = 1
    c.Radius = G.AimbotFOV
    c.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    c.Visible = false; G.FOVCircle = c
end

local function InitCrosshair()
    for _, v in pairs(G.Crosshair) do if v then pcall(function() v:Remove() end) end end
    local function L()
        local l = Drawing.new("Line")
        l.Thickness = 1.5; l.Color = Color3.fromRGB(255,50,50)
        l.Transparency = 1; l.Visible = false; return l
    end
    G.Crosshair.h = L(); G.Crosshair.v = L()
end

RunService.RenderStepped:Connect(function()
    if G.FOVCircle then
        G.FOVCircle.Radius   = G.AimbotFOV
        G.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        G.FOVCircle.Visible  = G.ShowFOV
    end
    if G.Crosshair.h then
        local cx, cy, sz = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 10
        G.Crosshair.h.From = Vector2.new(cx-sz,cy); G.Crosshair.h.To = Vector2.new(cx+sz,cy)
        G.Crosshair.v.From = Vector2.new(cx,cy-sz); G.Crosshair.v.To = Vector2.new(cx,cy+sz)
        G.Crosshair.h.Visible = G.ShowCrosshair
        G.Crosshair.v.Visible = G.ShowCrosshair
    end
end)

InitFOV(); InitCrosshair()

-- ════════════════════════════════════════════════════════════
--  AIMBOT / SILENT AIM
-- ════════════════════════════════════════════════════════════
local function GetClosestEnemy()
    local best, bestDist = nil, G.AimbotFOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local sp, vis = Camera:WorldToViewportPoint(head.Position)
                if vis then
                    local dist = (Vector2.new(sp.X,sp.Y)-center).Magnitude
                    if dist < bestDist then bestDist=dist; best=p end
                end
            end
        end
    end
    return best
end

local function AimbotLoop()
    Kill("Aimbot"); if not G.Aimbot then return end
    G.Conn["Aimbot"] = RunService.RenderStepped:Connect(function()
        local e = GetClosestEnemy()
        G.AimbotTarget = e
        if e and e.Character then
            local head = e.Character:FindFirstChild("Head")
            if head then Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position) end
        end
    end)
end

local function ToggleSilentAim(v)
    G.SilentAim = v; Kill("SilentAim")
    if v then
        G.Conn["SilentAim"] = RunService.RenderStepped:Connect(function()
            local e = GetClosestEnemy()
            if e then G.AimbotTarget = e end
        end)
    else G.AimbotTarget = nil end
end

-- ════════════════════════════════════════════════════════════
--  HITBOX
-- ════════════════════════════════════════════════════════════
local function ApplyHitbox(p)
    local c = p.Character; if not c then return end
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then part.Size = Vector3.new(G.HitboxSize,G.HitboxSize,G.HitboxSize) end
    end
end

local function ToggleHitbox(v)
    G.HitboxExp = v; Kill("HitboxChar")
    if v then
        for _, p in ipairs(Players:GetPlayers()) do if p~=LP then pcall(ApplyHitbox,p) end end
        G.Conn["HitboxChar"] = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() task.wait(.5); pcall(ApplyHitbox,p) end)
        end)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name=="HumanoidRootPart" then
                        part.Size = Vector3.new(2,2,1)
                    end
                end
            end
        end
    end
end

-- ════════════════════════════════════════════════════════════
--  ESP
-- ════════════════════════════════════════════════════════════
local function MakeESPEntry(p)
    if p==LP then return end
    local e = {}
    local function D(t) local d=Drawing.new(t); d.Visible=false; return d end
    e.box    = D("Square"); e.box.Thickness=1.8; e.box.Filled=false
    e.name   = D("Text");   e.name.Size=13; e.name.Font=2; e.name.Outline=true; e.name.OutlineColor=Color3.new(0,0,0)
    e.dist   = D("Text");   e.dist.Size=11; e.dist.Font=2; e.dist.Outline=true; e.dist.OutlineColor=Color3.new(0,0,0)
    e.hpbg   = D("Square"); e.hpbg.Filled=true; e.hpbg.Color=Color3.fromRGB(40,0,0)
    e.hpfill = D("Square"); e.hpfill.Filled=true
    e.tracer = D("Line");   e.tracer.Thickness=1
    G.ESPObj[p.Name] = e
end

local function RemoveESPEntry(name)
    local e = G.ESPObj[name]; if not e then return end
    for _, d in pairs(e) do pcall(function() d:Remove() end) end
    G.ESPObj[name] = nil
end

local function ESPLoop()
    for _, p in ipairs(Players:GetPlayers()) do
        if p~=LP and not G.ESPObj[p.Name] then MakeESPEntry(p) end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            local e=G.ESPObj[p.Name]; if not e then continue end
            local char=p.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid"); local myHRP=HRP()
            local function HideAll() for _,d in pairs(e) do pcall(function() d.Visible=false end) end end
            if not hrp or not hum or not myHRP or hum.Health<=0 or not G.ESP then HideAll(); continue end
            local sp,vis = Camera:WorldToViewportPoint(hrp.Position)
            if not vis then HideAll(); continue end
            local dist=( myHRP.Position-hrp.Position).Magnitude
            local scale=1/dist*850; local bw,bh=scale*2.2,scale*5.5; local bx,by=sp.X-bw/2,sp.Y-bh/2
            local hpPct=hum.Health/hum.MaxHealth
            local col=Color3.fromRGB(math.floor(255*(1-hpPct)),math.floor(255*hpPct),80)
            e.box.Position=Vector2.new(bx,by); e.box.Size=Vector2.new(bw,bh); e.box.Color=col; e.box.Visible=true
            local bary=by+bh+4
            e.hpbg.Position=Vector2.new(bx,bary); e.hpbg.Size=Vector2.new(bw,5); e.hpbg.Visible=true
            e.hpfill.Position=Vector2.new(bx,bary); e.hpfill.Size=Vector2.new(bw*hpPct,5); e.hpfill.Color=col; e.hpfill.Visible=true
            e.name.Position=Vector2.new(sp.X,by-16); e.name.Text=p.Name; e.name.Color=col; e.name.Visible=true
            e.dist.Position=Vector2.new(sp.X,by-28); e.dist.Text=math.floor(dist).."m"; e.dist.Color=Color3.new(1,1,1); e.dist.Visible=true
            e.tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y); e.tracer.To=Vector2.new(sp.X,sp.Y); e.tracer.Color=col; e.tracer.Visible=true
        end
    end
end

local function ToggleESP(v)
    G.ESP=v; Kill("ESP")
    if v then
        for _, p in ipairs(Players:GetPlayers()) do MakeESPEntry(p) end
        G.Conn["ESP"]=RunService.RenderStepped:Connect(ESPLoop)
        Players.PlayerRemoving:Connect(function(p) RemoveESPEntry(p.Name) end)
    else for name,_ in pairs(G.ESPObj) do RemoveESPEntry(name) end end
end

-- ════════════════════════════════════════════════════════════
--  CHAMS
-- ════════════════════════════════════════════════════════════
local ChamsColor = Color3.fromRGB(255,0,150)
local function ApplyChams(p,on)
    if p==LP then return end
    local c=p.Character; if not c then return end
    for _,part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            if on then
                local hl=Instance.new("SelectionBox"); hl.Name="DIV_Cham"; hl.Adornee=part
                hl.Color3=ChamsColor; hl.LineThickness=0; hl.SurfaceTransparency=0.4; hl.SurfaceColor3=ChamsColor; hl.Parent=part
            else for _,ch in ipairs(part:GetChildren()) do if ch.Name=="DIV_Cham" then ch:Destroy() end end end
        end
    end
end

local function ToggleChams(v)
    G.Chams=v
    for _,p in ipairs(Players:GetPlayers()) do pcall(ApplyChams,p,v) end
end

-- ════════════════════════════════════════════════════════════
--  FLY
-- ════════════════════════════════════════════════════════════
local function ToggleFly(v)
    G.Fly=v; Kill("Fly")
    local char=Char(); local hrp=HRP(); local hum=Hum()
    if not char or not hrp or not hum then return end
    if v then
        hum.PlatformStand=true
        local bv=Instance.new("BodyVelocity",hrp); bv.Name="DIV_BV"; bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e9,1e9,1e9)
        local bg=Instance.new("BodyGyro",hrp);     bg.Name="DIV_BG"; bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.D=60
        G.FlyBodies={bv=bv,bg=bg}
        G.Conn["Fly"]=RunService.RenderStepped:Connect(function()
            if not G.Fly then return end
            local cf=Camera.CFrame; local dir=Vector3.zero; local spd=G.FlySpeed
            if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir=dir+cf.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir=dir-cf.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir=dir-cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir=dir+cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir=dir+Vector3.yAxis  end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.yAxis  end
            bv.Velocity=dir.Magnitude>0 and dir.Unit*spd or Vector3.zero; bg.CFrame=cf
        end)
    else
        if G.FlyBodies then pcall(function() G.FlyBodies.bv:Destroy() end); pcall(function() G.FlyBodies.bg:Destroy() end); G.FlyBodies=nil end
        if hum then hum.PlatformStand=false end
    end
end

-- ════════════════════════════════════════════════════════════
--  NOCLIP / SPEED / INF JUMP / ANTI-AFK / FAKE LAG
-- ════════════════════════════════════════════════════════════
local function ToggleNoClip(v)
    G.NoClip=v; Kill("NoClip")
    if v then
        G.Conn["NoClip"]=RunService.Stepped:Connect(function()
            local c=Char(); if not c then return end
            for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    else
        local c=Char(); if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
    end
end

local function SetSpeed(val)
    G.WalkSpeed=val; Kill("SpeedHB")
    local h=Hum(); if h then h.WalkSpeed=val end
    G.Conn["SpeedHB"]=RunService.Heartbeat:Connect(function()
        local h2=Hum(); if h2 then h2.WalkSpeed=G.WalkSpeed end
    end)
end

G.Conn["InfJump_Global"]=UserInputService.JumpRequest:Connect(function()
    if G.InfJump then local h=Hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

local function ToggleAntiAFK(v)
    G.AntiAFK=v; Kill("AntiAFK")
    if v then
        G.Conn["AntiAFK"]=RunService.Heartbeat:Connect(function()
            pcall(function()
                local VU=game:GetService("VirtualUser")
                VU:Button2Down(Vector2.new(0,0),Camera.CFrame); VU:Button2Up(Vector2.new(0,0),Camera.CFrame)
            end)
        end)
        task.spawn(function()
            while G.AntiAFK do pcall(function() LP:Move(Vector3.new(0,0,0)) end); task.wait(30) end
        end)
    end
end

local function ToggleFakeLag(v)
    G.FakeLag=v; Kill("FakeLag")
    if v then G.Conn["FakeLag"]=RunService.Heartbeat:Connect(function() task.wait(G.FakeLagPing/1000) end) end
end

local ChatLog = {}
local function ToggleChatSpy(v)
    G.ChatSpy=v; Kill("ChatSpy")
    if v then
        local function hook(p)
            if p==LP then return end
            p.Chatted:Connect(function(msg)
                if G.ChatSpy then
                    table.insert(ChatLog,1,"["..p.Name.."]: "..msg)
                    if #ChatLog>50 then table.remove(ChatLog,#ChatLog) end
                end
            end)
        end
        for _,p in ipairs(Players:GetPlayers()) do hook(p) end
        G.Conn["ChatSpy"]=Players.PlayerAdded:Connect(hook)
    end
end

local function BringAll()
    local myHRP=HRP(); if not myHRP then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local pHRP=p.Character:FindFirstChild("HumanoidRootPart")
            if pHRP then pHRP.CFrame=myHRP.CFrame*CFrame.new(math.random(-4,4),0,math.random(-4,4)) end
        end
    end
end

local function TeleportToPlayer(pname)
    local myHRP=HRP(); if not myHRP then return end
    local target=Players:FindFirstChild(pname)
    if target and target.Character then
        local tHRP=target.Character:FindFirstChild("HumanoidRootPart")
        if tHRP then myHRP.CFrame=tHRP.CFrame*CFrame.new(0,3,0) end
    end
end

local function ServerHop()
    local id=game.PlaceId
    pcall(function()
        local page=TeleportService:GetSortedGameInstances(id)
        for _,s in ipairs(page) do
            if s.CurrentPlayers<s.MaxPlayers and s.Id~=game.JobId then
                TeleportService:TeleportToPlaceInstance(id,s.Id,LP); return
            end
        end
        TeleportService:Teleport(id,LP)
    end)
end

-- ════════════════════════════════════════════════════════════
--  RESPAWN HANDLER
-- ════════════════════════════════════════════════════════════
LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    local h=c:WaitForChild("Humanoid",5)
    if h then h.WalkSpeed=G.WalkSpeed; h.JumpPower=G.JumpPower end
    if G.Fly        then task.wait(.2); ToggleFly(true)        end
    if G.NoClip     then task.wait(.2); ToggleNoClip(true)     end
    if G.HitboxExp  then task.wait(.2); ToggleHitbox(true)     end
end)

-- ════════════════════════════════════════════════════════════
--  ⚡ REMOTE SPY
--  Hookeia __namecall pra interceptar todas as chamadas
--  de RemoteEvent:FireServer e RemoteFunction:InvokeServer
-- ════════════════════════════════════════════════════════════
local RemoteSpyActive = false
local OldNamecall

local function StartRemoteSpy()
    if OldNamecall then return end  -- já hookado
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if RemoteSpyActive then
            if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) and
               (method == "FireServer" or method == "InvokeServer") then

                local argStrings = {}
                for _, v in ipairs(args) do
                    table.insert(argStrings, tostring(v))
                end

                local entry = {
                    t    = os.clock(),
                    kind = self.ClassName,
                    name = self.Name,
                    path = self:GetFullName(),
                    args = table.concat(argStrings, ", "),
                }
                table.insert(G.RemoteLog, 1, entry)
                if #G.RemoteLog > 200 then table.remove(G.RemoteLog, #G.RemoteLog) end
                print(string.format("[RemoteSpy] %s :: %s | %s", entry.kind, entry.path, entry.args))
            end
        end

        return OldNamecall(self, ...)
    end)
end

local function ToggleRemoteSpy(v)
    G.RemoteSpy = v
    if v then
        RemoteSpyActive = true
        StartRemoteSpy()
    else
        RemoteSpyActive = false
    end
end

-- ════════════════════════════════════════════════════════════
--  🛡 ANTI-KICK HARDCORE
--  Hook em Player:Kick() e no evento de saída do servidor.
--  Se o servidor tentar kickar, cancela e auto-rejeita.
-- ════════════════════════════════════════════════════════════
local KickHook = nil

local function ToggleAntiKick(v)
    G.AntiKick = v
    if v then
        -- Hook no método Kick do LocalPlayer
        if not KickHook then
            local ok = pcall(function()
                KickHook = hookfunction(LP.Kick, function(...)
                    if G.AntiKick then
                        warn("[AntiKick] Kick bloqueado!")
                        return  -- cancela o kick
                    end
                    return KickHook(...)
                end)
            end)
            if not ok then
                -- Fallback: monitora se LP é removido da lista de players
                G.Conn["AntiKickFallback"] = Players.PlayerRemoving:Connect(function(p)
                    if p == LP and G.AntiKick then
                        task.wait(0.1)
                        pcall(function()
                            TeleportService:Teleport(game.PlaceId, LP)
                        end)
                    end
                end)
            end
        end

        -- Loop de rejoin via monitoramento de kick
        task.spawn(function()
            local old = LP.OnTeleport
            LP.OnTeleport:Connect(function(state)
                if state == Enum.TeleportState.Failed and G.AntiKick then
                    task.wait(2)
                    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
                end
            end)
        end)

        print("[AntiKick] Hook ativado no LocalPlayer")
    else
        Kill("AntiKickFallback")
        print("[AntiKick] Desativado")
    end
end

-- ════════════════════════════════════════════════════════════
--  👥 DECOY CLONE
--  Cria uma cópia estática do seu personagem no lugar atual
--  como isca para outros players
-- ════════════════════════════════════════════════════════════
local DecoyModel = nil

local function SpawnDecoy()
    if DecoyModel then DecoyModel:Destroy(); DecoyModel = nil end
    local char = Char(); local hrp = HRP()
    if not char or not hrp then return false end

    -- Clona o personagem inteiro
    local clone = char:Clone()
    clone.Name  = LP.Name .. "_Decoy"

    -- Remove scripts e humanoid do clone para não interferir
    for _, v in ipairs(clone:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            v:Destroy()
        end
    end

    -- Posiciona onde o player está
    local cloneHRP = clone:FindFirstChild("HumanoidRootPart")
    if cloneHRP then
        cloneHRP.Anchored = true  -- trava o decoy no lugar
        cloneHRP.CFrame   = hrp.CFrame
    end

    -- Ancora todas as partes
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then part.Anchored = true end
    end

    clone.Parent = workspace
    DecoyModel   = clone
    return true
end

local function RemoveDecoy()
    if DecoyModel then DecoyModel:Destroy(); DecoyModel = nil end
end

-- ════════════════════════════════════════════════════════════
--  🔍 INSTANCE EXPLORER (helper de dados)
-- ════════════════════════════════════════════════════════════
local function GetInstanceInfo(inst)
    if not inst then return "nil" end
    local lines = {
        "📦 "  .. inst.Name .. " [" .. inst.ClassName .. "]",
        "🔗 Path: " .. inst:GetFullName(),
    }
    if inst:IsA("BasePart") then
        lines[#lines+1] = "📐 Size: " .. tostring(inst.Size)
        lines[#lines+1] = "📍 Pos: "  .. tostring(inst.Position)
    end
    if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
        lines[#lines+1] = "⚡ Remote detectado!"
    end
    local children = inst:GetChildren()
    lines[#lines+1] = "👶 Filhos: " .. #children
    return table.concat(lines, "\n")
end

-- ════════════════════════════════════════════════════════════
--  RAYFIELD UI
-- ════════════════════════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name            = "DIVINITY HUB  ⚡  v3 ADVANCED",
    LoadingTitle    = "DIVINITY HUB",
    LoadingSubtitle = "Advanced Edition • Delta Mobile",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

-- ══════════════════════════════
--  ABA: COMBAT
-- ══════════════════════════════
local TabCombat = Window:CreateTab("⚔  Combat", 4483362458)

TabCombat:CreateSection("Mira")
TabCombat:CreateToggle({ Name="Aimbot",          CurrentValue=false, Flag="Aimbot",
    Callback=function(v) G.Aimbot=v; AimbotLoop() end })
TabCombat:CreateToggle({ Name="Silent Aim",      CurrentValue=false, Flag="SilentAim",
    Callback=function(v) ToggleSilentAim(v) end })
TabCombat:CreateToggle({ Name="Hitbox Expander", CurrentValue=false, Flag="HitboxExp",
    Callback=function(v) ToggleHitbox(v) end })
TabCombat:CreateSlider({ Name="FOV Aimbot",    Range={20,400}, Increment=5,  Suffix="px",  CurrentValue=120, Flag="AimbotFOV",
    Callback=function(v) G.AimbotFOV=v end })
TabCombat:CreateSlider({ Name="Hitbox Size",   Range={4,30},   Increment=1,  Suffix="st",  CurrentValue=8,   Flag="HitboxSize",
    Callback=function(v) G.HitboxSize=v end })
TabCombat:CreateSection("Visual")
TabCombat:CreateToggle({ Name="Círculo FOV",  CurrentValue=false, Flag="ShowFOV",       Callback=function(v) G.ShowFOV=v end })
TabCombat:CreateToggle({ Name="Crosshair",    CurrentValue=false, Flag="ShowCrosshair", Callback=function(v) G.ShowCrosshair=v end })

-- ══════════════════════════════
--  ABA: MOVEMENT
-- ══════════════════════════════
local TabMove = Window:CreateTab("🚀  Move", 4483362458)

TabMove:CreateSection("Movimento")
TabMove:CreateToggle({ Name="Fly",           CurrentValue=false, Flag="Fly",     Callback=function(v) ToggleFly(v) end })
TabMove:CreateToggle({ Name="NoClip",        CurrentValue=false, Flag="NoClip",  Callback=function(v) ToggleNoClip(v) end })
TabMove:CreateToggle({ Name="Infinite Jump", CurrentValue=false, Flag="InfJump", Callback=function(v) G.InfJump=v end })
TabMove:CreateSection("Stats")
TabMove:CreateSlider({ Name="WalkSpeed",  Range={16,500}, Increment=1,  Suffix="spd", CurrentValue=16, Flag="WalkSpeed",
    Callback=function(v) SetSpeed(v) end })
TabMove:CreateSlider({ Name="Fly Speed",  Range={10,400}, Increment=5,  Suffix="spd", CurrentValue=60, Flag="FlySpeed",
    Callback=function(v) G.FlySpeed=v end })
TabMove:CreateSlider({ Name="Jump Power", Range={50,300}, Increment=5,  Suffix="jp",  CurrentValue=50, Flag="JumpPower",
    Callback=function(v) G.JumpPower=v; local h=Hum(); if h then h.JumpPower=v end end })

-- ══════════════════════════════
--  ABA: VISUAL
-- ══════════════════════════════
local TabVisual = Window:CreateTab("👁  Visual", 4483362458)

TabVisual:CreateSection("ESP")
TabVisual:CreateToggle({ Name="ESP Avançado",    CurrentValue=false, Flag="ESP",     Callback=function(v) ToggleESP(v) end })
TabVisual:CreateToggle({ Name="Chams Wallhack",  CurrentValue=false, Flag="Chams",   Callback=function(v) ToggleChams(v) end })
TabVisual:CreateToggle({ Name="Chat Spy",        CurrentValue=false, Flag="ChatSpy", Callback=function(v) ToggleChatSpy(v) end })
TabVisual:CreateButton({ Name="📋 Ver Chat Log (Output)", Callback=function()
    if #ChatLog==0 then Rayfield:Notify({Title="Chat Log",Content="Vazio.",Duration=2}); return end
    for i=1,math.min(8,#ChatLog) do print(ChatLog[i]) end
    Rayfield:Notify({Title="Chat Log",Content="Veja o output (F9).",Duration=3})
end})

-- ══════════════════════════════
--  ABA: REMOTE SPY  ⚡
-- ══════════════════════════════
local TabSpy = Window:CreateTab("⚡  Remote Spy", 4483362458)

TabSpy:CreateSection("Monitor de Remotes")
TabSpy:CreateToggle({
    Name         = "Remote Spy Ativo",
    CurrentValue = false,
    Flag         = "RemoteSpy",
    Callback     = function(v)
        ToggleRemoteSpy(v)
        Rayfield:Notify({
            Title   = "Remote Spy",
            Content = v and "Monitorando remotes... veja o output (F9)" or "Remote Spy OFF",
            Duration = 3
        })
    end,
})

TabSpy:CreateButton({
    Name     = "🗑  Limpar Log de Remotes",
    Callback = function()
        G.RemoteLog = {}
        Rayfield:Notify({Title="Remote Spy",Content="Log limpo.",Duration=2})
    end,
})

TabSpy:CreateButton({
    Name     = "📄  Ver Últimos 10 Remotes (Output)",
    Callback = function()
        if #G.RemoteLog == 0 then
            Rayfield:Notify({Title="Remote Spy",Content="Nenhum remote capturado ainda.",Duration=3})
            return
        end
        print("══════ REMOTE LOG ══════")
        for i = 1, math.min(10, #G.RemoteLog) do
            local e = G.RemoteLog[i]
            print(string.format("[%s] %s | args: %s", e.kind, e.path, e.args))
        end
        print("════════════════════════")
        Rayfield:Notify({Title="Remote Spy",Content="Últimos "..math.min(10,#G.RemoteLog).." remotes no output.",Duration=3})
    end,
})

TabSpy:CreateButton({
    Name     = "🔍  Listar TODOS os Remotes do Jogo",
    Callback = function()
        print("══════ TODOS REMOTES ══════")
        local count = 0
        local function scan(inst)
            for _, v in ipairs(inst:GetChildren()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    print("[" .. v.ClassName .. "] " .. v:GetFullName())
                    count = count + 1
                end
                pcall(scan, v)
            end
        end
        scan(game)
        print("Total: " .. count .. " remotes")
        print("═══════════════════════════")
        Rayfield:Notify({Title="Remote Scan",Content=count.." remotes encontrados. Veja o output.",Duration=4})
    end,
})

-- ══════════════════════════════
--  ABA: LUA EXECUTOR  💻
-- ══════════════════════════════
local TabExec = Window:CreateTab("💻  Executor", 4483362458)

TabExec:CreateSection("Executor Interno")

-- Buffer de código compartilhado
local ExecBuffer = "print('Hello from DIVINITY!')"

TabExec:CreateInput({
    Name        = "Código Lua",
    PlaceholderText = "print('teste')",
    RemoveTextAfterFocusLost = false,
    Flag        = "ExecCode",
    Callback    = function(v)
        ExecBuffer = v
    end,
})

TabExec:CreateButton({
    Name     = "▶  Executar",
    Callback = function()
        if ExecBuffer == "" then
            Rayfield:Notify({Title="Executor",Content="Código vazio.",Duration=2}); return
        end
        local ok, res = SafeExec(ExecBuffer)
        print("[Executor] " .. (ok and "OK" or "ERRO") .. ": " .. tostring(res))
        Rayfield:Notify({
            Title   = ok and "✅ Executado" or "❌ Erro",
            Content = tostring(res):sub(1, 80),
            Duration = 4
        })
    end,
})

TabExec:CreateButton({
    Name     = "🗑  Limpar",
    Callback = function()
        ExecBuffer = ""
        Rayfield:Notify({Title="Executor",Content="Buffer limpo.",Duration=2})
    end,
})

TabExec:CreateSection("Snippets Rápidos")

TabExec:CreateButton({
    Name     = "💀  Kill All (loop)",
    Callback = function()
        local code = [[
for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
    if p ~= game:GetService("Players").LocalPlayer and p.Character then
        local h = p.Character:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0 end
    end
end
print("Kill All executado")]]
        local ok, res = SafeExec(code)
        Rayfield:Notify({Title=ok and "Kill All" or "Erro",Content=tostring(res):sub(1,60),Duration=3})
    end,
})

TabExec:CreateButton({
    Name     = "🌀  Rejoin",
    Callback = function()
        local ok, res = SafeExec("game:GetService('TeleportService'):Teleport(game.PlaceId, game:GetService('Players').LocalPlayer)")
        Rayfield:Notify({Title="Rejoin",Content=ok and "Recarregando..." or res,Duration=3})
    end,
})

TabExec:CreateButton({
    Name     = "🔓  Unlock FPS (60→144)",
    Callback = function()
        local ok, res = SafeExec("setfpscap(144)")
        Rayfield:Notify({Title="FPS Unlock",Content=ok and "FPS: 144" or "Executor não suporta setfpscap",Duration=3})
    end,
})

-- ══════════════════════════════
--  ABA: ANTI-KICK 🛡
-- ══════════════════════════════
local TabKick = Window:CreateTab("🛡  Anti-Kick", 4483362458)

TabKick:CreateSection("Proteção de Kick")
TabKick:CreateToggle({
    Name         = "Anti-Kick Hardcore",
    CurrentValue = false,
    Flag         = "AntiKick",
    Callback     = function(v)
        ToggleAntiKick(v)
        Rayfield:Notify({
            Title   = "Anti-Kick",
            Content = v and "Hook ativado! Kick bloqueado." or "Desativado.",
            Duration = 3
        })
    end,
})

TabKick:CreateSection("Auto Rejoin")
TabKick:CreateButton({
    Name     = "🔄  Rejoin Manual",
    Callback = function()
        Rayfield:Notify({Title="Rejoin",Content="Reconectando...",Duration=2})
        task.wait(1)
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
    end,
})

TabKick:CreateButton({
    Name     = "📋  Ver Histórico de Kicks (Output)",
    Callback = function()
        print("[AntiKick] Hook status: " .. tostring(KickHook ~= nil))
        Rayfield:Notify({Title="Anti-Kick",Content="Veja o output pra status.",Duration=3})
    end,
})

-- ══════════════════════════════
--  ABA: INFINITE YIELD ♾
-- ══════════════════════════════
local TabIY = Window:CreateTab("♾  Inf Yield", 4483362458)

TabIY:CreateSection("Infinite Yield")
TabIY:CreateParagraph({
    Title   = "O que é Infinite Yield?",
    Content = "IY é um admin script que dá comandos via chat. Digite ;cmds depois de carregar pra ver todos os comandos."
})

TabIY:CreateButton({
    Name     = "⬇  Carregar Infinite Yield",
    Callback = function()
        if G.IYLoaded then
            Rayfield:Notify({Title="IY",Content="Já carregado! Digite ;cmds no chat.",Duration=3}); return
        end
        Rayfield:Notify({Title="Infinite Yield",Content="Carregando IY...",Duration=3})
        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            end)
            if ok then
                G.IYLoaded = true
                Rayfield:Notify({Title="✅ IY Carregado",Content="Digite ;cmds no chat pra ver os comandos!",Duration=5})
            else
                Rayfield:Notify({Title="❌ Erro IY",Content=tostring(err):sub(1,80),Duration=5})
            end
        end)
    end,
})

TabIY:CreateSection("Comandos Rápidos IY")
TabIY:CreateButton({
    Name="🚀 Speed 100 (via IY chat)",
    Callback=function()
        if not G.IYLoaded then Rayfield:Notify({Title="IY",Content="Carregue o IY primeiro!",Duration=3}); return end
        -- Simula o comando IY via chat
        local ok = pcall(function()
            local ChatService = game:GetService("TextChatService")
            if ChatService and ChatService.TextChannels then
                local ch = ChatService.TextChannels:FindFirstChild("RBXGeneral")
                if ch then ch:SendAsync(";speed 100") end
            end
        end)
        if not ok then
            -- fallback direto
            SetSpeed(100)
            Rayfield:Notify({Title="Speed",Content="WalkSpeed 100 aplicado direto.",Duration=2})
        end
    end,
})

-- ══════════════════════════════
--  ABA: INSTANCE EXPLORER 🔍
-- ══════════════════════════════
local TabExplorer = Window:CreateTab("🔍  Explorer", 4483362458)

TabExplorer:CreateSection("Instance Explorer")

TabExplorer:CreateInput({
    Name            = "Caminho (ex: workspace.Baseplate)",
    PlaceholderText = "workspace.Part",
    RemoveTextAfterFocusLost = false,
    Flag            = "ExplorerPath",
    Callback        = function(v)
        G.ExplorerPathStr = v
    end,
})

TabExplorer:CreateButton({
    Name     = "🔎  Inspecionar Instance",
    Callback = function()
        if not G.ExplorerPathStr or G.ExplorerPathStr == "" then
            Rayfield:Notify({Title="Explorer",Content="Digite um caminho.",Duration=2}); return
        end
        local ok, inst = pcall(function()
            -- Resolve o path dinamicamente
            local parts = string.split(G.ExplorerPathStr, ".")
            local cur   = game
            for _, part in ipairs(parts) do
                cur = cur[part]
            end
            return cur
        end)
        if ok and inst then
            local info = GetInstanceInfo(inst)
            print("[Explorer]\n" .. info)
            Rayfield:Notify({Title="Explorer",Content=inst.Name.." ["..inst.ClassName.."]\nVeja o output.",Duration=4})
        else
            Rayfield:Notify({Title="Explorer",Content="Instance não encontrada: "..tostring(inst),Duration=4})
        end
    end,
})

TabExplorer:CreateButton({
    Name     = "📦  Listar Filhos no Output",
    Callback = function()
        if not G.ExplorerPathStr or G.ExplorerPathStr == "" then
            Rayfield:Notify({Title="Explorer",Content="Digite um caminho.",Duration=2}); return
        end
        local ok, inst = pcall(function()
            local parts = string.split(G.ExplorerPathStr, ".")
            local cur   = game
            for _, part in ipairs(parts) do cur = cur[part] end
            return cur
        end)
        if ok and inst then
            print("══ Filhos de " .. inst:GetFullName() .. " ══")
            for _, child in ipairs(inst:GetChildren()) do
                print("  [" .. child.ClassName .. "] " .. child.Name)
            end
        else
            Rayfield:Notify({Title="Explorer",Content="Erro: "..tostring(inst),Duration=3})
        end
    end,
})

TabExplorer:CreateButton({
    Name     = "⚡  Scan Remotes no Caminho",
    Callback = function()
        local root = G.ExplorerPathStr
        if not root or root == "" then root = "game" end
        local ok, inst = pcall(function()
            if root == "game" then return game end
            local parts = string.split(root, ".")
            local cur   = game
            for _, part in ipairs(parts) do cur = cur[part] end
            return cur
        end)
        if not ok then Rayfield:Notify({Title="Scan",Content="Erro no path.",Duration=3}); return end
        local found = 0
        print("══ Remote Scan: " .. inst:GetFullName() .. " ══")
        local function scan(i)
            for _, v in ipairs(i:GetChildren()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    print("[" .. v.ClassName .. "] " .. v:GetFullName()); found=found+1
                end
                pcall(scan, v)
            end
        end
        scan(inst)
        print("Total: " .. found)
        Rayfield:Notify({Title="Remote Scan",Content=found.." remotes em "..inst.Name,Duration=4})
    end,
})

-- ══════════════════════════════
--  ABA: DECOY / PLAYERS
-- ══════════════════════════════
local TabPlayers = Window:CreateTab("👤  Players", 4483362458)

TabPlayers:CreateSection("Decoy Clone")
TabPlayers:CreateParagraph({
    Title   = "Decoy Clone",
    Content = "Cria uma cópia estática do seu personagem como isca. Outros players podem confundir com você real."
})
TabPlayers:CreateButton({
    Name     = "👥  Spawnar Decoy",
    Callback = function()
        local ok = SpawnDecoy()
        Rayfield:Notify({Title="Decoy",Content=ok and "Clone criado!" or "Personagem não carregado.",Duration=3})
    end,
})
TabPlayers:CreateButton({
    Name     = "🗑  Remover Decoy",
    Callback = function()
        RemoveDecoy()
        Rayfield:Notify({Title="Decoy",Content="Clone removido.",Duration=2})
    end,
})

TabPlayers:CreateSection("Ações")
TabPlayers:CreateButton({ Name="🧲 Bring All",    Callback=function() BringAll(); Rayfield:Notify({Title="Bring All",Content="Players puxados!",Duration=2}) end })
TabPlayers:CreateButton({ Name="🌐 Server Hop",   Callback=function() Rayfield:Notify({Title="Server Hop",Content="Trocando...",Duration=2}); task.wait(1); ServerHop() end })
TabPlayers:CreateButton({ Name="🏠 Teleport Spawn", Callback=function()
    local h=HRP(); if h then h.CFrame=CFrame.new(0,10,0); Rayfield:Notify({Title="Teleport",Content="→ Spawn",Duration=2}) end
end})

TabPlayers:CreateSection("Teleport → Jogador")
TabPlayers:CreateDropdown({
    Name            = "Selecionar Jogador",
    Options         = (function()
        local list={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(list,p.Name) end end
        return list
    end)(),
    CurrentOption   = {},
    MultipleOptions = false,
    Flag            = "TeleportTarget",
    Callback        = function(opt)
        if opt and opt~="" then
            TeleportToPlayer(opt)
            Rayfield:Notify({Title="Teleport",Content="→ "..opt,Duration=2})
        end
    end,
})

-- ══════════════════════════════
--  ABA: UTILITY
-- ══════════════════════════════
local TabUtil = Window:CreateTab("⚙  Utility", 4483362458)

TabUtil:CreateSection("Misc")
TabUtil:CreateToggle({ Name="Anti-AFK", CurrentValue=false, Flag="AntiAFK", Callback=function(v) ToggleAntiAFK(v) end })
TabUtil:CreateToggle({ Name="Fake Lag", CurrentValue=false, Flag="FakeLag", Callback=function(v) ToggleFakeLag(v) end })
TabUtil:CreateSlider({ Name="Ping Fake", Range={50,1000}, Increment=10, Suffix="ms", CurrentValue=200, Flag="FakeLagPing",
    Callback=function(v) G.FakeLagPing=v end })
TabUtil:CreateButton({ Name="💀 Kill Self", Callback=function()
    local h=Hum(); if h then h.Health=0 end
end})

-- ════════════════════════════════════════════════════════════
--  BOOT
-- ════════════════════════════════════════════════════════════
Rayfield:Notify({
    Title    = "DIVINITY HUB ⚡ v3",
    Content  = "Advanced Edition carregada!\nRemote Spy • Executor • Anti-Kick • IY • Explorer",
    Duration = 6,
})

print("╔═══════════════════════════════════════╗")
print("║  DIVINITY HUB v3.0 ADVANCED — ATIVO  ║")
print("║  Remote Spy • Lua Executor • Anti-Kick ║")
print("║  Infinite Yield • Explorer • Decoy     ║")
print("╚═══════════════════════════════════════╝")
