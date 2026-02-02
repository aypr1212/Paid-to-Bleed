local Blockstun = {}

function Blockstun.Stun(char, speed)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid:SetAttribute("Blocking", true)
	humanoid.WalkSpeed = speed
	humanoid.JumpHeight = 0
end

function Blockstun.UnStun(char, speed)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid:SetAttribute("Blocking", false)
	humanoid.WalkSpeed = speed
	humanoid.JumpHeight = 7.2
end

return Blockstun
