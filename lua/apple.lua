Apple = {}

function Apple:eat(snake)
    for i = 1, 1000, 1 do
        local blocked = false

        local x = math.random(0, 19)
        local y = math.random(0, 19)

        local curr = snake.head

        while curr ~= nil do
            if curr.x == x and curr.y == y then
                blocked = true
                break
            end
            curr = curr.next
        end

        if not blocked then
            self.x = x
            self.y = y
            break
        end
    end
end

function Apple:new(snake)
    local a = {
        x = 0,
        y = 0
    }
    setmetatable(a, self)
    self.__index = self

    a:eat(snake)

    return a
end

return Apple