-- ================================================
--   WAYPOINT SAVER v6.0
--   MoveTo Bypass — servidor vê como caminhada
--   Humanoid:MoveTo() = movimento 100% legítimo
--   Delta Executor Mobile
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local LP    = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Char, HRP, Hum

local function RefreshChar()
    Char = LP.Character
    if Char then
        HRP = Char:FindFirstChild("HumanoidRootPart")
        Hum = Char:FindFirstChildOfClass("Humanoid")
    end
end
RefreshChar()
LP.CharacterAdded:Connect(function(c)
    task.wait(1); Char = c
    HRP = c:WaitForChild("HumanoidRootPart")
    Hum = c:WaitForChild("Humanoid")
end)

-- ================================================
-- DADOS
-- ================================================
local MAX_WAYPOINTS = 15
local Waypoints     = {}
local MarkingMode   = false

-- ================================================
-- MODOS DE TELEPORTE
-- MOVETO   → Humanoid:MoveTo (legítimo pro servidor)
-- DIRETO   → CFrame instantâneo
-- ================================================
local ModoTP       = "MOVETO"
local TPAtivo      = false
local TPConns      = {}

local function LimparConns()
    for _, c in ipairs(TPConns) do pcall(function() c:Disconnect() end) end
    TPConns = {}
    TPAtivo = false
end

-- ================================================
-- MOVETO BYPASS
-- Aumenta WalkSpeed absurdamente pra chegar rápido
-- Servidor lê como corrida — não como TP
-- ================================================
local function TeleportMoveTo(pos)
    LimparConns()
    RefreshChar()
    if not HRP or not Hum then return end

    TPAtivo = true

    local destino     = pos + Vector3.new(0, 1, 0)
    local speedOrig   = Hum.WalkSpeed
    local jumpOrig    = Hum.JumpPower

    -- Velocidade absurda — chega em ~0.1s mesmo longe
    Hum.WalkSpeed = 9999
    Hum.JumpPower = 0

    -- MoveTo legítimo
    Hum:MoveTo(destino)

    -- Aguarda chegar OU timeout de 1s
    local chegou = false
    local t = 0

    local conn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        if not TPAtivo then return end
        RefreshChar()
        if not HRP or not Hum then LimparConns(); return end

        local dist = (HRP.Position - destino).Magnitude

        -- Chegou perto o suficiente
        if dist < 3 or t > 1 then
            chegou = true
            Hum.WalkSpeed = speedOrig
            Hum.JumpPower = jumpOrig
            Hum:MoveTo(HRP.Position) -- para o movimento
            LimparConns()
        end
    end)

    table.insert(TPConns, conn)

    -- Fallback: se demorou demais, força CFrame
    task.delay(1.2, function()
        if TPAtivo and not chegou then
            LimparConns()
            RefreshChar()
            if HRP then HRP.CFrame = CFrame.new(destino) end
            if Hum then
                Hum.WalkSpeed = speedOrig
                Hum.JumpPower = jumpOrig
            end
        end
    end)
end

-- ================================================
-- FUNÇÃO PRINCIPAL DE TELEPORTE
-- ================================================
local function Teleport(pos)
    if ModoTP == "MOVETO" then
        TeleportMoveTo(pos)
    else
        RefreshChar()
        if HRP then
            HRP.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end
    end
end

-- ================================================
-- MARCADORES VISUAIS
-- ================================================
local MarkersFolder = Instance.new("Folder")
MarkersFolder.Name   = "WP_Markers"
MarkersFolder.Parent = Workspace

local function SpawnMarker(pos, index)
    local old  = MarkersFolder:FindFirstChild("WP_"  .. index); if old  then old:Destroy()  end
    local oldB = MarkersFolder:FindFirstChild("WPB_" .. index); if oldB then oldB:Destroy() end

    local part = Instance.new("Part")
    part.Name = "WP_"..index; part.Size = Vector3.new(2,0.2,2)
    part.Position = Vector3.new(pos.X, pos.Y+0.2, pos.Z)
    part.Anchored = true; part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(0,180,255); part.Transparency = 0.3
    part.Parent = MarkersFolder

    local beam = Instance.new("Part")
    beam.Name = "WPB_"..index; beam.Size = Vector3.new(0.3,6,0.3)
    beam.Position = Vector3.new(pos.X, pos.Y+3, pos.Z)
    beam.Anchored = true; beam.CanCollide = false
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(0,180,255); beam.Transparency = 0.5
    beam.Parent = MarkersFolder

    local BG = Instance.new("BillboardGui", part)
    BG.Size = UDim2.new(0,40,0,40); BG.StudsOffset = Vector3.new(0,4,0); BG.AlwaysOnTop = true
    local TL = Instance.new("TextLabel", BG)
    TL.Size = UDim2.new(1,0,1,0); TL.BackgroundColor3 = Color3.fromRGB(0,0,0)
    TL.BackgroundTransparency = 0.4; TL.TextColor3 = Color3.fromRGB(255,255,255)
    TL.Text = tostring(index); TL.Font = Enum.Font.GothamBold; TL.TextSize = 18
    Instance.new("UICorner", TL).CornerRadius = UDim.new(1,0)
