-- ============================================================
-- HERO TROCA v1.0 - DELTA MOBILE | redvampiro1
-- Sistema: Roubar Aparência + Trocar Identidade + Trollagem
-- Captura token de OUTRO player e voce entra como ele!
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- MEMORIA PERSISTENTE
-- ============================================================
local function getExecutorEnv()
    if getgenv then return getgenv() end
    return _G
end

local ENV = getExecutorEnv()
ENV.HeroTrocaV1 = ENV.HeroTrocaV1 or {}
local MEM = ENV.HeroTrocaV1

-- ============================================================
-- CONFIGURACAO
-- ============================================================
local MEUS_DADOS = {
    WalkSpeed = 16,
    MaxHealth = 100,
    JumpHeight = 7.2,
    HipHeight = 1.7982,
    AutoRotate = true,
    CorPele = BrickColor.new("Burlap"),
    ShirtTemplate = "http://www.roblox.com/asset/?id=144076357",
    PantsTemplate = "http://www.roblox.com/asset/?id=321738870",
    ShirtGraphic = "http://www.roblox.com/asset/?id=1947880429",
}

-- ============================================================
-- FUNCAO: CAPTURAR TOKEN DE OUTRO PLAYER (SCAN)
-- ============================================================
local function CapturarTokenAlvo(alvo)
    if not alvo or not alvo.Character then
        warn("[TROCA] Alvo nao encontrado!")
        return nil
    end

    local char = alvo.Character
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")

    local token = {
        -- DADOS DO ALVO
        AlvoName = alvo.Name,
        AlvoDisplayName = alvo.DisplayName,
        AlvoUserId = alvo.UserId,

        -- CHAVE DO SERVIDOR
        ServerKey = {
            PlaceId = game.PlaceId,
            JobId = game.JobId,
            PrivateServerId = game.PrivateServerId or nil,
        },

        -- APARENCIA COMPLETA DO ALVO
        Appearance = {
            BodyColors = {},
            Shirt = "",
            Pants = "",
            TShirt = "",
            Face = "",
            Hats = {},
            Accessories = {},
        },

        -- STATS DO ALVO
        Stats = {
            WalkSpeed = humanoid and humanoid.WalkSpeed or 16,
            JumpHeight = humanoid and humanoid.JumpHeight or 7.2,
            HipHeight = humanoid and humanoid.HipHeight or 1.7982,
            MaxHealth = humanoid and humanoid.MaxHealth or 100,
        },

        -- POSICAO DO ALVO
        Position = hrp and hrp.CFrame or CFrame.new(0, 10, 0),
    }

    -- BodyColors do alvo
    pcall(function()
        local bc = char:FindFirstChildOfClass("BodyColors")
        if bc then
            token.Appearance.BodyColors = {
                HeadColor = tostring(bc.HeadColor),
                TorsoColor = tostring(bc.TorsoColor),
                LeftArmColor = tostring(bc.LeftArmColor),
                RightArmColor = tostring(bc.RightArmColor),
                LeftLegColor = tostring(bc.LeftLegColor),
                RightLegColor = tostring(bc.RightLegColor),
            }
        end
    end)

    -- Roupas do alvo
    pcall(function()
        local shirt = char:FindFirstChildOfClass("Shirt")
        if shirt then token.Appearance.Shirt = shirt.ShirtTemplate end
        local pants = char:FindFirstChildOfClass("Pants")
        if pants then token.Appearance.Pants = pants.PantsTemplate end
        local sg = char:FindFirstChildOfClass("ShirtGraphic")
        if sg then token.Appearance.TShirt = sg.Graphic end
        local face = head and head:FindFirstChild("face")
        if face then token.Appearance.Face = face.Texture end
    end)

    -- Acessorios/Hats do alvo
    pcall(function()
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") or acc:IsA("Hat") then
                local info = {
                    Name = acc.Name,
                    AssetId = nil,
                    Position = nil,
                }
                -- Tenta pegar mesh/texture ID
                local handle = acc:FindFirstChild("Handle")
                if handle then
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChildOfClass("Mesh")
                    if mesh and mesh:IsA("SpecialMesh") then
                        info.AssetId = mesh.MeshId
                    end
                end
                table.insert(token.Appearance.Accessories, info)
            end
        end
    end)

    MEM.TokenAlvo = token
    MEM.MeuToken = MEM.MeuToken or {} -- Guarda meus dados tambem

    warn("[TROCA] Token de '" .. alvo.Name .. "' capturado!")
    warn("        Roupa: " .. (token.Appearance.Shirt ~= "" and "SIM" or "NAO"))
    warn("        Calca: " .. (token.Appearance.Pants ~= "" and "SIM" or "NAO"))
    return token
