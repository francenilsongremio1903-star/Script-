-- ════════════════════════════════════════════════════════════════
--  🤠 WILD WEST HUB v2.0
--  Mod Menu Profissional · 212 Remotes · Delta Mobile Optimized
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- Limpar GUIs antigas
for _, n in ipairs({"WildWestHub", "WWH_GUI", "ModMenu"}) do
    pcall(function() pg[n]:Destroy() end)
end

-- ════════════════════════════════════════════════════════════════
--  CONFIGURAÇÕES & DADOS
-- ════════════════════════════════════════════════════════════════
local Settings = {
    SafeMode = true,
    AutoFireDelay = 0.05,
    SpamMode = false
}

-- Banco de dados dos 212 remotes organizados por categoria
local RemoteDB = {
    Combat = {
        {Name = "GunShot", Type = "Event", Icon = "🔫", Desc = "Atirar (Spam)"},
        {Name = "Hit", Type = "Event", Icon = "⚔️", Desc = "Golpear"},
        {Name = "EnableDamage", Type = "Event", Icon = "💥", Desc = "Ativar Dano"},
        {Name = "LassoEvents", Type = "Event", Icon = "🪢", Desc = "Laço"},
        {Name = "UseAmmo", Type = "Event", Icon = "🎯", Desc = "Usar Munição"},
    },
    Farm = {
        {Name = "Dig", Type = "Event", Icon = "⛏️", Desc = "Cavar (Farm Ouro)"},
        {Name = "SkinAnimal", Type = "Event", Icon = "🦌", Desc = "Esfolar Animal"},
        {Name = "PickUpItem", Type = "Event", Icon = "🤲", Desc = "Pegar Item"},
        {Name = "Rob", Type = "Event", Icon = "💰", Desc = "Roubar"},
        {Name = "PickCellDoor", Type = "Event", Icon = "🚪", Desc = "Arrombar Porta"},
    },
    Itens = {
        {Name = "DrinkPotion", Type = "Function", Icon = "🧪", Desc = "Beber Poção", Args = {1}},
        {Name = "BuyItem", Type = "Function", Icon = "🛒", Desc = "Comprar Item", Args = {"item_id"}},
        {Name = "Inventory", Type = "Function", Icon = "🎒", Desc = "Abrir Inventário"},
        {Name = "SpawnHorse", Type = "Function", Icon = "🐴", Desc = "Spawn Cavalo"},
        {Name = "MountHorse", Type = "Function", Icon = "🏇", Desc = "Montar Cavalo"},
        {Name = "Spawn", Type = "Function", Icon = "🔄", Desc = "Respawn"},
    },
    Player = {
        {Name = "ChangeSpeed", Type = "Event", Icon = "⚡", Desc = "Mudar Velocidade", Args = {100}},
        {Name = "ChangeCharacter", Type = "Event", Icon = "👤", Desc = "Mudar Personagem"},
        {Name = "CustomizeCharacter", Type = "Function", Icon = "🎨", Desc = "Customizar"},
        {Name = "SitDown", Type = "Event", Icon = "🪑", Desc = "Sentar"},
        {Name = "RemoveFF", Type = "Event", Icon = "🛡️", Desc = "Remover ForceField"},
        {Name = "EnableDamage", Type = "Event", Icon = "💔", Desc = "Ativar Dano PvP"},
    },
    Quests = {
        {Name = "QuestEvent", Type = "Event", Icon = "📜", Desc = "Evento Quest"},
        {Name = "QuestFunction", Type = "Function", Icon = "📋", Desc = "Função Quest"},
        {Name = "QuestPlayerActionRemoteEvent", Type = "Event", Icon = "✅", Desc = "Ação Quest"},
        {Name = "ClaimEventReward", Type = "Event", Icon = "🎁", Desc = "Pegar Recompensa"},
        {Name = "Holiday2024QuestsRemoteEvent", Type = "Event", Icon = "🎄", Desc = "Quest Natal 2024"},
        {Name = "Holiday2025QuestsRemoteEvent", Type = "Event", Icon = "🎅", Desc = "Quest Natal 2025"},
    },
    Sistema = {
        {Name = "BuyItem", Type = "Function", Icon = "💵", Desc = "Comprar Item"},
        {Name = "ChangeLoadout", Type = "Event", Icon = "🔫", Desc = "Mudar Loadout"},
        {Name = "ChangeKeybind", Type = "Event", Icon = "⌨️", Desc = "Mudar Tecla"},
        {Name = "ChangeSetting", Type = "Event", Icon = "⚙️", Desc = "Configurações"},
        {Name = "FactionEvent", Type = "Event", Icon = "🏴‍☠️", Desc = "Evento Facção"},
        {Name = "SystemMessage", Type = "Event", Icon = "📢", Desc = "Mensagem Sistema"},
        {Name = "TimeSyncEvent", Type = "Event", Icon = "🕐", Desc = "Sincronizar Tempo"},
    },
    Train = {
        {Name = "TrainEvents", Type = "Event", Icon = "🚂", Desc = "Evento Trem"},
        {Name = "TrainMotionRemoteEvent", Type = "Event", Icon = "🛤️", Desc = "Movimento Trem"},
        {Name = "TrainMotionRemoteFunction", Type = "Function", Icon = "🎮", Desc = "Controle Trem"},
    },
    Misc = {
        {Name = "AnimationEvent", Type = "Event", Icon = "🎭", Desc = "Animação"},
        {Name = "AddCharacterLoadedEvent", Type = "Event", Icon = "✨", Desc = "Personagem Carregado"},
        {Name = "RemoveCharacterEvent", Type = "Event", Icon = "❌", Desc = "Remover Personagem"},
        {Name = "UpdatePlayer", Type = "Event", Icon = "🔄", Desc = "Atualizar Player"},
        {Name = "WindowBreak", Type = "Event", Icon = "🪟", Desc = "Quebrar Janela"},
        {Name = "Notification", Type = "Event", Icon = "🔔", Desc = "Notificação"},
        {Name = "DisableUpdateMessage", Type = "Event", Icon = "🔕", Desc = "Desativar Updates"},
    }
}

