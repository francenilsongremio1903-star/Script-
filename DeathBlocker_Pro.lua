-- ═══════════════════════════════════════════════════════════════
--   DEATH BLOCKER PRO + ANTI-ELIMINAÇÃO  by RBXSCAN
--   Protege contra:
--   1. Telas de morte / overlay de congelamento
--   2. Morte do Humanoid (Health, estado Dead)
--   3. Personagem preso no chão / ragdoll
--   4. Personagem deletado pelo jogo
--   5. Atributos de morto / eliminado
--   6. Câmera / controles travados
--   7. Remotes de eliminação (hookmetamethod)
--   8. GUIs de espectador / eliminação
-- ═══════════════════════════════════════════════════════════════

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local StarterGui   = game:GetService("StarterGui")
local lp           = Players.LocalPlayer
local pgui         = lp:WaitForChild("PlayerGui")
local camera       = workspace.CurrentCamera

-- ══════════════════════════════════════════════════
--  ESTADOS
-- ══════════════════════════════════════════════════
local S = {
    guiBlock      = false,
    humanoidBlock = false,
    attrBlock     = false,
    unfreezeBlock = false,
    charBlock     = false,
    inputBlock    = false,
    participBlock = false,
    antiElim      = false,
    autoRevive    = false,
}

local _conns = {}
local function disconnect(key)
    if _conns[key] then
        pcall(function() _conns[key]:Disconnect() end)
        _conns[key] = nil
    end
end

-- ══════════════════════════════════════════════════
--  ANTI-ELIMINAÇÃO — hookmetamethod (ativa no load)
--  Bloqueia FireServer/InvokeServer/FireAllClients
--  de QUALQUER remote que cheira a eliminação.
--  Estratégia: bloquear por palavras-chave EM QUALQUER
--  parte do nome, não só no começo/fim.
-- ══════════════════════════════════════════════════

-- Palavras que, se aparecerem em QUALQUER parte do nome, bloqueiam
local ELIM_KEYWORDS = {
    "elim","spectate","spectator","sendlobby","sendtospect",
    "playerout","playerelim","removeplayer","setdead","markdead",
    "knockout","knockedout","killedplayer","killplayer",
    "setloser","putspectator","golobby","movelobby",
    "deathremote","dieremote","deadremote",
    "coffin","bury","buried","grave",
    "eliminado","eliminação","eliminar","morreu","matar",
}
-- Palavras que, se o nome for EXATAMENTE igual, bloqueiam (sem falso positivo)
local ELIM_EXACT = {
    "die","dead","kill","out","remove","hide","tp","teleport",
    "move","send","set","mark","update","notify","event",
}
-- Combinações suspeitas: bloquear se o nome contiver DUAS dessas juntas
local ELIM_COMBO = {
    {"kill","player"},{"kill","char"},{"kill","local"},
    {"dead","player"},{"die","player"},{"set","dead"},
    {"set","elim"},{"player","dead"},{"player","die"},
    {"remove","char"},{"delete","char"},{"destroy","char"},
    {"tp","dead"},{"tp","coffin"},{"send","dead"},
    {"move","dead"},{"put","spec"},{"set","spec"},
    {"force","dead"},{"force","die"},{"force","elim"},
}

local function shouldBlockRemote(name)
    local low = name:lower()

    -- 1) Palavra-chave em qualquer parte do nome
    for _, kw in ipairs(ELIM_KEYWORDS) do
        if low:find(kw, 1, true) then return true end
    end

    -- 2) Combinação de duas palavras suspeitas no mesmo nome
    for _, pair in ipairs(ELIM_COMBO) do
        if low:find(pair[1], 1, true) and low:find(pair[2], 1, true) then
            return true
        end
    end

    return false
end

-- Interceptar também FireClient e InvokeClient vindos do servidor
-- (alguns jogos mandam pro client a ordem de se eliminar)
-- ══════════════════════════════════════════════════
--  HOOK PRINCIPAL + TAKEDAMAGE
-- ══════════════════════════════════════════════════

-- Palavras suspeitas nos ARGUMENTOS de um remote (tipo string enviada)
local ARG_KW_BLOCK = {
    "elim","dead","die","kill","spectate","knocked","ko",
    "eliminated","loser","buried","coffin","remove",
    "morreu","eliminar","eliminado","morto",
}
local function argSuspeito(arg)
    if type(arg) ~= "string" then return false end
    local low = arg:lower()
    for _, kw in ipairs(ARG_KW_BLOCK) do
        if low:find(kw,1,true) then return true end
    end
    return false
end

-- Verificar se algum argumento da chamada é o LocalPlayer ou seu char
local function argsContemLocalPlayer(args)
    for _, a in ipairs(args) do
        if a == lp then return true end
        if lp.Character and a == lp.Character then return true end
        -- UserId como número
        if type(a) == "number" and a == lp.UserId then return true end
    end
    return false
end

local _hookAtivo = false
pcall(function()
    local prev
    prev = hookmetamethod(game, "__namecall", function(self, ...)
        local m = getnamecallmethod()

        -- === BLOQUEAR TakeDamage direto no Humanoid do LocalPlayer ===
        if m == "TakeDamage" then
            if self:IsA("Humanoid") then
                local char = lp.Character
                if char and self == char:FindFirstChildOfClass("Humanoid") then
                    return 0  -- ignorar dano completamente
                end
            end
        end

        -- === BLOQUEAR remotes de eliminação ===
        if m == "FireServer" or m == "InvokeServer"
        or m == "FireClient" or m == "InvokeClient" then
            if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                -- 1) Nome do remote contém palavra de eliminação
                if shouldBlockRemote(self.Name) then return end

                -- 2) Argumento string contém palavra de eliminação
                --    (ex: remote genérico "Event" com arg "eliminate")
                local args = {...}
                for _, a in ipairs(args) do
                    if argSuspeito(a) then return end
                end

                -- 3) Remote genérico que passa o LocalPlayer como alvo
                --    E tem nome suspeito de ação sobre player
                --    (ex: "KillPlayer", "RemovePlayer", "HitPlayer")
                if argsContemLocalPlayer(args) then
                    local low = self.Name:lower()
                    -- Nomes de ação sobre player que indicam eliminação
                    local PVP_KW = {
                        "kill","hit","damage","hurt","die","dead","elim",
                        "remove","tp","teleport","send","move","force",
                        "knockout","ko","coffin","bury","spectate",
                    }
                    for _, kw in ipairs(PVP_KW) do
                        if low:find(kw,1,true) then return end
                    end
                end
            end
        end

        return prev(self, ...)
    end)
    _hookAtivo = true
end)

-- Hook TakeDamage via __newindex também (alguns executores expõem diferente)
pcall(function()
    local hum_mt = getrawmetatable(game)
    -- Tentar hookar diretamente o método TakeDamage no Humanoid
    -- via setrawmetatable se disponível
    if setrawmetatable then
        local old_index = hum_mt.__index
        setrawmetatable(game, hum_mt)
    end
end)

-- ══════════════════════════════════════════════════
--  CRIAR GUI
-- ══════════════════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "RBXSCAN_DBPro"
screenGui.ResetOnSpawn   = false
screenGui.DisplayOrder   = 9999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent         = pgui