end

-- ============================================================
-- FUNCAO: APLICAR APARENCIA DO ALVO EM MIM
-- ============================================================
local function AplicarAparenciaAlvo()
    if not MEM.TokenAlvo then
        warn("[TROCA] Nenhum alvo capturado! Use SCAN primeiro.")
        return
    end

    local char = LocalPlayer.Character
    if not char then
        warn("[TROCA] Personagem nao carregado!")
        return
    end

    local data = MEM.TokenAlvo
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")

    -- 1. Aplicar BodyColors do alvo
    pcall(function()
        local bc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", char)
        local c = data.Appearance.BodyColors
        if c.HeadColor then bc.HeadColor = BrickColor.new(c.HeadColor) end
        if c.TorsoColor then bc.TorsoColor = BrickColor.new(c.TorsoColor) end
        if c.LeftArmColor then bc.LeftArmColor = BrickColor.new(c.LeftArmColor) end
        if c.RightArmColor then bc.RightArmColor = BrickColor.new(c.RightArmColor) end
        if c.LeftLegColor then bc.LeftLegColor = BrickColor.new(c.LeftLegColor) end
        if c.RightLegColor then bc.RightLegColor = BrickColor.new(c.RightLegColor) end
    end)

    -- 2. Aplicar Roupas do alvo
    pcall(function()
        if data.Appearance.Shirt ~= "" then
            local s = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
            s.ShirtTemplate = data.Appearance.Shirt
        end
        if data.Appearance.Pants ~= "" then
            local p = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
            p.PantsTemplate = data.Appearance.Pants
        end
        if data.Appearance.TShirt ~= "" then
            local t = char:FindFirstChildOfClass("ShirtGraphic") or Instance.new("ShirtGraphic", char)
            t.Graphic = data.Appearance.TShirt
        end
    end)

    -- 3. Aplicar Face do alvo
    pcall(function()
        if data.Appearance.Face ~= "" and head then
            local face = head:FindFirstChild("face")
            if face then
                face.Texture = data.Appearance.Face
            end
        end
    end)

    -- 4. Aplicar Stats do alvo
    pcall(function()
        if humanoid then
            humanoid.WalkSpeed = data.Stats.WalkSpeed
            humanoid.JumpHeight = data.Stats.JumpHeight
            humanoid.HipHeight = data.Stats.HipHeight
        end
    end)

    -- 5. CRIAR NOME FAKE (Overhead com nome do alvo)
    pcall(function()
        if humanoid then
            -- Remove nome antigo se existir
            local old = humanoid:FindFirstChild("TrocaNameTag")
            if old then old:Destroy() end

            local bill = Instance.new("BillboardGui")
            bill.Name = "TrocaNameTag"
            bill.Size = UDim2.new(0, 200, 0, 50)
            bill.StudsOffset = Vector3.new(0, 3, 0)
            bill.AlwaysOnTop = false
            bill.Parent = humanoid

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = data.AlvoDisplayName
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Parent = bill
        end
    end)

    warn("[TROCA] Voce agora parece '" .. data.AlvoDisplayName .. "'!")
end

