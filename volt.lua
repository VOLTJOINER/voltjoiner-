-- VOLT JOINER - Custom GUI + Key System (with 2-day keys and Discord link GUI)
-- THIS SCRIPT WILL EXECUTE YOUR ORIGINAL AUTO-JOINER WITHOUT MODIFYING IT.

-- === Configuration ===
local CONFIG = {
    WindowName = "VOLT JOINER",
    LoadingTitle = "VOLT",
    LoadingSubtitle = "MADE BY REX",
    ToggleUIKey = Enum.KeyCode.K,
    KeyFileName = "VOLT_key",
    KeyList = {
        ["test"] = math.huge,  -- permanent
        ["key1"] = os.time() + 2 * 24 * 60 * 60,  -- 2 days
        ["key2"] = os.time() + 2 * 24 * 60 * 60   -- 2 days
    },
    SaveKeyByDefault = true
}

-- === ORIGINAL SCRIPT (UNCHANGED) ===
local ORIGINAL_SCRIPT = [[
(function()
    repeat wait() until game:IsLoaded()

    local WebSocketURL = "ws://127.0.0.1:51948"

    local Players = game:GetService("Players")

    -- anti-kick / thanks to fractal hub for bypass
    hookfunction(isfunctionhooked, function(func) if func == tick then return false end end)
    local origTick = getfenv()["tick"]
    getfenv()["tick"] = function() return math.huge end
    hookfunction(tick, function() return math.huge end)

    -- lagger bypass
    for _, player in pairs(Players:GetPlayers()) do
        player.CharacterAdded:Connect(function()
            player:ClearCharacterAppearance()
        end)
        if player.Character then
            player:ClearCharacterAppearance()
        end
    end
    Players.PlayerAdded:Connect(function(player)
        if player.Character then
            player:ClearCharacterAppearance()
        end
        player.CharacterAdded:Connect(function()
            player:ClearCharacterAppearance()
        end)
    end)

    local function prints(str)
        print("[AutoJoiner]: " .. str)
    end

    local function findTargetGui()
        local coreGui = game:GetService("CoreGui")
        for _, gui in ipairs(coreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local mainFrame = gui:FindFirstChild("MainFrame")
                if mainFrame and mainFrame:FindFirstChild("ContentContainer") then
                    local contentContainer = mainFrame.ContentContainer
                    local tabServer = contentContainer:FindFirstChild("TabContent_Server")
                    if tabServer then
                        return tabServer
                    end
                end
            end
        end
        return nil
    end

    local function setJobIDText(targetGui, text)
        if not targetGui then return end
        local inputFrame = targetGui:FindFirstChild("Input")
        local textBox = inputFrame:FindFirstChildOfClass("TextBox")
        textBox.Text = text
        firesignal(textBox.FocusLost)
        prints('Textbox updated: ' .. text .. ' (10m+ bypass)')
        return origTick()
    end

    local function clickJoinButton(targetGui)
        for _, buttonFrame in ipairs(targetGui:GetChildren()) do
            if buttonFrame:IsA("Frame") and buttonFrame.Name == "Button" then
                local textLabel = buttonFrame:FindFirstChildOfClass("TextLabel")
                local imageButton = buttonFrame:FindFirstChildOfClass("ImageButton")
                if textLabel and imageButton and textLabel.Text == "Join Job-ID" then
                    return imageButton
                end
            end
        end
        return nil
    end

    local function bypass10M(jobId)
        task.defer(function()
            local targetGui = findTargetGui()
            local start = setJobIDText(targetGui, jobId)
            local button = clickJoinButton(targetGui)
            getconnections(button.MouseButton1Click)[1]:Fire()
            prints(string.format("Join server clicked (10m+ bypass) | maybe real delay: %.5fs", origTick() - start))
        end)
    end

    local function justJoin(script)
        local func, err = loadstring(script)
        if func then
            local ok, result = pcall(func)
            if not ok then
                prints("Error while executing script: " .. result)
            end
        else
            prints("Some unexcepted error: " .. err)
        end
    end

    local function connect()
        while true do
            prints("Trying to connect to " .. WebSocketURL)
            local success, socket = pcall(WebSocket.connect, WebSocketURL)
            if success and socket then
                prints("Connected to WebSocket")
                local ws = socket
                ws.OnMessage:Connect(function(msg)
                    if not string.find(msg, "TeleportService") then
                        prints("Bypassing 10m server: " .. msg)
                        bypass10M(msg)
                    else
                        prints("Running the script: " .. msg)
                        justJoin(msg)
                    end
                end)
                local closed = false
                ws.OnClose:Connect(function()
                    if not closed then
                        closed = true
                        prints("The websocket closed, trying to reconnect...")
                        wait(1)
                        connect()
                    end
                end)
                break
            else
                prints("Unable to connect to websocket, trying again..")
                wait(1)
            end
        end
    end
    connect()
end)()
]]

-- === Utilities (safe file ops) ===
local function safe_isfile(name)
    if type(isfile) == "function" then
        local ok, res = pcall(isfile, name)
        if ok then return res end
    end
    return false
end
local function safe_readfile(name)
    if type(readfile) == "function" then
        local ok, res = pcall(readfile, name)
        if ok then return res end
    end
    return nil
end
local function safe_writefile(name, data)
    if type(writefile) == "function" then
        local ok, res = pcall(writefile, name, data)
        if ok then return true end
    end
    return false
end

local function prints(s)
    print("[AutoJoiner GUI]: " .. tostring(s))
end

-- === Build GUI ===
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- remove old UI
for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name == "VOLT_JOINER_UI" then
        v:Destroy()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VOLT_JOINER_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 420, 0, 220)
