--[[
    ╔═══════════════════════════════════════════════════════════════════════════════════╗
    ║                                                                                   ║
    ║     ██████╗ ██╗███╗   ██╗ ██████╗ ████████╗ █████╗     ███████╗ ██████╗██████╗ ██╗████████╗██████╗ ███████╗
    ║     ██╔══██╗██║████╗  ██║██╔═══██╗╚══██╔══╝██╔══██╗    ██╔════╝██╔════╝██╔══██╗██║╚══██╔══╝██╔══██╗██╔════╝
    ║     ██████╔╝██║██╔██╗ ██║██║   ██║   ██║   ███████║    ███████╗██║     ██████╔╝██║   ██║   ██████╔╝███████╗
    ║     ██╔══██╗██║██║╚██╗██║██║   ██║   ██║   ██╔══██║    ╚════██║██║     ██╔══██╗██║   ██║   ██╔══██╗╚════██║
    ║     ██║  ██║██║██║ ╚████║╚██████╔╝   ██║   ██║  ██║    ███████║╚██████╗██║  ██║██║   ██║   ██║  ██║███████║
    ║     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
    ║                                                                                   ║
    ║                              ULTRA PREMIUM EDITION v4.0                           ║
    ║                              Game: Ugc (ID: 70876832253163)                       ║
    ║                              Audit Date: 10/04/2026                               ║
    ║                                                                                   ║
    ╚═══════════════════════════════════════════════════════════════════════════════════╝
    
    Features:
    ✓ Ultra-Modern UI (Ghost Hub / Nihon Style)
    ✓ Console/Debug Output System
    ✓ Keybind System (F4 = Toggle UI)
    ✓ Multiple Themes (Dark, Purple, Blue, Red, Green)
    ✓ Advanced ESP with Skeleton
    ✓ Smart Auto-Farm with Pathfinding
    ✓ Remote Event Scanner & Logger
    ✓ Script Hub with Categories
    ✓ Player List with Teleport
    ✓ Real-time Stats Monitor
    ✓ Notification Center
    ✓ Draggable & Resizable Window
]]

-- ═════════════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═════════════════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═════════════════════════════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES ULTRA PREMIUM
-- ═════════════════════════════════════════════════════════════════════════════════════
local Config = {
    Version = "4.0 Ultra Premium",
    Keybind = Enum.KeyCode.F4,
    
    Themes = {
        Dark = {
            Primary = Color3.fromRGB(88, 101, 242),      -- Discord Blurple
            Secondary = Color3.fromRGB(57, 60, 67),       -- Dark Gray
            Accent = Color3.fromRGB(88, 101, 242),
            Background = Color3.fromRGB(30, 31, 34),      -- Discord Dark
            Surface = Color3.fromRGB(43, 45, 49),         -- Discord Surface
            SurfaceLight = Color3.fromRGB(54, 57, 63),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(185, 187, 190),
            Success = Color3.fromRGB(59, 165, 93),        -- Discord Green
            Error = Color3.fromRGB(237, 66, 69),          -- Discord Red
            Warning = Color3.fromRGB(250, 168, 26),       -- Discord Yellow
            Info = Color3.fromRGB(88, 101, 242)           -- Discord Blurple
        },
        Purple = {
            Primary = Color3.fromRGB(147, 112, 219),
            Secondary = Color3.fromRGB(75, 0, 130),
            Accent = Color3.fromRGB(255, 215, 0),
            Background = Color3.fromRGB(20, 20, 30),
            Surface = Color3.fromRGB(35, 35, 50),
            SurfaceLight = Color3.fromRGB(50, 50, 70),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(180, 180, 180),
            Success = Color3.fromRGB(0, 255, 127),
            Error = Color3.fromRGB(255, 69, 69),
            Warning = Color3.fromRGB(255, 165, 0),
            Info = Color3.fromRGB(147, 112, 219)
        },
        Blue = {
            Primary = Color3.fromRGB(0, 150, 255),
            Secondary = Color3.fromRGB(0, 80, 150),
            Accent = Color3.fromRGB(0, 255, 255),
            Background = Color3.fromRGB(15, 25, 40),
            Surface = Color3.fromRGB(25, 40, 65),
            SurfaceLight = Color3.fromRGB(35, 55, 90),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(180, 200, 220),
            Success = Color3.fromRGB(0, 255, 150),
            Error = Color3.fromRGB(255, 80, 80),
            Warning = Color3.fromRGB(255, 200, 0),
            Info = Color3.fromRGB(0, 150, 255)
        },
        Red = {
            Primary = Color3.fromRGB(220, 50, 50),
            Secondary = Color3.fromRGB(150, 30, 30),
            Accent = Color3.fromRGB(255, 100, 100),
            Background = Color3.fromRGB(30, 15, 15),
            Surface = Color3.fromRGB(50, 25, 25),
            SurfaceLight = Color3.fromRGB(70, 35, 35),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(220, 180, 180),
            Success = Color3.fromRGB(100, 255, 100),
            Error = Color3.fromRGB(255, 50, 50),
            Warning = Color3.fromRGB(255, 150, 50),
            Info = Color3.fromRGB(220, 50, 50)
        },
        Green = {
            Primary = Color3.fromRGB(50, 200, 100),
            Secondary = Color3.fromRGB(30, 120, 60),
            Accent = Color3.fromRGB(100, 255, 150),
            Background = Color3.fromRGB(15, 30, 20),
            Surface = Color3.fromRGB(25, 50, 35),
            SurfaceLight = Color3.fromRGB(35, 70, 50),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(180, 220, 190),
            Success = Color3.fromRGB(50, 255, 100),
            Error = Color3.fromRGB(255, 100, 100),
            Warning = Color3.fromRGB(255, 200, 50),
            Info = Color3.fromRGB(50, 200, 100)
        }
    },
    
    CurrentTheme = "Dark",
    
    Animations = {
        Enabled = true,
        Speed = 0.25,
        Easing = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out
    },
    
    Sounds = {
        Enabled = true,
        Volume = 0.3,
        Click = 9113083740,
        Hover = 9113083741,
        Success = 9113083742,
        Error = 9113083743,
        Notification = 9113083744
    }
}

-- ═════════════════════════════════════════════════════════════════════════════════════
-- CONSOLE SYSTEM
-- ═════════════════════════════════════════════════════════════════════════════════════
local Console = {
    Logs = {},
    MaxLogs = 100,
    Enabled = true,
    AutoScroll = true
}

function Console.Log(message, type)
    type = type or "info"
    local timestamp = os.date("%H:%M:%S")
    local logEntry = {
        Message = message,
        Type = type,
        Time = timestamp
    }
    
    table.insert(Console.Logs, logEntry)
    
    if #Console.Logs > Console.MaxLogs then
        table.remove(Console.Logs, 1)
    end
    
    print("[" .. timestamp .. "] [" .. type:upper() .. "] " .. message)
    
    -- Update UI if exists
    if Console.UI and Console.UI.Update then
        Console.UI.Update()
    end
end

function Console.Clear()
    Console.Logs = {}
    if Console.UI and Console.UI.Update then
        Console.UI.Update()
    end
    Console.Log("Console cleared", "info")
end

function Console.Export()
    local output = ""
    for _, log in ipairs(Console.Logs) do
        output = output .. "[" .. log.Time .. "] [" .. log.Type:upper() .. "] " .. log.Message .. "\n"
    end
    return output
end

