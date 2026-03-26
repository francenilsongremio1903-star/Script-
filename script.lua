-- ════════════════════════════════════════════════════════════════
--  REMOTE SPAM V5.2 — UNLIMITED SCROLL
--  Todos os remotes visíveis · Rolagem infinita · Mobile otimizado
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- Limpar GUIs antigas
for _, n in ipairs({"RS5_GUI", "RS5_Modal", "RS5_Report", "RS5_Mobile", "RemoteSpam"}) do
    pcall(function() pg[n]:Destroy() end)
end

-- Config
local Settings = {SafeMode = true, Delay = 0.02}
local Stats = {Fired = 0, Blocked = 0}
local AllRemotesCache = {}
local RemoteButtons = {}

-- Blacklist simples
local Blacklist = {"kick", "ban", "devtools", "coregui", "internal", "spy", "detect", "audit"}
local function IsBlacklisted(name)
    local low = tostring(name):lower()
    for _, w in ipairs(Blacklist) do if low:find(w) then return true end end
    return false
end

-- Fire seguro
local function SafeFire(remote)
    if not remote or not remote.Parent then return end
    if IsBlacklisted(remote.Name) then Stats.Blocked = Stats.Blocked + 1 return end
    
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer()
            remote:FireServer(lp)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer()
        end
        Stats.Fired = Stats.Fired + 1
    end)
end

-- Scanner profundo
local function ScanAllRemotes()
    local found = {}
    local seen = {}
    
    local function Add(obj)
        if seen[obj] then return end
        seen[obj] = true
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if not IsBlacklisted(obj.Name) then
                table.insert(found, {
                    Name = obj.Name,
                    Path = obj:GetFullName(),
                    Type = obj:IsA("RemoteFunction") and "⚙️" or "📡",
                    Remote = obj
                })
            end
        end
    end
    
    -- TODOS os serviços possíveis
    local services = {
        "ReplicatedStorage", "Workspace", "Players", "Chat", "Teams",
        "StarterGui", "StarterPack", "StarterPlayer", "SoundService",
        "Lighting", "ReplicatedFirst", "MaterialService", "LocalizationService",
        "HttpService", "RunService", "TweenService", "CoreGui"
    }
    
    for _, svcName in ipairs(services) do
        pcall(function()
            local svc = game:GetService(svcName)
            for _, d in ipairs(svc:GetDescendants()) do Add(d) end
        end)
    end
    
    -- PlayerGui e Character
    pcall(function() 
        for _, d in ipairs(lp:WaitForChild("PlayerGui"):GetDescendants()) do Add(d) end 
    end)
    pcall(function() 
        if lp.Character then 
            for _, d in ipairs(lp.Character:GetDescendants()) do Add(d) end 
        end 
    end)
    
    -- Ordena
    table.sort(found, function(a, b) return a.Name < b.Name end)
    AllRemotesCache = found
    return found
end