Window.Position = UDim2.new(0.5, -210, 0.4, -110)
Window.BackgroundColor3 = Color3.fromRGB(20,20,20)
Window.BorderSizePixel = 0
Window.Active = true
Window.Draggable = true
Window.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1,0,0,40)
TopBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
TopBar.BorderSizePixel = 0
TopBar.Parent = Window

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "VOLT JOINER https://discord.gg/9fk58uUn"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Size = UDim2.new(1, -20, 0, 18)
SubTitle.Position = UDim2.new(0, 10, 0, 22)
SubTitle.BackgroundTransparency = 1
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Text = "made by rex"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SubTitle.Parent = TopBar

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -20, 0, 18)
Status.Position = UDim2.new(0, 10, 0, 48)
Status.BackgroundTransparency = 1
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Text = "Status: Waiting for key..."
Status.Font = Enum.Font.Gotham
Status.TextSize = 14
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Parent = Window

local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(1, -20, 0, 48)
KeyFrame.Position = UDim2.new(0, 10, 0, 72)
KeyFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = Window

local KeyBox = Instance.new("TextBox")
KeyBox.Name = "KeyBox"
KeyBox.Size = UDim2.new(0.68, -6, 1, -8)
KeyBox.Position = UDim2.new(0, 6, 0, 4)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyBox.ClearTextOnFocus = false
KeyBox.PlaceholderText = "Enter Key"
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(230, 230, 230)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 14
KeyBox.Parent = KeyFrame

local SaveKeyToggle = Instance.new("TextButton")
SaveKeyToggle.Name = "SaveKeyToggle"
SaveKeyToggle.Size = UDim2.new(0.3, -6, 1, -8)
SaveKeyToggle.Position = UDim2.new(0.7, 6, 0, 4)
SaveKeyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SaveKeyToggle.Text = (CONFIG.SaveKeyByDefault and "Save: ON" or "Save: OFF")
SaveKeyToggle.Font = Enum.Font.Gotham
SaveKeyToggle.TextSize = 14
SaveKeyToggle.TextColor3 = Color3.fromRGB(230, 230, 230)
SaveKeyToggle.Parent = KeyFrame

local VerifyButton = Instance.new("TextButton")
VerifyButton.Name = "VerifyButton"
VerifyButton.Size = UDim2.new(1, -20, 0, 34)
VerifyButton.Position = UDim2.new(0, 10, 0, 128)
VerifyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
VerifyButton.Text = "Enter Key"
VerifyButton.Font = Enum.Font.GothamBold
VerifyButton.TextSize = 16
VerifyButton.TextColor3 = Color3.fromRGB(230, 230, 230)
VerifyButton.Parent = Window