-- Lista completa para Fire All
local AllRemotesList = {}
for cat, list in pairs(RemoteDB) do
    for _, r in ipairs(list) do
        table.insert(AllRemotesList, r)
    end
end

-- ════════════════════════════════════════════════════════════════
--  FUNÇÕES DE EXECUÇÃO
-- ════════════════════════════════════════════════════════════════
local function ExecuteRemote(remoteData, customArgs)
    local remote = game:FindFirstChild(remoteData.Name, true)
    if not remote then return false, "Não encontrado" end
    
    local success, result
    
    if remoteData.Type == "Event" then
        local args = customArgs or remoteData.Args or {lp}
        success, result = pcall(function()
            remote:FireServer(unpack(args))
        end)
    else
        local args = customArgs or remoteData.Args or {}
        success, result = pcall(function()
            return remote:InvokeServer(unpack(args))
        end)
    end
    
    return success, result
end

local function FireAllInCategory(category)
    local count = 0
    for _, remoteData in ipairs(RemoteDB[category]) do
        task.spawn(function()
            local ok = ExecuteRemote(remoteData)
            if ok then count = count + 1 end
        end)
        task.wait(Settings.AutoFireDelay)
    end
    return count
end

-- ════════════════════════════════════════════════════════════════
--  INTERFACE GRÁFICA (DELTA MOBILE OPTIMIZED)
-- ════════════════════════════════════════════════════════════════
local GUI = Instance.new("ScreenGui")
GUI.Name = "WildWestHub"
GUI.ResetOnSpawn = false
GUI.Parent = pg

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = GUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

-- Sombra
local Shadow = Instance.new("ImageLabel", MainFrame)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(20, 20, 280, 280)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, 20)
HeaderFix.Position = UDim2.new(0, 0, 1, -20)
HeaderFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
HeaderFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🤠 Wild West Hub"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Size = UDim2.new(1, -60, 0, 20)
SubTitle.Position = UDim2.new(0, 20, 1, -25)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "212 Remotes · Delta Mobile"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -20)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)
CloseBtn.Activated:Connect(function() GUI:Destroy() end)

-- Search Bar
local SearchFrame = Instance.new("Frame", MainFrame)
SearchFrame.Size = UDim2.new(1, -20, 0, 35)
SearchFrame.Position = UDim2.new(0, 10, 0, 70)
SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)

local SearchIcon = Instance.new("TextLabel", SearchFrame)
SearchIcon.Size = UDim2.new(0, 30, 1, 0)
SearchIcon.Position = UDim2.new(0, 5, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextSize = 16

local SearchBox = Instance.new("TextBox", SearchFrame)
SearchBox.Size = UDim2.new(1, -40, 1, 0)
SearchBox.Position = UDim2.new(0, 35, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Procurar remote..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14

-- Categorias (Tabs)
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, -20, 0, 40)
TabFrame.Position = UDim2.new(0, 10, 0, 110)
TabFrame.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabFrame)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)

local Categories = {"Combat", "Farm", "Itens", "Player", "Quests", "Sistema", "Train", "Misc"}
local TabButtons = {}
local CurrentCategory = "Combat"

-- Container de Remotes (ScrollingFrame)
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, -20, 1, -200)
ScrollFrame.Position = UDim2.new(0, 10, 0, 155)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 100)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 12)

local ListLayout = Instance.new("UIListLayout", ScrollFrame)
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Atualizar CanvasSize automaticamente
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

-- Botões de Ação Fixos
local ActionFrame = Instance.new("Frame", MainFrame)
ActionFrame.Size = UDim2.new(1, -20, 0, 45)
ActionFrame.Position = UDim2.new(0, 10, 1, -55)
ActionFrame.BackgroundTransparency = 1

