local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.ServerModules

local function setUpModules()
	for _, module in ServerModules:GetDescendants() do
		if module:IsA("ModuleScript") then
			local moduleScript = require(module)
			if moduleScript and typeof(moduleScript.Init) == "function" then
				moduleScript.Init()
			end
		end
	end
end

setUpModules()

local CharacterMenuServer = require(ReplicatedStorage.ClientModules.CharacterMenu.CharacterMenuServer)

CharacterMenuServer.Init()