end

local function RemoveMarker(index)
    local p = MarkersFolder:FindFirstChild("WP_"  .. index); if p then p:Destroy() end
    local b = MarkersFolder:FindFirstChild("WPB_" .. index); if b then b:Destroy() end
end

-- ================================================
-- GUI
-- ================================================
pcall(function()
    local v = game:GetService("CoreGui"):FindFirstChild("WP_GUI6")
    if v then v:Destroy() end
end)

local SG = Instance.new("ScreenGui")
SG.Name = "WP_GUI6"; SG.ResetOnSpawn = false
SG.DisplayOrder = 999; SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = LP.PlayerGui end

-- Ícone
local Icone = Instance.new("TextButton", SG)
Icone.Size = UDim2.new(0,58,0,58); Icone.Position = UDim2.new(0,14,0.38,0)
Icone.BackgroundColor3 = Color3.fromRGB(10,10,20)
Icone.Text = "📍"; Icone.TextSize = 26; Icone.Font = Enum.Font.GothamBold
Icone.BorderSizePixel = 0; Icone.ZIndex = 50
Instance.new("UICorner", Icone).CornerRadius = UDim.new(1,0)
local IcStroke = Instance.new("UIStroke", Icone)
IcStroke.Color = Color3.fromRGB(0,180,255); IcStroke.Thickness = 2

local iDrag, iDS, iSP, iMoved = false
Icone.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        iDrag=true; iMoved=false; iDS=i.Position; iSP=Icone.Position
    end
end)
Icone.InputChanged:Connect(function(i)
    if iDrag and (i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = i.Position - iDS
        if math.abs(d.X)>6 or math.abs(d.Y)>6 then iMoved=true end
        Icone.Position = UDim2.new(iSP.X.Scale, iSP.X.Offset+d.X,
                                    iSP.Y.Scale, iSP.Y.Offset+d.Y)
    end
end)
Icone.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then iDrag=false end
end)

-- Menu
local Menu = Instance.new("Frame", SG)
Menu.Size = UDim2.new(0,230,0,430); Menu.Position = UDim2.new(0,82,0.38,0)
Menu.BackgroundColor3 = Color3.fromRGB(10,10,16); Menu.BorderSizePixel = 0
Menu.Active = true; Menu.Visible = false; Menu.ZIndex = 40
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0,12)
local MStroke = Instance.new("UIStroke", Menu)
MStroke.Color = Color3.fromRGB(0,180,255); MStroke.Thickness = 1.5

-- Header
local Header = Instance.new("Frame", Menu)
Header.Size = UDim2.new(1,0,0,42); Header.BackgroundColor3 = Color3.fromRGB(0,110,190)
Header.BorderSizePixel = 0; Header.Active = true; Header.ZIndex = 41
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,12)
local HFix = Instance.new("Frame", Header)
HFix.Size = UDim2.new(1,0,0,12); HFix.Position = UDim2.new(0,0,1,-12)
HFix.BackgroundColor3 = Color3.fromRGB(0,110,190); HFix.BorderSizePixel = 0; HFix.ZIndex = 41

local HTitle = Instance.new("TextLabel", Header)
HTitle.Size = UDim2.new(1,-50,1,0); HTitle.Position = UDim2.new(0,12,0,0)
HTitle.BackgroundTransparency = 1; HTitle.Text = "📍 WAYPOINTS"
HTitle.TextColor3 = Color3.fromRGB(255,255,255); HTitle.Font = Enum.Font.GothamBold
HTitle.TextSize = 14; HTitle.TextXAlignment = Enum.TextXAlignment.Left; HTitle.ZIndex = 42

local BtnX = Instance.new("TextButton", Header)
BtnX.Size = UDim2.new(0,30,0,30); BtnX.Position = UDim2.new(1,-36,0.5,-15)
BtnX.BackgroundColor3 = Color3.fromRGB(160,20,20); BtnX.TextColor3 = Color3.fromRGB(255,255,255)
BtnX.Text = "✕"; BtnX.Font = Enum.Font.GothamBold; BtnX.TextSize = 13
BtnX.BorderSizePixel = 0; BtnX.ZIndex = 43
Instance.new("UICorner", BtnX).CornerRadius = UDim.new(0,8)