-- ═════════════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION CENTER
-- ═════════════════════════════════════════════════════════════════════════════════════
local NotificationCenter = {
    Queue = {},
    Active = {},
    MaxActive = 5,
    Position = UDim2.new(1, -320, 1, -20)
}

function NotificationCenter.Notify(title, message, duration, type)
    type = type or "info"
    duration = duration or 4
    
    table.insert(NotificationCenter.Queue, {
        Title = title,
        Message = message,
        Duration = duration,
        Type = type
    })
    
    NotificationCenter.ProcessQueue()
end

function NotificationCenter.ProcessQueue()
    while #NotificationCenter.Queue > 0 and #NotificationCenter.Active < NotificationCenter.MaxActive do
        local notif = table.remove(NotificationCenter.Queue, 1)
        NotificationCenter.Show(notif)
    end
end

function NotificationCenter.Show(notifData)
    local theme = Config.Themes[Config.CurrentTheme]
    
    local colors = {
        success = theme.Success,
        error = theme.Error,
        warning = theme.Warning,
        info = theme.Info
    }
    
    local color = colors[notifData.Type] or theme.Info
    
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "RingtaNotification_" .. HttpService:GenerateGUID(false)
    notifGui.ResetOnSpawn = false
    notifGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = theme.Surface
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = notifGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Text = notifData.Type == "success" and "✅" or notifData.Type == "error" and "❌" or notifData.Type == "warning" and "⚠️" or "ℹ️"
    icon.TextSize = 20
    icon.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 25)
    title.Position = UDim2.new(0, 45, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = notifData.Title
    title.TextColor3 = color
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, -20, 0, 0)
    message.Position = UDim2.new(0, 10, 0, 35)
    message.AutomaticSize = Enum.AutomaticSize.Y
    message.BackgroundTransparency = 1
    message.Text = notifData.Message
    message.TextColor3 = theme.Text
    message.Font = Enum.Font.Gotham
    message.TextSize = 12
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextWrapped = true
    message.Parent = frame
    
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1, 0, 0, 3)
    progress.Position = UDim2.new(0, 0, 1, -3)
    progress.BackgroundColor3 = color
    progress.BorderSizePixel = 0
    progress.Parent = frame
    
    -- Position calculation
    local yOffset = -20 - (#NotificationCenter.Active * 90)
    
    table.insert(NotificationCenter.Active, notifGui)
    
    -- Animate in
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 300, 0, 80)
    }):Play()
    
    TweenService:Create(notifGui, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
        Position = NotificationCenter.Position + UDim2.new(0, 0, 0, yOffset)
    }):Play()
    
    -- Progress bar animation
    TweenService:Create(progress, TweenInfo.new(notifData.Duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    }):Play()
    
    -- Remove after duration
    task.delay(notifData.Duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 300, 0, 0)
        }):Play()
        
        task.wait(0.3)
        
        for i, gui in ipairs(NotificationCenter.Active) do
            if gui == notifGui then
                table.remove(NotificationCenter.Active, i)
                break
            end
        end
        
        notifGui:Destroy()
        NotificationCenter.Reposition()
        NotificationCenter.ProcessQueue()
    end)
end

function NotificationCenter.Reposition()
    for i, gui in ipairs(NotificationCenter.Active) do
        local yOffset = -20 - ((i - 1) * 90)
        TweenService:Create(gui, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = NotificationCenter.Position + UDim2.new(0, 0, 0, yOffset)
        }):Play()
    end
end

-- ═════════════════════════════════════════════════════════════════════════════════════
-- SISTEMA DE REMOTES (Baseado no relatório completo)
-- ═════════════════════════════════════════════════════════════════════════════════════
local Remotes = {
    All = {},
    Weapon = {},
    Train = {},
    Class = {},
    Economy = {},
    Interaction = {},
    Combat = {},
    Social = {},
    Misc = {},
    JABBY = {},
    Replica = {},
    Conch = {}
}

