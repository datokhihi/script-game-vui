local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local following = nil
local followConnection = nil
local isMinimized = false
local currentTab = "players"
local lockPosition = "behind"
local FOLLOW_DISTANCE = 4
local nametagEnabled = true

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FollowGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local nametagFolder = Instance.new("Folder")
nametagFolder.Name = "Nametags"
nametagFolder.Parent = screenGui

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(0, 214, 0, 354)
shadow.Position = UDim2.new(0, 13, 0.5, -177)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.55
shadow.BorderSizePixel = 0
shadow.ZIndex = 0
shadow.Parent = screenGui
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 12)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 210, 0, 350)
mainFrame.Position = UDim2.new(0, 20, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 100, 220)
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0.5, 0)
headerFix.Position = UDim2.new(0, 0, 0.5, 0)
headerFix.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 3, 0, 18)
accent.Position = UDim2.new(0, 10, 0.5, -9)
accent.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
accent.BorderSizePixel = 0
accent.ZIndex = 3
accent.Parent = header
Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Follow Player"
title.TextColor3 = Color3.fromRGB(220, 225, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = header

local function makeWinBtn(posX, bg, fg, txt)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 20, 0, 20)
    b.Position = UDim2.new(1, posX, 0.5, -10)
    b.BackgroundColor3 = bg
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = fg
    b.TextSize = txt == "×" and 16 or 13
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 4
    b.Parent = header
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    return b
end

local btnMin   = makeWinBtn(-88, Color3.fromRGB(255,189,46),  Color3.fromRGB(100,70,0),   "–")
local btnMax   = makeWinBtn(-62, Color3.fromRGB(40,200,120),  Color3.fromRGB(0,70,30),    "□")
local btnClose = makeWinBtn(-36, Color3.fromRGB(255,70,70),   Color3.fromRGB(120,0,0),    "×")

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -36)
body.Position = UDim2.new(0, 0, 0, 36)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.Parent = mainFrame

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 28)
tabBar.Position = UDim2.new(0, 8, 0, 8)
tabBar.BackgroundColor3 = Color3.fromRGB(18, 20, 35)
tabBar.BorderSizePixel = 0
tabBar.Parent = body
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 6)

local function makeTab(txt, posX)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0.5, -4, 1, -6)
    t.Position = UDim2.new(posX, posX == 0 and 3 or -3, 0, 3)
    t.BackgroundColor3 = Color3.fromRGB(30, 35, 60)
    t.BorderSizePixel = 0
    t.Text = txt
    t.TextColor3 = Color3.fromRGB(180, 185, 220)
    t.TextSize = 11
    t.Font = Enum.Font.GothamBold
    t.Parent = tabBar
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
    return t
end

local tabPlayers  = makeTab("Players", 0)
local tabSettings = makeTab("Settings", 0.5)

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -16, 0, 26)
statusBar.Position = UDim2.new(0, 8, 0, 44)
statusBar.BackgroundColor3 = Color3.fromRGB(18, 20, 35)
statusBar.BorderSizePixel = 0
statusBar.Parent = body
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 6)

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 7, 0, 7)
statusDot.Position = UDim2.new(0, 10, 0.5, -3)
statusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
statusDot.BorderSizePixel = 0
statusDot.Parent = statusBar
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -26, 1, 0)
statusLabel.Position = UDim2.new(0, 22, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Not following anyone"
statusLabel.TextColor3 = Color3.fromRGB(100, 105, 130)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusBar

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -16, 0, 1)
divider.Position = UDim2.new(0, 8, 0, 76)
divider.BackgroundColor3 = Color3.fromRGB(28, 32, 55)
divider.BorderSizePixel = 0
divider.Parent = body

local playersPanel = Instance.new("Frame")
playersPanel.Size = UDim2.new(1, 0, 1, -82)
playersPanel.Position = UDim2.new(0, 0, 0, 82)
playersPanel.BackgroundTransparency = 1
playersPanel.BorderSizePixel = 0
playersPanel.Parent = body

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -12, 1, -4)
scrollFrame.Position = UDim2.new(0, 6, 0, 4)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 2
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 100, 220)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = playersPanel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 3)
listLayout.Parent = scrollFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 3)
listPad.PaddingBottom = UDim.new(0, 3)
listPad.Parent = scrollFrame

local settingsPanel = Instance.new("Frame")
settingsPanel.Size = UDim2.new(1, 0, 1, -82)
settingsPanel.Position = UDim2.new(0, 0, 0, 82)
settingsPanel.BackgroundTransparency = 1
settingsPanel.BorderSizePixel = 0
settingsPanel.Visible = false
settingsPanel.Parent = body

local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Size = UDim2.new(1, -12, 1, -4)
settingsScroll.Position = UDim2.new(0, 6, 0, 4)
settingsScroll.BackgroundTransparency = 1
settingsScroll.BorderSizePixel = 0
settingsScroll.ScrollBarThickness = 2
settingsScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 100, 220)
settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
settingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsScroll.Parent = settingsPanel

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.Padding = UDim.new(0, 6)
settingsLayout.Parent = settingsScroll

