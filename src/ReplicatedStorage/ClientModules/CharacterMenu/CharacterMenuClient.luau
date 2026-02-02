local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local plrGui: PlayerGui = plr:WaitForChild("PlayerGui")

local Events = ReplicatedStorage:WaitForChild("Events")
local ClientEvents = Events:WaitForChild("Client")
local CharacterMenuEvent = ClientEvents:WaitForChild("CharacterMenu")

local CharacterMenu = plrGui:WaitForChild("CharacterMenu")

local selections = {
	Gender = nil,
	ReflectionServiceace = nil,
}

local CharacterMenuClient = {}

local function connectButtons(menu)
	local main = menu:WaitForChild("Main")
	local frame = main:WaitForChild("CharacterMenu")
	local NameBox = frame.NameFrame.NameBox

	local MaleButton = frame.MaleFrame.MaleButton
	local FemaleButton = frame.FemaleFrame.FemaleButton
	local HumanButton = frame.HumanFrame.SelectHumanButton
	local FiendButton = frame.FiendFrame.SelectFiendButton
	local CompleteButton = frame.CompleteButton

	-- Gender
	MaleButton.MouseButton1Click:Connect(function()
		selections["Gender"] = "Male"
	end)

	FemaleButton.MouseButton1Click:Connect(function()
		selections["Gender"] = "Female"
	end)

	-- Race
	HumanButton.MouseButton1Click:Connect(function()
		selections["Race"] = "Human"
	end)

	FiendButton.MouseButton1Click:Connect(function()
		selections["Race"] = "Fiend"
	end)

	CompleteButton.MouseButton1Click:Connect(function()
		local nameText = NameBox.Text

		CharacterMenuEvent:FireServer({
			Gender = selections.Gender,
			Race = selections.Race,
			Name = nameText,
		})

		menu:Destroy()
	end)
end

function CharacterMenuClient.Init()
	CharacterMenuEvent.OnClientEvent:Connect(function(args)
		if args == "EnableGui" then
			connectButtons(CharacterMenu)
		end
	end)
end

return CharacterMenuClient
