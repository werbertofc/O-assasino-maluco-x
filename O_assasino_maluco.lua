--[[ 
    WERBERT HUB V43 - LÓGICA DE IMUNIDADE (ZERO ERROS)
    Criador: @werbert_ofc
    
    Correção Definitiva do "Xerife marcado como Assassino":
    - Regra de Ouro: Se o jogador tem 'WornKnife' visível nas costas, ele JAMAIS será marcado como Assassino.
    - Isso impede que o Xerife (que tem a faca decorativa ou nada) seja confundido.
    - O Assassino é OBRIGATORIAMENTE quem NÃO TEM a 'WornKnife' nas costas.
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
local scannerActive = false 
local isInLobby = true
local monitoredFolders = {}

if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- INTERFACE
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V43_Immunity"
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
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "ASSASSINO LOUCO X (V43)"
Title.TextColor3 = Color3.fromRGB(255, 0, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 15
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
FloatIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
FloatIcon.Text = "V43"
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
-- 1. SISTEMA DE TIMER / LOBBY
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
            
            if distance < 300 then 
                if not isInLobby then
                    isInLobby = true
                    scannerActive = false
                    roleMemory = {}
                    StatusLabel.Text = "STATUS: LOBBY (Resetado)"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                    game.StarterGui:SetCore("SendNotification", {Title="Hub V43", Text="Lobby = Memória Limpa", Duration=3})
                end
            else
                if isInLobby then
                    isInLobby = false
                    task.spawn(function()
                        for i = 20, 1, -1 do
                            if isInLobby then return end
                            StatusLabel.Text = "AGUARDANDO: " .. i .. "s"
                            StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                            task.wait(1)
                        end
                        if not isInLobby then
                            scannerActive = true
                            StatusLabel.Text = "STATUS: DETECÇÃO ATIVA"
                            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                            game.StarterGui:SetCore("SendNotification", {Title="Hub V43", Text="Scanner Liberado!", Duration=3})
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
-- 2. LÓGICA DE IMUNIDADE (O SEGREDO)
-- ==============================================================================

function analyzePlayer(folder)
    local playerName = folder.Name
    if playerName == LocalPlayer.Name then return end

    -- [REGRA 1] IMUNIDADE ABSOLUTA
    -- Se o jogador tem WornKnife nas costas, ele JAMAIS será o assassino.
    -- Se ele foi marcado errado antes, limpamos AGORA.
    if folder:FindFirstChild("WornKnife") then
        if roleMemory[playerName] == "Murderer" then
            roleMemory[playerName] = nil -- Corrige o erro imediatamente
        end
    end

    -- Se o jogador tem WornGun nas costas, ele JAMAIS será o Xerife.
    if folder:FindFirstChild("WornGun") then
        if roleMemory[playerName] == "Sheriff" then
            roleMemory[playerName] = nil -- Corrige o erro imediatamente
        end
    end

    -- [REGRA 2] DETECÇÃO VISUAL (ARMA NA MÃO)
    -- Ignora o timer. Se puxou, a gente analisa.
    if folder:FindFirstChild("WorldModel") then
        -- Se tem algo na mão E tem WornGun nas costas...
        -- Significa que ele NÃO está segurando a arma. Então é a faca.
        -- E como ele tem WornGun, ele não é Xerife.
        -- CONCLUSÃO: ASSASSINO.
        if folder:FindFirstChild("WornGun") then
            roleMemory[playerName] = "Murderer"
            return
        end

        -- Se tem algo na mão E tem WornKnife nas costas...
        -- Significa que ele NÃO está segurando a faca. Então é a arma.
        -- CONCLUSÃO: XERIFE.
        if folder:FindFirstChild("WornKnife") then
            roleMemory[playerName] = "Sheriff"
            return
        end
    end

    -- [REGRA 3] DETECÇÃO PASSIVA (APÓS 20s)
    if scannerActive then
        -- Se falta a WornKnife nas costas...
        -- E não é porque ele acabou de equipar (já tratamos acima)...
        -- É porque ele é o Assassino.
        if not folder:FindFirstChild("WornKnife") then
            roleMemory[playerName] = "Murderer"
        end
        
        -- Se falta a WornGun nas costas...
        -- E ele não foi marcado como Assassino...
        -- É porque ele é o Xerife.
        if not folder:FindFirstChild("WornGun") then
            -- Check extra de segurança: só marca se não for assassino
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

-- LOOP CORRETOR (Roda a cada 0.2s para limpar erros)
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
        task.wait(0.2)
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
createToggle("ESP PLAYERS (Imunidade)", 60, function(state) settings.esp = state end)
createToggle("ESP ARMA (Azul)", 105, function(state) settings.gunEsp = state end)
createToggle("X-RAY (Paredes)", 150, function(state) settings.xray = state; toggleXray(state) end)
createToggle("SPEED (Correr +)", 195, function(state) settings.speed = state end)
createToggle("FULLBRIGHT (Luz)", 240, function(state) settings.fullbright = state end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V43", Text="Lógica de Imunidade Ativa!", Duration=5})
