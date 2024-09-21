local kEncodeTable = {
--[[A]]'B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/',
}
kEncodeTable[0] = 'A'

function base64Encode(str, offset, limit)
    offset = offset or 1
    limit = limit or #str
    local byte = string.byte
    local extra = (limit-offset+1)%3
    local result = {}
    for i=offset,limit-extra,3 do
        local x, y, z = byte(str, i, i+2)
        result[#result+1] = kEncodeTable[x>>2] .. kEncodeTable[(x&3)<<4|y>>4] .. kEncodeTable[(y&15)<<2|z>>6] .. kEncodeTable[z&63]
    end
    if extra == 1 then
        local x = byte(str, limit)
        result[#result+1] = kEncodeTable[x>>2] ..  kEncodeTable[(x&3)<<4] .. "=="
    elseif extra == 2 then
        local x, y = byte(str, limit-1, limit)
        result[#result+1] = kEncodeTable[x>>2] .. kEncodeTable[(x&3)<<4|y>>4] .. kEncodeTable[(y&15)<<2] .. "="
    end
    return table.concat(result)
end

local kDecodeTable = {}
for i = 1,128 do
    kDecodeTable[i] = 0
end
for i = 0,63 do
    local c = kEncodeTable[i]
    kDecodeTable[string.byte(c)] = i
end

function base64Decode(str, offset, limit)
    offset = offset or 1
    limit = limit or #str
    local length = limit-offset+1
    if length == 0 then return "" end
    if length%4 ~= 0 then return nil end
    local byte, char = string.byte, string.char
    local result = {}
    for i=offset,limit,4 do
        local s, t, u, v = byte(str, i, i+3)
        s, t, u, v = kDecodeTable[s], kDecodeTable[t], kDecodeTable[u], kDecodeTable[v]
        result[#result+1] = char(s<<2|t>>4, (t&7)<<4|u>>2, (u&3)<<6|v)
    end
    if str:sub(limit-1, limit-1) == "=" then
        result[#result] = result[#result]:sub(1, 1)
    elseif str:sub(limit, limit) == "=" then
        result[#result] = result[#result]:sub(1, 2)
    end
    return table.concat(result)
end