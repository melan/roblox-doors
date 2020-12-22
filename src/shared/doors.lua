-- !strict
local Doors = {}

local function multiplycfv3(a, b)
	local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = a:GetComponents()
	local vx, vy, vz = b.x, b.y, b.z
	local nx = m11*vx+m12*vy+m13*vz+x
	local ny = m21*vx+m22*vy+m23*vz+y
	local nz = m31*vx+m32*vy+m33*vz+z
	return Vector3.new(nx, ny, nz)
end

local BaseDoor = {}
BaseDoor.__index = BaseDoor

function Doors.NewBaseDoor()
	local newBaseDoor = setmetatable({}, BaseDoor)
	newBaseDoor.isOpen = false
	newBaseDoor.TransitionComplete = Instance.new("BindableEvent")
	newBaseDoor.TransitionComplete.Name = "TransitionComplete"
	
	return newBaseDoor
end

function BaseDoor:doOpen()
	return error("[BaseDoor] Please implement the doOpen method in your class")
end

function BaseDoor:Open()
	if not self.isOpen then
		self:doOpen()
		self.isOpen = true
	end
	
	self.TransitionComplete:Fire(self.isOpen)
end

function BaseDoor:doClose()
	return error("[BaseDoor] Please implement the doClose method in your class")
end

function BaseDoor:Close()
	if self.isOpen then
		self:doClose()
		self.isOpen = false
	end
	
	self.TransitionComplete:Fire(self.isOpen)
end

function BaseDoor:IsOpen()
	return self.isOpen
end

---------

local SlidingDoor = setmetatable({}, BaseDoor)
SlidingDoor.__index = SlidingDoor

function Doors.NewSlidingDoor(part, direction)
	local newSlidingDoor = Doors.NewBaseDoor()
	setmetatable(newSlidingDoor, SlidingDoor)
	
	newSlidingDoor.Part = part
	newSlidingDoor.Direction = direction
	newSlidingDoor.Iterations = 100
	newSlidingDoor.TimeToComplete = 3.0
	
	newSlidingDoor.StepCFrame = newSlidingDoor.Direction / newSlidingDoor.Iterations
	newSlidingDoor.Delay = newSlidingDoor.TimeToComplete / newSlidingDoor.Iterations
	
	return newSlidingDoor
end

function SlidingDoor:doOpen()
	for i = 1,self.Iterations do
		self.Part.CFrame = CFrame.new(self.Part.Position) + self.StepCFrame
		--print("New door position " .. tostring(self.Part.Position))
		wait(self.Delay)
	end
end

function SlidingDoor:doClose()
	for i = 1,self.Iterations do
		self.Part.CFrame = CFrame.new(self.Part.Position) - self.StepCFrame
		--print("New door position " .. tostring(self.Part.Position))
		wait(self.Delay)
	end
end

----------
local DoubleDoor = setmetatable({}, BaseDoor)
DoubleDoor.__index = DoubleDoor

function Doors.NewDoubleDoor(leftDoor, rightDoor)
	local newDoubleDoor = Doors.NewBaseDoor()
	setmetatable(newDoubleDoor, DoubleDoor)
	
	newDoubleDoor.LeftDoor = leftDoor
	newDoubleDoor.RightDoor = rightDoor
	
	return newDoubleDoor
end

function DoubleDoor:doOpen()
	spawn(function ()
		self.LeftDoor:Open()
	end)
	
	spawn(function ()
		self.RightDoor:Open()
	end)
	
	local leftIsOpen = self.LeftDoor.TransitionComplete.Event:Wait()
	local rightIsOpen = self.RightDoor.TransitionComplete.Event:Wait()
end

function DoubleDoor:doClose()
	spawn(function ()
		self.LeftDoor:Close()
	end)

	spawn(function ()
		self.RightDoor:Close()
	end)

	local leftIsOpen = self.LeftDoor.TransitionComplete.Event:Wait()
	local rightIsOpen = self.RightDoor.TransitionComplete.Event:Wait()
end

---------------

local SwingDoor = setmetatable({}, BaseDoor)
SwingDoor.__index = SwingDoor

function Doors.NewSwingDoor(part, axis, direction)
	local newSwingDoor = Doors.NewBaseDoor()
	setmetatable(newSwingDoor, SwingDoor)
	
	newSwingDoor.Part = part
	newSwingDoor.Direction = direction
	newSwingDoor.Axis = axis
	newSwingDoor.Iterations = 100
	newSwingDoor.TimeToComplete = 3.0

	newSwingDoor.StepCFrame = newSwingDoor.Direction / newSwingDoor.Iterations
	newSwingDoor.Delay = newSwingDoor.TimeToComplete / newSwingDoor.Iterations

	return newSwingDoor
end

function SwingDoor:doOpen()
	self:Spin(0, 90, 90/self.Iterations)
end

function SwingDoor:doClose()
	self:Spin(90, 0, -90/self.Iterations)
end

function SwingDoor:Spin(startAngle, stopAngle, increment)
	local axisPosition = self.Axis.CFrame.Position
	local doorPosition = self.Part.CFrame.Position

	local doorPositionAxisVector = Vector3.new(axisPosition.X - doorPosition.X, axisPosition.Y - doorPosition.Y, axisPosition.Z - doorPosition.Z)
	local doorPositionAxisUnitVector = doorPositionAxisVector.Unit
	local axisUp = self.Axis.CFrame.UpVector

	local cosTheta = doorPositionAxisUnitVector:Dot(axisUp)
	local ro = doorPositionAxisVector.Magnitude * math.sqrt(1 - math.pow(cosTheta, 2))
	local yCenterOffset = -doorPositionAxisVector.Magnitude*cosTheta
	
	for i = startAngle,stopAngle,increment do
		local fi = i / 360 * 2 * math.pi
		
		local doorX = ro * math.cos(fi)
		local doorY = yCenterOffset
		local doorZ = ro * math.sin(fi)
		
		local doorCenter =  multiplycfv3(self.Axis.CFrame, Vector3.new(doorX, doorY, doorZ))
		local doorRight = (doorCenter - self.Axis.CFrame.Position).Unit
		local doorUp = axisUp
		local doorFace = doorUp:Cross(doorRight).Unit
		

		
		self.Part.CFrame = CFrame.fromMatrix(doorCenter, doorRight, doorUp, -doorFace)
		
		wait(self.Delay)
	end
end


return Doors