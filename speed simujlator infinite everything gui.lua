
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")


local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = screenGui


local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)  
corner.Parent = frame


local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if not dragging then return end
            updateDrag(input)
        end)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)


local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 200, 0, 30)
speedLabel.Position = UDim2.new(0.5, -100, 0, 20)
speedLabel.Text = "Enter Speed:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = frame


local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0, 200, 0, 30)
speedInput.Position = UDim2.new(0.5, -100, 0, 60)
speedInput.PlaceholderText = "0"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedInput.Parent = frame

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(0, 200, 0, 30)
moneyLabel.Position = UDim2.new(0.5, -100, 0, 100)
moneyLabel.Text = "Enter Money:"
moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Parent = frame

local moneyInput = Instance.new("TextBox")
moneyInput.Size = UDim2.new(0, 200, 0, 30)
moneyInput.Position = UDim2.new(0.5, -100, 0, 140)
moneyInput.PlaceholderText = "0"
moneyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
moneyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
moneyInput.Parent = frame


local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 40)
button.Position = UDim2.new(0.5, -100, 0, 180)
button.Text = "Give Cash"
button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = frame


button.MouseButton1Click:Connect(function()
    -- Get the inputs
    local speed = tonumber(speedInput.Text)
    local money = tonumber(moneyInput.Text)

    if speed and money then
      
        local args = {
            [1] = speed, 
            [2] = money  
        }

   
        game:GetService("ReplicatedStorage").GlobalFunctions.AddPlayerSpeed:FireServer(unpack(args))
    else
 
        print("Invalid input! Please enter valid numbers for speed and money.")
    end
end)


game.Players.LocalPlayer.CharacterAdded:Connect(function()

    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end)


screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
