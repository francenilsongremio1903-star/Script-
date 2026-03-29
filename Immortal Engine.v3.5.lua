    GODMODE = {
        {true}, {lp, true}, {true, lp}, {1}, 
        {lp, "god"}, {"enable", lp}, {tick(), true}
    },
    REVIVE = {
        {lp}, {lp.Character}, {true, lp}, {os.time(), lp}
    }
}

function BypassGenerator.TrySimpleBypass(remoteData)
    local obj = remoteData.Object
    local remoteType = remoteData.Type
    local argsList = COMMON_ARGUMENTS[remoteType] or {{lp}, {100}, {true}}
    
    Log("🔓 Testando " .. remoteData.Name .. " (" .. #argsList .. " combinações)...", "BYPASS")
    
    for i, args in ipairs(argsList) do
        -- Limita a 3 tentativas por remote para não travar
        if i > 3 then break end
        
        local success = pcall(function()
            if remoteData.IsFunction then
                return obj:InvokeServer(unpack(args))
            else
                obj:FireServer(unpack(args))
                return true
            end
        end)
        
        if success then
            Log("✅ BYPASS: " .. remoteData.Name .. " funciona!", "SUCCESS")
            return {
                remote = remoteData,
                method = "Simple_" .. i,
                args = args,
                working = true
            }
        end
        
        task.wait(0.1) -- Delay entre tentativas
    end
    
    return nil
end

function BypassGenerator.CreateUniversalGodmode()
    Log("🔓 Criando proteção universal...", "BYPASS")
    
    local char = lp.Character
    if not char then return false end
    
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    
    -- Método 1: Loop simples de heal (sem hooks perigosos)
    task.spawn(function()
        while GodModeActive do
            pcall(function()
                if hum.Health < LOCAL_CONFIG.MaxHealth then
                    hum.Health = LOCAL_CONFIG.MaxHealth
                end
            end)
            task.wait(0.1) -- Intervalo seguro
        end
    end)
    
    -- Método 2: Detectar dano e reverter
    hum.HealthChanged:Connect(function(newHealth)
        if newHealth < LOCAL_CONFIG.MaxHealth and GodModeActive then
            task.delay(0.05, function()
                pcall(function()
                    hum.Health = LOCAL_CONFIG.MaxHealth
                end)
            end)
        end
    end)
    
    Log("🔓 Proteção universal ativa!", "BYPASS")
    return true
end

function BypassGenerator.GenerateCustomBypass()
    -- Evita múltiplas gerações simultâneas
    if IsGeneratingBypass then
        Log("⚠️ Geração já em andamento...", "WARNING")
        return false
    end
    
    IsGeneratingBypass = true
    Log("🔓 Iniciando geração de bypass...", "BYPASS")
    
    local bypassesEncontrados = 0
    
    -- Tenta cada remote encontrado (limite de 5 para não travar)
    local allRemotes = {}
    for _, r in ipairs(DiscoveredRemotes.Heal) do table.insert(allRemotes, r) end
    for _, r in ipairs(DiscoveredRemotes.SetHealth) do table.insert(allRemotes, r) end
    for _, r in ipairs(DiscoveredRemotes.GodMode) do table.insert(allRemotes, r) end
    
    -- Limita a 5 remotes
    for i = 1, math.min(#allRemotes, 5) do
        local remoteData = allRemotes[i]
        local bypass = BypassGenerator.TrySimpleBypass(remoteData)
        
        if bypass then
            table.insert(ActiveBypasses, bypass)
            bypassesEncontrados = bypassesEncontrados + 1
        end
        
        task.wait(0.2) -- Delay entre remotes
    end
    
    -- Se não achou nenhum, ativa proteção universal
    if bypassesEncontrados == 0 then
        Log("⚠️ Nenhum remote funcionou, ativando universal...", "WARNING")
        BypassGenerator.CreateUniversalGodmode()
        
        -- Adiciona bypass universal virtual
        table.insert(ActiveBypasses, {
            remote = {Name = "Universal", Type = "UNIVERSAL", IsFunction = false},
            method = "Universal",
            args = {},
            working = true,
            universal = true
        })
        bypassesEncontrados = 1
    end
    
    IsGeneratingBypass = false
    Log("✅ " .. bypassesEncontrados .. " bypasses prontos!", "SUCCESS")
    return bypassesEncontrados > 0
end

-- ════════════════════════════════════════════════════════════════
--  IA LOCAL (SIMPLIFICADA)
-- ════════════════════════════════════════════════════════════════
local AI_System = {}

function AI_System.PredictBestArgs(remoteData)
    -- Retorna argumentos comuns baseados no tipo
    local defaults = {
        HEAL = {100, lp},
        SET_HEALTH = {999999, lp},
        MAX_HEALTH = {999999},
        GODMODE = {true, lp},
        REVIVE = {lp}
    }
    return defaults[remoteData.Type] or {lp}
end

-- ════════════════════════════════════════════════════════════════
--  GUI v3.6 (ESTÁVEL)
-- ════════════════════════════════════════════════════════════════
local function CreateAdvancedGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ImmortalEngineV36"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        sg.Parent = game:GetService("CoreGui")
    end)
    if not sg.Parent then
        sg.Parent = lp:WaitForChild("PlayerGui")
    end
    
    GUI = sg
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainPanel"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = sg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 128)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    MainFrame = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.Text = "👑 IMMORTAL v3.6"
    title.TextColor3 = Color3.fromRGB(0, 255, 128)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.Text = "−"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Scroll
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 55)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 128)
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scrollFrame
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Text = "⏳ Pronto"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.BackgroundTransparency = 1
    statusLabel.Parent = scrollFrame
    
    -- Função criar botão
    local function createBtn(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.Text = text
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = scrollFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        btn.Activated:Connect(callback)
        return btn
    end
    
    -- BOTÕES
    createBtn("🔍 SCAN REMOTES", Color3.fromRGB(0, 150, 255), function()
        statusLabel.Text = "⏳ Scanning..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        task.spawn(function()
            local found = ScanForLifeRemotes()
            statusLabel.Text = "✅ " .. found .. " remotes!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
        end)
    end)
    
    createBtn("🔓 GERAR BYPASS", Color3.fromRGB(150, 0, 255), function()
        if IsGeneratingBypass then
            statusLabel.Text = "⏳ Já está gerando..."
            return
        end
        
        statusLabel.Text = "⏳ Gerando... (aguarde)"
        statusLabel.TextColor3 = Color3.fromRGB(150, 0, 255)
        
        task.spawn(function()
            local success = BypassGenerator.GenerateCustomBypass()
            if success then
                statusLabel.Text = "✅ " .. #ActiveBypasses .. " bypasses!"
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
            else
                statusLabel.Text = "❌ Falhou"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end)
    
    createBtn("👑 ATIVAR GODMODE", Color3.fromRGB(0, 200, 100), function()
        if #ActiveBypasses == 0 then
            statusLabel.Text = "⏳ Gerando primeiro..."
            BypassGenerator.GenerateCustomBypass()
            task.wait(1)
        end
        
        if #ActiveBypasses > 0 then
            ActivateGodMode()
            statusLabel.Text = "👑 GODMODE ON!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
        else
            statusLabel.Text = "❌ Sem bypasses"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    createBtn("🛡️ EMERGÊNCIA", Color3.fromRGB(255, 100, 100), function()
        EmergencyHeal()
        statusLabel.Text = "🚨 Heal emergencial!"
    end)
    
    createBtn("⏹️ DESATIVAR", Color3.fromRGB(100, 100, 100), function()
        DeactivateGodMode()
        statusLabel.Text = "⏹️ Desativado"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    -- Botão flutuante
    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, 60, 0, 60)
    floatBtn.Position = UDim2.new(0, 20, 0.3, 0)
    floatBtn.Text = "👑"
    floatBtn.TextSize = 28
    floatBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
    floatBtn.Visible = false
    floatBtn.Parent = sg
    
    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatBtn
    
    -- Minimizar/Maximizar
    local function Minimize()
        IsMinimized = true
        closeBtn.Text = "+"
        closeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        mainFrame.Visible = false
        floatBtn.Visible = true
    end
    
    local function Maximize()
        IsMinimized = false
        closeBtn.Text = "−"
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        floatBtn.Visible = false
        mainFrame.Visible = true
    end
    
    closeBtn.Activated:Connect(function()
        if IsMinimized then Maximize() else Minimize() end
    end)
    floatBtn.Activated:Connect(Maximize)
    
    return sg
end

-- ════════════════════════════════════════════════════════════════
--  SCANNER (OTIMIZADO)
-- ════════════════════════════════════════════════════════════════
local LIFE_KEYWORDS = {
    {kw = {"health", "heal", "life", "hp"}, type = "HEAL", weight = 10},
    {kw = {"sethealth", "changehealth"}, type = "SET_HEALTH", weight = 9},
    {kw = {"maxhealth"}, type = "MAX_HEALTH", weight = 8},
    {kw = {"damage", "hurt", "hit"}, type = "DAMAGE", weight = 10},
    {kw = {"godmode", "god", "invincible"}, type = "GODMODE", weight = 10},
    {kw = {"revive", "respawn"}, type = "REVIVE", weight = 9}
}

local function AnalyzeRemote(obj)
    if not obj or not (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then return nil end
    
    local blacklist = {"kick", "ban", "log"}
    local name = obj.Name:lower()
    for _, k in ipairs(blacklist) do
        if name:find(k, 1, true) then return nil end
    end
    
    local score = 0
    local detectedType = "UNKNOWN"
    
    for _, entry in ipairs(LIFE_KEYWORDS) do
        for _, kw in ipairs(entry.kw) do
            if name:find(kw, 1, true) then
                if entry.weight > score then
                    score = entry.weight
                    detectedType = entry.type
                end
            end
        end
    end
    
    if score >= 6 then
        return {
            Object = obj,
            Name = obj.Name,
            Type = detectedType,
            Path = obj:GetFullName(),
            IsFunction = obj:IsA("RemoteFunction")
        }
    end
    return nil
end

function ScanForLifeRemotes()
    Log("🔍 Scanning...", "INFO")
    local found = 0
    
    local function ScanContainer(container)
        for _, obj in ipairs(container:GetDescendants()) do
            local analysis = AnalyzeRemote(obj)
            if analysis then
                found = found + 1
                Log("Found: " .. analysis.Name, "SUCCESS")
                
                if analysis.Type == "HEAL" then
                    table.insert(DiscoveredRemotes.Heal, analysis)
                elseif analysis.Type == "SET_HEALTH" then
                    table.insert(DiscoveredRemotes.SetHealth, analysis)
                elseif analysis.Type == "MAX_HEALTH" then
                    table.insert(DiscoveredRemotes.MaxHealth, analysis)
                elseif analysis.Type == "GODMODE" then
                    table.insert(DiscoveredRemotes.GodMode, analysis)
                elseif analysis.Type == "REVIVE" then
                    table.insert(DiscoveredRemotes.Revive, analysis)
                end
            end
        end
    end
    
    pcall(function() ScanContainer(ReplicatedStorage) end)
    pcall(function() ScanContainer(workspace) end)
    
    Log("✅ " .. found .. " remotes", "SUCCESS")
    return found
end

-- ════════════════════════════════════════════════════════════════
--  GODMODE (VERSÃO ESTÁVEL)
-- ════════════════════════════════════════════════════════════════
function ActivateGodMode()
    if GodModeActive then return end
    GodModeActive = true
    
    Log("👑 GODMODE ON!", "SUCCESS")
    
    local char = lp.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- Sistema anti-dano simples
    hum.HealthChanged:Connect(function(newHealth)
        if GodModeActive and newHealth < LOCAL_CONFIG.MaxHealth then
            task.delay(0.05, function()
                pcall(function()
                    hum.Health = LOCAL_CONFIG.MaxHealth
                end)
            end)
        end
    end)
    
    -- Loop de proteção
    HealLoopRunning = true
    task.spawn(function()
        while HealLoopRunning and GodModeActive do
            pcall(function()
                if hum.Health < LOCAL_CONFIG.MaxHealth then
                    hum.Health = LOCAL_CONFIG.MaxHealth
                end
            end)
            task.wait(0.1)
        end
    end)
end

function DeactivateGodMode()
    GodModeActive = false
    HealLoopRunning = false
    Log("⏹️ OFF", "INFO")
end

-- ════════════════════════════════════════════════════════════════
--  INICIALIZAÇÃO
-- ════════════════════════════════════════════════════════════════
local function Initialize()
    Log("🚀 v3.6 Estável iniciado", "SUCCESS")
    CreateAdvancedGUI()
    
    -- Auto-scan após 1 segundo
    task.delay(1, function()
        ScanForLifeRemotes()
    end)
    
    -- Tenta conectar cloud em background
    task.delay(3, function()
        local config = CloudSystem.FetchConfig()
        if config then
            CloudSystem.ApplyConfig(config)
            CloudSystem.StartAutoSync()
        end
    end)
end

Initialize()

_G.ImmortalEngine = {
    Scan = ScanForLifeRemotes,
    Activate = ActivateGodMode,
    Deactivate = DeactivateGodMode,
    Emergency = EmergencyHeal,
    GenerateBypass = BypassGenerator.GenerateCustomBypass,
    GetBypasses = function() return ActiveBypasses end
}
