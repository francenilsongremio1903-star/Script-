--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║        GOD MODE FUSION ULTRA v1.0                               ║
    ║   GodMode ULTIMATE v22 + Anti-Eliminação ULTRA UNIDOS          ║
    ║                                                                  ║
    ║  DUAL ENGINE: Clone Swap + Character Repair                     ║
    ║  TRIPLE SHIELD: Remote Block + GUI Neutralizer + Attr Guard     ║
    ║  FE-Safe · Delta/Arceus X/KRNL/Synapse                         ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════
-- LOADSTRING ORIGINAL (GodMode v22)
-- ════════════════════════════════════════════
pcall(function()
    loadstring(game:HttpGet("https://pastebin.com/raw/hQLWaCQd"))()
end)
task.wait(0.5)

-- ════════════════════════════════════════════
-- CONFIGURAÇÕES GLOBAIS
-- ════════════════════════════════════════════
local CFG = {
    DEBUG             = true,
    REPAIR_INTERVAL   = 0.1,
    REVIVE_DELAY      = 5,
    TELEPORT_MAX_Y    = 300,
    TELEPORT_MAX_DIST = 200,
    ANTI_SPECTATE     = true,
    ANTI_TEAM         = true,
    ANTI_RAGDOLL      = true,
    ANTI_GUI          = true,
    ANTI_TELEPORT     = true,
    -- Novos do Anti-Eliminação
    BLOCK_REMOTES     = true,   -- bloqueia RemoteEvents de eliminação
    PROTECT_ATTRS     = true,   -- reverte atributos de morte
    REGEN_INTERVAL    = 0.5,    -- intervalo de regeneração de HP
}

-- ════════════════════════════════════════════
-- SERVIÇOS E VARIÁVEIS GLOBAIS
-- ════════════════════════════════════════════
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local lp               = Players.LocalPlayer
local playerGui        = lp:WaitForChild("PlayerGui")

local active           = true
local isDead           = false
local swapping         = false
local rebuilding       = false
local useRepairMode    = false

local savedPos         = Vector3.new(0, 5, 0)
local savedWalkSpeed   = 16
local lastValidPos     = Vector3.new(0, 5, 0)
local savedTeam        = lp.Team

local charClone        = nil
local diedConnections  = {}

-- ════════════════════════════════════════════
-- LOG HELPER
-- ════════════════════════════════════════════
local function log(msg)
    if CFG.DEBUG then
        print(string.format("[FUSION v1] %s", msg))
    end
end

-- ══════════════════════════════════════════════════════════════
-- BLOQUEADOR DE REMOTOS — RAINBOW FRIENDS + GENÉRICO
-- Remotes ESPECÍFICOS do jogo identificados pelo relatório
-- ══════════════════════════════════════════════════════════════

-- Remotes pelo NOME EXATO (genérico, qualquer jogo)
local REMOTE_EXACT_BLOCK = {
    "eliminate","eliminated","eliminateplayer","eliminatelocal","elim",
    "eliminar","eliminado","setdead","markdead","playerdead","isdead",
    "setspectator","sendtospectate","spectatelocal","sendtolobby",
    "kicktolobby","playerout","setdefeated","playerdefeated",
    "seteliminated","playereliminated","playerlost","setlost",
    "removeplayer","die","died","playerdie",
    -- ★ RAINBOW FRIENDS — remotes de morte/eliminação confirmados:
    "onSurvivorDeath",      -- morte do survivor → principal remote de eliminação
    "PlayerDied",           -- GameHandler_cl → dispara ao morrer
    "AttackCharacter",      -- Purple monster ataca e elimina
    "PlayerScaredByMonster",-- monster assusta/captura → pode triggerar elim
    "ShowFallen",           -- mostra tela de "caiu"/morreu
    "LoadFallen",           -- carrega dados de quem morreu
    "CacheFallenData",      -- cacheia dados do morto
    "UpdateRespawnInfo",    -- atualiza info de respawn (indica que morreu)
    "RequestBuyback",       -- tela de revive/buyback (pós-morte)
    "finishcurrentnight",   -- termina a noite = pode eliminar sobreviventes
}

-- Remotes PELO PATH — bloqueia qualquer remote dentro dessas pastas
local BLOCK_BY_PATH = {
    "NightRecapInterface_cl", -- tudo aqui é recap de morte
    "Spectate_cl",            -- sistema de spectate
}

-- Combinação: palavra de morte + referência a player no mesmo nome
local REMOTE_COMBO_WORDS = {
    "dead","death","eliminate","elim","spectate","defeat","lost","fallen","survivor",
}