local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.new(0, 278, 0, 530)
main.Position         = UDim2.new(0, 14, 0.5, -205)
main.BackgroundColor3 = Color3.fromRGB(7, 7, 14)
main.BorderSizePixel  = 0
main.Parent           = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", main)
mStroke.Color = Color3.fromRGB(0, 210, 155); mStroke.Thickness = 1.2

local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 20, 15)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
local tfix = Instance.new("Frame")
tfix.Size=UDim2.new(1,0,0.5,0); tfix.Position=UDim2.new(0,0,0.5,0)
tfix.BackgroundColor3=Color3.fromRGB(0,20,15); tfix.BorderSizePixel=0; tfix.Parent=titleBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size=UDim2.new(1,-82,1,0); titleLbl.Position=UDim2.new(0,12,0,0)
titleLbl.BackgroundTransparency=1; titleLbl.Text="⚡ DEATH BLOCKER PRO"
titleLbl.TextColor3=Color3.fromRGB(0,210,155); titleLbl.TextSize=12
titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
titleLbl.Parent=titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size=UDim2.new(0,28,0,28); minBtn.Position=UDim2.new(1,-64,0.5,-14)
minBtn.BackgroundColor3=Color3.fromRGB(25,55,42); minBtn.Text="—"
minBtn.TextColor3=Color3.fromRGB(0,210,155); minBtn.TextSize=14
minBtn.Font=Enum.Font.GothamBold; minBtn.BorderSizePixel=0; minBtn.Parent=titleBar
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(0,6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,28,0,28); closeBtn.Position=UDim2.new(1,-32,0.5,-14)
closeBtn.BackgroundColor3=Color3.fromRGB(160,25,40); closeBtn.Text="✕"
closeBtn.TextColor3=Color3.fromRGB(255,255,255); closeBtn.TextSize=11
closeBtn.Font=Enum.Font.GothamBold; closeBtn.BorderSizePixel=0; closeBtn.Parent=titleBar
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local scroll = Instance.new("ScrollingFrame")
scroll.Name                 = "Scroll"
scroll.Size                 = UDim2.new(1,-8,1,-52)
scroll.Position             = UDim2.new(0,4,0,46)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel      = 0
scroll.ScrollBarThickness   = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(0,180,120)
scroll.CanvasSize           = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
scroll.Parent               = main

local content = Instance.new("Frame")
content.Name              = "Content"
content.Size              = UDim2.new(1,-6,0,0)
content.AutomaticSize     = Enum.AutomaticSize.Y
content.BackgroundTransparency = 1
content.Parent            = scroll

local layout = Instance.new("UIListLayout",content)
layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,6)
local pad = Instance.new("UIPadding",content)
pad.PaddingLeft=UDim.new(0,2); pad.PaddingRight=UDim.new(0,2)
pad.PaddingTop=UDim.new(0,4);  pad.PaddingBottom=UDim.new(0,8)

local floatBtn = Instance.new("TextButton")
floatBtn.Size=UDim2.new(0,46,0,46); floatBtn.Position=UDim2.new(0,14,0.5,-23)
floatBtn.BackgroundColor3=Color3.fromRGB(0,20,15); floatBtn.Text="⚡"
floatBtn.TextSize=22; floatBtn.Font=Enum.Font.GothamBold
floatBtn.TextColor3=Color3.fromRGB(0,210,155); floatBtn.BorderSizePixel=0
floatBtn.Visible=false; floatBtn.Parent=screenGui
Instance.new("UICorner",floatBtn).CornerRadius=UDim.new(0,10)
local fStroke=Instance.new("UIStroke",floatBtn)
fStroke.Color=Color3.fromRGB(0,210,155); fStroke.Thickness=1.2

minBtn.MouseButton1Click:Connect(function() main.Visible=false; floatBtn.Visible=true end)
floatBtn.MouseButton1Click:Connect(function() main.Visible=true; floatBtn.Visible=false end)

-- ══════════════════════════════════════════════════
--  HELPER
-- ══════════════════════════════════════════════════
local function ehNosso(obj)
    local cur=obj
    while cur do if cur==screenGui then return true end; cur=cur.Parent end
    return false
end

-- ══════════════════════════════════════════════════
--  RAGDOLL — UTILITÁRIO CENTRAL
--  Essa é a função que resolve o preso no chão.
--  Chama ela sempre que suspeitar de ragdoll.
-- ══════════════════════════════════════════════════
local function fixRagdoll(char)
    if not char or not char.Parent then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- 1) Reativar todas as Motor6D (jogos desligam pra fazer ragdoll)
    for _, m in ipairs(char:GetDescendants()) do
        if m:IsA("Motor6D") and not m.Enabled then
            pcall(function() m.Enabled = true end)
        end
    end

    -- 2) Destruir constraints de ragdoll que jogos inserem
    --    (BallSocketConstraint, HingeConstraint, NoPhysics etc.)
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") then
            -- Só destruir se o pai for um osso (BasePart dentro do char)
            -- e não for parte original do personagem
            if obj.Parent and obj.Parent:IsA("BasePart") then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    -- 3) Desancorar tudo
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Anchored then
            pcall(function() p.Anchored = false end)
        end
    end

    -- 4) Remover BodyPosition/AlignPosition que pregam no chão
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BodyPosition") or p:IsA("AlignPosition") or p:IsA("BodyGyro") then
            pcall(function() p:Destroy() end)
        end
    end

    -- 5) Desabilitar estados que travam e forçar Running
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,      false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,          false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead,             false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running,          true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,          true)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,        true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,         true)

        -- Força Running diretamente (mais confiável que GettingUp)
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.FallingDown
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.PlatformStanding then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)

    -- 6) Restaurar velocidade se zerada
    pcall(function()
        if hum.WalkSpeed < 1 then hum.WalkSpeed = 16 end
        if hum.JumpPower  < 1 then hum.JumpPower = 50 end
        if hum.Health     < 1 then hum.Health = hum.MaxHealth end
    end)
end

-- ══════════════════════════════════════════════════
--  SQUIDGAME X — FIXES ESPECÍFICOS
-- ══════════════════════════════════════════════════
local S_squid      = false
local _lastGoodPos = Vector3.new(0, 10, 0)
local _squidConns  = {}

-- Partes originais do R15/R6 — nunca esconder essas
local _originais = {
    HumanoidRootPart=true, Head=true,
    UpperTorso=true, LowerTorso=true, Torso=true,
    LeftUpperArm=true, LeftLowerArm=true, LeftHand=true,
    RightUpperArm=true, RightLowerArm=true, RightHand=true,
    LeftUpperLeg=true, LeftLowerLeg=true, LeftFoot=true,
    RightUpperLeg=true, RightLowerLeg=true, RightFoot=true,
    ["Left Arm"]=true, ["Right Arm"]=true,
    ["Left Leg"]=true, ["Right Leg"]=true,
}

-- Classes de força que puxam o char pro caixão
local function ehForca(obj)
    local c = obj.ClassName
    return c=="BodyPosition" or c=="BodyVelocity" or c=="BodyForce"
        or c=="BodyGyro"     or c=="AlignPosition" or c=="LinearVelocity"
        or c=="AngularVelocity" or c=="VectorForce"
