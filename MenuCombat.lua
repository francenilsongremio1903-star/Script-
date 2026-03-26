-- ============================================================
--  COMBAT MENU V16 — Delta Mobile
--  FIX: GUI migrada para gethui() — imune ao anti-cheat
--  Todas as funções da V15 preservadas integralmente
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp               = Players.LocalPlayer
local cam              = workspace.CurrentCamera

local atkOn   = false
local npcOn   = false
local godOn   = false
local voidOn  = false
local stealOn = false
local godConn = nil
local voidParts = {}
local voidKillConn = nil
local lastAtk = 0
local lastNpc = 0

-- ============================================================
-- KILL AURA
-- ============================================================
local auraOn        = false
local auraPlayers   = true
local auraNPCs      = true
local auraRange     = 20
local auraInterval  = 0.05
local auraTimer     = 0
local auraRangeLabel = nil

local function killAura(tc)
    if not tc then return end
    pcall(function()
        local h = tc:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0; h:TakeDamage(99999) end
    end)
    local char  = lp.Character
    local tool  = char and char:FindFirstChildOfClass("Tool")
    local handle = tool and tool:FindFirstChild("Handle")
    if handle then
        local orig = handle.CFrame
        for _, nm in ipairs({"HumanoidRootPart","UpperTorso","Torso","Head"}) do
            local p = tc:FindFirstChild(nm)
            if p then pcall(function()
                handle.CFrame = p.CFrame
                firetouchinterest(handle, p, 0)
                firetouchinterest(handle, p, 1)
            end) end
        end
        pcall(function() handle.CFrame = orig end)
        task.spawn(function()
            for _, p in pairs(tc:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function()
                    handle.CFrame = p.CFrame
                    firetouchinterest(handle, p, 0)
                    firetouchinterest(handle, p, 1)
                end) end
            end
            pcall(function() handle.CFrame = orig end)
        end)
    end
    if tool then
        for _, r in pairs(tool:GetDescendants()) do
            if r:IsA("RemoteEvent") then pcall(function() r:FireServer(tc) end) end
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    if not auraOn then return end
    auraTimer = auraTimer + dt
    if auraTimer < auraInterval then return end
    auraTimer = 0
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pChars = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then pChars[p.Character] = true end
    end
    if auraPlayers then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local pr = p.Character:FindFirstChild("HumanoidRootPart")
                local ph = p.Character:FindFirstChildOfClass("Humanoid")
                if pr and ph and ph.Health > 0 then
                    if (root.Position - pr.Position).Magnitude <= auraRange then
                        task.spawn(function() killAura(p.Character) end)
                    end
                end
            end
        end
    end
    if auraNPCs then
        local myChar = lp.Character
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and not pChars[obj] and obj ~= myChar then
                local h = obj:FindFirstChildOfClass("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if h and h.Health > 0 and r then
                    if (root.Position - r.Position).Magnitude <= auraRange then
                        task.spawn(function() killAura(obj) end)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- LIMPA GUIS ANTIGAS (PlayerGui) — não mexe no CoreGui
-- ============================================================
local pg = lp:WaitForChild("PlayerGui")
for _, n in ipairs({"CM_V8","CM_V15","CM_V16","CM_Float","CM_Notif"}) do
    local o = pg:FindFirstChild(n)
    if o then o:Destroy() end
end
-- Limpa também no gethui se já existir
pcall(function()
    local h = gethui()
    for _, n in ipairs({"CM_V16_Core","CM_Float_Core","CM_Notif_Core"}) do
        local o = h:FindFirstChild(n)
        if o then o:Destroy() end
    end
end)

-- ============================================================
-- FUNÇÃO PARA OBTER CONTAINER IMUNE AO ANTI-CHEAT
-- Tenta gethui() (Delta/executores) → fallback PlayerGui
-- ============================================================
local function getContainer()
    local ok, h = pcall(gethui)
    if ok and h then return h end
    return pg
end
local container = getContainer()

-- ============================================================
-- NOTIF — dentro do container imune
-- ============================================================
local nsg = Instance.new("ScreenGui", container)
nsg.Name = "CM_Notif_Core"
nsg.ResetOnSpawn = false
nsg.IgnoreGuiInset = true
nsg.DisplayOrder = 9999

local function notif(msg, dur)
    local f = Instance.new("Frame", nsg)
    f.Size = UDim2.new(0,255,0,42)
    f.Position = UDim2.new(1,10,1,-52)
    f.BackgroundColor3 = Color3.fromRGB(20,20,30)
    f.BorderSizePixel = 0
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke",f).Color = Color3.fromRGB(180,20,20)
    local lb = Instance.new("TextLabel",f)
    lb.Size = UDim2.new(1,-10,1,0)
    lb.Position = UDim2.new(0,8,0,0)
    lb.BackgroundTransparency = 1
    lb.Text = msg
    lb.TextColor3 = Color3.fromRGB(225,225,235)
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextWrapped = true
    TweenService:Create(f,TweenInfo.new(0.2),{Position=UDim2.new(1,-265,1,-52)}):Play()
    task.delay(dur or 2.5, function()
        TweenService:Create(f,TweenInfo.new(0.2),{Position=UDim2.new(1,10,1,-52)}):Play()
        task.delay(0.25, function() pcall(function() f:Destroy() end) end)
    end)
end

-- ============================================================
-- KILL ORIGINAL
-- ============================================================
local function kill(tc)
    if not tc then return end
    local char   = lp.Character
    local tool   = char and char:FindFirstChildOfClass("Tool")
    local handle = tool and tool:FindFirstChild("Handle")
    if handle then
        local orig = handle.CFrame
        for _, nm in ipairs({"HumanoidRootPart","UpperTorso","Torso","Head"}) do
            local p = tc:FindFirstChild(nm)
            if p then pcall(function()
                handle.CFrame = p.CFrame
                firetouchinterest(handle, p, 0)
                firetouchinterest(handle, p, 1)
            end) end
        end
        pcall(function() handle.CFrame = orig end)
        task.spawn(function()
            local orig2 = handle.CFrame
            for _, p in pairs(tc:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function()
                    handle.CFrame = p.CFrame
                    firetouchinterest(handle, p, 0)
                    firetouchinterest(handle, p, 1)
                end) end
            end
            pcall(function() handle.CFrame = orig2 end)
        end)
    end
    pcall(function()
        local h = tc:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0; h:TakeDamage(99999) end
    end)
    if tool then
        for _, r in pairs(tool:GetDescendants()) do
            if r:IsA("RemoteEvent") then pcall(function() r:FireServer(tc) end) end
        end
    end
end

local function atkAll()
    local now = tick()
    if now - lastAtk < 0.15 then return end
    lastAtk = now
    local function escanearAlvos()
        local alvos = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then table.insert(alvos, p.Character) end
        end
        return alvos
    end
    local alvos = escanearAlvos()
    local n = #alvos
    if n == 0 then return end
    for _, tc in pairs(alvos) do task.spawn(function() kill(tc) end) end
    task.delay(0.1, function()
        for _, tc in pairs(escanearAlvos()) do task.spawn(function() kill(tc) end) end
    end)
    task.delay(0.25, function()
        for _, tc in pairs(escanearAlvos()) do
            local h = tc:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then task.spawn(function() kill(tc) end) end
        end
    end)
    notif("Ataque: "..n.." players", 1.2)
end

local function atkNPCs()
    local now = tick()
    if now - lastNpc < 0.15 then return end
    lastNpc = now
    local pChars = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then pChars[p.Character] = true end
    end
    local myChar = lp.Character
    local n = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not pChars[obj] and obj ~= myChar then
            local h = obj:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                n = n + 1
                task.spawn(function() kill(obj) end)
            end
        end
    end
    if n > 0 then notif("NPCs: "..n, 1.2) end
end

UserInputService.TouchStarted:Connect(function(touch, gpe)
    if gpe then return end
    if touch.Position.X > cam.ViewportSize.X * 0.5 then
        if atkOn then atkAll() end
        if npcOn then atkNPCs() end
        if stealOn then stealAll() end
    end
end)

-- ============================================================
-- GOD MODE
-- ============================================================
local GOD_HP = 1000000
local function stopGod()
    godOn = false
    if godConn then pcall(function() godConn:Disconnect() end); godConn = nil end
    pcall(function()
        local char = lp.Character
        if not char then return end
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then
            h.BreakJointsOnDeath = true
            h:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            h.MaxHealth = 100
            h.Health = 100
        end
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("ForceField") then v:Destroy() end
        end
    end)
end

local function setupChar(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        hum.BreakJointsOnDeath = false
        hum.MaxHealth = GOD_HP
        hum.Health = GOD_HP
        if not char:FindFirstChildOfClass("ForceField") then
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = char
        end
    end)
end

local function startGod()
    local char = lp.Character
    setupChar(char)
    godConn = RunService.Heartbeat:Connect(function()
        if not godOn then return end
        local c = lp.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        pcall(function() hum.BreakJointsOnDeath = false; hum.Health = GOD_HP end)
    end)
    local function conectarMorte(c)
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        hum.StateChanged:Connect(function(_, new)
            if not godOn then return end
            if new == Enum.HumanoidStateType.Dead then
                task.defer(function() pcall(function()
                    hum.Health = GOD_HP
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end) end)
            end
        end)
    end
    conectarMorte(char)
    task.spawn(function()
        while godOn do
            task.wait(0.5)
            if not godOn then break end
            local myChar = lp.Character
            local pChars = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then pChars[p.Character] = true end
            end
            for _, obj in pairs(workspace:GetDescendants()) do
                if not godOn then break end
                if obj:IsA("Model") and not pChars[obj] and obj ~= myChar then
                    local eh = obj:FindFirstChildOfClass("Humanoid")
                    if eh and eh.Health > 0 and eh.MaxHealth < 500000 then
                        task.spawn(function() kill(obj) end)
                    end
                end
            end
        end
    end)
    lp.CharacterAdded:Connect(function(nc)
        if not godOn then return end
        task.wait(0.15)
        setupChar(nc)
        conectarMorte(nc)
        if godConn then godConn:Disconnect() end
        startGod()
    end)
end

-- ============================================================
-- VOID ZONE
-- ============================================================
local VOID_SIZE = 2000
local SAFE_RADIUS = 15

local function limparVoid()
    for _, p in pairs(voidParts) do pcall(function() p:Destroy() end) end
    voidParts = {}
    if voidKillConn then voidKillConn:Disconnect(); voidKillConn = nil end
end

local function criarVoid()
    limparVoid()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local centro = root.Position
    local zonaChao = Instance.new("Part")
    zonaChao.Name = "VoidZonaChao"
    zonaChao.Size = Vector3.new(VOID_SIZE, 0.2, VOID_SIZE)
    zonaChao.Position = Vector3.new(centro.X, centro.Y - 3, centro.Z)
    zonaChao.Anchored = true
    zonaChao.CanCollide = false
    zonaChao.CanTouch = true
    zonaChao.Material = Enum.Material.Neon
    zonaChao.Color = Color3.fromRGB(200, 0, 0)
    zonaChao.Transparency = 0.4
    zonaChao.Parent = workspace
    table.insert(voidParts, zonaChao)
    local half = VOID_SIZE / 2
    local sR = SAFE_RADIUS
    for _, s in pairs({
        {sz=Vector3.new(VOID_SIZE,20,half-sR), pos=Vector3.new(centro.X,centro.Y+1,centro.Z+(half+sR)/2)},
        {sz=Vector3.new(VOID_SIZE,20,half-sR), pos=Vector3.new(centro.X,centro.Y+1,centro.Z-(half+sR)/2)},
        {sz=Vector3.new(half-sR,20,sR*2),      pos=Vector3.new(centro.X+(half+sR)/2,centro.Y+1,centro.Z)},
        {sz=Vector3.new(half-sR,20,sR*2),      pos=Vector3.new(centro.X-(half+sR)/2,centro.Y+1,centro.Z)},
    }) do
        local p = Instance.new("Part")
        p.Name = "VoidKill"
        p.Size = s.sz; p.Position = s.pos
        p.Anchored = true; p.CanCollide = false; p.CanTouch = true
        p.Transparency = 1; p.Parent = workspace
        table.insert(voidParts, p)
    end
    voidKillConn = RunService.Heartbeat:Connect(function()
        if not voidOn then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local pr = p.Character:FindFirstChild("HumanoidRootPart")
                if pr and (pr.Position - centro).Magnitude > SAFE_RADIUS then
                    task.spawn(function()
                        pcall(function() firetouchinterest(zonaChao,pr,0); firetouchinterest(zonaChao,pr,1) end)
                        kill(p.Character)
                    end)
                end
            end
        end
    end)
    task.spawn(function()
        while voidOn do
            task.wait(0.5)
            local c = lp.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r then
                local np = r.Position
                local i = 1
                zonaChao.Position = Vector3.new(np.X, np.Y - 3, np.Z)
                local ns = {
                    Vector3.new(np.X, np.Y+1, np.Z+(half+sR)/2),
                    Vector3.new(np.X, np.Y+1, np.Z-(half+sR)/2),
                    Vector3.new(np.X+(half+sR)/2, np.Y+1, np.Z),
                    Vector3.new(np.X-(half+sR)/2, np.Y+1, np.Z),
                }
                for _, vp in pairs(voidParts) do
                    if vp.Name == "VoidKill" then
                        vp.Position = ns[i] or vp.Position
                        i = i + 1
                    end
                end
            end
        end
    end)
    notif("☠️ Void Zone ATIVA!", 4)
end

-- ============================================================
-- ROUBO
-- ============================================================
local lastSteal = 0

local function stealFromPrompt(prompt)
    if not prompt or not prompt.Parent then return end
    local od = prompt.MaxActivationDistance
    local ol = prompt.RequiresLineOfSight
    local ht = prompt.HoldDuration
    pcall(function() prompt.MaxActivationDistance = 9999; prompt.RequiresLineOfSight = false end)
    task.wait(0.05)
    pcall(function() prompt:InputHoldBegin() end)
    task.wait(math.max(ht, 0.1) + 0.05)
    pcall(function() prompt:InputHoldEnd() end)
    pcall(function() fireproximityprompt(prompt) end)
    task.wait(0.1)
    pcall(function() prompt.MaxActivationDistance = od; prompt.RequiresLineOfSight = ol end)
end

local function stealAll()
    local now = tick()
    if now - lastSteal < 0.3 then return end
    lastSteal = now
    local n = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            n = n + 1
            task.spawn(function()
                for _, desc in ipairs(p.Character:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then stealFromPrompt(desc) end
                end
            end)
        end
    end
    if n > 0 then notif("Roubo: "..n, 1.2) end
end

-- ============================================================
-- GUI — AGORA EM gethui() (IMUNE AO ANTI-CHEAT)
-- ============================================================
local W, H = 310, 480
local BG  = Color3.fromRGB(14,14,20)
local HDR = Color3.fromRGB(22,22,32)
local RED = Color3.fromRGB(185,20,20)
local BTN = Color3.fromRGB(40,40,56)
local BHV = Color3.fromRGB(60,60,82)
local GRN = Color3.fromRGB(65,205,85)
local GRY = Color3.fromRGB(65,65,65)
local TXT = Color3.fromRGB(225,225,235)
local SUB = Color3.fromRGB(135,135,155)
local CYN = Color3.fromRGB(50,200,255)
local PRP = Color3.fromRGB(130,50,220)

-- ▶ ScreenGui pai vai para gethui() — o jogo NÃO consegue destruir
local sg = Instance.new("ScreenGui", container)
sg.Name           = "CM_V16_Core"
sg.ResetOnSpawn   = false
sg.IgnoreGuiInset = true
sg.DisplayOrder   = 9998  -- alto, mas abaixo da notif (9999)

local win = Instance.new("Frame", sg)
win.Size = UDim2.new(0,W,0,H)
win.Position = UDim2.new(0.5,-W/2,0.5,-H/2)
win.BackgroundColor3 = BG
win.BorderSizePixel = 0
win.ClipsDescendants = true
Instance.new("UICorner",win).CornerRadius = UDim.new(0,10)
local ws = Instance.new("UIStroke",win)
ws.Color = RED; ws.Thickness = 1.5; ws.Transparency = 0.5

local hdr = Instance.new("Frame",win)
hdr.Size = UDim2.new(1,0,0,44)
hdr.BackgroundColor3 = HDR; hdr.BorderSizePixel = 0
Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,10)
local hfix = Instance.new("Frame",hdr)
hfix.Size = UDim2.new(1,0,0,10)
hfix.Position = UDim2.new(0,0,1,-10)
hfix.BackgroundColor3 = HDR; hfix.BorderSizePixel = 0

local tl = Instance.new("TextLabel",hdr)
tl.Size = UDim2.new(1,-88,1,0); tl.Position = UDim2.new(0,12,0,0)
tl.BackgroundTransparency = 1
tl.Text = "Combat V16  ⚔️  [CoreGui]"
tl.TextColor3 = TXT; tl.Font = Enum.Font.GothamBold; tl.TextSize = 13
tl.TextXAlignment = Enum.TextXAlignment.Left

local function hB(txt, x, col)
    local b = Instance.new("TextButton",hdr)
    b.Size = UDim2.new(0,30,0,30); b.Position = UDim2.new(1,x,0,7)
    b.BackgroundColor3 = col; b.Text = txt; b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.BorderSizePixel = 0
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    return b
end
local closeB = hB("X", -38, Color3.fromRGB(190,30,30))
local minB   = hB("-", -72, Color3.fromRGB(50,50,70))

-- Drag do header
local dw, ds, dp = false, nil, nil
hdr.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dw = true; ds = i.Position; dp = win.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not dw then return end
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseMove then
        local d = i.Position - ds
        win.Position = UDim2.new(dp.X.Scale, dp.X.Offset+d.X, dp.Y.Scale, dp.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then dw = false end
end)

local mini = false
minB.MouseButton1Click:Connect(function()
    mini = not mini
    TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quart),
        {Size = mini and UDim2.new(0,W,0,44) or UDim2.new(0,W,0,H)}):Play()
    minB.Text = mini and "+" or "-"
