--[[
    ╔══════════════════════════════════════════════════════╗
    ║    GLOBAL ACTION - MULTIPLAYER SCRIPT V2             ║
    ║    Delta Executor Mobile - Roblox                    ║
    ║                                                      ║
    ║  ► Ação Universal: QUALQUER coisa que você fizer     ║
    ║    será executada em TODOS os players               ║
    ║  ► ESP com linhas saindo de você até todos players   ║
    ║  ► TP invisível ou TP visível para atacar todos      ║
    ║  ► Interface arrastável otimizada para mobile        ║
    ╚══════════════════════════════════════════════════════╝
--]]

-- ============================================================
--  SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")

local LocalPlayer     = Players.LocalPlayer
local Camera          = workspace.CurrentCamera

-- ============================================================
--  CONFIGURAÇÕES
-- ============================================================
local CFG = {
    -- ESP
    LineColor         = Color3.fromRGB(255, 60, 60),
    LineThickness     = 2,
    ESPFillColor      = Color3.fromRGB(255, 30, 30),
    ESPOutlineColor   = Color3.fromRGB(0, 255, 120),
    ESPFillTransp     = 0.75,

    -- Cores de distância no nome
    DistClose         = Color3.fromRGB(255, 50,  50),   -- < 20 studs
    DistMid           = Color3.fromRGB(255, 200,  0),   -- < 60 studs
    DistFar           = Color3.fromRGB(0,   255, 100),  -- > 60 studs

    -- Ação fantasma
    GhostOffset       = Vector3.new(0, 0, 2.5),
    GhostWait         = 0.04,
    ReturnDelay       = 0.02,
}

-- ============================================================
--  ESTADO GLOBAL
-- ============================================================
local espData              = {}
local globalMode          = false
local universalActionMode = false  -- NOVO: Modo de ação universal
local isProjecting        = false
local lastActionTime      = 0
local actionCooldown      = 0.05

-- ============================================================
--  UTILS
-- ============================================================
local function getRoot(player)
    local char = player and player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getMyRoot()
    return getRoot(LocalPlayer)
end

-- ============================================================
--  NÚCLEO: AÇÃO UNIVERSAL GLOBAL
--  Qualquer ação (botão, RemoteEvent, etc) é executada
--  em TODOS os players automaticamente
-- ============================================================

local lastClickedObject = nil
local actionQueue = {}

-- Intercepta cliques/ativações de objetos
local function interceptAction(obj)
    if not universalActionMode then return end
    if not obj then return end
    
    local now = tick()
    if now - lastActionTime < actionCooldown then return end
    lastActionTime = now

    local myRoot = getMyRoot()
    if not myRoot then return end

    local originalCFrame = myRoot.CFrame
    local myChar = LocalPlayer.Character

    -- Loop por cada player
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            local targetRoot = getRoot(target)
            if targetRoot then
                -- TP rápido até o alvo (invisível)
                myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                task.wait(CFG.GhostWait)

                -- Executa a ação no contexto do alvo
                pcall(function()
                    -- Se for um botão, clica nele
                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        obj:Activate()
                        if obj.MouseButton1Click then
                            obj:FireEvent("MouseButton1Click")
                        end
                    end

                    -- Se for um RemoteEvent, dispara
                    if obj:IsA("RemoteEvent") then
                        obj:FireServer()
                    end

                    -- Se for uma ferramenta, ativa
                    if obj:IsA("Tool") then
                        obj:Activate()
                    end

                    -- Se for um objeto com handle (arma), usa touch interest
                    if obj:FindFirstChild("Handle") then
                        local handle = obj:FindFirstChild("Handle")
                        for _, p in pairs(target.Character:GetChildren()) do
                            if p:IsA("BasePart") then
                                firetouchinterest(handle, p, 0)
                                firetouchinterest(handle, p, 1)
                            end
                        end
                    end

                    -- ProximityPrompt (roubo, etc)
                    if obj:IsA("ProximityPrompt") then
                        obj:InputHoldBegin()
                        task.wait(math.max(obj.HoldDuration, 0.1) + 0.05)
                        obj:InputHoldEnd()
                        fireproximityprompt(obj)
                    end
                end)

                task.wait(CFG.GhostWait)
            end
        end
    end

    -- Volta para a posição original
    task.wait(CFG.ReturnDelay)
    myRoot.CFrame = originalCFrame