end

-- Nomes de anim de morte
local DEATH_ANIMS = {"death","die","dead","fall","fallingdown","knockout","ko","ragdoll","coffin","buried"}
local function ehAnimMorte(track)
    local n = track.Name:lower()
    for _, kw in ipairs(DEATH_ANIMS) do if n:find(kw,1,true) then return true end end
    return false
end

-- Detectar se o char foi tornado invisível (caixão)
local function charInvisivel(char)
    local total, invis = 0, 0
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and _originais[p.Name] then
            total = total + 1
            if p.Transparency >= 0.9 then invis = invis + 1 end
        end
    end
    return total > 0 and (invis/total) >= 0.8
end

local function restaurarChar(char)
    -- Restaurar visibilidade das partes originais
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and _originais[p.Name] then
            pcall(function() p.Transparency = 0 end)
        end
    end
    fixRagdoll(char)
    -- Parar anims de morte
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local anim = hum:FindFirstChildOfClass("Animator")
        if anim then
            for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                if ehAnimMorte(t) then pcall(function() t:Stop(0) end) end
            end
        end
    end
end

local _recuperando = false
local function recuperarCharSquid()
    if _recuperando then return end
    _recuperando = true
    task.spawn(function()
        local char = lp.Character
        if char and char.Parent then
            restaurarChar(char)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position.Y < -10 or hrp.Position.Y > 800) then
                pcall(function() hrp.Anchored=false; hrp.CFrame=CFrame.new(_lastGoodPos) end)
            end
            task.wait(0.3)
            if lp.Character and charInvisivel(lp.Character) then
                for _ = 1, 4 do
                    pcall(function() lp:LoadCharacter() end)
                    task.wait(0.5)
                    if lp.Character and not charInvisivel(lp.Character) then break end
                end
            end
        else
            for _ = 1, 4 do
                pcall(function() lp:LoadCharacter() end)
                task.wait(0.5)
                if lp.Character and lp.Character.Parent then break end
            end
        end
        task.wait(1)
        _recuperando = false
    end)
end

local function ativarSquidFix()
    if S_squid then return end; S_squid = true

    local function monitorarSquid(char)

        -- FIX 1: destruir forças em tempo real (puxado pro caixão)
        -- FIX 2: esconder quadrado branco (BasePart extra adicionada ao char)
        local connAdd = char.DescendantAdded:Connect(function(obj)
            if not S_squid then return end

            -- Destruir imediatamente objeto de força
            if ehForca(obj) then
                pcall(function() obj:Destroy() end)
                -- Teleportar de volta se já foi arrastado
                task.defer(function()
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Position.Y < -5 then
                        pcall(function() hrp.CFrame = CFrame.new(_lastGoodPos) end)
                    end
                end)
                return
            end

            -- Esconder BasePart extra filho direto do char (quadrado branco)
            -- Não afeta accessories (Accessory contém Handle, não BasePart direta)
            if obj:IsA("BasePart") and obj.Parent == char and not _originais[obj.Name] then
                task.defer(function()
                    pcall(function()
                        obj.Transparency = 1
                        obj.CanCollide   = false
                        obj.Anchored     = false
                    end)
                end)
            end
        end)
        table.insert(_squidConns, connAdd)

        -- FIX 3: Deleção rápida do char inteiro
        -- AncestryChanged no char dispara IMEDIATAMENTE quando o servidor
        -- remove o char do workspace — mais rápido que DescendantRemoving
        -- Depois do respawn: forçar câmera pro novo char (não ficar presa na morte)
        local _respawnandoRapido = false
        local connAnc = char.AncestryChanged:Connect(function(_, parent)
            if not S_squid then return end
            if parent ~= nil then return end -- só quando removido do workspace
            if _respawnandoRapido then return end
            _respawnandoRapido = true

            -- Câmera: apontar pro último ponto bom imediatamente (não ficar presa)
            pcall(function()
                camera.CameraType = Enum.CameraType.Custom
                -- CFrame provisório enquanto respawn não chega
                camera.CFrame = CFrame.new(_lastGoodPos + Vector3.new(0, 5, 0),
                                           _lastGoodPos)
            end)

            task.spawn(function()
                -- Respawn rápido: tentar a cada 0.2s até 8 vezes
                for _ = 1, 8 do
                    pcall(function() lp:LoadCharacter() end)
                    task.wait(0.2)
                    local nc = lp.Character
                    if nc and nc.Parent and nc ~= char then
                        -- Char novo apareceu — corrigir câmera imediatamente
                        task.wait(0.05)
                        pcall(function()
                            local hum = nc:FindFirstChildOfClass("Humanoid")
                            if hum then
                                camera.CameraType    = Enum.CameraType.Custom
                                camera.CameraSubject = hum
                            end
                        end)
                        break
                    end
                end
                _respawnandoRapido = false
            end)
        end)
        table.insert(_squidConns, connAnc)

        -- Também monitorar CharacterRemoving no player (dispara quando o servidor
        -- remove o personagem via Destroy — complementa o AncestryChanged)
        local connCharRem = lp.CharacterRemoving:Connect(function(removedChar)
            if not S_squid or removedChar ~= char then return end
            -- Câmera: tirar do lugar da morte na hora
            pcall(function()
                camera.CameraType = Enum.CameraType.Custom
                camera.CFrame = CFrame.new(_lastGoodPos + Vector3.new(0,8,0),
                                           _lastGoodPos)
            end)
        end)
        table.insert(_squidConns, connCharRem)

        -- FIX 4: Anti-TP do servidor — detecta salto brusco de posição
        -- Teleportes do servidor movem o char > 30 studs em 1 frame
        -- Movimento normal nunca passa de ~2-3 studs por frame
        local _prevPos = nil
        local _antiTpAtivo = false -- pequena janela de graça após spawn
        task.delay(1.5, function() _antiTpAtivo = true end) -- ignorar os primeiros 1.5s (spawn normal)

        local connTP = RunService.RenderStepped:Connect(function()
            if not S_squid or not _antiTpAtivo then return end
            if not char or not char.Parent then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local pos = hrp.Position
            if _prevPos then
                local dist = (pos - _prevPos).Magnitude
                -- Salto > 25 studs em 1 frame = TP forçado pelo servidor
                if dist > 25 then
                    -- Voltar pra posição anterior imediatamente
                    pcall(function() hrp.CFrame = CFrame.new(_lastGoodPos) end)
                    -- Não atualizar _prevPos nem _lastGoodPos aqui
                    return
                end
            end
            -- Posição válida — salvar
            _prevPos = pos
            if pos.Y > -5 and pos.Y < 800 then
                _lastGoodPos = pos + Vector3.new(0, 5, 0)
            end
        end)
        table.insert(_squidConns, connTP)

        -- Heartbeat: caixão (invisível / subsolo) + anim presa
        local connHB = RunService.Heartbeat:Connect(function()
            if not S_squid then return end
            if not char or not char.Parent then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if charInvisivel(char)          then recuperarCharSquid(); return end
            if hrp and hrp.Position.Y < -15 then recuperarCharSquid(); return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed == 0 then
                local anim = hum:FindFirstChildOfClass("Animator")
                if anim then
                    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                        if ehAnimMorte(t) then
                            pcall(function() t:Stop(0); fixRagdoll(char) end); break
                        end
                    end
                end
            end
        end)
        table.insert(_squidConns, connHB)
    end

    if lp.Character then monitorarSquid(lp.Character) end
    local connChar = lp.CharacterAdded:Connect(function(char)
        task.wait(0.2); monitorarSquid(char)
    end)
    table.insert(_squidConns, connChar)
