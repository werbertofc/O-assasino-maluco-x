--[[ 
    SCRIPT: O ASSASSINO LOUCO X (HUB V25 - ESTÁVEL)
    Criador: @werbert_ofc
    
    Funcionalidades:
    - Detecção Inteligente (WornItems na pasta Characters)
    - Gun ESP (Arma Azul Neon)
    - Speed Legit (24)
    - Fullbright (Luz Infinita)
    - ESP Players (Wallhack)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
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
local originalTransparency = {}

if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- MENU VISUAL (INTERFACE)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AssassinoLoucoX_Hub_V25"
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
MainFrame.Size = UDim2.new(0, 260, 0, 320) -- Tamanho ajustado
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "O ASSASSINO LOUCO X"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = MainFrame

local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 15)
Credits.Position = UDim2.new(0, 0, 0, 25)
Credits.BackgroundTransparency = 1
Credits.Text = "Criado por @werbert_ofc"
Credits.TextColor3 = Color3.fromRGB(150, 150, 150)
Credits.Font = Enum.Font.Gotham
Credits.TextSize = 10
Credits.Parent = MainFrame

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
FloatIcon.Text = "X"
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
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end)
end

-- ==============================================================================
-- LÓGICA DO SCRIPT
-- ==============================================================================

-- 1. SCANNER DE PAPÉIS (WornItems)
-- Monitora constantemente se os itens sumiram da pasta do jogador
task.spawn(function()
    while true do
        if settings.esp then
            local charactersFolder = Workspace:FindFirstChild("Characters")
            
            if charactersFolder then
                for _, charFolder in pairs(charactersFolder:GetChildren()) do
                    local playerName = charFolder.Name
                    
                    if playerName ~= LocalPlayer.Name then
                        -- Lógica confirmada:
                        -- Se NÃO TEM WornKnife = ASSASSINO
                        if not charFolder:FindFirstChild("WornKnife") then
                            roleMemory[playerName] = "Murderer"
                        end

                        -- Se NÃO TEM WornGun = XERIFE
                        if not charFolder:FindFirstChild("WornGun") then
                            roleMemory[playerName] = "Sheriff"
                        end
                    end
                end
            end
        end
        task.wait(0.1) -- Rápido
    end
end)

-- 2. ESP VISUAL (Wallhack)
task.spawn(function()
    while true do
        if settings.esp then
            local charactersFolder = Workspace:FindFirstChild("Characters")

            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local char = nil
                    if charactersFolder then char = charactersFolder:FindFirstChild(plr.Name) end
                    if not char then char = plr.Character end

                    if char and char:FindFirstChild("Head") then
                        local role = roleMemory[plr.Name]
                        local color = Color3.fromRGB(255, 255, 255) -- Branco (Padrão)
                        local txt = "Inocente"

                        if role == "Murderer" then
                            color = Color3.fromRGB(255, 0, 0) -- Vermelho
                            txt = "ASSASSINO"
                        elseif role == "Sheriff" then
                            color = Color3.fromRGB(0, 100, 255) -- Azul
                            txt = "XERIFE"
                        end

                        -- Highlight (Brilho no corpo)
                        local hl = char:FindFirstChild("WerbertHighlight")
                        if not hl then 
                            hl = Instance.new("Highlight", char) 
                            hl.Name = "WerbertHighlight"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        hl.FillColor = color
                        hl.OutlineColor = color
                        
                        -- Tag (Nome na cabeça)
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
        else
            -- Limpeza quando desliga
            for _, plr in pairs(Players:GetPlayers()) do
                local char = plr.Character
                if char then
                    if char:FindFirstChild("WerbertHighlight") then char.WerbertHighlight:Destroy() end
                    if char:FindFirstChild("Head") and char.Head:FindFirstChild("WerbertTag") then char.Head.WerbertTag:Destroy() end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- 3. ESP ARMA (AZUL NEON)
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

-- 4. SPEED (Velocidade 24)
task.spawn(function()
    while true do
        if settings.speed then
            pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 24 end)
        end
        task.wait(0.2)
    end
end)

-- 5. FULLBRIGHT (Luz Infinita)
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

-- 6. X-RAY
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

-- RESET AO MUDAR DE MAPA
local function resetDetection()
    roleMemory = {} 
    game.StarterGui:SetCore("SendNotification", {Title = "ASSASSINO LOUCO X"; Text = "Novo Jogo Iniciado!"; Duration = 3;})
end
LocalPlayer.CharacterAdded:Connect(resetDetection)
Workspace.ChildAdded:Connect(function(c) if c.Name == "Map" then resetDetection() end end)

-- BOTÕES
createToggle("ESP PLAYERS (Auto-Detect)", 50, function(state) settings.esp = state end)
createToggle("ESP ARMA (Azul)", 95, function(state) settings.gunEsp = state end)
createToggle("X-RAY (Paredes)", 140, function(state) settings.xray = state; toggleXray(state) end)
createToggle("SPEED (Correr +)", 185, function(state) settings.speed = state end)
createToggle("FULLBRIGHT (Luz)", 230, function(state) settings.fullbright = state end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V25", Text="Script Carregado!", Duration=5})