function Remotes.Scan()
    Console.Log("Scanning for RemoteEvents...", "info")
    
    local count = 0
    
    local function ScanFolder(folder, path)
        for _, obj in pairs(folder:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("UnreliableRemoteEvent") then
                count = count + 1
                local remoteData = {
                    Object = obj,
                    Name = obj.Name,
                    Path = path .. "/" .. obj:GetFullName(),
                    Type = obj:IsA("UnreliableRemoteEvent") and "Unreliable" or "Reliable"
                }
                
                table.insert(Remotes.All, remoteData)
                
                -- Categorize
                if obj.Name == "Shoot" then
                    table.insert(Remotes.Weapon, remoteData)
                elseif obj.Name:find("Train") then
                    table.insert(Remotes.Train, remoteData)
                elseif obj.Name:find("Class") then
                    table.insert(Remotes.Class, remoteData)
                elseif obj.Name:find("Money") or obj.Name:find("Buy") or obj.Name:find("Bonds") then
                    table.insert(Remotes.Economy, remoteData)
                elseif obj.Name:find("Party") or obj.Name:find("Trade") then
                    table.insert(Remotes.Social, remoteData)
                elseif obj.Name:find("Hit") or obj.Name:find("Hurt") or obj.Name:find("Damage") then
                    table.insert(Remotes.Combat, remoteData)
                elseif obj.Name:find("JABBY") or obj.Parent.Name:find("JABBY") then
                    table.insert(Remotes.JABBY, remoteData)
                elseif obj.Name:find("Replica") or obj.Parent.Name:find("Replica") then
                    table.insert(Remotes.Replica, remoteData)
                elseif obj.Name:find("conch") or obj.Parent.Name:find("conch") then
                    table.insert(Remotes.Conch, remoteData)
                else
                    table.insert(Remotes.Misc, remoteData)
                end
            end
        end
    end
    
    ScanFolder(ReplicatedStorage, "ReplicatedStorage")
    ScanFolder(Workspace, "Workspace")
    
    Console.Log("Found " .. count .. " RemoteEvents", "success")
    return count
end

function Remotes.Fire(remoteName, ...)
    for _, remote in ipairs(Remotes.All) do
        if remote.Name == remoteName then
            pcall(function()
                remote.Object:FireServer(...)
            end)
            Console.Log("Fired Remote: " .. remoteName, "info")
            return true
        end
    end
    Console.Log("Remote not found: " .. remoteName, "error")
    return false
end

function Remotes.GetByName(name)
    for _, remote in ipairs(Remotes.All) do
        if remote.Name == name then
            return remote.Object
        end
    end
    return nil
end

-- ═════════════════════════════════════════════════════════════════════════════════════
-- ESP SYSTEM ULTRA
-- ═════════════════════════════════════════════════════════════════════════════════════
local ESP = {
    Enabled = false,
    Players = true,
    NPCs = false,
    Items = false,
    Boxes = true,
    Names = true,
    Distance = true,
    Health = true,
    HealthBar = true,
    Tracers = false,
    Skeleton = false,
    TeamCheck = false,
    MaxDistance = 1000,
    Objects = {},
    Settings = {
        PlayerColor = Color3.fromRGB(255, 0, 0),
        NPCColor = Color3.fromRGB(255, 165, 0),
        ItemColor = Color3.fromRGB(0, 255, 255),
        BoxThickness = 2,
        TracerOrigin = "Bottom" -- Bottom, Center, Mouse
    }
}

function ESP.CreateObject(obj, objType)
    if not obj or ESP.Objects[obj] then return end
    
    local espObj = {
        Object = obj,
        Type = objType,
        Components = {},
        Connections = {}
    }
    
    local color = objType == "player" and ESP.Settings.PlayerColor or 
                  objType == "npc" and ESP.Settings.NPCColor or 
                  ESP.Settings.ItemColor
    
    -- Box
    if ESP.Boxes then
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = ESP.Settings.BoxThickness
        box.Color = color
        box.Filled = false
        espObj.Components.Box = box
        
        -- Filled box (background)
        local boxFill = Drawing.new("Square")
        boxFill.Visible = false
        boxFill.Thickness = 1
        boxFill.Color = color
        boxFill.Filled = true
        boxFill.Transparency = 0.1
        espObj.Components.BoxFill = boxFill
    end
    
    -- Name
    if ESP.Names then
        local name = Drawing.new("Text")
        name.Visible = false
        name.Size = 13
        name.Color = Color3.fromRGB(255, 255, 255)
        name.Center = true
        name.Outline = true
        name.Font = Drawing.Fonts.UI
        espObj.Components.Name = name
    end
    
    -- Distance
    if ESP.Distance then
        local dist = Drawing.new("Text")
        dist.Visible = false
        dist.Size = 11
        dist.Color = Color3.fromRGB(200, 200, 200)
        dist.Center = true
        dist.Outline = true
        dist.Font = Drawing.Fonts.UI
        espObj.Components.Distance = dist
    end
    
    -- Health
    if ESP.Health and objType ~= "item" then
        local health = Drawing.new("Text")
        health.Visible = false
        health.Size = 11
        health.Color = Color3.fromRGB(0, 255, 0)
        health.Center = true
        health.Outline = true
        health.Font = Drawing.Fonts.UI
        espObj.Components.Health = health
    end
    
    -- Health Bar
    if ESP.HealthBar and objType ~= "item" then
        local healthBarBg = Drawing.new("Square")
        healthBarBg.Visible = false
        healthBarBg.Thickness = 1
        healthBarBg.Color = Color3.fromRGB(50, 50, 50)
        healthBarBg.Filled = true
        espObj.Components.HealthBarBg = healthBarBg
        
        local healthBar = Drawing.new("Square")
        healthBar.Visible = false
        healthBar.Thickness = 1
        healthBar.Color = Color3.fromRGB(0, 255, 0)
        healthBar.Filled = true
        espObj.Components.HealthBar = healthBar
    end
    
    -- Tracer
    if ESP.Tracers then
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1
        tracer.Color = color
        tracer.Transparency = 0.7
        espObj.Components.Tracer = tracer
    end
    
    -- Skeleton
    if ESP.Skeleton and objType ~= "item" then
        local skeleton = {}
        local joints = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
        for i = 1, 10 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 1
            line.Color = color
            line.Transparency = 0.8
            table.insert(skeleton, line)
        end
        espObj.Components.Skeleton = skeleton
    end
    
    ESP.Objects[obj] = espObj
    return espObj
end

function ESP.RemoveObject(obj)
    local espObj = ESP.Objects[obj]
    if espObj then
        for _, component in pairs(espObj.Components) do
            if type(component) == "table" then
                for _, line in ipairs(component) do
                    line:Remove()
                end
            else
                component:Remove()
            end
        end
        for _, conn in ipairs(espObj.Connections) do
            conn:Disconnect()
        end
        ESP.Objects[obj] = nil
    end
end

function ESP.Update()
    if not ESP.Enabled then
        for _, espObj in pairs(ESP.Objects) do
            for key, component in pairs(espObj.Components) do
                if type(component) == "table" then
                    for _, line in ipairs(component) do
                        line.Visible = false
                    end
                else
                    component.Visible = false
                end
            end
        end
        return
    end
    
    for obj, espObj in pairs(ESP.Objects) do
        if not obj or not obj.Parent then
            ESP.RemoveObject(obj)
            continue
        end
        
        local pos = nil
        local humanoid = nil
        local rootPart = nil
        
        if espObj.Type == "player" or espObj.Type == "npc" then
            rootPart = obj:FindFirstChild("HumanoidRootPart")
            humanoid = obj:FindFirstChild("Humanoid")
            if rootPart then
                pos = rootPart.Position
            end
        else
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primary then
                    pos = primary.Position
                end
            end
        end
        
        if pos and rootPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            local distance = (Camera.CFrame.Position - pos).Magnitude
            
            if onScreen and distance <= ESP.MaxDistance then
                local size = Vector3.new(4, 6, 0)
                local topPos = Camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(0, size.Y / 2, 0)).Position)
                local bottomPos = Camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(0, -size.Y / 2, 0)).Position)
                local height = math.abs(topPos.Y - bottomPos.Y)
                local width = height / 2
                
                local boxSize = Vector2.new(width, height)
                local boxPos = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
                
                -- Update Box
                if espObj.Components.Box then
                    espObj.Components.Box.Visible = true
                    espObj.Components.Box.Size = boxSize
                    espObj.Components.Box.Position = boxPos
                end
                
                if espObj.Components.BoxFill then
                    espObj.Components.BoxFill.Visible = true
                    espObj.Components.BoxFill.Size = boxSize
                    espObj.Components.BoxFill.Position = boxPos
                end
                
                -- Update Name
                if espObj.Components.Name then
                    espObj.Components.Name.Visible = true
                    espObj.Components.Name.Position = Vector2.new(screenPos.X, boxPos.Y - 18)
                    espObj.Components.Name.Text = obj.Name
                end
                
                -- Update Distance
                if espObj.Components.Distance then
                    espObj.Components.Distance.Visible = true
                    espObj.Components.Distance.Position = Vector2.new(screenPos.X, boxPos.Y + boxSize.Y + 5)
                    espObj.Components.Distance.Text = math.floor(distance) .. "m"
                end
                
                -- Update Health
                if espObj.Components.Health and humanoid then
                    espObj.Components.Health.Visible = true
                    espObj.Components.Health.Position = Vector2.new(screenPos.X, boxPos.Y + boxSize.Y + 18)
                    espObj.Components.Health.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                    espObj.Components.Health.Color = Color3.fromRGB(
                        255 * (1 - humanoid.Health / humanoid.MaxHealth),
                        255 * (humanoid.Health / humanoid.MaxHealth),
                        0
                    )
                end
                
                -- Update Health Bar
                if espObj.Components.HealthBar and espObj.Components.HealthBarBg and humanoid then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barHeight = boxSize.Y * healthPercent
                    
                    espObj.Components.HealthBarBg.Visible = true
                    espObj.Components.HealthBarBg.Size = Vector2.new(4, boxSize.Y)
                    espObj.Components.HealthBarBg.Position = Vector2.new(boxPos.X - 10, boxPos.Y)
                    
                    espObj.Components.HealthBar.Visible = true
                    espObj.Components.HealthBar.Size = Vector2.new(4, barHeight)
                    espObj.Components.HealthBar.Position = Vector2.new(boxPos.X - 10, boxPos.Y + boxSize.Y - barHeight)
                    espObj.Components.HealthBar.Color = Color3.fromRGB(
                        255 * (1 - healthPercent),
                        255 * healthPercent,
                        0
                    )
                end
                
                -- Update Tracer
                if espObj.Components.Tracer then
                    espObj.Components.Tracer.Visible = true
                    local origin = ESP.Settings.TracerOrigin == "Bottom" and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) or
                                   ESP.Settings.TracerOrigin == "Center" and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) or
                                   Vector2.new(Mouse.X, Mouse.Y)
                    espObj.Components.Tracer.From = origin
                    espObj.Components.Tracer.To = Vector2.new(screenPos.X, boxPos.Y + boxSize.Y)
                end
                
            else
                for key, component in pairs(espObj.Components) do
                    if type(component) == "table" then
                        for _, line in ipairs(component) do
                            line.Visible = false
                        end
                    else
                        component.Visible = false
                    end
                end
            end
        end
    end