end

local function desativarSquidFix()
    S_squid = false
    for _, c in ipairs(_squidConns) do pcall(function() c:Disconnect() end) end
    _squidConns = {}
    _recuperando = false
end

-- ══════════════════════════════════════════════════
--  TIPO 1 — BLOQUEAR GUI DE MORTE
-- ══════════════════════════════════════════════════
local DEATH_TEXTS = {
    "volte para o lobby","regenerar 10","jogue de novo","carregando???",
    "você morreu","você foi eliminado","hora 1","hora1",
    "play again","back to lobby","you died","you have died",
}
local DEATH_NAMES = {
    "deathgui","deathscreen","deathui","diedgui",
    "eliminatedgui","killgui","gameovergui","deadgui","killcard",
    "deathframe","deathoverlay","deathpanel",
}
local PROTECTED_NAMES = {
    "coregui","topbar","chat","playerlist","backpack","healthgui",
    "respawngui","mobile","touchgui","joystick","jumpbutton",
    "sprintbutton","runbutton","dashbutton","attackbutton",
    "skillgui","abilitygui","hotbar","hud","maingui","gamegui",
    "inventarygui","loja","shop","inventory","configuracoes",
    "settings","menu","mainmenu","startergui",
}

-- GUIs de espectador/eliminação (do anti-eliminação)
local SPEC_GUIS = {
    "spectategui","spectatorgui","eliminatedgui","eliminationscreen",
    "spectatescreen","sendtolobbygui","youareeliminated","playeroutgui",
}

local _bloqueados = {}

local function estaProtegido(sg)
    if not sg then return true end
    local n = sg.Name:lower()
    for _, p in ipairs(PROTECTED_NAMES) do
        if n:find(p,1,true) then return true end
    end
    return false
end
local function textoSuspeito(obj)
    if not(obj:IsA("TextLabel") or obj:IsA("TextButton")) then return false end
    local t = obj.Text:lower()
    for _,kw in ipairs(DEATH_TEXTS) do if t:find(kw,1,true) then return true end end
    return false
end
local function nomeSuspeito(obj)
    local n = obj.Name:lower()
    for _,kw in ipairs(DEATH_NAMES) do if n:find(kw,1,true) then return true end end
    for _,kw in ipairs(SPEC_GUIS)   do if n == kw            then return true end end
    return false
end
local function getSG(obj)
    local cur=obj
    while cur and cur~=pgui do if cur:IsA("ScreenGui") then return cur end; cur=cur.Parent end
    return nil
end
local function bloquear(alvo)
    if not alvo or _bloqueados[alvo] or ehNosso(alvo) then return end
    if estaProtegido(alvo) then return end
    _bloqueados[alvo]=true
    pcall(function() alvo.Enabled=false end)
    pcall(function() alvo.Visible=false end)
    pcall(function() alvo:Destroy() end)
end
local function processarObj(obj)
    if not obj or not obj.Parent or ehNosso(obj) then return end
    local sg = getSG(obj) or obj
    if estaProtegido(sg) then return end
    if (obj:IsA("ScreenGui") or obj:IsA("Frame")) and nomeSuspeito(obj) then
        bloquear(obj)
    elseif textoSuspeito(obj) then
        local parent = getSG(obj)
        if parent and not estaProtegido(parent) then bloquear(parent) end
    end
end

local function ativarGuiBlock()
    if S.guiBlock then return end; S.guiBlock=true; _bloqueados={}
    for _,obj in ipairs(pgui:GetDescendants()) do if not ehNosso(obj) then processarObj(obj) end end
    _conns.guiAdd = pgui.DescendantAdded:Connect(function(obj) task.defer(function() processarObj(obj) end) end)
    _conns.guiHB  = RunService.Heartbeat:Connect(function()
        for _,sg in ipairs(pgui:GetChildren()) do
            if sg~=screenGui and sg:IsA("ScreenGui") and sg.Enabled then
                for _,ch in ipairs(sg:GetDescendants()) do
                    if textoSuspeito(ch) then bloquear(sg); break end
                end
            end
        end
    end)
end
local function desativarGuiBlock()
    S.guiBlock=false; _bloqueados={}
    disconnect("guiAdd"); disconnect("guiHB")
end

-- ══════════════════════════════════════════════════
--  TIPO 2A — INTERCEPÇÃO PRÉ-MORTE (Humanoid)
-- ══════════════════════════════════════════════════
local _revivedThisFrame = false

local function executarRevive()
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/hQLWaCQd"))()
        end)
    end)
end

local function hookHumanoid(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local maxHP = math.max(hum.MaxHealth, 100)

    -- Desabilitar estados problemáticos imediatamente
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead,             false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,      false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,          false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running,          true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,          true)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,        true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,         true)
    end)

    -- HOOK TakeDamage no nível do Humanoid (PvP usa isso diretamente)
    -- Sobrescreve o método TakeDamage pra não fazer nada
    pcall(function()
        hum.TakeDamage = function() end
    end)
    -- Se o executor suportar hookfunction
    pcall(function()
        if hookfunction then
            hookfunction(hum.TakeDamage, function() return end)
        end
    end)

    -- CAMADA 1: RenderStepped — antes da física
    disconnect("render")
    _conns.render = RunService.RenderStepped:Connect(function()
        if not S.humanoidBlock then return end
        if not char or not char.Parent then disconnect("render"); return end
        if hum.MaxHealth > 0 then maxHP = hum.MaxHealth end

        -- Checar morte E qualquer dano (PvP reduz health gradualmente)
        if hum.Health < maxHP then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum.Health = maxHP  -- restaurar HP completo todo frame
            end)
        end

        -- Checar ragdoll/preso no chão — SEMPRE, não só quando morre
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.FallingDown
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.PlatformStanding then
            fixRagdoll(char)
        end
    end)

    -- CAMADA 2: GetPropertyChangedSignal("Health") — reage na hora do dano
    disconnect("hpChanged")
    _conns.hpChanged = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not S.humanoidBlock then return end
        -- PvP: qualquer redução de HP → restaurar imediatamente
        if hum.Health < maxHP and not _revivedThisFrame then
            _revivedThisFrame = true
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum.Health = maxHP
            end)
            if hum.Health <= 0 and S.autoRevive then executarRevive() end
            task.defer(function() _revivedThisFrame = false end)
        end
    end)

    -- CAMADA 3: StateChanged
    disconnect("state")
    _conns.state = hum.StateChanged:Connect(function(_, new)
        if not S.humanoidBlock then return end
        if new == Enum.HumanoidStateType.Dead then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum.Health = maxHP
            end)
            if S.autoRevive then executarRevive() end
        end
        -- Detectar ragdoll pelo StateChanged também
        if new == Enum.HumanoidStateType.FallingDown
        or new == Enum.HumanoidStateType.Ragdoll then
            task.defer(function() fixRagdoll(char) end)
        end
    end)

    -- CAMADA 4: Heartbeat — rede de segurança
    disconnect("health")
    _conns.health = RunService.Heartbeat:Connect(function()
        if not S.humanoidBlock then return end
        if not char or not char.Parent then disconnect("health"); return end
        if hum.MaxHealth > 0 then maxHP = hum.MaxHealth end
        if hum.Health <= 0 then
            pcall(function() hum.Health = maxHP end)
        end
        -- Segunda checagem de ragdoll no Heartbeat
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.FallingDown
        or st == Enum.HumanoidStateType.Ragdoll then
            fixRagdoll(char)
        end
    end)

    -- CAMADA 5: DescendantAdded — detectar Motor6D sendo desligado em tempo real
    disconnect("descAdded")
    _conns.descAdded = char.DescendantAdded:Connect(function(obj)
        if not S.humanoidBlock then return end
        -- Jogo adicionou BallSocketConstraint = ragdoll acontecendo agora
        if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") then
            task.defer(function() fixRagdoll(char) end)
        end
    end)
