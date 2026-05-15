-- SCANNER AUTO - Carrega e copia automaticamente
-- Ícone de download no topo da tela, copia sozinho quando terminar

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Config
local CONFIG = {
    MAX_DEPTH = 12,
    YIELD_EVERY = 30,
    YIELD_TIME = 0.02
}

-- Criar GUI minimalista no topo
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoScanner"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Container no topo central
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 300, 0, 60)
Container.Position = UDim2.new(0.5, -150, 0, 10)
Container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Container.BackgroundTransparency = 0.2
Container.BorderSizePixel = 0
Container.Parent = ScreenGui

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 12)
ContainerCorner.Parent = Container

-- Ícone de download/carregamento (círculo animado)
local LoaderIcon = Instance.new("Frame")
LoaderIcon.Size = UDim2.new(0, 32, 0, 32)
LoaderIcon.Position = UDim2.new(0, 15, 0.5, -16)
LoaderIcon.BackgroundTransparency = 1
LoaderIcon.Parent = Container

-- Círculo de fundo
local CircleBg = Instance.new("Frame")
CircleBg.Size = UDim2.new(1, 0, 1, 0)
CircleBg.BackgroundTransparency = 1
CircleBg.Parent = LoaderIcon

local CircleBgUI = Instance.new("UICorner")
CircleBgUI.CornerRadius = UDim.new(1, 0)
CircleBgUI.Parent = CircleBg

local CircleBgStroke = Instance.new("UIStroke")
CircleBgStroke.Color = Color3.fromRGB(60, 60, 70)
CircleBgStroke.Thickness = 3
CircleBgStroke.Parent = CircleBg

-- Círculo de progresso (parte colorida)
local CircleProgress = Instance.new("Frame")
CircleProgress.Size = UDim2.new(1, 0, 1, 0)
CircleProgress.BackgroundTransparency = 1
CircleProgress.Parent = LoaderIcon

local CircleProgressUI = Instance.new("UICorner")
CircleProgressUI.CornerRadius = UDim.new(1, 0)
CircleProgressUI.Parent = CircleProgress

local CircleProgressStroke = Instance.new("UIStroke")
CircleProgressStroke.Color = Color3.fromRGB(0, 200, 255)
CircleProgressStroke.Thickness = 3
CircleProgressStroke.Parent = CircleProgress

-- Texto de status
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -60, 0, 20)
StatusText.Position = UDim2.new(0, 55, 0, 8)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Iniciando escaneamento..."
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextSize = 14
StatusText.Font = Enum.Font.GothamBold
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = Container

-- Texto de detalhes
local DetailText = Instance.new("TextLabel")
DetailText.Size = UDim2.new(1, -60, 0, 16)
DetailText.Position = UDim2.new(0, 55, 0, 32)
DetailText.BackgroundTransparency = 1
DetailText.Text = "Objetos: 0 | Remotes: 0 | Scripts: 0"
DetailText.TextColor3 = Color3.fromRGB(150, 150, 150)
DetailText.TextSize = 11
DetailText.Font = Enum.Font.Gotham
DetailText.TextXAlignment = Enum.TextXAlignment.Left
DetailText.Parent = Container

-- Botão de fechar (X pequeno)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Container

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Animação do loader
local rotation = 0
local isComplete = false

local function animateLoader()
    while not isComplete and ScreenGui.Parent do
        rotation = rotation + 15
        CircleProgress.Rotation = rotation
        task.wait(0.05)
    end
    
    -- Animação de completo
    if ScreenGui.Parent then
        CircleProgressStroke.Color = Color3.fromRGB(0, 255, 100)
        CircleBgStroke.Color = Color3.fromRGB(0, 255, 100)
        
        -- Pulsar
        for i = 1, 3 do
            CircleProgress.Size = UDim2.new(1.2, 0, 1.2, 0)
            CircleProgress.Position = UDim2.new(-0.1, 0, -0.1, 0)
            task.wait(0.15)
            CircleProgress.Size = UDim2.new(1, 0, 1, 0)
            CircleProgress.Position = UDim2.new(0, 0, 0, 0)
            task.wait(0.15)
        end
    end
