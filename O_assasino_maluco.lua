--[[ 
    WERBERT HUB V12 - DETECÇÃO AGRESSIVA (INSTANTÂNEA)
    Criador: @werbert_ofc
    Mudança: Usa Eventos (.ChildAdded) para detectar a arma no milissegundo que ela aparece.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
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

local knownArmed = {} 
local originalTransparency = {}

-- Limpa UI antiga
if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- MENU VISUAL (ESTILO V1)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V12"
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
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Criador: @werbert_ofc"
Title.TextColor3 = Color3.fromRGB(255, 50, 50) -- Vermelho para indicar agressivo
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Botão Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
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
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end)
end

-- ==============================================================================
-- SISTEMA DE DETECÇÃO AGRESSIVO
-- ==============================================================================

-- Função para verificar se um objeto é uma arma
local function isWeapon(obj)
    if not obj then return false end
    local name = obj.Name:lower()
    
    -- Critérios Agressivos:
    -- 1. Se chamar WorldModel
    if name == "worldmodel" or obj:IsA("WorldModel") then return true end
    -- 2. Se for uma Tool (Ferramenta) qualquer
    if obj:IsA("Tool") then return true end
    -- 3. Nomes suspeitos
    if name:find("knife") or name:find("gun") or name:find("revolver") or name:find("weapon") then return true end
    
    return false
end

-- Função para monitorar uma pasta de personagem individualmente
local monitoredFolders = {}

local function monitorCharacterFolder(charFolder)
    if monitoredFolders[charFolder] then return end -- Já está monitorando
    monitoredFolders[charFolder] = true

    local player = Players:FindFirstChild(charFolder.Name)
    if not player then return end

    -- 1. Checagem inicial (O que já tem lá dentro)
    for _, child in pairs(charFolder:GetChildren()) do
        if isWeapon(child) then
            knownArmed[player] = true
        end
    end

    -- 2. GATILHO INSTANTÂNEO (.ChildAdded)
    -- Isso dispara no exato momento que o item entra na pasta
    charFolder.ChildAdded:Connect(function(child)
        if settings.esp and isWeapon(child) then
            knownArmed[player] = true
        end
    end)
end

-- Loop Principal Agressivo
task.spawn(function()
    while true do
        if settings.esp then
            local charactersFolder = Workspace:FindFirstChild("Characters")
            if charactersFolder then
                -- Itera sobre todas as pastas de players
                for _, charFolder in pairs(charactersFolder:GetChildren()) do
                    -- Inicia o monitoramento de eventos nessa pasta
                    monitorCharacterFolder(charFolder)
                    
                    -- Redundância: Checa de novo manualmente caso o evento falhe
                    local player = Players:FindFirstChild(charFolder.Name)
                    if player and not knownArmed[player] then -- Só checa se ainda não for marcado
                         for _, child in pairs(charFolder:GetChildren()) do
                            if isWeapon(child) then
                                knownArmed[player] = true
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait() -- Sem tempo definido = roda o mais rápido possível (aprox 30-60x por segundo)
    end
end)


-- ESP VISUAL
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
                        local color = Color3.fromRGB(255, 255, 255) 
                        local txt = "Inocente"
                        
                        if knownArmed[plr] then
                            color = Color3.fromRGB(255, 0, 0) -- PERIGO
                            txt = "PERIGO (ARMADO)"
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

-- ESP DA ARMA (AZUL)
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
                        hl.FillColor = Color3.fromRGB(0, 0, 255)
                        hl.OutlineColor = Color3.fromRGB(0, 0, 255)
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
                        txt.TextColor3 = Color3.fromRGB(0, 100, 255)
                        txt.Font = Enum.Font.GothamBlack
                        txt.TextSize = 14
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
    knownArmed = {} 
    monitoredFolders = {} -- Reseta monitoramento para evitar memory leak
    game.StarterGui:SetCore("SendNotification", {Title = "RODADA NOVA"; Text = "ESP Resetado!"; Duration = 3;})
end
LocalPlayer.CharacterAdded:Connect(resetDetection)
Workspace.ChildAdded:Connect(function(c) if c.Name == "Map" then resetDetection() end end)


-- BOTÕES
createToggle("ESP PLAYERS (Wallhack)", 50, function(state) settings.esp = state end)
createToggle("ESP ARMA (Azul)", 100, function(state) settings.gunEsp = state end)
createToggle("X-RAY (Paredes)", 150, function(state) settings.xray = state; toggleXray(state) end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V12", Text="Detecção AGRESSIVA Ativa!", Duration=5})
