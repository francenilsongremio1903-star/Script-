-- ════════════════════════════════════════════════════════════════
--  IMMORTAL ENGINE v3.5 - AUTO-BYPASS GENERATOR
--  URL Embutida · IA Cria Bypasses · Godmode Universal
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
--  CONFIGURAÇÃO COM URL EMBUTIDA (EDITÁVEL PELA IA)
-- ════════════════════════════════════════════════════════════════
local CLOUD_CONFIG = {
    -- URL DO SEU PASTEBIN (JÁ CONFIGURADA!)
    ConfigURL = "https://pastebin.com/raw/K3spudw3",
    
    -- Sistema de sincronização
    AutoSync = true,
    SyncInterval = 30,
    LastSync = 0,
    
    -- Segurança
    API_Key = "",
    SecretToken = "immortal_" .. math.random(100000, 999999),
    
    -- Configurações dinâmicas
    DynamicSettings = {},
    
    -- NOVO: Sistema de criação de bypass
    AutoBypassGenerator = true,
    BypassCreationMode = "aggressive",
    MaxBypassAttempts = 10
}

-- Configurações locais
local LOCAL_CONFIG = {
    HealthThreshold = 25,
    CriticalThreshold = 10,
    HealSpamInterval = 0.05,
    GodModeEnabled = true,
    DebugMode = true,
    MaxHealth = 100,
    ParallelSpams = 5,
    AI_Mode = "hybrid",
    EmergencyMode = false,
    
    -- NOVO: Configurações de criação de remote
    CreateFakeRemotes = true,
    HookExistingRemotes = true,
    MetaMethodHook = true
}

-- ════════════════════════════════════════════════════════════════
--  VARIÁVEIS GLOBAIS
-- ════════════════════════════════════════════════════════════════
local DiscoveredRemotes = {Heal = {}, SetHealth = {}, MaxHealth = {}, GodMode = {}, Damage = {}, Revive = {}, Shield = {}}
local ActiveBypasses = {}
local HealLoopRunning = false
local GodModeActive = false
local GUI = nil
local MainFrame = nil
local IsMinimized = false
local AI_Memory = {}
local ConfigVersion = "1.0"
local Logs = {}

-- NOVO: Sistema de hooks e criação
local OriginalRemotes = {}
local CreatedRemotes = {}
local HookedFunctions = {}

-- ════════════════════════════════════════════════════════════════
--  LOG SYSTEM
-- ════════════════════════════════════════════════════════════════
local function Log(msg, type)
    local entry = {time = os.date("%H:%M:%S"), msg = msg, type = type or "INFO"}
    table.insert(Logs, entry)
    if #Logs > 50 then table.remove(Logs, 1) end
    
    if LOCAL_CONFIG.DebugMode then
        local prefix = type == "SUCCESS" and "✅" or type == "WARNING" and "⚠️" 
                    or type == "ERROR" and "❌" or type == "CLOUD" and "☁️" 
                    or type == "AI" and "🤖" or type == "BYPASS" and "🔓" or "ℹ️"
        print(string.format("[%s] %s %s", entry.time, prefix, msg))
    end
end

-- ════════════════════════════════════════════════════════════════
--  SISTEMA DE SINCRONIZAÇÃO CLOUD
-- ════════════════════════════════════════════════════════════════
local CloudSystem = {}

function CloudSystem.FetchConfig()
    Log("☁️ Conectando ao Pastebin...", "CLOUD")
    
    local success, result = pcall(function()
        local response = HttpService:RequestAsync({
            Url = CLOUD_CONFIG.ConfigURL,
            Method = "GET",
            Headers = {["Cache-Control"] = "no-cache"}
        })
        
        if response.Success then
            return HttpService:JSONDecode(response.Body)
        end
        return nil
    end)
    
    if success and result then
        CLOUD_CONFIG.LastSync = tick()
        Log("☁️ Configuração recebida! v" .. (result.version or "1.0"), "CLOUD")
        return result
    else
        Log("❌ Falha na conexão: " .. tostring(result), "ERROR")
        return nil
    end
end

function CloudSystem.ApplyConfig(cloudConfig)
    if not cloudConfig then return false end
    
    if cloudConfig.auth_key and cloudConfig.auth_key ~= CLOUD_CONFIG.API_Key then
        Log("🚫 Auth key inválida", "ERROR")
        return false
    end
    
    if cloudConfig.settings then
        for key, value in pairs(cloudConfig.settings) do
            if LOCAL_CONFIG[key] ~= nil then
                LOCAL_CONFIG[key] = value
                Log("☁️ " .. key .. " = " .. tostring(value), "CLOUD")
            end
        end
    end
    
    if cloudConfig.commands then
        for _, cmd in ipairs(cloudConfig.commands) do
            CloudSystem.ExecuteCommand(cmd)
        end
    end
    
    if cloudConfig.version then
        ConfigVersion = cloudConfig.version
    end
    
    CLOUD_CONFIG.DynamicSettings = cloudConfig
    return true
