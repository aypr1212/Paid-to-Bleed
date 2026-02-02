local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterMenuClient = require(ReplicatedStorage.ClientModules.CharacterMenu.CharacterMenuClient)
local Movement = require(ReplicatedStorage.ClientModules.Movement.Movement)
local NotificationClient = require(ReplicatedStorage.ClientModules.NotificationClient)

CharacterMenuClient.Init()
NotificationClient.Init()
Movement.Init()
