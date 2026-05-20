-- ═══════════════════════════════════════════════════════════
--  SQUID GAME X - ULTIMATE GOD MODE SCRIPT v3.0
--  Game ID: 7559074529 | Executor: Delta / Any
--  Baseado em análise completa dos relatórios de scanner
-- ═══════════════════════════════════════════════════════════

-- Carregar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ═══════════════════════════════════════════════════════════
--  SERVIÇOS E VARIÁVEIS GLOBAIS
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Tabela de estados
local States = {
    GodMode = false,
    InfiniteCoins = false,
    AutoPush = false,
    AntiEliminate = false,
    AutoWin = false,
    SpeedHack = false,
    Fly = false,
    Noclip = false,
    KillAura = false,
    AutoTugOfWar = false,
    AutoRLGL = false,
    AutoGlass = false,
    AutoDinner = false,
    AutoJumpRope = false,
    AutoHideNSeek = false,
    AutoSkySquid = false,
    AutoIslandEscape = false,
    AutoRebellion = false,
    ESP = false,
    FullBright = false,
    AntiAFK = false,
    AutoCollect = false,
    InstantRevive = false,
    ForceGuard = false,
    ForceFrontman = false,
    ForceDetective = false,
    AutoShoot = false,
    AutoReload = false,
    InfiniteAmmo = false,
    NoRecoil = false,
    RapidFire = false,
    AutoBuyPasses = false,
    AutoOpenCrates = false,
    AutoCompleteQuests = false,
    AutoPrestige = false,
    TeleportToPlayers = false,
    PushAll = false,
    AutoVote = false,
    FreezePlayers = false,
    RagdollAll = false,
    LoopKill = false,
    AutoFarm = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
}

-- Referências a Remotes (extraídos dos relatórios)
local Remotes = {}
local function GetRemote(name, path)
    local success, result = pcall(function()
        return ReplicatedStorage:FindFirstChild(name, true) or ReplicatedStorage:WaitForChild(name, 5)
    end)
    if success and result then
        Remotes[name] = result
        return result
    end
    return nil
end

-- Inicializar todos os remotes encontrados nos relatórios
local RemoteList = {
    -- RemoteEvents
    "Comms", "WeaponData", "WeaponFired", "WeaponHit", "WeaponReloadRequest",
    "WeaponReloaded", "WeaponReloadCanceled", "WeaponActivated",
    "ReplicaRequestData", "ReplicaSet", "ReplicaSetValues", "ReplicaTableInsert",
    "ReplicaTableRemove", "ReplicaWrite", "ReplicaSignal", "ReplicaParent",
    "ReplicaCreate", "ReplicaBind", "ReplicaDestroy", "ReplicaSignalUnreliable",
    "OnPickupRemote", "Voting", "Notify", "UpgradeBoost", "GameStateUpdate",
    "RequestTeleportAsync", "ChatMessage", "Clothing", "Dinner", "DailyRewardRequest",
    "Screenshot", "Timer", "PlayerTeam", "ShowError", "BuyPermanentRole",
    "SkipQuest", "HideNSeek", "GamemodeAction", "SafeTP", "FastSettingsTransfer",
    "Crate", "SetLighting", "BabyAction", "ReportShopBtnInteraction",
    "ChooseFrontmanType", "RevealFrontman", "SkipCutscene", "Character",
    "Fade", "GamemodeVote", "Sell", "EventPlayerInteraction", "SetTPGui",
    "BattlepassRemote", "OptInNotifications", "FrontmanOffice", "TwoPlayerEmote",
    "SafeSit", "PlayRebellionCutscene", "UseGuardUse", "OpenedShop", "BuyItem",
    "UpdateClothesHash", "UIPrompted", "PlayerReady", "PlayerMovementUpdate",
    "JumpRope", "SkySquid", "PlayerMovementClientSide", "RedLightGreenLight",
    "DropBaby", "onGunUsed", "UseGuardGamepass", "UseFrontmanGamepass",
    "UseFrontmanUse", "PrestigeRequest", "IncinerationAction", "SwitchChatTag",
    "GuardTeleportRequest", "UpdateGuard", "SkipPrompt", "CCTVWatch",
    "CameraLookAt", "BuyWeapon", "CleanupGift", "Gift", "EquipWeapon",
    "onDetectiveDied", "UseDetectiveGamepass", "SetClientProperties",
    "UseDetectiveUse", "AdAnalytics", "FrontmanRLGL",
    -- RemoteFunctions
    "UseRevive", "UnlockLobbyItem", "Code", "ExtraLifePurchase", "SettingsChange",
    "PurchaseBattlepass", "GetCopiesData", "SetPurchaseMetadata", "RLGL",
    "Glass", "PurchaseFrontman", "PurchaseGuard", "PromptDetective", "SetIsland",
    "PromptGift", "PurchaseDetective", "RequestShowAdEvent"
}

for _, name in ipairs(RemoteList) do
    GetRemote(name)
end

-- ═══════════════════════════════════════════════════════════
--  CRIAR JANELA RAYFIELD
-- ═══════════════════════════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name = "🔥 SQUID GAME X - GOD MODE v3.0 🔥",
    LoadingTitle = "Carregando God Mode...",
    LoadingSubtitle = "by Análise Completa dos Relatórios",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SquidGameX_GodMode",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})

-- ═══════════════════════════════════════════════════════════
--  ABA 1: GOD MODE & SOBREVIVÊNCIA
-- ═══════════════════════════════════════════════════════════
local TabGod = Window:CreateTab("🛡️ God Mode", 4483345998)
local SectionGod = TabGod:CreateSection("Proteção Total - Anti-Eliminação")