end

-- ============================================================
--  PROJEÇÃO DE AÇÃO (modo invisível original)
-- ============================================================
local function ProjectActionToAll()
    if isProjecting then return end
    isProjecting = true

    local myRoot = getMyRoot()
    if not myRoot then
        isProjecting = false
        return
    end

    local originalCFrame = myRoot.CFrame
    local myChar = LocalPlayer.Character
    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true
    end

    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer then
            local targetRoot = getRoot(target)
            if targetRoot then
                local projectionPos = targetRoot.CFrame * CFrame.new(CFG.GhostOffset)
                myRoot.CFrame = projectionPos
                task.wait(CFG.GhostWait)

                pcall(function()
                    local tool = myChar:FindFirstChildOfClass("Tool")
                    if tool then
                        local activate = tool:FindFirstChild("Activate")
                        if activate and activate:IsA("RemoteEvent") then
                            activate:FireServer()
                        end
                        tool:Activate()
                    end
                end)
            end
        end
    end

    task.wait(CFG.ReturnDelay)
    myRoot.CFrame = originalCFrame

    if hrp then
        hrp.Anchored = false
    end

    isProjecting = false
end

-- ============================================================
--  TP ATAQUE GLOBAL (TP visível + mata)
-- ============================================================
local function TPAttackAll()
    if isProjecting then return end
    isProjecting = true

    local myRoot = getMyRoot()
    if not myRoot then
        isProjecting = false
        return
    end

    local originalCFrame = myRoot.CFrame
    local myChar = LocalPlayer.Character

    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            local targetRoot = getRoot(target)
            if targetRoot then
                -- TP visível até o alvo
                myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.1)

                -- Ataque com ferramentas
                pcall(function()
                    local tool = myChar:FindFirstChildOfClass("Tool")
                    if tool then
                        local handle = tool:FindFirstChild("Handle")
                        if handle then
                            for _, p in pairs(target.Character:GetChildren()) do
                                if p:IsA("BasePart") then
                                    firetouchinterest(handle, p, 0)
                                    firetouchinterest(handle, p, 1)
                                end
                            end
                        end
                        tool:Activate()
                    end
                end)

                task.wait(0.1)
            end
        end
    end

    task.wait(0.2)
    myRoot.CFrame = originalCFrame
    isProjecting = false
end

