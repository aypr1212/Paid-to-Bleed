local HelperFunctions = {}

function HelperFunctions.PlayAnimation(Character: Model, Animation: Animation): Animation
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	local Animator = Humanoid:FindFirstChild("Animator") :: Animator

	local LoadedAnimation = Animator:LoadAnimation(Animation)

	LoadedAnimation:Play()

	return LoadedAnimation
end

function HelperFunctions.StopAllAnimations(Character: Model)
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	if not Humanoid then
		return
	end

	local Animator = Humanoid:FindFirstChildOfClass("Animator")

	for _, anim in Animator:GetPlayingAnimationTracks() do
		anim:Stop()
	end
end

return HelperFunctions
