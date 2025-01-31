local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local farming = false
local character
local rootPart
local humanoid

local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:FindFirstChildOfClass("Humanoid")
end

player.CharacterAdded:Connect(function()
    wait(1)
    updateCharacter()
end)

updateCharacter()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 150, 0, 50)
ToggleButton.Position = UDim2.new(0.85, 0, 0.1, 0)
ToggleButton.Text = "Ativar Farm"
ToggleButton.Parent = ScreenGui

ToggleButton.MouseButton1Click:Connect(function()
    farming = not farming
    ToggleButton.Text = farming and "Desativar Farm" or "Ativar Farm"
end)

local function noClip()
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end
RunService.Stepped:Connect(noClip)

local function findClosestCoin()
    local closestCoin = nil
    local shortestDistance = math.huge

    for _, container in ipairs(workspace:GetChildren()) do
        local coinContainer = container:FindFirstChild("CoinContainer")
        if coinContainer then
            for _, coin in ipairs(coinContainer:GetChildren()) do
                if coin.Name == "Coin_Server" and coin:IsA("BasePart") then
                    local distance = (rootPart.Position - coin.Position).Magnitude
                    if distance < shortestDistance then
                        closestCoin = coin
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestCoin
end

local function moveToCoin(coin)
    if not rootPart or not coin then return end
    local targetPosition = coin.Position
    rootPart.CFrame = CFrame.new(targetPosition - Vector3.new(0, 10, 0))
    wait(0.2)
    rootPart.CFrame = CFrame.new(targetPosition)
    wait(0.2)
    rootPart.CFrame = CFrame.new(targetPosition - Vector3.new(0, 10, 0))
    wait(0.2)
end

spawn(function()
    while true do
        if farming and rootPart then
            local coin = findClosestCoin()
            if coin then
                moveToCoin(coin)
            end
        end
        wait(0.5)
    end
end)

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
