local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local PlaceId = game.PlaceId
local JobId = game.JobId

local WebhookURL = "https://discord.com/api/webhooks/1367992741375643721/CITgXfhkeFZC4Q1k832QIPbAj3_rM4Tl81ZqR-u164g5ccZCsC00UA7uLItyJKR0Cs9J"

local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or httprequest

if queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://pastebin.com/raw/YOUR_PASTE_ID"))()
    ]])
end

task.spawn(function()
    while true do
        local prompt = CoreGui:FindFirstChild("ErrorPrompt", true)
        if prompt and prompt:IsA("Frame") then
            local okBtn = prompt:FindFirstChild("OK", true)
            if okBtn then
                pcall(function()
                    okBtn.MouseButton1Click:Fire()
                    print("Dismissed 'Requested experience full' prompt.")
                end)
            end
        end
        task.wait(0.25)
    end
end)

local function sendWebhook(message)
    if not requestFunc then return end
    pcall(function()
        requestFunc({
            Url = WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ content = message })
        })
    end)
end

local function hopToNewServer()
    if not requestFunc then return false end

    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", PlaceId)
    local success, result = pcall(function()
        return requestFunc({ Url = url })
    end)

    if not (success and result and result.Body) then return false end

    local data = HttpService:JSONDecode(result.Body)
    local servers = {}

    for _, v in ipairs(data.data or {}) do
        if v.id ~= JobId and v.playing < v.maxPlayers then
            table.insert(servers, v.id)
        end
    end

    if #servers > 0 then
        local target = servers[math.random(1, #servers)]
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, target, LocalPlayer)
        end)
        if ok then return true else warn("Teleport failed:", err) end
    else
        warn("No suitable servers found.")
    end

    return false
end

local function checkForSillyEgg()
    task.wait(5.75)

    local rifts = workspace:FindFirstChild("Rendered") and workspace.Rendered:FindFirstChild("Rifts")
    local sillyEgg = rifts and rifts:FindFirstChild("silly-egg")

    if sillyEgg then
        local msg = "@everyone 🪺 silly-egg found!\nPlaceId: " .. PlaceId .. "\nJobId: " .. JobId
        sendWebhook(msg)
    else
        local msg = "❌ silly-egg NOT found.\nPlaceId: " .. PlaceId .. "\nJobId: " .. JobId .. "\nRifts Children:\n"
        if rifts then
            for _, child in ipairs(rifts:GetChildren()) do
                msg = msg .. "- " .. child.Name .. "\n"
            end
        else
            msg = msg .. "(Rifts folder missing)"
        end
        sendWebhook(msg)

        -- Retry logic for full server with improvements
        local retries = 0
        local maxRetries = 10000 -- Set a high retry limit (10000)
        local teleportSuccess = false

        while retries < maxRetries and not teleportSuccess do
            teleportSuccess = hopToNewServer()  -- Try to teleport

            if teleportSuccess then
                print("Successfully hopped to a new server!")
            else
                print("Retry #" .. retries .. " failed. Retrying...")
                retries = retries + 1
                task.wait(0.25)  -- Wait before retrying again
            end
        end

        if retries >= maxRetries then
            warn("Max retries reached. Could not find an available server.")
        end
    end
end

checkForSillyEgg()
