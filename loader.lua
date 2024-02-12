-- TODO: parsing it as text and stuff is bad. convert it to lua code and use loadstring with a sandbox)
-- i will sumo you: --
local owner = owner
----------------------
-- Services
local TweenS = game:service("TweenService")
-------------
-- UTILS --
local Utils = {}
function Utils:Create(InstData, Props)
	local Obj = Instance.new(InstData[1], InstData[2])
	for k, v in pairs (Props) do
		Obj[k] = v
	end; return Obj
end
function Utils:CNR(cf) -- CFrameNoRotate
	return CFrame.new(cf.x,cf.y,cf.z)
end
-- LEGACY FUNCTIONS WITH ADDED FEATURES
function Utils:ezweld(p, a, b, cf, c1)
	local weld = Instance.new("Weld",p)
	weld.Part0 = a
	weld.Part1 = b
	weld.C0 = cf
	if c1 then weld.C1 = c1 end
    return weld
end
function Utils:NewSound(p, id, pit, vol, loop, autoplay)
	local Sound = Instance.new("Sound",p)
    Sound.Pitch = pit
    Sound.Volume = vol
    Sound.SoundId = "rbxassetid://" ..id
    Sound.Looped = loop
	if autoplay then
    	Sound:Play()
	end
    return Sound
end
-----------

local Engine = {}
function Engine:RemoveWS(str)
	str = string.gsub(str, [[

]], "/n") -- exclude line breaks from whitespace
	str = string.gsub(str, "%s+", " ") -- change whitespace to only one space
	return string.gsub(str, "/n", [[;]])
end

