--[[ 
    WERBERT HUB V52 - VISUAL COMPLETO (STATUS + TIMER)
    Criador: @werbert_ofc
    
    FUNCIONALIDADES:
    1. Reset Automático ao voltar pro Lobby (MapParts).
    2. Mostra contagem de 15s na tela ao iniciar a partida.
    3. Mostra "OBSERVANDO" quando a proteção de lag acaba.
    4. Lógica Híbrida: Pega arma na mão instantaneamente, falta de item após 15s.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==============================================================================
-- CONFIGURAÇÕES
-- ==============================================================================
local settings = {
    esp = false,
    gunEsp = false,
    xray = false,
    speed = false,
    fullbright = false
}

local roleMemory = {} 
local passiveScannerActive = false 
local isInLobby = true
local monitoredFolders = {}

if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- INTERFACE (UI COM STATUS)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V52_Status"
if pcall(function() ScreenGui.Parent = CoreGui end) then
    getgenv().WerbertUI = ScreenGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    getgenv().WerbertUI = ScreenGui
end

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 360)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "HUB V52 (STATUS)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = MainFrame

-- LABEL DE STATUS (IMPORTANTE)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS: LOBBY (RESETADO)"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Ciano
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MiniBtn = Instance.new("TextButton")
MiniBtn.Text = "-"
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 5)
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.Parent = MainFrame

local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 50, 0, 50)
FloatIcon.Position = UDim2.new(0.1, 0, 0.2, 0)
FloatIcon.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FloatIcon.Text = "V52"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 18
FloatIcon.Visible = false
FloatIcon.Parent = ScreenGui
Instance.new("UICorner", FloatIcon).CornerRadius = UDim.new(0.5, 0)

MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatIcon.Visible = true end)
FloatIcon.MouseButton1Click:Connect(function() FloatIcon.Visible = false; MainFrame.Visible = true end)

makeDraggable(MainFrame)
makeDraggable(FloatIcon)

local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = UDim2.new(0.075, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        if enabled then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        end
    end)
end

-- ==============================================================================
-- 1. SISTEMA DE TIMER E STATUS (LOBBY/PARTIDA)
-- ==============================================================================

local function checkLocation()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    local lobby = Workspace:FindFirstChild("Lobby")
    local mapParts = lobby and lobby:FindFirstChild("MapParts")
    
    if mapParts then
        local referencePart = mapParts:FindFirstChildWhichIsA("BasePart", true)
        if referencePart then
            local distance = (root.Position - referencePart.Position).Magnitude
            
            -- ====================
            -- ESTADO: LOBBY
            -- ====================
            if distance < 300 then 
                if not isInLobby then
                    isInLobby = true
                    passiveScannerActive = false
                    roleMemory = {} 
                    
                    -- MENSAGEM NO MENU
                    StatusLabel.Text = "STATUS: LOBBY (RESETADO)"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Ciano
                    
                    game.StarterGui:SetCore("SendNotification", {Title="Hub V52", Text="Lobby: Status Resetado", Duration=3})
                end
                
            -- ====================
            -- ESTADO: PARTIDA
            -- ====================
            else
                if isInLobby then
                    isInLobby = false
                    
                    roleMemory = {} -- Limpa no inicio
                    passiveScannerActive = false 
                    
                    -- CONTAGEM REGRESSIVA VISUAL (15s)
                    task.spawn(function()
                        for i = 15, 1, -1 do
                            if isInLobby then return end
                            StatusLabel.Text = "CARREGANDO: " .. i .. "s"
                            StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0) -- Laranja
                            task.wait(1)
                        end
                        
                        -- FIM DO TIMER
                        if not isInLobby then
                            passiveScannerActive = true 
                            
                            -- MENSAGEM NO MENU
                            StatusLabel.Text = "STATUS: OBSERVANDO..."
                            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Verde
                            
                            game.StarterGui:SetCore("SendNotification", {Title="Hub V52", Text="Observação Iniciada!", Duration=3})
                            
                            -- Reanalisa todo mundo
                            local chars = Workspace:FindFirstChild("Characters")
                            if chars then
                                for _, c in pairs(chars:GetChildren()) do
                                    analyzePlayer(c)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        checkLocation()
        task.wait(0.5)
    end