-- ============================================================
--  ESP: CRIAR
-- ============================================================
local function CreateESP(player)
    if player == LocalPlayer then return end
    if espData[player.UserId] then return end

    local line = Drawing.new("Line")
    line.Color      = CFG.LineColor
    line.Thickness  = CFG.LineThickness
    line.Visible    = false
    line.ZIndex     = 1

    local hl = Instance.new("Highlight")
    hl.FillColor          = CFG.ESPFillColor
    hl.OutlineColor       = CFG.ESPOutlineColor
    hl.FillTransparency   = CFG.ESPFillTransp
    hl.OutlineTransparency = 0
    hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop

    local bb = Instance.new("BillboardGui")
    bb.Size        = UDim2.new(0, 160, 0, 44)
    bb.StudsOffset = Vector3.new(0, 4, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 2000

    local lbl = Instance.new("TextLabel")
    lbl.Size                  = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3            = CFG.DistFar
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3      = Color3.new(0, 0, 0)
    lbl.TextScaled            = true
    lbl.Font                  = Enum.Font.GothamBold
    lbl.Text                  = player.Name
    lbl.Parent                = bb

    espData[player.UserId] = {
        line      = line,
        highlight = hl,
        billboard = bb,
        nameLabel = lbl,
    }

    local function attachToChar(char)
        local head = char:WaitForChild("Head", 6)
        if head then
            bb.Parent = head
            hl.Parent = char
        end
    end

    if player.Character then
        attachToChar(player.Character)
    end
    player.CharacterAdded:Connect(attachToChar)
end

-- ============================================================
--  ESP: REMOVER
-- ============================================================
local function RemoveESP(player)
    local d = espData[player.UserId]
    if not d then return end
    pcall(function() d.line:Remove() end)
    pcall(function() d.highlight:Destroy() end)
    pcall(function() d.billboard:Destroy() end)
    espData[player.UserId] = nil
end

-- ============================================================
--  INTERCEPTAR CLIQUES EM BUTTONS/OBJETOS
-- ============================================================
local function hookButtonClicks()
    -- Intercepta todos os TextButtons
    local function hookButton(button)
        if not button:IsA("GuiButton") then return end
        
        local oldActivate = button.Activated
        button.Activated:Connect(function()
            if universalActionMode then
                interceptAction(button)
            end
        end)

        button.MouseButton1Click:Connect(function()
            if universalActionMode then
                interceptAction(button)
            end
        end)
    end

    -- Hook em todos os buttons da tela
    local function scanGui(parent)
        for _, child in pairs(parent:GetDescendants()) do
            if child:IsA("GuiButton") then
                hookButton(child)
            end
        end
    end

    scanGui(LocalPlayer:WaitForChild("PlayerGui"))
    scanGui(game.CoreGui)

    -- Hook para novos buttons criados
    LocalPlayer.PlayerGui.DescendantAdded:Connect(function(child)
        if child:IsA("GuiButton") then
            hookButton(child)
        end
    end)
end

-- ============================================================
--  GUI PRINCIPAL
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "GlobalActionGUI_V2"
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = LocalPlayer.PlayerGui

local Panel = Instance.new("Frame")
Panel.Name                 = "Panel"
Panel.Size                 = UDim2.new(0, 280, 0, 520)
Panel.Position             = UDim2.new(0.5, -140, 0.5, -260)
Panel.BackgroundColor3     = Color3.fromRGB(10, 10, 15)
Panel.BackgroundTransparency = 0.05
Panel.BorderSizePixel      = 0
Panel.Parent               = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke", Panel)
Stroke.Color       = Color3.fromRGB(255, 60, 60)
Stroke.Thickness   = 1.5
Stroke.Transparency = 0.4

-- ── Título ─────────────────────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Size              = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3  = Color3.fromRGB(200, 30, 30)
TitleBar.BorderSizePixel   = 0
TitleBar.Parent            = Panel
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleText = Instance.new("TextLabel")
TitleText.Size                  = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text                  = "⚡ AÇÃO GLOBAL UNIVERSAL"
TitleText.TextColor3            = Color3.fromRGB(255, 255, 255)
TitleText.TextScaled            = true
TitleText.Font                  = Enum.Font.GothamBold
TitleText.Parent                = TitleBar

-- ── ScrollingFrame para os botões ─────────────────────────
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -50)
ScrollFrame.Position = UDim2.new(0, 0, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 30, 30)
ScrollFrame.Parent = Panel

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local UIPadding = Instance.new("UIPadding", ScrollFrame)
UIPadding.PaddingLeft = UDim.new(0, 8)
UIPadding.PaddingRight = UDim.new(0, 8)
UIPadding.PaddingTop = UDim.new(0, 8)
UIPadding.PaddingBottom = UDim.new(0, 8)

-- Função para criar botões
local function createButton(parent, text, subtext, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, subtext and 50 or 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, 22)
    label.Position = UDim2.new(0, 12, 0, subtext and 5 or 9)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(225, 225, 235)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    if subtext then
        local sublabel = Instance.new("TextLabel")
        sublabel.Size = UDim2.new(1, -12, 0, 18)
        sublabel.Position = UDim2.new(0, 12, 0, 27)
        sublabel.BackgroundTransparency = 1
        sublabel.Text = subtext
        sublabel.TextColor3 = Color3.fromRGB(135, 135, 155)
        sublabel.Font = Enum.Font.Gotham
        sublabel.TextSize = 11
        sublabel.TextXAlignment = Enum.TextXAlignment.Left
        sublabel.Parent = btn
    end

    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 82)}):Play()
    end)

    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
    end)

    btn.Activated:Connect(callback)
    return btn