end

local function ativarHumanoidBlock()
    if S.humanoidBlock then return end; S.humanoidBlock=true
    if lp.Character then hookHumanoid(lp.Character) end
    disconnect("charH")
    _conns.charH=lp.CharacterAdded:Connect(function(char)
        task.wait(0.1); hookHumanoid(char)
    end)
end
local function desativarHumanoidBlock()
    S.humanoidBlock=false
    disconnect("state"); disconnect("health"); disconnect("charH")
    disconnect("render"); disconnect("hpChanged"); disconnect("descAdded")
    local char=lp.Character
    if char then
        local h=char:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Dead,true) end) end
    end
end

-- ══════════════════════════════════════════════════
--  TIPO 2B — ATRIBUTOS DE MORTE
-- ══════════════════════════════════════════════════
-- Qualquer atributo cujo nome contenha essas palavras → forçar false
local ATTR_KW_FALSE = {
    "dead","die","death","elim","spectate","spectator","spec",
    "out","loser","lose","knockout","ko","buried","coffin",
    "waiting","lobby","removed","inactive","frozen","locked",
    "morto","morreu","eliminado","perdedor","fora","espectador",
}
-- Qualquer atributo cujo nome contenha essas palavras → forçar true
local ATTR_KW_TRUE = {
    "alive","active","playing","ingame","inround","inMatch",
    "participant","player","canplay","canmove","canrun",
    "vivo","jogando","ativo","participante",
}
-- Atributos exatos que sempre forçamos (independente de keyword)
local ATTR_EXACT_FALSE = {
    "IsDead","isDead","is_dead","Dead","dead",
    "IsEliminated","isEliminated","Eliminated","eliminated",
    "IsSpectating","isSpectating","Spectating","spectating",
    "IsSpectator","isSpectator","IsOut","isOut","Out",
    "KnockedOut","knockedOut","IsLoser","isLoser",
    "GameOver","gameOver","WaitingForRound","waitingForRound",
    "InLobby","inLobby","IsInactive","isInactive",
    "IsFrozen","isFrozen","IsLocked","isLocked",
}
local ATTR_EXACT_TRUE = {
    "IsAlive","isAlive","is_alive","Alive","alive",
    "InGame","inGame","InRound","inRound","Playing","playing",
    "InMatch","inMatch","Active","active","IsPlayer","isPlayer",
    "CanPlay","canPlay","IsParticipant","isParticipant",
    "CanMove","canMove","IsActive","isActive",
}

local function deveSerFalse(attrName)
    local low = attrName:lower()
    for _, kw in ipairs(ATTR_KW_FALSE) do
        if low:find(kw, 1, true) then return true end
    end
    for _, ex in ipairs(ATTR_EXACT_FALSE) do
        if attrName == ex then return true end
    end
    return false
end
local function deveSerTrue(attrName)
    local low = attrName:lower()
    for _, kw in ipairs(ATTR_KW_TRUE) do
        if low:find(kw, 1, true) then return true end
    end
    for _, ex in ipairs(ATTR_EXACT_TRUE) do
        if attrName == ex then return true end
    end
    return false
end

-- Corrigir todos os atributos de um objeto de uma vez
local function corrigirAttrsObj(obj)
    pcall(function()
        for attr, val in pairs(obj:GetAttributes()) do
            if type(val) == "boolean" then
                if val == true  and deveSerFalse(attr) then
                    pcall(function() obj:SetAttribute(attr, false) end)
                elseif val == false and deveSerTrue(attr) then
                    pcall(function() obj:SetAttribute(attr, true) end)
                end
            elseif type(val) == "number" then
                -- Alguns jogos usam 0/1 em vez de bool
                if val == 1 and deveSerFalse(attr) then
                    pcall(function() obj:SetAttribute(attr, 0) end)
                elseif val == 0 and deveSerTrue(attr) then
                    pcall(function() obj:SetAttribute(attr, 1) end)
                end
            end
        end
    end)
end

local function corrigirAtributos()
    corrigirAttrsObj(lp)
    if lp.Character then
        corrigirAttrsObj(lp.Character)
        -- Corrigir também no Humanoid (alguns jogos colocam attrs lá)
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then corrigirAttrsObj(hum) end
    end
end


-- Watcher reativo: reverte na hora que o jogo muda um atributo
local _attrWatchConns = {}
local function watchAttributes(obj)
    local key = tostring(obj)
    if _attrWatchConns[key] then return end
    _attrWatchConns[key] = obj.AttributeChanged:Connect(function(attr)
        if not S.attrBlock then return end
        local val = obj:GetAttribute(attr)
        if type(val) == "boolean" then
            if val == true  and deveSerFalse(attr) then pcall(function() obj:SetAttribute(attr, false) end) end
            if val == false and deveSerTrue(attr)  then pcall(function() obj:SetAttribute(attr, true)  end) end
        elseif type(val) == "number" then
            if val == 1 and deveSerFalse(attr) then pcall(function() obj:SetAttribute(attr, 0) end) end
            if val == 0 and deveSerTrue(attr)  then pcall(function() obj:SetAttribute(attr, 1) end) end
        end
    end)
end

local function ativarAttrBlock()
    if S.attrBlock then return end; S.attrBlock=true
    watchAttributes(lp)
    if lp.Character then
        watchAttributes(lp.Character)
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then watchAttributes(hum) end
    end
    -- Heartbeat para corrigir em loop (resistir a correções do servidor)
    _conns.attrHB = RunService.Heartbeat:Connect(function()
        if not S.attrBlock then return end
        corrigirAtributos()
    end)
    disconnect("attrChar")
    _conns.attrChar = lp.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        watchAttributes(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then watchAttributes(hum) end
    end)
end
local function desativarAttrBlock()
    S.attrBlock=false
    disconnect("attrHB"); disconnect("attrChar")
    for _, c in pairs(_attrWatchConns) do pcall(function() c:Disconnect() end) end
    _attrWatchConns = {}