-- ============================================================
-- FUNCAO: TROCA COMPLETA (Death + Rejoin como Alvo)
-- ============================================================
local function TrocaHeroica(alvo)
    if alvo then
        CapturarTokenAlvo(alvo)
    end

    if not MEM.TokenAlvo then
        warn("[TROCA] Selecione um alvo primeiro!")
        return
    end

    -- Salva meus dados antes de trocar
    local meuChar = LocalPlayer.Character
    if meuChar then
        local meuToken = {
            Appearance = {
                BodyColors = {},
                Shirt = MEUS_DADOS.ShirtTemplate,
                Pants = MEUS_DADOS.PantsTemplate,
                TShirt = MEUS_DADOS.ShirtGraphic,
                Face = "",
            },
            Stats = {
                WalkSpeed = MEUS_DADOS.WalkSpeed,
                JumpHeight = MEUS_DADOS.JumpHeight,
                HipHeight = MEUS_DADOS.HipHeight,
            }
        }
        pcall(function()
            local bc = meuChar:FindFirstChildOfClass("BodyColors")
            if bc then
                meuToken.Appearance.BodyColors = {
                    HeadColor = tostring(bc.HeadColor),
                    TorsoColor = tostring(bc.TorsoColor),
                    LeftArmColor = tostring(bc.LeftArmColor),
                    RightArmColor = tostring(bc.RightArmColor),
                    LeftLegColor = tostring(bc.LeftLegColor),
                    RightLegColor = tostring(bc.RightLegColor),
                }
            end
        end)
        MEM.MeuToken = meuToken
    end

    -- Prepara queue_on_teleport para aplicar apos rejoin
    pcall(function()
        if queue_on_teleport then
            local trocaScript = [[
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local MEM = (getgenv and getgenv() or _G).HeroTrocaV1

                if not MEM or not MEM.TokenAlvo then return end

                local data = MEM.TokenAlvo
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local humanoid = char:WaitForChild("Humanoid", 10)
                local head = char:WaitForChild("Head", 10)

                task.wait(2)

                -- Aplicar BodyColors
                pcall(function()
                    local bc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", char)
                    local c = data.Appearance.BodyColors
                    if c.HeadColor then bc.HeadColor = BrickColor.new(c.HeadColor) end
                    if c.TorsoColor then bc.TorsoColor = BrickColor.new(c.TorsoColor) end
                    if c.LeftArmColor then bc.LeftArmColor = BrickColor.new(c.LeftArmColor) end
                    if c.RightArmColor then bc.RightArmColor = BrickColor.new(c.RightArmColor) end
                    if c.LeftLegColor then bc.LeftLegColor = BrickColor.new(c.LeftLegColor) end
                    if c.RightLegColor then bc.RightLegColor = BrickColor.new(c.RightLegColor) end
                end)

                -- Aplicar Roupas
                pcall(function()
                    if data.Appearance.Shirt ~= "" then
                        local s = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
                        s.ShirtTemplate = data.Appearance.Shirt
                    end
                    if data.Appearance.Pants ~= "" then
                        local p = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
                        p.PantsTemplate = data.Appearance.Pants
                    end
                    if data.Appearance.TShirt ~= "" then
                        local t = char:FindFirstChildOfClass("ShirtGraphic") or Instance.new("ShirtGraphic", char)
                        t.Graphic = data.Appearance.TShirt
                    end
                end)

                -- Aplicar Face
                pcall(function()
                    if data.Appearance.Face ~= "" and head then
                        local face = head:FindFirstChild("face")
                        if face then face.Texture = data.Appearance.Face end
                    end
                end)

                -- Aplicar Stats
                pcall(function()
                    if humanoid then
                        humanoid.WalkSpeed = data.Stats.WalkSpeed
                        humanoid.JumpHeight = data.Stats.JumpHeight
                        humanoid.HipHeight = data.Stats.HipHeight
                    end
                end)

                -- Nome Fake
                pcall(function()
                    if humanoid then
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "TrocaNameTag"
                        bill.Size = UDim2.new(0, 200, 0, 50)
                        bill.StudsOffset = Vector3.new(0, 3, 0)
                        bill.Parent = humanoid

                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = data.AlvoDisplayName
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextStrokeTransparency = 0
                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label.TextScaled = true
                        label.Font = Enum.Font.GothamBold
                        label.Parent = bill
                    end
                end)

                warn("[TROCA AUTO] Voce entrou como '" .. data.AlvoDisplayName .. "'!")
            ]]
            queue_on_teleport(trocaScript)
        end
    end)

    -- Deleta personagem
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Efeito de troca
                for i = 1, 15 do
                    local part = Instance.new("Part")
                    part.Shape = Enum.PartType.Ball
                    part.Size = Vector3.new(0.5, 0.5, 0.5)
                    part.Position = hrp.Position + Vector3.new(math.random(-2,2), math.random(0,3), math.random(-2,2))
                    part.Anchored = false
                    part.CanCollide = false
                    part.Material = Enum.Material.Neon
                    part.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                    part.Parent = workspace
                    Debris:AddItem(part, 1)
                end
            end
            char:Destroy()
        end
        LocalPlayer.Character = nil
    end)

    task.wait(1.5)

    -- Teleporta pro mesmo servidor
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end

