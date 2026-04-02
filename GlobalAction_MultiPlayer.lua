--[[
    ╔══════════════════════════════════════════════════════╗
    ║         GLOBAL ACTION - MULTIPLAYER SCRIPT           ║
    ║         Delta Executor Mobile - Roblox               ║
    ║                                                      ║
    ║  ► ESP com linhas saindo de você até todos players   ║
    ║  ► Sua ação é projetada para TODOS sem você se mover ║
    ║  ► Funciona com qualquer ação: ataque, push, etc     ║
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
    LineColor         = Color3.fromRGB(255, 60, 60),   -- cor das linhas
    LineThickness     = 2,
    ESPFillColor      = Color3.fromRGB(255, 30, 30),
    ESPOutlineColor   = Color3.fromRGB(0, 255, 120),
    ESPFillTransp     = 0.75,

    -- Cores de distância no nome
    DistClose         = Color3.fromRGB(255, 50,  50),  -- < 20 studs
    DistMid           = Color3.fromRGB(255, 200,  0),  -- < 60 studs
    DistFar           = Color3.fromRGB(0,   255, 100), -- > 60 studs

    -- Ação fantasma
    GhostOffset       = Vector3.new(0, 0, 2.5), -- onde a ação será projetada (atrás do alvo)
    GhostWait         = 0.04,                   -- tempo (s) que fica em cada player (mínimo para o jogo registrar)
    ReturnDelay       = 0.02,                   -- delay antes de voltar à posição original
}

-- ============================================================
--  ESTADO GLOBAL
-- ============================================================
local espData         = {}   -- [userId] = { line, highlight, billboard, nameLabel }
local globalMode      = false
local isProjecting    = false

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
--  NÚCLEO: PROJEÇÃO DE AÇÃO
--  O player NÃO se move visualmente.
--  O sistema TP o personagem INVISÍVEL (ultrarápido) até cada
--  alvo → o jogo registra a proximidade → depois volta.
-- ============================================================
local function ProjectActionToAll()
    if isProjecting then return end
    isProjecting = true

    local myRoot = getMyRoot()
    if not myRoot then
        isProjecting = false
        return
    end

    local originalCFrame = myRoot.CFrame  -- salva posição real

    -- Desativa colisão temporariamente para não empurrar nada durante o TP
    local myChar = LocalPlayer.Character
    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true  -- ancora durante a projeção
    end

    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer then
            local targetRoot = getRoot(target)
            if targetRoot then
                -- TP fantasma: vai até o alvo
                local projectionPos = targetRoot.CFrame * CFrame.new(CFG.GhostOffset)
                myRoot.CFrame = projectionPos

                -- Aguarda o jogo registrar a proximidade/ação
                task.wait(CFG.GhostWait)

                -- Dispara tool/habilidade equipada no contexto deste player
                pcall(function()
                    local tool = myChar:FindFirstChildOfClass("Tool")
                    if tool then
                        -- Tenta ativar o tool (funciona na maioria dos jogos)
                        local activate = tool:FindFirstChild("Activate")
                        if activate and activate:IsA("RemoteEvent") then
                            activate:FireServer()
                        end
                        -- Fallback: simula o evento de ativação padrão
                        tool:Activate()
                    end
                end)
            end
        end
    end

    -- Volta para a posição original
    task.wait(CFG.ReturnDelay)
    myRoot.CFrame = originalCFrame

    if hrp then
        hrp.Anchored = false  -- desanchora
    end

    isProjecting = false
end

-- ============================================================
--  ESP: CRIAR
-- ============================================================
local function CreateESP(player)
    if player == LocalPlayer then return end
    if espData[player.UserId] then return end  -- já existe

    -- ── Linha (Drawing) ──────────────────────────────────────
    local line = Drawing.new("Line")
    line.Color      = CFG.LineColor
    line.Thickness  = CFG.LineThickness
    line.Visible    = false
    line.ZIndex     = 1

    -- ── Highlight ────────────────────────────────────────────
    local hl = Instance.new("Highlight")
    hl.FillColor          = CFG.ESPFillColor
    hl.OutlineColor       = CFG.ESPOutlineColor
    hl.FillTransparency   = CFG.ESPFillTransp
    hl.OutlineTransparency = 0
    hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop

    -- ── Billboard (nome + distância) ─────────────────────────
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

    -- Guarda tudo
    espData[player.UserId] = {
        line      = line,
        highlight = hl,
        billboard = bb,
        nameLabel = lbl,
    }

    -- Attach ao personagem
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
--  GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "GlobalActionGUI"
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = LocalPlayer.PlayerGui

-- ── Painel principal ─────────────────────────────────────────
local Panel = Instance.new("Frame")
Panel.Name                 = "Panel"
Panel.Size                 = UDim2.new(0, 250, 0, 200)
Panel.Position             = UDim2.new(0.5, -125, 0.72, 0)
Panel.BackgroundColor3     = Color3.fromRGB(10, 10, 15)
Panel.BackgroundTransparency = 0.05
Panel.BorderSizePixel      = 0
Panel.Parent               = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 14)