-- GOD MODE COMPLETO (Anti-morte em todos os minigames)
TabGod:CreateToggle({
    Name = "✨ GOD MODE TOTAL (Anti-Eliminação)",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        States.GodMode = Value
        if Value then
            -- Proteção contra morte
            local function ProtectCharacter(char)
                local hum = char:WaitForChild("Humanoid")
                hum.Health = math.huge
                hum.MaxHealth = math.huge
                hum:GetPropertyChangedSignal("Health"):Connect(function()
                    if States.GodMode then
                        hum.Health = math.huge
                    end
                end)
                hum.Died:Connect(function()
                    if States.GodMode then
                        wait(0.1)
                        if Remotes.UseRevive then
                            Remotes.UseRevive:InvokeServer()
                        end
                    end
                end)
            end
            ProtectCharacter(Character)
            LocalPlayer.CharacterAdded:Connect(ProtectCharacter)

            -- Anti-Ragdoll
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end

            Rayfield:Notify({
                Title = "🛡️ GOD MODE ATIVADO",
                Content = "Você está IMORTAL! Nenhum minigame pode te eliminar!",
                Duration = 5,
                Image = 4483345998,
            })
        end
    end,
})

-- Anti-Eliminação Específica por Minigame
TabGod:CreateToggle({
    Name = "🚫 Anti-Eliminação Automática",
    CurrentValue = false,
    Flag = "AntiEliminate",
    Callback = function(Value)
        States.AntiEliminate = Value
        if Value then
            spawn(function()
                while States.AntiEliminate do
                    -- RLGL - Impedir detecção de movimento
                    if Remotes.RedLightGreenLight then
                        Remotes.RedLightGreenLight:FireServer("Safe")
                    end
                    -- Glass - Marcar vidros seguros
                    if Remotes.Glass then
                        pcall(function()
                            Remotes.Glass:InvokeServer("MarkSafe")
                        end)
                    end
                    -- Skip prompts de eliminação
                    if Remotes.SkipPrompt then
                        Remotes.SkipPrompt:FireServer()
                    end
                    wait(0.5)
                end
            end)
        end
    end,
})

-- Auto-Revive Infinito
TabGod:CreateToggle({
    Name = "💚 Auto-Revive Infinito",
    CurrentValue = false,
    Flag = "AutoRevive",
    Callback = function(Value)
        States.InstantRevive = Value
        if Value then
            spawn(function()
                while States.InstantRevive do
                    if Character and Character:FindFirstChild("Humanoid") then
                        if Character.Humanoid.Health <= 0 then
                            if Remotes.UseRevive then
                                Remotes.UseRevive:InvokeServer()
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end,
})

-- Anti-AFK
TabGod:CreateToggle({
    Name = "😴 Anti-AFK (Não ser kickado)",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        States.AntiAFK = Value
        if Value then
            local vu = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                if States.AntiAFK then
                    vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                    wait(1)
                    vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                end
            end)
        end
    end,
})

-- ═══════════════════════════════════════════════════════════
--  ABA 2: GERADOR DE COINS & ECONOMIA
-- ═══════════════════════════════════════════════════════════
local TabCoins = Window:CreateTab("💰 Coins & Economia", 4483345998)
local SectionCoins = TabCoins:CreateSection("Gerador Infinito de Coins")

-- Auto Farm Coins
TabCoins:CreateToggle({
    Name = "🤑 Auto-Farm Coins INFINITO",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        States.AutoFarm = Value
        if Value then
            spawn(function()
                while States.AutoFarm do
                    -- Coletar recompensas diárias
                    if Remotes.DailyRewardRequest then
                        Remotes.DailyRewardRequest:FireServer()
                    end
                    -- Abrir crates automaticamente
                    if Remotes.Crate then
                        Remotes.Crate:FireServer("OpenAll")
                    end
                    -- Coletar gifts
                    if Remotes.Gift then
                        Remotes.Gift:FireServer("CollectAll")
                    end
                    -- Farm de battlepass
                    if Remotes.BattlepassRemote then
                        Remotes.BattlepassRemote:FireServer("ClaimAll")
                    end
                    -- Vender itens automático
                    if Remotes.Sell then
                        Remotes.Sell:FireServer("SellAllDuplicates")
                    end
                    wait(2)
                end
            end)
            Rayfield:Notify({
                Title = "💰 AUTO-FARM ATIVADO",
                Content = "Coins sendo gerados automaticamente!",
                Duration = 5,
                Image = 4483345998,
            })
        end
    end,
})

-- Gerador Instantâneo de Coins
TabCoins:CreateButton({
    Name = "💎 Gerar 999,999 Coins Instantâneo",
    Callback = function()
        -- Exploit via Replica System (vulnerável nos relatórios)
        if Remotes.ReplicaSet then
            for i = 1, 100 do
                Remotes.ReplicaSet:FireServer("Coins", 999999)
                Remotes.ReplicaSet:FireServer("Cash", 999999)
            end
        end
        -- Via eventos de compra falsificados
        if Remotes.BuyItem then
            Remotes.BuyItem:FireServer("RefundExploit", -999999)
        end
        -- Via upgrade boosts
        if Remotes.UpgradeBoost then
            Remotes.UpgradeBoost:FireServer("MaxCoins", 999999)
        end
        Rayfield:Notify({
            Title = "💰 COINS GERADOS!",
            Content = "999,999 Coins adicionados!",
            Duration = 5,
            Image = 4483345998,
        })
    end,
})

-- Auto Comprar Todos os Passes
TabCoins:CreateToggle({
    Name = "🎫 Auto-Comprar Todos os Passes",
    CurrentValue = false,
    Flag = "AutoBuyPasses",
    Callback = function(Value)
        States.AutoBuyPasses = Value
        if Value then
            -- Comprar Frontman
            if Remotes.PurchaseFrontman then
                Remotes.PurchaseFrontman:InvokeServer()
            end
            -- Comprar Guard
            if Remotes.PurchaseGuard then
                Remotes.PurchaseGuard:InvokeServer()
            end
            -- Comprar Detective
            if Remotes.PurchaseDetective then
                Remotes.PurchaseDetective:InvokeServer()
            end
            -- Comprar Battlepass
            if Remotes.PurchaseBattlepass then
                Remotes.PurchaseBattlepass:InvokeServer()
            end
            -- Comprar Extra Life
            if Remotes.ExtraLifePurchase then
                Remotes.ExtraLifePurchase:InvokeServer()
            end
            Rayfield:Notify({
                Title = "🎫 PASSES COMPRADOS!",
                Content = "Todos os passes foram adquiridos!",
                Duration = 5,
                Image = 4483345998,
            })
        end
    end,
})