-- ============================================================
-- FUNCAO: VOLTAR AO NORMAL (restaurar meus dados)
-- ============================================================
local function VoltarNormal()
    if not MEM.MeuToken then
        warn("[TROCA] Nenhum dado seu salvo!")
        return
    end

    local char = LocalPlayer.Character
    if not char then return end

    local data = MEM.MeuToken
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")

    -- Restaurar minhas cores
    pcall(function()
        local bc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", char)
        local c = data.Appearance.BodyColors
        if c.HeadColor then bc.HeadColor = BrickColor.new(c.HeadColor) end
        if c.TorsoColor then bc.TorsoColor = BrickColor.new(c.TorsoColor) end
        if c.LeftArmColor then bc.LeftArmColor = BrickColor.new(c.LeftArmColor) end
        if c.RightArmColor then bc.RightArmColor = BrickColor.new(c.RightArmColor) end
        if c.LeftLegColor then bc.LeftLegColor = BrickColor.new(c.LeftLegColor) end
        if c.RightLegColor then bc.RightLegColor = BrickColor.new(c.RightLegColor) end
    end)

    -- Restaurar minhas roupas
    pcall(function()
        if data.Appearance.Shirt ~= "" then
            local s = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
            s.ShirtTemplate = data.Appearance.Shirt
        end
        if data.Appearance.Pants ~= "" then
            local p = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
            p.PantsTemplate = data.Appearance.Pants
        end
        if data.Appearance.TShirt ~= "" then
            local t = char:FindFirstChildOfClass("ShirtGraphic") or Instance.new("ShirtGraphic", char)
            t.Graphic = data.Appearance.TShirt
        end
    end)

    -- Remover nome fake
    pcall(function()
        if humanoid then
            local tag = humanoid:FindFirstChild("TrocaNameTag")
            if tag then tag:Destroy() end
        end
    end)

    -- Restaurar stats
    pcall(function()
        if humanoid then
            humanoid.WalkSpeed = data.Stats.WalkSpeed
            humanoid.JumpHeight = data.Stats.JumpHeight
            humanoid.HipHeight = data.Stats.HipHeight
        end
    end)

    MEM.TokenAlvo = nil
    warn("[TROCA] Voce voltou ao normal!")
end

