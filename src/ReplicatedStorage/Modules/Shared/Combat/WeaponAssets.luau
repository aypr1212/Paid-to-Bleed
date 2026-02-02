local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponAssets = {}

local AssetsFolder = ReplicatedStorage:WaitForChild("Assets")
local Animations = AssetsFolder:WaitForChild("Animations")

local assets = {}

function WeaponAssets.preloadAnimation()
	for _, animation in pairs(Animations:GetDescendants()) do
		if animation:IsA("Animation") then
			table.insert(assets, animation)
		end
	end

	ContentProvider:PreloadAsync(assets)
end

return WeaponAssets