end)
closeB.MouseButton1Click:Connect(function() win.Visible = false end)

-- Tab Bar
local tabBar = Instance.new("Frame",win)
tabBar.Size = UDim2.new(1,0,0,32); tabBar.Position = UDim2.new(0,0,0,44)
tabBar.BackgroundColor3 = HDR; tabBar.BorderSizePixel = 0
Instance.new("UIListLayout",tabBar).FillDirection = Enum.FillDirection.Horizontal

local tNames = {"Ataque","Aura","Players","God","Roubo","Void","Invis"}
local tbBtns, pages = {}, {}

local area = Instance.new("Frame",win)
area.Size = UDim2.new(1,0,1,-76); area.Position = UDim2.new(0,0,0,76)
area.BackgroundColor3 = BG; area.BorderSizePixel = 0; area.ClipsDescendants = true

for i, n in ipairs(tNames) do
    local tb = Instance.new("TextButton",tabBar)
    tb.Size = UDim2.new(1/#tNames,0,1,0)
    tb.BackgroundColor3 = i==1 and RED or Color3.fromRGB(30,30,44)
    tb.Text = n; tb.TextColor3 = TXT
    tb.Font = Enum.Font.GothamBold; tb.TextSize = 9; tb.BorderSizePixel = 0
    tbBtns[i] = tb
    local pf = Instance.new("ScrollingFrame",area)
    pf.Size = UDim2.new(1,0,1,0); pf.BackgroundTransparency = 1; pf.BorderSizePixel = 0
    pf.ScrollBarThickness = 3; pf.ScrollBarImageColor3 = RED
    pf.CanvasSize = UDim2.new(0,0,0,0); pf.Visible = i==1
    local lay = Instance.new("UIListLayout",pf); lay.Padding = UDim.new(0,6)
    local pad = Instance.new("UIPadding",pf)
    pad.PaddingLeft = UDim.new(0,8); pad.PaddingRight = UDim.new(0,8); pad.PaddingTop = UDim.new(0,8)
    pages[i] = pf
end

for i, tb in ipairs(tbBtns) do
    local idx = i
    tb.MouseButton1Click:Connect(function()
        for j, t in ipairs(tbBtns) do
            t.BackgroundColor3 = j==idx and RED or Color3.fromRGB(30,30,44)
            pages[j].Visible = j==idx
        end
    end)
    -- Activated para mobile
    tb.Activated:Connect(function()
        for j, t in ipairs(tbBtns) do
            t.BackgroundColor3 = j==idx and RED or Color3.fromRGB(30,30,44)
            pages[j].Visible = j==idx
        end
    end)
end

-- Helpers de UI
local function upd(p)
    local lay = p:FindFirstChildOfClass("UIListLayout")
    if lay then p.CanvasSize = UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+16) end
