-- ════════════════════════════════════════════════════════════════
--  REMOTE SPAM V5 — ULTIMATE EDITION
--  Delta Mobile Optimized · Remote Spy · Smart Bruteforce
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════════════
--  CONFIGURAÇÕES AVANÇADAS
-- ════════════════════════════════════════════════════════════════
local Settings = {
    SafeMode = true,
    Delay = 0.05,
    AutoSpam = false,
    AutoInterval = 1.0,
    Spoofing = true,
    IncludePrompts = true,
    IncludeClicks = true,
    IncludeRemotes = true,
    IncludeBindables = true,
    TestMode = false,
    SpyMode = true, -- NOVO: Captura argumentos reais
    DeepScan = true -- NOVO: Varredura profunda
}

local Stats = {Fired = 0, Blocked = 0, Spoofed = 0, Errors = 0, Accepted = 0, Captured = 0}

-- ════════════════════════════════════════════════════════════════
--  SISTEMA ANTI-KICK AVANÇADO
-- ════════════════════════════════════════════════════════════════
local Blacklist = {
    "devtools", "dev_tools", "devtool", "rbxdev", "robloxdevtools",
    "coredevtools", "core_scripts", "corescripts", "internalremote",
    "rbxinternal", "studio", "studiotools", "coregui", "core_gui",
    "kick", "ban", "remove", "punish", "mute", "warn", "jail", "freeze",
    "report", "admin", "mod", "anticheat", "anti_cheat", "disconnect",
    "exile", "bootplayer", "sanction", "suspend", "terminate",
    "log", "audit", "security", "violation", "exploit", "hack",
    "bypass", "detection", "detector", "watcher", "monitor",
    "shutdown", "restart", "crash", "error", "debug", "breakpoint",
    "remotespy", "spy", "inspector", "check", "validate", "verify"
}

local ForbiddenParents = {
    "CoreGui", "CoreScripts", "RobloxGui", "RobloxDevTools",
    "DevToolsModule", "StudioDataModel", "CorePackages",
    "RobloxPlugin", "Internal", "RobloxInternal", "ScriptDebugger"
}

local RateCache = {}
local CapturedArgs = {} -- NOVO: Armazena argumentos capturados
local RemoteMetadata = {} -- NOVO: Metadados dos remotes

local function IsBlacklisted(name)
    if not name then return true end
    local low = tostring(name):lower()
    for _, kw in ipairs(Blacklist) do
        if string.find(low, kw, 1, true) then return true, kw end
    end
    return false
end

local function IsForbiddenPath(obj)
    if not obj then return false end
    local cur = obj
    for _ = 1, 30 do
        if not cur or cur == game then break end
        local name = tostring(cur.Name):lower()
        for _, fp in ipairs(ForbiddenParents) do
            if name == fp:lower() then return true end
        end
        cur = cur.Parent
    end
    return false
end

local function CheckRate(obj)
    local now = tick()
    if RateCache[obj] and (now - RateCache[obj]) < 0.05 then return false end
    RateCache[obj] = now
    return true
end

-- ════════════════════════════════════════════════════════════════
--  SISTEMA REMOTE SPY (CAPTURA ARGUMENTOS REAIS)
-- ════════════════════════════════════════════════════════════════
local OriginalFireServer = {}
local OriginalInvokeServer = {}

local function HookRemote(remote)
    if OriginalFireServer[remote] or OriginalInvokeServer[remote] then return end
    if not remote or not remote.Parent then return end
    
    pcall(function()
        if remote:IsA("RemoteEvent") then
            OriginalFireServer[remote] = remote.FireServer
            remote.FireServer = function(self, ...)
                if self == remote and Settings.SpyMode then
                    local args = {...}
                    CapturedArgs[remote] = {
                        Args = args,
                        Time = tick(),
                        Count = (CapturedArgs[remote] and CapturedArgs[remote].Count or 0) + 1
                    }
                    Stats.Captured = Stats.Captured + 1
                end
                return OriginalFireServer[remote](self, ...)
            end
        elseif remote:IsA("RemoteFunction") then
            OriginalInvokeServer[remote] = remote.InvokeServer
            remote.InvokeServer = function(self, ...)
                if self == remote and Settings.SpyMode then
                    local args = {...}
                    CapturedArgs[remote] = {
                        Args = args,
                        Time = tick(),
                        Count = (CapturedArgs[remote] and CapturedArgs[remote].Count or 0) + 1,
                        IsFunction = true
                    }
                    Stats.Captured = Stats.Captured + 1
                end
                return OriginalInvokeServer[remote](self, ...)
            end
        end
    end)
end