end

task.spawn(animateLoader)

-- ============ VARIÁVEIS ============
local scannedData = {
    instances = {},
    remotes = {},
    scripts = {},
    memory = {},
    registry = {}
}

local stats = { objects = 0, remotes = 0, scripts = 0, memory = 0, registry = 0 }
local isCancelled = false

-- ============ FUNÇÕES ============
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if success then return result end
    return nil
end

local function escapeString(str)
    if type(str) ~= "string" then return tostring(str) end
    return str:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\t", "\\t")
end

local function updateDisplay()
    DetailText.Text = string.format("Objetos: %d | Remotes: %d | Scripts: %d | Memória: %d",
        stats.objects, stats.remotes, stats.scripts, stats.memory)
end

-- ============ ESCANEAMENTO ============
local function scanAll()
    -- 1. MEMÓRIA
    StatusText.Text = "Escaneando memória..."
    local gc = safeCall(getgc)
    if gc then
        for i, obj in ipairs(gc) do
            if isCancelled then return end
            
            local objType = typeof(obj)
            local info = { type = objType }
            
            if objType == "function" then
                local infoFunc = debug.getinfo(obj)
                if infoFunc then
                    info.name = infoFunc.name or "anonymous"
                    info.source = infoFunc.source and infoFunc.source:sub(1, 150) or "unknown"
                    info.numupvalues = infoFunc.nups or 0
                    
                    local upvalues = {}
                    for j = 1, math.min(info.numupvalues, 20) do
                        local name, value = debug.getupvalue(obj, j)
                        if name then
                            upvalues[name] = tostring(value):sub(1, 80)
                        end
                    end
                    info.upvalues = upvalues
                end
            elseif objType == "table" then
                local keyCount = 0
                for _ in pairs(obj) do
                    keyCount = keyCount + 1
                    if keyCount > 1000 then break end
                end
                info.keyCount = keyCount
            end
            
            table.insert(scannedData.memory, info)
            stats.memory = stats.memory + 1
            
            if i % CONFIG.YIELD_EVERY == 0 then
                updateDisplay()
                task.wait(CONFIG.YIELD_TIME)
            end
        end
    end
    
    -- 2. REGISTRY
    StatusText.Text = "Escaneando registry..."
    local registry = safeCall(getreg)
    if registry then
        local count = 0
        for k, v in pairs(registry) do
            if isCancelled then return end
            
            table.insert(scannedData.registry, {
                key = tostring(k):sub(1, 80),
                value = tostring(v):sub(1, 150)
            })
            stats.registry = stats.registry + 1
            count = count + 1
            
            if count % CONFIG.YIELD_EVERY == 0 then
                updateDisplay()
                task.wait(CONFIG.YIELD_TIME)
            end
        end
    end
    
    -- 3. INSTÂNCIAS
    StatusText.Text = "Escaneando objetos..."
    local scanQueue = {}
    local queueIndex = 1
    
    local services = {
        game:GetService("Workspace"),
        game:GetService("Players"),
        game:GetService("Lighting"),
        game:GetService("ReplicatedStorage"),
        game:GetService("StarterGui"),
        game:GetService("StarterPack"),
        game:GetService("StarterPlayer"),
        game:GetService("Teams"),
        game:GetService("SoundService"),
        game:GetService("Chat"),
        game:GetService("TextChatService")
    }
    
    for _, svc in ipairs(services) do
        table.insert(scanQueue, { instance = svc, depth = 0, path = svc.Name })
    end
    
    while queueIndex <= #scanQueue do
        if isCancelled then return end
        
        local item = scanQueue[queueIndex]
        queueIndex = queueIndex + 1
        
        if not item or not item.instance then continue end
        if item.depth > CONFIG.MAX_DEPTH then continue end
        
        local instance = item.instance
        local depth = item.depth
        local path = item.path
        
        stats.objects = stats.objects + 1
        local currentPath = path .. "/" .. instance.Name
        
        local info = {
            name = instance.Name,
            class = instance.ClassName,
            path = currentPath,
            depth = depth
        }
        
        -- Propriedades
        local props = {}
        local propList = {"Name", "ClassName", "Position", "Size", "Transparency", 
                         "Visible", "CanCollide", "Anchored", "Color", "Material",
                         "Health", "MaxHealth", "WalkSpeed", "JumpPower",
                         "Source", "Disabled", "Value", "Text", "Image"}
        for _, prop in ipairs(propList) do
            local ok, val = pcall(function() return instance[prop] end)
            if ok and val ~= nil then
                props[prop] = tostring(val):sub(1, 100)
            end
        end
        info.properties = props
        
        -- Remote
        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") or 
           instance:IsA("UnreliableRemoteEvent") then
            stats.remotes = stats.remotes + 1
            table.insert(scannedData.remotes, {
                name = instance.Name,
                class = instance.ClassName,
                path = currentPath,
                fullName = instance:GetFullName()
            })
        end
        
        -- Script
        if instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
            stats.scripts = stats.scripts + 1
            local scriptInfo = {
                name = instance.Name,
                class = instance.ClassName,
                path = currentPath,
                fullName = instance:GetFullName()
            }
            
            local ok, source = pcall(function() return instance.Source end)
            if ok and source then
                scriptInfo.sourceLength = #source
                scriptInfo.sourcePreview = source:sub(1, 300)
            end
            
            table.insert(scannedData.scripts, scriptInfo)
        end
        
        table.insert(scannedData.instances, info)
        
        -- Filhos
        local children = safeCall(instance.GetChildren, instance) or {}
        for _, child in ipairs(children) do
            table.insert(scanQueue, { instance = child, depth = depth + 1, path = currentPath })
        end
        
        if stats.objects % CONFIG.YIELD_EVERY == 0 then
            updateDisplay()
            task.wait(CONFIG.YIELD_TIME)
        end
    end
