-- ============================================================
-- XEPHOR GROW A GARDEN 2 - FULL SCRIPT
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

local Config = {
    AimbotEnabled = true,
    AimbotFOV = 200,
    AimbotSmooth = 0.3,
    ShowESP = true,
    AutoFarm = false,
    FixLag = true,
}

local function showToast(msg, color)
    color = color or Color3.fromRGB(0, 255, 255)
    local gui = Instance.new("ScreenGui")
    gui.Parent = player.PlayerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0.1, -60)
    frame.BackgroundColor3 = Color3.fromRGB(0, 10, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 0, 2)
    border.BackgroundColor3 = color
    border.Parent = frame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = msg
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0.1, 50)}):Play()
    task.wait(2.5)
    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0.1, -60)}):Play()
    task.wait(0.3)
    gui:Destroy()
end

local function fixLag()
    if not Config.FixLag then return end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
    Lighting.Brightness = 1.5
    Lighting.ClockTime = 12
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Decal") then
            v:Destroy()
        end
    end
    local gs = UserSettings().GameSettings
    gs.GraphicsMode = Enum.GraphicsMode.Manual
    gs.MaterialQuality = Enum.MaterialQuality.Low
    gs.TextureQuality = Enum.TextureQuality.Low
end

local function setupEffects()
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.3
    bloom.Size = 10
    bloom.Threshold = 0.5
    bloom.Parent = camera
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Saturation = 0.8
    cc.Brightness = 1.2
    cc.Parent = camera
    Lighting.Ambient = Color3.fromRGB(100, 120, 150)
end

local espObjects = {}
local function createESP(target)
    if not Config.ShowESP then return end
    if espObjects[target] then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = target
    highlight.FillColor = Color3.fromRGB(0, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.Parent = target
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.Adornee = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
    billboard.Parent = target
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = target.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    espObjects[target] = true
end

local function updateESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= player.Character then
            if v:FindFirstChild("Humanoid").Health > 0 then
                createESP(v)
            end
        end
    end
end

local function getNearestTarget()
    local nearest = nil
    local nearestDist = 50
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= player.Character then
            local root = v:FindFirstChild("HumanoidRootPart")
            if root and v:FindFirstChild("Humanoid").Health > 0 then
                local pos, onScreen = camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local screenDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if screenDist < Config.AimbotFOV and screenDist < nearestDist then
                        nearest = v
                        nearestDist = screenDist
                    end
                end
            end
        end
    end
    return nearest
end

local function aimAt(target)
    if not target then return end
    local root = target:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local head = target:FindFirstChild("Head") or root
    local targetPos = head.Position + Vector3.new(0, 1.5, 0)
    local camPos = camera.CFrame.Position
    local direction = (targetPos - camPos).unit
    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camPos, camPos + direction), Config.AimbotSmooth)
end

local function autoFarm()
    while Config.AutoFarm do
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, Enum.UserInputType.MouseButton1, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, Enum.UserInputType.MouseButton1, 0)
        task.wait(0.1)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.AimbotEnabled = not Config.AimbotEnabled
        showToast("Aimbot: " .. (Config.AimbotEnabled and "ON ✅" or "OFF ❌"))
    end
    if input.KeyCode == Enum.KeyCode.F2 then
        Config.ShowESP = not Config.ShowESP
        showToast("ESP: " .. (Config.ShowESP and "ON ✅" or "OFF ❌"))
    end
    if input.KeyCode == Enum.KeyCode.F3 then
        Config.AutoFarm = not Config.AutoFarm
        showToast("Auto Farm: " .. (Config.AutoFarm and "ON ✅" or "OFF ❌"))
        if Config.AutoFarm then
            task.spawn(autoFarm)
        end
    end
end)

fixLag()
setupEffects()
updateESP()

RunService.Heartbeat:Connect(function()
    if Config.AimbotEnabled then
        local target = getNearestTarget()
        if target then
            aimAt(target)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        updateESP()
    end
end)

showToast("🔥 XEPHOR GROW A GARDEN 2 LOADED!", Color3.fromRGB(0, 255, 255))
print("🔥 XEPHOR SCRIPT LOADED!")