end

function CloudSystem.ExecuteCommand(cmd)
    Log("🤖 Comando: " .. cmd.action, "AI")
    
    if cmd.action == "emergency_heal" then
        EmergencyHeal()
    elseif cmd.action == "increase_protection" then
        LOCAL_CONFIG.ParallelSpams = math.min(LOCAL_CONFIG.ParallelSpams + 5, 20)
    elseif cmd.action == "set_health_threshold" then
        LOCAL_CONFIG.HealthThreshold = cmd.value or 25
    elseif cmd.action == "force_godmode" then
        if not GodModeActive then ActivateGodMode() end
    elseif cmd.action == "create_bypass" then
        BypassGenerator.CreateFromCommand(cmd)
    elseif cmd.action == "shutdown" then
        DeactivateGodMode()
    end
end

function CloudSystem.StartAutoSync()
    if not CLOUD_CONFIG.AutoSync then return end
    
    task.spawn(function()
        while true do
            task.wait(CLOUD_CONFIG.SyncInterval)
            local config = CloudSystem.FetchConfig()
            if config then
                CloudSystem.ApplyConfig(config)
            end
        end
    end)
    
    Log("☁️ Auto-sync ativo (30s)", "CLOUD")
end

-- ════════════════════════════════════════════════════════════════
--  SISTEMA ANTI-ONESHOT
-- ════════════════════════════════════════════════════════════════
local function ParallelHealSpam(count)
    local spamCount = count or LOCAL_CONFIG.ParallelSpams
    for i = 1, spamCount do
        task.spawn(function()
            for _, bypass in ipairs(ActiveBypasses) do
                if bypass.remote.Type == "HEAL" or bypass.remote.Type == "SET_HEALTH" or bypass.remote.Type == "MAX_HEALTH" then
                    pcall(function()
                        if bypass.remote.IsFunction then
                            bypass.remote.Object:InvokeServer(unpack(bypass.args))
                        else
                            bypass.remote.Object:FireServer(unpack(bypass.args))
                        end
                    end)
                end
            end
        end)
    end
end

