local HttpService = game:GetService("HttpService")

local base64 = {}

function base64.encode(data)
    local result = HttpService:JSONEncode(data)
    return result:match('"z?base64"%s*:%s*"(.-)"')
end

function base64.decode(base64)
    local base64_type = base64:sub(1, 5) == "KLUv/" and "zbase64" or "base64"
    local result = HttpService:JSONDecode('{"m":null,"t":"buffer","'..base64_type..'":"'..base64..'"}')
    return result
end

return base64