end

-- Função para criar toggle
local function createToggle(parent, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 46)
    row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -62, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(225, 225, 235)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = row

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 46, 0, 26)
    toggle.Position = UDim2.new(1, -54, 0.5, -13)
    toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = row
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = false
    local function setState(v)
        state = v
        local newColor = v and Color3.fromRGB(65, 205, 85) or Color3.fromRGB(65, 65, 65)
        TweenService:Create(toggle, TweenInfo.new(0.18), {BackgroundColor3 = newColor}):Play()
        TweenService:Create(knob, TweenInfo.new(0.18),
            {Position = v and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}):Play()
        callback(v)
    end

    toggle.Activated:Connect(function() setState(not state) end)
    return setState
end

-- ============================================================
--  BOTÕES DA GUI
-- ============================================================

-- MODO AÇÃO UNIVERSAL
createToggle(ScrollFrame, "🌍 MODO AÇÃO UNIVERSAL", function(v)
    universalActionMode = v
    if v then
        Stroke.Color = Color3.fromRGB(0, 255, 100)
        print("✅ MODO AÇÃO UNIVERSAL ATIVADO - TODOS OS CLIQUES SERÃO GLOBAIS")
        hookButtonClicks()
    else
        Stroke.Color = Color3.fromRGB(255, 60, 60)
        print("❌ Modo Ação Universal desativado")
    end
end)

createButton(ScrollFrame, "⚡ EXECUTAR EM TODOS AGORA", "Ativa ação projetada", function()
    ProjectActionToAll()
end)

createButton(ScrollFrame, "💀 TP ATAQUE GLOBAL", "TP visível + mata todos", function()
    TPAttackAll()
end)

createButton(ScrollFrame, "🌐 MODO GLOBAL INVISÍVEL", "TP invisível automático", function()
    globalMode = not globalMode
    if globalMode then
        hookButtonClicks()
    end
end)

-- ============================================================
--  ARRASTAR PAINEL
-- ============================================================
do
    local dragging    = false
    local dragStartPos
    local panelStartPos

    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = inp.Position
            panelStartPos = Panel.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStartPos
            Panel.Position = UDim2.new(
                panelStartPos.X.Scale,
                panelStartPos.X.Offset + delta.X,
                panelStartPos.Y.Scale,
                panelStartPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ============================================================
--  INIT: Criar ESP
-- ============================================================
for _, p in pairs(Players:GetPlayers()) do
    CreateESP(p)
end

Players.PlayerAdded:Connect(function(p)
    task.wait(0.5)
    CreateESP(p)
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- ============================================================
--  RENDER LOOP: Atualizar ESP
-- ============================================================
RunService.RenderStepped:Connect(function()
    local myRoot = getMyRoot()
    local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local d = espData[player.UserId]
            if d then
                local root = getRoot(player)
                if root then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    d.line.From    = origin
                    d.line.To      = Vector2.new(screenPos.X, screenPos.Y)
                    d.line.Visible = onScreen

                    if myRoot then
                        local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                        d.nameLabel.Text = "👤 " .. player.Name .. "\n📏 " .. dist .. " m"

                        if dist < 20 then
                            d.nameLabel.TextColor3 = CFG.DistClose
                        elseif dist < 60 then
                            d.nameLabel.TextColor3 = CFG.DistMid
                        else
                            d.nameLabel.TextColor3 = CFG.DistFar
                        end
                    end
                else
                    d.line.Visible = false
                end
            end
        end
    end
end)

-- ============================================================
print("╔════════════════════════════════════════════╗")
print("║  AÇÃO GLOBAL UNIVERSAL — V2 LOADED ✅     ║")
print("║  Qualquer ação será executada em TODOS    ║")
print("╚════════════════════════════════════════════╝")