-- ============================================================
-- GUI: LISTA DE PLAYERS PARA ESCOLHER ALVO
-- ============================================================
local function CriarListaPlayers()
    -- Remove GUI antiga
    local old = LocalPlayer.PlayerGui:FindFirstChild("HeroTroca_PlayerList")
    if old then old:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "HeroTroca_PlayerList"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 9997
    sg.Parent = LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 50, 200)
    stroke.Thickness = 2
    stroke.Parent = frame

    -- Titulo
    local titulo = Instance.new("TextLabel")
    titulo.Size = UDim2.new(1, 0, 0, 40)
    titulo.BackgroundTransparency = 1
    titulo.Text = "ESCOLHA SEU ALVO"
    titulo.TextColor3 = Color3.fromRGB(255, 100, 255)
    titulo.TextScaled = true
    titulo.Font = Enum.Font.GothamBold
    titulo.Parent = frame

    -- Subtitulo
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(0.9, 0, 0, 20)
    sub.Position = UDim2.new(0.05, 0, 0, 38)
    sub.BackgroundTransparency = 1
    sub.Text = "Toque para roubar a aparencia"
    sub.TextColor3 = Color3.fromRGB(180, 180, 180)
    sub.TextScaled = true
    sub.Font = Enum.Font.Gotham
    sub.Parent = frame

    -- Scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.9, 0, 0, 300)
    scroll.Position = UDim2.new(0.05, 0, 0, 65)
    scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = scroll

    local function atualizarLista()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 50)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.Text = ""
            btn.BorderSizePixel = 0
            btn.Parent = scroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            -- Nome
            local nome = Instance.new("TextLabel")
            nome.Size = UDim2.new(0.7, 0, 1, 0)
            nome.Position = UDim2.new(0, 10, 0, 0)
            nome.BackgroundTransparency = 1
            nome.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
            nome.TextColor3 = Color3.fromRGB(255, 255, 255)
            nome.TextScaled = true
            nome.Font = Enum.Font.GothamBold
            nome.TextXAlignment = Enum.TextXAlignment.Left
            nome.Parent = btn

            -- Status
            local status = Instance.new("TextLabel")
            status.Size = UDim2.new(0.25, 0, 0.6, 0)
            status.Position = UDim2.new(0.72, 0, 0.2, 0)
            status.BackgroundTransparency = 1
            status.Text = "ESCOLHER"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            status.TextScaled = true
            status.Font = Enum.Font.GothamBold
            status.Parent = btn

            btn.Activated:Connect(function()
                CapturarTokenAlvo(plr)
                status.Text = "OK!"
                status.TextColor3 = Color3.fromRGB(255, 255, 0)
                task.wait(0.5)
                sg:Destroy()
            end)
        end
    end

    atualizarLista()

    -- Botao fechar
    local fechar = Instance.new("TextButton")
    fechar.Size = UDim2.new(0, 30, 0, 30)
    fechar.Position = UDim2.new(1, -35, 0, 5)
    fechar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    fechar.Text = "X"
    fechar.TextColor3 = Color3.fromRGB(255,255,255)
    fechar.TextScaled = true
    fechar.Font = Enum.Font.GothamBold
    fechar.Parent = frame
    Instance.new("UICorner", fechar).CornerRadius = UDim.new(0, 8)
    fechar.Activated:Connect(function() sg:Destroy() end)

    -- Botao refresh
    local refresh = Instance.new("TextButton")
    refresh.Size = UDim2.new(0, 30, 0, 30)
    refresh.Position = UDim2.new(1, -70, 0, 5)
    refresh.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    refresh.Text = "R"
    refresh.TextColor3 = Color3.fromRGB(255,255,255)
    refresh.TextScaled = true
    refresh.Font = Enum.Font.GothamBold
    refresh.Parent = frame
    Instance.new("UICorner", refresh).CornerRadius = UDim.new(0, 8)
    refresh.Activated:Connect(atualizarLista)

    -- Drag
    local arrastando, dragInicio, posInicio = false, nil, nil
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            arrastando = true
            dragInicio = i.Position
            posInicio = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if arrastando and i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - dragInicio
            frame.Position = UDim2.new(posInicio.X.Scale, posInicio.X.Offset + d.X, posInicio.Y.Scale, posInicio.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then arrastando = false end
    end)
