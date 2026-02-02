local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HitboxService = {}

local StunModule = require(ReplicatedStorage.Modules.Combat.StunService) :: any
local AttributeModule = require(ReplicatedStorage.Modules.Shared.AttributeHandler) :: any

local Events = ReplicatedStorage.Events
local CombatFolder = Events.Combat
local CombatEvent = CombatFolder.CombatEvent

export type HitboxParams = {
	plr: Player,
	weapon: ModuleScript,
	char: Model?,
	size: Vector3?,
	cframe: CFrame?,
	Combo: number?,
	stunDur: number?,
	damage: number,
}

function HitboxService.M1Hitbox(params: HitboxParams)
	local hitbox = Instance.new("Part")
	hitbox.Parent = workspace
	hitbox.Size = params.size
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.Color = Color3.fromRGB(255, 50, 30)
	hitbox.Transparency = 0.7
	hitbox.CFrame = params.cframe
	hitbox.Material = Enum.Material.ForceField
	game.Debris:AddItem(hitbox, 0.2)

	params.Combo = params.Combo or 0

	local hits = {}

	local overlapParams = OverlapParams.new()

	local parts = workspace:GetPartsInPart(hitbox, overlapParams)

	for _, part in ipairs(parts) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and not hits[model] and model ~= params.char then
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end

			if AttributeModule:GetAttribute(humanoid, "IFrames") then
				return
			end

			if AttributeModule:GetAttribute(humanoid, "Parry") then
				local attackerHum = if params.char then params.char:FindFirstChild("Humanoid") :: Humanoid else nil
				if attackerHum then
					StunModule.Stun(params.char, 6, 0.75)
				end

				CombatEvent:FireAllClients("ParryVFX", model)
				return
			end
			if AttributeModule:GetAttribute(humanoid, "RollIFrames") then
				StunModule.Stun(model, 6, 0.5)
				print("Stunned for dodge")
				CombatEvent:FireAllClients("RollIFrames", model)
				return
			end

			hits[model] = true

			StunModule.Stun(model, 4, params.stunDur)

			humanoid:TakeDamage(params.damage)

			CombatEvent:FireAllClients(
				"Hit",
				model,
				{ weaponName = params.weapon.Name, combo = params.Combo, hitType = "Normal" }
			)

			local highlight = Instance.new("Highlight")
			highlight.Parent = model
			highlight.FillTransparency = 1
			highlight.FillColor = Color3.fromRGB(255, 22, 1)
			highlight.OutlineColor = Color3.fromRGB(255, 0, 0)

			TweenService:Create(highlight, TweenInfo.new(0.05), { FillTransparency = 0.8 }):Play()

			local weaponConfig = require(params.weapon)
			task.delay(weaponConfig.ComboConfig.m1Stun, function()
				hits[model] = nil
				local tween = TweenService:Create(highlight, TweenInfo.new(0.05), { FillTransparency = 1 })
				tween:Play()

				tween.Completed:Connect(function()
					highlight:Destroy()
				end)
			end)
		end
	end

	return hitbox
end

return HitboxService
