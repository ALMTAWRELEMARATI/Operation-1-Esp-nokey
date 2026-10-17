-- =========================================
-- Operation 1 | Draggable ESP (Viewmodels)
-- =========================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- =========================================
-- ESP Logic
-- =========================================
local espEnabled = false
local espColor = Color3.fromRGB(0, 255, 0)
local espOutline = Color3.fromRGB(255, 255, 255)

local function getViewmodelsFolder()
    local ws = workspace
    local folder = ws:FindFirstChild("Viewmodels")
    return folder
end

local function findTorso(model)
    -- Check direct children first
    local torso = model:FindFirstChild("Torso")
    if torso and torso:IsA("BasePart") then return torso end
    
    -- Recursive fallback
    torso = model:FindFirstChild("Torso", true)
    if torso and torso:IsA("BasePart") then return torso end
    
    -- Any part containing "torso" (case-insensitive)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "torso") then
            return obj
        end
    end
    
    -- Last resort: first BasePart
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then return obj end
    end
    
    return nil
end

local function applyESP()
    local folder = getViewmodelsFolder()
    if not folder then return end
    
    for _, model in ipairs(folder:GetChildren()) do
        -- Skip your own viewmodel
        if model.Name ~= "LocalViewmodel" and model.Name ~= LocalPlayer.Name then
            local torso = findTorso(model)
            if torso and not torso:FindFirstChild("ESP_Highlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Adornee = torso
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = espColor
                highlight.OutlineColor = espOutline
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = torso
            end
        end
    end
end

local function removeESP()
    local folder = getViewmodelsFolder()
    if not folder then return end
    
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj.Name == "ESP_Highlight" then
            obj:Destroy()
        end
    end
end

local function toggleESP(state)
    espEnabled = state
    if state then
        applyESP()
    else
        removeESP()
    end
end

-- Continuously refresh ESP (viewmodels appear/disappear dynamically)
task.spawn(function()
    while true do
        task.wait(0.5)
        if espEnabled then
            applyESP()
        end
    end
end)

-- =========================================
-- Draggable GUI Button
-- =========================================
local gui = Instance.new("ScreenGui")
gui.Name = "ESPButtonGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

local button = Instance.new("TextButton")
button.Name = "ESPButton"
button.Size = UDim2.new(0, 120, 0, 40)
button.Position = UDim2.new(0, 20, 0, 100)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.BorderSizePixel = 0
button.Text = "ESP: OFF"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.AutoButtonColor = false
button.Active = true
button.Draggable = true
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 2
stroke.Parent = button

local dragStart
button.MouseButton1Down:Connect(function()
    dragStart = UserInputService:GetMouseLocation()
end)

button.MouseButton1Up:Connect(function()
    if dragStart then
        local moved = (UserInputService:GetMouseLocation() - dragStart).Magnitude
        if moved < 5 then
            local newState = not espEnabled
            toggleESP(newState)
            
            if newState then
                button.Text = "ESP: ON"
                button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                stroke.Color = Color3.fromRGB(0, 255, 0)
            else
                button.Text = "ESP: OFF"
                button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                stroke.Color = Color3.fromRGB(255, 0, 0)
            end
        end
    end
    dragStart = nil
end)

print("[ESP] Viewmodel-based draggable ESP loaded.")
