local M = {}

-- from Rosetta: https://rosettacode.org/wiki/Rot-13#Lua
function M.rot13(s)
    local a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    local b = "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm"
    return (s:gsub("%a", function(c) return b:sub(a:find(c)) end))
end

function M.get_info()
    local t = {}
    t['s'] = sys.get_config_string('test.string', '-')
    t['f'] = sys.get_config_number('test.float', -1)
    t['i'] = sys.get_config_int('test.int', -1)
    return t
end

return M
