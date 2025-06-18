local __DLBUNDLE __DLBUNDLE={cache={},load=function(m)if not __DLBUNDLE.cache[m]
then __DLBUNDLE.cache[m]={c=__DLBUNDLE[m]()}end return __DLBUNDLE.cache[m].c end
}do function __DLBUNDLE.a()local function getProperties()local HttpService=game:
GetService('HttpService')local API=HttpService:JSONDecode(HttpService:GetAsync(
[[https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.json]]
,true))local ApiTable={}for i,v in pairs(API['Classes'])do local Class=v['Name']
ApiTable[Class]={Superclass=v['Superclass'],Properties={}}for j,member in pairs(
v['Members'])do if member['MemberType']=='Property'then if member['Tags']and(
table.find(member['Tags'],'ReadOnly')or table.find(member['Tags'],'Deprecated')
or table.find(member['Tags'],'NotScriptable'))then continue end ApiTable[Class].
Properties[member['Name'] ]=true end end end local function getProperties(
className)local propertyNames={}local function addProperties(class)for propName
in pairs(ApiTable[class].Properties)do table.insert(propertyNames,propName)end
end local currentClass=className while currentClass do if ApiTable[currentClass]
then addProperties(currentClass)currentClass=ApiTable[currentClass].Superclass
else currentClass=nil end end return propertyNames end return getProperties end
local getProperties=getProperties()local function readProps(ins)local class=ins.
ClassName local defaults=Instance.new(class)local props=getProperties(class)
local ret={}for i,prop in pairs(props)do pcall(function()local val=ins[prop]
local default=defaults[prop]if val==default then return end ret[prop]=ins[prop]
end)end return ret end local function instanceToTable(ins)if ins:IsA(
'LuaSourceContainer')then warn(ins.Name..
' is a non-supported instance, skipping')return elseif ins:IsA(
'TouchTransmitter')then warn(ins.Name..' is a non-supported instance, skipping')
return end local data={realInst=ins,ClassName=ins.ClassName,Name=ins.Name,
Properties=readProps(ins),Children={}}for _,child in ipairs(ins:GetChildren())do
local ch=instanceToTable(child)if ch~=nil then table.insert(data.Children,ch)end
end return data end return instanceToTable end function __DLBUNDLE.b()local
HttpService=game:GetService('HttpService')local base64={}function base64.encode(
data)local result=HttpService:JSONEncode(data)return result:match(
'"z?base64"%s*:%s*"(.-)"')end function base64.decode(base64)local base64_type=
base64:sub(1,5)=='KLUv/'and'zbase64'or'base64'local result=HttpService:
JSONDecode('{"m":null,"t":"buffer","'..base64_type..'":"'..base64..'"}')return
result end return base64 end function __DLBUNDLE.c()local function toBytes(n,
byteCount)local bytes={}for i=1,byteCount do local byte=n%256 table.insert(bytes
,string.char(byte))n=math.floor(n/256)end return table.concat(bytes)end
local function escapeString(str)return(str:gsub('.',function(c)return string.
format('/%03d',string.byte(c))end))end return{toBytes=toBytes,escapeString=
escapeString}end function __DLBUNDLE.d()local butil=__DLBUNDLE.load('c')local
BrickColors={}for i=1,1032 do local BrickColorValue=BrickColor.new(i)if not
table.find(BrickColors,BrickColorValue)then table.insert(BrickColors,
BrickColorValue)end end local function double(val)if typeof(val)=='string'then
return string.unpack('<d',val)elseif typeof(val)=='number'then return string.
pack('<d',val)end end local function vect3Encode(val:Vector3)return double(val.X
)..double(val.Y)..double(val.Z)end local function boolean(val:boolean)if val==
true then return'\1'else return'\0'end end local function str(val)return butil.
toBytes(string.len(val),2)..val end local function color3Encode(val)return
double(val.R)..double(val.G)..double(val.B)end return{encode={str,boolean,(
function(val:number)return double(val)end),(function(val:CFrame)return double(
val.X)..double(val.Y)..double(val.Z)..vect3Encode(val.XVector)..vect3Encode(val.
YVector)..vect3Encode(val.ZVector)end),vect3Encode,(function(val:Vector2)return
double(val.X)..double(val.Y)end),(function(val:UDim2)return double(val.X.Scale)
..double(val.Y.Scale)..double(val.X.Offset)..double(val.Y.Offset)end),(function(
val:UDim)return double(val.Scale)..double(val.Offset)end),(function(val:Ray)
return vect3Encode(val.Origin)..vect3Encode(val.Direction)end),(function(val:
BrickColor)return butil.toBytes(table.find(BrickColors,val),1)end),(function(val
:Axes)return boolean(val.X)..boolean(val.Y)..boolean(val.Z)..boolean(val.Top)..
boolean(val.Bottom)..boolean(val.Left)..boolean(val.Right)..boolean(val.Back)..
boolean(val.Front)end),color3Encode,(function(val:EnumItem)return butil.toBytes(
val.Value,2)end),(function(val,toId)return butil.toBytes(val.SourceType.Value,2)
..str(val.Uri)..(toId[val.Object]or'\0')end),(function(val:ColorSequence)local
len=#val.Keypoints local encodedKeypoints=''for i,keypoint in pairs(val.
Keypoints)do encodedKeypoints=encodedKeypoints..double(keypoint.Time)..
color3Encode(keypoint.Value)end return butil.toBytes(len,2)..encodedKeypoints
end),(function(val:NumberSequence)local len=#val.Keypoints local
encodedKeypoints=''for i,keypoint in pairs(val.Keypoints)do encodedKeypoints=
encodedKeypoints..double(keypoint.Time)..double(keypoint.Value)..double(keypoint
.Envelope)end return butil.toBytes(len,2)..encodedKeypoints end),nil,(function(
val:PhysicalProperties)return double(val.Density)..double(val.Friction)..double(
val.Elasticity)..double(val.FrictionWeight)..double(val.ElasticityWeight)end),(
function(val:NumberRange)return double(val.Min)..double(val.Max)end),(function(
val:Font,toId)local family=val.Family if typeof(family)=='string'then return
butil.toBytes(Enum.ContentSourceType.Uri.Value,2)..str(family)..(toId[family.
Object]or'\0')..butil.toBytes(val.Weight.Value,2)..butil.toBytes(val.Style.Value
,2)..boolean(val.Bold)else return butil.toBytes(family.SourceType.Value,2)..str(
family.Uri)..(toId[family.Object]or'\0')..butil.toBytes(val.Weight.Value,2)..
butil.toBytes(val.Style.Value,2)..boolean(val.Bold)end end)},decode={(function(
data)return data:readString()end),(function(data)return data:readBytes(1)=='\1'
end),(function(data)return data:readDouble()end),(function(data)local x=data:
readDouble()local y=data:readDouble()local z=data:readDouble()local xv=Vector3.
new(data:readDouble(),data:readDouble(),data:readDouble())local yv=Vector3.new(
data:readDouble(),data:readDouble(),data:readDouble())local zv=Vector3.new(data:
readDouble(),data:readDouble(),data:readDouble())return CFrame.fromMatrix(
Vector3.new(x,y,z),xv,yv,zv)end),(function(data)return Vector3.new(data:
readDouble(),data:readDouble(),data:readDouble())end),(function(data)return
Vector2.new(data:readDouble(),data:readDouble())end),(function(data)local xScale
=data:readDouble()local yScale=data:readDouble()local xOffset=data:readDouble()
local yOffset=data:readDouble()return UDim2.new(xScale,xOffset,yScale,yOffset)
end),(function(data)return UDim.new(data:readDouble(),data:readDouble())end),(
function(data)local origin=Vector3.new(data:readDouble(),data:readDouble(),data:
readDouble())local dir=Vector3.new(data:readDouble(),data:readDouble(),data:
readDouble())return Ray.new(origin,dir)end),(function(data)return BrickColors[
data:readu8()]end),(function(data)return Axes.new(data:readBytes(1)=='\1',data:
readBytes(1)=='\1',data:readBytes(1)=='\1',data:readBytes(1)=='\1',data:
readBytes(1)=='\1',data:readBytes(1)=='\1',data:readBytes(1)=='\1',data:
readBytes(1)=='\1',data:readBytes(1)=='\1')end),(function(data)local r=data:
readDouble()local g=data:readDouble()local b=data:readDouble()return Color3.new(
r,g,b)end),(function(data)return data:readu16()end),(function(data,fromId)local
sourceType=data:readu16()local uri=data:readString()local objId=data:readBytes(1
)if sourceType==Enum.ContentSourceType.Uri.Value then return Content.fromUri(uri
)elseif sourceType==Enum.ContentSourceType.Object then return nil elseif
sourceType==Enum.ContentSourceType.None then return Content.None end end),(
function(data)local tableLength=data:readu16()local colorTable=table.create(
tableLength)for i=1,tableLength do colorTable[i]=ColorSequenceKeypoint.new(data:
readDouble(),Color3.new(data:readDouble(),data:readDouble(),data:readDouble()))
end return ColorSequence.new(colorTable)end),(function(data)local tableLength=
data:readu16()local numberTable=table.create(tableLength)for i=1,tableLength do
numberTable[i]=NumberSequenceKeypoint.new(data:readDouble(),data:readDouble(),
data:readDouble())end return NumberSequence.new(numberTable)end),nil,(function(
data)return PhysicalProperties.new(data:readDouble(),data:readDouble(),data:
readDouble(),data:readDouble(),data:readDouble())end),(function(data)return
NumberRange.new(data:readDouble(),data:readDouble())end),(function(data)local
sourceType=data:readu16()local uri=data:readString()local objId=data:readBytes(1
)local family if sourceType==Enum.ContentSourceType.Uri.Value then family=uri
elseif sourceType==Enum.ContentSourceType.Object then return nil elseif
sourceType==Enum.ContentSourceType.None then family=Content.None end local
weight=data:readu16()local style=data:readu16()local bold=data:readu8()==1 local
f=Font.new(family,Enum.FontWeight:FromValue(weight),Enum.FontStyle:FromValue(
style))f.Bold=bold return f end)}}end function __DLBUNDLE.e()local BufferReader=
{}BufferReader.__index=BufferReader function BufferReader.new(buf)return
setmetatable({buffer=buf,pointer=0},BufferReader)end function BufferReader:
readString()local len=self:readu16()local bytes=buffer.readstring(self.buffer,
self.pointer,len)self.pointer=self.pointer+len return bytes end function
BufferReader:readBytes(n)local bytes=buffer.readstring(self.buffer,self.pointer,
n)self.pointer=self.pointer+n return bytes end function BufferReader:readu8()
local val=buffer.readu8(self.buffer,self.pointer)self.pointer=self.pointer+1
return val end function BufferReader:readu16()local val=buffer.readu16(self.
buffer,self.pointer)self.pointer=self.pointer+2 return val end function
BufferReader:readFloat()local bytes=self:readBytes(4)if not bytes or#bytes<4
then error('Failed to read 4 bytes for float')end return string.unpack('<f',
bytes)end function BufferReader:readDouble()self.pointer=self.pointer+8 return
buffer.readf64(self.buffer,self.pointer-8)end function BufferReader:readBool()
return self:readu8()==1 end function BufferReader:readu32()local val=buffer.
readu32(self.buffer,self.pointer)self.pointer=self.pointer+4 return val end
function BufferReader:readi32()local val=buffer.readi32(self.buffer,self.pointer
)self.pointer=self.pointer+4 return val end function BufferReader:readf32()local
val=buffer.readf32(self.buffer,self.pointer)self.pointer=self.pointer+4 return
val end function BufferReader:readu64()local low=self:readu32()local high=self:
readu32()return high*4294967296+low end return BufferReader end end local DEBUG=
false local toTable=__DLBUNDLE.load('a')local b64=__DLBUNDLE.load('b')local
butil=__DLBUNDLE.load('c')local basicTypes=__DLBUNDLE.load('d')local
bufferReader=__DLBUNDLE.load('e')local http=game:GetService('HttpService')local
serializeTable={'string','boolean','number','CFrame','Vector3','Vector2','UDim2'
,'UDim','Ray','BrickColor','Axes','Color3','EnumItem','Content','ColorSequence',
'NumberSequence','Instance','PhysicalProperties','NumberRange','Font'}function
combineValues(list)local counts={}for _,value in ipairs(list)do counts[value]=(
counts[value]or 0)+1 end local result={}for value,count in pairs(counts)do table
.insert(result,{value,count})end return result end function tablelength(T)local
count=0 for _ in pairs(T)do count=count+1 end return count end local function
serialize(ins,metadata)print('Serialization began')local magic=
'rbxSerial\0\0\0\0'local instanceTable=toTable(ins)local instances={}local
instanceToId={}table.insert(instances,instanceTable['ClassName'])local recursive
recursive=function(inst)for _,v in ipairs(inst.Children)do table.insert(
instances,v.ClassName)recursive(v)end end recursive(instanceTable)table.sort(
instances,function(a,b)return a<b end)instances=combineValues(instances)table.
sort(instances,function(a,b)return a[1]<b[1]end)local instChunk=butil.toBytes(#
instances,4)for _,class in ipairs(instances)do instChunk=instChunk..butil.
toBytes(class[2],4)..butil.toBytes(#class[1],2)..class[1]end instChunk='I'..
instChunk local propTable={}local id=0 recursive=function(inst)id+=1 propTable[
id]={}propTable[id].ClassName=inst.ClassName propTable[id].real=inst.realInst
instanceToId[inst.realInst]=id for name,value in pairs(inst.Properties)do
propTable[id][name]=value end for _,child in pairs(inst.Children)do recursive(
child)end end recursive(instanceTable)table.sort(propTable,function(a,b)return a
.ClassName<b.ClassName end)for i,v in pairs(propTable)do instanceToId[v.real]=i
end for instanceId,props in pairs(propTable)do for name,value in pairs(props)do
local t=typeof(value)if t=='Instance'then local refId=instanceToId[value]if
refId then props[name]='\17'..butil.toBytes(refId,4)else props[name]='\0'end
else local pos=table.find(serializeTable,t)if not pos then warn(
'Unknown value type '..t)else props[name]=butil.toBytes(pos,1)..basicTypes.
encode[pos](value,instanceToId)end end end end local propChunk=butil.toBytes(#
propTable,4)for instanceId,properties in ipairs(propTable)do propChunk=propChunk
..butil.toBytes(instanceId,4)..butil.toBytes(tablelength(properties)-2,4)for
name,value in pairs(properties)do if name=='ClassName'or name=='real'then
continue end propChunk=propChunk..butil.toBytes(string.len(name),2)..name..value
end end local propChunk='P'..propChunk local data=magic..instChunk..propChunk..
'E'data=http:JSONEncode(buffer.fromstring(data))print(
'\u{2705} Serialization complete!')return data:match('"zbase64"%s*:%s*"([^"]+)"'
)end local InsertService=game:GetService('InsertService')local function
deserializeToTree(data)data=bufferReader.new(b64.decode(data))if data:readBytes(
13)~='rbxSerial\0\0\0\0'then error('Incorrect data format')end local
nilInstances={}local instances={}while true do local chunkType=data:readBytes(1)
if chunkType=='I'then local tableLength=data:readu32()for i=1,tableLength do
local amt=data:readu32()local name=data:readString()for j=1,amt do table.insert(
instances,{references={},self={ClassName=name,Properties={},Children={}}})end
end elseif chunkType=='P'then local tableLength=data:readu32()for i=1,
tableLength do local inst=instances[data:readu32()]local propLength=data:
readu32()for j=1,propLength do local name=data:readString()local t=data:readu8()
if t==17 then local id=data:readu32()inst.references[name]=id elseif t==0 then
inst.self.Properties[name]=nil else local res=basicTypes.decode[t](data)inst.
self.Properties[name]=res end end end elseif chunkType=='E'then break end end
for _,inst in ipairs(instances)do for name,ref in pairs(inst.references)do if
ref and instances[ref]then inst.self.Properties[name]=instances[ref].self end
end end for _,inst in ipairs(instances)do local parent=inst.self.Properties[
'Parent']if parent then table.insert(parent.Children,inst.self)else table.
insert(nilInstances,inst.self)end end return nilInstances end local function
createTree(tree)local nodeToInstance={}local function createInstance(node)local
className=node.ClassName local inst if className=='MeshPart'and node.Properties.
MeshId then local meshId=node.Properties.MeshId local colFid=node.Properties.
CollisionFidelity or Enum.CollisionFidelity.Default local rendFid=node.
Properties.RenderFidelity or Enum.RenderFidelity.Automatic inst=InsertService:
CreateMeshPartAsync(meshId,colFid,rendFid)else inst=Instance.new(className)end
nodeToInstance[node]=inst for key,value in pairs(node.Properties)do if key~=
'Parent'and key~='MeshId'and key~='CollisionFidelity'and key~='RenderFidelity'
then if typeof(value)=='table'and value.ClassName then inst[key]=nil else if key
=='Transparency'and(inst:IsA('TextLabel')or inst:IsA('TextButton')or inst:IsA(
'TextBox'))then continue end pcall(function()inst[key]=value end)end end end for
_,childNode in ipairs(node.Children)do local childInstance=createInstance(
childNode)childInstance.Parent=inst end return inst end local roots={}for _,node
in ipairs(tree)do table.insert(roots,createInstance(node))end for node,inst in
pairs(nodeToInstance)do for key,value in pairs(node.Properties)do if typeof(
value)=='table'and value.ClassName then local refInst=nodeToInstance[value]if
refInst then pcall(function()inst[key]=refInst end)end end end end return roots
end local function deserialize(data)local tree=deserializeToTree(data)return
createTree(tree)end local HttpService=game:GetService('HttpService')function
upload(text)local hastebinUrl='https://backend.ianhon.com/hastebin/create'local
data={signature='',content={{'main',text}}}local jsonData=HttpService:
JSONEncode(data)local response local success,errorMessage=pcall(function()
response=HttpService:PostAsync(hastebinUrl,jsonData,Enum.HttpContentType.
ApplicationJson)end)if not success then warn('Error posting to Hastebin: '..
errorMessage)return end print('Posted successfully! Response: '..response)end
return{serialize=serialize,deserialize=deserialize,upload=upload}