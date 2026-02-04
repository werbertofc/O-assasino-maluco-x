--[[ 
    WERBERT HUB V48 - O OLHO QUE TUDO VÊ (SENSOR ABSOLUTO)
    Criador: @werbert_ofc
    
    LÓGICA RÍGIDA:
    1. Monitora APENAS 'WornKnife' e 'WornGun'.
    2. Delay de 15s no início da partida (Todos Inocentes).
    3. Após 15s:
       - Se falta WornKnife -> ASSASSINO (Fixo até o fim).
       - Se falta WornGun -> XERIFE (Pode haver múltiplos).
    4. Reset apenas ao retornar para a área do Lobby (MapParts).
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

-- Tabela de memória: [NomeDoPlayer] = "Role"
local roleMemory = {} 
-- Variáveis de Estado
local isScannerActive = false 
local isInLobby = true
local connections = {} -- Para guardar os sensores e limpar depois

if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- INTERFACE (UI)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V48_TheEye"
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
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- Preto Profundo
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "O OLHO V48 (SENSOR)"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
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
FloatIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FloatIcon.Text = "👁️"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 24
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
-- SENSORES E LÓGICA DE DETECÇÃO (O CORAÇÃO DO SCRIPT)
-- ==============================================================================

-- Função que analisa um jogador individualmente
local function analyzeTarget(character)
    if not isScannerActive then return end -- Se não passou os 15s, não faz nada
    if not character then return end
    
    local playerName = character.Name
    
    -- Se já sabemos que é o Assassino, não precisa checar mais (Memória Eterna)
    if roleMemory[playerName] == "Murderer" then return end
    
    -- SENSOR 1: WornKnife (Faca nas costas)
    -- Se NÃO tem a faca -> É o Assassino.
    if not character:FindFirstChild("WornKnife") then
        roleMemory[playerName] = "Murderer"
        return -- Achamos o assassino, encerra análise deste player
    end
    
    -- SENSOR 2: WornGun (Arma nas costas)
    -- Se NÃO tem a arma -> É Xerife.
    -- (Pode ter vários xerifes, então não damos return, apenas marcamos)
    if not character:FindFirstChild("WornGun") then
        -- Só marca se não for o assassino (segurança)
        if roleMemory[playerName] ~= "Murderer" then
            roleMemory[playerName] = "Sheriff"
        end
    end
end

-- Função que conecta o sensor "ChildRemoved" na pasta do jogador
local function attachSensor(character)
    -- Evita duplicar sensores no mesmo personagem
    if connections[character] then return end
    
    -- SENSOR DE EVENTO: Dispara no milésimo de segundo que algo sai da pasta
    local conn = character.ChildRemoved:Connect(function(child)
        if not isScannerActive then return end -- Ignora se estiver no delay de 15s
        
        -- Verifica apenas os objetos solicitados
        if child.Name == "WornKnife" or child.Name == "WornGun" then
            analyzeTarget(character)
        end
    end)
    
    connections[character] = conn
    
    -- Faz uma análise inicial (caso já tenha tirado antes de conectar)
    analyzeTarget(character)
end

-- Limpa todas as conexões (usado no Reset)
local function clearSensors()
    for char, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    connections = {}
end

-- ==============================================================================
-- GERENCIADOR DA PARTIDA (TIMER E ESTADOS)
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
            
            -- ==========================================
            -- ESTADO: DENTRO DO LOBBY (RESET TOTAL)
            -- ==========================================
            if distance < 300 then 
                if not isInLobby then
                    isInLobby = true
                    isScannerActive = false
                    roleMemory = {} -- Limpa quem é quem
                    clearSensors() -- Desliga os sensores
                    
                    StatusLabel.Text = "STATUS: LOBBY (Resetado)"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                    game.StarterGui:SetCore("SendNotification", {Title="Hub V48", Text="Memória Limpa!", Duration=3})
                end
                
            -- ==========================================
            -- ESTADO: FORA DO LOBBY (PARTIDA)
            -- ==========================================
            else
                if isInLobby then
                    isInLobby = false -- Partida começou agora
                    
                    -- Limpa novamente para garantir que todos comecem inocentes
                    roleMemory = {} 
                    isScannerActive = false 
                    
                    -- Contagem Regressiva de 15 Segundos
                    task.spawn(function()
                        for i = 15, 1, -1 do
                            if isInLobby then return end -- Se voltar pro lobby, cancela
                            StatusLabel.Text = "RESETADO: " .. i .. "s"
                            StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                            task.wait(1)
                        end
                        
                        -- FIM DOS 15s: ATIVAÇÃO DOS OLHOS
                        if not isInLobby then
                            isScannerActive = true -- Libera a marcação
                            StatusLabel.Text = "OLHO ATIVO: VIGIANDO"
                            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho Ameaçador
                            game.StarterGui:SetCore("SendNotification", {Title="Hub V48", Text="Sensores Ativados!", Duration=3})
                            
                            -- Conecta os sensores em todos os jogadores presentes
                            local chars = Workspace:FindFirstChild("Characters")
                            if chars then
                                for _, c in pairs(chars:GetChildren()) do
                                    attachSensor(c)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

-- Loop de Gerenciamento (Roda a cada 0.5s)
task.spawn(function()
    while true do
        checkGameStatus()
        task.wait(0.5)
    end
end)

-- Loop de Segurança (Reforço)
-- Caso um jogador entre depois ou o evento falhe, esse loop varre a cada 0.5s
-- Só funciona se o scanner estiver ativo (após os 15s)
task.spawn(function()
    while true do
        if settings.esp and isScannerActive then
            local chars = Workspace:FindFirstChild("Characters")
            if chars then
                for _, c in pairs(chars:GetChildren()) do
                    if c.Name ~= LocalPlayer.Name then
                        attachSensor(c) -- Garante que o sensor está conectado
                        analyzeTarget(c) -- Analisa o estado atual
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- ==============================================================================
-- VISUAL (ESP) - SÓ MOSTRA O QUE ESTÁ NA MEMÓRIA
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
                
                -- Padrão: Inocente (Branco)
                local color = Color3.fromRGB(255, 255, 255)
                local txt = "Inocente"

                -- Se a memória diz que é Assassino, pinta de Vermelho
                if role == "Murderer" then
                    color = Color3.fromRGB(255, 0, 0)
                    txt = "ASSASSINO"
                -- Se a memória diz que é Xerife, pinta de Azul
                elseif role == "Sheriff" then
                    color = Color3.fromRGB(0, 100, 255)
                    txt = "XERIFE"
                end

                -- Aplica visual
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

-- ESP ARMA (Item no chão)
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
createToggle("ESP PLAYERS (Olho V48)", 60, function(state) settings.esp = state end)
createToggle("ESP ARMA (Azul)", 105, function(state) settings.gunEsp = state end)
createToggle("X-RAY (Paredes)", 150, function(state) settings.xray = state; toggleXray(state) end)
createToggle("SPEED (Correr +)", 195, function(state) settings.speed = state end)
createToggle("FULLBRIGHT (Luz)", 240, function(state) settings.fullbright = state end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V48", Text="O Olho que Tudo Vê Ativado!", Duration=5})