end

local function addToggle(p, label, cb)
    local row = Instance.new("Frame",p)
    row.Size = UDim2.new(1,0,0,46); row.BackgroundColor3 = BTN; row.BorderSizePixel = 0
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)
    local lb = Instance.new("TextLabel",row)
    lb.Size = UDim2.new(1,-62,1,0); lb.Position = UDim2.new(0,12,0,0)
    lb.BackgroundTransparency = 1; lb.Text = label; lb.TextColor3 = TXT
    lb.Font = Enum.Font.GothamBold; lb.TextSize = 13
    lb.TextXAlignment = Enum.TextXAlignment.Left; lb.TextWrapped = true
    local tog = Instance.new("TextButton",row)
    tog.Size = UDim2.new(0,46,0,26); tog.Position = UDim2.new(1,-54,0.5,-13)
    tog.BackgroundColor3 = GRY; tog.Text = ""; tog.BorderSizePixel = 0
    Instance.new("UICorner",tog).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame",tog)
    knob.Size = UDim2.new(0,20,0,20); knob.AnchorPoint = Vector2.new(0,0.5)
    knob.Position = UDim2.new(0,2,0.5,0)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local state = false
    local function set(v)
        state = v
        TweenService:Create(tog,TweenInfo.new(0.18),{BackgroundColor3=v and GRN or GRY}):Play()
        TweenService:Create(knob,TweenInfo.new(0.18),
            {Position = v and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0)}):Play()
        cb(v)
    end
    tog.Activated:Connect(function() set(not state) end)
    upd(p); return set
