local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Movement = {}

local plr = Players.LocalPlayer

local humanoid = nil
local animator = nil

local tracks = {}
local currentTrack

local SETTINGS = {
	RunWindow = 0.35,
	RunSpeed = 30,
	DefaultSpeed = 16,
}

local Animations = {
	Idle = "rbxassetid://107028268347264",
	Walk = "rbxassetid://110276369977406",
	Run = "rbxassetid://100573845589785",
}

local WHeld = false
local IsRunning = false
local LastWPress = 0

-- UTIL

local function stopCurrent()
	if currentTrack then
		currentTrack:Stop()
		currentTrack = nil
	end
end

local function play(track)
	if currentTrack == track then
		return
	end
	stopCurrent()
	currentTrack = track
	if track then
		track:Play()
	end
end

-- LOAD WEAPON ANIMATIONS

local function clearTracks()
	for _, track in pairs(tracks) do
		track:Stop()
		track:Destroy()
	end
	tracks = {}
end

local function updateSpeed()
	if not humanoid then
		return
	end

	-- Running
	if IsRunning then
		humanoid.WalkSpeed = SETTINGS.RunSpeed
	else
		humanoid.WalkSpeed = SETTINGS.DefaultSpeed
	end
end

local function loadAnimations()
	clearTracks()

	local function load(name)
		local animID = Animations[name]
		if not animID then
			return
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = animID

		local track = animator:LoadAnimation(animation)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Movement
		tracks[name] = track
	end

	load("Idle")
	load("Walk")
	load("Run")
end

-- MOVEMENT LOOP

local function startMovementLoop()
	RunService.RenderStepped:Connect(function()
		if not humanoid then
			return
		end

		local moving = humanoid.MoveDirection.Magnitude > 0.1

		if moving then
			if WHeld and IsRunning and tracks.Run then
				play(tracks.Run)
			else
				play(tracks.Walk)
			end
		else
			play(tracks.Idle)
		end
	end)
end

local function onCharacterAdded(hum)
	humanoid = hum
	animator = humanoid:WaitForChild("Animator")

	humanoid.WalkSpeed = SETTINGS.DefaultSpeed

	startMovementLoop()
	loadAnimations()
end

-- INPUT

function Movement.Init()
	print("Initiaited")
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe or not humanoid then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			WHeld = true
			local now = os.clock()

			if now - LastWPress <= SETTINGS.RunWindow then
				IsRunning = true
				updateSpeed()
			end

			LastWPress = now
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if not humanoid then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			WHeld = false
			IsRunning = false
			updateSpeed()
		end
	end)

	if plr.Character then
		onCharacterAdded(plr.Character:WaitForChild("Humanoid"))
	end
	plr.CharacterAdded:Connect(function(character)
		onCharacterAdded(character:WaitForChild("Humanoid"))
	end)
end

return Movement