end

function ESP.ScanPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not ESP.TeamCheck or player.Team ~= LocalPlayer.Team then
                ESP.CreateObject(player.Character, "player")
            end
        end
    end
end

function ESP.ScanNPCs()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if not Players:GetPlayerFromCharacter(obj) then
                ESP.CreateObject(obj, "npc")
            end
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════════════
-- AUTO-FARM SYSTEM ULTRA
-- ═════════════════════════════════════════════════════════════════════════════════════
local AutoFarm = {
    Enabled = false,
    Mode = "NPC", -- NPC, Player, Item
    Range = 100,
    AutoShoot = true,
    AutoReload = true,
    InstantKill = false,
    AutoCollect = true,
    SmartTarget = true, -- Target closest/lowest health
    LoopRunning = false,
    Stats = {
        Kills = 0,
        MoneyEarned = 0,
        StartTime = 0
    }
}

function AutoFarm.GetTarget()
    local targets = {}
    
    if AutoFarm.Mode == "NPC" then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if not Players:GetPlayerFromCharacter(obj) then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude
                    if dist <= AutoFarm.Range then
                        table.insert(targets, {
                            Object = obj,
                            Distance = dist,
                            Health = obj.Humanoid.Health
                        })
                    end
                end
            end
        end
    elseif AutoFarm.Mode == "Player" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not ESP.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= AutoFarm.Range then
                        table.insert(targets, {
                            Object = player.Character,
                            Distance = dist,
                            Health = player.Character.Humanoid.Health
                        })
                    end
                end
            end
        end
    end
    
    -- Sort by closest or lowest health
    if AutoFarm.SmartTarget then
        table.sort(targets, function(a, b) return a.Distance < b.Distance end)
    else
        table.sort(targets, function(a, b) return a.Health < b.Health end)
    end
    
    return targets[1] and targets[1].Object or nil
end

function AutoFarm.ShootAt(target)
    if not target or not LocalPlayer.Character then return end
    
    local targetPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head") or target:FindFirstChild("Torso")
    if not targetPart then return end
    
    -- Aim at target
    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then
        myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(targetPart.Position.X, myHRP.Position.Y, targetPart.Position.Z))
    end
    
    -- Fire all shoot remotes
    for _, remote in ipairs(Remotes.Weapon) do
        if remote.Name == "Shoot" then
            pcall(function()
                remote.Object:FireServer(targetPart.Position, targetPart)
            end)
        end
    end
end

function AutoFarm.Start()
    if AutoFarm.LoopRunning then return end
    AutoFarm.LoopRunning = true
    AutoFarm.Stats.StartTime = tick()
    
    Console.Log("Auto-Farm started (Mode: " .. AutoFarm.Mode .. ")", "success")
    NotificationCenter.Notify("Auto-Farm", "Started in " .. AutoFarm.Mode .. " mode", 3, "success")
    
    task.spawn(function()
        while AutoFarm.Enabled and AutoFarm.LoopRunning do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local target = AutoFarm.GetTarget()
                
                if target then
                    if AutoFarm.AutoShoot then
                        AutoFarm.ShootAt(target)
                    end
                    
                    if AutoFarm.InstantKill then
                        local humanoid = target:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            humanoid.Health = 0
                            AutoFarm.Stats.Kills = AutoFarm.Stats.Kills + 1
                        end
                    end
                end
                
                if AutoFarm.AutoCollect then
                    -- Collect nearby drops
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (obj.Name:lower():find("money") or obj.Name:lower():find("drop")) then
                            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                            if dist <= 50 then
                                pcall(function()
                                    obj.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                                end)
                            end
                        end
                    end
                end
            end
            
            task.wait(0.05)
        end
        
        AutoFarm.LoopRunning = false
        local duration = tick() - AutoFarm.Stats.StartTime
        Console.Log("Auto-Farm stopped. Kills: " .. AutoFarm.Stats.Kills .. ", Duration: " .. math.floor(duration) .. "s", "info")
    end)
end

function AutoFarm.Stop()
    AutoFarm.Enabled = false
    NotificationCenter.Notify("Auto-Farm", "Stopped. Total Kills: " .. AutoFarm.Stats.Kills, 3, "warning")
end

-- ═════════════════════════════════════════════════════════════════════════════════════
-- GOD MODE SYSTEM
-- ═════════════════════════════════════════════════════════════════════════════════════
local GodMode = {
    Enabled = false,
    InfiniteHealth = true,
    NoRagdoll = true,
    AutoRevive = true,
    AntiFling = true,
    Connections = {}
}

function GodMode.Enable()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Infinite Health
    if GodMode.InfiniteHealth then
        table.insert(GodMode.Connections, humanoid.HealthChanged:Connect(function(health)
            if GodMode.Enabled and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end))
    end
    
    -- No Ragdoll
    if GodMode.NoRagdoll then
        for _, obj in pairs(LocalPlayer.Character:GetDescendants()) do
            if obj:IsA("JointInstance") then
                obj.Enabled = true
            end
        end
    end
    
    -- Auto Revive
    if GodMode.AutoRevive then
        table.insert(GodMode.Connections, humanoid.Died:Connect(function()
            if GodMode.Enabled then
                task.wait(2)
                local reviveRemote = Remotes.GetByName("RevivePlayer")
                if reviveRemote then
                    reviveRemote:FireServer()
                    Console.Log("Auto-revived!", "success")
                end
            end
        end))
    end
    
    Console.Log("God Mode enabled", "success")
    NotificationCenter.Notify("God Mode", "All protections active", 3, "success")
end

function GodMode.Disable()
    GodMode.Enabled = false
    for _, conn in ipairs(GodMode.Connections) do
        conn:Disconnect()
    end
    GodMode.Connections = {}
    Console.Log("God Mode disabled", "warning")
end

-- ═════════════════════════════════════════════════════════════════════════════════════
-- TELEPORT SYSTEM
-- ═════════════════════════════════════════════════════════════════════════════════════
local Teleport = {
    Locations = {},
    History = {}
}

function Teleport.To(pos)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local oldPos = LocalPlayer.Character.HumanoidRootPart.CFrame
    LocalPlayer.Character.HumanoidRootPart.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
    
    table.insert(Teleport.History, oldPos)
    Console.Log("Teleported to " .. tostring(pos), "info")
end

function Teleport.ToPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        Teleport.To(player.Character.HumanoidRootPart.CFrame)
        NotificationCenter.Notify("Teleport", "Teleported to " .. player.Name, 3, "success")
    end
end

function Teleport.Undo()
    if #Teleport.History > 0 then
        local pos = table.remove(Teleport.History)
        Teleport.To(pos)
        NotificationCenter.Notify("Teleport", "Undone last teleport", 3, "info")
    end
end

-- ═════════════════════════════════════════════════════════════════════════════════════
-- WEAPON MODS
-- ═════════════════════════════════════════════════════════════════════════════════════
local WeaponMods = {
    InfiniteAmmo = false,
    RapidFire = false,
    NoRecoil = false,
    NoSpread = false,
    InstantReload = false,
    DamageMultiplier = 1,
    FireRate = 0.05,
    OneShot = false
}

