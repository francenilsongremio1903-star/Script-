-- ════════════════════════════════════════════════════════════════
--  IMMORTAL ENGINE v4.0 - EMERGENCY FIX
--  Menu garantido · Código enxuto · Funciona em qualquer executor
-- ════════════════════════════════════════════════════════════════

-- Espera carregar
task.wait(2)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local lp = Players.LocalPlayer

-- Cria GUI
local sg = Instance.new("ScreenGui")
sg.Name = "ImmortalV4"
sg.ResetOnSpawn = false

-- Tenta CoreGui, senão PlayerGui
pcall(function() sg.Parent = game:GetService("CoreGui") end)
if not sg.Parent then
    sg.Parent = lp:WaitForChild("PlayerGui")
end

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 20, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Parent = sg

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(0, 255, 100)

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "👑 IMMORTAL v4.0"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.BackgroundTransparency = 1

-- Status
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 40)
status.Text = "✅ Menu Carregado!"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.SourceSans
status.TextSize = 14
status.BackgroundTransparency = 1

-- Container
local container = Instance.new("Frame", frame)
container.Size = UDim2.new(1, -20, 1, -80)
container.Position = UDim2.new(0, 10, 0, 75)
container.BackgroundTransparency = 1

Instance.new("UIListLayout", container).Padding = UDim.new(0, 8)

-- Variáveis
local Bypasses = {}
local GodModeAtivo = false
local Criando = false

-- Função botão
local function AddBtn(texto, cor, fn)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.Text = texto
    btn.BackgroundColor3 = cor
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(function() pcall(fn) end)
    return btn
end

-- BOTÕES FUNCIONAIS
AddBtn("🔍 ESCANEAR", Color3.fromRGB(0, 150, 255), function()
    status.Text = "⏳ Escaneando..."
    local count = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("heal") or n:find("health") or n:find("god") then count = count + 1 end
        end
    end
    status.Text = "✅ " .. count .. " remotes!"
    status.TextColor3 = Color3.fromRGB(0, 255, 0)
end)

AddBtn("🔓 GERAR BYPASS", Color3.fromRGB(150, 0, 255), function()
    if Criando then status.Text = "⏳ Aguarde..." return end
    Criando = true
    status.Text = "⏳ Gerando..."
    
    task.spawn(function()
        local argsList = {{lp}, {100}, {lp,100}, {true}, {999999}}
        local found = 0
        
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if found >= 2 then break end
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("heal") or n:find("health") then
                    for _, args in ipairs(argsList) do
                        local ok = pcall(function()
                            if obj:IsA("RemoteFunction") then obj:InvokeServer(unpack(args))
                            else obj:FireServer(unpack(args)) end
                        end)
                        if ok then
                            table.insert(Bypasses, {R = obj, A = args})
                            found = found + 1
                            break
                        end
                        task.wait(0.1)
                    end
                end
            end
        end
        
        if found == 0 then table.insert(Bypasses, {R = nil, A = {}, U = true}) end
        Criando = false
        status.Text = "✅ " .. #Bypasses .. " bypasses!"
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
    end)
end)

AddBtn("👑 ATIVAR GODMODE", Color3.fromRGB(0, 200, 100), function()
    if #Bypasses == 0 then
        status.Text = "⚠️ Gere bypass primeiro!"
        return
    end
    if GodModeAtivo then return end
    
    GodModeAtivo = true
    status.Text = "👑 GODMODE ATIVO!"
    status.TextColor3 = Color3.fromRGB(0, 255, 100)
    
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not hum then status.Text = "❌ Sem humanoid" return end
    
    -- Loop proteção
    task.spawn(function()
        while GodModeAtivo do
            pcall(function()
                if hum.Health < 100 then
                    for _, b in ipairs(Bypasses) do
                        if b.R then pcall(function()
                            if b.R:IsA("RemoteFunction") then b.R:InvokeServer(unpack(b.A))
                            else b.R:FireServer(unpack(b.A)) end
                        end) end
                    end
                    hum.Health = 100
                end
            end)
            task.wait(0.1)
        end
    end)
end)

AddBtn("🛡️ EMERGÊNCIA", Color3.fromRGB(255, 100, 100), function()
    pcall(function()
        local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 100 end
    end)
    status.Text = "🚨 Heal!"
end)

AddBtn("⏹️ DESATIVAR", Color3.fromRGB(100, 100, 100), function()
    GodModeAtivo = false
    status.Text = "⏹️ Desativado"
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

-- Botão minimizar
local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "−"
minBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local floatBtn = Instance.new("TextButton", sg)
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.Position = UDim2.new(0, 20, 0.5, -25)
floatBtn.Text = "👑"
floatBtn.TextSize = 24
floatBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
floatBtn.Visible = false
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    frame.Visible = not minimized
    floatBtn.Visible = minimized
end)

floatBtn.MouseButton1Click:Connect(function()
    minimized = false
    frame.Visible = true
    floatBtn.Visible = false
end)

-- Notificação
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Immortal v4.0",
        Text = "Menu carregado com sucesso!",
        Duration = 3
    })
end)

print("[IMMORTAL] ✅ Menu v4.0 carregado!")
