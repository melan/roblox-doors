local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local doorsModule = require(ReplicatedStorage.Common.doors)

local door = doorsModule.NewSwingDoor(Workspace.door, Workspace.axis)
spawn(function ()
    door:Spin()
end)