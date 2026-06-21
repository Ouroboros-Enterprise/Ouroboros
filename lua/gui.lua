local terminal = require("terminal")

local gui = {}
gui.__index = gui

function gui.new()
    local g = {map = {}}
    setmetatable(g, gui)

    for y = 1, 22 do
        g.map[y] = {}
        for x = 1, 22 do
            g.map[y][x] = " "
        end
    end

    return g
end

function gui:place_borders()
    for i = 1, 22, 1 do
        self.map[1][i] = '#'
        self.map[22][i] = '#'
        self.map[i][1] = '#'
        self.map[i][22] = '#'
    end
end

function gui:place_snake(snake)
    if snake.head == nil then
        return
    end

    local curr = snake.head

    self.map[curr.y + 2][curr.x + 2] = 'X'

    curr = curr.next

    while curr ~= nil do
        self.map[curr.y + 2][curr.x + 2] = 'O'
        curr = curr.next
    end
end

function gui:place_apple(apple)
    self.map[apple.y + 2][apple.x + 2] = '@'
end

function gui:draw(snake, apple, score)
    terminal.goto_xy(1, 1)

    for y = 1, 22 do
        for x = 1, 22 do
            self.map[y][x] = " "
        end
    end

    self:place_borders()
    self:place_snake(snake)
    self:place_apple(apple)

    local out = ""

    for j = 1, 22, 1 do
        for i = 1, 22, 1 do
            local field = self.map[j][i]

            if field == '#' then
                out = out .. "##"
            else
                out = out .. field .. " "
            end
        end

        if j == 1 then
            out = out .. "  Score:  " .. score
        end

        out = out .. "\n"
    end

    io.write(out)
end

function gui:game_over()
    terminal.goto_xy(1, 23)

    io.write("         ___                 \n")
    io.write("        / __|__ _ _ __  ___  \n")
    io.write("       | (_ / _` | ''  \\/ -_) \n")
    io.write("        \\___\\__,_|_|_|_\\___| \n")
    io.write("         ___                 \n")
    io.write("        / _ \\_ _____ _ _     \n")
    io.write("       | (_) \\ V / -_) ''_|   \n")
    io.write("        \\___/ \\_/\\___|_|     \n")
end

return gui