local settingsPad = Instance.new("UIPadding")
settingsPad.PaddingTop = UDim.new(0, 6)
settingsPad.PaddingBottom = UDim.new(0, 6)
settingsPad.Parent = settingsScroll

local function makeSectionLabel(txt, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = txt
    lbl.TextColor3 = Color3.fromRGB(60, 80, 160)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = settingsScroll
    return lbl
end

local function makeSettingRow(labelTxt, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = Color3.fromRGB(18, 20, 35)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = settingsScroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelTxt
    lbl.TextColor3 = Color3.fromRGB(190, 195, 225)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    return row
end

makeSectionLabel("LOCK POSITION", 1)

local posOptions = {"Behind", "Front", "Under Feet", "Above Head"}
local posValues  = {"behind", "front", "under", "above"}
local posButtons = {}

for i, opt in ipairs(posOptions) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = i == 1 and Color3.fromRGB(25, 40, 100) or Color3.fromRGB(18, 20, 35)
    row.BorderSizePixel = 0
    row.LayoutOrder = i + 1
    row.Parent = settingsScroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = opt
    lbl.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 195, 225)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    posButtons[i] = {row = row, lbl = lbl}

    row.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            lockPosition = posValues[i]
            for j, pb in ipairs(posButtons) do
                pb.row.BackgroundColor3 = j == i and Color3.fromRGB(25, 40, 100) or Color3.fromRGB(18, 20, 35)
                pb.lbl.TextColor3 = j == i and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 195, 225)
            end
        end
    end)
end

makeSectionLabel("NAMETAG", 10)

local nametagRow = Instance.new("Frame")
nametagRow.Size = UDim2.new(1, 0, 0, 32)
nametagRow.BackgroundColor3 = Color3.fromRGB(18, 20, 35)
nametagRow.BorderSizePixel = 0
nametagRow.LayoutOrder = 11
nametagRow.Parent = settingsScroll
Instance.new("UICorner", nametagRow).CornerRadius = UDim.new(0, 6)

local nametagRowLabel = Instance.new("TextLabel")
nametagRowLabel.Size = UDim2.new(1, -60, 1, 0)
nametagRowLabel.Position = UDim2.new(0, 10, 0, 0)
nametagRowLabel.BackgroundTransparency = 1
nametagRowLabel.Text = "Show Nametag"
nametagRowLabel.TextColor3 = Color3.fromRGB(190, 195, 225)
nametagRowLabel.TextSize = 12
nametagRowLabel.Font = Enum.Font.Gotham
nametagRowLabel.TextXAlignment = Enum.TextXAlignment.Left
nametagRowLabel.Parent = nametagRow

local ntToggle = Instance.new("TextButton")
ntToggle.Size = UDim2.new(0, 38, 0, 20)
ntToggle.Position = UDim2.new(1, -46, 0.5, -10)
ntToggle.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
ntToggle.BorderSizePixel = 0
ntToggle.Text = ""
ntToggle.Parent = nametagRow
Instance.new("UICorner", ntToggle).CornerRadius = UDim.new(1, 0)

local ntKnob = Instance.new("Frame")
ntKnob.Size = UDim2.new(0, 14, 0, 14)
ntKnob.Position = UDim2.new(1, -17, 0.5, -7)
ntKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ntKnob.BorderSizePixel = 0
ntKnob.Parent = ntToggle
Instance.new("UICorner", ntKnob).CornerRadius = UDim.new(1, 0)

local Camera = workspace.CurrentCamera
local nametags = {}

local function removeNametag(player)
    if nametags[player] then
        nametags[player]:Destroy()
        nametags[player] = nil
    end
end