end

-- ══════════════════════════════════════════════════
--  TIPO 3A — DESCONGELAR CÂMERA / TELA
-- ══════════════════════════════════════════════════
local function descongelarTela()
    pcall(function()
        camera.CameraType = Enum.CameraType.Custom
        if lp.Character then
            local hum=lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then camera.CameraSubject=hum end
        end
    end)
    for _,sg in ipairs(pgui:GetChildren()) do
        if sg~=screenGui and sg:IsA("ScreenGui") then
            for _,f in ipairs(sg:GetDescendants()) do
                if f:IsA("Frame") and f.BackgroundTransparency<=0.05
                and f.Size==UDim2.new(1,0,1,0) and not ehNosso(f) then
                    pcall(function() f.Visible=false end)
                end
            end
        end
    end
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true) end)
end

local function ativarUnfreezeBlock()
    if S.unfreezeBlock then return end; S.unfreezeBlock=true
    _conns.unfreezeHB=RunService.Heartbeat:Connect(function()
        if not S.unfreezeBlock then return end
        if camera.CameraType~=Enum.CameraType.Custom then
            pcall(function() camera.CameraType=Enum.CameraType.Custom end)
        end
        if lp.Character then
            local hum=lp.Character:FindFirstChildOfClass("Humanoid")
            if hum and camera.CameraSubject~=hum then
                pcall(function() camera.CameraSubject=hum end)
            end
        end
    end)
    descongelarTela()
end
local function desativarUnfreezeBlock()
    S.unfreezeBlock=false; disconnect("unfreezeHB")
end

-- ══════════════════════════════════════════════════
--  TIPO 3B — RESTAURAR PERSONAGEM DELETADO
-- ══════════════════════════════════════════════════
local _lastChar       = nil
local _charDeleteConn = nil
local _lastSpawnPos   = Vector3.new(0, 10, 0)

