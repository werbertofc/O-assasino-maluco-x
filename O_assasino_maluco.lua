--[[ 
    WERBERT HUB V55 - OMEGA SENSOR + UI FIX
    Criador: @werbert_ofc
    
    ATUALIZAÇÃO:
    - Botão de Minimizar (-) restaurado.
    - Ícone Flutuante para reabrir o menu.
    - Mantida a Tecnologia Omega (Detecção Híbrida + Heartbeat 60x/s).
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
    esp = false,    -- Roles (Murderer/Sheriff)
    gunEsp = false  -- Dropped Gun
}

local roleMemory = {} 
local isPassiveScanActive = false 
local isInLobby = true

if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- INTERFACE (COM MINIMIZAR)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V55_OmegaUI"
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
MainFrame.Size = UDim2.new(0, 240, 0, 220)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- Preto Absoluto
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "HUB V55 (OMEGA)"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- STATUS
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "LOBBY"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
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

-- ÍCONE FLUTUANTE (QUANDO MINIMIZADO)
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

-- LÓGICA DE MINIMIZAR
MiniBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = false
    FloatIcon.Visible = true 
end)

FloatIcon.MouseButton1Click:Connect(function() 
    FloatIcon.Visible = false
    MainFrame.Visible = true 
end)

makeDraggable(MainFrame)
makeDraggable(FloatIcon)

local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Vermelho OMEGA
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        end
    end)
end

-- ==============================================================================
-- 1. TECNOLOGIA DE DETECÇÃO OMEGA (CORAÇÃO DO SCRIPT)
-- ==============================================================================

local function analyzePlayer(folder)
    local playerName = folder.Name
    if playerName == LocalPlayer.Name then return end
    
    -- Memória Blindada
    if roleMemory[playerName] == "Murderer" then return end

    -- [A] SENSOR VISUAL (Instante Zero)
    -- Se aparecer qualquer ferramenta ou modelo na mão, analisamos NA HORA.
    local equipped = folder:FindFirstChildOfClass("Tool") or folder:FindFirstChild("WorldModel")
    
    if equipped then
        -- LÓGICA DE ELIMINAÇÃO:
        -- Se tem arma na mão + WornGun nas costas = A arma na mão só pode ser Faca -> ASSASSINO
        if folder:FindFirstChild("WornGun") then
            roleMemory[playerName] = "Murderer"
            return
        end
        
        -- Se tem arma na mão + WornKnife nas costas = A arma na mão só pode ser Gun -> XERIFE
        if folder:FindFirstChild("WornKnife") then
            if roleMemory[playerName] ~= "Murderer" then
                roleMemory[playerName] = "Sheriff"
            end
            return
        end
    end

    -- [B] SENSOR PASSIVO (Pós-Lag 15s)
    if isPassiveScanActive then
        -- Sumiu WornKnife? -> ASSASSINO
        if not folder:FindFirstChild("WornKnife") then
            roleMemory[playerName] = "Murderer"
        end
        
        -- Sumiu WornGun? -> XERIFE
        if not folder:FindFirstChild("WornGun") then
            if roleMemory[playerName] ~= "Murderer" then
                roleMemory[playerName] = "Sheriff"
            end
        end
    end
end

-- ==============================================================================
-- 2. LOOP HEARTBEAT (A TECNOLOGIA ULTRA BOA)
-- ==============================================================================

RunService.Heartbeat:Connect(function()
    -- 1. Gerenciamento de Estado (Lobby vs Partida)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
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
                        isPassiveScanActive = false
                        roleMemory = {} -- RESET TOTAL
                        StatusLabel.Text = "LOBBY (MEMÓRIA LIMPA)"
                        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                    end
                -- PARTIDA DETECTADA
                else
                    if isInLobby then
                        isInLobby = false
                        roleMemory = {}
                        isPassiveScanActive = false
                        
                        -- Timer Visual 15s
                        task.spawn(function()
                            for i = 15, 1, -1 do
                                if isInLobby then return end
                                StatusLabel.Text = "LAG PROTECT: " .. i .. "s"
                                StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                                task.wait(1)
                            end
                            
                            if not isInLobby then
                                isPassiveScanActive = true
                                StatusLabel.Text = "OMEGA SENSOR: ATIVO"
                                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                                game.StarterGui:SetCore("SendNotification", {Title="Hub V55", Text="Sensores Maximizados!", Duration=3})
                            end
                        end)
                    end
                end
            end
        end
    end

    -- 2. Varredura Turbo (Só se o ESP estiver ligado e fora do lobby)
    if settings.esp and not isInLobby then
        local chars = Workspace:FindFirstChild("Characters")
        if chars then
            for _, folder in pairs(chars:GetChildren()) do
                analyzePlayer(folder) -- Analisa 60x por segundo
            end
        end
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

-- BOTÕES
createToggle("OMEGA SENSOR (Players)", 60, function(state) settings.esp = state end)
createToggle("ESP GUN (Arma)", 110, function(state) settings.gunEsp = state end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V55", Text="Minimizar Adicionado!", Duration=5})
