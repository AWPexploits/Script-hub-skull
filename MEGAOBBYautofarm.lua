local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local restartObby = workspace:WaitForChild("Restart Obby")


local targetPart = workspace["Restart Obby"].Part

if targetPart and targetPart:IsA("BasePart") then
    local scaleFactor = Vector3.new(3, 1, 3) 
    targetPart.Size = targetPart.Size * scaleFactor

    -- Set up tweening
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.005, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true) 

 
    local function tweenPart()

        local initialPosition = hrp.Position + Vector3.new(0, 5, 0)
        targetPart.CFrame = CFrame.new(initialPosition)


        local upTween = tweenService:Create(targetPart, tweenInfo, {Position = hrp.Position + Vector3.new(0, 10, 0)})
        upTween:Play()

        upTween.Completed:Connect(function()
     
            targetPart.CFrame = initialPosition
            print("Part moved and reset above the character.")
            tweenPart()
        end)
    end


    tweenPart()

else
    print("Target part not found in 'Restart Obby'.")
end
