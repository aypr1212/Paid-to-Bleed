local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotificationService = require(ReplicatedStorage.Modules.NotificationService)

local Events = ReplicatedStorage:WaitForChild("Events")
local ClientEvents = Events:WaitForChild("Client")

local NotificationEvent = ClientEvents:WaitForChild("Notification")

local NotificationClient = {}

function NotificationClient.Init()
	NotificationEvent.OnClientEvent:Connect(function(title: string?, description: string?)
		local plr = Players.LocalPlayer

		NotificationService.Notify(plr, title, description)
	end)
end

return NotificationClient