local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.Size = UDim2.new(1, -20, 0, 36)
StartButton.Position = UDim2.new(0, 10, 0, 170)
StartButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
StartButton.Text = "Start Auto Joiner"
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 16
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Parent = Window
StartButton.AutoButtonColor = true
StartButton.Active = true

local SmallLabel = Instance.new("TextLabel")
SmallLabel.Name = "SmallLabel"
SmallLabel.Size = UDim2.new(1, -20, 0, 14)
SmallLabel.Position = UDim2.new(0, 10, 0, 212)
SmallLabel.BackgroundTransparency = 1
SmallLabel.Text = "Press '" .. tostring(CONFIG.ToggleUIKey.Name) .. "' to toggle UI"
SmallLabel.Font = Enum.Font.Gotham
SmallLabel.TextSize = 11
SmallLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
SmallLabel.Parent = Window

-- UI toggle
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == CONFIG.ToggleUIKey then
        uiVisible = not uiVisible
        Window.Visible = uiVisible
    end
end)

-- === Key system logic with expiration support ===
local keyAccepted = false

local function keyIsAccepted(k)
    if not k then return false end
    local expiry = CONFIG.KeyList[k]
    if expiry and os.time() <= expiry then
        return true
    end
    return false
end

-- load saved key if present
if safe_isfile(CONFIG.KeyFileName) then
    local data = safe_readfile(CONFIG.KeyFileName)
    if data and data ~= "" then
        KeyBox.Text = data
        if keyIsAccepted(data) then
            keyAccepted = true
            Status.Text = "Status: Key accepted (loaded)"
            VerifyButton.Text = "Key Accepted"
            VerifyButton.BackgroundColor3 = Color3.fromRGB(40,160,40)
        else
            Status.Text = "Status: Saved key invalid or expired"
        end
    end
end

SaveKeyToggle.MouseButton1Click:Connect(function()
    saveEnabled = not saveEnabled
    SaveKeyToggle.Text = (saveEnabled and "Save: ON" or "Save: OFF")
end)

VerifyButton.MouseButton1Click:Connect(function()
    local k = KeyBox.Text or ""
    if k == "" then
        Status.Text = "Status: Enter a key"
        return
    end
    if keyIsAccepted(k) then
        keyAccepted = true
        Status.Text = "Status: Key accepted"
        VerifyButton.Text = "Key Accepted"
        VerifyButton.BackgroundColor3 = Color3.fromRGB(40,160,40)
        if saveEnabled then
            pcall(function() safe_writefile(CONFIG.KeyFileName, k) end)
        end
        local expiry = CONFIG.KeyList[k]
        if expiry and expiry ~= math.huge then
            local secondsLeft = expiry - os.time()
            local hours = math.floor(secondsLeft / 3600)
            local mins = math.floor((secondsLeft % 3600) / 60)
            prints("Key expires in " .. hours .. "h " .. mins .. "m")
        end
        prints("Key accepted: " .. tostring(k))
    else
        keyAccepted = false
        Status.Text = "Status: Invalid or expired key"
        VerifyButton.Text = "Enter Key"
        VerifyButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
        prints("Invalid key attempt: " .. tostring(k))
    end
end)

-- === Start button logic ===
local started = false
StartButton.MouseButton1Click:Connect(function()
    if started then
        Status.Text = "Status: Already started"
        return
    end
    if not keyAccepted then
        Status.Text = "Status: Enter a valid key first"
        return
    end

    started = true
    StartButton.Text = "Auto Joiner: Running"
    StartButton.BackgroundColor3 = Color3.fromRGB(120,120,120)
    StartButton.Active = false
    Status.Text = "Status: Running auto-joiner (original script)"

    local ok, f = pcall(function() return loadstring(ORIGINAL_SCRIPT) end)
    if ok and f then
        local s, err = pcall(function() f() end)
        if not s then
            prints("Original script error: " .. tostring(err))
            Status.Text = "Status: Original script error (check console)"
        else
            prints("Original script executed.")
        end
    else
        prints("Failed to load original script: " .. tostring(f))
        Status.Text = "Status: Failed to load original script"
    end
end)

prints("VOLT JOINER UI loaded. Toggle UI with " .. tostring(CONFIG.ToggleUIKey.Name))  