function EmergencyHeal()
    Log("🚨 EMERGÊNCIA!", "ERROR")
    local emergencySpams = LOCAL_CONFIG.EmergencyMode and 20 or LOCAL_CONFIG.ParallelSpams
    ParallelHealSpam(emergencySpams)
    
    task.spawn(function()
        for i = 1, 10 do
            pcall(function()
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Health = LOCAL_CONFIG.MaxHealth
                    lp.Character.Humanoid.MaxHealth = math.max(lp.Character.Humanoid.MaxHealth, 1000)
                end
            end)
            task.wait(0.01)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  🔓 SISTEMA DE CRIAÇÃO DE BYPASS (NOVO v3.5)
-- ════════════════════════════════════════════════════════════════
local BypassGenerator = {}

function BypassGenerator.AnalyzeGameStructure()
    Log("🔓 Analisando estrutura do jogo...", "BYPASS")
    
    local analysis = {
        hasCustomHealthSystem = false,
        healthRemotes = {},
        damageRemotes = {},
        adminRemotes = {},
        vulnerablePoints = {}
    }
    
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            if name:find("health") or name:find("damage") or name:find("character") then
                analysis.hasCustomHealthSystem = true
                table.insert(analysis.vulnerablePoints, {
                    type = "ModuleScript",
                    path = obj:GetFullName(),
                    name = obj.Name
                })
            end
        end
    end
    
    for _, remote in ipairs(DiscoveredRemotes.Damage) do
        table.insert(analysis.damageRemotes, {
            path = remote.Path,
            name = remote.Name,
            args = BypassGenerator.GuessArgs(remote, "DAMAGE")
        })
    end
    
    return analysis
end

function BypassGenerator.GuessArgs(remoteData, forcedType)
    local remoteType = forcedType or remoteData.Type
    local name = remoteData.Name:lower()
    
    local patterns = {
        HEAL = {
            {100, lp},
            {lp, 100},
            {999999},
            {"heal", lp, 100},
            {lp, "full"},
            {os.time(), lp, 100}
        },
        SET_HEALTH = {
            {100, lp},
            {lp, 100},
            {999999, lp},
            {lp, 999999},
            {math.huge, lp},
            {1/0, lp}
        },
        GODMODE = {
            {true, lp},
            {lp, true},
            {true},
            {1, lp},
            {"enable", lp},
            {lp, "god"},
            {tick(), true, lp}
        },
        DAMAGE = {
            {0, lp},
            {lp, 0},
            {false, lp},
            {lp, false}
        },
        REVIVE = {
            {lp},
            {lp, lp.Character},
            {true, lp},
            {os.time(), lp}
        }
    }
    
    if patterns[remoteType] then
        return patterns[remoteType]
    end
    
    if name:find("admin") or name:find("mod") then
        return {
            {lp, 999999, true},
            {"godmode", lp, true},
            {true, lp, 999999}
        }
    end
    
    return {
        {lp},
        {lp, 100},
        {100, lp},
        {true, lp},
        {lp, true}
    }
end

function BypassGenerator.CreateFakeRemote(remoteType, targetPath)
    Log("🔓 Criando fake remote tipo: " .. remoteType, "BYPASS")
    
    local parent = ReplicatedStorage
    local fakeRemote = Instance.new("RemoteEvent")
    fakeRemote.Name = "Admin_" .. remoteType .. "_" .. math.random(1000, 9999)
    fakeRemote.Parent = parent
    
    local originalRemote = nil
    for _, r in ipairs(DiscoveredRemotes[remoteType] or {}) do
        if r.Path == targetPath then
            originalRemote = r.Object
            break
        end
    end
    
    if originalRemote then
        local originalFire = originalRemote.FireServer
        originalRemote.FireServer = function(self, ...)
            Log("🔓 Interceptado: " .. originalRemote.Name, "BYPASS")
            return originalFire(self, ...)
        end
    end
    
    table.insert(CreatedRemotes, {
        fake = fakeRemote,
        type = remoteType,
        target = targetPath,
        createdAt = tick()
    })
    
    return fakeRemote
end

function BypassGenerator.TryAllCombinations(remoteData)
    Log("🔓 Tentando combinações para: " .. remoteData.Name, "BYPASS")
    
    local obj = remoteData.Object
    local allArgs = BypassGenerator.GuessArgs(remoteData)
    local specialArgs = {
        {lp, lp.Character},
        {lp.Character},
        {lp.Character and lp.Character:FindFirstChild("Humanoid")},
        {lp.UserId},
        {lp.Name},
        {game.PlaceId, lp},
        {tick(), lp},
        {math.random(1000000, 9999999), lp},
        {true, false, lp},
        {nil, lp},
        {},
        {lp, nil},
        {lp, {}, true}
    }
    
    for _, arg in ipairs(specialArgs) do
        table.insert(allArgs, arg)
    end
    
    for i, args in ipairs(allArgs) do
        if i > CLOUD_CONFIG.MaxBypassAttempts then break end
        
        local success, result = pcall(function()
            if remoteData.IsFunction then
                return obj:InvokeServer(unpack(args))
            else
                obj:FireServer(unpack(args))
                return true
            end
        end)
        
        if success then
            Log("🔓 BYPASS CRIADO! Args: " .. HttpService:JSONEncode(args), "BYPASS")
            return {
                remote = remoteData,
                method = "Generated_" .. i,
                args = args,
                working = true,
                generated = true
            }
        end
        
        task.wait(0.05)
    end
    
    return nil
end

function BypassGenerator.HookMetaMethods()
    if not LOCAL_CONFIG.MetaMethodHook then return end
    
    Log("🔓 Hookando metamétodos...", "BYPASS")
    
    local mt = getrawmetatable(game)
    if mt then
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if (method == "FireServer" or method == "InvokeServer") and self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                local name = self.Name:lower()
                
                if name:find("damage") or name:find("hurt") or name:find("kill") then
                    Log("🔓 Interceptado remote de dano: " .. self.Name, "BYPASS")
                    
                    if LOCAL_CONFIG.BypassCreationMode == "aggressive" then
                        return nil
                    end
                end
                
                if name:find("heal") or name:find("health") then
                    Log("🔓 Interceptado remote de heal: " .. self.Name .. " Args: " .. HttpService:JSONEncode(args), "BYPASS")
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        setreadonly(mt, true)
        Log("🔓 Metamétodos hookados!", "BYPASS")
    end
end

function BypassGenerator.CreateUniversalGodmode()
    Log("🔓 Criando godmode universal...", "BYPASS")
    
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    local lastHealth = hum.Health
    hum.HealthChanged:Connect(function(newHealth)
        if newHealth < lastHealth then
            task.spawn(function()
                hum.Health = LOCAL_CONFIG.MaxHealth
            end)
        end
        lastHealth = hum.Health
    end)
    
    pcall(function()
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end)
    
    task.spawn(function()
        while true do
            pcall(function()
                if hum.Health < LOCAL_CONFIG.MaxHealth then
                    hum.Health = LOCAL_CONFIG.MaxHealth
                end
            end)
            task.wait(0.01)
        end
    end)
    
    Log("🔓 Godmode universal ativo!", "BYPASS")
    return true
end

function BypassGenerator.CreateFromCommand(cmd)
    if cmd.remote_type == "heal" then
        return BypassGenerator.CreateFakeRemote("HEAL", cmd.target_path)
    elseif cmd.remote_type == "godmode" then
        return BypassGenerator.CreateFakeRemote("GODMODE", cmd.target_path)
    elseif cmd.action == "universal_godmode" then
        return BypassGenerator.CreateUniversalGodmode()
    end
end

function BypassGenerator.GenerateCustomBypass()
    Log("🔓 INICIANDO GERAÇÃO DE BYPASS CUSTOMIZADO...", "BYPASS")
    
    local analysis = BypassGenerator.AnalyzeGameStructure()
    BypassGenerator.HookMetaMethods()
    BypassGenerator.CreateUniversalGodmode()
    
    for remoteType, remotes in pairs(DiscoveredRemotes) do
        for _, remoteData in ipairs(remotes) do
            local bypass = BypassGenerator.TryAllCombinations(remoteData)
            if bypass then
                table.insert(ActiveBypasses, bypass)
                Log("🔓 Bypass gerado para: " .. remoteData.Name, "BYPASS")
            end
            
            if CLOUD_CONFIG.BypassCreationMode == "aggressive" then
                BypassGenerator.CreateFakeRemote(remoteType, remoteData.Path)
            end
            
            task.wait(0.1)
        end
    end
    
    if #ActiveBypasses == 0 then
        Log("🔓 Usando godmode universal puro", "BYPASS")
        table.insert(ActiveBypasses, {
            remote = {Name = "UniversalGodmode", Type = "UNIVERSAL"},
            method = "DirectMemory",
            args = {},
            working = true,
            universal = true
        })
    end
    
    Log("🔓 Geração completa! " .. #ActiveBypasses .. " bypasses ativos", "BYPASS")
    return #ActiveBypasses > 0
end

-- ════════════════════════════════════════════════════════════════
--  IA LOCAL
-- ════════════════════════════════════════════════════════════════
local AI_System = {}

function AI_System.AnalyzeRemotePattern(remoteData, testResults)
    local pattern = {
        remoteName = remoteData.Name,
        remoteType = remoteData.Type,
        successfulArgs = nil,
        successRate = 0,
        timestamp = os.time()
    }
    
    for _, test in ipairs(testResults) do
        if test.success then
            pattern.successfulArgs = test.args
            pattern.successRate = test.score or 1
            break
        end
    end
    
    if pattern.successfulArgs then
        AI_Memory[remoteData.Path] = pattern
        Log("🤖 IA aprendeu: " .. remoteData.Name, "AI")
    end
    
    return pattern
end

function AI_System.PredictBestArgs(remoteData)
    if AI_Memory[remoteData.Path] then
        return AI_Memory[remoteData.Path].successfulArgs
    end
    
    if CLOUD_CONFIG.DynamicSettings.ai_memory and CLOUD_CONFIG.DynamicSettings.ai_memory[remoteData.Path] then
        return CLOUD_CONFIG.DynamicSettings.ai_memory[remoteData.Path].successfulArgs
    end
    
    return BypassGenerator.GuessArgs(remoteData)[1]
end

-- ════════════════════════════════════════════════════════════════
--  GUI v3.5
-- ════════════════════════════════════════════════════════════════
local function CreateAdvancedGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ImmortalEngineV35"
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
    mainFrame.Size = UDim2.new(0, 320, 0, 480)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -240)
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
    header.Size = UDim2.new(1, 0, 0, 55)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 0.6, 0)
    title.Position = UDim2.new(0.05, 0, 0.1, 0)
    title.Text = "👑 IMMORTAL v3.5"
    title.TextColor3 = Color3.fromRGB(0, 255, 128)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local bypassStatus = Instance.new("TextLabel")
    bypassStatus.Name = "BypassStatus"
    bypassStatus.Size = UDim2.new(0.5, 0, 0.3, 0)
    bypassStatus.Position = UDim2.new(0.05, 0, 0.6, 0)
    bypassStatus.Text = "🔓 Generator: OFF"
    bypassStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    bypassStatus.Font = Enum.Font.Gotham
    bypassStatus.TextSize = 10
    bypassStatus.BackgroundTransparency = 1
    bypassStatus.TextXAlignment = Enum.TextXAlignment.Left
    bypassStatus.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.Text = "−"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -65)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
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
    
    -- SEÇÃO CLOUD
    local cloudFrame = Instance.new("Frame")
    cloudFrame.Size = UDim2.new(1, 0, 0, 100)
    cloudFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
    cloudFrame.BorderSizePixel = 0
    cloudFrame.Parent = scrollFrame
    
    local cloudFrameCorner = Instance.new("UICorner")
    cloudFrameCorner.CornerRadius = UDim.new(0, 12)
    cloudFrameCorner.Parent = cloudFrame
    
    local cloudTitle = Instance.new("TextLabel")
    cloudTitle.Size = UDim2.new(1, -10, 0, 20)
    cloudTitle.Position = UDim2.new(0, 5, 0, 5)
    cloudTitle.Text = "☁️ CLOUD CONFIG (AUTO-LOAD)"
    cloudTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    cloudTitle.Font = Enum.Font.GothamBold
    cloudTitle.TextSize = 12
    cloudTitle.BackgroundTransparency = 1
    cloudTitle.Parent = cloudFrame
    
    local urlLabel = Instance.new("TextLabel")
    urlLabel.Size = UDim2.new(1, -10, 0, 20)
    urlLabel.Position = UDim2.new(0, 5, 0, 25)
    urlLabel.Text = "URL: " .. CLOUD_CONFIG.ConfigURL:sub(1, 30) .. "..."
    urlLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    urlLabel.Font = Enum.Font.Gotham
    urlLabel.TextSize = 9
    urlLabel.BackgroundTransparency = 1
    urlLabel.Parent = cloudFrame
    
    local apiInput = Instance.new("TextBox")
    apiInput.Size = UDim2.new(1, -70, 0, 25)
    apiInput.Position = UDim2.new(0, 5, 0, 50)
    apiInput.PlaceholderText = "API Key (opcional)..."
    apiInput.Text = ""
    apiInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    apiInput.BackgroundColor3 = Color3.fromRGB(40, 45, 70)
    apiInput.Font = Enum.Font.Gotham
    apiInput.TextSize = 10
    apiInput.Parent = cloudFrame
    
    local apiCorner = Instance.new("UICorner")
    apiCorner.CornerRadius = UDim.new(0, 6)
    apiCorner.Parent = apiInput
    
    local connectBtn = Instance.new("TextButton")
    connectBtn.Size = UDim2.new(0, 60, 0, 25)
    connectBtn.Position = UDim2.new(1, -65, 0, 50)
    connectBtn.Text = "🔗"
    connectBtn.TextSize = 16
    connectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    connectBtn.Parent = cloudFrame
    
    local connectCorner = Instance.new("UICorner")
    connectCorner.CornerRadius = UDim.new(0, 6)
    connectCorner.Parent = connectBtn
    
    local cloudStatusLabel = Instance.new("TextLabel")
    cloudStatusLabel.Size = UDim2.new(1, -10, 0, 20)
    cloudStatusLabel.Position = UDim2.new(0, 5, 0, 78)
    cloudStatusLabel.Text = "⏳ Auto-conectando em 3s..."
    cloudStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    cloudStatusLabel.Font = Enum.Font.Gotham
    cloudStatusLabel.TextSize = 10
    cloudStatusLabel.BackgroundTransparency = 1
    cloudStatusLabel.Parent = cloudFrame
    
    task.delay(3, function()
        local config = CloudSystem.FetchConfig()
        if config then
            CloudSystem.ApplyConfig(config)
            CloudSystem.StartAutoSync()
            cloudStatusLabel.Text = "✅ Conectado! v" .. ConfigVersion
            cloudStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
        else
            cloudStatusLabel.Text = "⚠️ Usando config local"
            cloudStatusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
        end
    end)
    
    connectBtn.Activated:Connect(function()
        local key = apiInput.Text
        if key:match("^sk%-") then
            CLOUD_CONFIG.API_Key = key
            apiInput.Text = key:sub(1, 8) .. "..."
        end
        
        cloudStatusLabel.Text = "🔄 Conectando..."
        local config = CloudSystem.FetchConfig()
        if config then
            CloudSystem.ApplyConfig(config)
            cloudStatusLabel.Text = "✅ Conectado! v" .. ConfigVersion
            cloudStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
        else
            cloudStatusLabel.Text = "❌ Falha na conexão"
            cloudStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    -- BOTÕES PRINCIPAIS
    local function createBtn(text, color, callback, height)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, height or 45)
        btn.Text = text
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = scrollFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.2)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        btn.Activated:Connect(callback)
        return btn
    end
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Text = "⏳ Aguardando..."
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.BackgroundTransparency = 1
    statusLabel.Parent = scrollFrame
    
    createBtn("🔍 SCAN REMOTES", Color3.fromRGB(0, 150, 255), function()
        statusLabel.Text = "⏳ Scanning..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        local found = ScanForLifeRemotes()
        statusLabel.Text = "✅ " .. found .. " remotes encontrados!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
    end)
    
    createBtn("🔓 GERAR BYPASS AUTO", Color3.fromRGB(150, 0, 255), function()
        statusLabel.Text = "⏳ Gerando bypass..."
        statusLabel.TextColor3 = Color3.fromRGB(150, 0, 255)
        
        task.spawn(function()
            local success = BypassGenerator.GenerateCustomBypass()
            if success then
                bypassStatus.Text = "🔓 Generator: ON (" .. #ActiveBypasses .. ")"
                bypassStatus.TextColor3 = Color3.fromRGB(0, 255, 128)
                statusLabel.Text = "✅ " .. #ActiveBypasses .. " bypasses gerados!"
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
            else
                statusLabel.Text = "❌ Falha ao gerar"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end)
    
    createBtn("🧪 TESTAR BYPASSES", Color3.fromRGB(255, 150, 0), function()
        statusLabel.Text = "⏳ Testando..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        local bypasses = DiscoverAllBypasses()
        statusLabel.Text = "✅ " .. #bypasses .. " bypasses ativos!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
    end)
    
    createBtn("👑 ATIVAR GODMODE", Color3.fromRGB(0, 200, 100), function()
        if #ActiveBypasses == 0 then
            statusLabel.Text = "⏳ Gerando bypass primeiro..."
            BypassGenerator.GenerateCustomBypass()
        end
        
        if #ActiveBypasses > 0 then
            ActivateGodMode()
            statusLabel.Text = "👑 GODMODE ATIVO! (" .. #ActiveBypasses .. " bypasses)"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
        else
            statusLabel.Text = "❌ Nenhum bypass funcionou"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    createBtn("🛡️ EMERGÊNCIA", Color3.fromRGB(255, 100, 100), function()
        EmergencyHeal()
        statusLabel.Text = "🚨 Emergência!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end)
    
    createBtn("⏹️ DESATIVAR", Color3.fromRGB(100, 100, 100), function()
        DeactivateGodMode()
        statusLabel.Text = "⏹️ Desativado"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 60)
    infoLabel.Text = "💡 Se os remotes normais falharem, use 🔓 GERAR BYPASS AUTO\nA IA criará bypasses customizados ou godmode universal!"
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 9
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextWrapped = true
    infoLabel.Parent = scrollFrame
    
    -- BOTÃO FLUTUANTE
    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "FloatButton"
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
    
    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.fromRGB(255, 255, 255)
    floatStroke.Thickness = 3
    floatStroke.Parent = floatBtn
    
    task.spawn(function()
        while true do
            if floatBtn.Visible then
                TweenService:Create(floatBtn, TweenInfo.new(0.5), {Size = UDim2.new(0, 65, 0, 65)}):Play()
                task.wait(0.5)
                TweenService:Create(floatBtn, TweenInfo.new(0.5), {Size = UDim2.new(0, 60, 0, 60)}):Play()
                task.wait(0.5)
            else
                task.wait(1)
            end
        end
    end)
    
    -- Minimizar/Maximizar
    local function Minimize()
        IsMinimized = true
        closeBtn.Text = "+"
        closeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Position = UDim2.new(0, -340, 0.5, -240)}):Play()
        task.wait(0.3)
        mainFrame.Visible = false
        floatBtn.Visible = true
        
        floatBtn.Position = UDim2.new(0, -80, 0.3, 0)
        TweenService:Create(floatBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(0, 20, 0.3, 0)}):Play()
    end
    
    local function Maximize()
        IsMinimized = false
        closeBtn.Text = "−"
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        floatBtn.Visible = false
        mainFrame.Visible = true
        
        mainFrame.Position = UDim2.new(0, -340, 0.5, -240)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(0, 20, 0.5, -240)}):Play()
    end
    
    closeBtn.Activated:Connect(function()
        if IsMinimized then Maximize() else Minimize() end
    end)
    floatBtn.Activated:Connect(Maximize)
    
    -- Dragging
    local dragging, dragStart, startPos = false, nil, nil
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = floatBtn.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    local mainDragging, mainDragStart, mainStartPos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            mainDragging = true
            mainDragStart = input.Position
            mainStartPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if mainDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - mainDragStart
            mainFrame.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            mainDragging = false
        end
    end)
    
    return sg