-- Contador
local CountLabel = Instance.new("TextLabel", Menu)
CountLabel.Size = UDim2.new(1,-16,0,18); CountLabel.Position = UDim2.new(0,8,0,46)
CountLabel.BackgroundTransparency = 1; CountLabel.Text = "0 / 15 salvos"
CountLabel.TextColor3 = Color3.fromRGB(130,130,150); CountLabel.Font = Enum.Font.Gotham
CountLabel.TextSize = 11; CountLabel.TextXAlignment = Enum.TextXAlignment.Left; CountLabel.ZIndex = 41

-- Botão MARCAR
local MarkBtn = Instance.new("TextButton", Menu)
MarkBtn.Size = UDim2.new(1,-16,0,36); MarkBtn.Position = UDim2.new(0,8,0,68)
MarkBtn.BackgroundColor3 = Color3.fromRGB(0,130,210); MarkBtn.TextColor3 = Color3.fromRGB(255,255,255)
MarkBtn.Text = "🎯  MARCAR POSIÇÃO"; MarkBtn.Font = Enum.Font.GothamBold
MarkBtn.TextSize = 12; MarkBtn.BorderSizePixel = 0; MarkBtn.ZIndex = 41
Instance.new("UICorner", MarkBtn).CornerRadius = UDim.new(0,8)

local HintLabel = Instance.new("TextLabel", Menu)
HintLabel.Size = UDim2.new(1,-16,0,16); HintLabel.Position = UDim2.new(0,8,0,108)
HintLabel.BackgroundTransparency = 1; HintLabel.Text = ""
HintLabel.TextColor3 = Color3.fromRGB(255,200,0); HintLabel.Font = Enum.Font.Gotham
HintLabel.TextSize = 10; HintLabel.TextXAlignment = Enum.TextXAlignment.Left; HintLabel.ZIndex = 41

-- Seletor de modo
local ModoBox = Instance.new("Frame", Menu)
ModoBox.Size = UDim2.new(1,-16,0,50); ModoBox.Position = UDim2.new(0,8,0,128)
ModoBox.BackgroundColor3 = Color3.fromRGB(12,12,22); ModoBox.BorderSizePixel = 0; ModoBox.ZIndex = 41
Instance.new("UICorner", ModoBox).CornerRadius = UDim.new(0,10)
local MBStroke = Instance.new("UIStroke", ModoBox)
MBStroke.Color = Color3.fromRGB(0,180,80); MBStroke.Thickness = 1

local ModoLbl = Instance.new("TextLabel", ModoBox)
ModoLbl.Size = UDim2.new(1,0,0,20); ModoLbl.Position = UDim2.new(0,10,0,2)
ModoLbl.BackgroundTransparency = 1; ModoLbl.Text = "🚶 MODO DE TELEPORTE"
ModoLbl.TextColor3 = Color3.fromRGB(100,200,120); ModoLbl.Font = Enum.Font.GothamBold
ModoLbl.TextSize = 10; ModoLbl.TextXAlignment = Enum.TextXAlignment.Left; ModoLbl.ZIndex = 42

local BtnMoveTo = Instance.new("TextButton", ModoBox)
BtnMoveTo.Size = UDim2.new(0,100,0,24); BtnMoveTo.Position = UDim2.new(0,8,0,22)
BtnMoveTo.BackgroundColor3 = Color3.fromRGB(0,130,50); BtnMoveTo.TextColor3 = Color3.fromRGB(255,255,255)
BtnMoveTo.Text = "🛡 MOVETO (safe)"; BtnMoveTo.Font = Enum.Font.GothamBold; BtnMoveTo.TextSize = 9
BtnMoveTo.BorderSizePixel = 0; BtnMoveTo.ZIndex = 42
Instance.new("UICorner", BtnMoveTo).CornerRadius = UDim.new(0,6)

local BtnDireto = Instance.new("TextButton", ModoBox)
BtnDireto.Size = UDim2.new(0,100,0,24); BtnDireto.Position = UDim2.new(0,114,0,22)
BtnDireto.BackgroundColor3 = Color3.fromRGB(30,30,50); BtnDireto.TextColor3 = Color3.fromRGB(160,160,200)
BtnDireto.Text = "⚡ DIRETO"; BtnDireto.Font = Enum.Font.GothamBold; BtnDireto.TextSize = 9
BtnDireto.BorderSizePixel = 0; BtnDireto.ZIndex = 42
Instance.new("UICorner", BtnDireto).CornerRadius = UDim.new(0,6)

