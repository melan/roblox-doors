local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local doorsModule = require(ReplicatedStorage.Common.doors)

local door = doorsModule.NewSwingDoor(Workspace.door, Workspace.axis, 1)
spawn(function ()
    while true do
        door:Open()

        wait(3)

        door:Close()

        wait(3)
    end
end)