end

-- ============ FORMATAÇÃO E CÓPIA ============
local function formatReport()
    local lines = {}
    
    table.insert(lines, "═══════════════════════════════════════════════════════════")
    table.insert(lines, "           RELATÓRIO DE AUDITORIA - SCANNER AUTO")
    table.insert(lines, "═══════════════════════════════════════════════════════════")
    table.insert(lines, "Data: " .. os.date("%d/%m/%Y %H:%M:%S"))
    table.insert(lines, "Game ID: " .. tostring(game.PlaceId))
    table.insert(lines, "Game Name: " .. tostring(game.Name))
    table.insert(lines, "═══════════════════════════════════════════════════════════\n")
    
    table.insert(lines, "📊 ESTATÍSTICAS:")
    table.insert(lines, "  • Objetos: " .. stats.objects)
    table.insert(lines, "  • Remotes: " .. stats.remotes)
    table.insert(lines, "  • Scripts: " .. stats.scripts)
    table.insert(lines, "  • Memória: " .. stats.memory)
    table.insert(lines, "  • Registry: " .. stats.registry)
    table.insert(lines, "")
    
    table.insert(lines, "📡 REMOTES (" .. #scannedData.remotes .. "):")
    table.insert(lines, "───────────────────────────────────────────────────────────")
    for _, r in ipairs(scannedData.remotes) do
        table.insert(lines, "  [" .. r.class .. "] " .. r.name)
        table.insert(lines, "      Path: " .. r.path)
        table.insert(lines, "")
    end
    
    table.insert(lines, "📜 SCRIPTS (" .. #scannedData.scripts .. "):")
    table.insert(lines, "───────────────────────────────────────────────────────────")
    for _, s in ipairs(scannedData.scripts) do
        table.insert(lines, "  [" .. s.class .. "] " .. s.name)
        table.insert(lines, "      Path: " .. s.path)
        if s.sourceLength then
            table.insert(lines, "      Source: " .. s.sourceLength .. " chars")
        end
        table.insert(lines, "")
    end
    
    table.insert(lines, "💾 FUNÇÕES EM MEMÓRIA (primeiras 50):")
    table.insert(lines, "───────────────────────────────────────────────────────────")
    local funcCount = 0
    for _, m in ipairs(scannedData.memory) do
        if m.type == "function" and funcCount < 50 then
            funcCount = funcCount + 1
            table.insert(lines, "  [" .. funcCount .. "] " .. (m.name or "anonymous"))
            table.insert(lines, "      Source: " .. (m.source or "unknown"))
            table.insert(lines, "      Upvalues: " .. (m.numupvalues or 0))
            table.insert(lines, "")
        end
    end
    
    table.insert(lines, "🌳 INSTÂNCIAS (primeiras 200):")
    table.insert(lines, "───────────────────────────────────────────────────────────")
    for i = 1, math.min(#scannedData.instances, 200) do
        local inst = scannedData.instances[i]
        local indent = string.rep("  ", inst.depth)
        table.insert(lines, indent .. "├─ [" .. inst.class .. "] " .. inst.name)
    end
    
    if #scannedData.instances > 200 then
        table.insert(lines, "\n... e mais " .. (#scannedData.instances - 200) .. " objetos")
    end
    
    table.insert(lines, "\n═══════════════════════════════════════════════════════════")
    table.insert(lines, "                    FIM DO RELATÓRIO")
    table.insert(lines, "═══════════════════════════════════════════════════════════")
    
    return table.concat(lines, "\n")
end

local function autoCopy(content)
    local copied = false
    
    -- Tentar setclipboard
    if type(setclipboard) == "function" then
        pcall(function()
            setclipboard(content)
            copied = true
        end)
    end
    
    -- Tentar toclipboard
    if not copied and type(toclipboard) == "function" then
        pcall(function()
            toclipboard(content)
            copied = true
        end)
    end
    
    return copied
end

-- ============ EXECUÇÃO ============
task.spawn(function()
    -- Escanear tudo
    scanAll()
    
    if isCancelled then
        StatusText.Text = "❌ Cancelado"
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    -- Marcar como completo
    isComplete = true
    StatusText.Text = "✅ Completo! Copiando..."
    StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
    
    -- Gerar relatório
    local report = formatReport()
    
    -- Tentar copiar
    local copied = autoCopy(report)
    
    if copied then
        StatusText.Text = "✅ Relatório copiado!"
        DetailText.Text = string.format("%d objetos | %d remotes | %d scripts copiados",
            stats.objects, stats.remotes, stats.scripts)
        
        -- Fade out após 3 segundos
        task.wait(3)
        for i = 1, 20 do
            Container.BackgroundTransparency = 0.2 + (i * 0.04)
            StatusText.TextTransparency = i * 0.05
            DetailText.TextTransparency = i * 0.05
            LoaderIcon.ImageTransparency = i * 0.05
            task.wait(0.05)
        end
        ScreenGui:Destroy()
    else
        StatusText.Text = "⚠️ Clipboard não disponível"
        DetailText.Text = "Dados no console (F9)"
        StatusText.TextColor3 = Color3.fromRGB(255, 200, 0)
        
        -- Imprimir no console em partes
        task.spawn(function()
            local chunkSize = 8000
            for i = 1, #report, chunkSize do
                print(report:sub(i, i + chunkSize - 1))
                task.wait(0.2)
            end
        end)
    end
end)

print("🔍 Auto Scanner iniciado... Aguarde o carregamento completo!")
