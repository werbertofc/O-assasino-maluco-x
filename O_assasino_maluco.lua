--[[ 
    WERBERT HUB V49 - REAVALIAÇÃO COMPLETA (FIXED)
    Criador: @werbert_ofc
    
    CORREÇÕES REAIS:
    1. O sensor de "ChildRemoved" e "ChildAdded" agora fica ATIVO desde o início da partida.
    2. Se o jogador puxar a arma durante a contagem de 15s, O SCRIPT PEGA!
    3. A contagem de 15s serve apenas para não marcar inocentes que ainda estão carregando (Lag).
    4. Detecção focada estritamente em 'WornKnife' e 'WornGun' conforme pedido.
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
local passiveScannerActive = false -- Só controla a verificação de "quem não tem nada"
local isInLobby = true
local connections = {}

if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- INTERFACE
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V49_Fixed"
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
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "HUB V49 (REAVALIADO)"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS: LOBBY"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12
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
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
FloatIcon.Text = "V49"
FloatIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
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
-- 1. ANALISADOR DE PLAYER (CÉREBRO DO SCRIPT)
-- ==============================================================================

local function analyzeTarget(character)
    if not character then return end
    local playerName = character.Name
    if playerName == LocalPlayer.Name then return end
    
    -- Se já sabemos o papel, não muda (Memória Infinita)
    if roleMemory[playerName] == "Murderer" then return end
    
    -- Se estiver no Lobby, limpa e ignora
    if isInLobby then 
        roleMemory[playerName] = nil 
        return 
    end

    local hasKnife = character:FindFirstChild("WornKnife")
    local hasGun = character:FindFirstChild("WornGun")
    
    -- DETECÇÃO 1: ALGUÉM TIROU O ITEM (INSTANTÂNEO)
    -- Isso roda SEMPRE, ignorando o timer de 15s.
    -- Se a faca sumiu, ele É o assassino. Ponto.
    
    if not hasKnife then
        -- Mas calma, só marcamos se o timer de 15s já passou OU se ele tem algo na mão.
        -- Se estiver no começo da partida, pode ser lag de carregamento.
        -- ENTÃO:
        if passiveScannerActive or character:FindFirstChildWhichIsA("Tool") or character:FindFirstChild("WorldModel") then
            roleMemory[playerName] = "Murderer"
            return
        end
    end
    
    if not hasGun then
        if passiveScannerActive or character:FindFirstChildWhichIsA("Tool") or character:FindFirstChild("WorldModel") then
            if roleMemory[playerName] ~= "Murderer" then
                roleMemory[playerName] = "Sheriff"
            end
        end
    end
    
    -- DETECÇÃO 2: ARMA NA MÃO (VISUAL)
    local tool = character:FindFirstChildWhichIsA("Tool") or character:FindFirstChild("WorldModel")
    if tool then
        -- Se tem algo na mão e AINDA TEM WornGun -> É Faca na mão -> ASSASSINO
        if hasGun then
            roleMemory[playerName] = "Murderer"
            return
        end
        -- Se tem algo na mão e AINDA TEM WornKnife -> É Arma na mão -> XERIFE
        if hasKnife then
            if roleMemory[playerName] ~= "Murderer" then
                roleMemory[playerName] = "Sheriff"
            end
        end
    end
end

-- ==============================================================================
-- 2. SENSORES (OLHO VIGILANTE)
-- ==============================================================================

local function attachSensor(character)
    if connections[character] then return end
    
    -- Sensor: Alguém tirou algo da pasta?
    local c1 = character.ChildRemoved:Connect(function(child)
        -- Observa SÓ os itens pedidos
        if child.Name == "WornKnife" or child.Name == "WornGun" then
            analyzeTarget(character)
        end
    end)
    
    -- Sensor: Alguém colocou algo na pasta? (Ex: Equipou arma)
    local c2 = character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") or child.Name == "WorldModel" then
            analyzeTarget(character)
        end
    end)
    
    connections[character] = {c1, c2}
    
    -- Primeira análise rápida
    analyzeTarget(character)
end

local function clearSensors()
    for char, conns in pairs(connections) do
        for _, c in pairs(conns) do c:Disconnect() end
    end
    connections = {}
end

-- ==============================================================================
-- 3. GERENCIADOR DE PARTIDA (TIMER/LOBBY)
-- ==============================================================================

local function checkGameStatus()
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
            -- LOBBY (RESET)
            -- ====================
            if distance < 300 then 
                if not isInLobby then
                    isInLobby = true
                    passiveScannerActive = false
                    roleMemory = {} -- RESET TOTAL
                    StatusLabel.Text = "STATUS: LOBBY (Resetado)"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                    game.StarterGui:SetCore("SendNotification", {Title="Hub V49", Text="Lobby: Memória Limpa!", Duration=3})
                end
                
            -- ====================
            -- PARTIDA (AÇÃO)
            -- ====================
            else
                if isInLobby then
                    isInLobby = false
                    
                    -- Limpa no start para garantir
                    roleMemory = {} 
                    passiveScannerActive = false
                    
                    -- ATIVAÇÃO IMEDIATA DOS SENSORES (Mas com lógica de segurança)
                    local chars = Workspace:FindFirstChild("Characters")
                    if chars then
                        for _, c in pairs(chars:GetChildren()) do
                            attachSensor(c)
                        end
                    end
                    
                    -- Contagem 15s para liberar o "Scanner Passivo"
                    task.spawn(function()
                        for i = 15, 1, -1 do
                            if isInLobby then return end
                            StatusLabel.Text = "CALIBRANDO: " .. i .. "s"
                            StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                            task.wait(1)
                        end
                        
                        -- FIM DO TIMER
                        if not isInLobby then
                            passiveScannerActive = true -- AGORA olhamos quem "não tem nada"
                            StatusLabel.Text = "STATUS: OLHO ABSOLUTO"
                            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                            game.StarterGui:SetCore("SendNotification", {Title="Hub V49", Text="Varredura Completa Liberada!", Duration=3})
                            
                            -- Reanalisa todo mundo agora que o tempo passou
                            if chars then
                                for _, c in pairs(chars:GetChildren()) do
                                    analyzeTarget(c)
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
        checkGameStatus()
        task.wait(0.5)
    end
end)

-- Monitoramento contínuo de novos players
task.spawn(function()
    while true do
        if settings.esp and not isInLobby then
            local chars = Workspace:FindFirstChild("Characters")
            if chars then
                for _, c in pairs(chars:GetChildren()) do
                    if c.Name ~= LocalPlayer.Name then
                        attachSensor(c) -- Garante sensor
                        analyzeTarget(c) -- Garante análise
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

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
createToggle("ESP PLAYERS (Olho V49)", 60, function