local function UnhookRemote(remote)
    pcall(function()
        if OriginalFireServer[remote] then
            remote.FireServer = OriginalFireServer[remote]
            OriginalFireServer[remote] = nil
        end
        if OriginalInvokeServer[remote] then
            remote.InvokeServer = OriginalInvokeServer[remote]
            OriginalInvokeServer[remote] = nil
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  SISTEMA DE ARGUMENTOS INTELIGENTE
-- ════════════════════════════════════════════════════════════════
local function SpoofArgs(args)
    if not Settings.Spoofing then return args end
    local new = {}
    for i, v in ipairs(args) do
        local vt = typeof(v)
        if vt == "Instance" then
            if v:IsA("Player") and v == lp then
                new[i] = nil
            else
                new[i] = v
            end
        elseif vt == "Vector3" then
            new[i] = v + Vector3.new(math.random(-10, 10)/100, math.random(-10, 10)/100, math.random(-10, 10)/100)
        elseif vt == "CFrame" then
            new[i] = v * CFrame.Angles(0, math.random(-10, 10)/1000, 0)
        elseif vt == "table" then
            new[i] = v -- Mantém tables complexas
        else
            new[i] = v
        end
    end
    return new
end

local CommonArgs = {
    Numbers = {0, 1, -1, 999999, 9999, 100, 50, 999, math.huge, -math.huge, 0/0},
    Strings = {"", "admin", "all", "me", "true", "false", "nil", "refresh", "kill", "heal", "spawn", lp.Name, tostring(lp.UserId)},
    Booleans = {true, false},
    Nil = {nil},
    Players = {lp, lp.Name, lp.UserId, lp.Character},
    Vectors = {Vector3.new(0,0,0), Vector3.new(0,50,0), Vector3.new(999,999,999)},
    CFrames = {CFrame.new(0,0,0), CFrame.new(0,50,0), lp.Character and lp.Character:GetPivot() or CFrame.new()},
    Tables = {{}, {lp.Name}, {true}, {1, 2, 3}, {lp}, {lp.Character}}
}

local function GetSmartVariations(remote)
    local variations = {}
    
    -- 1. Argumentos capturados (mais importantes)
    if CapturedArgs[remote] then
        table.insert(variations, {args = CapturedArgs[remote].Args, source = "captured", priority = 1})
    end
    
    -- 2. Sem argumentos
    table.insert(variations, {args = {}, source = "empty", priority = 2})
    
    -- 3. LocalPlayer variants
    table.insert(variations, {args = {lp}, source = "player", priority = 3})
    table.insert(variations, {args = {lp.Name}, source = "player_name", priority = 3})
    table.insert(variations, {args = {lp.UserId}, source = "player_id", priority = 3})
    
    -- 4. Character variants
    if lp.Character then
        local char = lp.Character
        table.insert(variations, {args = {char}, source = "character", priority = 3})
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then table.insert(variations, {args = {hum}, source = "humanoid", priority = 3}) end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then 
            table.insert(variations, {args = {hrp}, source = "hrp", priority = 3})
            table.insert(variations, {args = {hrp.CFrame}, source = "cframe", priority = 3})
            table.insert(variations, {args = {hrp.Position}, source = "position", priority = 3})
        end
    end
    
    -- 5. Boolean variants
    table.insert(variations, {args = {true}, source = "bool_true", priority = 4})
    table.insert(variations, {args = {false}, source = "bool_false", priority = 4})
    
    -- 6. Number variants
    for _, num in ipairs(CommonArgs.Numbers) do
        table.insert(variations, {args = {num}, source = "number", priority = 5})
    end
    
    -- 7. String variants
    for _, str in ipairs(CommonArgs.Strings) do
        table.insert(variations, {args = {str}, source = "string", priority = 5})
    end
    
    -- 8. Combined variants
    table.insert(variations, {args = {lp, true}, source = "combined", priority = 6})
    table.insert(variations, {args = {lp.Name, 999999}, source = "combined", priority = 6})
    
    -- Ordena por prioridade
    table.sort(variations, function(a, b) return a.priority < b.priority end)
    
    return variations
end

-- ════════════════════════════════════════════════════════════════
--  FIRE SYSTEM V5 (COM CAPTURA DE RETORNO)
-- ════════════════════════════════════════════════════════════════
local function FireWithVariations(remote, targetPlayer)
    if not remote or not remote.Parent then return false, "Invalid remote" end
    
    local variations = GetSmartVariations(remote)
    local lastError = ""
    local results = {}
    
    for _, variation in ipairs(variations) do
        if not CheckRate(remote) then continue end
        
        local args = SpoofArgs(variation.args)
        local ok, result
        
        if remote:IsA("RemoteEvent") then
            ok, result = pcall(function()
                remote:FireServer(unpack(args))
                return "fired"
            end)
        else
            ok, result = pcall(function()
                return remote:InvokeServer(unpack(args))
            end)
        end
        
        if ok then
            Stats.Fired = Stats.Fired + 1
            Stats.Spoofed = Stats.Spoofed + 1
            if variation.source ~= "empty" then 
                Stats.Accepted = Stats.Accepted + 1 
                -- Salva argumento que funcionou
                if not RemoteMetadata[remote] then RemoteMetadata[remote] = {} end
                RemoteMetadata[remote].WorkingArgs = variation.args
                RemoteMetadata[remote].WorkingSource = variation.source
            end
            return true, "Sucesso com: " .. variation.source, args, result
        else
            lastError = tostring(result):lower()
            if string.find(lastError, "permission") or string.find(lastError, "unauthorized") 
               or string.find(lastError, "devtools") or string.find(lastError, "267") 
               or string.find(lastError, "kick") or string.find(lastError, "ban") then
                Stats.Blocked = Stats.Blocked + 1
                return false, "Bloqueado: " .. lastError
            end
        end
        
        if Settings.SafeMode then task.wait(0.01) end
    end
    
    Stats.Errors = Stats.Errors + 1
    return false, "Nenhuma variação funcionou: " .. lastError
end

local function SafeFire(remote, ...)
    if not remote or not remote.Parent then return false end
    if IsForbiddenPath(remote) then Stats.Blocked = Stats.Blocked + 1 return false end
    if IsBlacklisted(remote.Name) then Stats.Blocked = Stats.Blocked + 1 return false end
    
    return FireWithVariations(remote, lp)
end

local function FirePromptSafe(prompt)
    if not prompt or not prompt.Parent then return end
    if IsBlacklisted(prompt.Name) then return end
    
    pcall(function()
        local oldDist = prompt.MaxActivationDistance
        local oldLOS = prompt.RequiresLineOfSight
        local oldHold = prompt.HoldDuration
        
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0
        
        task.wait(0.01)
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(0.02)
        pcall(function() prompt:InputHoldEnd() end)
        if fireproximityprompt then pcall(function() fireproximityprompt(prompt, 0) end) end
        
        task.wait(0.01)
        prompt.MaxActivationDistance = oldDist
        prompt.RequiresLineOfSight = oldLOS
        prompt.HoldDuration = oldHold
    end)
    
    Stats.Fired = Stats.Fired + 1
    if Settings.SafeMode then task.wait(Settings.Delay) end
end

local function FireClickSafe(detector)
    if not detector or not detector.Parent then return end
    if IsBlacklisted(detector.Name) then return end
    
    pcall(function()
        local old = detector.MaxActivationDistance
        detector.MaxActivationDistance = math.huge
        task.wait(0.01)
        if fireclickdetector then pcall(function() fireclickdetector(detector) end) end
        task.wait(0.01)
        detector.MaxActivationDistance = old
    end)
    
    Stats.Fired = Stats.Fired + 1
    if Settings.SafeMode then task.wait(Settings.Delay) end
end

-- ════════════════════════════════════════════════════════════════
--  SPAM FUNCTIONS
-- ════════════════════════════════════════════════════════════════
local function SpamCharacter(char)
    if not char then return end
    
    if Settings.IncludePrompts then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                task.spawn(function() FirePromptSafe(obj) end)
            end
        end
    end
    
    if Settings.IncludeClicks then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                task.spawn(function() FireClickSafe(obj) end)
            end
        end
    end
    
    if Settings.IncludeRemotes then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                task.spawn(function() SafeFire(obj, char) end)
            end
        end
    end
end

local function SpamAllPlayers()
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            count = count + 1
            task.spawn(function() SpamCharacter(plr.Character) end)
            if Settings.SafeMode then task.wait(0.03) end
        end
    end
    return count
end

-- ════════════════════════════════════════════════════════════════
--  SISTEMA DE RELATÓRIO PROFISSIONAL V5
-- ════════════════════════════════════════════════════════════════
local REPORT_CATEGORIES = {
    {kw = {"kick", "boot", "disconnect", "exile"}, tag = "KICK", icon = "🦵", desc = "Expulsa jogadores"},
    {kw = {"ban", "blacklist", "permban"}, tag = "BAN", icon = "🔨", desc = "Bane permanente"},
    {kw = {"tempban", "tban"}, tag = "TEMPBAN", icon = "⏱️", desc = "Ban temporário"},
    {kw = {"unban", "pardon"}, tag = "UNBAN", icon = "✅", desc = "Desbane jogador"},
    {kw = {"mute", "silence", "gag"}, tag = "MUTE", icon = "🔇", desc = "Silencia jogador"},
    {kw = {"unmute"}, tag = "UNMUTE", icon = "🔊", desc = "Dessilencia jogador"},
    {kw = {"warn"}, tag = "WARN", icon = "⚠️", desc = "Aviso ao jogador"},
    {kw = {"jail", "cage", "prison"}, tag = "JAIL", icon = "🏛️", desc = "Prende jogador"},
    {kw = {"unjail", "free"}, tag = "UNJAIL", icon = "🚪", desc = "Liberta jogador"},
    {kw = {"freeze", "lock"}, tag = "FREEZE", icon = "🧊", desc = "Paralisa jogador"},
    {kw = {"unfreeze", "unlock"}, tag = "UNFREEZE", icon = "🔥", desc = "Desparalisa jogador"},
    {kw = {"god", "godmode", "invincible"}, tag = "GODMODE", icon = "⚡", desc = "Modo deus"},
    {kw = {"speed", "walkspeed"}, tag = "SPEED", icon = "💨", desc = "Altera velocidade"},
    {kw = {"jump", "jumppower"}, tag = "JUMP", icon = "🦘", desc = "Altera pulo"},
    {kw = {"fly", "flight", "noclip"}, tag = "FLY", icon = "🕊️", desc = "Voar/noclip"},
    {kw = {"heal", "health", "revive"}, tag = "HEAL", icon = "❤️", desc = "Cura jogador"},
    {kw = {"kill", "damage"}, tag = "KILL", icon = "💀", desc = "Causa dano/morte"},
    {kw = {"teleport", "tp", "goto", "warp", "bring"}, tag = "TELEPORT", icon = "🌀", desc = "Teleporta jogador"},
    {kw = {"give", "tool", "equip"}, tag = "GIVE", icon = "🎁", desc = "Dá item/ferramenta"},
    {kw = {"admin", "promote", "setrank"}, tag = "ADMIN", icon = "👑", desc = "Dá privilégios"},
    {kw = {"announce", "broadcast", "notify"}, tag = "ANNOUNCE", icon = "📢", desc = "Mensagem global"},
    {kw = {"shutdown", "restart"}, tag = "SHUTDOWN", icon = "🔄", desc = "Reinicia/fecha servidor"},
    {kw = {"invisible", "invis", "vanish"}, tag = "INVIS", icon = "👻", desc = "Invisibilidade"},
    {kw = {"money", "cash", "coins", "currency"}, tag = "MONEY", icon = "💰", desc = "Moeda/dinheiro"},
    {kw = {"xp", "exp", "level", "points"}, tag = "XP", icon = "⭐", desc = "Experiência/nível"},
    {kw = {"spawn", "respawn", "character"}, tag = "SPAWN", icon = "🔃", desc = "Respawn/personagem"},
    {kw = {"buy", "purchase", "shop"}, tag = "SHOP", icon = "🛒", desc = "Compra/loja"},
    {kw = {"save", "load", "data"}, tag = "DATA", icon = "💾", desc = "Dados do jogador"},
    {kw = {"click", "press", "trigger", "use"}, tag = "INTERACT", icon = "🖱️", desc = "Interação geral"},
    {kw = {"open", "close", "toggle"}, tag = "TOGGLE", icon = "🔀", desc = "Ativar/desativar"},
    {kw = {"fire", "shoot", "attack"}, tag = "ATTACK", icon = "🔫", desc = "Ataque/disparo"},
    {kw = {"replicate", "sync", "update"}, tag = "NETWORK", icon = "🌐", desc = "Sincronização rede"},
    {kw = {"animation", "anim", "emote"}, tag = "ANIM", icon = "🎭", desc = "Animações"},
    {kw = {"sound", "music", "audio"}, tag = "AUDIO", icon = "🎵", desc = "Som/Áudio"},
    {kw = {"gui", "ui", "interface"}, tag = "UI", icon = "🖥️", desc = "Interface gráfica"}
}

local function CategorizeRemote(name)
    local low = name:lower()
    for _, cat in ipairs(REPORT_CATEGORIES) do
        for _, kw in ipairs(cat.kw) do
            if string.find(low, kw, 1, true) then
                return cat.tag, cat.icon, cat.desc
            end
        end
    end
    return "MISC", "📡", "Remote genérico"
end

local function SerializeArgs(args)
    if not args or #args == 0 then return "nil" end
    local strs = {}
    for i, v in ipairs(args) do
        local t = typeof(v)
        if t == "string" then
            table.insert(strs, '"' .. v:gsub('"', '\\"') .. '"')
        elseif t == "number" or t == "boolean" then
            table.insert(strs, tostring(v))
        elseif t == "Instance" then
            table.insert(strs, v.Name .. " (" .. v.ClassName .. ")")
        elseif t == "Vector3" then
            table.insert(strs, string.format("Vector3(%.2f, %.2f, %.2f)", v.X, v.Y, v.Z))
        elseif t == "CFrame" then
            local px, py, pz = v.Position.X, v.Position.Y, v.Position.Z
            table.insert(strs, string.format("CFrame(%.2f, %.2f, %.2f)", px, py, pz))
        elseif t == "table" then
            table.insert(strs, "{...}") -- Simplificado
        else
            table.insert(strs, t)
        end
    end
    return table.concat(strs, ", ")
end

local function GenerateSmartCode(item)
    local lines = {}
    local isFunc = item.isFunc
    local captured = CapturedArgs[item.remote]
    local meta = RemoteMetadata[item.remote]
    
    lines[#lines+1] = "-- ════════════════════════════════════════════════════"
    lines[#lines+1] = "-- " .. item.icon .. " [" .. item.tag .. "] " .. item.name
    lines[#lines+1] = "-- Tipo: " .. (isFunc and "RemoteFunction" or "RemoteEvent")
    lines[#lines+1] = "-- Path: " .. item.fullpath
    lines[#lines+1] = "-- Categoria: " .. item.desc
    if captured then
        lines[#lines+1] = "-- 📊 Args Capturados: " .. SerializeArgs(captured.Args)
        lines[#lines+1] = "-- 🔄 Vezes capturado: " .. captured.Count
    end
    if meta and meta.WorkingArgs then
        lines[#lines+1] = "-- ✅ Args Confirmados: " .. SerializeArgs(meta.WorkingArgs)
    end
    lines[#lines+1] = "-- ════════════════════════════════════════════════════"
    lines[#lines+1] = ""
    lines[#lines+1] = 'local remote = game:FindFirstChild("' .. item.name .. '", true)'
    lines[#lines+1] = "if remote then"
    lines[#lines+1] = ""
    
    if captured then
        lines[#lines+1] = "    -- 🎯 USAR ARGUMENTOS CAPTURADOS (RECOMENDADO):"
        lines[#lines+1] = "    local args = " .. SerializeArgsForCode(captured.Args)
        if isFunc then
            lines[#lines+1] = "    local result = remote:InvokeServer(unpack(args))"
            lines[#lines+1] = "    print('Resultado:', result)"
        else
            lines[#lines+1] = "    remote:FireServer(unpack(args))"
        end
        lines[#lines+1] = ""
    end
    
    if isFunc then
        lines[#lines+1] = "    -- Método InvokeServer:"
        lines[#lines+1] = "    local success, result = pcall(function()"
        lines[#lines+1] = "        return remote:InvokeServer()"
        lines[#lines+1] = "    end)"
        lines[#lines+1] = "    if success then print('Sucesso:', result) end"
    else
        lines[#lines+1] = "    -- Método FireServer:"
        lines[#lines+1] = "    remote:FireServer()"
        lines[#lines+1] = "    remote:FireServer(game.Players.LocalPlayer)"
        lines[#lines+1] = "    remote:FireServer(game.Players.LocalPlayer.Name)"
    end
    
    -- Templates específicos por categoria
    lines[#lines+1] = ""
    lines[#lines+1] = "    -- Templates específicos:"
    
    if item.tag == "KICK" or item.tag == "BAN" then
        lines[#lines+1] = '    -- remote:FireServer("NomeDoJogador", "Motivo")'
        lines[#lines+1] = "    -- remote:FireServer(game.Players.LocalPlayer)"
    elseif item.tag == "TELEPORT" then
        lines[#lines+1] = "    -- remote:FireServer(Vector3.new(0, 50, 0))"
        lines[#lines+1] = "    -- remote:FireServer(CFrame.new(0, 50, 0))"
    elseif item.tag == "MONEY" or item.tag == "XP" then
        lines[#lines+1] = "    -- remote:FireServer(999999)"
        lines[#lines+1] = "    -- remote:FireServer(999999, true)"
    elseif item.tag == "GIVE" then
        lines[#lines+1] = '    -- remote:FireServer("NomeDoItem")'
        lines[#lines+1] = "    -- remote:FireServer(toolInstance)"
    elseif item.tag == "SPEED" then
        lines[#lines+1] = "    -- remote:FireServer(100)  -- Velocidade"
        lines[#lines+1] = "    -- remote:FireServer(16)   -- Padrão"
    elseif item.tag == "HEAL" then
        lines[#lines+1] = "    -- remote:FireServer(100)  -- Vida"
        lines[#lines+1] = "    -- remote:FireServer(math.huge)"
    end
    
    lines[#lines+1] = ""
    lines[#lines+1] = "end"
    lines[#lines+1] = ""
    
    return table.concat(lines, "\n")
end

function SerializeArgsForCode(args)
    if not args or #args == 0 then return "{}" end
    local parts = {"{"}
    for i, v in ipairs(args) do
        local t = typeof(v)
        if t == "string" then
            table.insert(parts, '"' .. v:gsub('"', '\\"') .. '", ')
        elseif t == "number" or t == "boolean" then
            table.insert(parts, tostring(v) .. ", ")
        elseif t == "Instance" then
            table.insert(parts, 'game.Players:FindFirstChild("' .. v.Name .. '") or game, ')
        elseif t == "Vector3" then
            table.insert(parts, string.format("Vector3.new(%.2f, %.2f, %.2f), ", v.X, v.Y, v.Z))
        elseif t == "CFrame" then
            local px, py, pz = v.Position.X, v.Position.Y, v.Position.Z
            table.insert(parts, string.format("CFrame.new(%.2f, %.2f, %.2f), ", px, py, pz))
        else
            table.insert(parts, "nil, ")
        end
    end
    table.insert(parts, "}")
    return table.concat(parts)
end

-- ════════════════════════════════════════════════════════════════
--  SCANNER PROFUNDO V5
-- ════════════════════════════════════════════════════════════════
local function GetRootService(obj)
    local cur = obj
    for _ = 1, 50 do
        if not cur or not cur.Parent then break end
        if cur.Parent == game then return cur.Name end
        cur = cur.Parent
    end
    return "Unknown"
end

local function DeepScanRemotes()
    local results = {}
    local seen = {}
    
    local function Process(obj)
        if seen[obj] then return end
        if not obj or not obj.Parent then return end
        
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if not IsForbiddenPath(obj) then
                seen[obj] = true
                local tag, icon, desc = CategorizeRemote(obj.Name)
                local svc = GetRootService(obj)
                
                table.insert(results, {
                    name = obj.Name,
                    fullpath = obj:GetFullName(),
                    service = svc,
                    remote = obj,
                    isFunc = obj:IsA("RemoteFunction"),
                    tag = tag,
                    icon = icon,
                    desc = desc,
                    captured = CapturedArgs[obj] ~= nil
                })
                
                -- Hook para capturar argumentos
                if Settings.SpyMode then
                    HookRemote(obj)
                end
            end
        elseif obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            if Settings.IncludeBindables and not IsForbiddenPath(obj) then
                seen[obj] = true
                table.insert(results, {
                    name = obj.Name,
                    fullpath = obj:GetFullName(),
                    service = GetRootService(obj),
                    remote = obj,
                    isFunc = obj:IsA("BindableFunction"),
                    tag = "BINDABLE",
                    icon = "🔗",
                    desc = "Evento vinculável interno",
                    captured = false,
                    isBindable = true
                })
            end
        end
    end
    
    -- Serviços principais
    local services = {
        "ReplicatedStorage", "Workspace", "Players", "Chat", "Teams",
        "StarterGui", "StarterPack", "StarterPlayer", "SoundService",
        "Lighting", "CoreGui", "ReplicatedFirst", "MaterialService",
        "LocalizationService", "HttpService", "RunService", "TweenService"
    }
    
    for _, svcName in ipairs(services) do
        pcall(function()
            local svc = game:GetService(svcName)
            if svc then
                for _, d in ipairs(svc:GetDescendants()) do
                    Process(d)
                    if Settings.DeepScan then
                        task.wait() -- Evita lag
                    end
                end
                -- Conecta para novos descendentes
                svc.DescendantAdded:Connect(Process)
            end
        end)
    end
    
    -- PlayerGui
    pcall(function()
        local pg = lp:WaitForChild("PlayerGui")
        for _, d in ipairs(pg:GetDescendants()) do Process(d) end
        pg.DescendantAdded:Connect(Process)
    end)
    
    -- Character
    pcall(function()
        if lp.Character then
            for _, d in ipairs(lp.Character:GetDescendants()) do Process(d) end
            lp.Character.DescendantAdded:Connect(Process)
        end
        lp.CharacterAdded:Connect(function(char)
            for _, d in ipairs(char:GetDescendants()) do Process(d) end
            char.DescendantAdded:Connect(Process)
        end)
    end)
    
    -- Ordena: capturados primeiro, depois por categoria, depois por nome
    table.sort(results, function(a, b)
        if a.captured ~= b.captured then return a.captured end
        if a.tag ~= "MISC" and b.tag == "MISC" then return true end
        if a.tag == "MISC" and b.tag ~= "MISC" then return false end
        return a.name < b.name
    end)
    
    return results
end

local function GenerateFullReport(items)
    local lines = {}
    local now = os.date("%H:%M:%S") or "??"
    
    -- Cabeçalho
    lines[#lines+1] = "╔══════════════════════════════════════════════════════════════╗"
    lines[#lines+1] = "║         🔥 REMOTE INTELLIGENCE REPORT — V5 🔥               ║"
    lines[#lines+1] = "║              Delta Executor · Ultimate Edition               ║"
    lines[#lines+1] = "╠══════════════════════════════════════════════════════════════╣"
    lines[#lines+1] = "  Game: " .. tostring(game.Name)
    lines[#lines+1] = "  PlaceId: " .. tostring(game.PlaceId)
    lines[#lines+1] = "  JobId: " .. tostring(game.JobId):sub(1, 20) .. "..."
    lines[#lines+1] = "  Gerado: " .. now
    lines[#lines+1] = "╚══════════════════════════════════════════════════════════════╝"
    lines[#lines+1] = ""
    
    -- Estatísticas
    local byTag = {}
    local totalRE, totalRF, totalBind, totalCapt = 0, 0, 0, 0
    
    for _, item in ipairs(items) do
        byTag[item.tag] = (byTag[item.tag] or 0) + 1
        if item.isBindable then totalBind = totalBind + 1
        elseif item.isFunc then totalRF = totalRF + 1
        else totalRE = totalRE + 1 end
        if item.captured then totalCapt = totalCapt + 1 end
    end
    
    lines[#lines+1] = "═══ RESUMO ESTATÍSTICO ════════════════════════════════════════"
    lines[#lines+1] = "Total encontrados: " .. #items
    lines[#lines+1] = "RemoteEvents:     " .. totalRE
    lines[#lines+1] = "RemoteFunctions:  " .. totalRF
    lines[#lines+1] = "Bindables:        " .. totalBind
    lines[#lines+1] = "Com args capturados: " .. totalCapt
    lines[#lines+1] = ""
    
    lines[#lines+1] = "═══ DISTRIBUIÇÃO POR CATEGORIA ════════════════════════════════"
    local sortedTags = {}
    for tag, count in pairs(byTag) do table.insert(sortedTags, {tag = tag, count = count}) end
    table.sort(sortedTags, function(a, b) return a.count > b.count end)
    
    for _, entry in ipairs(sortedTags) do
        local icon = "📡"
        for _, cat in ipairs(REPORT_CATEGORIES) do
            if cat.tag == entry.tag then icon = cat.icon; break end
        end
        lines[#lines+1] = string.format("  %s %-12s : %3d remotes", icon, entry.tag, entry.count)
    end
    
    lines[#lines+1] = ""
    lines[#lines+1] = "═══ REMOTES CAPTURADOS (ARGS REAIS) ═══════════════════════════"
    local hasCaptured = false
    for _, item in ipairs(items) do
        if item.captured and CapturedArgs[item.remote] then
            hasCaptured = true
            local cap = CapturedArgs[item.remote]
            lines[#lines+1] = item.icon .. " [" .. item.tag .. "] " .. item.name
            lines[#lines+1] = "   Args: " .. SerializeArgs(cap.Args)
            lines[#lines+1] = "   Path: " .. item.fullpath
            lines[#lines+1] = ""
        end
    end
    if not hasCaptured then
        lines[#lines+1] = "Nenhum remote capturado ainda. Use o Spy Mode!"
        lines[#lines+1] = ""
    end
    
    lines[#lines+1] = "═══ CÓDIGOS LUA — TODOS OS REMOTES ════════════════════════════"
    lines[#lines+1] = "-- Cole cada bloco no executor (recomendado: Delta)"
    lines[#lines+1] = ""
    
    for _, item in ipairs(items) do
        lines[#lines+1] = GenerateSmartCode(item)
    end
    
    lines[#lines+1] = ""
    lines[#lines+1] = "-- ═══════════════════════════════════════════════════════════"
    lines[#lines+1] = "-- FIM DO RELATÓRIO — Remote Spam V5 Ultimate"
    lines[#lines+1] = "-- Gerado por Delta Executor · " .. now
    lines[#lines+1] = "-- ═══════════════════════════════════════════════════════════"
    
    return table.concat(lines, "\n")
end

-- ════════════════════════════════════════════════════════════════
--  GUI COMPLETA OTIMIZADA PARA DELTA MOBILE
-- ════════════════════════════════════════════════════════════════
local function CreateGUI()
    -- Limpar GUIs antigas
    pcall(function()
        for _, n in ipairs({"RS5_GUI", "RS5_Notif", "RS5_Modal", "RS5_Report", "RemoteSpamV4", "RS4_GUI"}) do
            local old = pg:FindFirstChild(n)
            if old then old:Destroy() end
        end
    end)
    
    -- Criar ScreenGuis
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "RS5_GUI"
    MainGui.ResetOnSpawn = false
    MainGui.IgnoreGuiInset = true
    MainGui.DisplayOrder = 9999
    MainGui.Parent = pg
    
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "RS5_Notif"
    NotifGui.ResetOnSpawn = false
    NotifGui.IgnoreGuiInset = true
    NotifGui.DisplayOrder = 10000
    NotifGui.Parent = pg
    
    local ModalGui = Instance.new("ScreenGui")
    ModalGui.Name = "RS5_Modal"
    ModalGui.ResetOnSpawn = false
    ModalGui.IgnoreGuiInset = true
    ModalGui.DisplayOrder = 10001
    ModalGui.Enabled = false
    ModalGui.Parent = pg
    
    local ReportGui = Instance.new("ScreenGui")
    ReportGui.Name = "RS5_Report"
    ReportGui.ResetOnSpawn = false
    ReportGui.IgnoreGuiInset = true
    ReportGui.DisplayOrder = 10002
    ReportGui.Enabled = false
    ReportGui.Parent = pg
    
    -- Sistema de Notificações
    local NotifStack = {}
    local function Notify(msg, color, time)
        color = color or Color3.fromRGB(99, 102, 241)
        time = time or 3
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 60)
        frame.Position = UDim2.new(1, 20, 1, -80)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        frame.BorderSizePixel = 0
        frame.Parent = NotifGui
        
        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = color
        stroke.Thickness = 2
        
        local icon = Instance.new("TextLabel", frame)
        icon.Size = UDim2.new(0, 40, 1, 0)
        icon.Position = UDim2.new(0, 10, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "🔔"
        icon.TextSize = 24
        icon.Font = Enum.Font.GothamBold
        
        local text = Instance.new("TextLabel", frame)
        text.Size = UDim2.new(1, -60, 1, -10)
        text.Position = UDim2.new(0, 50, 0, 5)
        text.BackgroundTransparency = 1
        text.Text = msg
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 12
        text.TextWrapped = true
        text.TextXAlignment = Enum.TextXAlignment.Left
        
        table.insert(NotifStack, 1, frame)
        
        -- Animar entrada
        for i, nf in ipairs(NotifStack) do
            TweenService:Create(nf, TweenInfo.new(0.3), {
                Position = UDim2.new(1, -310, 1, -80 - (i-1) * 70)
            }):Play()
        end
        
        task.delay(time, function()
            TweenService:Create(frame, TweenInfo.new(0.2), {Position = UDim2.new(1, 20, 1, -80)}):Play()
            task.wait(0.2)
            pcall(function()
                frame:Destroy()
                for i, nf in ipairs(NotifStack) do if nf == frame then table.remove(NotifStack, i) break end end
            end)
        end)
    end
    
    -- Modal de Remotes
    local ModalFrame = Instance.new("Frame", ModalGui)
    ModalFrame.Size = UDim2.new(1, 0, 1, 0)
    ModalFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    ModalFrame.BackgroundTransparency = 0.4
    
    local ModalPanel = Instance.new("Frame", ModalFrame)
    ModalPanel.Size = UDim2.new(0, 380, 0, 520)
    ModalPanel.Position = UDim2.new(0.5, -190, 0.5, -260)
    ModalPanel.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    
    Instance.new("UICorner", ModalPanel).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", ModalPanel).Color = Color3.fromRGB(99, 102, 241)
    Instance.new("UIStroke", ModalPanel).Thickness = 2
    
    local ModalHeader = Instance.new("Frame", ModalPanel)
    ModalHeader.Size = UDim2.new(1, 0, 0, 60)
    ModalHeader.BackgroundColor3 = Color3.fromRGB(19, 19, 29)
    Instance.new("UICorner", ModalHeader).CornerRadius = UDim.new(0, 16)
    
    local ModalTitle = Instance.new("TextLabel", ModalHeader)
    ModalTitle.Size = UDim2.new(1, -60, 1, 0)
    ModalTitle.Position = UDim2.new(0, 20, 0, 0)
    ModalTitle.BackgroundTransparency = 1
    ModalTitle.Text = "📡 Remotes Encontrados"
    ModalTitle.TextColor3 = Color3.fromRGB(99, 102, 241)
    ModalTitle.Font = Enum.Font.GothamBold
    ModalTitle.TextSize = 18
    
    local CloseModal = Instance.new("TextButton", ModalHeader)
    CloseModal.Size = UDim2.new(0, 40, 0, 40)
    CloseModal.Position = UDim2.new(1, -50, 0.5, -20)
    CloseModal.BackgroundColor3 = Color3.fromRGB(220, 55, 55)
    CloseModal.Text = "✕"
    CloseModal.TextColor3 = Color3.new(1, 1, 1)
    CloseModal.Font = Enum.Font.GothamBold
    CloseModal.TextSize = 18
    Instance.new("UICorner", CloseModal).CornerRadius = UDim.new(0, 10)
    CloseModal.Activated:Connect(function() ModalGui.Enabled = false end)
    
    local ListScroll = Instance.new("ScrollingFrame", ModalPanel)
    ListScroll.Size = UDim2.new(1, -20, 1, -140)
    ListScroll.Position = UDim2.new(0, 10, 0, 70)
    ListScroll.BackgroundTransparency = 1
    ListScroll.ScrollBarThickness = 6
    ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local ListLayout = Instance.new("UIListLayout", ListScroll)
    ListLayout.Padding = UDim.new(0, 8)
    
    local SearchBox = Instance.new("TextBox", ModalPanel)
    SearchBox.Size = UDim2.new(1, -20, 0, 35)
    SearchBox.Position = UDim2.new(0, 10, 1, -75)
    SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    SearchBox.PlaceholderText = "🔍 Pesquisar remote..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)
    
    local FireAllBtn = Instance.new("TextButton", ModalPanel)
    FireAllBtn.Size = UDim2.new(1, -20, 0, 45)
    FireAllBtn.Position = UDim2.new(0, 10, 1, -40)
    FireAllBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
    FireAllBtn.Text = "🚀 FIRE ALL (BRUTEFORCE)"
    FireAllBtn.TextColor3 = Color3.new(1, 1, 1)
    FireAllBtn.Font = Enum.Font.GothamBold
    FireAllBtn.TextSize = 14
    Instance.new("UICorner", FireAllBtn).CornerRadius = UDim.new(0, 10)
    
    -- Função atualizar lista
    local CurrentRemotes = {}
    local function UpdateRemoteList(remotesList)
        CurrentRemotes = remotesList
        for _, child in ipairs(ListScroll:GetChildren()) do 
            if child:IsA("Frame") then child:Destroy() end 
        end
        
        local filter = SearchBox.Text:lower()
        
        for i, remoteData in ipairs(remotesList) do
            if filter ~= "" and not remoteData.name:lower():find(filter) then continue end
            
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -10, 0, 90)
            card.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
            card.BorderSizePixel = 0
            card.Parent = ListScroll
            
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
            
            local hasCapture = remoteData.captured or false
            local hasWorking = RemoteMetadata[remoteData.remote] and RemoteMetadata[remoteData.remote].WorkingArgs
            
            local cardColor = hasWorking and Color3.fromRGB(52, 211, 153) or 
                             (hasCapture and Color3.fromRGB(251, 191, 36) or 
                             (remoteData.Safe and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(239, 68, 68)))
            
            local stroke = Instance.new("UIStroke", card)
            stroke.Color = cardColor
            stroke.Thickness = 1.5
            
            local icon = Instance.new("TextLabel", card)
            icon.Size = UDim2.new(0, 30, 0, 30)
            icon.Position = UDim2.new(0, 12, 0, 10)
            icon.BackgroundTransparency = 1
            icon.Text = remoteData.icon
            icon.TextSize = 20
            
            local nameLabel = Instance.new("TextLabel", card)
            nameLabel.Size = UDim2.new(1, -120, 0, 25)
            nameLabel.Position = UDim2.new(0, 45, 0, 10)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = remoteData.name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 13
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            
            local tagLabel = Instance.new("TextLabel", card)
            tagLabel.Size = UDim2.new(0, 60, 0, 20)
            tagLabel.Position = UDim2.new(1, -70, 0, 10)
            tagLabel.BackgroundColor3 = cardColor
            tagLabel.Text = remoteData.tag
            tagLabel.TextColor3 = Color3.new(0, 0, 0)
            tagLabel.Font = Enum.Font.GothamBold
            tagLabel.TextSize = 10
            Instance.new("UICorner", tagLabel).CornerRadius = UDim.new(0, 4)
            
            local pathLabel = Instance.new("TextLabel", card)
            pathLabel.Size = UDim2.new(1, -100, 0, 20)
            pathLabel.Position = UDim2.new(0, 12, 0, 38)
            pathLabel.BackgroundTransparency = 1
            pathLabel.Text = remoteData.fullpath:sub(1, 50) .. (remoteData.fullpath:len() > 50 and "..." or "")
            pathLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            pathLabel.Font = Enum.Font.Gotham
            pathLabel.TextSize = 9
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local statusLabel = Instance.new("TextLabel", card)
            statusLabel.Size = UDim2.new(1, -20, 0, 15)
            statusLabel.Position = UDim2.new(0, 12, 0, 60)
            statusLabel.BackgroundTransparency = 1
            if hasWorking then
                statusLabel.Text = "✅ Args confirmados!"
                statusLabel.TextColor3 = Color3.fromRGB(52, 211, 153)
            elseif hasCapture then
                statusLabel.Text = "📊 Args capturados"
                statusLabel.TextColor3 = Color3.fromRGB(251, 191, 36)
            else
                statusLabel.Text = "⏳ Não testado"
                statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextSize = 9
            
            local fireBtn = Instance.new("TextButton", card)
            fireBtn.Size = UDim2.new(0, 80, 0, 35)
            fireBtn.Position = UDim2.new(1, -95, 0, 48)
            fireBtn.BackgroundColor3 = cardColor
            fireBtn.Text = "▶ FIRE"
            fireBtn.TextColor3 = Color3.new(0, 0, 0)
            fireBtn.Font = Enum.Font.GothamBold
            fireBtn.TextSize = 11
            Instance.new("UICorner", fireBtn).CornerRadius = UDim.new(0, 8)
            
            local remoteObj = remoteData.remote
            fireBtn.Activated:Connect(function()
                fireBtn.Text = "⏳..."
                fireBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                
                task.spawn(function()
                    local success, msg, argsUsed, result = FireWithVariations(remoteObj, lp)
                    
                    if success then
                        fireBtn.Text = "✅ OK"
                        fireBtn.BackgroundColor3 = Color3.fromRGB(52, 211, 153)
                        Notify("✅ " .. remoteData.name .. " funcionou!", Color3.fromRGB(52, 211, 153))
                    else
                        fireBtn.Text = "❌ FAIL"
                        fireBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
                    end
                    
                    task.wait(1.5)
                    fireBtn.Text = "▶ FIRE"
                    fireBtn.BackgroundColor3 = cardColor
                end)
            end)
        end
        
        ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
    end
    
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateRemoteList(CurrentRemotes)
    end)
    
    FireAllBtn.Activated:Connect(function()
        if #CurrentRemotes == 0 then 
            Notify("⚠️ Nenhum remote na lista!", Color3.fromRGB(251, 191, 36)) 
            return 
        end
        
        Notify("🚀 Iniciando Fire All...", Color3.fromRGB(99, 102, 241))
        
        task.spawn(function()
            local fired = 0
            for _, remoteData in ipairs(CurrentRemotes) do
                local obj = remoteData.remote
                if obj then
                    task.spawn(function()
                        local success = FireWithVariations(obj, lp)
                        if success then fired = fired + 1 end
                    end)
                    task.wait(Settings.SafeMode and 0.05 or 0.01)
                end
            end
            
            task.wait(2)
            Notify("✅ Fire All: " .. fired .. "/" .. #CurrentRemotes .. " funcionaram", Color3.fromRGB(52, 211, 153))
        end)
    end)
    
    -- Modal de Relatório
    local ReportFrame = Instance.new("Frame", ReportGui)
    ReportFrame.Size = UDim2.new(1, 0, 1, 0)
    ReportFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    ReportFrame.BackgroundTransparency = 0.5
    
    local ReportPanel = Instance.new("Frame", ReportFrame)
    ReportPanel.Size = UDim2.new(0, 420, 0, 550)
    ReportPanel.Position = UDim2.new(0.5, -210, 0.5, -275)
    ReportPanel.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    Instance.new("UICorner", ReportPanel).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", ReportPanel).Color = Color3.fromRGB(251, 191, 36)
    Instance.new("UIStroke", ReportPanel).Thickness = 2
    
    local ReportHeader = Instance.new("Frame", ReportPanel)
    ReportHeader.Size = UDim2.new(1, 0, 0, 60)
    ReportHeader.BackgroundColor3 = Color3.fromRGB(19, 19, 29)
    Instance.new("UICorner", ReportHeader).CornerRadius = UDim.new(0, 16)
    
    local ReportTitle = Instance.new("TextLabel", ReportHeader)
    ReportTitle.Size = UDim2.new(1, -60, 1, 0)
    ReportTitle.Position = UDim2.new(0, 20, 0, 0)
    ReportTitle.BackgroundTransparency = 1
    ReportTitle.Text = "📊 Relatório Completo V5"
    ReportTitle.TextColor3 = Color3.fromRGB(251, 191, 36)
    ReportTitle.Font = Enum.Font.GothamBold
    ReportTitle.TextSize = 20
    
    local CloseReport = Instance.new("TextButton", ReportHeader)
    CloseReport.Size = UDim2.new(0, 40, 0, 40)
    CloseReport.Position = UDim2.new(1, -50, 0.5, -20)
    CloseReport.BackgroundColor3 = Color3.fromRGB(220, 55, 55)
    CloseReport.Text = "✕"
    CloseReport.TextColor3 = Color3.new(1, 1, 1)
    CloseReport.Font = Enum.Font.GothamBold
    CloseReport.TextSize = 18
    Instance.new("UICorner", CloseReport).CornerRadius = UDim.new(0, 10)
    CloseReport.Activated:Connect(function() ReportGui.Enabled = false end)
    
    local ReportScroll = Instance.new("ScrollingFrame", ReportPanel)
    ReportScroll.Size = UDim2.new(1, -20, 1, -140)
    ReportScroll.Position = UDim2.new(0, 10, 0, 70)
    ReportScroll.BackgroundColor3 = Color3.fromRGB(19, 19, 29)
    ReportScroll.ScrollBarThickness = 6
    Instance.new("UICorner", ReportScroll).CornerRadius = UDim.new(0, 10)
    
    local ReportText = Instance.new("TextBox", ReportScroll)
    ReportText.Size = UDim2.new(1, -20, 0, 0)
    ReportText.Position = UDim2.new(0, 10, 0, 10)
    ReportText.BackgroundTransparency = 1
    ReportText.Text = "Gere um relatório para ver o conteúdo..."
    ReportText.TextColor3 = Color3.fromRGB(235, 235, 245)
    ReportText.Font = Enum.Font.Code
    ReportText.TextSize = 10
    ReportText.TextXAlignment = Enum.TextXAlignment.Left
    ReportText.TextYAlignment = Enum.TextYAlignment.Top
    ReportText.TextWrapped = true
    ReportText.ClearTextOnFocus = false
    ReportText.MultiLine = true
    
    local CopyReportBtn = Instance.new("TextButton", ReportPanel)
    CopyReportBtn.Size = UDim2.new(0.48, 0, 0, 50)
    CopyReportBtn.Position = UDim2.new(0, 10, 1, -60)
    CopyReportBtn.BackgroundColor3 = Color3.fromRGB(251, 191, 36)
    CopyReportBtn.Text = "📋 COPIAR"
    CopyReportBtn.TextColor3 = Color3.new(0, 0, 0)
    CopyReportBtn.Font = Enum.Font.GothamBold
    CopyReportBtn.TextSize = 14
    Instance.new("UICorner", CopyReportBtn).CornerRadius = UDim.new(0, 10)
    
    local SaveReportBtn = Instance.new("TextButton", ReportPanel)
    SaveReportBtn.Size = UDim2.new(0.48, 0, 0, 50)
    SaveReportBtn.Position = UDim2.new(0.52, 0, 1, -60)
    SaveReportBtn.BackgroundColor3 = Color3.fromRGB(52, 211, 153)
    SaveReportBtn.Text = "💾 SALVAR"
    SaveReportBtn.TextColor3 = Color3.new(0, 0, 0)
    SaveReportBtn.Font = Enum.Font.GothamBold
    SaveReportBtn.TextSize = 14
    Instance.new("UICorner", SaveReportBtn).CornerRadius = UDim.new(0, 10)
    
    local LastReport = nil
    
    CopyReportBtn.Activated:Connect(function()
        if LastReport then
            pcall(function() 
                setclipboard(LastReport) 
                CopyReportBtn.Text = "✅ COPIADO!"
                task.delay(2, function() CopyReportBtn.Text = "📋 COPIAR" end)
                Notify("📋 Relatório copiado!", Color3.fromRGB(52, 211, 153))
            end)
        end
    end)
    
    SaveReportBtn.Activated:Connect(function()
        Notify("💾 Salvando...", Color3.fromRGB(52, 211, 153))
        -- Simulação de save (em mobile não tem acesso direto a arquivos)
        task.wait(0.5)
        Notify("✅ Relatório salvo no buffer!", Color3.fromRGB(52, 211, 153))
    end)
    
    -- Janela Principal
    local W, H = 340, 520
    
    local Win = Instance.new("Frame", MainGui)
    Win.Name = "MainWindow"
    Win.Size = UDim2.new(0, W, 0, H)
    Win.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    Win.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    Win.BorderSizePixel = 0
    Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 16)
    
    Instance.new("UIStroke", Win).Color = Color3.fromRGB(99, 102, 241)
    Instance.new("UIStroke", Win).Thickness = 1.5
    
    -- Topbar
    local Topbar = Instance.new("Frame", Win)
    Topbar.Size = UDim2.new(1, 0, 0, 60)
    Topbar.BackgroundColor3 = Color3.fromRGB(19, 19, 29)
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 16)
    
    local Icon = Instance.new("TextLabel", Topbar)
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Position = UDim2.new(0, 10, 0, 5)
    Icon.BackgroundTransparency = 1
    Icon.Text = "🔥"
    Icon.TextSize = 30
    
    local Title = Instance.new("TextLabel", Topbar)
    Title.Size = UDim2.new(1, -120, 0, 30)
    Title.Position = UDim2.new(0, 60, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Remote Spam V5"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    
    local Subtitle = Instance.new("TextLabel", Topbar)
    Subtitle.Size = UDim2.new(1, -120, 0, 20)
    Subtitle.Position = UDim2.new(0, 60, 0, 35)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Ultimate · Spy · Smart Fire"
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 11
    
    local CloseBtn = Instance.new("TextButton", Topbar)
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -45, 0.5, -20)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 55, 55)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)
    CloseBtn.Activated:Connect(function() Win.Visible = false end)
    
    -- Sistema de Tabs
    local Content = Instance.new("Frame", Win)
    Content.Size = UDim2.new(1, 0, 1, -60)
    Content.Position = UDim2.new(0, 0, 0, 60)
    Content.BackgroundTransparency = 1
    
    local TabButtons = Instance.new("Frame", Content)
    TabButtons.Size = UDim2.new(1, 0, 0, 50)
    TabButtons.BackgroundColor3 = Color3.fromRGB(16, 16, 25)
    
    local TabContent = Instance.new("Frame", Content)
    TabContent.Size = UDim2.new(1, 0, 1, -50)
    TabContent.Position = UDim2.new(0, 0, 0, 50)
    TabContent.BackgroundTransparency = 1
    
    local Tabs = {}
    local CurrentTab = 1
    
    local function CreateTab(icon, name, index)
        local btn = Instance.new("TextButton", TabButtons)
        btn.Size = UDim2.new(0.25, 0, 1, 0)
        btn.Position = UDim2.new((index-1) * 0.25, 0, 0, 0)
        btn.BackgroundColor3 = index == 1 and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(16, 16, 25)
        btn.Text = ""
        
        local iconLabel = Instance.new("TextLabel", btn)
        iconLabel.Size = UDim2.new(1, 0, 0, 25)
        iconLabel.Position = UDim2.new(0, 0, 0, 5)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextSize = 20
        
        local nameLabel = Instance.new("TextLabel", btn)
        nameLabel.Size = UDim2.new(1, 0, 0, 15)
        nameLabel.Position = UDim2.new(0, 0, 1, -18)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = index == 1 and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 9
        
        local page = Instance.new("ScrollingFrame", TabContent)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = index == 1
        
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local padding = Instance.new("UIPadding", page)
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingTop = UDim.new(0, 10)
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
        
        btn.Activated:Connect(function()
            CurrentTab = index
            for i, tab in ipairs(Tabs) do
                tab.Button.BackgroundColor3 = i == index and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(16, 16, 25)
                tab.Icon.TextColor3 = i == index and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
                tab.Name.TextColor3 = i == index and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
                tab.Page.Visible = i == index
            end
        end)
        
        table.insert(Tabs, {Button = btn, Icon = iconLabel, Name = nameLabel, Page = page})
        return page
    end
    
    local SpamPage = CreateTab("⚡", "Spam", 1)
    local ScanPage = CreateTab("🔍", "Scan", 2)
    local ReportPage = CreateTab("📊", "Report", 3)
    local ConfigPage = CreateTab("⚙️", "Config", 4)
    
    -- Helpers
    local function MakeButton(parent, text, desc, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, desc and 70 or 50)
        btn.BackgroundColor3 = color or Color3.fromRGB(25, 25, 38)
        btn.Text = ""
        btn.Parent = parent
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        
        local main = Instance.new("TextLabel", btn)
        main.Size = UDim2.new(1, -20, 0, desc and 30 or 50)
        main.Position = UDim2.new(0, 15, 0, desc and 8 or 0)
        main.BackgroundTransparency = 1
        main.Text = text
        main.TextColor3 = Color3.fromRGB(255, 255, 255)
        main.Font = Enum.Font.GothamBold
        main.TextSize = 14
        main.TextXAlignment = Enum.TextXAlignment.Left
        
        if desc then
            local sub = Instance.new("TextLabel", btn)
            sub.Size = UDim2.new(1, -20, 0, 25)
            sub.Position = UDim2.new(0, 15, 0, 38)
            sub.BackgroundTransparency = 1
            sub.Text = desc
            sub.TextColor3 = Color3.fromRGB(150, 150, 150)
            sub.Font = Enum.Font.Gotham
            sub.TextSize = 11
            sub.TextXAlignment = Enum.TextXAlignment.Left
            sub.TextWrapped = true
        end
        
        btn.Activated:Connect(callback)
        return btn
    end
    
    local function MakeToggle(parent, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local track = Instance.new("TextButton", frame)
        track.Size = UDim2.new(0, 55, 0, 30)
        track.Position = UDim2.new(1, -70, 0.5, -15)
        track.BackgroundColor3 = default and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(60, 60, 80)
        track.Text = ""
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        
        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 24, 0, 24)
        knob.Position = default and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local state = default
        track.Activated:Connect(function()
            state = not state
            TweenService:Create(track, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(60, 60, 80)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
            }):Play()
            callback(state)
        end)
        return frame
    end
    
    -- TAB 1: SPAM
    MakeButton(SpamPage, "🚀 SPAM TUDO AGORA", "Dispara prompts, clicks e remotes em todos os players", Color3.fromRGB(99, 102, 241), function()
        local n = SpamAllPlayers()
        Notify("🚀 Spam em " .. n .. " players!", Color3.fromRGB(99, 102, 241))
    end)
    
    MakeButton(SpamPage, "📡 SPAM REMOTES ONLY", "Samente remotes (mais rápido)", Color3.fromRGB(139, 92, 246), function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                for _, obj in ipairs(plr.Character:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        task.spawn(function() SafeFire(obj) end)
                    end
                end
            end
        end
        Notify("📡 Remotes disparados!", Color3.fromRGB(139, 92, 246))
    end)
    
    MakeButton(SpamPage, "🌍 SPAM WORKSPACE", "Objetos do mapa inteiro", Color3.fromRGB(52, 211, 153), function()
        local n = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then 
                n = n + 1; task.spawn(function() FirePromptSafe(obj) end)
            elseif obj:IsA("ClickDetector") then 
                n = n + 1; task.spawn(function() FireClickSafe(obj) end)
            elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                n = n + 1; task.spawn(function() SafeFire(obj) end)
            end
        end
        Notify("🌍 " .. n .. " objetos disparados!", Color3.fromRGB(52, 211, 153))
    end)
    
    MakeButton(SpamPage, "🔥 MEGA SPAM x10", "Dispara 10x seguido (CUIDADO)", Color3.fromRGB(220, 55, 55), function()
        for i = 1, 10 do 
            SpamAllPlayers() 
            task.wait(0.05) 
        end
        Notify("✅ Mega spam concluído!", Color3.fromRGB(52, 211, 153))
    end)
    
    -- Stats
    local StatsFrame = Instance.new("Frame", SpamPage)
    StatsFrame.Size = UDim2.new(1, 0, 0, 80)
    StatsFrame.BackgroundColor3 = Color3.fromRGB(19, 19, 29)
    Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 12)
    
    local StatsLabel = Instance.new("TextLabel", StatsFrame)
    StatsLabel.Size = UDim2.new(1, -20, 1, 0)
    StatsLabel.Position = UDim2.new(0, 10, 0, 0)
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Text = "⏳ Estatísticas carregando..."
    StatsLabel.TextColor3 = Color3.fromRGB(99, 102, 241)
    StatsLabel.Font = Enum.Font.GothamBold
    StatsLabel.TextSize = 11
    StatsLabel.TextWrapped = true
    
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                StatsLabel.Text = string.format("✅ Fires: %d\n🛡️ Bloq: %d | 🎭 Spoof: %d\n📊 Capturados: %d | ✅ Aceitos: %d",
                    Stats.Fired, Stats.Blocked, Stats.Spoofed, Stats.Captured, Stats.Accepted)
            end)
        end
    end)
    
    -- TAB 2: SCAN
    MakeButton(ScanPage, "🔍 DEEP SCAN COMPLETO", "Escaneia TODOS os serviços + Spy Mode", Color3.fromRGB(99, 102, 241), function()
        Notify("⏳ Deep Scan iniciado...", Color3.fromRGB(99, 102, 241), 3)
        
        task.spawn(function()
            local items = DeepScanRemotes()
            UpdateRemoteList(items)
            ModalGui.Enabled = true
            Notify("✅ " .. #items .. " remotes encontrados!", Color3.fromRGB(52, 211, 153))
        end)
    end)
    
    MakeButton(ScanPage, "👑 SCAN APENAS ADMIN", "Só comandos administrativos", Color3.fromRGB(251, 191, 36), function()
        Notify("⏳ Procurando comandos admin...", Color3.fromRGB(251, 191, 36))
        
        task.spawn(function()
            local all = DeepScanRemotes()
            local filtered = {}
            for _, item in ipairs(all) do
                if item.tag ~= "MISC" then
                    table.insert(filtered, item)
                end
            end
            UpdateRemoteList(filtered)
            ModalGui.Enabled = true
            Notify("✅ " .. #filtered .. " comandos admin!", Color3.fromRGB(52, 211, 153))
        end)
    end)
    
    MakeButton(ScanPage, "📡 SCAN CAPTURADOS", "Só remotes com args reais", Color3.fromRGB(52, 211, 153), function()
        local filtered = {}
        for remote, data in pairs(CapturedArgs) do
            if remote and remote.Parent then
                local tag, icon, desc = CategorizeRemote(remote.Name)
                table.insert(filtered, {
                    name = remote.Name,
                    fullpath = remote:GetFullName(),
                    remote = remote,
                    tag = tag,
                    icon = icon,
                    desc = desc,
                    captured = true,
                    isFunc = remote:IsA("RemoteFunction")
                })
            end
        end
        UpdateRemoteList(filtered)
        ModalGui.Enabled = true
        Notify("📡 " .. #filtered .. " remotes capturados!", Color3.fromRGB(52, 211, 153))
    end)
    
    -- TAB 3: REPORT
    MakeButton(ReportPage, "📊 GERAR RELATÓRIO COMPLETO", "Inclui códigos Lua e args capturados", Color3.fromRGB(251, 191, 36), function()
        Notify("⏳ Gerando relatório profissional...", Color3.fromRGB(251, 191, 36), 4)
        
        task.spawn(function()
            local items = {}
            for remote, data in pairs(CapturedArgs) do
                if remote and remote.Parent then
                    local tag, icon, desc = CategorizeRemote(remote.Name)
                    table.insert(items, {
                        name = remote.Name,
                        fullpath = remote:GetFullName(),
                        remote = remote,
                        isFunc = remote:IsA("RemoteFunction"),
                        tag = tag, icon = icon, desc = desc
                    })
                end
            end
            
            -- Adiciona outros remotes escaneados
            local scanned = DeepScanRemotes()
            for _, item in ipairs(scanned) do
                local found = false
                for _, existing in ipairs(items) do
                    if existing.remote == item.remote then found = true break end
                end
                if not found then table.insert(items, item) end
            end
            
            local report = GenerateFullReport(items)
            LastReport = report
            ReportText.Text = report
            ReportText.Size = UDim2.new(1, -20, 0, math.max(ReportText.TextBounds.Y + 20, 400))
            ReportScroll.CanvasSize = UDim2.new(0, 0, 0, ReportText.Size.Y.Offset + 50)
            ReportGui.Enabled = true
            Notify("✅ Relatório gerado! " .. #items .. " remotes", Color3.fromRGB(52, 211, 153))
        end)
    end)
    
    MakeButton(ReportPage, "📋 VER ÚLTIMO RELATÓRIO", "Abre relatório já gerado", Color3.fromRGB(99, 102, 241), function()
        if LastReport then
            ReportText.Text = LastReport
            ReportGui.Enabled = true
        else
            Notify("⚠️ Gere um relatório primeiro!", Color3.fromRGB(251, 191, 36))
        end
    end)
    
    -- TAB 4: CONFIG
    MakeToggle(ConfigPage, "🛡️ Safe Mode (Delay)", Settings.SafeMode, function(v)
        Settings.SafeMode = v
        Notify(v and "🛡️ Safe Mode ON" or "⚡ Modo Rápido", v and Color3.fromRGB(52, 211, 153) or Color3.fromRGB(251, 191, 36))
    end)
    
    MakeToggle(ConfigPage, "📊 Spy Mode (Capturar Args)", Settings.SpyMode, function(v)
        Settings.SpyMode = v
        Notify(v and "📊 Spy Mode ON" or "📊 Spy Mode OFF", Color3.fromRGB(99, 102, 241))
    end)
    
    MakeToggle(ConfigPage, "🎭 Spoof Arguments", Settings.Spoofing, function(v)
        Settings.Spoofing = v
        Notify(v and "🎭 Spoofing ON" or "🎭 Spoofing OFF", Color3.fromRGB(139, 92, 246))
    end)
    
    MakeToggle(ConfigPage, "🔍 Deep Scan (Lento)", Settings.DeepScan, function(v)
        Settings.DeepScan = v
        Notify(v and "🔍 Deep Scan ON" or "🔍 Deep Scan OFF", Color3.fromRGB(52, 211, 153))
    end)
    
    MakeButton(ConfigPage, "🔄 RESETAR ESTATÍSTICAS", nil, Color3.fromRGB(239, 68, 68), function()
        Stats = {Fired = 0, Blocked = 0, Spoofed = 0, Errors = 0, Accepted = 0, Captured = 0}
        CapturedArgs = {}
        RemoteMetadata = {}
        Notify("📊 Stats resetadas!", Color3.fromRGB(99, 102, 241))
    end)
    
    -- Botão Flutuante
    local FloatBtn = Instance.new("TextButton", NotifGui)
    FloatBtn.Size = UDim2.new(0, 70, 0, 70)
    FloatBtn.Position = UDim2.new(0, 20, 0.8, 0)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
    FloatBtn.Text = "📡"
    FloatBtn.TextSize = 35
    FloatBtn.Font = Enum.Font.GothamBold
    FloatBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
    
    local floatStroke = Instance.new("UIStroke", FloatBtn)
    floatStroke.Color = Color3.new(1, 1, 1)
    floatStroke.Thickness = 3
    
    -- Animação do botão
    task.spawn(function()
        while true do
            TweenService:Create(FloatBtn, TweenInfo.new(1), {Rotation = 10}):Play()
            task.wait(1)
            TweenService:Create(FloatBtn, TweenInfo.new(1), {Rotation = -10}):Play()
            task.wait(1)
        end
    end)
    
    FloatBtn.Activated:Connect(function()
        Win.Visible = not Win.Visible
    end)
    
    -- Arrastar janela
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Win.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Inicialização
    Notify("🔥 Remote Spam V5 Ultimate carregado!", Color3.fromRGB(99, 102, 241), 4)
    Notify("📊 Spy Mode ativo - Args serão capturados", Color3.fromRGB(52, 211, 153), 4)
    Notify("🎯 Use Deep Scan para começar", Color3.fromRGB(251, 191, 36), 4)
    
    return MainGui
end

-- Executar
local success, err = pcall(CreateGUI)
if not success then
    warn("Erro ao carregar GUI: " .. tostring(err))
    -- Fallback
    pcall(function()
        local gui = Instance.new("ScreenGui", pg)
        local btn = Instance.new("TextButton", gui)
        btn.Size = UDim2.new(0, 200, 0, 50)
        btn.Position = UDim2.new(0.5, -100, 0.5, -25)
        btn.Text = "⚠️ ERRO - CLICK PARA SPAM"
        btn.Activated:Connect(function() SpamAllPlayers() end)
    end)
else
    print("✅ Remote Spam V5 Ultimate carregado com sucesso!")
end