function WeaponMods.Apply()
    if not LocalPlayer.Character then return end
    
    for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local config = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Config") or tool:FindFirstChild("Settings")
            if config then
                for _, setting in pairs(config:GetChildren()) do
                    local name = setting.Name:lower()
                    
                    if WeaponMods.InfiniteAmmo and (name:find("ammo") or name:find("bullet")) then
                        if setting:IsA("IntValue") or setting:IsA("NumberValue") then
                            setting.Value = 9999
                        end
                    end
                    
                    if WeaponMods.RapidFire and name:find("firerate") then
                        if setting:IsA("NumberValue") then
                            setting.Value = WeaponMods.FireRate
                        end
                    end
                    
                    if WeaponMods.NoRecoil and name:find("recoil") then
                        if setting:IsA("NumberValue") then
                            setting.Value = 0
                        end
                    end
                    
                    if WeaponMods.NoSpread and name:find("spread") then
                        if setting:IsA("NumberValue") then
                            setting.Value = 0
                        end
                    end
                    
                    if WeaponMods.InstantReload and name:find("reload") then
                        if setting:IsA("NumberValue") then
                            setting.Value = 0.01
                        end
                    end
                    
                    if name:find("damage") then
                        if setting:IsA("IntValue") or setting:IsA("NumberValue") then
                            setting.Value = setting.Value * WeaponMods.DamageMultiplier
                        end
                    end
                end
            end
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════════════
-- ULTRA PREMIUM GUI
-- ═════════════════════════════════════════════════════════════════════════════════════
local GUI = {}