end

local function addButton(p, label, sub, cb)
    local btn = Instance.new("TextButton",p)
    btn.Size = UDim2.new(1,0,0,sub and 50 or 40)
    btn.BackgroundColor3 = BTN; btn.Text = ""; btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
    local lb = Instance.new("TextLabel",btn)
    lb.Size = UDim2.new(1,-12,0,22); lb.Position = UDim2.new(0,12,0,sub and 5 or 9)
    lb.BackgroundTransparency = 1; lb.Text = label; lb.TextColor3 = TXT
    lb.Font = Enum.Font.GothamBold; lb.TextSize = 13
    lb.TextXAlignment = Enum.TextXAlignment.Left
    if sub then
        local sl = Instance.new("TextLabel",btn)
        sl.Size = UDim2.new(1,-12,0,18); sl.Position = UDim2.new(0,12,0,27)
        sl.BackgroundTransparency = 1; sl.Text = sub; sl.TextColor3 = SUB
        sl.Font = Enum.Font.Gotham; sl.TextSize = 11
        sl.TextXAlignment = Enum.TextXAlignment.Left
    end
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=BHV}):Play() end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=BTN}):Play(); cb() end)
    btn.Activated:Connect(function() cb() end)
    upd(p); return btn
end

local function addSep(p)
    local s = Instance.new("Frame",p)
    s.Size = UDim2.new(1,0,0,1)
    s.BackgroundColor3 = Color3.fromRGB(40,40,55)
    s.BorderSizePixel = 0; upd(p)
