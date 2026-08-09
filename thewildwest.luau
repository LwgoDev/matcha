--!strict
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Camera = Workspace.CurrentCamera

local Paths = {
    ["Animals"] = Workspace:FindFirstChild("WORKSPACE_Entities.Animals"),
    ["Ores"] = Workspace:FindFirstChild("WORKSPACE_Interactables"):FindFirstChild("Mining"):FindFirstChild("OreDeposits")
}



local Ores = {
    GoldOres = {},
    SilverOres = {}
}



local function DrawText(Position, Text, Font, Outlined, Color, Opacity)
    local Text = Drawing.new("Text")

    Text.Position = Position
    Text.Text = tostring(Text)

    Text.Font = Font
    -- Text.FontSize = fontSize
    Text.Outline = Outlined
    Text.Center = true

    Text.Color = Color
    Text.Transparency = Opacity

    Text.Visible = true
    Text.ZIndex = 0

    return Text
end


task.spawn(function()
    while true do
        for _, Ore in Paths.Ores:FindFirstChild("Gold"):GetChildren() do
            local RockOre = Ore:FindFirstChild("RockOre")
            if not RockOre then continue end

            if Ores.GoldOres[RockOre.Address] then continue end
            local IsBig = false
            Ores.GoldOres[RockOre.Address] = {
                RockOre = RockOre,
                OreRemaining = Ore.DepositInfo.OreRemaining,
                Big = IsBig,
                Text = DrawText(Vector2.new(0, 0), "---", Drawing.Fonts.Minecraft, true, Color3.fromRGB(255, 200, 0), 1),
                AmountText = DrawText(Vector2.new(0, 0), "---", Drawing.Fonts.Minecraft, true, Color3.fromRGB(255, 255, 255), 1)
            }
        end
        for _, Ore in Paths.Ores:FindFirstChild("GoldVein"):GetChildren() do
            local RockOre = Ore:FindFirstChild("RockOre")
            if not RockOre then continue end

            if Ores.GoldOres[RockOre.Address] then continue end
            local IsBig = true
            Ores.GoldOres[RockOre.Address] = {
                RockOre = RockOre,
                OreRemaining = Ore.DepositInfo.OreRemaining,
                Big = IsBig,
                Text = DrawText(Vector2.new(0, 0), "---", Drawing.Fonts.Minecraft, true, Color3.fromRGB(255, 200, 0), 1),
                AmountText = DrawText(Vector2.new(0, 0), "---", Drawing.Fonts.Minecraft, true, Color3.fromRGB(255, 255, 255), 1)
            }
        end

        for _, Ore in Paths.Ores:FindFirstChild("Silver"):GetChildren() do
            local RockOre = Ore:FindFirstChild("RockOre")
            if not RockOre then continue end

            if Ores.SilverOres[RockOre.Address] then continue end
            local IsBig = false
            Ores.SilverOres[RockOre.Address] = {
                RockOre = RockOre,
                OreRemaining = Ore.DepositInfo.OreRemaining,
                Big = IsBig,
                Text = DrawText(Vector2.new(0, 0), "---", Drawing.Fonts.Minecraft, true, Color3.fromRGB(255, 200, 0), 1),
                AmountText = DrawText(Vector2.new(0, 0), "---", Drawing.Fonts.Minecraft, true, Color3.fromRGB(255, 255, 255), 1)
            }
        end
        for _, Ore in Paths.Ores:FindFirstChild("SilverVein"):GetChildren() do
            local RockOre = Ore:FindFirstChild("RockOre")
            if not RockOre then continue end

            if Ores.SilverOres[RockOre.Address] then continue end
            local IsBig = true
            Ores.SilverOres[RockOre.Address] = {
                RockOre = RockOre,
                OreRemaining = Ore.DepositInfo.OreRemaining,
                Big = IsBig,
                Text = DrawText(Vector2.new(0, 0), "---", Drawing.Fonts.Minecraft, true, Color3.fromRGB(255, 200, 0), 1),
                AmountText = DrawText(Vector2.new(0, 0), "---", Drawing.Fonts.Minecraft, true, Color3.fromRGB(255, 255, 255), 1)
            }
        end
        task.wait(3)
    end
end)



RunService.RenderStepped:Connect(function(Delta)
    for Address, Table in Ores.GoldOres do
        if Table.RockOre.Position == nil then continue end
        local ScreenPosition, OnScreen = WorldToScreen(Table.RockOre.Position)
        if not OnScreen then
            Table.Text.Visible = false
            Table.AmountText.Visible = false
            continue
        end

        local CameraPos = Camera.CFrame.Position
        local Distance = (Table.RockOre.Position - CameraPos).Magnitude
        local Text = "GOLD ORE"
        if Table.Big then
            Text = "[BIG] "..Text
        end
        if Table.OreRemaining.Value <= 0 then
            Table.Text.Color = Color3.fromRGB(255, 0, 0)
        else
            Table.Text.Color = Color3.fromRGB(255, 200, 0)
        end
        Table.AmountText.Text = "["..Table.OreRemaining.Value.."]"
        Table.AmountText.Color = Color3.fromRGB(255, 0, 0)
        if Table.Big and Table.OreRemaining.Value == 3 then
            Table.AmountText.Color = Color3.fromRGB(0, 255, 0)
        elseif not Table.Big and Table.OreRemaining.Value == 1 then
            Table.AmountText.Color = Color3.fromRGB(0, 255, 0)
        elseif Table.OreRemaining.Value > 0 then
            Table.AmountText.Color = Color3.fromRGB(255, 255, 255)
        end
        Table.Text.Text = Text.." ["..math.floor(Distance).."m]"

        Table.Text.Position = ScreenPosition
        Table.AmountText.Position = Vector2.new(
            ScreenPosition.X,
            ScreenPosition.Y + 14
        )

        Table.Text.Visible = true
        Table.AmountText.Visible = true
    end

    for Address, Table in Ores.SilverOres do
        if Table.RockOre.Position == nil then continue end
        local ScreenPosition, OnScreen = WorldToScreen(Table.RockOre.Position)
        if not OnScreen then
            Table.Text.Visible = false
            Table.AmountText.Visible = false
            continue
        end
        
        local CameraPos = Camera.CFrame.Position
        local Distance = (Table.RockOre.Position - CameraPos).Magnitude
        local Text = "SILVER ORE"
        if Table.Big then
            Text = "[BIG] "..Text
        end
        if Table.OreRemaining.Value <= 0 then
            Table.Text.Color = Color3.fromRGB(255, 0, 0)
        else
            Table.Text.Color = Color3.fromRGB(255, 255, 255)
        end
        Table.AmountText.Text = "["..Table.OreRemaining.Value.."]"
        Table.AmountText.Color = Color3.fromRGB(255, 0, 0)
        if Table.Big and Table.OreRemaining.Value == 4 then
            Table.AmountText.Color = Color3.fromRGB(0, 255, 0)
        elseif not Table.Big and Table.OreRemaining.Value == 1 then
            Table.AmountText.Color = Color3.fromRGB(0, 255, 0)
        elseif Table.OreRemaining.Value > 0 then
            Table.AmountText.Color = Color3.fromRGB(255, 255, 255)
        end
        Table.Text.Text = Text.." ["..math.floor(Distance).."m]"

        Table.Text.Position = ScreenPosition
        Table.AmountText.Position = Vector2.new(
            ScreenPosition.X,
            ScreenPosition.Y + 14
        )

        Table.Text.Visible = true
        Table.AmountText.Visible = true
    end
end)