function GUI.Create()
    local theme = Config.Themes[Config.CurrentTheme]
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OpenRingtaUltra"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui
    
    -- Watermark
    local watermark = Instance.new("TextLabel")
    watermark.Name = "Watermark"
    watermark.Size = UDim2.new(0, 250, 0, 25)
    watermark.Position = UDim2.new(0, 10, 0, 10)
    watermark.BackgroundTransparency = 1
    watermark.Text = "🔥 OPEN RINGTA ULTRA v" .. Config.Version
    watermark.TextColor3 = theme.Accent
    watermark.Font = Enum.Font.GothamBold
    watermark.TextSize = 14
    watermark.Parent = screenGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 900, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 60, 1, 60)
    shadow.Position = UDim2.new(0, -30, 0, -30)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = theme.Surface
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ OPEN RINGTA ULTRA"
    title.TextColor3 = theme.Primary
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Version
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0, 100, 1, 0)
    version.Position = UDim2.new(0, 230, 0, 0)
    version.BackgroundTransparency = 1
    version.Text = "v" .. Config.Version
    version.TextColor3 = theme.TextDark
    version.Font = Enum.Font.Gotham
    version.TextSize = 12
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.Parent = titleBar
    
    -- Control Buttons
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(0, 120, 1, 0)
    controls.Position = UDim2.new(1, -125, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = titleBar
    
    local function CreateControlButton(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = controls
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local minimizeBtn = CreateControlButton("−", theme.Warning, function()
        -- Minimize logic
    end)
    minimizeBtn.Position = UDim2.new(0, 0, 0.5, -15)
    
    local closeBtn = CreateControlButton("×", theme.Error, function()
        screenGui:Destroy()
        AutoFarm.Stop()
        ESP.Enabled = false
        GodMode.Disable()
    end)
    closeBtn.Position = UDim2.new(0, 70, 0.5, -15)
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 200, 1, -45)
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.BackgroundColor3 = theme.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    -- Tab Buttons Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 1, -60)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    -- Theme Selector
    local themeFrame = Instance.new("Frame")
    themeFrame.Size = UDim2.new(1, -20, 0, 40)
    themeFrame.Position = UDim2.new(0, 10, 1, -50)
    themeFrame.BackgroundColor3 = theme.SurfaceLight
    themeFrame.Parent = sidebar
    
    local themeCorner = Instance.new("UICorner")
    themeCorner.CornerRadius = UDim.new(0, 6)
    themeCorner.Parent = themeFrame
    
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Size = UDim2.new(1, 0, 0, 20)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "Theme"
    themeLabel.TextColor3 = theme.TextDark
    themeLabel.Font = Enum.Font.Gotham
    themeLabel.TextSize = 10
    themeLabel.Parent = themeFrame
    
    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -200, 1, -45)
    contentFrame.Position = UDim2.new(0, 200, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Console Area (Bottom)
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Name = "Console"
    consoleFrame.Size = UDim2.new(1, -220, 0, 150)
    consoleFrame.Position = UDim2.new(0, 210, 1, -160)
    consoleFrame.BackgroundColor3 = theme.Surface
    consoleFrame.BorderSizePixel = 0
    consoleFrame.Parent = mainFrame
    consoleFrame.Visible = true
    
    local consoleCorner = Instance.new("UICorner")
    consoleCorner.CornerRadius = UDim.new(0, 8)
    consoleCorner.Parent = consoleFrame
    
    local consoleTitle = Instance.new("TextLabel")
    consoleTitle.Size = UDim2.new(1, 0, 0, 25)
    consoleTitle.BackgroundColor3 = theme.SurfaceLight
    consoleTitle.Text = "  📋 Console Output"
    consoleTitle.TextColor3 = theme.Text
    consoleTitle.Font = Enum.Font.GothamBold
    consoleTitle.TextSize = 12
    consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
    consoleTitle.Parent = consoleFrame
    
    local consoleTitleCorner = Instance.new("UICorner")
    consoleTitleCorner.CornerRadius = UDim.new(0, 8)
    consoleTitleCorner.Parent = consoleTitle
    
    local consoleScroll = Instance.new("ScrollingFrame")
    consoleScroll.Size = UDim2.new(1, -10, 1, -35)
    consoleScroll.Position = UDim2.new(0, 5, 0, 30)
    consoleScroll.BackgroundTransparency = 1
    consoleScroll.ScrollBarThickness = 4
    consoleScroll.ScrollBarImageColor3 = theme.Primary
    consoleScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    consoleScroll.Parent = consoleFrame
    
    local consoleLayout = Instance.new("UIListLayout")
    consoleLayout.Padding = UDim.new(0, 2)
    consoleLayout.Parent = consoleScroll
    
    -- Console Functions
    function Console.UI.Update()
        for _, child in ipairs(consoleScroll:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        
        for _, log in ipairs(Console.Logs) do
            local logLabel = Instance.new("TextLabel")
            logLabel.Size = UDim2.new(1, 0, 0, 16)
            logLabel.BackgroundTransparency = 1
            logLabel.Text = "[" .. log.Time .. "] " .. log.Message
            logLabel.TextColor3 = log.Type == "error" and theme.Error or 
                                  log.Type == "success" and theme.Success or 
                                  log.Type == "warning" and theme.Warning or theme.Text
            logLabel.Font = Enum.Font.Code
            logLabel.TextSize = 11
            logLabel.TextXAlignment = Enum.TextXAlignment.Left
            logLabel.Parent = consoleScroll
        end
        
        if Console.AutoScroll then
            consoleScroll.CanvasPosition = Vector2.new(0, consoleScroll.AbsoluteCanvasSize.Y)
        end
    end
    
    -- Tabs
    local tabs = {
        {Name = "Main", Icon = "🏠"},
        {Name = "Combat", Icon = "⚔️"},
        {Name = "ESP", Icon = "👁️"},
        {Name = "Farm", Icon = "🤖"},
        {Name = "Tele", Icon = "🌀"},
        {Name = "Train", Icon = "🚂"},
        {Name = "Remotes", Icon = "📡"},
        {Name = "Misc", Icon = "⚙️"}
    }
    
    local tabButtons = {}
    local tabContents = {}
    local currentTab = nil
    
    -- Create Tab Content Frames
    for _, tabInfo in ipairs(tabs) do
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabInfo.Name .. "Content"
        tabContent.Size = UDim2.new(1, -20, 1, -170)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = theme.Primary
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.Parent = contentFrame
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        tabContents[tabInfo.Name] = tabContent
    end
    
    -- Create Tab Buttons
    for i, tabInfo in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabInfo.Name .. "Tab"
        tabBtn.Size = UDim2.new(1, -20, 0, 40)
        tabBtn.Position = UDim2.new(0, 10, 0, 10 + (i - 1) * 50)
        tabBtn.BackgroundColor3 = i == 1 and theme.Primary or theme.SurfaceLight
        tabBtn.Text = "  " .. tabInfo.Icon .. "  " .. tabInfo.Name
        tabBtn.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or theme.Text
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.Parent = tabContainer
        
        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 8)
        tabBtnCorner.Parent = tabBtn
        
        tabButtons[tabInfo.Name] = tabBtn
        
        tabBtn.MouseButton1Click:Connect(function()
            if currentTab == tabInfo.Name then return end
            
            -- Reset all tabs
            for name, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = theme.SurfaceLight,
                    TextColor3 = theme.Text
                }):Play()
                tabContents[name].Visible = false
            end
            
            -- Activate selected tab
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = theme.Primary,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            tabContents[tabInfo.Name].Visible = true
            currentTab = tabInfo.Name
        end)
    end
    
    currentTab = "Main"
    tabContents["Main"].Visible = true
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- UI COMPONENTS
    -- ═════════════════════════════════════════════════════════════════════════════════
    
    local function CreateSection(parent, title)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 0)
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.BackgroundColor3 = theme.Surface
        section.BorderSizePixel = 0
        section.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = section
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -20, 0, 30)
        titleLabel.Position = UDim2.new(0, 10, 0, 5)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = theme.Primary
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = section
        
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, -20, 0, 0)
        content.Position = UDim2.new(0, 10, 0, 35)
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.BackgroundTransparency = 1
        content.Parent = section
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.Parent = content
        
        local padding = Instance.new("UIPadding")
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = section
        
        return section, content
    end
    
    local function CreateToggle(parent, text, callback, default)
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(1, 0, 0, 35)
        toggle.BackgroundTransparency = 1
        toggle.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -70, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = theme.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggle
        
        local button = Instance.new("Frame")
        button.Size = UDim2.new(0, 55, 0, 26)
        button.Position = UDim2.new(1, -55, 0.5, -13)
        button.BackgroundColor3 = default and theme.Success or theme.Error
        button.Parent = toggle
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 13)
        corner.Parent = button
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.Parent = button
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle
        
        local enabled = default or false
        local clickArea = Instance.new("TextButton")
        clickArea.Size = UDim2.new(1, 0, 1, 0)
        clickArea.BackgroundTransparency = 1
        clickArea.Text = ""
        clickArea.Parent = toggle
        
        clickArea.MouseButton1Click:Connect(function()
            enabled = not enabled
            
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and theme.Success or theme.Error
            }):Play()
            
            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = enabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            }):Play()
            
            callback(enabled)
        end)
        
        return toggle
    end
    
    local function CreateButton(parent, text, callback, color)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 38)
        button.BackgroundColor3 = color or theme.Primary
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 13
        button.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 38)}):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            callback()
        end)
        
        return button
    end
    
    local function CreateSlider(parent, text, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 50)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.TextColor3 = theme.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50, 0, 20)
        valueLabel.Position = UDim2.new(1, -50, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = theme.Primary
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 13
        valueLabel.Parent = sliderFrame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 8)
        sliderBg.Position = UDim2.new(0, 0, 0, 30)
        sliderBg.BackgroundColor3 = theme.SurfaceLight
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = sliderFrame
        
        local sliderBgCorner = Instance.new("UICorner")
        sliderBgCorner.CornerRadius = UDim.new(0, 4)
        sliderBgCorner.Parent = sliderBg
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = theme.Primary
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        
        local sliderFillCorner = Instance.new("UICorner")
        sliderFillCorner.CornerRadius = UDim.new(0, 4)
        sliderFillCorner.Parent = sliderFill
        
        local value = default
        local dragging = false
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * pos)
                valueLabel.Text = tostring(value)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                callback(value)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return sliderFrame
    end
    
    local function CreateDropdown(parent, text, options, callback)
        local dropdown = Instance.new("Frame")
        dropdown.Size = UDim2.new(1, 0, 0, 40)
        dropdown.BackgroundColor3 = theme.SurfaceLight
        dropdown.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = dropdown
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. options[1]
        label.TextColor3 = theme.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = dropdown
        
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -25, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = theme.TextDark
        arrow.Font = Enum.Font.Gotham
        arrow.TextSize = 12
        arrow.Parent = dropdown
        
        local expanded = false
        local optionsFrame = nil
        
        dropdown.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                expanded = not expanded
                
                if expanded then
                    optionsFrame = Instance.new("Frame")
                    optionsFrame.Size = UDim2.new(1, 0, 0, #options * 30)
                    optionsFrame.Position = UDim2.new(0, 0, 1, 5)
                    optionsFrame.BackgroundColor3 = theme.SurfaceLight
                    optionsFrame.ZIndex = 10
                    optionsFrame.Parent = dropdown
                    
                    local ofCorner = Instance.new("UICorner")
                    ofCorner.CornerRadius = UDim.new(0, 6)
                    ofCorner.Parent = optionsFrame
                    
                    for i, option in ipairs(options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Size = UDim2.new(1, 0, 0, 30)
                        optBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
                        optBtn.BackgroundTransparency = 1
                        optBtn.Text = option
                        optBtn.TextColor3 = theme.Text
                        optBtn.Font = Enum.Font.Gotham
                        optBtn.TextSize = 12
                        optBtn.ZIndex = 11
                        optBtn.Parent = optionsFrame
                        
                        optBtn.MouseButton1Click:Connect(function()
                            label.Text = text .. ": " .. option
                            callback(option)
                            expanded = false
                            optionsFrame:Destroy()
                            arrow.Text = "▼"
                        end)
                    end
                    
                    arrow.Text = "▲"
                else
                    if optionsFrame then
                        optionsFrame:Destroy()
                    end
                    arrow.Text = "▼"
                end
            end
        end)
        
        return dropdown
    end
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- MAIN TAB
    -- ═════════════════════════════════════════════════════════════════════════════════
    local mainSection, mainContent = CreateSection(tabContents["Main"], "⚡ Quick Actions")
    
    CreateButton(mainContent, "▶ Start Auto-Farm NPC", function()
        AutoFarm.Mode = "NPC"
        AutoFarm.Enabled = true
        AutoFarm.Start()
    end, theme.Success)
    
    CreateButton(mainContent, "▶ Start Auto-Farm Players", function()
        AutoFarm.Mode = "Player"
        AutoFarm.Enabled = true
        AutoFarm.Start()
    end, theme.Warning)
    
    CreateButton(mainContent, "⏹ Stop Auto-Farm", function()
        AutoFarm.Stop()
    end, theme.Error)
    
    CreateToggle(mainContent, "Enable ESP", function(enabled)
        ESP.Enabled = enabled
        if enabled then
            ESP.ScanPlayers()
            NotificationCenter.Notify("ESP", "ESP Enabled", 3, "success")
        end
    end, false)
    
    CreateToggle(mainContent, "God Mode", function(enabled)
        GodMode.Enabled = enabled
        if enabled then
            GodMode.Enable()
        else
            GodMode.Disable()
        end
    end, false)
    
    local statsSection, statsContent = CreateSection(tabContents["Main"], "📊 Session Stats")
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(1, 0, 0, 100)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Auto-Farm Kills: 0\nMoney Earned: 0\nSession Time: 0s\nRemotes Found: " .. #Remotes.All
    statsLabel.TextColor3 = theme.Text
    statsLabel.Font = Enum.Font.Code
    statsLabel.TextSize = 12
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    statsLabel.Parent = statsContent
    
    task.spawn(function()
        while screenGui.Parent do
            local sessionTime = AutoFarm.Stats.StartTime > 0 and math.floor(tick() - AutoFarm.Stats.StartTime) or 0
            statsLabel.Text = string.format(
                "Auto-Farm Kills: %d\nMoney Earned: %d\nSession Time: %ds\nRemotes Found: %d",
                AutoFarm.Stats.Kills,
                AutoFarm.Stats.MoneyEarned,
                sessionTime,
                #Remotes.All
            )
            task.wait(1)
        end
    end)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- COMBAT TAB
    -- ═════════════════════════════════════════════════════════════════════════════════
    local combatSection, combatContent = CreateSection(tabContents["Combat"], "🛡️ God Mode")
    
    CreateToggle(combatContent, "Infinite Health", function(enabled)
        GodMode.InfiniteHealth = enabled
    end, true)
    
    CreateToggle(combatContent, "No Ragdoll", function(enabled)
        GodMode.NoRagdoll = enabled
    end, true)
    
    CreateToggle(combatContent, "Auto Revive", function(enabled)
        GodMode.AutoRevive = enabled
    end, true)
    
    CreateToggle(combatContent, "Anti Fling", function(enabled)
        GodMode.AntiFling = enabled
    end, true)
    
    local weaponSection, weaponContent = CreateSection(tabContents["Combat"], "🔫 Weapon Mods")
    
    CreateToggle(weaponContent, "Infinite Ammo", function(enabled)
        WeaponMods.InfiniteAmmo = enabled
        WeaponMods.Apply()
    end, false)
    
    CreateToggle(weaponContent, "Rapid Fire", function(enabled)
        WeaponMods.RapidFire = enabled
        WeaponMods.Apply()
    end, false)
    
    CreateToggle(weaponContent, "No Recoil", function(enabled)
        WeaponMods.NoRecoil = enabled
        WeaponMods.Apply()
    end, false)
    
    CreateToggle(weaponContent, "No Spread", function(enabled)
        WeaponMods.NoSpread = enabled
        WeaponMods.Apply()
    end, false)
    
    CreateToggle(weaponContent, "Instant Reload", function(enabled)
        WeaponMods.InstantReload = enabled
        WeaponMods.Apply()
    end, false)
    
    CreateToggle(weaponContent, "One Shot Kill", function(enabled)
        WeaponMods.OneShot = enabled
    end, false)
    
    CreateSlider(weaponContent, "Damage Multiplier", 1, 10, 1, function(value)
        WeaponMods.DamageMultiplier = value
        WeaponMods.Apply()
    end)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- ESP TAB
    -- ═════════════════════════════════════════════════════════════════════════════════
    local espSection, espContent = CreateSection(tabContents["ESP"], "👁️ ESP Settings")
    
    CreateToggle(espContent, "Enable ESP", function(enabled)
        ESP.Enabled = enabled
        if enabled then ESP.ScanPlayers() end
    end, false)
    
    CreateToggle(espContent, "Show Players", function(enabled)
        ESP.Players = enabled
        if enabled then ESP.ScanPlayers() end
    end, true)
    
    CreateToggle(espContent, "Show NPCs", function(enabled)
        ESP.NPCs = enabled
        if enabled then ESP.ScanNPCs() end
    end, false)
    
    CreateToggle(espContent, "Show Boxes", function(enabled)
        ESP.Boxes = enabled
    end, true)
    
    CreateToggle(espContent, "Show Names", function(enabled)
        ESP.Names = enabled
    end, true)
    
    CreateToggle(espContent, "Show Distance", function(enabled)
        ESP.Distance = enabled
    end, true)
    
    CreateToggle(espContent, "Show Health", function(enabled)
        ESP.Health = enabled
    end, true)
    
    CreateToggle(espContent, "Health Bar", function(enabled)
        ESP.HealthBar = enabled
    end, true)
    
    CreateToggle(espContent, "Show Tracers", function(enabled)
        ESP.Tracers = enabled
    end, false)
    
    CreateToggle(espContent, "Skeleton", function(enabled)
        ESP.Skeleton = enabled
    end, false)
    
    CreateToggle(espContent, "Team Check", function(enabled)
        ESP.TeamCheck = enabled
    end, false)
    
    CreateSlider(espContent, "Max Distance", 100, 5000, 1000, function(value)
        ESP.MaxDistance = value
    end)
    
    CreateButton(espContent, "🔄 Refresh ESP", function()
        ESP.ScanPlayers()
        if ESP.NPCs then ESP.ScanNPCs() end
        NotificationCenter.Notify("ESP", "Refreshed", 2, "success")
    end)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- FARM TAB
    -- ═════════════════════════════════════════════════════════════════════════════════
    local farmSection, farmContent = CreateSection(tabContents["Farm"], "🤖 Auto-Farm")
    
    CreateDropdown(farmContent, "Target Mode", {"NPC", "Player"}, function(option)
        AutoFarm.Mode = option
    end)
    
    CreateToggle(farmContent, "Auto Shoot", function(enabled)
        AutoFarm.AutoShoot = enabled
    end, true)
    
    CreateToggle(farmContent, "Instant Kill", function(enabled)
        AutoFarm.InstantKill = enabled
    end, false)
    
    CreateToggle(farmContent, "Auto Collect Drops", function(enabled)
        AutoFarm.AutoCollect = enabled
    end, true)
    
    CreateToggle(farmContent, "Smart Target (Closest)", function(enabled)
        AutoFarm.SmartTarget = enabled
    end, true)
    
    CreateSlider(farmContent, "Farm Range", 50, 500, 100, function(value)
        AutoFarm.Range = value
    end)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- TELEPORT TAB
    -- ═════════════════════════════════════════════════════════════════════════════════
    local teleSection, teleContent = CreateSection(tabContents["Tele"], "🌀 Teleport")
    
    CreateButton(teleContent, "🎯 Teleport to Nearest Player", function()
        local player = nil
        local minDist = math.huge
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    player = p
                end
            end
        end
        
        if player then
            Teleport.ToPlayer(player)
        end
    end)
    
    CreateButton(teleContent, "🎲 Teleport to Random Player", function()
        local players = Players:GetPlayers()
        local validPlayers = {}
        
        for _, p in pairs(players) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(validPlayers, p)
            end
        end
        
        if #validPlayers > 0 then
            Teleport.ToPlayer(validPlayers[math.random(1, #validPlayers)])
        end
    end)
    
    CreateButton(teleContent, "↩️ Undo Last Teleport", function()
        Teleport.Undo()
    end, theme.Warning)
    
    -- Player List
    local playerSection, playerContent = CreateSection(tabContents["Tele"], "👥 Player List")
    
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(1, 0, 0, 150)
    playerList.BackgroundColor3 = theme.SurfaceLight
    playerList.ScrollBarThickness = 4
    playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    playerList.Parent = playerContent
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = playerList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = playerList
    
    local function UpdatePlayerList()
        for _, child in ipairs(playerList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -10, 0, 30)
                btn.Position = UDim2.new(0, 5, 0, 0)
                btn.BackgroundColor3 = theme.Surface
                btn.Text = player.Name
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.Parent = playerList
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    Teleport.ToPlayer(player)
                end)
            end
        end
    end
    
    UpdatePlayerList()
    Players.PlayerAdded:Connect(UpdatePlayerList)
    Players.PlayerRemoving:Connect(UpdatePlayerList)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- TRAIN TAB
    -- ═════════════════════════════════════════════════════════════════════════════════
    local trainSection, trainContent = CreateSection(tabContents["Train"], "🚂 Train System")
    
    CreateButton(trainContent, "🔓 Unlock All Trains", function()
        local getTrains = Remotes.GetByName("GetTrains")
        if getTrains then
            getTrains:FireServer()
            NotificationCenter.Notify("Train", "Attempting to unlock all trains...", 3, "info")
        end
    end)
    
    CreateButton(trainContent, "🎁 Gift Random Train", function()
        local giftTrain = Remotes.GetByName("GiftTrain")
        if giftTrain then
            local players = Players:GetPlayers()
            for _, p in pairs(players) do
                if p ~= LocalPlayer then
                    giftTrain:FireServer(p.Name, "DefaultTrain")
                    break
                end
            end
        end
    end)
    
    local classSection, classContent = CreateSection(tabContents["Train"], "🎭 Class System")
    
    CreateButton(classContent, "🔓 Unlock All Classes", function()
        local getClasses = Remotes.GetByName("GetClasses")
        if getClasses then
            getClasses:FireServer()
            NotificationCenter.Notify("Class", "Attempting to unlock all classes...", 3, "info")
        end
    end)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- REMOTES TAB
    -- ═════════════════════════════════════════════════════════════════════════════════
    local remoteSection, remoteContent = CreateSection(tabContents["Remotes"], "📡 Remote Scanner")
    
    local remoteInfo = Instance.new("TextLabel")
    remoteInfo.Size = UDim2.new(1, 0, 0, 60)
    remoteInfo.BackgroundTransparency = 1
    remoteInfo.Text = "Total Remotes: " .. #Remotes.All .. "\nWeapon: " .. #Remotes.Weapon .. " | Train: " .. #Remotes.Train .. " | Economy: " .. #Remotes.Economy
    remoteInfo.TextColor3 = theme.Text
    remoteInfo.Font = Enum.Font.Code
    remoteInfo.TextSize = 12
    remoteInfo.TextYAlignment = Enum.TextYAlignment.Top
    remoteInfo.Parent = remoteContent
    
    CreateButton(remoteContent, "🔄 Re-scan Remotes", function()
        Remotes.All = {}
        Remotes.Scan()
        remoteInfo.Text = "Total Remotes: " .. #Remotes.All .. "\nWeapon: " .. #Remotes.Weapon .. " | Train: " .. #Remotes.Train .. " | Economy: " .. #Remotes.Economy
    end)
    
    CreateButton(remoteContent, "🔥 Fire All Shoot Remotes", function()
        for _, remote in ipairs(Remotes.Weapon) do
            if remote.Name == "Shoot" then
                pcall(function()
                    remote.Object:FireServer(Mouse.Hit.Position, Mouse.Target)
                end)
            end
        end
        NotificationCenter.Notify("Remotes", "Fired all Shoot remotes!", 2, "success")
    end, theme.Warning)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- MISC TAB
    -- ═════════════════════════════════════════════════════════════════════════════════
    local miscSection, miscContent = CreateSection(tabContents["Misc"], "⚙️ Miscellaneous")
    
    CreateToggle(miscContent, "Anti-AFK", function(enabled)
        if enabled then
            LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end, false)
    
    CreateButton(miscContent, "🌧️ Toggle Weather", function()
        local toggleWeather = Remotes.GetByName("ToggleWeather")
        if toggleWeather then
            toggleWeather:FireServer()
        end
    end)
    
    CreateButton(miscContent, "🛸 Spawn UFO", function()
        local spawnUFO = Remotes.GetByName("SpawnUFO")
        if spawnUFO then
            spawnUFO:FireServer()
        end
    end)
    
    CreateButton(miscContent, "🏠 Return to Lobby", function()
        local returnLobby = Remotes.GetByName("ReturnToLooby")
        if returnLobby then
            returnLobby:FireServer()
        end
    end, theme.Error)
    
    CreateButton(miscContent, "🔄 Reset Character", function()
        local resetChar = Remotes.GetByName("ResetCharacter")
        if resetChar then
            resetChar:FireServer()
        end
    end, theme.Warning)
    
    CreateButton(miscContent, "🗑️ Clear Console", function()
        Console.Clear()
    end)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- DRAG FUNCTIONALITY
    -- ═════════════════════════════════════════════════════════════════════════════════
    local dragging = false
    local dragStart
    local startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- KEYBIND (F4 TO TOGGLE)
    -- ═════════════════════════════════════════════════════════════════════════════════
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Config.Keybind then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    
    -- ═════════════════════════════════════════════════════════════════════════════════
    -- INITIAL ANIMATION
    -- ═════════════════════════════════════════════════════════════════════════════════
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 900, 0, 600)
    }):Play()
    
    -- Initial logs
    Console.Log("Open Ringta Ultra v" .. Config.Version .. " loaded!", "success")
    Console.Log("Game: Ugc (ID: 70876832253163)", "info")
    Console.Log("Press F4 to toggle UI", "info")
    
    -- Welcome notification
    NotificationCenter.Notify("Open Ringta Ultra", "Welcome! Press F4 to toggle UI", 5, "success")
    
    return screenGui
end

-- ═════════════════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═════════════════════════════════════════════════════════════════════════════════════
local function Initialize()
    -- Scan remotes
    Remotes.Scan()
    
    -- Create GUI
    GUI.Create()
    
    -- ESP Loop
    RunService.RenderStepped:Connect(function()
        ESP.Update()
    end)
    
    -- Auto-scan new players
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            if ESP.Enabled and ESP.Players then
                ESP.CreateObject(char, "player")
            end
        end)
    end)
    
    -- Weapon mods loop
    task.spawn(function()
        while true do
            if WeaponMods.InfiniteAmmo or WeaponMods.RapidFire or WeaponMods.NoRecoil then
                WeaponMods.Apply()
            end
            task.wait(1)
        end
    end)
    
    print("╔═══════════════════════════════════════════════════════════════════════════════════╗")
    print("║                    OPEN RINGTA ULTRA - LOADED SUCCESSFULLY                        ║")
    print("║                              Version " .. Config.Version .. "                              ║")
    print("╚═══════════════════════════════════════════════════════════════════════════════════╝")
end

-- Start
Initialize()