local function createNametag(player)
    removeNametag(player)
    if not nametagEnabled then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = head
    billboard.Parent = nametagFolder

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    bg.BackgroundTransparency = 0.3
    bg.BorderSizePixel = 0
    bg.Parent = billboard
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -8, 1, 0)
    nameLabel.Position = UDim2.new(0, 4, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(220, 225, 255)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = bg

    nametags[player] = billboard
end

local function refreshAllNametags()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if nametagEnabled then
                createNametag(player)
            else
                removeNametag(player)
            end
        end
    end
end

local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    following = nil
    statusLabel.Text = "Not following anyone"
    statusLabel.TextColor3 = Color3.fromRGB(100, 105, 130)
    statusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
end

local function getOffset()
    if lockPosition == "behind" then
        return CFrame.new(0, 0, FOLLOW_DISTANCE)
    end
    if lockPosition == "front" then
        return CFrame.new(0, 0, -FOLLOW_DISTANCE)
    end
    if lockPosition == "under" then
        return CFrame.new(0, -FOLLOW_DISTANCE - 2, 0) * CFrame.Angles(math.rad(90), 0, 0)
    end
    if lockPosition == "above" then
        return CFrame.new(0, FOLLOW_DISTANCE + 2, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    end
    return CFrame.new(0, 0, FOLLOW_DISTANCE)
end

local function startFollowing(targetPlayer)
    stopFollowing()
    following = targetPlayer
    statusLabel.Text = "Following: " .. targetPlayer.Name
    statusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
    statusDot.BackgroundColor3 = Color3.fromRGB(80, 220, 120)

    followConnection = RunService.Heartbeat:Connect(function()
        local myChar = LocalPlayer.Character
        local targetChar = targetPlayer.Character
        if not myChar or not targetChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not myRoot or not targetRoot then return end
        myRoot.CFrame = targetRoot.CFrame * getOffset()
    end)
end

local function createPlayerButton(player)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(18, 20, 35)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Name = player.Name
    btn.Parent = scrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local icon = Instance.new("Frame")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 8, 0.5, -10)
    icon.BackgroundColor3 = Color3.fromRGB(40, 50, 100)
    icon.BorderSizePixel = 0
    icon.Parent = btn
    Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = string.upper(string.sub(player.Name, 1, 1))
    iconLabel.TextColor3 = Color3.fromRGB(140, 170, 255)
    iconLabel.TextSize = 10
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = icon

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -38, 1, 0)
    nameLabel.Position = UDim2.new(0, 34, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(190, 195, 225)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn

    btn.MouseEnter:Connect(function()
        if following ~= player then
            btn.BackgroundColor3 = Color3.fromRGB(26, 30, 52)
        end
    end)
    btn.MouseLeave:Connect(function()
        if following ~= player then
            btn.BackgroundColor3 = Color3.fromRGB(18, 20, 35)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if following == player then
            btn.BackgroundColor3 = Color3.fromRGB(18, 20, 35)
            nameLabel.TextColor3 = Color3.fromRGB(190, 195, 225)
            icon.BackgroundColor3 = Color3.fromRGB(40, 50, 100)
            iconLabel.TextColor3 = Color3.fromRGB(140, 170, 255)
            stopFollowing()
        else
            for _, b in ipairs(scrollFrame:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(18, 20, 35)
                    local nl = b:FindFirstChildOfClass("TextLabel")
                    if nl then nl.TextColor3 = Color3.fromRGB(190, 195, 225) end
                    local ic = b:FindFirstChildOfClass("Frame")
                    if ic then
                        ic.BackgroundColor3 = Color3.fromRGB(40, 50, 100)
                        local il = ic:FindFirstChildOfClass("TextLabel")
                        if il then il.TextColor3 = Color3.fromRGB(140, 170, 255) end
                    end
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(25, 40, 100)
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            icon.BackgroundColor3 = Color3.fromRGB(60, 100, 220)
            iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            startFollowing(player)
        end
    end)

    return btn
end

local function refreshPlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createPlayerButton(player)
        end
    end
end

local function setTab(tab)
    currentTab = tab
    if tab == "players" then
        playersPanel.Visible = true
        settingsPanel.Visible = false
        tabPlayers.BackgroundColor3 = Color3.fromRGB(40, 50, 100)
        tabPlayers.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabSettings.BackgroundColor3 = Color3.fromRGB(30, 35, 60)
        tabSettings.TextColor3 = Color3.fromRGB(140, 145, 180)
    else
        playersPanel.Visible = false
        settingsPanel.Visible = true
        tabSettings.BackgroundColor3 = Color3.fromRGB(40, 50, 100)
        tabSettings.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabPlayers.BackgroundColor3 = Color3.fromRGB(30, 35, 60)
        tabPlayers.TextColor3 = Color3.fromRGB(140, 145, 180)
    end
end

setTab("players")

tabPlayers.MouseButton1Click:Connect(function() setTab("players") end)
tabSettings.MouseButton1Click:Connect(function() setTab("settings") end)

ntToggle.MouseButton1Click:Connect(function()
    nametagEnabled = not nametagEnabled
    if nametagEnabled then
        ntToggle.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
        ntKnob.Position = UDim2.new(1, -17, 0.5, -7)
    else
        ntToggle.BackgroundColor3 = Color3.fromRGB(40, 42, 65)
        ntKnob.Position = UDim2.new(0, 3, 0.5, -7)
    end
    refreshAllNametags()
end)

local originalSize = mainFrame.Size
local originalShadowSize = shadow.Size

btnMin.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        body.Visible = false
        mainFrame.Size = UDim2.new(0, 210, 0, 36)
        shadow.Size = UDim2.new(0, 214, 0, 40)
    else
        body.Visible = true
        mainFrame.Size = originalSize
        shadow.Size = originalShadowSize
    end
end)

btnMax.MouseButton1Click:Connect(function()
    mainFrame.Position = UDim2.new(0.5, -105, 0.5, -175)
    shadow.Position = UDim2.new(0.5, -108, 0.5, -177)
end)

btnClose.MouseButton1Click:Connect(function()
    stopFollowing()
    for _, player in ipairs(Players:GetPlayers()) do
        removeNametag(player)
    end
    screenGui:Destroy()
end)

Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    refreshPlayerList()
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        createNametag(player)
    end)
    createNametag(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if following == player then stopFollowing() end
    removeNametag(player)
    refreshPlayerList()
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            createNametag(player)
        end)
        createNametag(player)
    end
end

refreshPlayerList()
