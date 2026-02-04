--[[ 
    WERBERT HUB V56 - LOOP PURO (SEM EVENTOS)
    Criador: @werbert_ofc
    
    LÓGICA SIMPLIFICADA:
    1. Não usa ChildAdded/ChildRemoved (Eventos).
    2. Usa Varredura Constante (Heartbeat Loop).
    3. Começa todo mundo como Inocente (Branco).
    4. Menu com Minimizar (-) funcionando.
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
local isInLobby = true

if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- INTERFACE (COM MINIMIZAR FUNCIONAL)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V56_Loop"
if pcall(function() ScreenGui.Parent = CoreGui end) then
    getgenv().WerbertUI = ScreenGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    getgenv().WerbertUI = ScreenGui
end

-- Função de Arrastar
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

-- JANELA PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- TÍTULO
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "HUB V56 (LOOP)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
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

-- ÍCONE FLUTUANTE (ABRIR)
local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 50, 0, 50)
FloatIcon.Position = UDim2.new(0.1, 0, 0.2, 0)
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FloatIcon.BorderColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.BorderSizePixel = 1
FloatIcon.Text = "HUB"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 14
FloatIcon.Visible = false
FloatIcon.Parent = ScreenGui
Instance.new("UICorner", FloatIcon).CornerRadius = UDim.new(0.5, 0)

-- LÓGICA DO MINIMIZAR
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

-- CRIAÇÃO DE TOGGLES
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
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end)
end

-- ==============================================================================
-- 1. LOOP DE LÓGICA (NOVO CORAÇÃO DO SCRIPT)
-- ==============================================================================
-- Isso substitui os eventos. Roda a cada frame.

RunService.Heartbeat:Connect(function()
    
    -- [A] CHECAR ONDE ESTAMOS (LOBBY OU PARTIDA)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local lobby = Workspace:FindFirstChild("Lobby")
        local mapParts = lobby and lobby:FindFirstChild("MapParts")
        
        if mapParts then
            local ref = mapParts:FindFirstChildWhichIsA("BasePart", true)
            if ref then
                local dist = (char.HumanoidRootPart.Position - ref.Position).Magnitude
                
                -- Se estiver perto do mapa (< 300 studs) -> LOBBY
                if dist < 300 then
                    if not isInLobby then
                        isInLobby = true
                        roleMemory = {} -- RESET TOTAL
                        StatusLabel.Text = "LOBBY (RESETADO)"
                        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                    end
                -- Se estiver longe -> PARTIDA
                else
                    if isInLobby then
                        isInLobby = false
                        roleMemory = {} -- Limpa ao começar
                        StatusLabel.Text = "PARTIDA (VARREDURA ATIVA)"
                        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                        game.StarterGui:SetCore("SendNotification", {Title="Hub V56", Text="Scanner Ativado!", Duration=3})
                    end
                end
            end
        end
    end

    -- [B] VARREDURA DE JOGADORES (SÓ SE O ESP ESTIVER LIGADO)
    if settings.esp and not isInLobby then
        local charactersFolder = Workspace:FindFirstChild("Characters")
        if charactersFolder then
            for _, folder in pairs(charactersFolder:GetChildren()) do
                local playerName = folder.Name
                if playerName ~= LocalPlayer.Name then
                    
                    -- Se já sabemos quem é, não precisa checar (Memória)
                    if roleMemory[playerName] == "Murderer" then continue end
                    
                    -- DETECÇÃO 1: FALTAM ITENS?
                    if not folder:FindFirstChild("WornKnife") then
                        roleMemory[playerName] = "Murderer"
                    elseif not folder:FindFirstChild("WornGun") then
                        if roleMemory[playerName] ~= "Murderer" then
                            roleMemory[playerName] = "Sheriff"
                        end
                    end
                    
                    -- DETECÇÃO 2: ITEM NA MÃO? (CONFIRMAÇÃO)
                    local tool = folder:FindFirstChildOfClass("Tool") or folder:FindFirstChild("WorldModel")
                    if tool then
                        if folder:FindFirstChild("WornGun") then
                            roleMemory[playerName] = "Murderer" -- Arma nas costas + algo na mão = FACA
                        elseif folder:FindFirstChild("WornKnife") then
                            if roleMemory[playerName] ~= "Murderer" then
                                roleMemory[playerName] = "Sheriff" -- Faca nas costas + algo na mão = ARMA
                            end
                        end
                    end
                    
                end
            end
        end
    end
end)


-- ==============================================================================
-- VISUAL (ESP) - RODA A CADA FRAME VISUAL
-- ==============================================================================

RunService.RenderStepped:Connect(function()
    if not settings.esp then 
        -- Limpa se desligar
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
            -- MM2 usa uma pasta customizada "Characters", tenta achar lá primeiro
            if charactersFolder then char = charactersFolder:FindFirstChild(plr.Name) end
            if not char then char = plr.Character end

            if char and char:FindFirstChild("Head") then
                local role = roleMemory[plr.Name]
                
                -- PADRÃO: BRANCO / INOCENTE
                local color = Color3.fromRGB(255, 255, 255)
                local txt = "Inocente"

                if role == "Murderer" then
                    color = Color3.fromRGB(255, 0, 0)
                    txt = "ASSASSINO"
                elseif role == "Sheriff" then
                    color = Color3.fromRGB(0, 100, 255)
                    txt = "XERIFE"
                end

                -- Highlight (Brilho)
                local hl = char:FindFirstChild("WerbertHighlight")
                if not hl then 
                    hl = Instance.new("Highlight", char) 
                    hl.Name = "WerbertHighlight"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                hl.FillColor = color
                hl.OutlineColor = color
                hl.FillTransparency = 0.5
                
                -- Texto (Nome + Role)
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

-- ESP ARMA (LOOP SIMPLES)
task.spawn(function()
    while true do
        if settings.gunEsp then
            -- Procura a arma caída no mapa
            local targetFolder = nil
            for _, c in pairs(Workspace:GetChildren()) do
                -- Pasta onde as armas dropadas costumam ficar
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
            -- Limpa se desligar
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

-- BOTÕES DE ATIVAÇÃO
createToggle("ESP PLAYERS", 60, function(state) settings.esp = state end)
createToggle("ESP ARMA", 110, function(state) settings.gunEsp = state end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V56", Text="Modo Loop Puro Ativo!", Duration=5})
