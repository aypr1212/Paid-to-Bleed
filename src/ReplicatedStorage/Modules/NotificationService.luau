local TweenService = game:GetService("TweenService")

local NotificationClient = {}

function NotificationClient.Notify(plr, Title: string?, Description: string?)
	local plrGui: PlayerGui = plr:WaitForChild("PlayerGui")

	local NotificationGui = script:WaitForChild("NotificationGui"):Clone()
	NotificationGui.Parent = plrGui

	local mainFrame = NotificationGui:WaitForChild("Main")

	local NotificationFrame = mainFrame:WaitForChild("Notification")

	local TitleFrame = NotificationFrame:WaitForChild("TopBar")
	local DescriptionFrame = NotificationFrame:WaitForChild("Description")

	local TitleLabel = TitleFrame:WaitForChild("typeOfNotification")
	local DescriptionLabel = DescriptionFrame:WaitForChild("Description")

	TitleLabel.Text = Title
	DescriptionLabel.Text = Description

	TweenService:Create(
		NotificationFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Position = UDim2.fromScale(0.816, 0.655) }
	):Play()
	task.wait(3)
	TweenService:Create(
		NotificationFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Position = UDim2.fromScale(1.2, 0.655) }
	):Play()

	task.wait(0.5)
	NotificationGui:Destroy()
end

return NotificationClient
