local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--// MODULES --\\
local CombatInputs = require(script.Parent.CombatInputs) :: any

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Animations = Assets:WaitForChild("Animations")
local Combat = Animations:WaitForChild("Combat")
local Weapons = Combat:WaitForChild("Weapons")

--// CONNECTIONS --\\
local _CombatConnections = nil
local _ClientConnections = nil
local weaponCache = {}

--// VARIABLES --\\
local animator: Animator
local equipped: boolean
local blockTrack: AnimationTrack?

local WeaponsFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Combat"):WaitForChild("Weapons")

local Events = ReplicatedStorage:WaitForChild("Events")
local CombatEvents = Events:WaitForChild("Combat")
local CombatEvent = CombatEvents:WaitForChild("CombatEvent")

local Inputs = {
	M1 = CombatInputs.Attack.Keycode,
}

local plr = Players.LocalPlayer
local char: Model
local hum: Humanoid
local CurrentWeapon: StringValue? = nil -- Define CurrentWeapon as a string variable

local function clearConnections()
	if _CombatConnections then
		_CombatConnections:Disconnect()
		_CombatConnections = nil
	end
end

local function getWeaponModule(weaponName)
	if not weaponCache[weaponName] then
		local module = WeaponsFolder:FindFirstChild(weaponName)
		if module then
			weaponCache[weaponName] = require(module)
		end
	end
	return weaponCache[weaponName]
end

local function equipWeapon(Character)
	-- Play equip animation
	local humanoid = Character:WaitForChild("Humanoid")
	animator = humanoid:FindFirstChildOfClass("Animator")

	if not CurrentWeapon or not CurrentWeapon.Value then
		warn("CurrentWeapon or its Value is nil")
		return
	end
	local equipAnimation = Weapons[CurrentWeapon.Value]:WaitForChild("Equip")
	local equipTrack = animator:LoadAnimation(equipAnimation)
	equipTrack:Play()

	equipped = true

	--// FIRE TO SERVER HERE TO SET EQUIPPED ATTRIBUTE TO TRUE --\\
	CombatEvent:FireServer("EquipWeaponRequest", {})
	return equipTrack.Length
end
local function unequipWeapon()
	equipped = false

	CombatEvent:FireServer("UnequipWeaponRequest", {})
end

local function onWeaponChanged(newWeaponName)
	local weaponModule = getWeaponModule(newWeaponName)
	if weaponModule and plr then
		equipWeapon(weaponModule)
	else
		warn("Weapon module not found:", newWeaponName)
	end
end

local function refreshWeaponState()
	if plr:GetAttribute("WeaponEquipped") then
		CurrentWeapon = plr:WaitForChild("CurrentWeapon") -- Assign CurrentWeapon from player attributes
		if not CurrentWeapon or not CurrentWeapon.Value then
			warn("CurrentWeapon or its Value is nil")
			return
		end
		onWeaponChanged(CurrentWeapon.Value)
	else
		unequipWeapon()
	end
end

local function playM1(Humanoid: Humanoid, comboIndex: number)
	if not Humanoid or Humanoid.Health <= 0 then
		return
	end

	animator = Humanoid:FindFirstChildOfClass("Animator") :: Animator
	if not CurrentWeapon or not CurrentWeapon.Value then
		warn("CurrentWeapon or its Value is nil")
		return
	end
	local animFolder = Weapons[CurrentWeapon.Value]
	local animation = animFolder:FindFirstChild("m" .. comboIndex)
	if not animation then
		return warn("Missing animation m" .. comboIndex)
	end

	local track = animator:LoadAnimation(animation)

	track.KeyframeReached:Connect(function(keyframe)
		if keyframe == "Hit" then
			CombatEvent:FireServer("AttackHit", {
				combo = comboIndex,
			})
		end
	end)

	return track:Play()
end

local function UnBlock()
	if not blockTrack then
		return
	end

	blockTrack:Stop()
	blockTrack:Destroy()
	blockTrack = nil

	CombatEvent:FireServer("UnBlock", {})
end

local function Bind()
	clearConnections()

	_CombatConnections = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return
		end

		if input.UserInputType == Inputs.M1 then
			print("Attack input detected")
			-- Attack logic goes here
			if not CombatEvent then
				print("no event")
				return
			end
			CombatEvent:FireServer("AttackRequest", {})
		elseif input.KeyCode == Enum.KeyCode.E then
			if equipped then
				unequipWeapon()
			else
				equipWeapon(char)
			end
		end
	end)

	_ClientConnections = CombatEvent.OnClientEvent:Connect(function(action: string, data: any)
		print("Recieved client event")
		if action == "SwingStart" then
			print("Swing starting on client")
			local comboIndex = data.combo
			playM1(hum, comboIndex)
		end
	end)
end

local function setupHumanoidSignals(humanoid: Humanoid)
	humanoid:GetAttributeChangedSignal("Blocking"):Connect(function()
		if not humanoid:GetAttribute("Blocking") then
			UnBlock()
		end
	end)

	humanoid:GetAttributeChangedSignal("Roll"):Connect(function()
		if humanoid:GetAttribute("Roll") then
			UnBlock()
		end
	end)
end

local function onCharacterAdded(newChar: Model)
	char = newChar
	hum = char:WaitForChild("Humanoid") :: Humanoid
	CurrentWeapon = plr:WaitForChild("CurrentWeapon") -- Assign CurrentWeapon from player attributes

	hum.Died:Connect(function()
		unequipWeapon()
		refreshWeaponState()
	end)

	setupHumanoidSignals(hum)

	refreshWeaponState()
	Bind()

	plr:GetAttributeChangedSignal("WeaponEquipped"):Connect(refreshWeaponState)
	plr:WaitForChild("CurrentWeapon"):GetPropertyChangedSignal("Value"):Connect(function()
		refreshWeaponState()
	end)
end

if plr.Character then
	onCharacterAdded(plr.Character)
end

plr.CharacterAdded:Connect(onCharacterAdded)

print("Combat Client Initialized")