end

-- ════════════════════════════════════════════════════════════════
--  SCANNER E BYPASS (COM GERAÇÃO)
-- ════════════════════════════════════════════════════════════════
local LIFE_KEYWORDS = {
    {kw = {"health", "heal", "life", "hp", "hitpoints", "vitality"}, type = "HEAL", weight = 10},
    {kw = {"sethealth", "changehealth", "updatehealth"}, type = "SET_HEALTH", weight = 9},
    {kw = {"maxhealth", "setmaxhealth", "maxhp"}, type = "MAX_HEALTH", weight = 8},
    {kw = {"regen", "regenerate", "recovery"}, type = "REGEN", weight = 7},
    {kw = {"damage", "hurt", "hit", "attack", "dmg"}, type = "DAMAGE", weight = 10},
    {kw = {"takedamage", "applydamage"}, type = "TAKE_DAMAGE", weight = 9},
    {kw = {"godmode", "god", "invincible", "immortal", "nohit"}, type = "GODMODE", weight = 10},
    {kw = {"shield", "protect", "armor", "defense"}, type = "SHIELD", weight = 8},
    {kw = {"revive", "respawn", "resurrect", "reborn"}, type = "REVIVE", weight = 9},
    {kw = {"spawn", "character", "char"}, type = "SPAWN", weight = 6},
    {kw = {"adminheal", "modheal", "adminhealth"}, type = "ADMIN_HEAL", weight = 10},
    {kw = {"admindamage", "kill"}, type = "ADMIN_DAMAGE", weight = 10}
}

