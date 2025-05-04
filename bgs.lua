local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

local WebhookURL = "https://discord.com/api/webhooks/1367992741375643721/CITgXfhkeFZC4Q1k832QIPbAj3_rM4Tl81ZqR-u164g5ccZCsC00UA7uLItyJKR0Cs9J"

local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or httprequest

local function sendWebhook(message)
    if not requestFunc then
        warn("No supported HTTP request function found.")
        return
    end

    local data = { content = message }

    requestFunc({
        Url = WebhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end

local function clickErrorPrompt()
    -- Check if the error prompt exists and handle it
    local prompt = CoreGui:FindFirstChild("ErrorPrompt", true)
    if prompt and prompt:IsA("Frame") then
        local okButton = prompt:FindFirstChild("OK")
        if okButton and okButton:IsA("TextButton") then
            okButton.MouseButton1Click:Fire()
            print("[Info] Clicked OK on full server prompt.")
        end
    end
end

-- This function will be queued and run when teleporting to a new server
local function queueTeleport()
    local code = [[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AWPexploits/Script-hub-skull/refs/heads/main/bgs"))()
    ]]
    pcall(function()
        queue_on_teleport(code)
    end)
end

local function hopToNewServer()
    if not requestFunc then return false end

    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true",
        PlaceId
    )

    local success, result = pcall(function()
        return requestFunc({ Url = url, Method = "GET" })
    end)

    if success and result and result.Body then
        local decoded = HttpService:JSONDecode(result.Body)
        if decoded and decoded.data then
            for _, server in ipairs(decoded.data) do
                if server.id ~= JobId and server.playing < server.maxPlayers then
                    print("[Info] Teleporting to server:", server.id)
                    queueTeleport()
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                    return true
                end
            end
        end
    end

    return false
end

local function checkForSillyEgg()
    task.wait(5.75)

    local rifts = workspace:FindFirstChild("Rendered") and workspace.Rendered:FindFirstChild("Rifts")
    local sillyEgg = rifts and rifts:FindFirstChild("silly-egg")

    if sillyEgg then
        local msg = "@everyone 🪺 **silly-egg found!**\n"
            .. "📍 **PlaceId**: `" .. PlaceId .. "`\n"
            .. "🔗 **JobId**: `" .. JobId .. "`"
        sendWebhook(msg)
    else
        local report = "❌ **silly-egg NOT found.**\n📍 PlaceId: `" .. PlaceId .. "`\n🔗 JobId: `" .. JobId .. "`\n"

        if rifts then
            report = report .. "Rifts contains:\n"
            for _, child in ipairs(rifts:GetChildren()) do
                report = report .. "- " .. child.Name .. "\n"
            end
        else
            report = report .. "(⚠️ Rifts folder not found)"
        end

        sendWebhook(report)

        -- Retry loop with throttling and prompt dismissal
        local maxRetries = 10000
        local retryCount = 0
        while retryCount < maxRetries do
            retryCount = retryCount + 1
            print("Retrying... Attempt #" .. retryCount)

            -- Try hopping to a new server
            local hopped = hopToNewServer()
            if hopped then break end

            -- Check for the ErrorPrompt only every 0.5 seconds to avoid overloading the executor
            if retryCount % 5 == 0 then
                clickErrorPrompt()
            end

            task.wait(0.25)  -- Throttle retries to avoid too many requests
        end

        if retryCount >= maxRetries then
            warn("❗ Max retry attempts reached. Could not find an available server.")
        end
    end
end

-- Handle re-entry into new server
Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then
        print("[Info] Rejoined server, continuing egg check.")
        checkForSillyEgg()
    end
end)

-- Initial check for the silly-egg when the script starts
checkForSillyEgg()