-- Borda sutil
local Stroke = Instance.new("UIStroke", Panel)
Stroke.Color       = Color3.fromRGB(255, 60, 60)
Stroke.Thickness   = 1.5
Stroke.Transparency = 0.4

-- ── Título / área de arrastar ─────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Size              = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3  = Color3.fromRGB(200, 30, 30)
TitleBar.BorderSizePixel   = 0
TitleBar.Parent            = Panel
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

-- Corrige canto inferior do TitleBar (para grudar no painel)
local TitleFix = Instance.new("Frame")
TitleFix.Size             = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position         = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
TitleFix.BorderSizePixel  = 0
TitleFix.Parent           = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size                  = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text                  = "⚡  GLOBAL ACTION"
TitleText.TextColor3            = Color3.fromRGB(255, 255, 255)
TitleText.TextScaled            = true
TitleText.Font                  = Enum.Font.GothamBold
TitleText.Parent                = TitleBar

-- ── Status ───────────────────────────────────────────────────
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size                  = UDim2.new(0.9, 0, 0, 22)
StatusLabel.Position              = UDim2.new(0.05, 0, 0, 48)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text                  = "● Modo Global:  DESATIVADO"
StatusLabel.TextColor3            = Color3.fromRGB(160, 160, 160)
StatusLabel.TextScaled            = true
StatusLabel.Font                  = Enum.Font.Gotham
StatusLabel.TextXAlignment        = Enum.TextXAlignment.Left
StatusLabel.Parent                = Panel

-- ── Botão MODO GLOBAL ────────────────────────────────────────
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size              = UDim2.new(0.9, 0, 0, 42)
ToggleBtn.Position          = UDim2.new(0.05, 0, 0, 78)
ToggleBtn.BackgroundColor3  = Color3.fromRGB(40, 40, 55)
ToggleBtn.Text              = "🌐  MODO GLOBAL:  OFF"
ToggleBtn.TextColor3        = Color3.fromRGB(220, 220, 220)
ToggleBtn.TextScaled        = true
ToggleBtn.Font              = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel   = 0
ToggleBtn.Parent            = Panel
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

-- ── Botão EXECUTAR AGORA ─────────────────────────────────────
local ExecBtn = Instance.new("TextButton")
ExecBtn.Size              = UDim2.new(0.9, 0, 0, 42)
ExecBtn.Position          = UDim2.new(0.05, 0, 0, 128)
ExecBtn.BackgroundColor3  = Color3.fromRGB(200, 30, 30)
ExecBtn.Text              = "🎯  EXECUTAR EM TODOS"
ExecBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
ExecBtn.TextScaled        = true
ExecBtn.Font              = Enum.Font.GothamBold
ExecBtn.BorderSizePixel   = 0
ExecBtn.Parent            = Panel
Instance.new("UICorner", ExecBtn).CornerRadius = UDim.new(0, 10)

-- Label de contagem de players
local CountLabel = Instance.new("TextLabel")
CountLabel.Size                   = UDim2.new(0.9, 0, 0, 20)
CountLabel.Position               = UDim2.new(0.05, 0, 0, 176)
CountLabel.BackgroundTransparency = 1
CountLabel.Text                   = "Players conectados: 0"
CountLabel.TextColor3             = Color3.fromRGB(120, 120, 120)
CountLabel.TextScaled             = true
CountLabel.Font                   = Enum.Font.Gotham
CountLabel.Parent                 = Panel

-- ============================================================
--  LÓGICA DOS BOTÕES
-- ============================================================

