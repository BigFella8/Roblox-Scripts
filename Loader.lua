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
fill.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple color
fill.BorderSizePixel = 0
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 12)
fillCorner.Parent = fill
fill.Parent = frame

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(128, 0, 128) -- Purple color
textLabel.Text = "0%"
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 24
textLabel.TextStrokeTransparency = 0.8
textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
textLabel.Parent = frame

-- Add skip button
local skipButton = Instance.new("TextButton")
skipButton.Size = UDim2.new(0, 100, 0, 30)
skipButton.Position = UDim2.new(0.5, -50, 0.5, 20) -- Below the loading bar
skipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
skipButton.Text = "Skip"
skipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
skipButton.Font = Enum.Font.GothamBold
skipButton.TextSize = 16
local skipCorner = Instance.new("UICorner")
skipCorner.CornerRadius = UDim.new(0, 8)
skipCorner.Parent = skipButton
skipButton.Parent = screenGui

-- Audio handling - executor-specific approach
local sound = Instance.new("Sound")
sound.Parent = screenGui
sound.Name = "LoadingSound"
sound.Volume = 25.0 -- Set reasonable volume

local function loadAudio()
    -- Method 2: Base64 audio (executor-specific)
    if getsynasset then -- Synapse X
        writefile("loading_audio.mp3", game:HttpGet("https://files.catbox.moe/fldrsa.mp3"))
        sound.SoundId = getsynasset("loading_audio.mp3")
    elseif getcustomasset then -- Other executors
        writefile("loading_audio.mp3", game:HttpGet("https://files.catbox.moe/fldrsa.mp3"))
        sound.SoundId = getcustomasset("loading_audio.mp3")
    elseif deltaasset then -- Placeholder for Delta iOS Executor function
        writefile("loading_audio.mp3", game:HttpGet("https://files.catbox.moe/fldrsa.mp3"))
        sound.SoundId = deltaasset("loading_audio.mp3")
    end

    -- Wait for sound to load with retry
    local maxWait = 0.1 -- Maximum wait time in seconds
    local startTime = tick()
    while tick() - startTime < maxWait do
        if pcall(function() return sound.IsLoaded end) and sound.IsLoaded then
            return true
        end
        task.wait(0.1)
    end
    return false
end

-- Play sound and start loading bar
spawn(function()
    local success = pcall(loadAudio)
    if success and loadAudio() then
        print("Audio loaded successfully")
        sound:Play()
        
        -- Debug sound state
        print("Sound state:", {
            IsLoaded = sound.IsLoaded,
            Playing = sound.Playing,
            TimeLength = sound.TimeLength
        })
        
        -- Start loading bar animation (5 seconds)
        local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
        local fillTween = TweenService:Create(fill, tweenInfo, { Size = UDim2.new(1, 0, 1, 0) })
        fillTween:Play()
        
        local function updatePercentage()
            local progress = fill.Size.X.Scale
            textLabel.Text = math.floor(progress * 100) .. "%"
        end
        fill:GetPropertyChangedSignal("Size"):Connect(updatePercentage)
        
        -- Wait for loading bar to complete, then fade out GUI
        fillTween.Completed:Connect(function()
            local fadeTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            local fadeFrame = TweenService:Create(frame, fadeTweenInfo, { BackgroundTransparency = 1 })
            local fadeFill = TweenService:Create(fill, fadeTweenInfo, { BackgroundTransparency = 1 })
            local fadeText = TweenService:Create(textLabel, fadeTweenInfo, {
                TextTransparency = 1,
                TextStrokeTransparency = 1
            })
            local fadeBlur = TweenService:Create(blur, fadeTweenInfo, { Size = 0 })
            local fadeLogo = TweenService:Create(logo, fadeTweenInfo, { TextTransparency = 1 })
            fadeFrame:Play()
            fadeFill:Play()
            fadeText:Play()
            fadeBlur:Play()
            fadeLogo:Play()
            fadeFrame.Completed:Connect(function()
                frame:Destroy()
                fill:Destroy()
                textLabel:Destroy()
                blur:Destroy()
                logo:Destroy()
                skipButton:Destroy()
                print("Loading screen destroyed.")
            end)
        end)
        
        -- Keep music playing for 15 seconds
        task.wait(20)
        if sound.Playing then
            sound:Stop()
        end
    else
        warn("Failed to load audio")
    end
end)

-- Skip button functionality
skipButton.MouseButton1Click:Connect(function()
    local fadeTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    local fadeFrame = TweenService:Create(frame, fadeTweenInfo, { BackgroundTransparency = 1 })
    local fadeFill = TweenService:Create(fill, fadeTweenInfo, { BackgroundTransparency = 1 })
    local fadeText = TweenService:Create(textLabel, fadeTweenInfo, {
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    local fadeBlur = TweenService:Create(blur, fadeTweenInfo, { Size = 0 })
    local fadeLogo = TweenService:Create(logo, fadeTweenInfo, { TextTransparency = 1 })
    fadeFrame:Play()
    fadeFill:Play()
    fadeText:Play()
    fadeBlur:Play()
    fadeLogo:Play()
    fadeFrame.Completed:Connect(function()
        frame:Destroy()
        fill:Destroy()
        textLabel:Destroy()
        blur:Destroy()
        logo:Destroy()
        skipButton:Destroy()
        print("Loading screen skipped.")
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
    local tween = TweenService:Create(bubble, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
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
