-- ============================================
-- SCRIPT 1: CAPTURA DO PERSONAGEM
-- Delta Executor Mobile | FE-Safe
-- Use ANTES de entrar em jogos problemáticos
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildOfClass("Humanoid")
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

-- Aguarda personagem carregar
task.wait(1)

local relatorio = {}
local linha = function(texto) table.insert(relatorio, texto) end

linha("==============================================")
linha("   RELATÓRIO DO PERSONAGEM - HERO REVIVE")
linha("==============================================")
linha("")

-- INFO BÁSICA
linha("[INFO BÁSICA]")
linha("Nome: " .. LocalPlayer.Name)
linha("DisplayName: " .. LocalPlayer.DisplayName)
linha("UserId: " .. tostring(LocalPlayer.UserId))
linha("AccountAge: " .. tostring(LocalPlayer.AccountAge) .. " dias")
linha("")

-- HUMANOID
if Humanoid then
    linha("[HUMANOID]")
    linha("MaxHealth: " .. tostring(Humanoid.MaxHealth))
    linha("Health: " .. tostring(Humanoid.Health))
    linha("WalkSpeed: " .. tostring(Humanoid.WalkSpeed))
    linha("JumpPower: " .. tostring(Humanoid.JumpPower))
    linha("JumpHeight: " .. tostring(Humanoid.JumpHeight))
    linha("HipHeight: " .. tostring(Humanoid.HipHeight))
    linha("RigType: " .. tostring(Humanoid.RigType))
    linha("AutoRotate: " .. tostring(Humanoid.AutoRotate))
    linha("")
end

-- POSIÇÃO
if HumanoidRootPart then
    local pos = HumanoidRootPart.Position
    local rot = HumanoidRootPart.Orientation
    linha("[POSIÇÃO E ROTAÇÃO]")
    linha("Position: " .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z))
    linha("Orientation: " .. math.floor(rot.X) .. ", " .. math.floor(rot.Y) .. ", " .. math.floor(rot.Z))
    linha("")
end

-- APARÊNCIA / PARTES DO CORPO
linha("[PARTES DO CORPO]")
for _, part in ipairs(Character:GetChildren()) do
    if part:IsA("BasePart") then
        local cor = part.BrickColor.Name
        local tam = part.Size
        linha("Parte: " .. part.Name .. 
              " | Cor: " .. cor ..
              " | Tamanho: " .. string.format("%.2f, %.2f, %.2f", tam.X, tam.Y, tam.Z) ..
              " | Transparência: " .. tostring(part.Transparency) ..
              " | Material: " .. tostring(part.Material))
    end
end
linha("")

-- ACCESSORIES (chapéu, cabelo, etc.)
linha("[ACCESSORIES / ITENS]")
local temAcessorio = false
for _, acc in ipairs(Character:GetChildren()) do
    if acc:IsA("Accessory") then
        temAcessorio = true
        local handle = acc:FindFirstChild("Handle")
        local meshId = ""
        local texId = ""
        if handle then
            local mesh = handle:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                meshId = tostring(mesh.MeshId)
                texId = tostring(mesh.TextureId)
            end
        end
        linha("Accessory: " .. acc.Name .. " | MeshId: " .. meshId .. " | TextureId: " .. texId)
    end
end
if not temAcessorio then linha("Nenhum accessory encontrado") end
linha("")

-- SHIRTS / PANTS / BODY COLORS
linha("[ROUPAS / CORES]")
for _, item in ipairs(Character:GetChildren()) do
    if item:IsA("Shirt") then
        linha("Shirt: " .. item.Name .. " | ShirtTemplate: " .. tostring(item.ShirtTemplate))
    elseif item:IsA("Pants") then
        linha("Pants: " .. item.Name .. " | PantsTemplate: " .. tostring(item.PantsTemplate))
    elseif item:IsA("ShirtGraphic") then
        linha("ShirtGraphic: " .. tostring(item.Graphic))
    elseif item:IsA("BodyColors") then
        linha("BodyColors:")
        linha("  HeadColor: " .. tostring(item.HeadColor))
        linha("  TorsoColor: " .. tostring(item.TorsoColor))
        linha("  LeftArmColor: " .. tostring(item.LeftArmColor))
        linha("  RightArmColor: " .. tostring(item.RightArmColor))
        linha("  LeftLegColor: " .. tostring(item.LeftLegColor))
        linha("  RightLegColor: " .. tostring(item.RightLegColor))
    end
end
linha("")

-- ANIMAÇÕES
linha("[ANIMAÇÕES]")
local animate = Character:FindFirstChild("Animate")
if animate then
    for _, anim in ipairs(animate:GetChildren()) do
        if anim:IsA("StringValue") or anim:IsA("Animation") then
            linha("Anim: " .. anim.Name)
        elseif anim:IsA("LocalScript") or anim:IsA("Script") then
            linha("AnimScript: " .. anim.Name)
        end
    end