local function AnalyzeRemote(obj)
    if not obj or not (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then return nil end
    
    local blacklist = {"devtools", "coregui", "kick", "ban", "log", "audit", "report"}
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
            Score = score,
            Path = obj:GetFullName(),
            IsFunction = obj:IsA("RemoteFunction")
        }
    end
    return nil
end

function ScanForLifeRemotes()
    Log("🔍 Iniciando scan profundo...", "INFO")
    local found = 0
    
    local function ScanContainer(container, location)
        for _, obj in ipairs(container:GetDescendants()) do
            local analysis = AnalyzeRemote(obj)
            if analysis then
                found = found + 1
                Log("Encontrado: " .. analysis.Name .. " [" .. analysis.Type .. "]", "SUCCESS")
                
                if analysis.Type == "HEAL" or analysis.Type == "REGEN" or analysis.Type == "ADMIN_HEAL" then
                    table.insert(DiscoveredRemotes.Heal, analysis)
                elseif analysis.Type == "SET_HEALTH" then
                    table.insert(DiscoveredRemotes.SetHealth, analysis)
                elseif analysis.Type == "MAX_HEALTH" then
                    table.insert(DiscoveredRemotes.MaxHealth, analysis)
                elseif analysis.Type == "GODMODE" then
                    table.insert(DiscoveredRemotes.GodMode, analysis)
                elseif analysis.Type == "DAMAGE" or analysis.Type == "TAKE_DAMAGE" then
                    table.insert(DiscoveredRemotes.Damage, analysis)
                elseif analysis.Type == "REVIVE" then
                    table.insert(DiscoveredRemotes.Revive, analysis)
                elseif analysis.Type == "SHIELD" then
                    table.insert(DiscoveredRemotes.Shield, analysis)
                end
            end
        end
    end
    
    pcall(function() ScanContainer(ReplicatedStorage, "ReplicatedStorage") end)
    pcall(function() ScanContainer(workspace, "Workspace") end)
    pcall(function() ScanContainer(lp:WaitForChild("PlayerGui"), "PlayerGui") end)
    
    Log("✅ Scan completo! " .. found .. " remotes encontrados", "SUCCESS")
    return found
