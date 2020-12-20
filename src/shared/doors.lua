local Doors = {}

local function multiplycfv3(a, b)
	local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = a:GetComponents()
	local vx, vy, vz = b.x, b.y, b.z
	local nx = m11*vx+m12*vy+m13*vz+x
	local ny = m21*vx+m22*vy+m23*vz+y
	local nz = m31*vx+m32*vy+m33*vz+z
	return Vector3.new(nx, ny, nz)
end

local SwingDoor = {}
SwingDoor.__index = SwingDoor

function Doors.NewSwingDoor (door, axis)
	local newSwingDoor = setmetatable({}, SwingDoor)
	newSwingDoor.door = door
	newSwingDoor.axis = axis
	
	return newSwingDoor
end

function SwingDoor:Spin()
	local axisPosition = self.axis.CFrame.Position
	local axisUp = self.axis.CFrame.UpVector
	local i = 0
	
	while true do
		local fi = i / 360 * 2 * math.pi
		local ro = 7
		
		local doorX = ro * math.cos(fi)
		local doorY = 0
		local doorZ = ro * math.sin(fi)
		
		local doorCenter =  multiplycfv3(self.axis.CFrame, Vector3.new(doorX, doorY, doorZ)) -- axis.CFrame.Position +  Vector3.new(doorX, doorY, doorZ) 
		local doorRight = (doorCenter - self.axis.CFrame.Position).Unit
		local doorUp = axisUp
		local doorFace = doorUp:Cross(doorRight).Unit
		

		
		self.door.CFrame = CFrame.fromMatrix(doorCenter, doorRight, doorUp, -doorFace)		
		
		wait(.1)
		i += 5
	end
end


return Doors