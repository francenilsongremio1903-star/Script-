-- ANTI ELIMINAÇÃO ULTRA - Versão agressiva
-- Bloqueia TUDO que parecer eliminação, sem perguntar

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

print("🛡️ Anti-Eliminação ULTRA ativado!")

-- ═══════════════════════════════════════════════════════════════
-- LISTA MASSIVA DE PALAVRAS-CHAVE
-- ═══════════════════════════════════════════════════════════════
local BLOCKED_KEYWORDS = {
    -- Eliminação
    "eliminate", "eliminated", "elimination", "elim", "eliminado", "eliminar",
    "kill", "killed", "killing", "matar", "morto", "morte", "morrer", "morreu",
    "dead", "death", "die", "died", "dying", "ded", "falecido",
    
    -- Espectador
    "spectate", "spectator", "spectating", "spec", "espectador", "espectar",
    "watch", "assistir", "observar", "observador",
    
    -- Lobby/Saída
    "lobby", "sala", "sendtolobby", "goto", "tp", "teleport", "teleportar",
    "respawn", "spawn", "reaparecer", "out", "fora", "kick", "remover",
    
    -- Derrota
    "defeat", "defeated", "lose", "lost", "loser", "perdeu", "perdedor",
    "gameover", "fimdejogo", "fim", "end", "finish", "finished",
    
    -- Saúde/Dano
    "health", "vida", "hp", "sethealth", "damage", "dano", "danar",
    "takedamage", "applydamage", "hit", "hurt", "punch", "shoot",
    
    -- Estado
    "isdead", "iseliminated", "isout", "isspectator", "status",
    "state", "estado", "condicao", "condition",
}

-- ═══════════════════════════════════════════════════════════════
-- VERIFICADOR DE NOMES
-- ═══════════════════════════════════════════════════════════════
local function shouldBlock(name)
    local low = name:lower()
    for _, kw in ipairs(BLOCKED_KEYWORDS) do
        if low:find(kw, 1, true) then
            return true, kw
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════
-- BLOQUEADOR PRINCIPAL
-- ═══════════════════════════════════════════════════════════════
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" or method == "InvokeServer" then
            if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self:IsA("UnreliableRemoteEvent") then
                local shouldBlockIt, keyword = shouldBlock(self.Name)
                if shouldBlockIt then
                    print("🚫 BLOQUEADO:", self.Name, "(contém:", keyword .. ")")
                    return nil
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- PROTEÇÃO DO HUMANOID
-- ═══════════════════════════════════════════════════════════════
local function protectChar(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    -- Impede morte
    hum.HealthChanged:Connect(function(h)
        if h <= 0 then
            hum.Health = hum.MaxHealth
            print("💚 Vida restaurada!")
        end
    end)
    
    -- Impede MaxHealth = 0
    hum:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        if hum.MaxHealth <= 0 then
            hum.MaxHealth = 100
            hum.Health = 100
        end
    end)
    
    -- Impede paralisação
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum.WalkSpeed == 0 then
            hum.WalkSpeed = 14
        end
    end)
    
    hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if hum.JumpPower == 0 then
            hum.JumpPower = 50
        end
    end)
    
    hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
    end)
    
    -- Regeneração automática
    task.spawn(function()
        while char and char.Parent do
            task.wait(0.5)
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- PROTEÇÃO DE ATRIBUTOS
-- ═══════════════════════════════════════════════════════════════
local BAD_ATTRS = {
    "dead", "eliminated", "out", "spectator", "espectador", "eliminado",
    "morto", "fora", "perdeu", "lose", "defeated", "derrotado"
}

local function watchAttrs(obj)
    pcall(function()
        obj.AttributeChanged:Connect(function(attr)
            local low = attr:lower()
            for _, bad in ipairs(BAD_ATTRS) do
                if low:find(bad) then
                    local val = obj:GetAttribute(attr)
                    if val == true or val == "true" or val == "eliminated" or val == "dead" then
                        task.wait(0.05)
                        obj:SetAttribute(attr, false)
                        print("🔄 Atributo", attr, "revertido para false")
                    end
                    break
                end
            end
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- DESTRUIR GUIS RUINS
-- ═══════════════════════════════════════════════════════════════
local BAD_GUI = {
    "spectate", "spectator", "eliminate", "eliminated", "lobby",
    "dead", "death", "gameover", "lose", "defeat",
    "espectador", "eliminado", "morto", "fimdejogo", "perdeu"
}

local function isBadGui(name)
    local low = name:lower()
    for _, bad in ipairs(BAD_GUI) do
        if low:find(bad) then return true end
    end
    return false
end

local function destroyBadGuis()
    pcall(function()
        for _, gui in ipairs(lp.PlayerGui:GetChildren()) do
            if isBadGui(gui.Name) then
                print("🗑️ GUI destruída:", gui.Name)
                gui:Destroy()
            end
            for _, child in ipairs(gui:GetDescendants()) do
                if (child:IsA("ScreenGui") or child:IsA("Frame")) and isBadGui(child.Name) then
                    child:Destroy()
                end
            end
        end
    end)
end

lp.PlayerGui.ChildAdded:Connect(function(child)
    task.wait(0.1)
    if isBadGui(child.Name) then
        child:Destroy()
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════════════
local function setup(char)
    task.wait(0.3)
    protectChar(char)
    watchAttrs(char)
    watchAttrs(lp)
    destroyBadGuis()
end

if lp.Character then
    task.spawn(function() setup(lp.Character) end)
end
lp.CharacterAdded:Connect(setup)

print("✅ Proteção ULTRA ativa!")
print("💡 Você está praticamente imortal agora.")
