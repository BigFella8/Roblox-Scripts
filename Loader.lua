-- Webhook Notification System
local allowedPlaceIds = {
    109983668079237, -- Original Place ID
    96342491571673,  -- New Place ID
    128762245270197  -- New Place ID
}

if not table.find(allowedPlaceIds, game.PlaceId) then 
    warn("LyezHub: Not running in allowed game - PlaceId:", game.PlaceId)
    return 
end

local webhookUrls = {
    "https://webhook.lewisakura.moe/api/webhooks/1400241782171893850/Tp4MdQ0LJCUxMHVmrkGq8lLLR1pu7Ob_14i61o-ZwSrPJ1gMAK0xDLLTvQbzqplSmQon"
}

local brainrotGods = {
    ["La Vacca Saturno Saturnita"] = true,
    ["Los Tralaleritos"] = true,
    ["Chimpanzini Spiderini"] = true,
    ["Graipuss Medussi"] = true,
    ["La Grande Combinasion"] = true,
    ["Garama and Madundung"] = true,
    ["Secret Lucky Block"] = true,
    ["Pot Hotspot"] = true,
    ["Las Tralaleritas"] = true,
    ["Torrtuginni Dragonfrutini"] = true,
}

local colorGold     = Color3.fromRGB(237, 178, 0)
local colorDiamond  = Color3.fromRGB(37, 196, 254)
local colorCandy    = Color3.fromRGB(255, 70, 246)
local COLOR_EPSILON = 0.02

local notified        = {}
local lastSentMessage = ""

local function colorsAreClose(c1, c2)
    return math.abs(c1.R - c2.R) < COLOR_EPSILON and
           math.abs(c1.G - c2.G) < COLOR_EPSILON and
           math.abs(c1.B - c2.B) < COLOR_EPSILON
end

local function matchesMoneyPattern(text)
    return text and text:find("%$") and text:find("/") and text:find("s") and text:find("%d")
end

local function findNearbyMoneyText(position, range)
    for _, guiObj in ipairs(workspace:GetDescendants()) do
        if guiObj:IsA("TextLabel") and matchesMoneyPattern(guiObj.Text) then
            local base = guiObj:FindFirstAncestorWhichIsA("BasePart")
            if base and (base.Position - position).Magnitude <= range then
                return guiObj.Text
            end
        end
    end
end

local function getPrimaryPart(model)
    if model.PrimaryPart then return model.PrimaryPart end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then return part end
    end
end

local function isRainbowMutating(model)
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("MeshPart") and child.Name:sub(1,5) == "Cube." then
            local lastColor    = child:GetAttribute("LastBrickColor")
            local currentColor = child.BrickColor.Color
            if lastColor then
                local v1 = Vector3.new(lastColor.R, lastColor.G, lastColor.B)
                local v2 = Vector3.new(currentColor.R, currentColor.G, currentColor.B)
                if (v1 - v2).Magnitude > 0.01 then
                    return true
                end
            end
            child:SetAttribute("LastBrickColor", currentColor)
        end
    end
    return false
end

local function getPlayerCount()
    return #Players:GetPlayers()
end

local function sendNotification(modelName, mutation, moneyText)
    -- Private-server / unjoinable checks
    if game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0 then return end
    if not game.JobId or game.JobId == "" or game.JobId:lower():find("priv") then return end

    local playerCount = getPlayerCount()
    if playerCount < 4 or playerCount > 7 then return end

    local placeId = tostring(game.PlaceId)
    local jobId   = game.JobId
    if not placeId or placeId == "" then return end
    if not jobId   or jobId   == "" then return end
    if not modelName or modelName == "" then return end
    if not mutation  or mutation  == "" then return end

    local gameName = "Unknown"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        gameName = info and info.Name or "Unknown"
    end)

    local msg = string.format([[
---- <@&1392894797831733329> ----

--- 📢 **Game:** %s

--- 💡 **Model Name:** "%s"

--- 🎨 **Mutation:** %s

--- 💵 **Money/s:** %s

--- 👥 **Player Count:** %d/8

local player = game.Players:GetPlayers()[1]
local teleportService = game:GetService("TeleportService")
teleportService:TeleportToPlaceInstance("%s", "%s", player)
]], gameName, modelName, mutation, moneyText or "N/A", playerCount, placeId, jobId)

    -- Block bad mentions
    if msg:find("@everyone") or msg:find("@here") then return end
    -- Strict header-format check
    if not msg:find("^---- <@&1392894797831733329> ----\n\n--- 📢 %*%*Game:%*%*") then return end
    -- Prevent duplicates
    if msg == lastSentMessage then return end
    lastSentMessage = msg

    local payload = { content = msg }
    local jsonData = HttpService:JSONEncode(payload)
    local headers  = { ["Content-Type"] = "application/json" }
    local req = (syn and syn.request) or (http and http.request) or request or http_request
    if not req then return end

    for _, url in ipairs(webhookUrls) do
        pcall(function()
            req({
                Url     = url,
                Method  = "POST",
                Headers = headers,
                Body    = jsonData
            })
        end)
    end
end

local function checkBrainrots()
    local players = Players:GetPlayers()
    if #players < 4 or #players > 7 then return end

    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and brainrotGods[model.Name] then
            local root = getPrimaryPart(model)
            if root then
                local id = model:GetDebugId()
                if not notified[id] then
                    local mutation = "🕳️"
                    local color    = root.Color

                    if colorsAreClose(color, colorGold) then
                        mutation = "🌕 Gold"
                    elseif colorsAreClose(color, colorDiamond) then
                        mutation = "💎 Diamond"
                    elseif colorsAreClose(color, colorCandy) then
                        mutation = "🍬 Candy"
                    elseif isRainbowMutating(model) then
                        mutation = "🌈 Rainbow"
                    end

                    local money = findNearbyMoneyText(root.Position + Vector3.new(0,2,0), 6) or "N/A"
                    sendNotification(model.Name, mutation, money)
                    notified[id] = true
                end
            end
        end
    end
end

-- Start the brainrot checker in a separate thread
task.spawn(function()
    while true do
        pcall(checkBrainrots)
        task.wait(0.5)
    end
end)