local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
local DataTemplate = require(ServerStorage.ServerModules.Data.DataTemplate)

local Events = ReplicatedStorage.Events
local ClientEvents = Events.Client

local NotificationEvent = ClientEvents.Notification

local PlayerDataManager = {}

local DataStore = ProfileStore.New("TestData5", DataTemplate)

local Profiles: { [Player]: typeof(DataStore:StartSessionAsync()) } = {}

function PlayerDataManager.Init()
	Players.PlayerAdded:Connect(PlayerDataManager.HandlePlayer)
	Players.PlayerRemoving:Connect(PlayerDataManager.HandlePlayerDisconnect)
end

function PlayerDataManager.HandlePlayer(plr: Player)
	local profile = DataStore:StartSessionAsync(`{plr.UserId}`, {
		Cancel = function()
			return plr.Parent ~= Players
		end,
	})

	if not profile then
		plr:Kick("Failed to load player data, please rejoin.")
		return
	end

	profile:AddUserId(plr.UserId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		Profiles[plr] = nil
		plr:Kick("DataStore profile session has ended, please rejoin.")
		return
	end)

	if plr.Parent ~= Players then
		profile:EndSession()
		return
	end

	Profiles[plr] = profile

	print("Profile loaded for: ", plr.UserId)
	print(profile.Data)

	plr:SetAttribute("Money", profile.Data.Money)
	plr:SetAttribute("Race", profile.Data.Race)
	plr:SetAttribute("Name", profile.Data.Name)

	local CurrentWeapon = Instance.new("StringValue")
	CurrentWeapon.Name = "CurrentWeapon"
	CurrentWeapon.Value = profile.Data.CurrentWeapon or "Fist"
	CurrentWeapon.Parent = plr

	local character = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.DisplayName = profile.Data.Name
end

function PlayerDataManager.HandlePlayerDisconnect(plr: Player)
	local profile = Profiles[plr]
	if not profile then
		return
	end

	profile:EndSession()
end

function PlayerDataManager.GetData(plr: Player): { DataTemplate.PlayerData }
	local profile = Profiles[plr]
	if not profile then
		return {}
	end

	return profile.Data
end

function PlayerDataManager.IsDataLoaded(plr: Player): boolean
	return Profiles[plr] ~= nil
end

-- Setting data and getting data --

function PlayerDataManager.GetCurrentWeapon(plr: Player): string?
	if not PlayerDataManager.IsDataLoaded(plr) then
		return
	end

	local profile = Profiles[plr]
	if not profile then
		return
	end

	return profile.Data.CurrentWeapon
end

function PlayerDataManager.GetMoney(plr: Player): number
	if not PlayerDataManager.IsDataLoaded(plr) then
		return 0
	end

	local data = PlayerDataManager.GetData(plr)

	return data.Money
end

function PlayerDataManager.GiveMoney(plr: Player, amount: number)
	local profile = Profiles[plr]
	if not profile then
		return
	end

	profile.Data.Money += amount
end

function PlayerDataManager.AddItem(plr: Player, itemId: string, amount: number | string)
	local profile = Profiles[plr]
	if not profile then
		return
	end

	amount = amount or 1
	local inventory = profile.Data.Inventory

	if inventory[itemId] then
		inventory[itemId].Quantity += amount
	else
		inventory[itemId] = {
			Quantity = amount,
		}
	end

	print(`added item to inventory: {itemId}, amount: {amount}`)
	NotificationEvent:FireClient(plr, "Item Added", "You have received " .. amount .. " " .. itemId)
end

function PlayerDataManager.GetInventory(plr: Player): { DataTemplate.Inventory }
	if not PlayerDataManager.IsDataLoaded(plr) then
		return {}
	end
	local profile = Profiles[plr]
	if not profile then
		return {}
	end

	return profile.Data.Inventory
end

function PlayerDataManager.SetRace(plr: Player, value: string)
	local profile = Profiles[plr]
	if not profile then
		return
	end

	profile.Data.Race = value
end

function PlayerDataManager.GetRace(plr: Player): string?
	if not PlayerDataManager.IsDataLoaded(plr) then
		return
	end

	local profile = Profiles[plr]
	if not profile then
		return
	end

	return profile.Data.Race
end

function PlayerDataManager.GetContracts(plr: Player): DataTemplate.Contract?
	if not PlayerDataManager.IsDataLoaded(plr) then
		return
	end

	local profile = Profiles[plr]
	if not profile then
		return
	end

	return profile.Data.Contracts
end

function PlayerDataManager.SetContract(plr: Player, contractId: string, slotNumber: string)
	local profile = Profiles[plr]
	if not profile then
		return
	end

	profile.Data.Contracts[slotNumber] = contractId
end

function PlayerDataManager.GetName(plr: Player)
	if not PlayerDataManager.IsDataLoaded(plr) then
		return
	end

	local profile = Profiles[plr]
	if not profile then
		return
	end

	return profile.Data.Name
end

function PlayerDataManager.SetName(plr: Player, value)
	if not PlayerDataManager.IsDataLoaded(plr) then
		return
	end

	local profile = Profiles[plr]
	if not profile then
		return
	end

	profile.Data.Name = value
end

function PlayerDataManager.SetGender(plr: Player, value)
	if not PlayerDataManager.IsDataLoaded(plr) then
		return
	end

	local profile = Profiles[plr]
	if not profile then
		return
	end

	profile.Data.Gender = value
end

function PlayerDataManager.IsCharacterCompleted(plr: Player): boolean
	if not PlayerDataManager.IsDataLoaded(plr) then
		return false
	end

	local profile = Profiles[plr]
	if not profile then
		return false
	end

	return profile.Data.CharacterCompleted :: boolean
end

function PlayerDataManager.SetCharacterCompleted(plr: Player, selections)
	if not PlayerDataManager.IsDataLoaded(plr) then
		return
	end

	local profile = Profiles[plr]
	if not profile then
		return
	end

	PlayerDataManager.SetName(plr, selections.Name)
	PlayerDataManager.SetRace(plr, selections.Race)
	PlayerDataManager.SetGender(plr, selections.Gender)

	profile.Data.CharacterCompleted = true

	print(profile.Data)
end

return PlayerDataManager
