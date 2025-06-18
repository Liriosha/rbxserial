local function toBytes(n, byteCount)
    local bytes = {}
    for i = 1, byteCount do
        local byte = n % 256
        table.insert(bytes, string.char(byte))
        n = math.floor(n / 256)
    end
    return table.concat(bytes)
end
local function escapeString(str)
    return (str:gsub(".", function(c)
        return string.format("/%03d", string.byte(c))
    end))
end
return {
    toBytes=toBytes,
    escapeString=escapeString
}