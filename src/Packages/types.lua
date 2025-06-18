local butil = require("pkg/byteUtil")
local BrickColors = {}
for i = 1, 1032 do
    local BrickColorValue = BrickColor.new(i)
    if not table.find(BrickColors, BrickColorValue) then
        table.insert(BrickColors, BrickColorValue)
    end
end
local function double(val)
    if typeof(val)=="string" then
        return string.unpack("<d", val)
    elseif typeof(val)=="number" then
        return string.pack("<d", val)
    end
end
local function vect3Encode(val: Vector3)
    return double(val.X)..double(val.Y)..double(val.Z)
end
local function boolean(val : boolean)
    if val==true then
        return '\1'
    else
        return '\0'
    end
end
local function str(val)
    return butil.toBytes(string.len(val),2)..val
end
local function color3Encode(val)
    return double(val.R)..double(val.G)..double(val.B)
end
return {
    encode = {
            str,
            boolean,
            (function(val : number)
                return double(val)
            end),
            (function(val : CFrame)
                return double(val.X)..double(val.Y)..double(val.Z)..vect3Encode(val.XVector)..vect3Encode(val.YVector)..vect3Encode(val.ZVector)
            end),
            vect3Encode,
            (function(val : Vector2)
                return double(val.X)..double(val.Y)
            end),
            (function(val : UDim2)
                return double(val.X.Scale)..double(val.Y.Scale)..double(val.X.Offset)..double(val.Y.Offset)
            end),
            (function(val : UDim)
                return double(val.Scale)..double(val.Offset)
            end),
            (function(val : Ray)
                return vect3Encode(val.Origin)..vect3Encode(val.Direction)
            end),
            (function(val : BrickColor)
                return butil.toBytes(table.find(BrickColors, val),1)
            end),
            (function(val : Axes)
                return boolean(val.X)..boolean(val.Y)..boolean(val.Z)..boolean(val.Top)..boolean(val.Bottom)..boolean(val.Left)..boolean(val.Right)..boolean(val.Back)..boolean(val.Front)
            end),
            color3Encode,
            (function(val : EnumItem)
                return butil.toBytes(val.Value,2)
            end),
            (function(val, toId) -- Content
                return butil.toBytes(val.SourceType.Value,2)..str(val.Uri)..(toId[val.Object] or '\0')
            end),
            (function(val : ColorSequence)
                local len = #val.Keypoints
                local encodedKeypoints = ""
                for i,keypoint in pairs(val.Keypoints) do
                    encodedKeypoints = encodedKeypoints..double(keypoint.Time)..color3Encode(keypoint.Value)
                end
                return butil.toBytes(len,2)..encodedKeypoints
            end),
            (function(val : NumberSequence)
                local len = #val.Keypoints
                local encodedKeypoints = ""
                for i,keypoint in pairs(val.Keypoints) do
                    encodedKeypoints = encodedKeypoints..double(keypoint.Time)..double(keypoint.Value)..double(keypoint.Envelope)
                end
                return butil.toBytes(len,2)..encodedKeypoints
            end),
            nil, -- Instance
            (function(val : PhysicalProperties)
                return double(val.Density)..double(val.Friction)..double(val.Elasticity)..double(val.FrictionWeight)..double(val.ElasticityWeight)
            end),
            (function(val : NumberRange)
                return double(val.Min)..double(val.Max)
            end),
            (function(val : Font, toId)
                local family = val.Family
                if typeof(family)=="string" then
                    return butil.toBytes(Enum.ContentSourceType.Uri.Value,2)..str(family)..(toId[family.Object] or '\0')..-- Content
                butil.toBytes(val.Weight.Value,2).. -- Weight
                butil.toBytes(val.Style.Value,2).. -- Style
                boolean(val.Bold) -- Bold
                else
                    return butil.toBytes(family.SourceType.Value,2)..str(family.Uri)..(toId[family.Object] or '\0')..-- Content
                    butil.toBytes(val.Weight.Value,2).. -- Weight
                    butil.toBytes(val.Style.Value,2).. -- Style
                    boolean(val.Bold) -- Bold
                end
            end)
    },
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