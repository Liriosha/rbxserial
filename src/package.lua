local DEBUG = DEBUG or false -- Silence the warnings
local toTable = require("pkg/instances")
local b64 = require("pkg/base64")
local butil = require("pkg/byteUtil")
local basicTypes = require("pkg/types")
local bufferReader = require("pkg/bufferreader")
local http = game:GetService("HttpService")
local serializeTable = {
    "string",
    "boolean",
    "number",
    "CFrame",
    "Vector3",
    "Vector2",
    "UDim2",
    "UDim",
    "Ray",
    "BrickColor",
    "Axes",
    "Color3",
    "EnumItem",
    "Content",
    "ColorSequence",
    "NumberSequence",
    "Instance",
    "PhysicalProperties",
    "NumberRange",
    "Font"
}
function combineValues(list)
    local counts = {}
    for _, value in ipairs(list) do
        counts[value] = (counts[value] or 0) + 1
    end

    local result = {}
    for value, count in pairs(counts) do
        table.insert(result, {value, count})
    end

    return result
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function serialize(ins,metadata)
    print("Serialization began")
    local magic = "rbxSerial\0\0\0\0"
    local instanceTable = toTable(ins)
    local instances = {}
    local instanceToId = {} -- Maps instance object to ID
    table.insert(instances, instanceTable["ClassName"])
    local recursive
    recursive = function(inst)
        for _, v in ipairs(inst.Children) do
            table.insert(instances, v.ClassName)
            recursive(v)
        end
    end
    recursive(instanceTable)
    table.sort(instances, function(a, b)
        return a < b
    end)

    --[[
        Step 1, Instance chunk
            "I"
                Table length (32 bits)
                Amount of class (32 bits)
                String len (16 bits)
                Class name
    ]]
    instances = combineValues(instances)
    table.sort(instances, function(a, b)
        return a[1] < b[1]
    end)
    local instChunk = butil.toBytes(#instances, 4)
    for _, class in ipairs(instances) do
        instChunk = instChunk .. butil.toBytes(class[2], 4) .. butil.toBytes(#class[1], 2) .. class[1]
    end
    instChunk = "I".. instChunk

    --[[
        Step 2, Property chunk
            "P"
            Table length (32 bits)
                ID of instance (32 bits)
                Table length of properties (32 bits)
                (FOR EACH)
                    String len (16 bits)
                    Property name
                    (SERIALIZED VALUE)
    ]]
    local propTable = {}
    local id = 0
    recursive = function(inst)
        id += 1
        propTable[id] = {}
        propTable[id].ClassName=inst.ClassName
        propTable[id].real = inst.realInst
        instanceToId[inst.realInst] = id
        for name, value in pairs(inst.Properties) do
            propTable[id][name] = value
        end
        for _, child in pairs(inst.Children) do
            recursive(child)
        end
    end
    recursive(instanceTable)
    table.sort(propTable, function(a, b)
        return a.ClassName < b.ClassName
    end)
    for i,v in pairs(propTable) do
        instanceToId[v.real]=i
    end
    -- Serialize our properties
    for instanceId, props in pairs(propTable) do
        for name, value in pairs(props) do
            local t = typeof(value)
            if t=="Instance" then
                local refId = instanceToId[value]
                if refId then
                    props[name] = "\17"..butil.toBytes(refId,4)
                else
                    props[name] = "\0"
                end
            else
                local pos = table.find(serializeTable,t)
                if not pos then warn("Unknown value type "..t) else
                    props[name] = butil.toBytes(pos,1)..basicTypes.encode[pos](value,instanceToId)
                end
            end
        end
    end
    local propChunk=butil.toBytes(#propTable,4)
    for instanceId,properties in ipairs(propTable) do
        propChunk=propChunk..butil.toBytes(instanceId,4)..butil.toBytes(tablelength(properties)-2,4)
        for name,value in pairs(properties) do
            if name=="ClassName" or name=="real" then continue end
            propChunk=propChunk..butil.toBytes(string.len(name),2)..name..value
        end
    end
    local propChunk="P"..propChunk
    local data = magic..instChunk..propChunk.."E" -- E is end
    data = http:JSONEncode(buffer.fromstring(data))
    print("✅ Serialization complete!")
    return data:match('"zbase64"%s*:%s*"([^"]+)"')
end
local InsertService = game:GetService("InsertService")
local function deserializeToTree(data)
    data = bufferReader.new(b64.decode(data))
    if data:readBytes(13) ~= "rbxSerial\0\0\0\0" then
        error("Incorrect data format")
    end

    local nilInstances = {}
    local instances = {}

    while true do
        local chunkType = data:readBytes(1)
        if chunkType == "I" then
            local tableLength = data:readu32()
            for i = 1, tableLength do
                local amt = data:readu32()
                local name = data:readString()
                for j = 1, amt do
                    table.insert(instances, {
                        references = {},
                        self = {
                            ClassName = name,
                            Properties = {},
                            Children = {},
                        },
                    })
                end
            end
        elseif chunkType == "P" then
            local tableLength = data:readu32()
            for i = 1, tableLength do
                local inst = instances[data:readu32()]
                local propLength = data:readu32()
                for j = 1, propLength do
                    local name = data:readString()
                    local t = data:readu8()
                    if t == 17 then
                        local id = data:readu32()
                        inst.references[name] = id
                    elseif t == 0 then
                        inst.self.Properties[name] = nil
                    else
                        local res = basicTypes.decode[t](data)
                        inst.self.Properties[name] = res
                    end
                end
            end
        elseif chunkType == "E" then
            break
        end
    end

    -- Resolve references (e.g., Parent, ObjectValue)
    for _, inst in ipairs(instances) do
        for name, ref in pairs(inst.references) do
            if ref and instances[ref] then
                inst.self.Properties[name] = instances[ref].self
            end
        end
    end

    -- Build parent-child relationships
    for _, inst in ipairs(instances) do
        local parent = inst.self.Properties["Parent"]
        if parent then
            table.insert(parent.Children, inst.self)
        else
            table.insert(nilInstances, inst.self)
        end
    end

    return nilInstances
end
local function createTree(tree)
    local nodeToInstance = {}

    local function createInstance(node)
        local className = node.ClassName
        local inst

        if className == "MeshPart" and node.Properties.MeshId then
            local meshId = node.Properties.MeshId
            local colFid = node.Properties.CollisionFidelity or Enum.CollisionFidelity.Default
            local rendFid = node.Properties.RenderFidelity or Enum.RenderFidelity.Automatic
            -- Clear out the properties we have covered
            node.Properties.MeshId=nil
            node.Properties.CollisionFidelity=nil
            node.Properties.RenderFidelity = nil
            inst = InsertService:CreateMeshPartAsync(meshId, colFid, rendFid)
        else
            inst = Instance.new(className)
        end

        nodeToInstance[node] = inst

        for key, value in pairs(node.Properties) do
            if key ~= "Parent" then
                if typeof(value) == "table" and value.ClassName then
                    inst[key] = nil
                else
                    if key == "Transparency" and (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then
                    else
                        pcall(function() inst[key] = value end)
                    end
                end
            end
        end

        for _, childNode in ipairs(node.Children) do
            local childInstance = createInstance(childNode)
            childInstance.Parent = inst
        end

        return inst
    end

    local roots = {}
    for _, node in ipairs(tree) do
        table.insert(roots, createInstance(node))
    end

    for node, inst in pairs(nodeToInstance) do
        for key, value in pairs(node.Properties) do
            if typeof(value) == "table" and value.ClassName then
                local refInst = nodeToInstance[value]
                if refInst then
                    pcall(function() inst[key] = refInst end)
                end
            end
        end
    end

    return roots
end
local function deserialize(data)
    local tree = deserializeToTree(data)
    return createTree(tree)
end
local HttpService = game:GetService("HttpService")
function upload(text)
	local hastebinUrl = "https://backend.ianhon.com/hastebin/create"
	local data = {
		signature = "",
		content = {{"main", text}}
	}
	local jsonData = HttpService:JSONEncode(data)
	local response
	local success, errorMessage = pcall(function()
		response = HttpService:PostAsync(hastebinUrl, jsonData, Enum.HttpContentType.ApplicationJson)
	end)
	if not success then
		warn("Error posting to Hastebin: " .. errorMessage)
		return
	end
	print("Posted successfully! Response: " .. response)
end
return {
    serialize=serialize,
    deserialize=deserialize,
    upload=upload
}