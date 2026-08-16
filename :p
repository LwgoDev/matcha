local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================
-- CONFIGURAÇÕES GERAIS
-- ============================
local MAX_DISTANCE = 10000
local SCAN_INTERVAL = 3.0
local frameCounter = 0
local UPDATE_EVERY_N_FRAMES = 1

-- ============================
-- ANIMAL ESP
-- ============================
local ANIMALS = {
    Bison = { normal = 150 },
    Bear  = { normal = 300 },
    Gator = { normal = 300 },
    Deer  = { normal = 100 },
    Cow   = { normal = 150 },
    Capybara = { normal = 250 },
}

local animalEnabled = false
local legendaryEnabled = false
local animalEspObjects = {}
local notifiedLegendaries = {}
local healthCache = {}
local animalScanTimer = 0

-- ============================
-- ORE ESP
-- ============================
local ORE_TYPES = {
    "Copper", "Zinc", "Iron", "Silver", "Gold", "Limestone",
    "ZincVein", "SilverVein", "GoldVein", "CoalVein", "CopperVein", "IronVein",
    "Quartz", "Coal"
}

local oreMasterEnabled = false
local oreEnabled = {}
for _, ore in ipairs(ORE_TYPES) do oreEnabled[ore] = false end
local oreEspObjects = {}
local oreScanTimer = 0

-- ============================
-- FUNÇÕES AUXILIARES
-- ============================
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

local function getAnimalHealth(animal)
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
    local health = getAnimalHealth(animal)
    local name = animal.Name
    local info = ANIMALS[name]
    if info and info.normal then
        return health > info.normal
    end
    return false
end

local function getOrePosition(deposit)
    for _, part in ipairs(deposit:GetDescendants()) do
        if part:IsA("BasePart") then
            return part.Position
        end
    end
    return nil
end

-- ============================
-- ATUALIZAR ESP DOS ANIMAIS
-- ============================
local function updateAnimalESP(animal, data, cameraPos, viewport)
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
            local health = getAnimalHealth(animal)
            notify("Legendary " .. animal.Name, "Health: " .. health .. " | Distance: " .. math.floor(distance) .. " studs", 4)
        end
    elseif animalEnabled and not (legendaryEnabled and isLeg) then
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

-- ============================
-- ATUALIZAR ESP DOS MINÉRIOS
-- ============================
local function updateOreESP(deposit, data, cameraPos, viewport)
    local pos = getOrePosition(deposit)
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

    local color = Color3.fromRGB(255, 255, 255)
    data.box.Color = color
    data.text.Color = color
    data.distLabel.Color = color

    local boxSize = Vector2.new(40, 40)
    data.box.Position = Vector2.new(screenPos.X - boxSize.X/2, screenPos.Y - boxSize.Y/2)
    data.box.Size = boxSize
    data.box.Visible = true

    local oreType = deposit.Parent and deposit.Parent.Name or "Ore"
    data.text.Text = oreType
    data.text.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y/2 - 18)
    data.text.Visible = true

    data.distLabel.Text = math.floor(distance) .. "s"
    data.distLabel.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y/2 + 18)
    data.distLabel.Visible = true
end

-- ============================
-- SCAN ANIMAIS
-- ============================
local function scanAnimals()
    local animalsFolder = Workspace:FindFirstChild("WORKSPACE_Entities")
    if not animalsFolder then return end
    local animals = animalsFolder:FindFirstChild("Animals")
    if not animals then return end

    for key in pairs(healthCache) do
        if not key.Parent or not ANIMALS[key.Name] then
            healthCache[key] = nil
        end
    end

    local currentAnimals = {}
    for _, child in ipairs(animals:GetChildren()) do
        if ANIMALS[child.Name] then
            currentAnimals[child] = true
            if not animalEspObjects[child] then
                animalEspObjects[child] = createESP()
            end
            healthCache[child] = nil
        end
    end

    for model, data in pairs(animalEspObjects) do
        if not currentAnimals[model] or not model.Parent then
            if data.box then data.box:Remove() end
            if data.text then data.text:Remove() end
            if data.distLabel then data.distLabel:Remove() end
            animalEspObjects[model] = nil
            notifiedLegendaries[model] = nil
            healthCache[model] = nil
        end
    end
end

-- ============================
-- SCAN MINÉRIOS
-- ============================
local function scanOres()
    local interactables = Workspace:FindFirstChild("WORKSPACE_Interactables")
    if not interactables then return end
    local mining = interactables:FindFirstChild("Mining")
    if not mining then return end
    local deposits = mining:FindFirstChild("OreDeposits")
    if not deposits then return end

    local current = {}
    for _, oreType in ipairs(ORE_TYPES) do
        local folder = deposits:FindFirstChild(oreType)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("Model") then
                    current[child] = true
                    if not oreEspObjects[child] then
                        oreEspObjects[child] = createESP()
                    end
                end
            end
        end
    end

    for deposit, data in pairs(oreEspObjects) do
        if not current[deposit] or not deposit.Parent then
            if data.box then data.box:Remove() end
            if data.text then data.text:Remove() end
            if data.distLabel then data.distLabel:Remove() end
            oreEspObjects[deposit] = nil
        end
    end