end

-- ============================================================
-- TAB 1 — ATAQUE
-- ============================================================
addSep(pages[1])
addToggle(pages[1],"Ataque Players  (toque direito)",function(v)
    atkOn = v; notif(v and "Players ON - toque direito" or "OFF", 2)
end)
addToggle(pages[1],"Ataque NPCs  (toque direito)",function(v)
    npcOn = v; notif(v and "NPCs ON - toque direito" or "OFF", 2)
end)
addSep(pages[1])
addButton(pages[1],"MATAR TODOS AGORA","Players + NPCs ao mesmo tempo",function()
    atkAll(); atkNPCs()
end)
upd(pages[1])

-- ============================================================
-- TAB 2 — KILL AURA
-- ============================================================
local pAura = pages[2]
addSep(pAura)

local tituloAura = Instance.new("Frame",pAura)
tituloAura.Size = UDim2.new(1,0,0,32)
tituloAura.BackgroundColor3 = PRP; tituloAura.BorderSizePixel = 0
Instance.new("UICorner",tituloAura).CornerRadius = UDim.new(0,8)
local tituloTxt = Instance.new("TextLabel",tituloAura)
tituloTxt.Size = UDim2.new(1,0,1,0); tituloTxt.BackgroundTransparency = 1
tituloTxt.Text = "⚔️  KILL AURA — V16"
tituloTxt.TextColor3 = Color3.new(1,1,1)
tituloTxt.Font = Enum.Font.GothamBold; tituloTxt.TextSize = 13
upd(pAura)

