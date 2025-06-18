local BufferReader = {}
BufferReader.__index = BufferReader

function BufferReader.new(buf)
    return setmetatable({
        buffer = buf,
        pointer = 0
    }, BufferReader)
end

function BufferReader:readString()
    local len = self:readu16()
    local bytes = buffer.readstring(self.buffer, self.pointer, len)
    self.pointer = self.pointer + len
    return bytes
end

function BufferReader:readBytes(n)
    local bytes = buffer.readstring(self.buffer, self.pointer, n)
    self.pointer = self.pointer + n
    return bytes
end

function BufferReader:readu8()
    local val = buffer.readu8(self.buffer, self.pointer)
    self.pointer = self.pointer + 1
    return val
end

function BufferReader:readu16()
    local val = buffer.readu16(self.buffer, self.pointer)
    self.pointer = self.pointer + 2
    return val
end

function BufferReader:readFloat()
    local bytes = self:readBytes(4)
    if not bytes or #bytes < 4 then
        error("Failed to read 4 bytes for float")
    end
    return string.unpack("<f", bytes)
end

function BufferReader:readDouble()
    self.pointer= self.pointer + 8
    return buffer.readf64(self.buffer,self.pointer-8)
end

function BufferReader:readBool()
    return self:readu8() == 1
end

function BufferReader:readu32()
    local val = buffer.readu32(self.buffer, self.pointer)
    self.pointer = self.pointer + 4
    return val
end

function BufferReader:readi32()
    local val = buffer.readi32(self.buffer, self.pointer)
    self.pointer = self.pointer + 4
    return val
end

function BufferReader:readf32()
    local val = buffer.readf32(self.buffer, self.pointer)
    self.pointer = self.pointer + 4
    return val
end

function BufferReader:readu64() -- limited precision
    local low = self:readu32()
    local high = self:readu32()
    return high * 4294967296 + low
end


return BufferReader