end

-- ============================
-- ATUALIZAR TODOS OS ESPs
-- ============================
local function updateAllESP(cameraPos, viewport)
    -- Animais
    for animal, data in pairs(animalEspObjects) do
        if animal and animal.Parent then
            updateAnimalESP(animal, data, cameraPos, viewport)
        else
            if data.box then data.box:Remove() end
            if data.text then data.text:Remove() end
            if data.distLabel then data.distLabel:Remove() end
            animalEspObjects[animal] = nil
            notifiedLegendaries[animal] = nil
            healthCache[animal] = nil
        end
    end

    -- Minérios
    for deposit, data in pairs(oreEspObjects) do
        if deposit and deposit.Parent then
            updateOreESP(deposit, data, cameraPos, viewport)
        else
            if data.box then data.box:Remove() end
            if data.text then data.text:Remove() end
            if data.distLabel then data.distLabel:Remove() end
            oreEspObjects[deposit] = nil
        end
    end
end

-- ============================
-- MENU
-- ============================
UI.AddTab("Animal ESP", function(tab)
    local sec = tab:Section("Settings", "Left")
    sec:Toggle("animal_general", "All Animals", false, function(state)
        animalEnabled = state
    end)
    sec:Toggle("animal_legendary", "Legendary Only", false, function(state)
        legendaryEnabled = state
    end)
    sec:Text("White = Normal | Yellow = Legendary")
    sec:Tip("Legendary = health above normal (Bison>150, Bear>300, Gator>300)")
end)

UI.AddTab("Ore ESP", function(tab)
    local sec = tab:Section("Ore Settings", "Left")

    sec:Toggle("ore_master", "Enable Ore ESP", false, function(state)
        oreMasterEnabled = state
        notify("Ore ESP", state and "ON" or "OFF", 2)
    end)

    for _, ore in ipairs(ORE_TYPES) do
        sec:Toggle("ore_" .. ore, ore, false, function(state)
            oreEnabled[ore] = state
        end)
    end

    sec:Button("Print Enabled", function()
        local list = {}
        for ore, state in pairs(oreEnabled) do
            if state then table.insert(list, ore) end
        end
        local msg = "Enabled: " .. (#list > 0 and table.concat(list, ", ") or "none")
        notify("Ore ESP", msg, 5)
    end)

    sec:Tip("Scroll down to see all ore toggles. Resize the menu if hidden.")
end)

-- ============================
-- LOOP PRINCIPAL
-- ============================
RunService.RenderStepped:Connect(function(delta)
    -- Atualiza valores do menu
    animalEnabled = UI.GetValue("animal_general") or false
    legendaryEnabled = UI.GetValue("animal_legendary") or false
    oreMasterEnabled = UI.GetValue("ore_master") or false
    for _, ore in ipairs(ORE_TYPES) do
        oreEnabled[ore] = UI.GetValue("ore_" .. ore) or false
    end

    frameCounter = frameCounter + 1

    -- Verifica se algum ESP está ativo
    local anyAnimal = animalEnabled or legendaryEnabled
    local anyOre = false
    if oreMasterEnabled then
        for _, state in pairs(oreEnabled) do
            if state then anyOre = true break end
        end
    end

    -- Scan animais
    if anyAnimal then
        animalScanTimer = animalScanTimer + delta
        if animalScanTimer >= SCAN_INTERVAL then
            animalScanTimer = 0
            scanAnimals()
        end
    end

    -- Scan minérios
    if anyOre then
        oreScanTimer = oreScanTimer + delta
        if oreScanTimer >= SCAN_INTERVAL then
            oreScanTimer = 0
            scanOres()
        end
    end

    -- Atualiza renderização
    if frameCounter % UPDATE_EVERY_N_FRAMES == 0 then
        local cameraPos = Camera.CFrame.Position
        local viewport = Camera.ViewportSize

        if anyAnimal or anyOre then
            updateAllESP(cameraPos, viewport)
        else
            -- Esconde todos se nada estiver ativo
            for _, data in pairs(animalEspObjects) do
                if data.box then data.box.Visible = false end
                if data.text then data.text.Visible = false end
                if data.distLabel then data.distLabel.Visible = false end
            end
            for _, data in pairs(oreEspObjects) do
                if data.box then data.box.Visible = false end
                if data.text then data.text.Visible = false end
                if data.distLabel then data.distLabel.Visible = false end
            end
        end
    end
end)

-- ============================
-- INICIALIZAÇÃO
-- ============================
scanAnimals()
scanOres()
notify("Animal + Ore ESP loaded | Open menu", 3)
