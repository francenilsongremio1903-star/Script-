-- Remote Spam V4 - Hosteado no GitHub
-- NÃO COLE ISSO NO DELTA! Isso vai no GitHub!

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- Limpar GUI anterior
pcall(function()
    for _, n in ipairs({"RS4_GUI", "RS4_Notif", "RS4_Modal"}) do
        local o = pg:FindFirstChild(n)
        if o then o:Destroy() end
    end
end)

local Stats = {Fired = 0, Scanned = {}}
local Blacklist = {"devtools", "coregui", "kick", "ban", "remove", "admin", "mod", "anticheat"}

local function IsBlacklisted(n)
    if not n then return true end
    local l = n:lower()
    for _, k in ipairs(Blacklist) do
        if l:find(k, 1, true) then return true end
    end
    return false
end

local function Notify(m, c)
    c = c or Color3.fromRGB(99, 102, 241)
    local s = Instance.new("ScreenGui", pg)
    s.Name = "RS4_Notif"
    s.ResetOnSpawn = false
    s.DisplayOrder = 99999
    
    local f = Instance.new("Frame", s)
    f.Size = UDim2.new(0, 260, 0, 45)
    f.Position = UDim2.new(1, 20, 1, -60)
    f.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", f)
    stroke.Color = c
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.Text = m
    lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.BackgroundTransparency = 1
    
    TweenService:Create(f, TweenInfo.new(0.2), {Position = UDim2.new(1, -270, 1, -60)}):Play()
    task.delay(3, function() s:Destroy() end)
end

-- GUI Principal
local SG = Instance.new("ScreenGui", pg)
SG.Name = "RS4_GUI"
SG.ResetOnSpawn = false

local Win = Instance.new("Frame", SG)
Win.Size = UDim2.new(0, 300, 0, 350)
Win.Position = UDim2.new(0.5, -150, 0.5, -175)
Win.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 12)

-- Topbar
local Top = Instance.new("Frame", Win)
Top.Size = UDim2.new(1, 0, 0, 40)
Top.BackgroundColor3 = Color3.fromRGB(19, 19, 29)
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Top)
Title.Text = "📡 Remote Spam V4"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(99, 102, 241)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botão fechar
local X = Instance.new("TextButton", Top)
X.Size = UDim2.new(0, 30, 0, 30)
X.Position = UDim2.new(1, -35, 0, 5)
X.Text = "✕"
X.TextColor3 = Color3.fromRGB(255, 255, 255)
X.Font = Enum.Font.GothamBold
X.BackgroundColor3 = Color3.fromRGB(220, 55, 55)
Instance.new("UICorner", X).CornerRadius = UDim.new(0, 8)

-- Scroll
local Scroll = Instance.new("ScrollingFrame", Win)
Scroll.Size = UDim2.new(1, -20, 1, -90)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8)

-- Função criar botão
local function Btn(txt, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    b.TextColor3 = Color3.fromRGB(235, 235, 245)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.Activated:Connect(callback)
    return b
end

-- BOTÕES
Btn("🚀 SPAM TUDO", function()
    local c = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            c = c + 1
            for _, o in ipairs(p.Character:GetDescendants()) do
                if o:IsA("RemoteEvent") and not IsBlacklisted(o.Name) then
                    pcall(function() o:FireServer() end)
                    Stats.Fired = Stats.Fired + 1
                end
            end
        end
    end
    Notify("🚀 Spam: " .. c .. " players")
end)

Btn("🔍 ESCANEAR REMOTES", function()
    Stats.Scanned = {}
    local function Scan(parent)
        for _, o in ipairs(parent:GetDescendants()) do
            if (o:IsA("RemoteEvent") or o:IsA("RemoteFunction")) and not IsBlacklisted(o.Name) then
                table.insert(Stats.Scanned, {
                    Name = o.Name,
                    Obj = o,
                    Type = o:IsA("RemoteFunction") and "RF" or "RE"
                })
            end
        end
    end
    
    pcall(function() Scan(ReplicatedStorage) end)
    pcall(function() Scan(workspace) end)
    pcall(function() Scan(lp.PlayerGui) end)
    
    Notify("🔍 " .. #Stats.Scanned .. " remotes!")
    
    -- Lista simples
    for i, r in ipairs(Stats.Scanned) do
        print(i .. ". " .. r.Type .. ": " .. r.Name)
    end
end)

Btn("📊 RELATÓRIO", function()
    if #Stats.Scanned == 0 then
        Notify("⚠️ Escaneie primeiro!")
        return
    end
    
    local report = {"-- Remote Spam Report\n"}
    for _, r in ipairs(Stats.Scanned) do
        table.insert(report, r.Type .. ": " .. r.Name)
    end
    local text = table.concat(report, "\n")
    pcall(function() setclipboard(text) end)
    Notify("📋 Copiado!")
end)

-- Botão flutuante
local FB = Instance.new("TextButton", SG)
FB.Size = UDim2.new(0, 50, 0, 50)
FB.Position = UDim2.new(0, 20, 0.7, 0)
FB.Text = "📡"
FB.TextSize = 24
FB.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
FB.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", FB).CornerRadius = UDim.new(1, 0)

FB.Activated:Connect(function()
    Win.Visible = not Win.Visible
end)

X.Activated:Connect(function()
    Win.Visible = false
end)

-- Drag simples
local dragging, dragInput, dragStart, startPos

Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Win.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

Notify("✅ Script carregado do GitHub!")