local function shouldBlockRemote(self, name)
    local low = name:lower()

    -- 1. Match exato ou prefixo/sufixo
    for _, exact in ipairs(REMOTE_EXACT_BLOCK) do
        local el = exact:lower()
        if low == el or low:sub(1,#el) == el or low:sub(-#el) == el then
            return true, exact
        end
    end

    -- 2. Bloqueia pelo path da instância
    local ok, fullPath = pcall(function() return self:GetFullName() end)
    if ok and fullPath then
        for _, pathKw in ipairs(BLOCK_BY_PATH) do
            if fullPath:find(pathKw, 1, true) then
                return true, "path:"..pathKw
            end
        end
    end

    -- 3. Combinação: palavra de morte + referência a player/survivor no mesmo nome
    local hasRef = low:find("player") or low:find("local") or low:find("char") or low:find("survivor")
    if hasRef then
        for _, combo in ipairs(REMOTE_COMBO_WORDS) do
            if low:find(combo, 1, true) then
                return true, combo.."+ref"
            end
        end
    end

    return false
end

if CFG.BLOCK_REMOTES then
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self:IsA("UnreliableRemoteEvent") then
                    local blocked, kw = shouldBlockRemote(self, self.Name)
                    if blocked then
                        log("🚫 REMOTE BLOQUEADO: " .. self.Name .. " [" .. kw .. "]")
                        return nil
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
    log("✓ Bloqueador Rainbow Friends + Genérico ativo")
end

-- ════════════════════════════════════════════
-- DETECÇÃO DE MODO
-- ════════════════════════════════════════════
local function detectMode()
    if not Players.CharacterAutoLoads then
        useRepairMode = true
        log("⚙️ Modo: CHARACTER REPAIR (server-authoritative)")
        return
    end
    local suspiciousRemotes = {"die","death","dead","eliminate","spectate","revive","killed"}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, kw in ipairs(suspiciousRemotes) do
                if name:find(kw) then
                    useRepairMode = true
                    log("⚙️ Modo: CHARACTER REPAIR (Remote suspeito: " .. obj.Name .. ")")
                    return
                end
            end
        end
    end
    useRepairMode = false
    log("⚙️ Modo: CLONE SWAP (jogo genérico)")
end

-- ════════════════════════════════════════════
-- ENGINE 1: CLONE SWAP
-- ════════════════════════════════════════════
local function prepareCleanClone(source)
    if not source then return nil end
    local clone = nil
    pcall(function()
        clone = source:Clone()
        clone.Name = lp.Name
        for _, part in ipairs(clone:GetDescendants()) do
            if part:IsA("LocalScript") or part:IsA("Script") then
                part:Destroy(); continue
            end
            if part:IsA("BasePart") then
                part.Anchored     = false
                part.CanCollide   = true
                part.Transparency = 0
                part.Velocity     = Vector3.zero
                part.RotVelocity  = Vector3.zero
            end
            if part:IsA("Motor6D") then part.Enabled = true end
            if part:IsA("BallSocketConstraint") or part:IsA("HingeConstraint") then
                local n = part.Name:lower()
                if n:find("ragdoll") or n:find("rigid") or n:find("ball") then
                    part.Enabled = false
                end
            end
        end
        local hum = clone:FindFirstChildOfClass("Humanoid")
        if hum then
            local maxHp = hum.MaxHealth
            if maxHp == math.huge or maxHp <= 0 then maxHp = 100 end
            hum.Health        = maxHp
            hum.WalkSpeed     = savedWalkSpeed
            hum.JumpPower     = 50
            hum.PlatformStand = false
            hum.Sit           = false
            hum.AutoRotate    = true
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
        local root = clone:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame      = CFrame.new(savedPos)
            root.Velocity    = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
    end)
    return clone
end

local applyProtections
local reviveClean
local instantSwap

instantSwap = function(deadChar)
    if swapping or rebuilding then return end
    swapping = true
    isDead   = true
    log("⚡ CLONE SWAP iniciado...")
    local clone = nil
    if charClone then
        clone = prepareCleanClone(charClone)
        pcall(function() charClone:Destroy() end)
        charClone = nil
    end
    if not clone then clone = prepareCleanClone(deadChar) end
    if not clone then swapping = false; isDead = false; return end
    pcall(function()
        clone.Parent = workspace
        lp.Character = clone
        local cam = workspace.CurrentCamera
        if cam then
            cam.CameraSubject = clone:FindFirstChildOfClass("Humanoid")
                or clone:FindFirstChild("HumanoidRootPart")
            cam.CameraType = Enum.CameraType.Follow
        end
        local hum = clone:FindFirstChildOfClass("Humanoid")
        if hum then applyProtections(clone, hum) end
    end)
    log("✅ Clone ativo — revive em " .. CFG.REVIVE_DELAY .. "s")
    task.delay(CFG.REVIVE_DELAY, function()
        if isDead and active then
            isDead   = false
            swapping = false
            reviveClean(clone)
        end
    end)
    task.wait(0.5)
    swapping = false
end

reviveClean = function(deadChar)
    if rebuilding then return end
    rebuilding = true
    isDead     = false
    swapping   = false
    local nativeOk = false
    pcall(function() lp:LoadCharacter(); nativeOk = true end)
    if nativeOk then
        local waited = 0
        while waited < 2 do
            task.wait(0.1); waited += 0.1
            local c = lp.Character
            if c and c ~= deadChar then
                task.wait(0.3)
                pcall(function()
                    local root = c:FindFirstChild("HumanoidRootPart")
                    if root then root.CFrame = CFrame.new(savedPos) end
                end)
                rebuilding = false
                log("✅ Reviveu (nativo)!")
                return
            end
        end
    end
    local clone = prepareCleanClone(deadChar)
    if clone then
        pcall(function()
            clone.Parent = workspace
            lp.Character = clone
            local cam = workspace.CurrentCamera
            if cam then cam.CameraSubject = clone:FindFirstChildOfClass("Humanoid")
                or clone:FindFirstChild("HumanoidRootPart") end
            local hum = clone:FindFirstChildOfClass("Humanoid")
            if hum then applyProtections(clone, hum) end
        end)
        log("✅ Reviveu (clone fallback)!")
    else
        pcall(function() lp:LoadCharacter() end)
    end
    task.wait(1)
    rebuilding = false
end

-- ════════════════════════════════════════════
-- ENGINE 2: CHARACTER REPAIR
-- ════════════════════════════════════════════
local RepairEngine = {}

function RepairEngine.heartbeatRepair()
    RunService.Heartbeat:Connect(function()
        if not active or not useRepairMode then return end
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if hum.Health <= 5 then
            hum.Health = hum.MaxHealth > 0 and hum.MaxHealth * 0.5 or 50
        end
        if hum.PlatformStand then hum.PlatformStand = false end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum.Health = hum.MaxHealth > 0 and hum.MaxHealth or 100
        elseif state == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

function RepairEngine.periodicRepair()
    task.spawn(function()
        while active do
            task.wait(2)
            if not useRepairMode then continue end
            local char = lp.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then continue end
            if hum.Health <= 10 then
                hum.Health = hum.MaxHealth * 0.8
                log("HP reparado: " .. tostring(math.floor(hum.Health)))
            end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Anchored then
                    part.Anchored = false
                end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.AssemblyLinearVelocity.Magnitude
                if vel > 100 then
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
                if hrp.Position.Y < CFG.TELEPORT_MAX_Y then
                    lastValidPos = hrp.Position
                end
            end
        end
    end)
end

function RepairEngine.setup()
    RepairEngine.heartbeatRepair()
    RepairEngine.periodicRepair()
    lp.CharacterAdded:Connect(function()
        task.wait(1)
        if useRepairMode then
            local char = lp.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth > 0 and hum.MaxHealth or 100
                hum.PlatformStand = false
            end
        end
    end)
    log("✓ Character Repair Engine ativo")
end

-- ══════════════════════════════════════════════════════════════
-- PROTEÇÃO DO HUMANOID (Anti-Eliminação ULTRA — aprimorada)
-- Integrada ao applyProtections do GodMode
-- ══════════════════════════════════════════════════════════════
applyProtections = function(char, hum)
    if not hum then return end
    local maxHp = hum.MaxHealth
    if maxHp == math.huge or maxHp <= 0 then maxHp = 100 end

    -- CAMADA 1: HP intercept
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not active then return end
        pcall(function()
            if hum.Health <= 1 and not isDead then
                -- Restaura IMEDIATAMENTE antes do jogo processar a morte
                hum.Health = maxHp
                hum:ChangeState(Enum.HumanoidStateType.Running)
                if not useRepairMode then
                    task.spawn(function() instantSwap(char) end)
                end
            end
        end)
    end)

    -- CAMADA 1b: Trava HP no Heartbeat — nunca deixa cair abaixo de 10%
    -- Isso pega dano que acontece entre frames do HealthChanged
    RunService.Heartbeat:Connect(function()
        if not active or isDead then return end
        if not (hum and hum.Parent) then return end
        pcall(function()
            local hp = hum.Health
            local mp = hum.MaxHealth
            if mp <= 0 or mp == math.huge then mp = 100 end
            if hp < mp * 0.1 then  -- abaixo de 10% → restaura full
                hum.Health = mp
            end
            -- Nunca estado Dead
            if hum:GetState() == Enum.HumanoidStateType.Dead then
                hum.Health = mp
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end)

    -- CAMADA 2: MaxHealth nunca 0 (Anti-Elim)
    hum:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        if hum.MaxHealth <= 0 then
            hum.MaxHealth = 100
            hum.Health    = 100
        end
    end)

    -- CAMADA 3: PlatformStand
    hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if not active then return end
        pcall(function()
            if hum.PlatformStand then
                hum.PlatformStand = false
                if not useRepairMode and not isDead then
                    task.spawn(function() instantSwap(char) end)
                end
            end
        end)
    end)

    -- CAMADA 4: WalkSpeed nunca 0 (Anti-Elim)
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
    end)

    -- CAMADA 5: JumpPower nunca 0 (Anti-Elim)
    hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if hum.JumpPower == 0 then hum.JumpPower = 50 end
    end)

    -- CAMADA 6: StateChanged
    hum.StateChanged:Connect(function(_, new)
        if not active then return end
        if new == Enum.HumanoidStateType.Dead or
           new == Enum.HumanoidStateType.Physics then
            if useRepairMode then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                if hum.Health <= 0 then hum.Health = maxHp end
            elseif not isDead then
                task.spawn(function() instantSwap(char) end)
            end
        end
    end)

    -- CAMADA 7: Motor6D (Clone Swap)
    if not useRepairMode then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") then
                obj:GetPropertyChangedSignal("Part1"):Connect(function()
                    if not active or isDead then return end
                    if obj.Part1 == nil then
                        task.spawn(function() instantSwap(char) end)
                    end
                end)
            end
        end
    end

    -- CAMADA 8: Anti-Ragdoll BallSocket dinâmico
    char.DescendantAdded:Connect(function(desc)
        if not active then return end
        if desc:IsA("BallSocketConstraint") or desc:IsA("HingeConstraint") then
            local pName = (desc.Parent and desc.Parent.Name or ""):lower()
            if pName:match("torso") or pName:match("arm") or
               pName:match("leg") or pName:match("head") then
                task.delay(0, function() pcall(function() desc:Destroy() end) end)
                log("! BallSocket ragdoll removido")
            end
        end
    end)

    -- CAMADA 9: Bloquear animações de morte
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        local DEATH_ANIMS = {
            "die","death","dead","fall","collapse","eliminate",
            "eliminated","defeat","fail","ragdoll","stun","knock","down"
        }
        animator.AnimationPlayed:Connect(function(track)
            if not track.Animation then return end
            local n = track.Animation.Name:lower()
            for _, kw in ipairs(DEATH_ANIMS) do
                if n:match(kw) then
                    track:Stop(0)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    log("! :Death animation blocked".. n)
                    return
                end
            end
        end)
    end

    -- CAMADA 10: Backup loop (Anti-Elim REGEN + GodMode backup)
    task.spawn(function()
        while hum and hum.Parent and active do
            pcall(function()
                -- Regeneração total (Anti-Elim)
                if hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
                -- Backup swap se HP zerou
                if hum.Health <= 0 and not isDead then
                    hum.Health = 1
                    if useRepairMode then
                        hum.Health = maxHp * 0.5
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    else
                        task.spawn(function() instantSwap(char) end)
                    end
                end
            end)
            task.wait(CFG.REGEN_INTERVAL)
        end
    end)

    log("✓ 10 camadas de proteção aplicadas no Humanoid")