addToggle(pAura,"🔴 Ativar Kill Aura",function(v)
    auraOn = v
    notif(v and "⚔️ Kill Aura ON — range: "..auraRange.." studs" or "Kill Aura OFF", 2)
end)
addSep(pAura)
addToggle(pAura,"💀 Atacar Players",function(v)
    auraPlayers = v; notif(v and "Aura Players ON" or "Aura Players OFF", 1.5)
end)
addToggle(pAura,"🤖 Atacar NPCs/Mobs",function(v)
    auraNPCs = v; notif(v and "Aura NPCs ON" or "Aura NPCs OFF", 1.5)
end)
addSep(pAura)

local rangeDisplay = Instance.new("Frame",pAura)
rangeDisplay.Size = UDim2.new(1,0,0,36)
rangeDisplay.BackgroundColor3 = Color3.fromRGB(25,25,38); rangeDisplay.BorderSizePixel = 0
Instance.new("UICorner",rangeDisplay).CornerRadius = UDim.new(0,8)
local rangeLbl = Instance.new("TextLabel",rangeDisplay)
rangeLbl.Size = UDim2.new(1,0,1,0); rangeLbl.BackgroundTransparency = 1
rangeLbl.Text = "📏 Range atual: "..auraRange.." studs"
rangeLbl.TextColor3 = CYN; rangeLbl.Font = Enum.Font.GothamBold; rangeLbl.TextSize = 13
upd(pAura)
auraRangeLabel = rangeLbl

local function atualizarRange(novo)
    auraRange = novo
    rangeLbl.Text = "📏 Range atual: "..novo.." studs"
    notif("Range → "..novo.." studs", 1.5)
end

local presetFrame = Instance.new("Frame",pAura)
presetFrame.Size = UDim2.new(1,0,0,42); presetFrame.BackgroundTransparency = 1; presetFrame.BorderSizePixel = 0
local presetLayout = Instance.new("UIListLayout",presetFrame)
presetLayout.FillDirection = Enum.FillDirection.Horizontal; presetLayout.Padding = UDim.new(0,5)
upd(pAura)

for _, v in ipairs({5, 10, 20, 50, 100, 999}) do
    local pb = Instance.new("TextButton",presetFrame)
    pb.Size = UDim2.new(0,40,0,38); pb.BackgroundColor3 = Color3.fromRGB(80,30,140)
    pb.TextColor3 = Color3.new(1,1,1); pb.Text = tostring(v)
    pb.Font = Enum.Font.GothamBold; pb.TextSize = 12; pb.BorderSizePixel = 0
    Instance.new("UICorner",pb).CornerRadius = UDim.new(0,6)
    pb.Activated:Connect(function()
        atualizarRange(v)
        TweenService:Create(pb,TweenInfo.new(0.1),{BackgroundColor3=PRP}):Play()
        task.delay(0.3,function()
            TweenService:Create(pb,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(80,30,140)}):Play()
        end)
    end)
end
upd(pAura)

