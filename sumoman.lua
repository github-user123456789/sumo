return function(Utils, TXT)
local function sumoman(rig, guys)
local root = rig.HumanoidRootPart
local mots = {}
for i,v in pairs (rig:GetDescendants()) do
	if v:IsA("Motor6D") and v.Name ~= "RootJoint" and v.Name ~= "Neck" then
		local p0, p1 = Instance.new("Attachment", v.Part0), Instance.new("Attachment", v.Part1)
		p0.CFrame = v.C0 * CFrame.Angles(0, math.pi / 2, 0); p1.CFrame = v.C1 * CFrame.Angles(0, math.pi / 2, 0)
		local hinge = Utils:Create({"HingeConstraint", v.Parent}, {
			Attachment0 = p0,
			Attachment1 = p1,
			Name = v.Name,
			--ActuatorType = Enum.ActuatorType.Motor,
			--TargetAngle = 90,
			--AngularSpeed = math.rad(10),
			--AngularResponsiveness = 20,
		}); table.insert(mots, hinge)
		if v.Name == "Left Hip" or v.Name == "Right Hip" then v.Name = "og"; v.Parent = v.Part1 else v:Destroy() end
		--[[
		local a = 0
		game:service("RunService").Stepped:connect(function(_, dt)
			a = a + dt
			v.Part1.RotVelocity = ro.CFrame.lookVector * math.cos(a) * 100
		end)
		]]
	elseif v:IsA("BasePart") and v.Transparency <= 0 and v.Name ~= "HumanoidRootPart" then
		local e = Utils:Create({"Part", v}, {
			Size = v.Size / 1.25,
			Transparency = 1,
			Name = "hb",
			Massless = true,
		}); Utils:ezweld(e, e, v, CFrame.new())
		if string.match(v.Name, "Leg") then e.Size = e.Size / 1.5 end
		if v.Name == "Head" then -- texture
			Instance.new("BlockMesh", v)
			v.Size = Vector3.new(1, 1, 1)
		else v.CastShadow = false
		end
			for i = 0,5 do
				Utils:Create({"Texture", v}, {
					Face = i,
					Texture = TXT[#guys],
					StudsPerTileU = 4 * (v.Name == "Head" and 2 or 1),
					StudsPerTileV = 4 * (v.Name == "Head" and 2 or 1),
					ZIndex = 10
				})
			end
		Utils:Create({"NoCollisionConstraint", v}, {Part0 = v, Part1 = e})
		--if v.Name ~= "Head" and v.Name ~= "HumanoidRootPart" and v.Name ~= "Torso" then v.Name = "bob"; v.Parent = nil; task.wait(); v.Parent = rig end
	elseif v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then
		v:Destroy()
	end
end
Utils:Create({"Shirt", rig}, {ShirtTemplate = TXT[#guys]})
Utils:Create({"Pants", rig}, {PantsTemplate = TXT[#guys]})
table.insert(guys, rig)
-- yes give control .
local hum = rig.Humanoid
--hum.PlatformStand = true
hum.WalkSpeed = 0
hum.JumpPower = 0
local hed = rig.Head
hum.RequiresNeck = false; hed.Name = "hed"; hed.Parent = script

local gyr = Utils:Create({"BodyGyro", root}, {
	MaxTorque = Vector3.one * 100000,
	CFrame = CFrame.new(),
}); local push = Utils:Create({"BodyVelocity", root}, {
	MaxForce = Vector3.new(1, 0, 1) * 6000,
});

root.Touched:connect(function() end)

local spd = 15
local tspd = math.rad(2)
local fell = false
local pushed = false
local falltime = 0

local ra, la = rig["Right Arm"], rig["Left Arm"]
local rahb, lahb = ra.hb, la.hb
local rl, ll = rig["Right Leg"], rig["Left Leg"]

local rh, lh = rl.og, ll.og

local push2 = push:Clone(); push2.Parent = nil
push2.MaxForce = Vector3.one * 10000
local push3 = push:Clone(); push3.Parent = nil
push3.MaxForce = Vector3.one * 10000

local gyr2 = gyr:Clone(); gyr2.Parent = nil
local gyr3 = gyr:Clone(); gyr3.Parent = nil
local ok = 10500
gyr2.D = 5; gyr3.D = 5
gyr2.P = 1000; gyr3.P = 1000
gyr2.MaxTorque = Vector3.one * ok; gyr3.MaxTorque = Vector3.one * ok

local ori1 = Utils:Create({"AlignOrientation", nil}, {
	Mode = "OneAttachment",
	Attachment0 = rig.Torso["Right Hip"].Attachment1,
	Responsiveness = 100,
}); local ori2 = Utils:Create({"AlignOrientation", nil}, {
	Mode = "OneAttachment",
	Attachment0 = rig.Torso["Left Hip"].Attachment1,
	Responsiveness = 100,
})

for i,v in pairs (rig:children()) do if v:IsA("BasePart") then
	v.Touched:connect(function(hit)
		-- push hitbox
		if hit.Name == "smacka" then
			push.Velocity = hit.Velocity * 2 + (-root.Velocity * 2)
			pushed = true
			task.wait(1.5 + math.random())
			pushed = false
		end
	end)
end end

local life = 0
local c; c = game:service("RunService").Stepped:connect(function(_, dt)
	life = life + 1
	if not pcall(function() push.Parent = push.Parent end) then c:disconnect(); return end
	if hum.MoveDirection.magnitude > 0 then
		if hum.MoveDirection:Dot(root.CFrame.lookVector) > .45 then
			push.Velocity = push.Velocity:lerp(root.CFrame.lookVector * spd, .05 * 2 * dt * 60)
		elseif hum.MoveDirection:Dot(-root.CFrame.lookVector) > .45 then
			push.Velocity = push.Velocity:lerp(root.CFrame.lookVector * -spd, .05 * 2 * dt * 60)
		else
			push.Velocity = push.Velocity:lerp(Vector3.zero, .05)
		end
		
		if hum.MoveDirection:Dot(root.CFrame.rightVector) > .45 then
			gyr.CFrame = gyr.CFrame * CFrame.Angles(0, -tspd * dt * 60, 0)
		elseif hum.MoveDirection:Dot(-root.CFrame.rightVector) > .45 then
			gyr.CFrame = gyr.CFrame * CFrame.Angles(0, tspd * dt * 60, 0)
		end
	else
		push.Velocity = push.Velocity:lerp(Vector3.zero, .05 * 2)
	end
	if ((root.Velocity.y < -11 / 1.25 or root.Velocity.y > 11 / 1.25 and hum.FloorMaterial.Name ~= "Air") or (hum.FloorMaterial.Name == "Air" and not hum.PlatformStand)) or pushed then fell = true else task.wait(2) if not pushed then fell = false end end
	--ori1.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(math.cos(life / 4) * 180))
	ori1.CFrame = root.CFrame * CFrame.Angles(math.rad(90 * math.cos(life / 5)), 0, 0)
	ori2.CFrame = root.CFrame * CFrame.Angles(0, 0, -math.rad(math.cos(life / 4) * 180))
	if not fell and math.random(1, 15) == 1 then
	end; push2.Velocity = push2.Velocity:lerp(push.Velocity, .25)
		 push3.Velocity = push3.Velocity:lerp(push.Velocity, .25)
	
	if hum.Jump and not fell then
		--push2.Parent = ra
		--push3.Parent = la
		--ra.RotVelocity = root.CFrame.lookVector * 90
		--ra.RotVelocity = root.CFrame.lookVector * 90
		gyr2.Parent = ra
		gyr3.Parent = la
		--gyr2.CFrame = (root.CFrame - root.CFrame.p) * CFrame.Angles(0, 0, math.pi / 2)
		--gyr3.CFrame = (root.CFrame - root.CFrame.p) * CFrame.Angles(0, 0, math.pi / 2)
		gyr2.CFrame = gyr2.CFrame * CFrame.Angles(0, 0, -math.pi / 35)
		gyr3.CFrame = gyr3.CFrame * CFrame.Angles(0, 0, -math.pi / 35)
		rahb.Name = "smacka"
		lahb.Name = "smacka"
	else
		gyr2.Parent = nil; gyr2.CFrame = ra.CFrame
		gyr3.Parent = nil; gyr3.CFrame = la.CFrame
		push2.Parent = nil
		push3.Parent = nil
		if not fell then task.wait(1) end
		rahb.Name = "hb"
		lahb.Name = "hb"
	end
	ori1.Parent = nil; ori2.Parent = nil
	if fell then
		if rl:FindFirstChild("hb") and ll:FindFirstChild("hb") then rl.hb.CanCollide = true; ll.hb.CanCollide = true end
		if math.random(1, 2) == 1 and falltime < 5 and pushed then push.Velocity = -root.CFrame.lookVector * 25 * 1.5 + Vector3.new(0, 30); end
		task.delay(.3, function() push.Parent = nil end)
		hum.PlatformStand = true;
		gyr.Parent = nil; rh.Parent = nil; lh.Parent = nil
		local _, Y = root.CFrame:ToEulerAnglesYXZ()
		gyr.CFrame = CFrame.Angles(0, Y, 0)
		if #root:GetTouchingParts() > 0 or root.Position.y < (POS.y / 2) then falltime = falltime + 1 end
		--print(falltime)
		if math.random(1, 15) == 1 or falltime < 2 and pushed then ori1.Parent = rl; ori2.Parent = ll; ori1.CFrame = CFrame.Angles(0, -Y / 2, 0); ori2.CFrame = CFrame.Angles(0, -Y, 0) end
	else
		if rl:FindFirstChild("hb") and ll:FindFirstChild("hb") then rl.hb.CanCollide = false; ll.hb.CanCollide = false end
		falltime = math.clamp(falltime - .75, 0, math.huge)
		push.Parent = root; hum.PlatformStand = false; gyr.Parent = root; rh.Parent = rl; lh.Parent = ll
	end
	if rig:GetAttribute("newround") then falltime = 0; fell = false; rig:SetAttribute("newround", nil) end
	if falltime > 225 * 1.5 then -- death
		--print("guy died", rig)
		rig:SetAttribute("dead", true)
    rahb.Name = "hb"
		lahb.Name = "hb"
		if rig:FindFirstChild("Torso") then root.Anchored = true; ra.Anchored = true; la.Anchored = true; rl.Anchored = true; ll.Anchored = true end
	end; if not rig:GetAttribute("dead") and rig:FindFirstChild("Torso") then root.Anchored = false; ra.Anchored = false; la.Anchored = false; rl.Anchored = false; ll.Anchored = false end
end)
NLS([[
print("Space to attack.")
local H = script.Parent.HumanoidRootPart
local ANG = CFrame.new()
game:service("RunService").Stepped:connect(function(_, dt)
	if not H.Parent:GetAttribute("dead") then
		local _, Y = H.CFrame:ToEulerAnglesYXZ()
		ANG = ANG:lerp(CFrame.Angles(0, Y, 0), .3 * dt * 60)
		workspace.CurrentCamera.CameraType = "Scriptable"
		workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:lerp((ANG + H.CFrame.p) * CFrame.new(0, 7, 11) * CFrame.Angles(-math.pi / 8, 0, 0), .7 * dt * 60)
	else
		workspace.CurrentCamera.CameraType = "Custom"
		workspace.CurrentCamera.CameraSubject = H
	end
end)]], rig)
end; return sumoman
end