end

local function TestRemoteBypass(remoteData)
    local obj = remoteData.Object
    local testResults = {}
    
    local predictedArgs = AI_System.PredictBestArgs(remoteData)
    
    if predictedArgs then
        local success = pcall(function()
            if remoteData.IsFunction then
                obj:InvokeServer(unpack(predictedArgs))
            else
                obj:FireServer(unpack(predictedArgs))
            end
        end)
        table.insert(testResults, {args = predictedArgs, success = success, score = 10, source = "AI_PREDICTION"})
        if success then
            Log("🤖 IA acertou: " .. remoteData.Name, "AI")
            AI_System.AnalyzeRemotePattern(remoteData, testResults)
            return {remote = remoteData, method = "AI_Predicted", args = predictedArgs, working = true}
        end
    end
    
    local allArgs = BypassGenerator.GuessArgs(remoteData)
    
    for i, args in ipairs(allArgs) do
        if i > 5 then break end
        
        local success = pcall(function()
            if remoteData.IsFunction then
                return obj:InvokeServer(unpack(args))
            else
                obj:FireServer(unpack(args))
                return true
            end
        end)
        
        table.insert(testResults, {args = args, success = success, score = 5, name = "Guess_" .. i})
        if success then
            AI_System.AnalyzeRemotePattern(remoteData, testResults)
            return {remote = remoteData, method = "AI_Guess_" .. i, args = args, working = true}
        end
        
        task.wait(0.05)
    end
    
    return nil