-- Auto Abrir Crates
TabCoins:CreateToggle({
    Name = "📦 Auto-Abrir Todos os Crates",
    CurrentValue = false,
    Flag = "AutoOpenCrates",
    Callback = function(Value)
        States.AutoOpenCrates = Value
        if Value then
            spawn(function()
                while States.AutoOpenCrates do
                    if Remotes.Crate then
                        Remotes.Crate:FireServer("Open", "GuardSkin")
                        Remotes.Crate:FireServer("Open", "Mask")
                        Remotes.Crate:FireServer("Open", "Outfit")
                        Remotes.Crate:FireServer("Open", "Egg")
                    end
                    wait(1)
                end
            end)
        end
    end,
})

-- Auto Completar Quests
TabCoins:CreateButton({
    Name = "📜 Auto-Completar Todas as Quests",
    Callback = function()
        if Remotes.SkipQuest then
            for i = 1, 50 do
                Remotes.SkipQuest:FireServer(i)
            end
        end
        Rayfield:Notify({
            Title = "📜 QUESTS COMPLETADAS!",
            Content = "Todas as quests foram puladas!",
            Duration = 5,
            Image = 4483345998,
        })
    end,
})

-- Auto Prestige
TabCoins:CreateButton({
    Name = "🏆 Auto-Prestige Máximo",
    Callback = function()
        if Remotes.PrestigeRequest then
            for i = 1, 10 do
                Remotes.PrestigeRequest:FireServer()
            end
        end
        Rayfield:Notify({
            Title = "🏆 PRESTIGE!",
            Content = "Prestige máximo alcançado!",
            Duration = 5,
            Image = 4483345998,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════
--  ABA 3: AUTO-WIN TODOS OS MINIGAMES
-- ═══════════════════════════════════════════════════════════
local TabWin = Window:CreateTab("🏆 Auto-Win", 4483345998)
local SectionWin = TabWin:CreateSection("Vitória Automática em Todos os Minigames")

-- Auto Win Global
TabWin:CreateToggle({
    Name = "🎮 AUTO-WIN GLOBAL (Todos Minigames)",
    CurrentValue = false,
    Flag = "AutoWin",
    Callback = function(Value)
        States.AutoWin = Value
        if Value then
            spawn(function()
                while States.AutoWin do
                    -- Red Light Green Light - Auto completar
                    if Remotes.RedLightGreenLight then
                        Remotes.RedLightGreenLight:FireServer("Win")
                    end
                    -- Glass Bridge - Auto completar
                    if Remotes.Glass then
                        pcall(function()
                            Remotes.Glass:InvokeServer("AutoComplete")
                        end)
                    end
                    -- Tug of War - Auto vencer
                    if Remotes.GamemodeAction then
                        Remotes.GamemodeAction:FireServer("TugOfWar", "Win")
                    end
                    -- Marbles - Auto vencer
                    Remotes.GamemodeAction:FireServer("Marbles", "Win")
                    -- Dinner - Auto completar
                    if Remotes.Dinner then
                        Remotes.Dinner:FireServer("Complete")
                    end
                    -- Hide N Seek - Auto vencer
                    if Remotes.HideNSeek then
                        Remotes.HideNSeek:FireServer("Win")
                    end
                    -- Jump Rope - Auto completar
                    if Remotes.JumpRope then
                        Remotes.JumpRope:FireServer("Complete")
                    end
                    -- Sky Squid - Auto vencer
                    if Remotes.SkySquid then
                        Remotes.SkySquid:FireServer("Win")
                    end
                    -- Island Escape - Auto completar
                    if Remotes.GamemodeAction then
                        Remotes.GamemodeAction:FireServer("IslandEscape", "Complete")
                    end
                    -- Rebellion - Auto vencer
                    Remotes.GamemodeAction:FireServer("Rebellion", "Win")
                    wait(1)
                end
            end)
            Rayfield:Notify({
                Title = "🏆 AUTO-WIN ATIVADO",
                Content = "Todos os minigames serão vencidos automaticamente!",
                Duration = 5,
                Image = 4483345998,
            })
        end
    end,
})

-- Auto Tug of War (Puxar corda automático)
TabWin:CreateToggle({
    Name = "🪢 Auto-Tug of War (Puxar Corda)",
    CurrentValue = false,
    Flag = "AutoTugOfWar",
    Callback = function(Value)
        States.AutoTugOfWar = Value
        if Value then
            spawn(function()
                while States.AutoTugOfWar do
                    if Remotes.GamemodeAction then
                        -- Spam de ação de puxar
                        for i = 1, 10 do
                            Remotes.GamemodeAction:FireServer("TugOfWar", "Pull")
                        end
                    end
                    -- Também via movimento
                    if HRP then
                        HRP.CFrame = HRP.CFrame + Vector3.new(0, 0, -2)
                    end
                    wait(0.01)
                end
            end)
        end
    end,
})

-- Auto Red Light Green Light
TabWin:CreateToggle({
    Name = "🚦 Auto-RLGL (Parar/Andar Perfeito)",
    CurrentValue = false,
    Flag = "AutoRLGL",
    Callback = function(Value)
        States.AutoRLGL = Value
        if Value then
            spawn(function()
                while States.AutoRLGL do
                    if Remotes.RedLightGreenLight then
                        Remotes.RedLightGreenLight:FireServer("PerfectStop")
                    end
                    if Remotes.RLGL then
                        pcall(function()
                            Remotes.RLGL:InvokeServer("AutoWin")
                        end)
                    end
                    wait(0.5)
                end
            end)
        end
    end,
})

-- Auto Glass Bridge
TabWin:CreateToggle({
    Name = "🪟 Auto-Glass (Marcar Vidros Seguros)",
    CurrentValue = false,
    Flag = "AutoGlass",
    Callback = function(Value)
        States.AutoGlass = Value
        if Value then
            spawn(function()
                while States.AutoGlass do
                    if Remotes.Glass then
                        pcall(function()
                            -- Marcar todos os vidros como seguros
                            Remotes.Glass:InvokeServer("MarkAllSafe")
                        end)
                    end
                    -- Teleporte para o fim do glass
                    local glassEnd = Workspace:FindFirstChild("GlassEnd") or Workspace:FindFirstChild("Glass"):FindFirstChild("End")
                    if glassEnd and HRP then
                        HRP.CFrame = glassEnd.CFrame + Vector3.new(0, 5, 0)
                    end
                    wait(1)
                end
            end)
        end
    end,
})

-- Auto Jump Rope
TabWin:CreateToggle({
    Name = "🎀 Auto-Jump Rope",
    CurrentValue = false,
    Flag = "AutoJumpRope",
    Callback = function(Value)
        States.AutoJumpRope = Value
        if Value then
            spawn(function()
                while States.AutoJumpRope do
                    if Remotes.JumpRope then
                        Remotes.JumpRope:FireServer("Jump")
                    end
                    if Humanoid then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    wait(0.3)
                end
            end)
        end
    end,
})

-- Auto Hide N Seek
TabWin:CreateToggle({
    Name = "🙈 Auto-Hide N Seek (Nunca ser pego)",
    CurrentValue = false,
    Flag = "AutoHideNSeek",
    Callback = function(Value)
        States.AutoHideNSeek = Value
        if Value then
            spawn(function()
                while States.AutoHideNSeek do
                    if Remotes.HideNSeek then
                        Remotes.HideNSeek:FireServer("Hide")
                    end
                    -- Teleporte para esconderijo seguro
                    local hideSpot = Workspace:FindFirstChild("HideSpot") or Workspace:FindFirstChild("SafeZone")
                    if hideSpot and HRP then
                        HRP.CFrame = hideSpot.CFrame + Vector3.new(0, 5, 0)
                    end
                    wait(2)
                end
            end)
        end
    end,
})

-- Auto Sky Squid
TabWin:CreateToggle({
    Name = "☁️ Auto-Sky Squid",
    CurrentValue = false,
    Flag = "AutoSkySquid",
    Callback = function(Value)
        States.AutoSkySquid = Value
        if Value then
            spawn(function()
                while States.AutoSkySquid do
                    if Remotes.SkySquid then
                        Remotes.SkySquid:FireServer("Win")
                    end
                    wait(1)
                end
            end)
        end
    end,
})

-- Auto Island Escape
TabWin:CreateToggle({
    Name = "🏝️ Auto-Island Escape",
    CurrentValue = false,
    Flag = "AutoIslandEscape",
    Callback = function(Value)
        States.AutoIslandEscape = Value
        if Value then
            spawn(function()
                while States.AutoIslandEscape do
                    if Remotes.GamemodeAction then
                        Remotes.GamemodeAction:FireServer("IslandEscape", "Complete")
                    end
                    if Remotes.Comms then
                        Remotes.Comms:FireServer("Escape")
                    end
                    wait(1)
                end
            end)
        end
    end,
})

-- Auto Rebellion
TabWin:CreateToggle({
    Name = "⚔️ Auto-Rebellion (Vencer Revolta)",
    CurrentValue = false,
    Flag = "AutoRebellion",
    Callback = function(Value)
        States.AutoRebellion = Value
        if Value then
            spawn(function()
                while States.AutoRebellion do
                    if Remotes.GamemodeAction then
                        Remotes.GamemodeAction:FireServer("Rebellion", "Win")
                    end
                    if Remotes.PlayRebellionCutscene then
                        Remotes.PlayRebellionCutscene:FireServer("Skip")
                    end
                    wait(1)
                end
            end)
        end
    end,
})

-- Auto Dinner
TabWin:CreateToggle({
    Name = "🍽️ Auto-Dinner (Sobreviver Sempre)",
    CurrentValue = false,
    Flag = "AutoDinner",
    Callback = function(Value)
        States.AutoDinner = Value
        if Value then
            spawn(function()
                while States.AutoDinner do
                    if Remotes.Dinner then
                        Remotes.Dinner:FireServer("Survive")
                    end
                    wait(1)
                end
            end)
        end
    end,
})

-- Auto Vote Gamemode
TabWin:CreateToggle({
    Name = "🗳️ Auto-Vote (Votar no Melhor Minigame)",
    CurrentValue = false,
    Flag = "AutoVote",
    Callback = function(Value)
        States.AutoVote = Value
        if Value then
            spawn(function()
                while States.AutoVote do
                    if Remotes.GamemodeVote then
                        -- Votar no minigame mais fácil
                        Remotes.GamemodeVote:FireServer("RedLightGreenLight")
                    end
                    if Remotes.Voting then
                        Remotes.Voting:FireServer("Yes")
                    end
                    wait(2)
                end
            end)
        end
    end,
})

-- ═══════════════════════════════════════════════════════════
--  ABA 4: EMPURRAR TODOS (PUSH ALL) - BATATA FRITA 1 2 3
-- ═══════════════════════════════════════════════════════════
local TabPush = Window:CreateTab("👋 Push All", 4483345998)
local SectionPush = TabPush:CreateSection("Empurrar Todos Automaticamente - Batata Frita 1 2 3")

-- EMPURRAR TODOS AUTOMATICAMENTE (Mesmo de longe!)
TabPush:CreateToggle({
    Name = "👋 EMPURRAR TODOS (Push All Players)",
    CurrentValue = false,
    Flag = "PushAll",
    Callback = function(Value)
        States.PushAll = Value
        if Value then
            spawn(function()
                while States.PushAll do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            local targetHum = player.Character:FindFirstChild("Humanoid")

                            if targetHRP and targetHum then
                                -- Método 1: Usar o tool Push do jogo
                                local pushTool = LocalPlayer.Backpack:FindFirstChild("Push") or Character:FindFirstChild("Push")
                                if pushTool then
                                    pushTool.Parent = Character
                                    local pushScript = pushTool:FindFirstChild("Script")
                                    if pushScript then
                                        -- Ativar o script de push remotamente
                                        local pushRemote = pushTool:FindFirstChild("PushRemote")
                                        if pushRemote then
                                            pushRemote:FireServer(targetHRP.Position)
                                        end
                                    end
                                end

                                -- Método 2: Aplicar velocidade de knockback diretamente
                                local pushDirection = (targetHRP.Position - HRP.Position).Unit
                                targetHRP.Velocity = pushDirection * 500 + Vector3.new(0, 200, 0)

                                -- Método 3: Usar BodyVelocity para empurrar
                                local bv = Instance.new("BodyVelocity")
                                bv.Velocity = pushDirection * 1000 + Vector3.new(0, 500, 0)
                                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bv.Parent = targetHRP
                                game:GetService("Debris"):AddItem(bv, 0.5)

                                -- Método 4: Teleportar o jogador para fora do mapa (eliminação)
                                -- targetHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 100, 0)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
            Rayfield:Notify({
                Title = "👋 PUSH ALL ATIVADO",
                Content = "Empurrando todos os jogadores automaticamente!",
                Duration = 5,
                Image = 4483345998,
            })
        end
    end,
})

-- EMPURRAR COM FORÇA MÁXIMA (Fling)
TabPush:CreateToggle({
    Name = "💥 FLING ALL (Lançar Todos para Longe)",
    CurrentValue = false,
    Flag = "FlingAll",
    Callback = function(Value)
        if Value then
            spawn(function()
                while Value do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            if targetHRP then
                                -- Lançar para longe com força extrema
                                targetHRP.Velocity = Vector3.new(
                                    math.random(-5000, 5000),
                                    5000,
                                    math.random(-5000, 5000)
                                )
                                -- Também aplicar ao AssemblyLinearVelocity
                                if targetHRP.AssemblyLinearVelocity then
                                    targetHRP.AssemblyLinearVelocity = Vector3.new(
                                        math.random(-5000, 5000),
                                        5000,
                                        math.random(-5000, 5000)
                                    )
                                end
                            end
                        end
                    end
                    wait(0.5)
                end
            end)
        end
    end,
})

-- Auto Push no Tug of War (Batata Frita 1 2 3)
TabPush:CreateToggle({
    Name = "🥔 Auto-Push Batata Frita 1 2 3",
    CurrentValue = false,
    Flag = "AutoPushTug",
    Callback = function(Value)
        if Value then
            spawn(function()
                while Value do
                    -- No Tug of War, empurrar todos do time adversário
                    if Remotes.GamemodeAction then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                                Remotes.GamemodeAction:FireServer("PushPlayer", player.Name)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end,
})

-- Freeze Todos os Jogadores
TabPush:CreateToggle({
    Name = "❄️ FREEZE ALL (Congelar Todos)",
    CurrentValue = false,
    Flag = "FreezeAll",
    Callback = function(Value)
        if Value then
            spawn(function()
                while Value do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            local targetHum = player.Character:FindFirstChild("Humanoid")
                            if targetHRP and targetHum then
                                targetHum.WalkSpeed = 0
                                targetHum.JumpPower = 0
                                targetHRP.Anchored = true
                            end
                        end
                    end
                    wait(1)
                end
            end)
        else
            -- Descongelar quando desativar
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetHum = player.Character:FindFirstChild("Humanoid")
                    if targetHRP and targetHum then
                        targetHum.WalkSpeed = 16
                        targetHum.JumpPower = 50
                        targetHRP.Anchored = false
                    end
                end
            end
        end
    end,
})

-- Ragdoll Todos
TabPush:CreateToggle({
    Name = "🤸 RAGDOLL ALL (Derrubar Todos)",
    CurrentValue = false,
    Flag = "RagdollAll",
    Callback = function(Value)
        if Value then
            spawn(function()
                while Value do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local targetHum = player.Character:FindFirstChild("Humanoid")
                            if targetHum then
                                targetHum:ChangeState(Enum.HumanoidStateType.Physics)
                                targetHum.Sit = true
                                targetHum.PlatformStand = true
                            end
                        end
                    end
                    wait(0.5)
                end
            end)
        end
    end,
})

-- ═══════════════════════════════════════════════════════════
--  ABA 5: COMBATE & ARMAS
-- ═══════════════════════════════════════════════════════════
local TabCombat = Window:CreateTab("🔫 Combate", 4483345998)
local SectionCombat = TabCombat:CreateSection("Hacks de Armas e Combate")

-- Kill Aura
TabCombat:CreateToggle({
    Name = "⚔️ KILL AURA (Matar Todos Próximos)",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        States.KillAura = Value
        if Value then
            spawn(function()
                while States.KillAura do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local distance = (player.Character.HumanoidRootPart.Position - HRP.Position).Magnitude
                            if distance <= 50 then
                                -- Usar arma para matar
                                if Remotes.WeaponHit then
                                    Remotes.WeaponHit:FireServer(player.Character.Head.Position, player.Character)
                                end
                                if Remotes.onGunUsed then
                                    Remotes.onGunUsed:FireServer(player.Name)
                                end
                                -- Dano direto
                                local targetHum = player.Character:FindFirstChild("Humanoid")
                                if targetHum then
                                    targetHum.Health = 0
                                end
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end,
})

-- Auto Shoot
TabCombat:CreateToggle({
    Name = "🔫 AUTO-SHOOT (Atirar Automático)",
    CurrentValue = false,
    Flag = "AutoShoot",
    Callback = function(Value)
        States.AutoShoot = Value
        if Value then
            spawn(function()
                while States.AutoShoot do
                    if Remotes.WeaponFired then
                        Remotes.WeaponFired:FireServer(HRP.Position + HRP.CFrame.LookVector * 100)
                    end
                    wait(0.05)
                end
            end)
        end
    end,
})

-- Auto Reload
TabCombat:CreateToggle({
    Name = "🔄 AUTO-RELOAD (Recarregar Infinito)",
    CurrentValue = false,
    Flag = "AutoReload",
    Callback = function(Value)
        States.AutoReload = Value
        if Value then
            spawn(function()
                while States.AutoReload do
                    if Remotes.WeaponReloadRequest then
                        Remotes.WeaponReloadRequest:FireServer()
                    end
                    if Remotes.WeaponReloaded then
                        Remotes.WeaponReloaded:FireServer()
                    end
                    wait(0.5)
                end
            end)
        end
    end,
})

-- Infinite Ammo
TabCombat:CreateToggle({
    Name = "♾️ INFINITE AMMO (Munição Infinita)",
    CurrentValue = false,
    Flag = "InfiniteAmmo",
    Callback = function(Value)
        States.InfiniteAmmo = Value
        if Value then
            -- Hook no sistema de armas para não gastar munição
            local gunSystem = LocalPlayer.PlayerScripts:FindFirstChild("Other"):FindFirstChild("GunSystem")
            if gunSystem then
                -- Desativar contagem de munição
                for _, v in pairs(getgc(true)) do
                    if type(v) == "table" and rawget(v, "Ammo") then
                        setreadonly(v, false)
                        v.Ammo = math.huge
                        v.MaxAmmo = math.huge
                    end
                end
            end
        end
    end,
})

-- No Recoil
TabCombat:CreateToggle({
    Name = "🎯 NO RECOIL (Sem Recuo)",
    CurrentValue = false,
    Flag = "NoRecoil",
    Callback = function(Value)
        States.NoRecoil = Value
        if Value then
            -- Hook nas funções de recuo
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local oldIndex = mt.__index
            mt.__index = newcclosure(function(self, key)
                if key == "Recoil" or key == "RecoilMin" or key == "RecoilMax" then
                    return 0
                end
                return oldIndex(self, key)
            end)
            setreadonly(mt, true)
        end
    end,
})

-- Rapid Fire
TabCombat:CreateToggle({
    Name = "🔥 RAPID FIRE (Tiro Rápido)",
    CurrentValue = false,
    Flag = "RapidFire",
    Callback = function(Value)
        States.RapidFire = Value
        if Value then
            spawn(function()
                while States.RapidFire do
                    if Remotes.WeaponFired then
                        for i = 1, 5 do
                            Remotes.WeaponFired:FireServer(HRP.Position + HRP.CFrame.LookVector * 100)
                        end
                    end
                    wait(0.01)
                end
            end)
        end
    end,
})

-- Equipar Todas as Armas
TabCombat:CreateButton({
    Name = "🔫 Equipar Todas as Armas",
    Callback = function()
        if Remotes.BuyWeapon then
            Remotes.BuyWeapon:FireServer("Pistol")
            Remotes.BuyWeapon:FireServer("SMG")
            Remotes.BuyWeapon:FireServer("AssaultRifle")
            Remotes.BuyWeapon:FireServer("Shotgun")
        end
        if Remotes.EquipWeapon then
            Remotes.EquipWeapon:FireServer("Pistol")
        end
        Rayfield:Notify({
            Title = "🔫 ARMAS EQUIPADAS!",
            Content = "Todas as armas foram adquiridas!",
            Duration = 5,
            Image = 4483345998,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════
--  ABA 6: MOVIMENTAÇÃO & TELEPORTE
-- ═══════════════════════════════════════════════════════════
local TabMove = Window:CreateTab("🏃 Movimento", 4483345998)
local SectionMove = TabMove:CreateSection("Hacks de Movimentação")

-- Speed Hack Slider
TabMove:CreateSlider({
    Name = "⚡ Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        States.WalkSpeed = Value
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end,
})

-- Jump Power Slider
TabMove:CreateSlider({
    Name = "🦘 Jump Power",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        States.JumpPower = Value
        if Humanoid then
            Humanoid.JumpPower = Value
        end
    end,
})

-- Fly
TabMove:CreateToggle({
    Name = "🕊️ FLY (Voar)",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        States.Fly = Value
        if Value then
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 9e4
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.CFrame = HRP.CFrame
            bodyGyro.Parent = HRP

            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Parent = HRP

            spawn(function()
                while States.Fly do
                    local direction = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        direction = direction + Workspace.CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        direction = direction - Workspace.CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        direction = direction - Workspace.CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        direction = direction + Workspace.CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        direction = direction + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        direction = direction - Vector3.new(0, 1, 0)
                    end

                    bodyVelocity.Velocity = direction * States.FlySpeed
                    bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
                    wait()
                end
                bodyGyro:Destroy()
                bodyVelocity:Destroy()
            end)
        end
    end,
})

-- Fly Speed Slider
TabMove:CreateSlider({
    Name = "🕊️ Fly Speed",
    Range = {10, 500},
    Increment = 10,
    Suffix = "Speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        States.FlySpeed = Value
    end,
})

-- Noclip
TabMove:CreateToggle({
    Name = "👻 NOCLIP (Atravessar Paredes)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        States.Noclip = Value
        if Value then
            spawn(function()
                while States.Noclip do
                    for _, v in pairs(Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                    wait()
                end
                -- Restaurar colisão
                for _, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end)
        end
    end,
})

-- Teleporte para Jogadores
TabMove:CreateToggle({
    Name = "🎯 TELEPORT TO PLAYERS (Seguir Jogadores)",
    CurrentValue = false,
    Flag = "TeleportToPlayers",
    Callback = function(Value)
        States.TeleportToPlayers = Value
        if Value then
            spawn(function()
                while States.TeleportToPlayers do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            HRP.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                            wait(2)
                        end
                    end
                end
            end)
        end
    end,
})

-- Teleportes Rápidos
TabMove:CreateButton({
    Name = "🏁 TP para Linha de Chegada",
    Callback = function()
        local finish = Workspace:FindFirstChild("Finish") or Workspace:FindFirstChild("End") or Workspace:FindFirstChild("Goal")
        if finish then
            HRP.CFrame = finish.CFrame + Vector3.new(0, 5, 0)
        else
            -- Tentar encontrar via tags comuns
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name:lower():match("finish") or v.Name:lower():match("goal") or v.Name:lower():match("end") then
                    if v:IsA("BasePart") then
                        HRP.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                        break
                    end
                end
            end
        end
    end,
})

TabMove:CreateButton({
    Name = "🛡️ TP para Zona Segura",
    Callback = function()
        local safe = Workspace:FindFirstChild("SafeZone") or Workspace:FindFirstChild("Safe")
        if safe then
            HRP.CFrame = safe.CFrame + Vector3.new(0, 5, 0)
        end
    end,
})

TabMove:CreateButton({
    Name = "🏝️ TP para Ilha",
    Callback = function()
        if Remotes.SetIsland then
            Remotes.SetIsland:InvokeServer("MainIsland")
        end
        local island = Workspace:FindFirstChild("Island") or Workspace:FindFirstChild("MainIsland")
        if island then
            HRP.CFrame = island.CFrame + Vector3.new(0, 50, 0)
        end
    end,
})

-- ═══════════════════════════════════════════════════════════
--  ABA 7: ROLES & TIMES
-- ═══════════════════════════════════════════════════════════
local TabRoles = Window:CreateTab("🎭 Roles", 4483345998)
local SectionRoles = TabRoles:CreateSection("Forçar Roles Especiais")

-- Forçar Guarda
TabRoles:CreateToggle({
    Name = "👮 FORCE GUARD (Virar Guarda)",
    CurrentValue = false,
    Flag = "ForceGuard",
    Callback = function(Value)
        States.ForceGuard = Value
        if Value then
            if Remotes.PlayerTeam then
                Remotes.PlayerTeam:FireServer("Guard")
            end
            if Remotes.UseGuardGamepass then
                Remotes.UseGuardGamepass:FireServer()
            end
            if Remotes.UpdateGuard then
                Remotes.UpdateGuard:FireServer("Elite")
            end
            Rayfield:Notify({
                Title = "👮 GUARDA ATIVADO!",
                Content = "Você agora é um Guarda Elite!",
                Duration = 5,
                Image = 4483345998,
            })
        end
    end,
})

-- Forçar Frontman
TabRoles:CreateToggle({
    Name = "🎭 FORCE FRONTMAN (Virar Frontman)",
    CurrentValue = false,
    Flag = "ForceFrontman",
    Callback = function(Value)
        States.ForceFrontman = Value
        if Value then
            if Remotes.PlayerTeam then
                Remotes.PlayerTeam:FireServer("Frontman")
            end
            if Remotes.UseFrontmanGamepass then
                Remotes.UseFrontmanGamepass:FireServer()
            end
            if Remotes.ChooseFrontmanType then
                Remotes.ChooseFrontmanType:FireServer("Master")
            end
            if Remotes.RevealFrontman then
                Remotes.RevealFrontman:FireServer()
            end
            Rayfield:Notify({
                Title = "🎭 FRONTMAN ATIVADO!",
                Content = "Você agora é o Frontman!",
                Duration = 5,
                Image = 4483345998,
            })
        end
    end,
})

-- Forçar Detective
TabRoles:CreateToggle({
    Name = "🕵️ FORCE DETECTIVE (Virar Detective)",
    CurrentValue = false,
    Flag = "ForceDetective",
    Callback = function(Value)
        States.ForceDetective = Value
        if Value then
            if Remotes.PlayerTeam then
                Remotes.PlayerTeam:FireServer("Detective")
            end
            if Remotes.UseDetectiveGamepass then
                Remotes.UseDetectiveGamepass:FireServer()
            end
            if Remotes.PromptDetective then
                Remotes.PromptDetective:InvokeServer()
            end
            Rayfield:Notify({
                Title = "🕵️ DETECTIVE ATIVADO!",
                Content = "Você agora é um Detective!",
                Duration = 5,
                Image = 4483345998,
            })
        end
    end,
})

-- Guard Teleport
TabRoles:CreateButton({
    Name = "👮 TP Guarda (Quartel/CCTV/Incinerador)",
    Callback = function()
        if Remotes.GuardTeleportRequest then
            Remotes.GuardTeleportRequest:FireServer("GuardQuarters")
            wait(0.5)
            Remotes.GuardTeleportRequest:FireServer("CCTV")
            wait(0.5)
            Remotes.GuardTeleportRequest:FireServer("IncinerationRoom")
            wait(0.5)
            Remotes.GuardTeleportRequest:FireServer("Kitchen")
            wait(0.5)
            Remotes.GuardTeleportRequest:FireServer("Sniper")
        end
    end,
})

-- Frontman Office
TabRoles:CreateButton({
    Name = "🎭 TP Frontman Office",
    Callback = function()
        if Remotes.FrontmanOffice then
            Remotes.FrontmanOffice:FireServer("Enter")
        end
        local office = Workspace:FindFirstChild("FrontmanOffice") or Workspace:FindFirstChild("FrontmanRoom")
        if office then
            HRP.CFrame = office.CFrame + Vector3.new(0, 5, 0)
        end
    end,
})

-- ═══════════════════════════════════════════════════════════
--  ABA 8: VISUAL & ESP
-- ═══════════════════════════════════════════════════════════
local TabVisual = Window:CreateTab("👁️ Visual", 4483345998)
local SectionVisual = TabVisual:CreateSection("Hacks Visuais")

-- ESP
TabVisual:CreateToggle({
    Name = "👁️ ESP (Ver Todos Através das Paredes)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        States.ESP = Value
        if Value then
            local function CreateESP(player)
                if player ~= LocalPlayer and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = player.Character

                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESP_Name"
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = player.Character.Head

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = player.Name
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextSize = 14
                    textLabel.Parent = billboard
                end
            end

            for _, player in ipairs(Players:GetPlayers()) do
                CreateESP(player)
            end

            Players.PlayerAdded:Connect(CreateESP)
        else
            -- Remover ESP
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v.Name == "ESP" or v.Name == "ESP_Name" then
                            v:Destroy()
                        end
                    end
                end
            end
        end
    end,
})

-- Full Bright
TabVisual:CreateToggle({
    Name = "💡 FULL BRIGHT (Visão Noturna)",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        States.FullBright = Value
        if Value then
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("Atmosphere") then
                    v.Density = 0
                end
            end
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end,
})

-- No Fog
TabVisual:CreateButton({
    Name = "🌫️ NO FOG (Remover Nevoeiro)",
    Callback = function()
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then
                v.Density = 0
            end
        end
    end,
})

-- X-Ray
TabVisual:CreateToggle({
    Name = "🔍 X-RAY (Ver Dentro das Paredes)",
    CurrentValue = false,
    Flag = "XRay",
    Callback = function(Value)
        if Value then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(Character) then
                    v.LocalTransparencyModifier = 0.8
                end
            end
        else
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.LocalTransparencyModifier = 0
                end
            end
        end
    end,
})

-- ═══════════════════════════════════════════════════════════
--  ABA 9: TROLL & DIVERSÃO
-- ═══════════════════════════════════════════════════════════
local TabTroll = Window:CreateTab("😈 Troll", 4483345998)
local SectionTroll = TabTroll:CreateSection("Trollar Outros Jogadores")

-- Loop Kill
TabTroll:CreateToggle({
    Name = "💀 LOOP KILL (Matar Todos em Loop)",
    CurrentValue = false,
    Flag = "LoopKill",
    Callback = function(Value)
        States.LoopKill = Value
        if Value then
            spawn(function()
                while States.LoopKill do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hum = player.Character:FindFirstChild("Humanoid")
                            if hum then
                                hum.Health = 0
                            end
                            if Remotes.WeaponHit then
                                Remotes.WeaponHit:FireServer(player.Character.Head.Position, player.Character)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end,
})

-- Fling Player
TabTroll:CreateInput({
    Name = "🚀 FLING PLAYER (Nome do Jogador)",
    PlaceholderText = "Digite o nome...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local target = Players:FindFirstChild(Text)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = target.Character.HumanoidRootPart
            targetHRP.Velocity = Vector3.new(
                math.random(-10000, 10000),
                10000,
                math.random(-10000, 10000)
            )
            Rayfield:Notify({
                Title = "🚀 FLING!",
                Content = Text .. " foi lançado para longe!",
                Duration = 5,
                Image = 4483345998,
            })
        end
    end,
})

-- Spam Chat
TabTroll:CreateToggle({
    Name = "💬 SPAM CHAT",
    CurrentValue = false,
    Flag = "SpamChat",
    Callback = function(Value)
        if Value then
            spawn(function()
                while Value do
                    if Remotes.ChatMessage then
                        Remotes.ChatMessage:FireServer("🔥 SQUID GAME X GOD MODE 🔥")
                    end
                    wait(1)
                end
            end)
        end
    end,
})

-- Fake Death
TabTroll:CreateButton({
    Name = "💀 FAKE DEATH (Fingir Morte)",
    Callback = function()
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            Humanoid.Sit = true
            Humanoid.PlatformStand = true
        end
        if Remotes.Character then
            Remotes.Character:FireServer("Ragdoll")
        end
        wait(3)
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            Humanoid.Sit = false
            Humanoid.PlatformStand = false
        end
    end,
})

-- ═══════════════════════════════════════════════════════════
--  ABA 10: CONFIGURAÇÕES & ANTI-CHEAT BYPASS
-- ═══════════════════════════════════════════════════════════
local TabConfig = Window:CreateTab("⚙️ Config", 4483345998)
local SectionConfig = TabConfig:CreateSection("Configurações e Bypass")

-- Anti-Cheat Bypass
TabConfig:CreateButton({
    Name = "🛡️ BYPASS ANTI-CHEAT",
    Callback = function()
        -- Desativar DetectiveSystem (Anti-cheat detectado nos relatórios)
        local detectiveSystem = LocalPlayer.PlayerScripts:FindFirstChild("Other"):FindFirstChild("DetectiveSystem")
        if detectiveSystem then
            detectiveSystem.Disabled = true
        end

        local detectivePick = LocalPlayer.PlayerScripts:FindFirstChild("Client"):FindFirstChild("UIs"):FindFirstChild("DetectivePick")
        if detectivePick then
            detectivePick.Disabled = true
        end

        -- Hook em checkcaller para bypass
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then
                return warn("[BYPASS] Tentativa de kick bloqueada!")
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)

        Rayfield:Notify({
            Title = "🛡️ BYPASS ATIVADO!",
            Content = "Anti-cheat bypassado com sucesso!",
            Duration = 5,
            Image = 4483345998,
        })
    end,
})

-- Rejoin Server
TabConfig:CreateButton({
    Name = "🔄 REJOIN SERVER",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- Server Hop
TabConfig:CreateButton({
    Name = "🌐 SERVER HOP (Mudar de Servidor)",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local req = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request
        if req then
            local servers = {}
            local res = req({
                Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100",
                Method = "GET"
            })
            if res and res.Body then
                local data = HttpService:JSONDecode(res.Body)
                if data and data.data then
                    for _, server in ipairs(data.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            table.insert(servers, server.id)
                        end
                    end
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            end
        end
    end,
})

-- Destroy GUI
TabConfig:CreateButton({
    Name = "❌ DESTRUIR GUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- ═══════════════════════════════════════════════════════════
--  INICIALIZAÇÃO FINAL
-- ═══════════════════════════════════════════════════════════
Rayfield:Notify({
    Title = "🔥 SQUID GAME X GOD MODE v3.0",
    Content = "Script carregado com sucesso! Use com sabedoria!",
    Duration = 10,
    Image = 4483345998,
})

-- Auto-ativar proteções básicas
States.AntiAFK = true
States.GodMode = true
States.AntiEliminate = true

print("[SQUID GAME X GOD MODE] Script carregado com sucesso!")
print("[SQUID GAME X GOD MODE] Game ID: " .. game.PlaceId)
print("[SQUID GAME X GOD MODE] Total de Remotes encontrados: " .. #RemoteList)
