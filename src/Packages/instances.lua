local function getProperties()
	local HttpService = game:GetService("HttpService")
	local API = HttpService:JSONDecode(HttpService:GetAsync("https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.json", true))
	local ApiTable = {}
	for i, v in pairs(API["Classes"]) do
		local Class = v["Name"]
		ApiTable[Class] = {
			Superclass = v["Superclass"],
			Properties = {},
		}
		for j, member in pairs(v["Members"]) do
			if member["MemberType"] == "Property" then
				if member["Tags"] and (table.find(member["Tags"],"ReadOnly") or table.find(member["Tags"],"Deprecated") or table.find(member["Tags"],"NotScriptable")) then continue end
				ApiTable[Class].Properties[member["Name"]] = true
			end
		end
	end
	local function getProperties(className)
		local propertyNames = {}
		local function addProperties(class)
			for propName in pairs(ApiTable[class].Properties) do
				table.insert(propertyNames,propName)
			end
		end
		local currentClass = className
		while currentClass do
			if ApiTable[currentClass] then
				addProperties(currentClass)
				currentClass = ApiTable[currentClass].Superclass
			else
				currentClass = nil
			end
		end
		return propertyNames
	end
	return getProperties
end
local getProperties = getProperties()
local function readProps(ins)
	local class = ins.ClassName
	local defaults = Instance.new(class)
	local props = getProperties(class)
	local ret = {}
	for i,prop in pairs(props) do
		pcall(function()
			local val = ins[prop]
			local default = defaults[prop]
			if val==default then return end
			ret[prop]=ins[prop]
		end)
	end
	return ret
end
local function instanceToTable(ins)
	if ins:IsA("LuaSourceContainer") then
		warn(ins.Name.." is a non-supported instance, skipping")
		return
	elseif ins:IsA("TouchTransmitter") then
		warn(ins.Name.." is a non-supported instance, skipping")
		return
	end
	local data = {
        realInst = ins,
		ClassName = ins.ClassName,
		Name = ins.Name,
		Properties = readProps(ins),
		Children = {}
	}

	for _, child in ipairs(ins:GetChildren()) do
		local ch = instanceToTable(child)
		if ch~=nil then
			table.insert(data.Children,ch)
		end
	end

	return data
end
return instanceToTable