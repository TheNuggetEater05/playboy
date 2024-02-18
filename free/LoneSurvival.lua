local Playboy = {
    Drawings = {},
    Connections = {},
    Players = {
        LocalPlayer = game:GetService("Players").LocalPlayer,
    },
    LoadedPlayers = {},
    Services = {
        RunService = game:GetService("RunService"),
        Players = game:GetService("Players"),
        Workspace = game:GetService("Workspace"),
    },
    Log = false,
}

Lone = {
    Players = Playboy.Services.Workspace:WaitForChild("Players"),
    OfflinePlayers = Playboy.Services.Workspace:WaitForChild("OfflinePlayers")
}

local CurrentCamera = Playboy.Services.Workspace.CurrentCamera
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint

local Quotes = {
    "It's good to be selfish.",
    "Sex is the driving force on the planet.",
    "Life is too short to be living somebody else's dream.",
    "In my wildest dreams, I could not have imagined a sweeter life.",
    "If you let society and your peers define who you are, you're the less for it.",
}

local ranQuote = Quotes[math.random(1,5)]

local EasyUtils = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheNuggetEater05/EasyUtils/main/EU.lua", true))()

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "playboy ~ free release | lone survival",
    SubTitle = ranQuote,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "playboy",
        Content = "It's good to be selfish.",
        Duration = 3
    })
end

-- Visuals
Playboy.Functions = {Visual = {}, Game = {}} do
    function Playboy.Functions.Visual:AddESP(target: Instance, props: table)
        assert(target, 'No target provided')
        local propstbl = props or { isPlayer = true, CustomName = nil }

        local drawings = {}

        -- Setting up the drawings
        local nametag = EasyUtils:newdraw('Text', {Visible = false, Transparency = 0, Size = 16, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), OutlineColor = Color3.fromRGB(0, 0, 0)})
        nametag.Text = propstbl.CustomName or target.Name
        local distance = EasyUtils:newdraw('Text', {Visible = false, Transparency = 0, Size = 16, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), OutlineColor = Color3.fromRGB(0, 0, 0)})
        

        local headpos, vis
        local hrppos
        local connection
        if propstbl.isPlayer then
            connection = Playboy.Services.RunService.RenderStepped:Connect(function()
                headpos, vis = WorldToViewportPoint(CurrentCamera, target:FindFirstChild("Head").Position)
                --hrppos = WorldToViewportPoint(CurrentCamera, target:FindFirstChild())

                nametag.Position = Vector2.new(headpos.X, headpos.Y-15)
                distance.Position = Vector2.new(nametag.Position.X, nametag.Position.Y+nametag.TextBounds.Y)

                if Playboy.Players.LocalPlayer.Character:FindFirstChild("Head") then
                    distance.Text = string.format("[%dm]", math.ceil((Playboy.Players.LocalPlayer.Character:FindFirstChild("Head").Position - target:FindFirstChild("Head").Position).Magnitude))
                end

                if Fluent.Options.PlayerESPGlobal.Value then
                    nametag.Color = Fluent.Options.ESPNametagColor.Value
                    distance.Color = Fluent.Options.ESPDistanceColor.Value
                    if vis then
                        if Fluent.Options.PlayerESPNametag.Value then
                            nametag.Visible = true; nametag.Transparency = 1;
                        else
                            nametag.Visible = false; nametag.Transparency = 0;
                        end
                        if Fluent.Options.PlayerESPDistance.Value then
                            distance.Visible = true; distance.Transparency = 1;
                        else
                            distance.Visible = false; distance.Transparency = 0;
                        end
                    else
                        nametag.Visible = false; nametag.Transparency = 0;
                        distance.Visible = false; distance.Transparency = 0;
                    end
                else
                    nametag.Visible = false; nametag.Transparency = 0
                    distance.Visible = false; distance.Transparency = 0
                end
            end)
        else
            -- If it's not a player
        end

        drawings["Nametag"] = nametag or nil
        drawings["Distance"] = distance or nil
        return drawings, connection
    end


    function Playboy.Functions.Game:GetPlayers(tbl: table)
        for index, player in pairs(Lone.Players:GetChildren()) do
            if player:FindFirstChild("Head") and player.Name ~= Playboy.Players.LocalPlayer.Name then
                if Playboy.Log then warn("[pb]:", tostring(index), player.Name) end
                local drawings, connection = Playboy.Functions.Visual:AddESP(player)
                tbl[player.Name] = {['Player'] = player, ['Connection'] = connection, ['Drawings'] = drawings}
            end
        end
    end

    function Playboy.Functions.Game:RefreshPlayers(tbl: table)
        Lone.Players.DescendantAdded:Connect(function(descendant) -- Player is the parent of the Head
            if descendant.ClassName == "MeshPart" and descendant.Name == "Head" and descendant.Parent.Name ~= "Head Armor" and descendant.Parent.Name ~= "Mask" and descendant.Parent.Name ~= Playboy.Players.LocalPlayer.Name then
                if Playboy.Log then warn("[pb]: Added", descendant.Parent.Name) end
                local drawings, connection = Playboy.Functions.Visual:AddESP(descendant.Parent)
                tbl[descendant.Parent.Name] = {['Player'] = descendant.Parent, ['Connection'] = connection, ['Drawings'] = drawings}
            end
        end)
        Lone.Players.DescendantRemoving:Connect(function(descendant)
            if descendant.ClassName == "MeshPart" and descendant.Name == "Head" and descendant.Parent.Name ~= "Head Armor" and descendant.Parent.Name ~= "Mask" then
                if Playboy.Log then warn("[pb]: Removed", descendant.Parent.Name) end
                for index, drawing in pairs(tbl[descendant.Parent.Name]['Drawings']) do
                    drawing:Destroy()
                    if Playboy.Log then warn("[pb]: Destroyed Drawing") end
                end
                tbl[descendant.Parent.Name]['Connection']:Disconnect()
                if Playboy.Log then warn("[pb]: Disconnected Event") end
                tbl[descendant.Parent.Name] = nil
            end
        end)
    end
end

Playboy.Functions.Game:GetPlayers(Playboy.LoadedPlayers)
Playboy.Functions.Game:RefreshPlayers(Playboy.LoadedPlayers)

do
    Tabs.Visuals:AddToggle("PlayerESPGlobal", {Title = "Toggle ESP", Default = false})
    Tabs.Visuals:AddToggle("PlayerESPNametag", {Title = "Show Nametags", Default = false})
    Tabs.Visuals:AddToggle("PlayerESPDistance", {Title = "Show Distance", Default = false})

    Tabs.Visuals:AddColorpicker("ESPNametagColor", {Title = "Nametag Color", Default = Color3.fromRGB(255, 255, 255)})
    Tabs.Visuals:AddColorpicker("ESPDistanceColor", {Title = "Distance Color", Default = Color3.fromRGB(255, 255, 255)})
end


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("playboy")
SaveManager:SetFolder("playboy/lonesurvival")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "playboy",
    Content = "Finished loading.",
    Duration = 5
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