local function trackPos(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Position.Y > -100 then
        _lastSpawnPos = hrp.Position + Vector3.new(0, 5, 0)
    end
end

local function liberarPersonagem(char)
    if not char then return end
    fixRagdoll(char)   -- reutiliza o utilitário central
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if hrp.Position.Y < -50 or hrp.Position.Y > 5000 then
            pcall(function() hrp.CFrame = CFrame.new(_lastSpawnPos) end)
        end
    end
end

local function monitorarChar(char)
    _lastChar = char
    if _charDeleteConn then pcall(function() _charDeleteConn:Disconnect() end) end

    local posConn = RunService.Heartbeat:Connect(function()
        if char and char.Parent then trackPos(char) end
    end)

    _charDeleteConn = char.AncestryChanged:Connect(function(_, parent)
        if not S.charBlock then posConn:Disconnect(); return end
        if parent == nil then
            posConn:Disconnect()
            task.wait(0.2)
            if lp.Character and lp.Character.Parent then return end
            pcall(function() lp:LoadCharacter() end)
            task.wait(0.5)
            if not lp.Character or not lp.Character.Parent then
                pcall(function() lp:LoadCharacter() end)
            end
        end
    end)
end

local function ativarCharBlock()
    if S.charBlock then return end; S.charBlock=true
    if lp.Character then
        monitorarChar(lp.Character)
        liberarPersonagem(lp.Character)
    end
    disconnect("charB")
    _conns.charB=lp.CharacterAdded:Connect(function(char)
        task.wait(0.15)
        monitorarChar(char)
        liberarPersonagem(char)
        if S.humanoidBlock  then hookHumanoid(char) end
        if S.attrBlock      then corrigirAtributos(); watchAttributes(char) end
        if S.unfreezeBlock  then descongelarTela() end
        if S.guiBlock       then _bloqueados={}; for _,obj in ipairs(pgui:GetDescendants()) do processarObj(obj) end end
    end)

    local _respawnando = false
    disconnect("charHB")
    _conns.charHB=RunService.Heartbeat:Connect(function()
        if not S.charBlock then return end
        local char = lp.Character
        if not char or not char.Parent then
            if not _respawnando then
                _respawnando = true
                task.spawn(function()
                    task.wait(0.8)
                    if not lp.Character or not lp.Character.Parent then
                        pcall(function() lp:LoadCharacter() end)
                        task.wait(0.5)
                        if not lp.Character or not lp.Character.Parent then
                            pcall(function() lp:LoadCharacter() end)
                        end
                    end
                    _respawnando = false
                end)
            end
            return
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Anchored then
            pcall(function() hrp.Anchored = false end)
        end
        -- Checar ragdoll no charHB também
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.FallingDown
            or st == Enum.HumanoidStateType.Ragdoll then
                fixRagdoll(char)
            end
        end
    end)
end
local function desativarCharBlock()
    S.charBlock=false
    disconnect("charB"); disconnect("charHB")
    if _charDeleteConn then pcall(function() _charDeleteConn:Disconnect() end); _charDeleteConn=nil end
end

-- ══════════════════════════════════════════════════
--  TIPO 4 — DESBLOQUEAR CONTROLES
-- ══════════════════════════════════════════════════
local function desbloquearControles()
    local char = lp.Character
    if not char then return end

    fixRagdoll(char)   -- resolve ragdoll + Motor6D + estados de uma vez

    -- Restaurar controles via PlayerModule
    pcall(function()
        local ctrlModule = require(Players.LocalPlayer
            :WaitForChild("PlayerScripts")
            :WaitForChild("PlayerModule"))
        local controls = ctrlModule:GetControls()
        if controls and controls.Enable then controls:Enable() end
    end)
end

local function ativarInputBlock()
    if S.inputBlock then return end; S.inputBlock=true
    desbloquearControles()
    disconnect("inputHB")
    _conns.inputHB = RunService.Heartbeat:Connect(function()
        if not S.inputBlock then return end
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.WalkSpeed == 0 then pcall(function() hum.WalkSpeed = 16 end) end
            if hum.JumpPower  == 0 then pcall(function() hum.JumpPower = 50 end) end
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.FallingDown
            or st == Enum.HumanoidStateType.Ragdoll then
                fixRagdoll(char)
            end
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Anchored then
            pcall(function() hrp.Anchored = false end)
        end
    end)
end
local function desativarInputBlock()
    S.inputBlock=false; disconnect("inputHB")
end

-- ══════════════════════════════════════════════════
--  TIPO 5 — FORÇAR PARTICIPAÇÃO
-- ══════════════════════════════════════════════════
-- TIPO 5: reutiliza o sistema de attrs novo — corrigirAtributos já cobre tudo
-- Mantém só o fix de equipe que ainda é necessário
local ELIM_TEAMS = {
    "eliminated","mortos","dead","spectators","espectadores",
    "lobby","fora","out","waiting","losers","perdedores","ko","knocked",
}
local _teamOriginal = nil
local function ehEquipeElim(team)
    if not team then return false end
    local n = team.Name:lower()
    for _,kw in ipairs(ELIM_TEAMS) do if n:find(kw,1,true) then return true end end
    return false
end
local function corrigirParticipacao()
    corrigirAtributos()  -- reutiliza o sistema novo
    -- Fix de equipe
    local curTeam = lp.Team
    if curTeam and ehEquipeElim(curTeam) then
        local alvo = _teamOriginal
        if not alvo or ehEquipeElim(alvo) then
            for _,t in ipairs(game:GetService("Teams"):GetTeams()) do
                if not ehEquipeElim(t) then alvo=t; break end
            end
        end
        if alvo then pcall(function() lp.Team=alvo end) end
    elseif curTeam and not ehEquipeElim(curTeam) then
        _teamOriginal = curTeam
    end
end

local function ativarParticipBlock()
    if S.participBlock then return end; S.participBlock=true
    _teamOriginal = lp.Team
    corrigirParticipacao()
    disconnect("participHB")
    _conns.participHB=RunService.Heartbeat:Connect(function()
        if not S.participBlock then return end
        corrigirParticipacao()
    end)
end
local function desativarParticipBlock()
    S.participBlock=false; disconnect("participHB")
end

-- ══════════════════════════════════════════════════
--  TIPO 6 — ANTI-ELIMINAÇÃO
--  hookmetamethod já rodou no load (sempre ativo).
--  Toggle controla: GUI killer + watcher de atributos
--  extra + monitoramento de valores no workspace
-- ══════════════════════════════════════════════════
local _elimGuiConns = {}

-- Palavras que matam a GUI se aparecerem no nome OU no texto
local ELIM_GUI_KW = {
    "spectate","spectator","spectat","eliminated","elimination",
    "youreout","youareout","youlose","youlost","playerout",
    "deathscreen","deathui","eliminatedgui","sendtolobby",
    "youaredead","youdie","gameover","knockout",
    "morreu","eliminado","eliminação","espectador","perdeu",
}
local function ehGuiElim(obj)
    local low = obj.Name:lower()
    for _, kw in ipairs(ELIM_GUI_KW) do
        if low:find(kw,1,true) then return true end
    end
    -- Checar texto dos filhos se for ScreenGui/Frame
    if obj:IsA("ScreenGui") or obj:IsA("Frame") then
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                local t = child.Text:lower()
                for _, kw in ipairs(ELIM_GUI_KW) do
                    if t:find(kw,1,true) then return true end
                end
            end
        end
    end
    return false
end
local function matarGuiElim(obj)
    if not obj or ehNosso(obj) then return end
    if not (obj:IsA("ScreenGui") or obj:IsA("Frame") or obj:IsA("BillboardGui")) then return end
    if estaProtegido(obj) then return end
    if ehGuiElim(obj) then
        pcall(function() obj.Enabled=false end)
        pcall(function() obj.Visible=false end)
        pcall(function() obj:Destroy() end)
    end
end

-- Monitorar IntValues/StringValues no workspace que controlam estado
local _valorConns = {}
local VALOR_KW_FALSE = {"dead","elim","spectate","out","loser","ko","morto","eliminado"}
local VALOR_KW_TRUE  = {"alive","playing","active","ingame","participant","vivo","jogando"}
local function watchValoresWorkspace()
    -- Checar Values no player e seus filhos
    local function scanValues(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            local n = obj.Name:lower()
            if obj:IsA("BoolValue") then
                local c = obj.Changed:Connect(function(v)
                    if not S.antiElim then return end
                    for _, kw in ipairs(VALOR_KW_FALSE) do
                        if n:find(kw,1,true) and v==true then
                            pcall(function() obj.Value=false end); return
                        end
                    end
                    for _, kw in ipairs(VALOR_KW_TRUE) do
                        if n:find(kw,1,true) and v==false then
                            pcall(function() obj.Value=true end); return
                        end
                    end
                end)
                table.insert(_valorConns, c)
            elseif obj:IsA("IntValue") or obj:IsA("NumberValue") then
                -- Alguns jogos usam 0/1
                local c = obj.Changed:Connect(function(v)
                    if not S.antiElim then return end
                    for _, kw in ipairs(VALOR_KW_FALSE) do
                        if n:find(kw,1,true) and v==1 then
                            pcall(function() obj.Value=0 end); return
                        end
                    end
                    for _, kw in ipairs(VALOR_KW_TRUE) do
                        if n:find(kw,1,true) and v==0 then
                            pcall(function() obj.Value=1 end); return
                        end
                    end
                end)
                table.insert(_valorConns, c)
            end
        end
    end
    scanValues(lp)
    -- Quando novos valores forem adicionados ao player
    local c = lp.ChildAdded:Connect(function(obj)
        if not S.antiElim then return end
        task.defer(function() scanValues(lp) end)
    end)
    table.insert(_valorConns, c)
end

local function ativarAntiElim()
    if S.antiElim then return end; S.antiElim=true

    -- Matar GUIs de elim já existentes
    for _,obj in ipairs(pgui:GetDescendants()) do matarGuiElim(obj) end

    -- Monitorar novas GUIs
    local c1 = pgui.DescendantAdded:Connect(function(obj)
        if not S.antiElim then return end
        task.defer(function() matarGuiElim(obj) end)
    end)
    table.insert(_elimGuiConns, c1)

    -- Monitorar Values no player (BoolValue/IntValue de eliminação)
    watchValoresWorkspace()
end
local function desativarAntiElim()
    S.antiElim=false
    for _,c in ipairs(_elimGuiConns) do pcall(function() c:Disconnect() end) end
    _elimGuiConns={}
    for _,c in ipairs(_valorConns) do pcall(function() c:Disconnect() end) end
    _valorConns={}
end

-- ══════════════════════════════════════════════════
--  COMPONENTES DA GUI
-- ══════════════════════════════════════════════════
local ti=TweenInfo.new(0.17,Enum.EasingStyle.Quad)

local function criarToggle(ordem,ico,titulo,desc,callback)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,50); row.BackgroundColor3=Color3.fromRGB(13,13,22)
    row.BorderSizePixel=0; row.LayoutOrder=ordem; row.Parent=content
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local iL=Instance.new("TextLabel"); iL.Size=UDim2.new(0,26,1,0); iL.Position=UDim2.new(0,7,0,0)
    iL.BackgroundTransparency=1; iL.Text=ico; iL.TextSize=18; iL.Font=Enum.Font.Gotham; iL.Parent=row

    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-80,0,17); lb.Position=UDim2.new(0,36,0,9)
    lb.BackgroundTransparency=1; lb.Text=titulo; lb.TextColor3=Color3.fromRGB(215,228,238)
    lb.TextSize=11; lb.Font=Enum.Font.GothamBold; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=row

    local sb=Instance.new("TextLabel"); sb.Size=UDim2.new(1,-80,0,13); sb.Position=UDim2.new(0,36,0,27)
    sb.BackgroundTransparency=1; sb.Text=desc; sb.TextColor3=Color3.fromRGB(65,82,98)
    sb.TextSize=9; sb.Font=Enum.Font.Gotham; sb.TextXAlignment=Enum.TextXAlignment.Left; sb.Parent=row

    local tr=Instance.new("Frame"); tr.Size=UDim2.new(0,40,0,21); tr.Position=UDim2.new(1,-48,0.5,-10.5)
    tr.BackgroundColor3=Color3.fromRGB(32,32,46); tr.BorderSizePixel=0; tr.Parent=row
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)

    local th=Instance.new("Frame"); th.Size=UDim2.new(0,17,0,17); th.Position=UDim2.new(0,2,0.5,-8.5)
    th.BackgroundColor3=Color3.fromRGB(85,85,105); th.BorderSizePixel=0; th.Parent=tr
    Instance.new("UICorner",th).CornerRadius=UDim.new(1,0)

    local on=false
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=row
    btn.MouseButton1Click:Connect(function()
        on=not on
        TweenService:Create(tr,ti,{BackgroundColor3=on and Color3.fromRGB(0,195,135) or Color3.fromRGB(32,32,46)}):Play()
        TweenService:Create(th,ti,{
            BackgroundColor3=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(85,85,105),
            Position=on and UDim2.new(0,21,0.5,-8.5) or UDim2.new(0,2,0.5,-8.5)
        }):Play()
        callback(on)
    end)