end)

-- ==============================================================================
-- 2. LÓGICA DE DETECÇÃO (MEMÓRIA BLINDADA)
-- ==============================================================================

function analyzePlayer(folder)
    local playerName = folder.Name
    if playerName == LocalPlayer.Name then return end
    
    -- Memória Blindada
    if roleMemory[playerName] == "Murderer" then return end

    -- [A] DETECÇÃO IMEDIATA (VISUAL)
    -- Funciona SEMPRE, mesmo durante o carregamento.
    if folder:FindFirstChild("WorldModel") then
        task.delay(0.2, function() 
            if not folder:FindFirstChild("WorldModel") then return end
            
            -- Arma na mão + WornGun nas costas = Faca (ASSASSINO)
            if folder:FindFirstChild("WornGun") then
                roleMemory[playerName] = "Murderer"
                return
            end
            
            -- Arma na mão + WornKnife nas costas = Arma (XERIFE)
            if folder:FindFirstChild("WornKnife") then
                if roleMemory[playerName] ~= "Murderer" then
                    roleMemory[playerName] = "Sheriff"
                end
                return
            end
            
            -- Arma na mão + Nada nas costas = Assassino (Chute Seguro)
            if not folder:FindFirstChild("WornGun") and not folder:FindFirstChild("WornKnife") then
                 if roleMemory[playerName] ~= "Sheriff" then
                     roleMemory[playerName] = "Murderer"
                 end
            end
        end)
    end

    -- [B] DETECÇÃO PASSIVA (SÓ APÓS OS 15s)
    if passiveScannerActive then
        -- Falta WornKnife = Assassino
        if not folder:FindFirstChild("WornKnife") then
            roleMemory[playerName] = "Murderer"
        end
        
        -- Falta WornGun = Xerife
        if not folder:FindFirstChild("WornGun") then
            if roleMemory[playerName] ~= "Murderer" then
                roleMemory[playerName] = "Sheriff"
            end
        end
    end
end

local function monitorCharacterFolder(folder)
    if monitoredFolders[folder] then return end
    monitoredFolders[folder] = true

    folder.ChildRemoved:Connect(function() analyzePlayer(folder) end)
    folder.ChildAdded:Connect(function() analyzePlayer(folder) end)
    
    task.spawn(function()
        while folder.Parent do
            analyzePlayer(folder)
            task.wait(0.2)
        end
    end)
end

local function startMonitoring()
    local charactersFolder = Workspace:FindFirstChild("Characters")
    if charactersFolder then
        for _, folder in pairs(charactersFolder:GetChildren()) do
            monitorCharacterFolder(folder)
        end
        charactersFolder.ChildAdded:Connect(monitorCharacterFolder)
    end
end

