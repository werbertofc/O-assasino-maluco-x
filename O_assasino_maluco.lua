--[[ 
    WERBERT HUB V57 - SENSOR DE EVENTOS (CLÁSSICO)
    Criador: @werbert_ofc
    
    LÓGICA SOLICITADA:
    1. Monitora a pasta Workspace.Characters.
    2. Usa o evento .ChildRemoved dentro da pasta de cada jogador.
    3. Se sumir WornKnife = Assassino.
    4. Se sumir WornGun = Xerife.
    5. Menu Limpo com Minimizar (-).
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==============================================================================
-- CONFIGURAÇÕES
-- ==============================================================================
local settings = {
    esp = false,    -- Roles
    gunEsp = false  -- Gun Drop
}

local roleMemory = {} 
local connectedCharacters = {} -- Evita conectar 2x no mesmo boneco
local isInLobby = true

if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- INTERFACE (MINIMALISTA + MINIMIZAR)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V57_Events"
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

-- JANELA
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- TÍTULO
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "HUB V57 (EVENTOS)"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = MainFrame

-- STATUS
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "AGUARDANDO..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

-- BOTÃO FECHAR (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- BOTÃO MINIMIZAR (-)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Text = "-"
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.Parent = MainFrame

-- ÍCONE FLUTUANTE
local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 50, 0, 50)
FloatIcon.Position = UDim2.new(0.1, 0, 0.2, 0)
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
FloatIcon.BorderColor3 = Color3.fromRGB(0, 255, 0)
FloatIcon.BorderSizePixel = 1
FloatIcon.Text = "V57"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 14
FloatIcon.Visible = false
FloatIcon.Parent = ScreenGui
Instance.new("UICorner", FloatIcon).CornerRadius = UDim.new(0.5, 0)

MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatIcon.Visible = true end)
FloatIcon.MouseButton1Click:Connect(function() FloatIcon.Visible = false; MainFrame.Visible = true end)

makeDraggable(MainFrame)
makeDraggable(FloatIcon)

local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        if enabled then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end)
end

-- ==============================================================================
-- 1. SISTEMA DE SENSORES DE EVENTO (A MÁGICA)
-- ==============================================================================

local function attachSensor(characterFolder)
    -- Se já conectamos nesse personagem, ignora
    if connectedCharacters[characterFolder] then return end
    connectedCharacters[characterFolder] = true
    
    local playerName = characterFolder.Name
    
    -- EVENTO: Dispara no momento EXATO que algo sai da pasta
    characterFolder.ChildRemoved:Connect(function(child)
        -- Se estiver no Lobby, não faz nada
        if isInLobby then return end
        
        -- LÓGICA DE DETECÇÃO PEDIDA
        if child.Name == "WornKnife" then
            -- Se saiu a faca -> É ASSASSINO
            roleMemory[playerName] = "Murderer"
        elseif child.Name == "WornGun" then
            -- Se saiu a arma -> É XERIFE (desde que não seja assassino)
            if roleMemory[playerName] ~= "Murderer" then
                roleMemory[playerName] = "Sheriff"
            end
        end
    end)
    
    -- Varredura inicial (caso ele já tenha tirado antes do script ligar)
    if not isInLobby then
        if not characterFolder:FindFirstChild("WornKnife") then
            roleMemory[playerName] = "Murderer"
        elseif not characterFolder:FindFirstChild("WornGun") then
            if roleMemory[playerName] ~= "Murderer" then
                roleMemory[playerName] = "Sheriff"
            end
        end
    end
end

local function setupSensors()
    local charactersFolder = Workspace:FindFirstChild("Characters")
    if charactersFolder then
        -- Conecta nos jogadores que já estão lá
        for _, folder in pairs(charactersFolder:GetChildren()) do
            attachSensor(folder)
        end
        
        -- Conecta nos jogadores que entrarem depois
        charactersFolder.ChildAdded:Connect(function(folder)
            attachSensor(folder)
        end)
    end
end

-- Inicia os sensores
setupSensors()
-- Caso a pasta Characters seja recriada (reset do mapa)
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Characters" then
        task.wait(0.5)
        setupSensors()
    end
end)

-- ==============================================================================
-- 2. GERENCIADOR DE LOBBY (RESET)
-- ==============================================================================

local function checkLocation()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    local lobby = Workspace:FindFirstChild("Lobby")
    local mapParts = lobby and lobby:FindFirstChild("MapParts")
    
    if mapParts then
        local ref = mapParts:FindFirstChildWhichIsA("BasePart", true)
        if ref then
            local dist = (char.HumanoidRootPart.Position - ref.Position).Magnitude
            
            -- LOBBY DETECTADO
            if dist < 300 then
                if not isInLobby then
                    isInLobby = true
                    roleMemory = {} -- RESET DA MEMÓRIA
                    StatusLabel.Text = "STATUS: LOBBY (Limpo)"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                end
            -- PARTIDA DETECTADA
            else
                if isInLobby then
                    isInLobby = false
                    roleMemory = {} -- Garante limpeza ao começar
                    StatusLabel.Text = "STATUS: PARTIDA (Eventos ON)"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    game.StarterGui:SetCore("SendNotification", {Title="Hub V57", Text="Monitorando Pastas...", Duration=3})
                    
                    -- Força varredura nos players atuais
                    local cf = Workspace:FindFirstChild("Characters")
                    if cf then
                        for _, f in pairs(cf:GetChildren()) do
                            -- Reaplica lógica inicial
                            if not f:FindFirstChild("WornKnife") then roleMemory[f.Name] = "Murderer" end
                            if not f:FindFirstChild("WornGun") then 
                                if roleMemory[f.Name] ~= "Murderer" then roleMemory[f.Name] = "Sheriff" end 
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Loop lento (só pra checar lobby)
task.spawn(function()
    while true do
        checkLocation()
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
                
                -- TODO MUNDO COMEÇA BRANCO (INOCENTE)
                local color = Color3.fromRGB(255, 255, 255)
                local txt = "Inocente"

                if role == "Murderer" then
                    color = Color3.fromRGB(255, 0, 0)
                    txt = "ASSASSINO"
                elseif role == "Sheriff" then
                    color = Color3.fromRGB(0, 100, 255)
                    txt = "XERIFE"
                end

                -- Visual
                local hl = char:FindFirstChild("WerbertHighlight")
                if not hl then 
                    hl = Instance.new("Highlight", char) 
                    hl.Name = "WerbertHighlight"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                hl.FillColor = color
                hl.OutlineColor = color
                hl.FillTransparency = 0.5
                
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
                    lbl.TextSize = 13
                    lbl.TextStrokeTransparency = 0.5
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
                        hl.FillTransparency = 0.2
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
                        txt.TextStrokeTransparency = 0.5
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

-- BOTÕES
createToggle("ESP PLAYERS (Roles)", 60, function(state) settings.esp = state end)
createToggle("ESP ARMA", 110, function(state) settings.gunEsp = state end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V57", Text="Sensores de Pasta Ativados!", Duration=5})