function Engine:LegacyLoad(file, offs)
	file = self:RemoveWS(file)

	local lines = string.split(file, [[;]])
	local vars = {}
	local funcs = {}
	
	local function parseline(i, v)
		local funcspace = string.split(v, "(")
		if funcspace[1] == "man" then
			local sfind = string.find(v, "%(")
			
			local ended = false
			local count = 1
			
			local restofstring = v:sub(sfind or 1)
			local paramsplit = string.split(restofstring, ",")
			if paramsplit and paramsplit[1] and paramsplit[2] and paramsplit[3] then
				-- cool BAD method of getting the numbers
				-- this could be so much better but i dont feel like making it better
				local pos1 = Vector3.new(paramsplit[1]:sub(6), paramsplit[2], paramsplit[3]:sub(1, #paramsplit[3]-1))
				--table.insert(data.man, pos1)
				local rig = Utils:Create({"Part", script}, {
					Anchored = true,
					Position = pos1 + offs,
				});
			end
		end
		if funcspace[1] == "repeat" then
			--table.insert(data.repeats, {repeats = tonumber(funcspace[2]:sub(1, #funcspace[2]-1))})
			local pos2 = string.find(funcspace[2], "%)")
			if not pos2 then return end
			local rpcount = tonumber(funcspace[2]:sub(1, pos2-1))
			--print(rpcount, funcspace[2]:sub(1, #funcspace[2]-1))
			for _ = 1,rpcount do
				local endof = i+1
				local search = true
				while search do
					if string.find(lines[endof], "}") then
						search = false
					else
						parseline(endof, lines[endof])
					end
					endof += 1
					task.wait()
				end
			end
		end
		local varspace = string.split(v, "=")
		local hasvar = string.match(v, "=")
		if varspace and hasvar and varspace[1] and varspace[2] then
			--[==[
			print(varspace[1], "|", varspace[2], varspace[2] == nil, #varspace[2])
			local returned = loadstring(varspace[1] .." = " ..varspace[2]); print(returned)
			local sb = getfenv(returned)
			for k,v in pairs (vars) do
				sb[k] = v
			end
			
			returned = returned()
			vars[varspace[1]] = returned
			]==]
			--vars[varspace[1]] = varspace[2]
			local pos2 = string.find(funcspace[2], "%)")
			if not pos2 then return end
			local rpcount = tonumber(funcspace[2]:sub(1, pos2-1))
			--print(rpcount, funcspace[2]:sub(1, #funcspace[2]-1))
			for _ = 1,rpcount do
				local endof = i+1
				local search = true
				while search do
					if string.find(lines[endof], "}") then
						search = false
					else
						parseline(endof, lines[endof])
					end
					endof += 1
					task.wait(.125)
				end
			end
		end
	end
	for i,v in pairs (lines) do
		parseline(i, v)
	end
end

Engine.TXT = {
	[0] = "rbxassetid://9828209752",
	[1] = "rbxassetid://9828209363",
	[2] = "rbxassetid://9828208936",
	[3] = "rbxassetid://9828208245",
	[4] = "rbxassetid://9828206183",
	[5] = "rbxassetid://9828206183",
	[6] = "rbxassetid://9828206183",
	[7] = "rbxassetid://9828206183",
	[8] = "rbxassetid://9828206183",
	[9] = "rbxassetid://9828205891",
	[10] = "rbxassetid://9828205443",
}
function Engine:Load(file, theoffsetya, paren)
	file = self:RemoveWS(file)
	file = string.gsub(file, ";", [[

]])
	
	local lines = string.split(file, [[

]])
	local function parseline(v)
		v = string.gsub(v, "vec", "Vector3.new")
		v = string.gsub(v, "}", "end")
		local foundrepeat = string.match(v, "repeat")
		if foundrepeat then
			v = string.gsub(v, "{", " do")
		end
		v = string.gsub(v, "repeat", "for i = 1,")
		v ..= [[

]]
		
		local foundfunc = string.match(v, "={")
		if foundfunc then
			v = v:sub(1, #v-3) ..[[

]]
			v = string.gsub(v, "=", "")
			v = "function " ..v
		else
			local foundvar = string.match(v, "=")
			local foundrepeat = string.match(v, "for i = 1,")
			local oknextchars = {"+", "-", "/", "*", " "}
			if foundvar and not foundrepeat then
				local split = string.split(v, "=")
				if split[2] then
					local findpos = string.find(v, split[2])
					local operator
					if findpos then
						operator = v:sub(#split[2]+findpos)
					else
						operator = ""
					end
					--if not string.match(split[2], split[1]) then
					if true then
						local isok = true
						for i,v in pairs (oknextchars) do
							if string.find(split[2], v) then
								isok = false
							end
						end
						if isok then
							v = "local " ..v
						end
					end
				end
			end
		end
		return v
	end
	
	local newfile = [==[
-- add base
local ignorethis = addbox(Vector3.new(100,1,100),Vector3.new(0,-10.5,0),1,1)
-- add song
--[[
local ignoresong = Instance.new("Sound", ignorethis)
ignoresong.SoundId = "rbxasset://sounds/sumotoridreams.mp3"
ignoresong.Volume = 8
ignoresong.Looped = true
ignoresong:Play()
]]
-- rest of stuff

]==]
	for k,v in pairs (lines) do
		lines[k] = parseline(v)
		newfile ..= lines[k]
		--print(k, "|", lines[k]); task.wait()
	end
	
	-- run lua convert with a sandbox
	--print(newfile)
	local luasumo, err = loadstring(newfile)
	local sb = getfenv(luasumo)
	
	local lastbox
	local mapmodel = paren or Instance.new("Model")
	
	local men = 0
	
	local function breakingcut(box, norm, dist)
		norm = Vector3.new(-norm.x, -norm.y, -norm.z)
		local oldpos = box.Position; box.Position = Vector3.zero
		local cut = Utils:Create({"SpawnLocation"}, {
			Size = Vector3.new(1000 / 4, 100 / 2, 1000 / 4),
			CFrame = CFrame.new(box.CFrame.p, box.CFrame.p+(norm)),
			Anchored = true,
			Transparency = 1,
			CanCollide = false,
			Enabled = false,
		}); --cut.Position = cut.CFrame.lookVector * (dist + (cut.Size.y / 2))
		
		local wasanchored = box.Anchored
		box.Anchored = true; box.Parent = script
		
		if norm.x ~= 0 or norm.z ~= 0 or true then
			--cut.CFrame *= CFrame.Angles(0, math.pi/2, 0)
			--cut.Orientation += Vector3.new(0, -180*0, 0)
			--cut.CFrame *= CFrame.Angles(-math.pi/2, 0, 0)
			--cut.CFrame *= CFrame.Angles(-math.pi/2, 0, 0)
			--cut.CFrame *= CFrame.Angles(0, 0, math.pi)
			cut.Orientation = Vector3.new(cut.Orientation.X, cut.Orientation.y, cut.Orientation.z)
			cut.Orientation += Vector3.new(90, 0, 0)
			cut.CFrame *= CFrame.Angles(0, 0, 0)
		end
		
		cut.Position -= cut.CFrame.upVector * ((cut.Size.y / 2) - (dist / 2))
		local newblock = box:SubtractAsync({cut})
		if newblock then
			newblock.Parent = mapmodel
			newblock.Anchored = wasanchored
			newblock.Position = oldpos
			newblock.Velocity = box.Velocity
			for i,v in pairs (box:children()) do
				if not v:IsA("TouchTransmitter") then
					v.Parent = newblock
				end
			end
			box:Destroy(); cut:Destroy()
		else
			return box
		end
		return newblock
	end
	
	sb.man = function(pos1)
		men += 1
		local rig = Utils:Create({"SpawnLocation", mapmodel}, {
			Anchored = true,
			Position = (pos1 / 2) + theoffsetya + (Vector3.one * 2),
			Enabled = false,
			CanCollide = false,
			Name = "spawn" ..tostring(men)
		}); return rig
	end
	sb.addbox = function(size, pos, txt, phys)
		-- fix props
		pos = pos / 2
		if tonumber(size) then
			size = Vector3.one * size
		end
		if tonumber(pos) then
			pos = Vector3.one * pos
		end
		-- create
		local box = Utils:Create({"SpawnLocation", mapmodel}, {
			Size = size,
			Position = pos + theoffsetya,
			Anchored = true,
			Enabled = false
		}); lastbox = box
		-- texture
		local tex = self.TXT[txt]
		if tex then
			local faces = {"Top", "Bottom", "Left", "Right", "Front", "Back"}
			for i,v in pairs (faces) do
				Utils:Create({"Texture", box}, {
					Face = v,
					Texture = tex,
					StudsPerTileU = 4,
					StudsPerTileV = 4,
				})
			end
		end;
		-- physics
		if phys == 0 then
			box.Anchored = false
		end
		task.wait()
		return box
	end
	sb.turnto = function(rot)
		rot = Vector3.new(-rot.x, rot.y, -rot.z)
		--lastbox.CFrame = CFrame.Angles(rot.x, rot.y, rot.z)
		lastbox.CFrame = CFrame.new(lastbox.CFrame.p, lastbox.CFrame.p+rot)
	end
	sb.rot = function(a, b)
		--[[
		if typeof(a) == "Vector3" then
			a = CFrame.new(a)
		end
		return a * CFrame.Angles(b.x, b.y, b.z)
		]]
		--print(a, "<-- rotate by")
		--local cf = (CFrame.new(lastbox.CFrame.p, lastbox.CFrame.p+a) * CFrame.Angles(b.x, b.y, b.z))
		--[[
		local cf = (CFrame.new(lastbox.CFrame.p+a, lastbox.CFrame.p+b))
		local ANX, ANY, ANZ = cf:ToEulerAnglesYXZ()
		--print(cf.LookVector)
		return cf.LookVector, Vector3.new(ANX, ANY, ANZ)
		]]
		--lastbox.CFrame = CFrame.new(a, a+b)
		--return CFrame.new(a, a+b).lookVector
		if typeof(a) == "function" then
			a = a()
		end; if typeof(b) == "function" then
			b = b()
		end
		local funced = function() return CFrame.new(a, a+b).lookVector end
		return funced()
	end
	sb.breakability = function(breaks)
		local breaking = 0
		local box = lastbox
		local connect; connect = box.Touched:connect(function(hit)
			if hit and not hit.Anchored and (hit.Velocity.magnitude > (20 / 4)) or box.Velocity.magnitude > (10 / 2) then
				breaking += (2 + (hit.Velocity.magnitude * 2.25))
				if (325-breaking) < breaks then
					connect:disconnect()
					for i = 1,7 do
						local clone = box:Clone()
						clone.Size = box.Size / 3
						--clone = breakingcut(clone, Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)), math.random(-2, 2))
						--clone.Orientation += Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
						clone.Position += Vector3.new(math.random(-1, 1) * box.Size.magnitude / 3, 2, math.random(-1, 1) * box.Size.magnitude / 3)
						clone.Parent = mapmodel
						clone.Anchored = false
						local colcheck = Utils:Create({"Part"}, {
							CFrame = clone.CFrame,
							Size = clone.Size - (Vector3.one * .05),
						}); if #colcheck:GetTouchingParts() > 0 or true then
							clone.Velocity += hit.Velocity + clone.CFrame.upVector * math.random(50, 200) / 2
							game.Debris:AddItem(clone, 3); box.Velocity = clone.Velocity
						end
					end; task.wait(.05); box:Destroy()
					--local debri = breakingcut(box, Vector3.new(1, 1, 1), 0); debri.CanCollide = false; debri.Anchored = false
					--local debri = breakingcut(debri, Vector3.new(-1, -1, -1), 0); debri.CanCollide = false; debri.Anchored = false
				end
			end
		end)
	end
	sb.cutplane = function(norm, dist)
		if typeof(norm) == "function" then
			norm = norm()
		end
		--[[
		local part2 = Utils:Create({"Part", script}, {
			Size = Vector3.new(1000, 1000, 0),
			--CFrame = CFrame.new(lastbox.CFrame.p, lastbox.CFrame.p + Vector3.new(norm.x, norm.y, norm.z)),
			CFrame = lastbox.CFrame * CFrame.Angles(0, norm.x, 0),
			Position = lastbox.CFrame.p,
			Anchored = true,
			Transparency = .75,
			--Orientation = Vector3.new(norm.x, 0, norm.z),
		})
		
		local cut = Utils:Create({"Part", script}, {
			Size = Vector3.new(1000 / 35, 10, 1000 / 35),
			CFrame = CFrame.new(lastbox.CFrame.p, lastbox.CFrame.p+(norm)),
			Anchored = true,
			Transparency = .5,
			CanCollide = false,
		}); --cut.Position = cut.CFrame.lookVector * (dist + (cut.Size.y / 2))
		
		if norm.x ~= 0 or norm.z ~= 0 or true then
			cut.Orientation += Vector3.new(0, -90, 0)
			cut.CFrame *= CFrame.Angles(-math.pi, 0, 0)
			cut.CFrame *= CFrame.Angles(-math.pi/2, 0, 0)
		end
		
		cut.Position += cut.CFrame.upVector * ((cut.Size.y / 2) - (dist / 2))
		
		local newblock = lastbox:SubtractAsync({cut})
		if newblock then
			newblock.Parent = script
			newblock.Position = lastbox.Position
		end
		lastbox:Destroy(); --cut:Destroy()
		]]
		norm = Vector3.new(-norm.x, -norm.y, -norm.z)
		local cut = Utils:Create({"SpawnLocation"}, {
			Size = Vector3.new(1000*100, 100*100, 1000*100),
			CFrame = CFrame.new(lastbox.CFrame.p, lastbox.CFrame.p+(norm)),
			Anchored = true,
			Transparency = 1,
			CanCollide = false,
			Enabled = false,
		}); --cut.Position = cut.CFrame.lookVector * (dist + (cut.Size.y / 2))
		
		local wasanchored = lastbox.Anchored
		lastbox.Anchored = true; lastbox.Parent = script
		
		if norm.x ~= 0 or norm.z ~= 0 or true then
			--cut.CFrame *= CFrame.Angles(0, math.pi/2, 0)
			--cut.Orientation += Vector3.new(0, -180*0, 0)
			--cut.CFrame *= CFrame.Angles(-math.pi/2, 0, 0)
			--cut.CFrame *= CFrame.Angles(-math.pi/2, 0, 0)
			--cut.CFrame *= CFrame.Angles(0, 0, math.pi)
			cut.Orientation = Vector3.new(cut.Orientation.X, cut.Orientation.y, cut.Orientation.z)
			cut.Orientation += Vector3.new(90, 0, 0)
			cut.CFrame *= CFrame.Angles(0, 0, 0)
		end
		
		cut.Position -= cut.CFrame.upVector * ((cut.Size.y / 2) - (dist / 2))
		
		local newblock = lastbox:SubtractAsync({cut})
		cut.Parent = nil; lastbox.Parent = nil
		if newblock then
			newblock.Parent = mapmodel
			newblock.Anchored = wasanchored
			newblock.Position = lastbox.Position
			for i,v in pairs (lastbox:children()) do
				if not v:IsA("TouchTransmitter") then
					v.Parent = newblock
				end
			end
		end
		lastbox:Destroy(); cut:Destroy(); lastbox = newblock
	end
	sb.pi = math.pi
	--
	local returning = luasumo()
	mapmodel.Parent = script
	return returning, mapmodel
end

return Engine