end

local function criarBotao(ordem,ico,titulo,desc,callback)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,50); row.BackgroundColor3=Color3.fromRGB(13,13,22)
    row.BorderSizePixel=0; row.LayoutOrder=ordem; row.Parent=content
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local iL=Instance.new("TextLabel"); iL.Size=UDim2.new(0,26,1,0); iL.Position=UDim2.new(0,7,0,0)
    iL.BackgroundTransparency=1; iL.Text=ico; iL.TextSize=18; iL.Font=Enum.Font.Gotham; iL.Parent=row

    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-80,0,17); lb.Position=UDim2.new(0,36,0,9)
    lb.BackgroundTransparency=1; lb.Text=titulo; lb.TextColor3=Color3.fromRGB(215,228,238)
    lb.TextSize=11; lb.Font=Enum.Font.GothamBold; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=row

    local sb=Instance.new("TextLabel"); sb.Size=UDim2.new(1,-80,0,13); sb.Position=UDim2.new(0,36,0,27)
    sb.BackgroundTransparency=1; sb.Text=desc; sb.TextColor3=Color3.fromRGB(65,82,98)
    sb.TextSize=9; sb.Font=Enum.Font.Gotham; sb.TextXAlignment=Enum.TextXAlignment.Left; sb.Parent=row

    local dot=Instance.new("TextLabel"); dot.Size=UDim2.new(0,32,0,32); dot.Position=UDim2.new(1,-40,0.5,-16)
    dot.BackgroundTransparency=1; dot.Text="▶"; dot.TextColor3=Color3.fromRGB(0,195,135)
    dot.TextSize=16; dot.Font=Enum.Font.GothamBold; dot.Parent=row

    local done=false
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=row
    btn.MouseButton1Click:Connect(function()
        if done then return end; done=true
        dot.Text="⏳"; dot.TextColor3=Color3.fromRGB(255,200,0)
        task.spawn(function()
            callback()
            task.wait(2)
            dot.Text="✓"; dot.TextColor3=Color3.fromRGB(0,255,136)
        end)
    end)
end

local function criarSep(ordem, texto)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,18); f.BackgroundTransparency=1
    f.LayoutOrder=ordem; f.Parent=content
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,1,0)
    l.BackgroundTransparency=1; l.Text=texto; l.TextColor3=Color3.fromRGB(0,150,100)
    l.TextSize=9; l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=f
end

-- ── MONTAR TOGGLES ────────────────────────────────
criarSep(0,  "  TELAS DE MORTE")
criarToggle(1,"🚫","Bloquear GUI de Morte","Remove telas: lobby, regenerar, congelado",function(on)
    if on then ativarGuiBlock() else desativarGuiBlock() end
end)

criarSep(2,  "  HUMANOID E ATRIBUTOS")
criarToggle(3,"❤️","Bloquear Morte (Humanoid)","Impede Health zerar + Dead + Ragdoll/Preso",function(on)
    if on then ativarHumanoidBlock() else desativarHumanoidBlock() end
end)
criarToggle(4,"🏷️","Corrigir Atributos de Morto","Reseta IsAlive/IsEliminated/IsDead/etc",function(on)
    if on then ativarAttrBlock() else desativarAttrBlock() end
end)

criarSep(5,  "  TELA CONGELADA E PERSONAGEM")
criarToggle(6,"🎥","Descongelar Câmera/Tela","Restaura câmera e remove overlay freeze",function(on)
    if on then ativarUnfreezeBlock() else desativarUnfreezeBlock() end
end)
criarToggle(7,"👤","Restaurar Personagem","Força respawn se char for deletado",function(on)
    if on then ativarCharBlock() else desativarCharBlock() end
end)

criarSep(8,  "  CONTROLES E PARTICIPAÇÃO")
criarToggle(9,"🕹️","Desbloquear Controles","Restaura WalkSpeed, Jump, Motor6D e ragdoll",function(on)
    if on then ativarInputBlock() else desativarInputBlock() end
end)
criarToggle(10,"🎮","Forçar Participação","Corrige eliminado/espectador, fixa equipe",function(on)
    if on then ativarParticipBlock() else desativarParticipBlock() end
end)

criarSep(11, "  ANTI-ELIMINAÇÃO")
criarToggle(12,"🛡️","Anti-Eliminação","Bloqueia remotes + GUIs de spectator/elim",function(on)
    if on then ativarAntiElim() else desativarAntiElim() end
end)

criarSep(13, "  SQUIDGAME X")
criarToggle(14,"⚰️","Fix SquidGame X","Recupera do caixão, invisível e preso no chão",function(on)
    if on then ativarSquidFix() else desativarSquidFix() end
end)

criarSep(15, "  REVIVE")
criarToggle(16,"⚡","Auto Revive Instantâneo","Dispara revive ao detectar morte (< 1 frame)",function(on)
    S.autoRevive=on
    if on then task.spawn(function()
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/hQLWaCQd"))() end)
    end) end
end)
criarBotao(17,"🔄","Revive Manual","Executa o script de revive agora",function()
    local ok,err=pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/hQLWaCQd"))()
    end)
    if not ok then warn("[DBPro] Erro revive: "..tostring(err)) end
end)

-- Status
local stLbl=Instance.new("TextLabel")
stLbl.Size=UDim2.new(1,-18,0,13); stLbl.Position=UDim2.new(0,9,1,-16)
stLbl.BackgroundTransparency=1; stLbl.Text="Hook ativo • Ative os toggles • SquidGame X: toggle ⚰️"
stLbl.TextColor3=Color3.fromRGB(40,60,50); stLbl.TextSize=9
stLbl.Font=Enum.Font.Gotham; stLbl.TextXAlignment=Enum.TextXAlignment.Left; stLbl.Parent=main

-- ══════════════════════════════════════════════════
--  DRAG
-- ══════════════════════════════════════════════════
local function makeDrag(handle,target)
    local drag,ds,dp=false,nil,nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=inp.Position; dp=target.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            local d=inp.Position-ds
            target.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

makeDrag(titleBar,main)
makeDrag(floatBtn,floatBtn)

print("[DeathBlocker PRO + Anti-Eliminação] Carregado! Hook ativo. Para SquidGame X: ative o toggle ⚰️")
