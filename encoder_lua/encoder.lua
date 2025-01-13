local M = {}

-- from Rosetta: https://rosettacode.org/wiki/Rot-13#Lua

local a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
local b = "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm"
local string = string
function M.rot13(s)
    return string.gsub(s, "%a", function(c) return string.sub(b, string.find(a, c)) end)
end

function M.get_info()
    local t = {}
    t['s'] = sys.get_config_string('test.string', '-')
    t['f'] = sys.get_config_number('test.float', -1)
    t['i'] = sys.get_config_int('test.int', -1)
    return t
end

function M.add(a, b)
    return a + b
end

return M