local inputRow = Instance.new("Frame",pAura)
inputRow.Size = UDim2.new(1,0,0,46); inputRow.BackgroundColor3 = BTN; inputRow.BorderSizePixel = 0
Instance.new("UICorner",inputRow).CornerRadius = UDim.new(0,8)
local inputLbl = Instance.new("TextLabel",inputRow)
inputLbl.Size = UDim2.new(0,100,1,0); inputLbl.Position = UDim2.new(0,8,0,0)
inputLbl.BackgroundTransparency = 1; inputLbl.Text = "Range custom:"; inputLbl.TextColor3 = TXT
inputLbl.Font = Enum.Font.Gotham; inputLbl.TextSize = 12
local inputBox = Instance.new("TextBox",inputRow)
inputBox.Size = UDim2.new(0,80,0,30); inputBox.Position = UDim2.new(0,108,0.5,-15)
inputBox.BackgroundColor3 = Color3.fromRGB(30,30,45); inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.PlaceholderText = "ex: 35"; inputBox.PlaceholderColor3 = SUB
inputBox.Text = ""; inputBox.Font = Enum.Font.GothamBold; inputBox.TextSize = 13
inputBox.ClearTextOnFocus = true
Instance.new("UICorner",inputBox).CornerRadius = UDim.new(0,6)
local inputOk = Instance.new("TextButton",inputRow)
inputOk.Size = UDim2.new(0,54,0,30); inputOk.Position = UDim2.new(1,-62,0.5,-15)
inputOk.BackgroundColor3 = PRP; inputOk.TextColor3 = Color3.new(1,1,1)
inputOk.Text = "✔ OK"; inputOk.Font = Enum.Font.GothamBold; inputOk.TextSize = 12
Instance.new("UICorner",inputOk).CornerRadius = UDim.new(0,6)
inputOk.Activated:Connect(function()
    local val = tonumber(inputBox.Text)
    if val and val > 0 and val <= 5000 then
        atualizarRange(val); inputBox.Text = ""
    else
        notif("⚠️ Valor inválido (1–5000)", 2)
    end
end)
upd(pAura)
addSep(pAura)
addButton(pAura,"⚡ AMBOS ON — Players + NPCs","Ativa aura em tudo ao mesmo tempo",function()
    auraPlayers = true; auraNPCs = true; auraOn = true
    notif("⚔️ Aura TOTAL ON — "..auraRange.." studs", 2)
end)
addButton(pAura,"⏹ DESLIGAR AURA","Para o Kill Aura",function()
    auraOn = false; notif("Kill Aura OFF", 1.5)
end)
upd(pAura)

-- ============================================================
-- TAB 3 — PLAYERS
-- ============================================================
local pSec = pages[3]
local function clrP()
    for _, v in pairs(pSec:GetChildren()) do
        if type(v.Name)=="string" and v.Name:sub(1,3)=="PB_" then v:Destroy() end
    end
end
local function refreshMap()
    clrP(); local n = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp then
            n = n + 1; local ref = p
            local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            local hp = h and math.floor(h.Health) or "?"
            local b = addButton(pSec, ref.Name, "HP: "..tostring(hp), function()
                if ref.Character then kill(ref.Character); notif("Matou "..ref.Name, 1.5) end
            end)
            b.Name = "PB_"..p.Name
        end
    end
    upd(pSec); return n
end
addButton(pSec,"Atualizar lista","Escaneia todos os players",function()
    notif(refreshMap().." players", 2)
end)
addButton(pSec,"MATAR TODOS","Elimina todo mundo",function() atkAll() end)
addSep(pSec); upd(pSec)
Players.PlayerAdded:Connect(function() task.wait(1); refreshMap() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); refreshMap() end)
task.delay(1, refreshMap)

-- ============================================================
-- TAB 4 — GOD MODE
-- ============================================================
addSep(pages[4])
addToggle(pages[4],"God Mode  (imortal + mata NPCs)",function(v)
    godOn = v
    if v then startGod(); notif("God Mode ON", 4)
    else stopGod(); notif("God Mode OFF", 2) end
end)
addButton(pages[4],"Reiniciar God Mode","Reconecta no char atual",function()
    if not godOn then notif("Ative primeiro", 2); return end
    if godConn then godConn:Disconnect() end; startGod(); notif("Reiniciado", 2)
end)
addButton(pages[4],"Matar NPCs agora","Varre todos os NPCs",function() atkNPCs() end)
upd(pages[4])

-- ============================================================
-- TAB 5 — ROUBO
-- ============================================================
addSep(pages[5])
addToggle(pages[5],"Roubo Global  (toque direito)",function(v)
    stealOn = v; notif(v and "Roubo ON" or "Roubo OFF", 2)
end)
addSep(pages[5])
addButton(pages[5],"ROUBAR TODOS AGORA","Teleporta atrás de cada player e rouba",function()
    stealAll()
end)
addButton(pages[5],"AUTO ROUBO  (loop)","Repete a cada 1s em todos os players",function()
    if stealOn then stealOn = false; notif("Auto Roubo OFF", 2)
    else stealOn = true; notif("Auto Roubo ON", 2)
        task.spawn(function() while stealOn do stealAll(); task.wait(1) end end)
    end
end)
upd(pages[5])

