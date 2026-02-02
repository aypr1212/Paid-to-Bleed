local StunModule = {}

function StunModule.Stun(char: Model, speed: number, duration: number)
	local humanoid: Humanoid? = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if humanoid:GetAttribute("Stunned") then
		return
	end

	local stunId = tick()

	local originalSpeed = humanoid.WalkSpeed
	local originalJumpHeight = humanoid.JumpHeight

	humanoid:SetAttribute("Stunned", true)
	humanoid:SetAttribute("StunId", stunId)
	humanoid.WalkSpeed = speed
	humanoid.JumpHeight = 0

	task.delay(duration, function()
		if humanoid.Parent == nil then
			return
		end
		if humanoid:GetAttribute("StunId") ~= stunId then
			return
		end

		humanoid:SetAttribute("Stunned", false)
		humanoid.WalkSpeed = originalSpeed
		humanoid.JumpHeight = originalJumpHeight
	end)
end

return StunModule
