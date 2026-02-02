local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local PlayerDataManager = require(ServerStorage.ServerModules.Data.PlayerDataManager)

local Events = ReplicatedStorage.Events
local ClientEvents = Events.Client
local CharacterMenuEvent = ClientEvents.CharacterMenu

local CharacterMenuServer = {}

function CharacterMenuServer.Init()
	Players.PlayerAdded:Connect(function(plr)
		-- Wait for data to load
		while not PlayerDataManager.IsDataLoaded(plr) do
			task.wait()
		end

		if PlayerDataManager.IsCharacterCompleted(plr) then
			return
		end

		CharacterMenuEvent:FireClient(plr, "EnableGui")
	end)

	CharacterMenuEvent.OnServerEvent:Connect(function(plr, selections)
		if typeof(selections) ~= "table" then
			return
		end
		if not PlayerDataManager.IsDataLoaded(plr) then
			return
		end

		local name = selections.Name
		if typeof(name) ~= "string" then
			return
		end

		-- Trim whitespace
		name = name:match("^%s*(.-)%s*$")

		-- Length rules
		if #name < 3 or #name > 16 then
			return
		end

		-- Only allow letters (optional but recommended)
		if not name:match("^[A-Za-z]+$") then
			return
		end

		PlayerDataManager.SetCharacterCompleted(plr, selections)

		print("Saved name:", name)
	end)
end

return CharacterMenuServer