-- ============================================================
-- TAB 6 — VOID
-- ============================================================
addSep(pages[6])
addToggle(pages[6],"☠️ VOID ZONE  (zona vermelha no chão)",function(v)
    voidOn = v
    if v then criarVoid() else limparVoid(); notif("Void OFF", 2) end
end)
addButton(pages[6],"Reposicionar Void","Centraliza no personagem atual",function()
    if not voidOn then notif("Ative primeiro", 2); return end
    limparVoid(); voidOn = true; criarVoid()
end)
addButton(pages[6],"KILL ZONE AGORA","Mata todos fora do raio safe",function()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local n = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local pr = p.Character:FindFirstChild("HumanoidRootPart")
            if pr and (pr.Position-root.Position).Magnitude > SAFE_RADIUS then
                n = n + 1; task.spawn(function() kill(p.Character) end)
            end
        end
    end
    notif("☠️ "..n.." eliminados", 2)
end)
upd(pages[6])

-- ============================================================
-- TAB 7 — INVIS
-- ============================================================
addSep(pages[7])
addButton(pages[7],"👻 ATIVAR INVISÍVEL","God Mode ativa junto automaticamente",function()
    notif("Carregando invisível...", 1)
    task.spawn(function()
        if not godOn then godOn = true; startGod() end
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function()
                hum.BreakJointsOnDeath = false
                hum.MaxHealth = GOD_HP; hum.Health = GOD_HP
            end) end
        end
        pcall(function()
            loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
        end)
        task.wait(0.3)
        pcall(function()
            local c = lp.Character
            if c then
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                lp.CameraMode = Enum.CameraMode.Classic
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum then
                    workspace.CurrentCamera.CameraSubject = hum
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    hum.BreakJointsOnDeath = false
                    hum.Health = GOD_HP
                end
            end
        end)
        notif("👻 Invisível + God Mode ON", 3)
    end)
end)
lp.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        lp.CameraMode = Enum.CameraMode.Classic
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then workspace.CurrentCamera.CameraSubject = hum end
    end)
end)
addButton(pages[7],"Recarregar","Usa após respawn",function()
    task.spawn(function()
        if not godOn then godOn = true; startGod() end
        pcall(function()
            loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
        end)
        task.wait(0.3)
        pcall(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            lp.CameraMode = Enum.CameraMode.Classic
            local c = lp.Character
            if c then
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum then workspace.CurrentCamera.CameraSubject = hum end
            end
        end)
        notif("Recarregado", 2)
    end)
end)
addButton(pages[7],"🔧 FIX TELA PRETA","Usa se travar após morte",function()
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        lp.CameraMode = Enum.CameraMode.Classic
        local c = lp.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
    notif("✅ Câmera restaurada!", 2)
end)
upd(pages[7])

-- ============================================================
-- FLOAT BUTTON — também no container imune
-- ============================================================
local fsg = Instance.new("ScreenGui", container)
fsg.Name = "CM_Float_Core"
fsg.ResetOnSpawn = false
fsg.IgnoreGuiInset = true
fsg.DisplayOrder = 10000  -- acima de tudo

local fb = Instance.new("TextButton", fsg)
fb.Size = UDim2.new(0,52,0,52); fb.Position = UDim2.new(0,10,0.5,0)
fb.BackgroundColor3 = RED; fb.Text = "[C]"; fb.TextColor3 = Color3.new(1,1,1)
fb.Font = Enum.Font.GothamBold; fb.TextSize = 14; fb.BorderSizePixel = 0
Instance.new("UICorner",fb).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke",fb).Color = Color3.fromRGB(255,80,80)

local fd, fs, fp, fdist = false, nil, nil, 0
fb.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        fd = true; fdist = 0; fs = i.Position; fp = fb.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not fd then return end
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseMove then
        local d = i.Position - fs; fdist = d.Magnitude
        fb.Position = UDim2.new(fp.X.Scale, fp.X.Offset+d.X, fp.Y.Scale, fp.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then fd = false end
end)
fb.Activated:Connect(function()
    if fdist > 8 then return end
    win.Visible = not win.Visible; mini = false
    if win.Visible then
        win.Size = UDim2.new(0,W,0,H)
        fb.BackgroundColor3 = RED
    else
        fb.BackgroundColor3 = Color3.fromRGB(40,40,40)
    end
end)

notif("V16 pronto! ⚔️  [C] abre o menu — GUI blindada CoreGui!", 4)
