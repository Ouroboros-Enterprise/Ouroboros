local Node = {}

function Node:new(x, y, next)
    local n = {
        x = x,
        y = y,
        next = next
    }
    setmetatable(n, self)
    self.__index = self

    return n
end

return Node