end

function DiscoverAllBypasses()
    Log("🧪 Testando bypasses...", "INFO")
    ActiveBypasses = {}
    
    local allRemotes = {}
    for _, r in ipairs(DiscoveredRemotes.Heal) do table.insert(allRemotes, r) end
    for _, r in ipairs(DiscoveredRemotes.SetHealth) do table.insert(allRemotes, r) end
    for _, r in ipairs(DiscoveredRemotes.MaxHealth) do table.insert(allRemotes, r) end
    for _, r in ipairs(DiscoveredRemotes.GodMode) do table.insert(allRemotes, r) end
    
    for _, remoteData in ipairs(allRemotes) do
        local bypass = TestRemoteBypass(remoteData)
        if bypass then
            table.insert(ActiveBypasses, bypass)
            Log("✅ Bypass: " .. remoteData.Name, "SUCCESS")
        end
        task.wait(0.1)
    end
    
    if #ActiveBypasses == 0 and CLOUD_CONFIG.AutoBypassGenerator then
        Log("⚠️ Nenhum bypass padrão funcionou! Tentando geração automática...", "WARNING")
        BypassGenerator.GenerateCustomBypass()
    end
    
    Log("✅ " .. #ActiveBypasses .. " bypasses ativos!", "SUCCESS")
    return ActiveBypasses
end

-- ════════════════════════════════════════════════════════════════
--  GODMODE SYSTEM (COM BYPASS UNIVERSAL)
-- ════════════════════════════════════════════════════════════════
function ActivateGodMode()
    if GodModeActive then return end
    GodModeActive = true
    
    Log("👑 GODMODE ATIVADO! v" .. ConfigVersion, "SUCCESS")
    
    local char = lp.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            local lastHealth = hum.Health
            local lastCheck = tick()
            
            hum.HealthChanged:Connect(function(newHealth)
                local timeDiff = tick() - lastCheck
                local healthDiff = lastHealth - newHealth
                
                if healthDiff > 30 and timeDiff < 0.1 then
                    Log("⚠️ Dano massivo!", "WARNING")
                    EmergencyHeal()
                end
                
                if newHealth <= LOCAL_CONFIG.CriticalThreshold then
                    EmergencyHeal()
                end
                
                lastHealth = newHealth
                lastCheck = tick()
            end)
        end
    end
    
    HealLoopRunning = true
    task.spawn(function()
        while HealLoopRunning and LOCAL_CONFIG.GodModeEnabled do
            local char = lp.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    if hum.Health <= LOCAL_CONFIG.HealthThreshold then
                        EmergencyHeal()
                    elseif hum.Health < LOCAL_CONFIG.MaxHealth then
                        for _, bypass in ipairs(ActiveBypasses) do
                            pcall(function()
                                if bypass.universal then
                                    hum.Health = LOCAL_CONFIG.MaxHealth
                                elseif bypass.remote and bypass.remote.Object then
                                    if bypass.remote.IsFunction then
                                        bypass.remote.Object:InvokeServer(unpack(bypass.args))
                                    else
                                        bypass.remote.Object:FireServer(unpack(bypass.args))
                                    end
                                end
                            end)
                        end
                    end
                end
            end
            task.wait(LOCAL_CONFIG.HealSpamInterval)
        end
    end)
    
    task.spawn(function()
        while GodModeActive do
            pcall(function()
                local char = lp.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum and hum.Health < LOCAL_CONFIG.MaxHealth then
                        hum.Health = LOCAL_CONFIG.MaxHealth
                    end
                end
            end)
            task.wait(0.03)
        end
    end)
    
    task.spawn(function()
        while GodModeActive do
            local char = lp.Character
            if not char or not char.Parent then
                Log("💀 Morte! Revivendo...", "ERROR")
                for i = 1, 10 do
                    for _, bypass in ipairs(ActiveBypasses) do
                        pcall(function()
                            if bypass.remote and bypass.remote.Type == "REVIVE" then
                                if bypass.remote.IsFunction then
                                    bypass.remote.Object:InvokeServer(unpack(bypass.args))
                                else
                                    bypass.remote.Object:FireServer(unpack(bypass.args))
                                end
                            end
                        end)
                    end
                    task.wait(0.01)
                end
                
                task.wait(0.5)
                char = lp.CharacterAdded:Wait()
                task.wait(0.5)
                
                if LOCAL_CONFIG.MetaMethodHook then
                    BypassGenerator.HookMetaMethods()
                end
                
                Log("✅ Revivido!", "SUCCESS")
            end
            task.wait(0.1)
        end
    end)
end

function DeactivateGodMode()
    GodModeActive = false
    HealLoopRunning = false
    Log("⏹️ Godmode desativado", "INFO")
end

-- ════════════════════════════════════════════════════════════════
--  INICIALIZAÇÃO
-- ════════════════════════════════════════════════════════════════
local function Initialize()
    Log("🚀 Immortal Engine v3.5 iniciando...", "SUCCESS")
    Log("☁️ URL: " .. CLOUD_CONFIG.ConfigURL:sub(1, 40) .. "...", "CLOUD")
    Log("🔓 Auto-Bypass Generator: " .. (CLOUD_CONFIG.AutoBypassGenerator and "ON" or "OFF"), "BYPASS")
    
    CreateAdvancedGUI()
    
    task.delay(2, function()
        ScanForLifeRemotes()
    end)
    
    Log("✅ Pronto! Use 🔓 GERAR BYPASS AUTO se os normais falharem", "SUCCESS")
end

Initialize()

_G.ImmortalEngine = {
    Scan = ScanForLifeRemotes,
    Test = DiscoverAllBypasses,
    Activate = ActivateGodMode,
    Deactivate = DeactivateGodMode,
    Emergency = EmergencyHeal,
    GenerateBypass = BypassGenerator.GenerateCustomBypass,
    Config = LOCAL_CONFIG,
    Cloud = CLOUD_CONFIG,
    AI = AI_System,
    BypassGen = BypassGenerator,
    CloudSystem = CloudSystem,
    GetBypasses = function() return ActiveBypasses end,
    GetRemotes = function() return DiscoveredRemotes end,
    GetMemory = function() return AI_Memory end,
    GetLogs = function() return Logs end
}
