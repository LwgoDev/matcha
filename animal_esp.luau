-- THIS IS NOT MINE

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = Workspace.CurrentCamera

local ANIMALS = {
    Bison = { normal = 150 },
    Bear  = { normal = 300 },
    Gator = { normal = 300 },
    Deer  = { normal = 100 },
    Cow   = { normal = 150 },
    Capybara = { normal = 250 },
}

local generalEnabled = false
local legendaryEnabled = false
local espObjects = {}
local notifiedLegendaries = {}
local healthCache = {}
local scanTimer = 0
local SCAN_INTERVAL = 3.0
local MAX_DISTANCE = 10000
local frameCounter = 0
local UPDATE_EVERY_N_FRAMES = 1

UI.AddTab("Animal ESP", function(tab)
    local sec = tab:Section("Settings", "Left")
    sec:Toggle("animal_general", "All Animals", false, function(state)
        generalEnabled = state
    end)
    sec:Toggle("animal_legendary", "Legendary Only", false, function(state)
        legendaryEnabled = state
    end)
    sec:Text("White = Normal | Yellow = Legendary")
    sec:Tip("Legendary = health above normal (Bison>150, Bear>300, Gator>300)")
end)

local function createESP()
    local box = Drawing.new("Square")
    box.Filled = false
    box.Thickness = 2
    box.Visible = false
    box.ZIndex = 10

    local text = Drawing.new("Text")
    text.Size = 16
    text.Font = Drawing.Fonts.UI
    text.Center = true
    text.Outline = true
    text.Visible = false
    text.ZIndex = 11

    local distLabel = Drawing.new("Text")
    distLabel.Size = 14
    distLabel.Font = Drawing.Fonts.UI
    distLabel.Center = true
    distLabel.Outline = true
    distLabel.Visible = false
    distLabel.ZIndex = 11

    return { box = box, text = text, distLabel = distLabel }
end

local function getAnimalPosition(animal)
    local root = animal:FindFirstChild("HumanoidRootPart")
    if root then return root.Position end
    for _, child in ipairs(animal:GetChildren()) do
        if child:IsA("BasePart") then
            return child.Position
        end
    end
    return nil
end

local function getAnimalSize(animal)
    local name = animal.Name
    if name == "Bison" then return Vector3.new(4, 2.5, 2) end
    if name == "Bear" then return Vector3.new(3, 2.5, 2) end
    if name == "Gator" then return Vector3.new(5, 2, 1.5) end
    if name == "Deer" then return Vector3.new(2, 2, 1.5) end
    if name == "Cow" then return Vector3.new(3, 2.5, 2) end
    if name == "Capybara" then return Vector3.new(2, 1.5, 1.5) end
    return Vector3.new(3, 2, 2)
end

local function getHealth(animal)
    local key = animal
    if healthCache[key] ~= nil then
        return healthCache[key]
    end
    local healthObj = animal:FindFirstChild("Health", true)
    local health = 0
    if healthObj then
        local ok, val = pcall(function()
            if healthObj:IsA("NumberValue") or healthObj:IsA("IntValue") then
                return healthObj.Value
            end
            return healthObj:GetAttribute("Health") or 0
        end)
        if ok and type(val) == "number" then
            health = val
        end
    end
    healthCache[key] = health
    return health
end

local function isLegendary(animal)
    local health = getHealth(animal)
    local name = animal.Name
    local info = ANIMALS[name]
    if info and info.normal then
        return health > info.normal
    end
    return false
end