end

-- ══════════════════════════════════════════════════════════════
-- PROTEÇÃO DE ATRIBUTOS (Anti-Eliminação ULTRA)
-- ══════════════════════════════════════════════════════════════
local BAD_ATTRS = {
    "dead","eliminated","out","spectator","espectador","eliminado",
    "morto","fora","perdeu","lose","defeated","derrotado","caught",
    "captured","tagged","frozen","stunned","iseliminated","isout",
}

local function watchAttrs(obj)
    if not CFG.PROTECT_ATTRS then return end
    pcall(function()
        obj.AttributeChanged:Connect(function(attr)
            local low = attr:lower()
            for _, bad in ipairs(BAD_ATTRS) do
                if low:find(bad, 1, true) then
                    local val = obj:GetAttribute(attr)
                    if val == true or val == "true" or val == "eliminated"
                    or val == "dead" or val == "caught" or val == "captured" then
                        task.wait(0.05)
                        obj:SetAttribute(attr, false)
                        log("🔄 Atributo revertido: " .. attr)
                    end
                    break
                end
            end
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- ANTI-ELIMINAÇÃO POR ANIMAÇÃO DE NPC
-- ★ Rainbow Friends: Blue, Green, Purple, Orange, Cyan, Red
-- ══════════════════════════════════════════════════════════════
local function setupAntiCatch()
    local CATCH_ANIM_KW = {
        -- Genérico
        "catch","caught","grab","grabbed","tag","tagged",
        "eliminate","capture","captured","arrest","freeze",
        "frozen","stun","stunned","kill","killed","die","death",
        -- ★ Rainbow Friends específico
        "looky",        -- Looky (mascote) pega o player
        "jumpscare",    -- jumpscare = captura nos monsters
        "attack",       -- AttackCharacter (Purple)
        "scare",        -- PlayerScaredByMonster
        "eaten",        -- Orange come o player
        "swallow",      -- Orange engole
        "fall",         -- "fallen" survivor
        "fallen",
        "drag",         -- arrastar para eliminar
        "pickup",       -- pegar o player
        "carry",        -- carregar (Orange)
        "devour",       -- devorar
    }

    -- Monitora animações que RODAM NO PERSONAGEM DO PLAYER
    -- (jogos colocam animação de "ser pego" no próprio char)
    local function watchCharAnims(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return end

        animator.AnimationPlayed:Connect(function(track)
            if not track.Animation then return end
            local animName = track.Animation.Name:lower()
            local animId   = tostring(track.Animation.AnimationId):lower()

            for _, kw in ipairs(CATCH_ANIM_KW) do
                if animName:find(kw, 1, true) or animId:find(kw, 1, true) then
                    -- Para a animação imediatamente
                    track:Stop(0)
                    -- Garante que o estado continua vivo
                    pcall(function()
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                        hum.Health = hum.MaxHealth > 0 and hum.MaxHealth or 100
                        hum.PlatformStand = false
                        hum.Sit = false
                    end)
                    -- Reverte qualquer atributo que possa ter sido setado junto
                    task.delay(0.1, function()
                        for _, attr in ipairs(char:GetAttributes()) do
                            watchAttrs(char) -- re-aplica proteção
                        end
                        watchAttrs(lp)
                    end)
                    log("🛡️ Animação de captura/elim bloqueada: " .. animName)
                    return
                end
            end
        end)
    end

    -- Aplica no char atual e futuros
    if lp.Character then
        task.spawn(function() watchCharAnims(lp.Character) end)
    end
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        watchCharAnims(char)
    end)

    -- ── Detecta NPC chegando perto e tentando "pegar" ──
    -- Quando NPC toca o HumanoidRootPart, verifica se o jogo
    -- tentou mudar status logo depois (janela de 0.5s)
    local function watchNPCTouch(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end

        hrp.Touched:Connect(function(hit)
            -- Só se for parte de um NPC (não do próprio player)
            local model = hit:FindFirstAncestorOfClass("Model")
            if not model then return end
            if model == char then return end
            -- Verifica se o model tem Humanoid (é NPC ou outro player)
            local npcHum = model:FindFirstChildOfClass("Humanoid")
            if not npcHum then return end

            -- Janela de proteção: nos próximos 0.3s reverte qualquer mudança de status
            task.delay(0.05, function()
                pcall(function()
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        if hum.Health <= 0 then
                            hum.Health = hum.MaxHealth > 0 and hum.MaxHealth or 100
                        end
                        if hum.PlatformStand then hum.PlatformStand = false end
                    end
                end)
                -- Reverte atributos que possam ter mudado no toque
                for attrName, val in pairs(lp:GetAttributes()) do
                    local low = attrName:lower()
                    for _, bad in ipairs(BAD_ATTRS) do
                        if low:find(bad, 1, true) and (val == true or val == "eliminated" or val == "dead") then
                            lp:SetAttribute(attrName, false)
                            log("🛡️ Atributo revertido após toque de NPC: " .. attrName)
                        end
                    end
                end
                if char and char.Parent then
                    for attrName, val in pairs(char:GetAttributes()) do
                        local low = attrName:lower()
                        for _, bad in ipairs(BAD_ATTRS) do
                            if low:find(bad, 1, true) and (val == true or val == "eliminated" or val == "dead") then
                                char:SetAttribute(attrName, false)
                            end
                        end
                    end
                end
            end)
        end)
    end

    if lp.Character then
        task.spawn(function() watchNPCTouch(lp.Character) end)
    end
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        watchNPCTouch(char)
    end)

    -- ══════════════════════════════════════════════════════════
    -- ★ RAINBOW FRIENDS — Proteção de valores do Survivor
    -- O jogo guarda se o player está vivo em IntValues/BoolValues
    -- dentro do próprio Player ou em pastas do jogo
    -- ══════════════════════════════════════════════════════════
    local RF_BAD_VALUES = {
        -- nomes de valores que o Rainbow Friends usa para marcar morte/elim
        "alive","survivor","isalive","issurvivor","ingame","playing",
        "fallen","isdead","caught","grabbed","looky",
    }

    local function revertRFValue(child)
        local n = child.Name:lower()
        local relevant = false
        for _, kw in ipairs(RF_BAD_VALUES) do
            if n == kw or n:find(kw, 1, true) then relevant = true; break end
        end
        if not relevant then return end

        child:GetPropertyChangedSignal("Value"):Connect(function()
            local v = child.Value
            -- Se virou false/0/"dead"/"fallen" → reverter para vivo
            local shouldFlip = false
            if child:IsA("BoolValue") and v == false then shouldFlip = true
            elseif child:IsA("IntValue") and v == 0 then shouldFlip = true
            elseif child:IsA("StringValue") then
                local vl = v:lower()
                if vl == "dead" or vl == "fallen" or vl == "eliminated"
                or vl == "caught" or vl == "" then shouldFlip = true end
            end

            if shouldFlip then
                task.wait(0.05)
                if child:IsA("BoolValue") then child.Value = true
                elseif child:IsA("IntValue") then child.Value = 1
                elseif child:IsA("StringValue") then child.Value = "alive"
                end
                log("🌈 [RF] Valor survivor revertido: " .. child.Name)
            end
        end)
    end

    -- Monitora valores no Player
    for _, child in ipairs(lp:GetChildren()) do
        pcall(function() revertRFValue(child) end)
    end
    lp.ChildAdded:Connect(function(child)
        pcall(function() revertRFValue(child) end)
    end)

    -- Monitora também valores que o jogo coloca dentro do Character
    local function watchCharValues(char)
        for _, child in ipairs(char:GetChildren()) do
            pcall(function() revertRFValue(child) end)
        end
        char.ChildAdded:Connect(function(child)
            pcall(function() revertRFValue(child) end)
        end)
    end
    if lp.Character then task.spawn(function() watchCharValues(lp.Character) end) end
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        watchCharValues(char)
    end)

    log("✓ Anti-Eliminação NPC/Animação + Rainbow Friends ativo")
end

-- ════════════════════════════════════════════
-- MÓDULO: ANTI-SPECTATE + ANTI-TEAM
-- ════════════════════════════════════════════
local AntiSpectate = {}

function AntiSpectate.setupTeleport()
    if not CFG.ANTI_TELEPORT then return end
    lp.CharacterAdded:Connect(function(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        lastValidPos = hrp.Position
        task.spawn(function()
            while char and char.Parent do
                task.wait(0.5)
                local c = lp.Character
                if not c then break end
                local r = c:FindFirstChild("HumanoidRootPart")
                if not r then break end
                local pos   = r.Position
                local delta = (pos - lastValidPos).Magnitude
                if pos.Y > CFG.TELEPORT_MAX_Y or delta > CFG.TELEPORT_MAX_DIST then
                    r.CFrame = CFrame.new(lastValidPos + Vector3.new(0,3,0))
                    log("! Teleporte para spectate bloqueado")
                else
                    lastValidPos = pos
                end
            end
        end)
    end)
    log("✓ Anti-Teleporte ativo")
end

function AntiSpectate.setupTeam()
    if not CFG.ANTI_TEAM then return end
    local SPECTATE_TEAMS = {"spectat","elimina","dead","observer","defeat","viewer","ghost"}
    local teamLock = false
    lp:GetPropertyChangedSignal("Team"):Connect(function()
        if teamLock then return end
        local newTeam = lp.Team
        if not newTeam then return end
        local n = newTeam.Name:lower()
        for _, kw in ipairs(SPECTATE_TEAMS) do
            if n:match(kw) then
                teamLock = true
                lp.Team  = savedTeam
                teamLock = false
                log("! Team bloqueado: " .. newTeam.Name)
                return
            end
        end
        savedTeam = newTeam
    end)
    log("✓ Anti-Team Change ativo")
end

function AntiSpectate.setupValues()
    local STATUS_KEYS = {"alive","status","state","ingame","eliminated","spectating","playing"}
    local function monitorValue(child)
        local n = child.Name:lower()
        local relevant = false
        for _, kw in ipairs(STATUS_KEYS) do
            if n:match(kw) then relevant = true; break end
        end
        if not relevant then return end
        child:GetPropertyChangedSignal("Value"):Connect(function()
            local v    = child.Value
            local flip = false
            if child:IsA("BoolValue") and v == false then flip = true
            elseif child:IsA("IntValue") and v == 0 then flip = true
            elseif child:IsA("StringValue") then
                local vl = v:lower()
                if vl:match("dead") or vl:match("spectat") or vl:match("elimina") then
                    flip = true
                end
            end
            if flip then
                if child:IsA("BoolValue") then child.Value = true
                elseif child:IsA("IntValue") then child.Value = 1
                elseif child:IsA("StringValue") then child.Value = "Playing"
                end
                log("! Valor revertido: " .. child.Name .. " → vivo")
            end
        end)
    end
    for _, child in ipairs(lp:GetChildren()) do
        pcall(function() monitorValue(child) end)
    end
    lp.ChildAdded:Connect(function(child)
        if child:IsA("BoolValue") or child:IsA("IntValue") or child:IsA("StringValue") then
            pcall(function() monitorValue(child) end)
        end
    end)
    log("✓ Proteção de valores ativa")
end

function AntiSpectate.setup()
    if not CFG.ANTI_SPECTATE then return end
    AntiSpectate.setupTeleport()
    AntiSpectate.setupTeam()
    AntiSpectate.setupValues()
    log("✓ Anti-Spectate completo")
end

-- ════════════════════════════════════════════
-- MÓDULO: ANTI-GUI PRECISO
-- ════════════════════════════════════════════
local AntiGUI = {}

local EXACT_GUI_NAMES = {
    "deathscreen","deathgui","deadui","deadscreen",
    "spectategui","spectatorui","spectatorscreen","spectatorframe",
    "eliminatedgui","eliminatedui","eliminatedscreen",
    "gameovergui","gameoverscreen","gameoverui",
    "defeatscreen","defeatgui","defeatui",
    "revivegui","revivescreen","reviveui",
    "playereliminated","youaredead","youdied","youlost",
    "espectadorgui","eliminadogui","mortescreen","fimdejogo",
}

-- Frases de texto que indicam morte — usa find (não exato) pra pegar variações
local DEATH_TEXT_PHRASES = {
    "você morreu",       -- "Você Morreu..." (com ou sem ...)
    "you died",
    "you were eliminated",
    "you are eliminated",
    "you lost",
    "game over",
    "você foi eliminado",
    "você está eliminado",
    "fim de jogo",
    "spectating",
    "você sobreviveu até",  -- tela de buyback "Você sobreviveu até a Hora X"
    "sobreviveu até a hora",
}

-- Botões de BUYBACK/REVIVE que o script deve clicar automaticamente
-- (clica em "Regenerar" pra gastar gemas e continuar, OU fecha a tela)
-- Na verdade, queremos FECHAR a tela de morte, não clicar em nada
-- Botões que devem ser clicados automaticamente pra fechar/ignorar
local AUTO_CLOSE_BUTTONS = {
    "volte para o lobby",  -- NÃO clica nesse
}
-- Botões que FECHAM a tela sem custo (se existir)
local AUTO_CLICK_FREE = {
    "continuar","continue","fechar","close","ok","dismiss",
}

local originalGuis = {}
task.spawn(function()
    task.wait(1)
    for _, g in ipairs(playerGui:GetChildren()) do originalGuis[g] = true end
end)

local function isExactDeathGui(name)
    local low = name:lower()
    for _, exact in ipairs(EXACT_GUI_NAMES) do
        if low == exact then return true end
    end
    local deathSuffixes = {"deathgui","deathscreen","deadgui","deadscreen","spectategui","eliminatedgui","gameovergui"}
    for _, suf in ipairs(deathSuffixes) do
        if low:sub(-#suf) == suf then return true end
    end
    return false
end

-- Verifica se texto CONTÉM frase de morte (find, não exato)
local function hasDeathText(txt)
    local low = txt:lower()
    for _, phrase in ipairs(DEATH_TEXT_PHRASES) do
        if low:find(phrase, 1, true) then return true, phrase end
    end
    return false
end

-- Verifica múltiplos sinais de morte na GUI
local function hasStrongDeathSignals(gui)
    local signals = 0
    local name = gui.Name:lower()

    if name:match("%f[%a]dead%f[%A]") or name:match("%f[%a]death%f[%A]")
    or name:match("%f[%a]spectate%f[%A]") or name:match("%f[%a]eliminated%f[%A]")
    or name:match("%f[%a]gameover%f[%A]") or name:match("%f[%a]defeat%f[%A]")
    or name:match("%f[%a]morreu%f[%A]") or name:match("%f[%a]morto%f[%A]") then
        signals += 1
    end

    for _, child in ipairs(gui:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            local found, phrase = hasDeathText(child.Text or "")
            if found then
                signals += 1
                log("! Texto de morte detectado: '" .. phrase .. "' em " .. gui.Name)
                break
            end
        end
    end

    return signals >= 1  -- 1 sinal já basta agora (era 2 antes — muito restritivo)
end

function AntiGUI.neutralize(gui)
    if originalGuis[gui] then return end

    -- Antes de neutralizar: tenta clicar em "Regenerar" automaticamente
    -- pra gastar gemas e continuar vivo (ou fechar sem custo se possível)
    pcall(function()
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("TextButton") then
                local t = desc.Text:lower()
                -- Clica em "Regenerar" primeiro (continua no round)
                if t:find("regenerar") or t:find("revive") or t:find("continuar") then
                    desc.MouseButton1Click:Fire()
                    log("🔄 Auto-clique: Regenerar/Revive")
                    task.wait(0.2)
                end
            end
        end
    end)

    -- Neutraliza a GUI de qualquer forma
    gui.Enabled = false
    for _, desc in ipairs(gui:GetDescendants()) do
        if desc:IsA("LocalScript") or desc:IsA("Script") then
            desc.Disabled = true
            pcall(function() desc.Parent = ReplicatedStorage end)
        end
    end
    local dummy = Instance.new("ScreenGui")
    dummy.Name    = gui.Name
    dummy.Enabled = false
    dummy.Parent  = playerGui
    pcall(function() gui.Parent = ReplicatedStorage end)
    log("! GUI de morte neutralizada: " .. gui.Name)
end

function AntiGUI.check(gui)
    if not (gui and gui.Parent) then return end
    if originalGuis[gui] then return end

    -- Nome exato
    if isExactDeathGui(gui.Name) then
        AntiGUI.neutralize(gui)
        return
    end

    -- Verifica sinais (com delay pra GUI popular os textos)
    task.spawn(function()
        task.wait(0.3)
        if not (gui and gui.Parent) then return end
        if originalGuis[gui] then return end
        if hasStrongDeathSignals(gui) then
            AntiGUI.neutralize(gui)
        end
    end)
end

function AntiGUI.setup()
    if not CFG.ANTI_GUI then return end

    playerGui.ChildAdded:Connect(function(gui)
        task.wait(0.1) -- espera GUI popular
        AntiGUI.check(gui)
        task.delay(1, function() AntiGUI.check(gui) end) -- segunda chance
    end)

    -- Varredura mais espaçada para não travar
    task.spawn(function()
        while active do
            task.wait(2)
            for _, gui in ipairs(playerGui:GetChildren()) do
                if not originalGuis[gui] then
                    AntiGUI.check(gui)
                end
            end
        end
    end)

    log("✓ Anti-GUI PRECISO ativo (nome exato + multi-sinal)")
end

-- ════════════════════════════════════════════
-- CLONE CACHE (modo Clone Swap)
-- ════════════════════════════════════════════
task.spawn(function()
    while active do
        task.wait(0.3)
        if useRepairMode then continue end
        local char = lp.Character
        if char and not isDead and not swapping then
            pcall(function()
                if charClone and charClone.Parent then charClone:Destroy() end
                charClone        = char:Clone()
                charClone.Name   = lp.Name
                charClone.Parent = nil
            end)
        end
    end
end)

-- ════════════════════════════════════════════
-- SALVAR POSIÇÃO E WALKSPEED
-- ════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local char = lp.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then savedPos = root.Position + Vector3.new(0, 2, 0) end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed > 0 and not isDead then
            savedWalkSpeed = hum.WalkSpeed
        end
    end
end)

-- ════════════════════════════════════════════
-- HEARTBEAT ANTI-GRAB (Rainbow Friends / jogos com grab)
-- Trava HP = Max e estado = Running FRAME A FRAME
-- enquanto NPC estiver em contato com o player.
-- Isso impede que o grab/segura mate o Humanoid.
-- ════════════════════════════════════════════
local npcTouchActive = false  -- true quando NPC está tocando agora
local npcTouchTimer  = 0      -- timer de cooldown após soltar

-- Detecta toque de NPC e ativa trava
local function setupGrabHeartbeat()
    -- Conexão de toque — atualiza flag em tempo real
    local function connectTouch(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end

        -- Todos os parts do char monitoram toque
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Touched:Connect(function(hit)
                    local model = hit:FindFirstAncestorOfClass("Model")
                    if not model or model == char then return end
                    -- É um NPC (tem Humanoid mas não é player)
                    local npcHum = model:FindFirstChildOfClass("Humanoid")
                    if not npcHum then return end
                    local isPlayer = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character == model then isPlayer = true; break end
                    end
                    if isPlayer then return end
                    -- NPC confirmado tocando → ativa trava
                    npcTouchActive = true
                    npcTouchTimer  = 1.5  -- mantém trava por 1.5s após soltar
                end)
            end
        end
    end

    if lp.Character then task.spawn(function() connectTouch(lp.Character) end) end
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        npcTouchActive = false
        npcTouchTimer  = 0
        connectTouch(char)
    end)

    -- Heartbeat: enquanto NPC toca, trava HP e estado todo frame
    RunService.Heartbeat:Connect(function(dt)
        if not active then return end

        -- Decrementa timer
        if npcTouchTimer > 0 then
            npcTouchTimer = npcTouchTimer - dt
            if npcTouchTimer <= 0 then
                npcTouchActive = false
                npcTouchTimer  = 0
            end
        end

        if not npcTouchActive then return end

        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local maxHp = hum.MaxHealth
        if maxHp <= 0 or maxHp == math.huge then maxHp = 100 end

        -- Trava HP no máximo todo frame durante o grab
        if hum.Health < maxHp then
            hum.Health = maxHp
        end

        -- Impede estado de morte/física
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Dead
        or state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.FallingDown then
            pcall(function()
                hum.Health = maxHp
                hum:ChangeState(Enum.HumanoidStateType.Running)
                hum.PlatformStand = false
                hum.Sit = false
            end)
        end

        -- Reverte atributos de eliminação durante grab (Rainbow Friends)
        pcall(function()
            for attrName, val in pairs(lp:GetAttributes()) do
                local low = attrName:lower()
                if (low:find("alive") or low:find("survivor") or low:find("fallen")
                or low:find("caught") or low:find("dead") or low:find("elim"))
                and (val == false or val == 0 or val == "dead" or val == "fallen") then
                    if type(val) == "boolean" then lp:SetAttribute(attrName, true)
                    elseif type(val) == "number" then lp:SetAttribute(attrName, 1)
                    elseif type(val) == "string" then lp:SetAttribute(attrName, "alive")
                    end
                end
            end
            if char and char.Parent then
                for attrName, val in pairs(char:GetAttributes()) do
                    local low = attrName:lower()
                    if (low:find("alive") or low:find("fallen") or low:find("caught")
                    or low:find("dead") or low:find("elim"))
                    and (val == false or val == 0 or val == "dead" or val == "fallen") then
                        if type(val) == "boolean" then char:SetAttribute(attrName, true)
                        elseif type(val) == "number" then char:SetAttribute(attrName, 1)
                        elseif type(val) == "string" then char:SetAttribute(attrName, "alive")
                        end
                    end
                end
            end
        end)
    end)

    log("✓ Heartbeat Anti-Grab ativo (HP travado frame-a-frame durante contato NPC)")
end

setupGrabHeartbeat()

-- ════════════════════════════════════════════
-- APPLY ALL (proteções completas no char)
-- ════════════════════════════════════════════
local function applyAll(char)
    if not char then return end
    task.wait(0.2)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    applyProtections(char, hum)
    watchAttrs(char)
    watchAttrs(lp)
end

if lp.Character then task.spawn(applyAll, lp.Character) end
lp.CharacterAdded:Connect(applyAll)

-- ════════════════════════════════════════════
-- CharacterRemoving (Clone Swap)
-- ════════════════════════════════════════════
lp.CharacterRemoving:Connect(function(char)
    if not active or isDead or useRepairMode then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then savedPos = root.Position + Vector3.new(0, 2, 0) end
    task.spawn(function() reviveClean(char) end)
end)

-- ════════════════════════════════════════════
-- CharacterAdded — reset de flags
-- ════════════════════════════════════════════
lp.CharacterAdded:Connect(function()
    rebuilding = false
    isDead     = false
    swapping   = false
    charClone  = nil
    for _, conn in pairs(diedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    diedConnections = {}
end)

-- ════════════════════════════════════════════
-- HEARTBEAT — recuperar se sem char por 0.3s
-- ════════════════════════════════════════════
local noCharTime = 0
RunService.Heartbeat:Connect(function(dt)
    if not active then return end
    if not lp.Character then
        noCharTime += dt
        if noCharTime >= 0.3 and not rebuilding and not isDead then
            noCharTime = 0
            pcall(function() lp:LoadCharacter() end)
        end
    else
        noCharTime = 0
    end
end)

-- ════════════════════════════════════════════
-- INICIALIZAÇÃO PRINCIPAL
-- ════════════════════════════════════════════
local function initialize()
    log("═══════════════════════════════════════════════════════")
    log("     GOD MODE FUSION ULTRA v1.0                        ")
    log("     GodMode v22 + Anti-Eliminação ULTRA UNIDOS        ")
    log("═══════════════════════════════════════════════════════")
    log("Place ID: " .. tostring(game.PlaceId))

    detectMode()

    if useRepairMode then
        RepairEngine.setup()
    end

    AntiSpectate.setup()
    AntiGUI.setup()
    setupAntiCatch()  -- Proteção contra eliminação por NPC/animação

    log("═══════════════════════════════════════════════════════")
    log("  ✅ FUSION COMPLETAMENTE ATIVA")
    log("  Modo Engine      : " .. (useRepairMode and "CHARACTER REPAIR" or "CLONE SWAP"))
    log("  Remote Block     : ✅ (preciso, não bloqueia interações)")
    log("  Anti-Spectate    : ✅")
    log("  Anti-Team        : ✅")
    log("  Anti-Ragdoll     : ✅ (BallSocket + Animações)")
    log("  Anti-GUI PRECISO : ✅ (nome exato + multi-sinal)")
    log("  Anti-Teleport    : ✅")
    log("  Attr Guard       : ✅ (+ caught/captured/tagged/frozen)")
    log("  HP Regen         : ✅ (a cada " .. CFG.REGEN_INTERVAL .. "s)")
    log("  Anti-NPC Catch   : ✅ (animação + toque de NPC)")
    log("  Camadas Hum.     : 10 camadas de proteção")
    log("═══════════════════════════════════════════════════════")
end

initialize()

-- ════════════════════════════════════════════
-- NOTIFICAÇÃO
-- ════════════════════════════════════════════
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title    = "FUSION ULTRA v1",
        Text     = "⚡ GodMode + Anti-Elim + Anti-NPC! Interações liberadas.",
        Duration = 6
    })
end)

print("🛡️ GOD MODE FUSION ULTRA v1.0 — TOTALMENTE ATIVO!")
print("💡 10 camadas de proteção + bloqueio de remotes + GUI neutralizer")
