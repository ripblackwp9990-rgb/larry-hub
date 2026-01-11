--// SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// FUNÇÃO CHARACTER (R6 / R15)
local function getChar()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")
	return char, hrp, hum
end

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LarryHub"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

--// BOTÃO ☠️ TOGGLE (40x40, MÓVEL)
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(40,40)
toggle.Position = UDim2.fromScale(0.9,0.05)
toggle.Text = "☠️"
toggle.TextSize = 22
toggle.Font = Enum.Font.GothamBlack
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(20,20,20)
toggle.Active = true
toggle.Draggable = true
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

--// FRAME PRINCIPAL
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(240,260)
frame.Position = UDim2.fromScale(0.35,0.35)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

--// TÍTULO
local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(240,30)
title.Text = "☠️ LARRY HUB DEV ☠️"
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = frame

--// FUNÇÃO BOTÃO
local function mkBtn(txt,y,color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(220,30)
	b.Position = UDim2.fromOffset(10,y)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = color
	b.Parent = frame
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local setBtn    = mkBtn("SETAR POSIÇÃO",40,Color3.fromRGB(0,170,255))
local goBtn     = mkBtn("IR ATÉ POSIÇÃO",75,Color3.fromRGB(0,200,120))
local noclipBtn = mkBtn("NOCLIP: OFF",110,Color3.fromRGB(200,80,80))
local arBtn     = mkBtn("ANTI RAGDOLL: OFF",145,Color3.fromRGB(200,80,80))
local speedBtn  = mkBtn("",180,Color3.fromRGB(120,120,255))

--// VARIÁVEIS
local savedAttachment
local noclip = false
local antiRagdoll = false
local noclipConn

--// TOGGLE MENU
toggle.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

--------------------------------------------------
--// SPEED SYSTEM
--------------------------------------------------
local speedLevel = 1
local baseSpeed = 16

local function applySpeed()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = baseSpeed * speedLevel
	end
end

local function updateSpeedText()
	local nextSpeed = speedLevel + 1
	if nextSpeed > 5 then nextSpeed = 1 end
	speedBtn.Text = "SPEED " .. speedLevel .. "x (PRÓXIMO " .. nextSpeed .. "x)"
end

updateSpeedText()

speedBtn.MouseButton1Click:Connect(function()
	speedLevel += 1
	if speedLevel > 5 then speedLevel = 1 end
	applySpeed()
	updateSpeedText()
end)

player.CharacterAdded:Connect(function()
	task.wait(0.3)
	applySpeed()
end)

--------------------------------------------------
--// SETAR POSIÇÃO
--------------------------------------------------
setBtn.MouseButton1Click:Connect(function()
	local _,hrp = getChar()
	if savedAttachment then savedAttachment:Destroy() end
	savedAttachment = Instance.new("Attachment")
	savedAttachment.WorldCFrame = hrp.CFrame
	savedAttachment.Parent = workspace.Terrain
end)

--------------------------------------------------
--// IR ATÉ POSIÇÃO (SEM ANTI TP)
--------------------------------------------------
goBtn.MouseButton1Click:Connect(function()
	if not savedAttachment then return end
	local _,hrp = getChar()

	local start = hrp.CFrame
	local target = savedAttachment.WorldCFrame
	local alpha = 0
	local speed = 0.12

	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		alpha += dt / speed
		if alpha >= 1 then
			hrp.CFrame = target
			conn:Disconnect()
			return
		end
		hrp.CFrame = start:Lerp(target, alpha)
	end)
end)

--------------------------------------------------
--// NOCLIP
--------------------------------------------------
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "NOCLIP: ON" or "NOCLIP: OFF"
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(80,200,120) or Color3.fromRGB(200,80,80)

	if noclipConn then noclipConn:Disconnect() end
	if noclip then
		noclipConn = RunService.Stepped:Connect(function()
			local char = player.Character
			if not char then return end
			for _,v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end)
	end
end)

--------------------------------------------------
--// ANTI RAGDOLL (SEM LENTIDÃO)
--------------------------------------------------
RunService.Heartbeat:Connect(function()
	if not antiRagdoll then return end
	local char,_,hum = getChar()
	hum.PlatformStand = false
	hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
	hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
	hum:ChangeState(Enum.HumanoidStateType.Running)

	for _,v in pairs(char:GetDescendants()) do
		if v:IsA("BallSocketConstraint") then
			v:Destroy()
		end
	end
end)

arBtn.MouseButton1Click:Connect(function()
	antiRagdoll = not antiRagdoll
	arBtn.Text = antiRagdoll and "ANTI RAGDOLL: ON" or "ANTI RAGDOLL: OFF"
	arBtn.BackgroundColor3 = antiRagdoll and Color3.fromRGB(80,200,120) or Color3.fromRGB(200,80,80)
end)