local function AtualizarModo()
    BtnMoveTo.BackgroundColor3 = ModoTP=="MOVETO" and Color3.fromRGB(0,130,50) or Color3.fromRGB(30,30,50)
    BtnDireto.BackgroundColor3 = ModoTP=="DIRETO" and Color3.fromRGB(0,110,190) or Color3.fromRGB(30,30,50)
    MBStroke.Color = ModoTP=="MOVETO" and Color3.fromRGB(0,200,80) or Color3.fromRGB(0,140,220)
end

BtnMoveTo.Activated:Connect(function()
    ModoTP = "MOVETO"; AtualizarModo()
    HintLabel.Text = "🛡 MoveTo ativo"; task.delay(1.5, function() HintLabel.Text="" end)
end)
BtnDireto.Activated:Connect(function()
    ModoTP = "DIRETO"; AtualizarModo()
    HintLabel.Text = "⚡ Direto ativo"; task.delay(1.5, function() HintLabel.Text="" end)
end)

-- Divisor
local Div = Instance.new("Frame", Menu)
Div.Size = UDim2.new(1,-16,0,1); Div.Position = UDim2.new(0,8,0,184)
Div.BackgroundColor3 = Color3.fromRGB(30,30,50); Div.BorderSizePixel = 0; Div.ZIndex = 41

local ListTitle = Instance.new("TextLabel", Menu)
ListTitle.Size = UDim2.new(1,-16,0,18); ListTitle.Position = UDim2.new(0,8,0,189)
ListTitle.BackgroundTransparency = 1; ListTitle.Text = "POSIÇÕES SALVAS"
ListTitle.TextColor3 = Color3.fromRGB(90,90,115); ListTitle.Font = Enum.Font.GothamBold
ListTitle.TextSize = 10; ListTitle.TextXAlignment = Enum.TextXAlignment.Left; ListTitle.ZIndex = 41

-- Scroll
local Scroll = Instance.new("ScrollingFrame", Menu)
Scroll.Size = UDim2.new(1,-16,0,228); Scroll.Position = UDim2.new(0,8,0,210)
Scroll.BackgroundColor3 = Color3.fromRGB(8,8,14); Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4; Scroll.ScrollBarImageColor3 = Color3.fromRGB(0,140,220)
Scroll.ElasticBehavior = Enum.ElasticBehavior.Always
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 41
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0,8)
local LL = Instance.new("UIListLayout", Scroll)
LL.Padding = UDim.new(0,4); LL.SortOrder = Enum.SortOrder.LayoutOrder
local LP2 = Instance.new("UIPadding", Scroll)
LP2.PaddingTop=UDim.new(0,4); LP2.PaddingBottom=UDim.new(0,4)
LP2.PaddingLeft=UDim.new(0,4); LP2.PaddingRight=UDim.new(0,4)

-- Drag menu
local mDrag, mDS, mSP = false
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        mDrag=true; mDS=i.Position; mSP=Menu.Position
    end
end)
Header.InputChanged:Connect(function(i)
    if mDrag and (i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = i.Position - mDS
        Menu.Position = UDim2.new(mSP.X.Scale, mSP.X.Offset+d.X,
                                   mSP.Y.Scale, mSP.Y.Offset+d.Y)
    end
end)
Header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then mDrag=false end
end)

-- Lista
local function UpdateCount()
    CountLabel.Text = #Waypoints.." / "..MAX_WAYPOINTS.." salvos"
end

