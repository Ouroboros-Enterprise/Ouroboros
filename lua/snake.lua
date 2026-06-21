local Node = require "node"

local Snake = {}

function Snake:new(x, y, next)
    local s = {
        head = Node:new(x, y, next)
    }
    setmetatable(s, self)
    self.__index = self

    return s
end

function Snake:wall_collision()
    local x = self.head.x
    local y = self.head.y

    return x < 0 or x >= 20 or y < 0 or y >= 20
end

function Snake:self_collision()
    local curr = self.head.next
    local x = self.head.x
    local y = self.head.y

    while curr ~= nil do
        if curr.x == x and curr.y == y then
            return true
        end
        curr = curr.next
    end
    return false
end

function Snake:move(nx, ny, grow)
    local new = Node:new(nx, ny, self.head)

    self.head = new

    if not grow then
        local curr = self.head

        while curr.next and curr.next.next ~= nil do
            curr = curr.next
        end
        curr.next = nil
    end
    return not self:wall_collision() and not self:self_collision()
end

return Snake