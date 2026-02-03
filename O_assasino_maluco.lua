--[[ 
    WERBERT HUB V15 - LÓGICA DE TROCA (SWAP)
    Criador: @werbert_ofc
    Lógica Exata:
    - WorldModel Apareceu + WornKnife Sumiu = ASSASSINO
    - WorldModel Apareceu + WornGun Sumiu = XERIFE
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==============================================================================
-- CONFIGURAÇÕES
-- ==============================================================================
local settings = {
    esp = false,      
    gunEsp = false,   
    xray = false      
}

-- Tabela para salvar quem é quem
local knownRoles = {} -- [Player] = "Murderer" ou "Sheriff"
local originalTransparency = {}

-- Limpa UI antiga
if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- MENU VISUAL (SIMPLES E CONFIÁVEL)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V15"
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

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 240)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Criador: @werbert_ofc"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Botão Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Botão Minimizar
local MiniBtn = Instance.new("TextButton")
MiniBtn.Text = "-"
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.Parent = MainFrame

-- Ícone
local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 45, 0, 45)
FloatIcon.Position = UDim2.new(0.1, 0, 0.2, 0)
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
FloatIcon.Text = "W"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 20
FloatIcon.Visible = false
FloatIcon.Parent = ScreenGui
Instance.new("UICorner", FloatIcon).CornerRadius = UDim.new(1, 0)

MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatIcon.Visible = true end)
FloatIcon.MouseButton1Click:Connect(function() FloatIcon.Visible = false; MainFrame.Visible = true end)

makeDraggable(MainFrame)
makeDraggable(FloatIcon)

-- Criar Botões
local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = UDim2.new(0.075, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
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
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
    end)
end

-- ==============================================================================
-- LÓGICA V15: A "TROCA" (SWAP)
-- ==============================================================================

task.spawn(function()
    while true do
        if settings.esp then
            local charactersFolder = Workspace:FindFirstChild("Characters")
            
            if charactersFolder then
                for _, charFolder in pairs(charactersFolder:GetChildren()) do
                    local player = Players:FindFirstChild(charFolder.Name)
                    
                    if player and player ~= LocalPlayer then
                        
                        -- GATILHO: A arma apareceu (WorldModel)
                        -- Agora verificamos o que sumiu!
                        if charFolder:FindFirstChild("WorldModel") then
                            
                            -- Se a WornKnife SUMIU, é Assassino
                            if not charFolder:FindFirstChild("WornKnife") then
                                knownRoles[player] = "Murderer"
                            
                            -- Se a WornGun SUMIU, é Xerife
                            elseif not charFolder:FindFirstChild("WornGun") then
                                knownRoles[player] = "Sheriff"
                            
                            -- Caso Especial: Se ele pegou a arma do chão (Heroi)
                            -- Ele ainda vai ter a WornKnife e a WornGun, mas tem o WorldModel da arma
                            elseif charFolder:FindFirstChild("WornKnife") and charFolder:FindFirstChild("WornGun") then
                                knownRoles[player] = "Sheriff" -- Heroi conta como Xerife
                            end
                            
                        end
                    end
                end
            end
        end
        task.wait(0.1) -- Rápido para pegar a troca exata
    end
end)

-- 2. ESP VISUAL
task.spawn(function()
    while true do
        if settings.esp then
            local charactersFolder = Workspace:FindFirstChild("Characters")

            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    -- Busca o personagem
                    local char = nil
                    if charactersFolder then char = charactersFolder:FindFirstChild(plr.Name) end
                    if not char then char = plr.Character end

                    if char and char:FindFirstChild("Head") then
                        local role = knownRoles[plr]
                        
                        -- Cores Padrão
                        local color = Color3.fromRGB(255, 255, 255) -- Inocente (Branco)
                        local txt = "Inocente"

                        -- Aplica Cores Baseado na Memória (Tabela)
                        if role == "Murderer" then
                            color = Color3.fromRGB(255, 0, 0) -- VERMELHO
                            txt = "ASSASSINO"
                        elseif role == "Sheriff" then
                            color = Color3.fromRGB(0, 100, 255) -- AZUL
                            txt = "XERIFE"
                        end

                        -- Highlight
                        local hl = char:FindFirstChild("WerbertHighlight")
                        if not hl then 
                            hl = Instance.new("Highlight", char) 
                            hl.Name = "WerbertHighlight"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        hl.FillColor = color
                        hl.OutlineColor = color
                        
                        -- Nome
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
            -- Limpeza
            for _, plr in pairs(Players:GetPlayers()) do
                local char = plr.Character
                if char then
                    if char:FindFirstChild("WerbertHighlight") then char.WerbertHighlight:Destroy() end
                    if char:FindFirstChild("Head") and char.Head:FindFirstChild("WerbertTag") then char.Head.WerbertTag:Destroy() end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- 3. ESP DA ARMA (AZUL)
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

-- RESET AO SPAWNAR
local function resetDetection()
    knownRoles = {} -- Zera tudo
    game.StarterGui:SetCore("SendNotification", {Title = "HUB V15"; Text = "Resetado! Aguardando troca."; Duration = 3;})
end
LocalPlayer.CharacterAdded:Connect(resetDetection)
Workspace.ChildAdded:Connect(function(c) if c.Name == "Map" then resetDetection() end end)

-- BOTÕES
createToggle("ESP PLAYERS (Lógica Troca)", 50, function(state) settings.esp = state end)
createToggle("ESP ARMA (Azul)", 100, function(state) settings.gunEsp = state end)
createToggle("X-RAY (Paredes)", 150, function(state) settings.xray = state; toggleXray(state) end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V15", Text="Scanner de WornItems Ativo!", Duration=5})
