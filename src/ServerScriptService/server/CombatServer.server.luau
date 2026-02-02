local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local combatSystem = {}

-- Require your modules
local Combat_Module =
	require(ServerStorage:WaitForChild("ServerModules"):WaitForChild("Combat"):WaitForChild("Combat_Module")) :: any
local HitboxService =
	require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Combat"):WaitForChild("HitboxService")) :: any

local PlayerDataHandler =
	require(ServerStorage:WaitForChild("ServerModules"):WaitForChild("Data"):WaitForChild("PlayerDataManager")) :: any

-- Wait for RemoteEvent reliably
local Events = ReplicatedStorage:WaitForChild("Events")
local CombatEvents = Events:WaitForChild("Combat")
local CombatEvent = CombatEvents:WaitForChild("CombatEvent") :: RemoteEvent

print("Server CombatEvent is ready:", CombatEvent) -- debug

-- Handle players joining
Players.PlayerAdded:Connect(function(plr)
	plr:SetAttribute("WeaponEquipped", false)

	plr.CharacterAdded:Connect(function(char)
		local humanoid = char:WaitForChild("Humanoid")

		-- Set default attributes
		humanoid:SetAttribute("Stunned", false)
		humanoid:SetAttribute("Blocking", false)
		humanoid:SetAttribute("InAerial", false)
		humanoid:SetAttribute("Roll", false)
		humanoid:SetAttribute("IFrames", false)

		combatSystem[char] = Combat_Module.new(char)
		return
	end)

	plr.CharacterRemoving:Connect(function(char)
		combatSystem[char] = nil
	end)

	return
end)

-- Helper to get weapon spec
local function getWeaponSpec(plr)
	local currentWeapon = plr:GetAttribute("CurrentWeapon")
	if currentWeapon then
		return ReplicatedStorage:WaitForChild("Modules")
			:WaitForChild("Combat")
			:WaitForChild("Weapons")
			:WaitForChild(currentWeapon)
	end
	return nil
end

-- Reliable server listener
CombatEvent.OnServerEvent:Connect(function(plr: Player, action: string, data: any)
	local char = plr.Character
	if not char then
		return
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end

	local combatInstance = combatSystem[char]
	if not combatInstance then
		return
	end

	if action == "AttackRequest" then
		if hum:GetAttribute("Stunned") or hum:GetAttribute("Blocking") then
			return print("no attributes")
		end

		print("received") -- <- original print

		combatInstance:M1()
	elseif action == "AttackHit" then
		local comboIndex = data.combo
		if not comboIndex then
			return
		end

		HitboxService.M1Hitbox({
			plr = plr,
			weapon = getWeaponSpec(plr),
			char = char,
			size = Vector3.new(8, 8, 8),
			cframe = combatInstance.HmanoidRootPart.CFrame * CFrame.new(0, 0, -3),
			Combo = comboIndex,
			stunDur = combatInstance.Weapon.ComboConfig.m1Stun,
			damage = combatInstance.Weapon.ComboConfig.Damage,
		})
	end
end)
