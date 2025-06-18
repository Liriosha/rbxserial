local bufferReader = require("pkg/bufferreader")
local b64 = require("pkg/base64")
local BrickColors = {}
for i = 1, 1032 do
    local BrickColorValue = BrickColor.new(i)
    if not table.find(BrickColors, BrickColorValue) then
        table.insert(BrickColors, BrickColorValue)
    end
end
local basicTypes = {
    decode = {
        (function(data)
            return data:readString()
        end),
        (function(data)
            return data:readBytes(1) == '\1'
        end),
        (function(data)
            return data:readDouble()
        end),
        (function(data)
            local x = data:readDouble()
            local y = data:readDouble()
            local z = data:readDouble()
            local xv = Vector3.new(data:readDouble(), data:readDouble(), data:readDouble())
            local yv = Vector3.new(data:readDouble(), data:readDouble(), data:readDouble())
            local zv = Vector3.new(data:readDouble(), data:readDouble(), data:readDouble())
            return CFrame.fromMatrix(Vector3.new(x, y, z), xv, yv, zv)
        end),
        (function(data)
            return Vector3.new(data:readDouble(), data:readDouble(), data:readDouble())
        end),
        (function(data)
            return Vector2.new(data:readDouble(), data:readDouble())
        end),
        (function(data)
            local xScale = data:readDouble()
            local yScale = data:readDouble()
            local xOffset = data:readDouble()
            local yOffset = data:readDouble()
            return UDim2.new(xScale, xOffset, yScale, yOffset)
        end),
        (function(data)
            return UDim.new(data:readDouble(), data:readDouble())
        end),
        (function(data)
            local origin = Vector3.new(data:readDouble(), data:readDouble(), data:readDouble())
            local dir = Vector3.new(data:readDouble(), data:readDouble(), data:readDouble())
            return Ray.new(origin, dir)
        end),
        (function(data)
            return BrickColors[data:readu8()]
        end),
        (function(data)
            return Axes.new(
                data:readBytes(1) == '\1',
                data:readBytes(1) == '\1',
                data:readBytes(1) == '\1',
                data:readBytes(1) == '\1',
                data:readBytes(1) == '\1',
                data:readBytes(1) == '\1',
                data:readBytes(1) == '\1',
                data:readBytes(1) == '\1',
                data:readBytes(1) == '\1'
            )
        end),
        (function(data)
            local r = data:readDouble()
            local g = data:readDouble()
            local b = data:readDouble()
            return Color3.new(r, g, b)
        end),
        (function(data)
            return data:readu16()
        end),
        (function(data, fromId) -- Content
            local sourceType = data:readu16()
            local uri = data:readString()
            local objId = data:readBytes(1)
            if sourceType==Enum.ContentSourceType.Uri.Value then
                return Content.fromUri(uri)
            elseif sourceType==Enum.ContentSourceType.Object then
                return nil -- Adding later
            elseif sourceType==Enum.ContentSourceType.None then
                return Content.None
            end
        end),
        (function(data) -- ColorSequence
            local tableLength = data:readu16()
            local colorTable = table.create(tableLength)
            for i=1,tableLength do
                colorTable[i]=ColorSequenceKeypoint.new(data:readDouble(),Color3.new(data:readDouble(),data:readDouble(),data:readDouble()))
            end
            return ColorSequence.new(colorTable)
        end),
        (function(data) -- NumberSequence
            local tableLength = data:readu16()
            local numberTable = table.create(tableLength)
            for i=1,tableLength do
                numberTable[i]=NumberSequenceKeypoint.new(data:readDouble(),data:readDouble(),data:readDouble())
            end
            return NumberSequence.new(numberTable)
        end),
        nil, -- Instance
        (function(data)
            return PhysicalProperties.new(data:readDouble(),data:readDouble(),data:readDouble(),data:readDouble(),data:readDouble())
        end),
        (function(data)
            return NumberRange.new(data:readDouble(),data:readDouble())
        end),
        (function(data) -- Font
            local sourceType = data:readu16()
            local uri = data:readString()
            local objId = data:readBytes(1)
            local family
            if sourceType==Enum.ContentSourceType.Uri.Value then
                family=uri
            elseif sourceType==Enum.ContentSourceType.Object then
                return nil -- Adding later
            elseif sourceType==Enum.ContentSourceType.None then
                family=Content.None
            end
            local weight = data:readu16()
            local style = data:readu16()
            local bold = data:readu8()==1
            local f = Font.new(family,Enum.FontWeight:FromValue(weight),Enum.FontStyle:FromValue(style))
            f.Bold=bold
            return f
        end)
    }
}
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

    for _, inst in ipairs(instances) do
        for name, ref in pairs(inst.references) do
            if ref and instances[ref] then
                inst.self.Properties[name] = instances[ref].self
            end
        end
    end

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
return deserialize