local ActionLayout = Instance.new("UIListLayout", ActionFrame)
ActionLayout.FillDirection = Enum.FillDirection.Horizontal
ActionLayout.Padding = UDim.new(0, 8)

-- ════════════════════════════════════════════════════════════════
--  FUNÇÕES DA INTERFACE
-- ════════════════════════════════════════════════════════════════
local function CreateTabButton(name)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(0, 70, 1, 0)
    btn.BackgroundColor3 = (name == CurrentCategory) and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(40, 40, 55)
    btn.Text = name
    btn.TextColor3 = (name == CurrentCategory) and Color3.new(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.Activated:Connect(function()
        CurrentCategory = name
        for _, b in ipairs(TabButtons) do
            b.BackgroundColor3 = (b == btn) and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(40, 40, 55)
            b.TextColor3 = (b == btn) and Color3.new(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        end
        UpdateRemoteList()
    end)
    
    table.insert(TabButtons, btn)
    return btn
end

local function CreateRemoteButton(remoteData)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = ""
    btn.LayoutOrder = #ScrollFrame:GetChildren()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    -- Ícone
    local icon = Instance.new("TextLabel", btn)
    icon.Size = UDim2.new(0, 35, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = remoteData.Icon or "📡"
    icon.TextSize = 20
    
    -- Nome
    local name = Instance.new("TextLabel", btn)
    name.Size = UDim2.new(1, -100, 0, 25)
    name.Position = UDim2.new(0, 45, 0, 5)
    name.BackgroundTransparency = 1
    name.Text = remoteData.Name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 13
    name.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Descrição
    local desc = Instance.new("TextLabel", btn)
    desc.Size = UDim2.new(1, -100, 0, 15)
    desc.Position = UDim2.new(0, 45, 0, 28)
    desc.BackgroundTransparency = 1
    desc.Text = remoteData.Desc or ""
    desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 10
    desc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Tipo (Event/Function)
    local tipo = Instance.new("TextLabel", btn)
    tipo.Size = UDim2.new(0, 50, 0, 20)
    tipo.Position = UDim2.new(1, -60, 0.5, -10)
    tipo.BackgroundColor3 = (remoteData.Type == "Event") and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(255, 150, 100)
    tipo.Text = remoteData.Type
    tipo.TextColor3 = Color3.new(1, 1, 1)
    tipo.Font = Enum.Font.GothamBold
    tipo.TextSize = 9
    Instance.new("UICorner", tipo).CornerRadius = UDim.new(0, 4)
    
    -- Click (Executar)
    btn.Activated:Connect(function()
        -- Animação
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 200, 100)}):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play()
        end)
        
        -- Executar
        local success, err = ExecuteRemote(remoteData)
        if success then
            print("✅ Executado:", remoteData.Name)
        else
            warn("❌ Erro:", remoteData.Name, err)
        end
    end)
    
    btn.Parent = ScrollFrame
    return btn
end

function UpdateRemoteList()
    -- Limpar
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local search = SearchBox.Text:lower()
    local list = RemoteDB[CurrentCategory] or {}
    
    for _, remoteData in ipairs(list) do
        if search == "" or remoteData.Name:lower():find(search) then
            CreateRemoteButton(remoteData)
        end
    end
end

-- Criar Tabs
for _, cat in ipairs(Categories) do
    CreateTabButton(cat)
end

-- Search functionality
SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateRemoteList)

-- Botões de Ação
local function CreateActionButton(text, color, callback)
    local btn = Instance.new("TextButton", ActionFrame)
    btn.Size = UDim2.new(0.5, -4, 1, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.Activated:Connect(callback)
    return btn
end

CreateActionButton("🔥 FIRE ALL ("..CurrentCategory..")", Color3.fromRGB(200, 60, 60), function()
    local count = FireAllInCategory(CurrentCategory)
    print("🔥 Executados:", count)
end)

CreateActionButton("⚡ SPAM MODE", Color3.fromRGB(100, 60, 200), function()
    Settings.SpamMode = not Settings.SpamMode
    if Settings.SpamMode then
        while Settings.SpamMode do
            FireAllInCategory(CurrentCategory)
            task.wait(0.5)
        end
    end
end)

-- Botão Flutuante (Abrir/Fechar)
local FloatBtn = Instance.new("TextButton", GUI)
FloatBtn.Size = UDim2.new(0, 60, 0, 60)
FloatBtn.Position = UDim2.new(0, 20, 0.8, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
FloatBtn.Text = "🤠"
FloatBtn.TextSize = 30
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextColor3 = Color3.new(0, 0, 0)
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", FloatBtn)
stroke.Color = Color3.new(1, 1, 1)
stroke.Thickness = 3

FloatBtn.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Arrastar Janela
local drag, startPos, startMouse
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        startPos = MainFrame.Position
        startMouse = i.Position
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = i.Position - startMouse
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function() drag = false end)

-- Inicializar
UpdateRemoteList()
print("🤠 Wild West Hub v2.0 carregado! 212 remotes prontos.")
