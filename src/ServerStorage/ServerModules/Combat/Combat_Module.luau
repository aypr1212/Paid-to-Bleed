local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StunModule = require(ReplicatedStorage.Modules.Combat.StunService) :: any
local Blockstun = require(ReplicatedStorage.Modules.Combat.BlockStun) :: any

local Events = ReplicatedStorage.Events

local CombatFolder = Events.Combat
local CombatEvent = CombatFolder.CombatEvent

local Combat = {}
Combat.__index = Combat

function Combat.new(char)
	local self = setmetatable({
		DefaultSpeed = 16,
		Combo = 0,
		CanAttack = true,
		Blocking = false,

		ParryWindow = 0.25,
		ParryCooldown = 0.5,
		ParryOnCooldown = false,

		BlockingCooldown = 0.5,

		TimeTillComboReset = 2,
	}, Combat)

	self.Character = char
	self.Humanoid = char:WaitForChild("Humanoid")
	self.HumanoidRootPart = char:WaitForChild("HumanoidRootPart")

	self.Player = Players:GetPlayerFromCharacter(char)

	self.Stunned = self.Humanoid:GetAttribute("Stunned")

	-- Only players have weapons
	if self.Player then
		print("player is here")
		local currentWeapon = self.Player:WaitForChild("CurrentWeapon")
		if currentWeapon then
			local weaponModule = ReplicatedStorage.Modules.Combat.Weapons:FindFirstChild(currentWeapon.Value)
			if weaponModule then
				self.Weapon = require(weaponModule)
			else
				warn("Weapon module not found:", currentWeapon.Value)
			end
		else
			warn("No current weapon attribute for player:", self.Player.UserId)
		end
	end

	if self.Weapon and self.Weapon.ComboConfig then
		self.MaxCombo = self.Weapon.ComboConfig.length :: number
	else
		self.MaxCombo = 4 -- safe fallback
	end

	print("Init")
	return self
end

function Combat:M1()
	print("M1")
	if not self.CanAttack then
		return
	end
	if not self.Weapon then
		return print("no weapon")
	end

	self.CanAttack = false

	print("Playered M1ed")

	self.Combo += 1
	if self.Combo > self.MaxCombo then
		self.Combo = 1
		self.CanAttack = false
		task.delay(self.TimeTillComboReset, function()
			self.CanAttack = true
		end)
	end

	local comboIndex = self.Combo

	-- Light self-stun for swing commitment
	StunModule.Stun(self.Character, 4, self.Weapon.ComboConfig.window)

	-- Tell client which animation to play
	CombatEvent:FireClient(self.Player, "SwingStart", {
		combo = comboIndex,
	})

	print("Fired")

	task.delay(self.Weapon.ComboConfig.window, function()
		self.CanAttack = true
		print("Can attack")
	end)
end

function Combat:Critical()
	if not self.CanAttack then
		return
	end
	if not self.Weapon then
		return
	end

	self.CanAttack = false

	StunModule.Stun(self.Character, 4, self.Weapon.ComboConfig.CriticalWindow)

	CombatEvent:FireClient(self.Player, "CriticalStart", {})
	task.delay(self.Weapon.ComboConfig.CriticalWindow, function()
		self.CanAttack = true
	end)
end

function Combat:Roll(dashDirection)
	if not self.CanAttack then
		return
	end
	if not self.HumanoidRootPart then
		return
	end

	self.CanAttack = false

	local hrp = self.HumanoidRootPart
	local attachment = hrp:FindFirstChild("RootAttachment")

	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "RootAttachment"
		attachment.Parent = hrp
	end

	local dashDuration = 0.35
	local dashStrength = 75
	local minStrength = dashStrength * 0.15
	local rate = 0.01

	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = attachment
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.MaxForce = 30000
	lv.Parent = hrp

	CombatEvent:FireClient(self.Player, "RollStart", { direction = dashDirection })

	self.Humanoid:SetAttribute("RollIFrames", true)
	self.Humanoid:SetAttribute("Roll", true)
	task.delay(dashDuration, function()
		self.Humanoid:SetAttribute("Roll", false)
	end)

	task.delay(dashDuration * 0.75, function()
		self.Humanoid:SetAttribute("RollIFrames", false)
	end)

	-- Direction resolver
	local function getDirection(): Vector3
		if dashDirection == "Front" then
			return hrp.CFrame.LookVector
		elseif dashDirection == "Back" then
			return -hrp.CFrame.LookVector
		elseif dashDirection == "Right" then
			return hrp.CFrame.RightVector
		elseif dashDirection == "Left" then
			return -hrp.CFrame.RightVector
		end
		return hrp.CFrame.LookVector :: Vector3
	end

	local elapsed = 0

	while elapsed < dashDuration do
		elapsed += rate

		-- Smooth ease-out curve
		local alpha = elapsed / dashDuration
		local strength = dashStrength * (1 - alpha)

		if strength < minStrength then
			strength = minStrength
		end

		lv.VectorVelocity = getDirection() * strength
		task.wait(rate)
	end

	lv:Destroy()
	self.CanAttack = true
end

function Combat:Block()
	if not self.CanAttack then
		return
	end
	if not self.Weapon then
		return
	end

	Blockstun.Stun(self.Character, 2)

	CombatEvent:FireClient(self.Player, "BlockStart", {})
end

function Combat:Parry()
	if not self.Weapon then
		return
	end
	if self.ParryOnCooldown then
		return
	end

	-- Defensive state checks
	if self.Humanoid:GetAttribute("Stunned") then
		return
	end
	if self.Humanoid:GetAttribute("Roll") then
		return
	end
	if self.Humanoid:GetAttribute("Blocking") then
		return
	end

	self.ParryOnCooldown = true
	self.Humanoid:SetAttribute("Parry", true)

	-- Parry window
	task.delay(self.ParryWindow, function()
		if self.Humanoid then
			self.Humanoid:SetAttribute("Parry", false)
		end
	end)

	-- Cooldown timer
	task.delay(self.ParryCooldown, function()
		self.ParryOnCooldown = false
	end)
end

function Combat:UnBlock()
	if not self.Weapon then
		return
	end

	Blockstun.UnStun(self.Character, self.DefaultSpeed)
end
return Combat