-- Toggle Modo Global
ToggleBtn.MouseButton1Click:Connect(function()
    globalMode = not globalMode

    if globalMode then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        ToggleBtn.Text             = "🌐  MODO GLOBAL:  ON"
        StatusLabel.Text           = "● Modo Global:  ATIVADO"
        StatusLabel.TextColor3     = Color3.fromRGB(0, 255, 100)
        -- Animação de entrada
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(0, 255, 100)}):Play()
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        ToggleBtn.Text             = "🌐  MODO GLOBAL:  OFF"
        StatusLabel.Text           = "● Modo Global:  DESATIVADO"
        StatusLabel.TextColor3     = Color3.fromRGB(160, 160, 160)
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(255, 60, 60)}):Play()
    end
end)

-- Executar em todos (manual)
ExecBtn.MouseButton1Click:Connect(function()
    if isProjecting then return end

    ExecBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
    ExecBtn.Text             = "⚡  PROJETANDO..."

    task.spawn(ProjectActionToAll)

    task.wait(0.8)
    ExecBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    ExecBtn.Text             = "🎯  EXECUTAR EM TODOS"
end)

-- ============================================================
--  ARRASTAR PAINEL (suporte a touch e mouse)
-- ============================================================
do
    local dragging    = false
    local dragStartPos
    local panelStartPos

    local function onDragStart(pos)
        dragging       = true
        dragStartPos   = pos
        panelStartPos  = Panel.Position
    end

    local function onDragMove(pos)
        if not dragging then return end
        local delta = pos - dragStartPos
        Panel.Position = UDim2.new(
            panelStartPos.X.Scale,
            panelStartPos.X.Offset + delta.X,
            panelStartPos.Y.Scale,
            panelStartPos.Y.Offset + delta.Y
        )
    end

    local function onDragEnd()
        dragging = false
    end

    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            onDragStart(inp.Position)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseMovement then
            onDragMove(inp.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            onDragEnd()
        end
    end)
end

-- ============================================================
--  MODO GLOBAL AUTOMÁTICO: detecta tool ativada e projeta
-- ============================================================
local lastToolActivate = 0

UserInputService.InputBegan:Connect(function(inp, gameHandled)
    if not globalMode then return end
    if gameHandled then return end

    -- Detecta tap/clique (ação do player)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        local now = tick()
        if now - lastToolActivate > 0.1 then  -- debounce
            lastToolActivate = now
            task.spawn(ProjectActionToAll)
        end
    end
end)

-- ============================================================
--  RENDER LOOP: atualiza ESP e linhas a cada frame
-- ============================================================
RunService.RenderStepped:Connect(function()
    local myRoot = getMyRoot()

    -- Ponto de origem das linhas = base da tela (centro inferior)
    local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    local count = 0

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            count += 1
            local d = espData[player.UserId]
            if d then
                local root = getRoot(player)

                if root then
                    -- Linha
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    d.line.From    = origin
                    d.line.To      = Vector2.new(screenPos.X, screenPos.Y)
                    d.line.Visible = onScreen

                    -- Nome + distância
                    if myRoot then
                        local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                        d.nameLabel.Text = "👤 " .. player.Name .. "\n📏 " .. dist .. " m"

                        -- Cor por distância
                        if dist < 20 then
                            d.nameLabel.TextColor3 = CFG.DistClose
                        elseif dist < 60 then
                            d.nameLabel.TextColor3 = CFG.DistMid
                        else
                            d.nameLabel.TextColor3 = CFG.DistFar
                        end
                    end
                else
                    -- Player sem personagem: oculta linha
                    d.line.Visible = false
                end
            end
        end
    end

    CountLabel.Text = "Players conectados: " .. count

    -- Pisca o painel quando está projetando
    if isProjecting then
        Panel.BackgroundTransparency = 0
    else
        Panel.BackgroundTransparency = 0.05
    end
end)

-- ============================================================
--  INIT: cria ESP para todos já na server
-- ============================================================
for _, p in pairs(Players:GetPlayers()) do
    CreateESP(p)
end

Players.PlayerAdded:Connect(function(p)
    -- Aguarda um frame para garantir que o player carregou
    task.wait(0.5)
    CreateESP(p)
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- ============================================================
print("╔════════════════════════════════╗")
print("║   GLOBAL ACTION  ─  LOADED ✅  ║")
print("╚════════════════════════════════╝")