end

-- ============================================================
-- GUI PRINCIPAL
-- ============================================================
local function CriarGUITroca()
    local sg = Instance.new("ScreenGui")
    sg.Name = "HeroTroca_GUI"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 9999
    sg.Parent = LocalPlayer.PlayerGui

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 220, 0, 280)
    container.Position = UDim2.new(0.5, -110, 1, -300)
    container.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.Parent = sg
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 50, 200)
    stroke.Thickness = 2
    stroke.Parent = container

    -- Titulo
    local titulo = Instance.new("TextLabel")
    titulo.Size = UDim2.new(1, 0, 0, 35)
    titulo.BackgroundTransparency = 1
    titulo.Text = "HERO TROCA v1"
    titulo.TextColor3 = Color3.fromRGB(255, 100, 255)
    titulo.TextScaled = true
    titulo.Font = Enum.Font.GothamBold
    titulo.Parent = container

    -- Alvo atual
    local alvoLabel = Instance.new("TextLabel")
    alvoLabel.Size = UDim2.new(0.9, 0, 0, 20)
    alvoLabel.Position = UDim2.new(0.05, 0, 0, 38)
    alvoLabel.BackgroundTransparency = 1
    alvoLabel.Text = "Alvo: Nenhum"
    alvoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    alvoLabel.TextScaled = true
    alvoLabel.Font = Enum.Font.Gotham
    alvoLabel.Parent = container

    local function criarBotao(y, texto, cor, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 42)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = cor
        btn.Text = texto
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(255, 255, 255)
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.5
        btnStroke.Parent = btn

        btn.Activated:Connect(function()
            pcall(callback)
        end)

        return btn
    end

    -- Botao 1: ESCOLHER ALVO
    criarBotao(65, "ESCOLHER ALVO", Color3.fromRGB(150, 50, 200), function()
        CriarListaPlayers()
    end)

    -- Botao 2: APLICAR AGORA (sem rejoin)
    criarBotao(113, "APLICAR AGORA", Color3.fromRGB(0, 120, 200), function()
        AplicarAparenciaAlvo()
        if MEM.TokenAlvo then
            alvoLabel.Text = "Alvo: " .. MEM.TokenAlvo.AlvoDisplayName
            alvoLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end)

    -- Botao 3: TROCA HEROICA (Death + Rejoin como alvo)
    criarBotao(161, "TROCA HEROICA", Color3.fromRGB(200, 100, 0), function()
        alvoLabel.Text = "Trocando..."
        alvoLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        TrocaHeroica()
    end)

    -- Botao 4: VOLTAR NORMAL
    criarBotao(209, "VOLTAR NORMAL", Color3.fromRGB(0, 150, 50), function()
        VoltarNormal()
        alvoLabel.Text = "Alvo: Nenhum"
        alvoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end)

    -- Drag
    local arrastando, dragInicio, posInicio = false, nil, nil
    container.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            arrastando = true
            dragInicio = i.Position
            posInicio = container.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if arrastando and i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - dragInicio
            container.Position = UDim2.new(posInicio.X.Scale, posInicio.X.Offset + d.X, posInicio.Y.Scale, posInicio.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then arrastando = false end
    end)

    -- Atualiza label
    task.spawn(function()
        while sg and sg.Parent do
            if MEM.TokenAlvo then
                alvoLabel.Text = "Alvo: " .. MEM.TokenAlvo.AlvoDisplayName
            end
            task.wait(1)
        end
    end)

    return sg
end

-- ============================================================
-- INICIALIZACAO
-- ============================================================
CriarGUITroca()

warn("[HERO TROCA v1.0] Delta Mobile carregado!")
warn("              1. Escolha um alvo da lista")
warn("              2. Aplique agora ou faca Troca Heroica")
warn("              3. Para voltar ao normal use 'Voltar Normal'")