local function updateESP(animal, data, cameraPos, viewport)
    local pos = getAnimalPosition(animal)
    if not pos then
        data.box.Visible = false
        data.text.Visible = false
        data.distLabel.Visible = false
        return
    end

    local distance = (pos - cameraPos).Magnitude
    if distance > MAX_DISTANCE then
        data.box.Visible = false
        data.text.Visible = false
        data.distLabel.Visible = false
        return
    end

    local screenPos = WorldToScreen(pos)
    if not screenPos then
        data.box.Visible = false
        data.text.Visible = false
        data.distLabel.Visible = false
        return
    end

    if screenPos.X < 0 or screenPos.X > viewport.X or screenPos.Y < 0 or screenPos.Y > viewport.Y then
        data.box.Visible = false
        data.text.Visible = false
        data.distLabel.Visible = false
        return
    end

    local isLeg = isLegendary(animal)
    local show = false
    local color = Color3.fromRGB(255, 255, 255)

    if isLeg and legendaryEnabled then
        show = true
        color = Color3.fromRGB(255, 215, 0)
        if not notifiedLegendaries[animal] then
            notifiedLegendaries[animal] = true
            local health = getHealth(animal)
            notify("Legendary " .. animal.Name, "Health: " .. health .. " | Distance: " .. math.floor(distance) .. " studs", 4)
        end
    elseif generalEnabled and not (legendaryEnabled and isLeg) then
        show = true
        color = Color3.fromRGB(255, 255, 255)
    end

    if not show then
        data.box.Visible = false
        data.text.Visible = false
        data.distLabel.Visible = false
        return
    end

    data.box.Color = color
    data.text.Color = color
    data.distLabel.Color = color

    local size = getAnimalSize(animal)
    local scale = math.max(0.5, 90 / distance)
    local boxSize = Vector2.new(size.X * scale * 30, size.Y * scale * 30)
    boxSize = Vector2.new(math.max(25, boxSize.X), math.max(25, boxSize.Y))

    data.box.Position = Vector2.new(screenPos.X - boxSize.X/2, screenPos.Y - boxSize.Y/2)
    data.box.Size = boxSize
    data.box.Visible = true

    local displayName = animal.Name
    if isLeg and legendaryEnabled then
        displayName = displayName .. " ★"
    end
    data.text.Text = displayName
    data.text.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y/2 - 18)
    data.text.Visible = true

    data.distLabel.Text = math.floor(distance) .. "s"
    data.distLabel.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y/2 + 18)
    data.distLabel.Visible = true
end

local function scanAnimals()
    local animalsFolder = Workspace:FindFirstChild("WORKSPACE_Entities")
    if not animalsFolder then return end
    local animals = animalsFolder:FindFirstChild("Animals")
    if not animals then return end

    -- Clean cache for removed animals
    for key in pairs(healthCache) do
        if not key.Parent or not ANIMALS[key.Name] then
            healthCache[key] = nil
        end
    end

    local currentAnimals = {}
    for _, child in ipairs(animals:GetChildren()) do
        if ANIMALS[child.Name] then
            currentAnimals[child] = true
            if not espObjects[child] then
                espObjects[child] = createESP()
            end
            healthCache[child] = nil
        end
    end

    for model, data in pairs(espObjects) do
        if not currentAnimals[model] or not model.Parent then
            if data.box then data.box:Remove() end
            if data.text then data.text:Remove() end
            if data.distLabel then data.distLabel:Remove() end
            espObjects[model] = nil
            notifiedLegendaries[model] = nil
            healthCache[model] = nil
        end
    end
end

local function updateAllESP(cameraPos, viewport)
    if next(espObjects) == nil then
        return
    end
    for animal, data in pairs(espObjects) do
        if animal and animal.Parent then
            updateESP(animal, data, cameraPos, viewport)
        else
            if data.box then data.box:Remove() end
            if data.text then data.text:Remove() end
            if data.distLabel then data.distLabel:Remove() end
            espObjects[animal] = nil
            notifiedLegendaries[animal] = nil
            healthCache[animal] = nil
        end
    end
end

RunService.RenderStepped:Connect(function(delta)
    generalEnabled = UI.GetValue("animal_general") or false
    legendaryEnabled = UI.GetValue("animal_legendary") or false

    if not generalEnabled and not legendaryEnabled then
        for _, data in pairs(espObjects) do
            if data.box then data.box.Visible = false end
            if data.text then data.text.Visible = false end
            if data.distLabel then data.distLabel.Visible = false end
        end
        return
    end

    frameCounter = frameCounter + 1

    scanTimer = scanTimer + delta
    if scanTimer >= SCAN_INTERVAL then
        scanTimer = 0
        scanAnimals()
    end

    if frameCounter % UPDATE_EVERY_N_FRAMES == 0 then
        local cameraPos = Camera.CFrame.Position
        local viewport = Camera.ViewportSize
        updateAllESP(cameraPos, viewport)
    end
end)

scanAnimals()
notify("Animal ESP loaded", 3)
