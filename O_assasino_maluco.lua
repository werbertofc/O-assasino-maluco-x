--[[ 
    WERBERT HUB V30 - DELAY SEGURO (10 SEGUNDOS)
    Criador: @werbert_ofc
    Alteração:
    - O script espera 10 segundos após o spawn para fazer a verificação inicial.
    - Isso garante que todos os itens carregaram, evitando marcar inocentes no início.
    - Detecção de SAQUE (puxar arma) continua instantânea.
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
local monitoredFolders = {} 

if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- INTERFACE (V1)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V30_10s"
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
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "ASSASSINO LOUCO X (V30)"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 15
Title.Parent = MainFrame

local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 15)
Credits.Position = UDim2.new(0, 0, 0, 25)
Credits.BackgroundTransparency = 1
Credits.Text = "Delay Inicial: 10 Segundos"
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
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
FloatIcon.Text = "V30"
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
-- LÓGICA V30: DELAY DE 10 SEGUNDOS + MEMÓRIA
-- ==============================================================================

local function monitorCharacterFolder(folder)
    if monitoredFolders[folder] then return end
    monitoredFolders[folder] = true

    local playerName = folder.Name
    
    -- [ATUALIZAÇÃO] Delay de 10 Segundos
    task.spawn(function()
        task.wait(10) -- Agora espera 10s para ter certeza que tudo carregou
        if not folder.Parent then return end
        
        -- Checagem Inicial (Após 10s)
        if not folder:FindFirstChild("WornKnife") then 
            roleMemory[playerName] = "Murderer" 
        end
        if not folder:FindFirstChild("WornGun") and folder:FindFirstChild("WorldModel") then
            roleMemory[playerName] = "Sheriff"
        end
    end)

    -- EVENTO: Detecção Instantânea (Isso funciona MESMO durante os 10s de espera)
    -- Se ele puxar a faca no segundo 5, o script PEGA NA HORA.
    folder.ChildRemoved:Connect(function(child)
        if not settings.esp then return end
        
        if child.Name == "WornKnife" then
            roleMemory[playerName] = "Murderer"
        
        elseif child.Name == "WornGun" then
            task.delay(0.2, function()
                if folder:FindFirstChild("WorldModel") then
                    roleMemory[playerName] = "Sheriff"
                end
            end)
        end
    end)

    -- EVENTO: Heroi
    folder.ChildAdded:Connect(function(child)
        if not settings.esp then return end

        if child.Name == "WorldModel" then
            if roleMemory[playerName] ~= "Murderer" then
                roleMemory[playerName] = "Sheriff"
            end
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

-- RESET TOTAL
local function resetDetection()
    roleMemory = {} 
    monitoredFolders = {} 
    game.StarterGui:SetCore("SendNotification", {Title = "HUB V30"; Text = "Aguardando 10s para analisar..."; Duration = 3;})
    startMonitoring() 
end
LocalPlayer.CharacterAdded:Connect(resetDetection)
Workspace.ChildAdded:Connect(function(c) if c.Name == "Map" then resetDetection() end end)

-- BOTÕES
createToggle("ESP PLAYERS (10s Delay)", 50, function(state) settings.esp = state end)
createToggle("ESP ARMA (Azul)", 95, function(state) settings.gunEsp = state end)
createToggle("X-RAY (Paredes)", 140, function(state) settings.xray = state; toggleXray(state) end)
createToggle("SPEED (Correr +)", 185, function(state) settings.speed = state end)
createToggle("FULLBRIGHT (Luz)", 230, function(state) settings.fullbright = state end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V30", Text="Delay 10s Ativado!", Duration=5})