-- Gerar relatório completo
local function GenerateReport()
    if #AllRemotesCache == 0 then return "-- Escaneie primeiro!" end
    
    local lines = {}
    lines[#lines+1] = "-- REMOTE REPORT - " .. game.Name .. " (" .. #AllRemotesCache .. " remotes)"
    lines[#lines+1] = ""
    
    for _, item in ipairs(AllRemotesCache) do
        lines[#lines+1] = "-- " .. item.Type .. " " .. item.Name
        lines[#lines+1] = 'local r=game:FindFirstChild("' .. item.Name .. '",true)'
        lines[#lines+1] = "if r then pcall(function()r:" .. (item.Type == "⚙️" and "InvokeServer()" or "FireServer(game.Players.LocalPlayer)") .. ")end)end"
        lines[#lines+1] = ""
    end
    return table.concat(lines, "\n")
end

-- GUI Principal
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "RS5_Unlimited"
MainGui.ResetOnSpawn = false
MainGui.Parent = pg

-- Janela
local Win = Instance.new("Frame")
Win.Size = UDim2.new(0, 300, 0, 400) -- Um pouco maior pra caber mais
Win.Position = UDim2.new(0.5, -150, 0.5, -200)
Win.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Win.BorderSizePixel = 0
Win.Parent = MainGui
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 12)

-- TopBar
local Top = Instance.new("Frame", Win)
Top.Size = UDim2.new(1, 0, 0, 45)
Top.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 Remote V5.2 Unlimited"
Title.TextColor3 = Color3.fromRGB(99, 102, 241)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local X = Instance.new("TextButton", Top)
X.Size = UDim2.new(0, 35, 0, 35)
X.Position = UDim2.new(1, -40, 0.5, -17)
X.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
X.Text = "✕"
X.TextColor3 = Color3.new(1, 1, 1)
X.Font = Enum.Font.GothamBold
Instance.new("UICorner", X).CornerRadius = UDim.new(0, 8)
X.Activated:Connect(function() Win.Visible = false end)

-- Container de botões fixos (topo)
local FixedFrame = Instance.new("Frame", Win)
FixedFrame.Size = UDim2.new(1, -10, 0, 140)
FixedFrame.Position = UDim2.new(0, 5, 0, 50)
FixedFrame.BackgroundTransparency = 1

local FixedLayout = Instance.new("UIListLayout", FixedFrame)
FixedLayout.Padding = UDim.new(0, 5)

-- ScrollingFrame para lista de remotes (ROLAGEM INFINITA)
local Scroll = Instance.new("ScrollingFrame", Win)
Scroll.Size = UDim2.new(1, -10, 1, -200) -- Espaço restante
Scroll.Position = UDim2.new(0, 5, 0, 195)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- Começa em 0, cresce dinamicamente
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 8)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 4)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Atualiza CanvasSize automaticamente quando adicionar itens
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- Função criar botão
local function MakeBtn(parent, text, color, height, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, height or 35)
    b.BackgroundColor3 = color or Color3.fromRGB(40, 40, 60)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    if callback then b.Activated:Connect(callback) end
    return b
end

-- Limpa lista anterior
local function ClearList()
    for _, btn in ipairs(RemoteButtons) do
        if btn and btn.Parent then btn:Destroy() end
    end
    RemoteButtons = {}
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- BOTÕES FIXOS (topo)
MakeBtn(FixedFrame, "🔍 ESCANEAR TODOS OS REMOTES", Color3.fromRGB(99, 102, 241), 40, function()
    ClearList()
    
    local loading = MakeBtn(Scroll, "⏳ Escaneando... Aguarde", Color3.fromRGB(60, 60, 80), 30)
    table.insert(RemoteButtons, loading)
    
    task.spawn(function()
        local items = ScanAllRemotes()
        loading:Destroy()
        
        -- Mostra contador no topo
        local countBtn = MakeBtn(Scroll, "📊 TOTAL: " .. #items .. " REMOTES ENCONTRADOS", Color3.fromRGB(50, 150, 50), 30)
        table.insert(RemoteButtons, countBtn)
        
        -- Cria TODOS os botões (sem limite!)
        -- Usa task.defer pra não travar a UI
        for i, item in ipairs(items) do
            task.defer(function()
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 32)
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                btn.Text = item.Type .. " " .. item.Name
                btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = Scroll
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                
                -- Padding visual
                local padding = Instance.new("UIPadding", btn)
                padding.PaddingLeft = UDim.new(0, 10)
                
                -- Click
                btn.Activated:Connect(function()
                    btn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
                    SafeFire(item.Remote)
                    task.wait(0.15)
                    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                end)
                
                table.insert(RemoteButtons, btn)
            end)
            
            -- Pequeno delay a cada 50 pra não crashar em listas enormes
            if i % 50 == 0 then
                task.wait(0.05)
            end
        end
    end)
end)

MakeBtn(FixedFrame, "📋 COPIAR RELATÓRIO COMPLETO", Color3.fromRGB(251, 191, 36), 35, function()
    if #AllRemotesCache == 0 then
        MakeBtn(Scroll, "⚠️ Escaneie primeiro!", Color3.fromRGB(200, 100, 50), 30)
        return
    end
    pcall(function()
        setclipboard(GenerateReport())
        local ok = MakeBtn(Scroll, "✅ " .. #AllRemotesCache .. " remotes copiados!", Color3.fromRGB(50, 200, 50), 30)
        task.delay(2, function() ok:Destroy() end)
    end)
end)

MakeBtn(FixedFrame, "🚀 FIRE ALL (EXECUTAR TODOS)", Color3.fromRGB(220, 55, 55), 35, function()
    task.spawn(function()
        for i, item in ipairs(AllRemotesCache) do
            SafeFire(item.Remote)
            if i % 20 == 0 then task.wait(0.01) end -- Evita lag
        end
    end)
end)

MakeBtn(FixedFrame, "🛡️ Toggle Safe Mode", Color3.fromRGB(60, 60, 80), 30, function()
    Settings.SafeMode = not Settings.SafeMode
end)

-- Botão flutuante
local Float = Instance.new("TextButton", MainGui)
Float.Size = UDim2.new(0, 55, 0, 55)
Float.Position = UDim2.new(0, 15, 0.85, 0)
Float.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
Float.Text = "📡"
Float.TextSize = 26
Float.Font = Enum.Font.GothamBold
Float.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Float).CornerRadius = UDim.new(1, 0)

Float.Activated:Connect(function()
    Win.Visible = not Win.Visible
end)

-- Arrastar
local drag, startPos, startMouse
Top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        startPos = Win.Position
        startMouse = i.Position
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = i.Position - startMouse
        Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function() drag = false end)

print("✅ Unlimited Scroll carregado! Clique em ESCANEAR pra ver todos.")