else
    linha("Script Animate não encontrado")
end
linha("")

-- VALORES / STATS
linha("[VALORES / LEADERSTATS]")
local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
if leaderstats then
    for _, stat in ipairs(leaderstats:GetChildren()) do
        linha(stat.Name .. ": " .. tostring(stat.Value))
    end
else
    linha("Sem leaderstats no jogo atual")
end
linha("")

-- SCRIPTS LOCAIS DO PERSONAGEM
linha("[SCRIPTS NO PERSONAGEM]")
for _, s in ipairs(Character:GetDescendants()) do
    if s:IsA("LocalScript") or s:IsA("Script") or s:IsA("ModuleScript") then
        linha("Script: " .. s:GetFullName())
    end
end
linha("")

linha("==============================================")
linha("   FIM DO RELATÓRIO")
linha("   Copie tudo acima e envie ao Claude")
linha("==============================================")

-- MONTAR TEXTO FINAL
local textoFinal = table.concat(relatorio, "\n")

-- EXIBIR NO OUTPUT
print(textoFinal)

-- ============================================
-- EXIBIR NA TELA (GUI MOBILE)
-- ============================================
local UserInputService = game:GetService("UserInputService")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.Name = "RelatorioGui"
ScreenGui.Parent = LocalPlayer.PlayerGui

local BG = Instance.new("Frame")
BG.Size = UDim2.new(0.9, 0, 0.8, 0)
BG.Position = UDim2.new(0.05, 0, 0.1, 0)
BG.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
BG.BorderSizePixel = 0
BG.Parent = ScreenGui
Instance.new("UICorner", BG).CornerRadius = UDim.new(0, 12)

local Titulo = Instance.new("TextLabel")
Titulo.Size = UDim2.new(1, 0, 0, 40)
Titulo.Position = UDim2.new(0, 0, 0, 0)
Titulo.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
Titulo.TextColor3 = Color3.fromRGB(255,255,255)
Titulo.Text = "⚡ RELATÓRIO DO PERSONAGEM"
Titulo.TextScaled = true
Titulo.Font = Enum.Font.GothamBold
Titulo.Parent = BG
Instance.new("UICorner", Titulo).CornerRadius = UDim.new(0, 12)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -100)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = BG

local Texto = Instance.new("TextLabel")
Texto.Size = UDim2.new(1, -10, 0, 0)
Texto.Position = UDim2.new(0, 5, 0, 0)
Texto.BackgroundTransparency = 1
Texto.TextColor3 = Color3.fromRGB(200, 255, 200)
Texto.Text = textoFinal
Texto.TextScaled = false
Texto.TextSize = 11
Texto.Font = Enum.Font.Code
Texto.TextWrapped = true
Texto.TextXAlignment = Enum.TextXAlignment.Left
Texto.TextYAlignment = Enum.TextYAlignment.Top
Texto.Parent = ScrollFrame
Texto.AutomaticSize = Enum.AutomaticSize.Y
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
task.wait(0.1)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Texto.TextBounds.Y + 20)

-- BOTÃO FECHAR
local BtnFechar = Instance.new("TextButton")
BtnFechar.Size = UDim2.new(0.45, 0, 0, 40)
BtnFechar.Position = UDim2.new(0.05, 0, 1, -50)
BtnFechar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BtnFechar.TextColor3 = Color3.fromRGB(255,255,255)
BtnFechar.Text = "✖ Fechar"
BtnFechar.TextScaled = true
BtnFechar.Font = Enum.Font.GothamBold
BtnFechar.Parent = BG
Instance.new("UICorner", BtnFechar).CornerRadius = UDim.new(0, 8)
BtnFechar.Activated:Connect(function()
    ScreenGui:Destroy()
end)

-- BOTÃO COPIAR (via setclipboard)
local BtnCopiar = Instance.new("TextButton")
BtnCopiar.Size = UDim2.new(0.45, 0, 0, 40)
BtnCopiar.Position = UDim2.new(0.5, 0, 1, -50)
BtnCopiar.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
BtnCopiar.TextColor3 = Color3.fromRGB(255,255,255)
BtnCopiar.Text = "📋 Copiar"
BtnCopiar.TextScaled = true
BtnCopiar.Font = Enum.Font.GothamBold
BtnCopiar.Parent = BG
Instance.new("UICorner", BtnCopiar).CornerRadius = UDim.new(0, 8)
BtnCopiar.Activated:Connect(function()
    if setclipboard then
        setclipboard(textoFinal)
        BtnCopiar.Text = "✅ Copiado!"
        task.wait(2)
        BtnCopiar.Text = "📋 Copiar"
    else
        BtnCopiar.Text = "❌ Sem suporte"
    end
end)

warn("[HERO REVIVE] Relatório gerado com sucesso! Pressione 'Copiar' ou copie do Output.")