-- Loop de Varredura
task.spawn(function()
    while true do
        if settings.esp then
            local charactersFolder = Workspace:FindFirstChild("Characters")
            if charactersFolder then
                for _, folder in pairs(charactersFolder:GetChildren()) do
                    if folder.Name ~= LocalPlayer.Name then
                        analyzePlayer(folder)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

startMonitoring()
Workspace.ChildAdded:Connect(function(c) if c.Name == "Characters" then task.wait(0.5); startMonitoring() end end)


-- ==============================================================================
-- VISUAL (ESP)
-- ==============================================================================

RunService.RenderStepped:Connect(function()
    if not settings.esp then 
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("WerbertHighlight") then
                plr.Character.WerbertHighlight:Destroy()
                if plr.Character.Head:FindFirstChild("WerbertTag") then plr.Character.Head.WerbertTag:Destroy() end
            end
        end
        return 
    end

    local charactersFolder = Workspace:FindFirstChild("Characters")

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = nil
            if charactersFolder then char = charactersFolder:FindFirstChild(plr.Name) end
            if not char then char = plr.Character end

            if char and char:FindFirstChild("Head") then
                local role = roleMemory[plr.Name]
                
                local color = Color3.fromRGB(255, 255, 255)
                local txt = "Inocente"

                if role == "Murderer" then
                    color = Color3.fromRGB(255, 0, 0)
                    txt = "ASSASSINO"
                elseif role == "Sheriff" then
                    color = Color3.fromRGB(0, 100, 255)
                    txt = "XERIFE"
                end

                local hl = char:FindFirstChild("WerbertHighlight")
                if not hl then 
                    hl = Instance.new("Highlight", char) 
                    hl.Name = "WerbertHighlight"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                hl.FillColor = color
                hl.OutlineColor = color
                
                local bg = char.Head:FindFirstChild("WerbertTag")
                if not bg then
                    bg = Instance.new("BillboardGui", char.Head)
                    bg.Name = "WerbertTag"
                    bg.Size = UDim2.new(0,100,0,50)
                    bg.StudsOffset = Vector3.new(0,2,0)
                    bg.AlwaysOnTop = true
                    local lbl = Instance.new("TextLabel", bg)
                    lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 14
                    lbl.TextStrokeTransparency = 0
                end
                bg.TextLabel.Text = plr.Name.."\n["..txt.."]"
                bg.TextLabel.TextColor3 = color
            end
        end
    end
end)

-- ESP ARMA
task.spawn(function()
    while true do
        if settings.gunEsp then
            local targetFolder = nil
            for _, c in pairs(Workspace:GetChildren()) do
                if c.Name == "Entities" and not c:FindFirstChild("MapModel") then
                    targetFolder = c
                    break
                end
            end

            if targetFolder then
                local gun = targetFolder:FindFirstChild("DroppedGun")
                if gun then
                    if not gun:FindFirstChild("WerbertGunESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "WerbertGunESP"
                        hl.FillColor = Color3.fromRGB(0, 100, 255)
                        hl.OutlineColor = Color3.fromRGB(0, 100, 255)
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Adornee = gun
                        hl.Parent = gun
                        
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "WerbertGunTag"
                        bg.Size = UDim2.new(0, 80, 0, 40)
                        bg.StudsOffset = Vector3.new(0, 1, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = gun
                        
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency = 1
                        txt.Text = "ARMA"
                        txt.TextColor3 = Color3.fromRGB(0, 200, 255)
                        txt.Font = Enum.Font.GothamBlack
                        txt.TextSize = 12
                        txt.TextStrokeTransparency = 0
                        txt.Parent = bg
                    end
                end
            end
        else
             for _, c in pairs(Workspace:GetChildren()) do
                if c.Name == "Entities" then
                    local gun = c:FindFirstChild("DroppedGun")
                    if gun then
                        if gun:FindFirstChild("WerbertGunESP") then gun.WerbertGunESP:Destroy() end
                        if gun:FindFirstChild("WerbertGunTag") then gun.WerbertGunTag:Destroy() end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- SPEED & FULLBRIGHT
task.spawn(function()
    while true do
        if settings.speed then
            pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 24 end)
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    while true do
        if settings.fullbright then
            pcall(function()
                Lighting.ClockTime = 12
                Lighting.Brightness = 2
                Lighting.GlobalShadows = false
            end)
        end
        task.wait(1)
    end
end)

-- X-RAY
local function toggleXray(state)
    if state then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                if not originalTransparency[part] then originalTransparency[part] = part.Transparency end
                if part.Transparency < 0.5 and not part.Parent:FindFirstChild("Humanoid") then
                    part.Transparency = 0.6
                end
            end
        end
    else
        for part, trans in pairs(originalTransparency) do
            if part and part.Parent then part.Transparency = trans end
        end
        originalTransparency = {}
    end
end

-- BOTÕES
createToggle("ESP PLAYERS (Status+Timer)", 60, function(state) settings.esp = state end)
createToggle("ESP ARMA (Azul)", 105, function(state) settings.gunEsp = state end)
createToggle("X-RAY (Paredes)", 150, function(state) settings.xray = state; toggleXray(state) end)
createToggle("SPEED (Correr +)", 195, function(state) settings.speed = state end)
createToggle("FULLBRIGHT (Luz)", 240, function(state) settings.fullbright = state end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V52", Text="Status Visual Ativo!", Duration=5})
