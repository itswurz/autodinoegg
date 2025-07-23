-- Auto Dino Craft Script for Delta Executor
-- Version 2.1 - With URL Placeholder

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Main execution function
local function main()
    repeat task.wait() until game:IsLoaded()

    local LocalPlayer = Players.LocalPlayer
    local Backpack = LocalPlayer:WaitForChild("Backpack")
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local CraftingService = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService")

    -- Retrieve stored craft choice from teleport data
    local teleportData = TeleportService:GetTeleportData() or {}
    local lastCraftChoice = teleportData.LastCraft or ""
    
    local function setupDinoEvent()
        local DinoEvent = workspace:FindFirstChild("DinoEvent") or ReplicatedStorage.Modules:WaitForChild("UpdateService"):WaitForChild("DinoEvent")
        if DinoEvent and DinoEvent:IsDescendantOf(ReplicatedStorage) then
            DinoEvent.Parent = workspace
        end
        return workspace:WaitForChild("DinoEvent"):WaitForChild("DinoCraftingTable")
    end

    local function inputTool(index, matchType, matchValue)
        for _, tool in ipairs(Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute(matchType) == matchValue then
                for _, t in ipairs(Character:GetChildren()) do
                    if t:IsA("Tool") then
                        t.Parent = Backpack
                    end
                end
                tool.Parent = Character
                task.wait(0.1)
                local uuid = tool:GetAttribute("c")
                if uuid then
                    CraftingService:FireServer("InputItem", DinoTable, "DinoEventWorkbench", index, {
                        ItemType = (matchType == "f") and "Holdable" or "PetEgg",
                        ItemData = { UUID = uuid }
                    })
                end
                tool.Parent = Backpack
                break
            end
        end
    end

    local function craft(typeToCraft)
        TeleportService:SetTeleportData({LastCraft = typeToCraft})

        DinoTable = setupDinoEvent()
        if typeToCraft == "Dino" then
            CraftingService:FireServer("SetRecipe", DinoTable, "DinoEventWorkbench", "Dinosaur Egg")
            task.wait(0.1)
            inputTool(1, "h", "Common Egg")
            inputTool(2, "f", "Bone Blossom")
        elseif typeToCraft == "Primal" then
            CraftingService:FireServer("SetRecipe", DinoTable, "DinoEventWorkbench", "Primal Egg")
            task.wait(0.1)
            inputTool(1, "h", "Dinosaur Egg")
            inputTool(2, "f", "Bone Blossom")
        elseif typeToCraft == "Ancient" then
            CraftingService:FireServer("SetRecipe", DinoTable, "DinoEventWorkbench", "Ancient Seed Pack")
            task.wait(0.1)
            inputTool(1, "h", "Dinosaur Egg")
        end
        task.wait(0.1)
        CraftingService:FireServer("Craft", DinoTable, "DinoEventWorkbench")
        task.wait(0.2)
        TeleportService:Teleport(game.PlaceId)
    end

    -- Auto-execute if we have a stored craft choice
    if lastCraftChoice ~= "" then
        craft(lastCraftChoice)
    else
        -- Show GUI if no auto-craft
        local CoreGui = game:GetService("CoreGui")
        local Gui = Instance.new("ScreenGui", CoreGui)
        Gui.Name = "AutoCraftUI"
        Gui.ResetOnSpawn = false

        local Frame = Instance.new("Frame", Gui)
        Frame.Size = UDim2.new(0, 300, 0, 250)
        Frame.Position = UDim2.new(0.5, -150, 0.5, -125)
        Frame.BackgroundColor3 = Color3.fromRGB(24, 25, 26)
        Frame.BorderSizePixel = 0

        local UICorner = Instance.new("UICorner", Frame)
        UICorner.CornerRadius = UDim.new(0, 10)

        local UIListLayout = Instance.new("UIListLayout", Frame)
        UIListLayout.Padding = UDim.new(0, 10)
        UIListLayout.FillDirection = Enum.FillDirection.Vertical
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        local Title = Instance.new("TextLabel", Frame)
        Title.Size = UDim2.new(1, -20, 0, 30)
        Title.Text = "Select Craft Option"
        Title.TextColor3 = Color3.fromRGB(220, 220, 220)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.TextScaled = true

        local function createButton(label, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -40, 0, 40)
            btn.Text = label
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(48, 49, 52)
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            btn.AutoButtonColor = true
            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(callback)
            btn.Parent = Frame
        end

        createButton("🐣 Dino Egg", function() craft("Dino") end)
        createButton("🔥 Primal Egg", function() craft("Primal") end)
        createButton("🌿 Ancient Seed Pack", function() craft("Ancient") end)
    end
end

-- IMPORTANT: Replace the URL below with your actual hosted script URL
-- Replace YOUR_URL_HERE with the direct raw link to your hosted script
-- Example valid URL: "https://raw.githubusercontent.com/yourusername/yourrepo/main/AutoDinoCraft.lua"
queue_on_teleport([[
    loadstring(game:HttpGet(https://raw.githubusercontent.com/itswurz/autodinoegg/refs/heads/main/auto.lua))()
]])

-- Initial execution
if not game:IsLoaded() then
    game.Loaded:Wait()
end
main()