local function RebuildList()
    for _, v in ipairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    for i, wp in ipairs(Waypoints) do
        local Row = Instance.new("Frame", Scroll)
        Row.Size = UDim2.new(1,0,0,38); Row.BackgroundColor3 = Color3.fromRGB(18,18,28)
        Row.BorderSizePixel = 0; Row.LayoutOrder = i; Row.ZIndex = 42
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0,6)

        local NameLbl = Instance.new("TextLabel", Row)
        NameLbl.Size = UDim2.new(1,-90,1,0); NameLbl.Position = UDim2.new(0,8,0,0)
        NameLbl.BackgroundTransparency = 1; NameLbl.Text = "📍 "..wp.name
        NameLbl.TextColor3 = Color3.fromRGB(220,220,220); NameLbl.Font = Enum.Font.Gotham
        NameLbl.TextSize = 11; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.TextTruncate = Enum.TextTruncate.AtEnd; NameLbl.ZIndex = 43

        local TpBtn = Instance.new("TextButton", Row)
        TpBtn.Size = UDim2.new(0,50,0,26); TpBtn.Position = UDim2.new(1,-84,0.5,-13)
        TpBtn.BackgroundColor3 = Color3.fromRGB(0,130,210); TpBtn.TextColor3 = Color3.fromRGB(255,255,255)
        TpBtn.Text = "⚡ TP"; TpBtn.Font = Enum.Font.GothamBold; TpBtn.TextSize = 10
        TpBtn.BorderSizePixel = 0; TpBtn.ZIndex = 43
        Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0,6)

        local DelBtn = Instance.new("TextButton", Row)
        DelBtn.Size = UDim2.new(0,26,0,26); DelBtn.Position = UDim2.new(1,-30,0.5,-13)
        DelBtn.BackgroundColor3 = Color3.fromRGB(160,25,25); DelBtn.TextColor3 = Color3.fromRGB(255,255,255)
        DelBtn.Text = "✕"; DelBtn.Font = Enum.Font.GothamBold; DelBtn.TextSize = 12
        DelBtn.BorderSizePixel = 0; DelBtn.ZIndex = 43
        Instance.new("UICorner", DelBtn).CornerRadius = UDim.new(0,6)

        local idx = i
        TpBtn.Activated:Connect(function()
            Teleport(Waypoints[idx].position)
            TpBtn.BackgroundColor3 = Color3.fromRGB(255,180,0)
            task.spawn(function()
                while TPAtivo do task.wait(0.1) end
                TpBtn.BackgroundColor3 = Color3.fromRGB(0,200,80)
                task.delay(0.5, function() TpBtn.BackgroundColor3 = Color3.fromRGB(0,130,210) end)
            end)
        end)
        DelBtn.Activated:Connect(function()
            RemoveMarker(idx); table.remove(Waypoints, idx)
            MarkersFolder:ClearAllChildren()
            for j, w in ipairs(Waypoints) do SpawnMarker(w.position, j) end
            RebuildList(); UpdateCount()
        end)
    end
    UpdateCount()
end

local function AddWaypoint(pos)
    if #Waypoints >= MAX_WAYPOINTS then
        HintLabel.Text = "⚠ Limite de 15!"
        task.delay(2, function() HintLabel.Text="" end); return
    end
    local idx = #Waypoints + 1
    table.insert(Waypoints, { name="WP "..idx, position=pos })
    SpawnMarker(pos, idx); RebuildList()
    HintLabel.Text = "✅ WP "..idx.." salvo!"
    task.delay(2, function() HintLabel.Text="" end)
end

-- Eventos
local MenuAberto = false

Icone.Activated:Connect(function()
    if iMoved then return end
    MenuAberto = not MenuAberto; Menu.Visible = MenuAberto
end)
BtnX.Activated:Connect(function() MenuAberto=false; Menu.Visible=false end)

MarkBtn.Activated:Connect(function()
    MarkingMode = not MarkingMode
    if MarkingMode then
        MarkBtn.BackgroundColor3 = Color3.fromRGB(220,130,0)
        MarkBtn.Text = "🟠  CLIQUE NO CHÃO..."; HintLabel.Text = "Toque no chão pra salvar"
    else
        MarkBtn.BackgroundColor3 = Color3.fromRGB(0,130,210)
        MarkBtn.Text = "🎯  MARCAR POSIÇÃO"; HintLabel.Text = ""
    end
end)

UserInputService.TouchTapInWorld:Connect(function(pos, processed)
    if processed or not MarkingMode then return end
    local unitRay = Workspace.CurrentCamera:ScreenPointToRay(pos.X, pos.Y)
    local params  = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character or Instance.new("Folder"), MarkersFolder}
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction*1000, params)
    if result then
        AddWaypoint(result.Position); MarkingMode=false
        MarkBtn.BackgroundColor3=Color3.fromRGB(0,130,210)
        MarkBtn.Text="🎯  MARCAR POSIÇÃO"; HintLabel.Text=""
    end
end)

Mouse.Button1Down:Connect(function()
    if not MarkingMode then return end
    local hit = Mouse.Target
    if not hit or hit:IsDescendantOf(SG) then return end
    AddWaypoint(Mouse.Hit.Position); MarkingMode=false
    MarkBtn.BackgroundColor3=Color3.fromRGB(0,130,210)
    MarkBtn.Text="🎯  MARCAR POSIÇÃO"; HintLabel.Text=""
end)

AtualizarModo()
UpdateCount()
print("[Waypoints v6.0] MoveTo bypass ativo 🛡")
