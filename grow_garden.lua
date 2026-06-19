-- ============================================================
-- XEPHOR GROW A GARDEN 2 - FIX LAG + AIMBOT + EFFECTS
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- CONFIG
local Config = {
    AimbotEnabled = true,
    AimbotFOV = 200,
    AimbotSmooth = 0.3,
    ShowESP = true,
    AutoFarm = false,
    FixLag = true,
}

-- FIX LAG
if Config.FixLag then
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Fire") then
            v.Enabled = false
        end
    end
    local gs = UserSettings().GameSettings
    gs.GraphicsMode = Enum.GraphicsMode.Manual
    gs.MaterialQuality = Enum.MaterialQuality.Low
end

-- ESP
local function createESP(target)
    if not Config.ShowESP then return end
    local h = Instance.new("Highlight")
    h.Adornee = target
    h.FillColor = Color3.fromRGB(0, 255, 255)
    h.FillTransparency = 0.3
    h.Parent = target
end

for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= player.Character then
        createESP(v)
    end
end

-- AIMBOT
local function getTarget()
    local nearest, nearestDist = nil, 50
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= player.Character then
            local root = v:FindFirstChild("HumanoidRootPart")
            if root then
                local pos, onScreen = camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist < Config.AimbotFOV and dist < nearestDist then
                        nearest, nearestDist = v, dist
                    end
                end
            end
        end
    end
    return nearest
end

RunService.Heartbeat:Connect(function()
    if Config.AimbotEnabled then
        local target = getTarget()
        if target then
            local root = target:FindFirstChild("HumanoidRootPart")
            if root then
                local targetPos = root.Position + Vector3.new(0, 1.5, 0)
                local camPos = camera.CFrame.Position
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camPos, targetPos), Config.AimbotSmooth)
            end
        end
    end
end)

-- AUTO FARM
task.spawn(function()
    while true do
        if Config.AutoFarm then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, Enum.UserInputType.MouseButton1, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, Enum.UserInputType.MouseButton1, 0)
        end
        task.wait(0.1)
    end
end)

-- KEYBINDS
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.AimbotEnabled = not Config.AimbotEnabled
        print("Aimbot:", Config.AimbotEnabled)
    end
    if input.KeyCode == Enum.KeyCode.F2 then
        Config.ShowESP = not Config.ShowESP
        print("ESP:", Config.ShowESP)
    end
    if input.KeyCode == Enum.KeyCode.F3 then
        Config.AutoFarm = not Config.AutoFarm
        print("Auto Farm:", Config.AutoFarm)
    end
end)

print("🔥 XEPHOR GROW A GARDEN 2 LOADED!")
