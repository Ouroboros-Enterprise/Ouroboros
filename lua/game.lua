local Snake = require "snake"
local Node  = require "node"
local Apple = require "apple"
local gui   = require "gui"
local terminal = require "terminal"
local input    = require "input"
local sleep    = require "sleep"

local Game = {}

function Game:new(sx, sy)
    local g = {
        score = 0,
        snake = Snake:new(sx, sy, Node:new(sx, sy + 1, nil)),
        apple = nil,
        gui = gui.new()
    }
    setmetatable(g, self)
    self.__index = self

    g.apple = Apple:new(g.snake)

    return g
end

function Game:start()
    terminal.hide_cursor()
    if input.init then
        input.init()
    end

    local dx = 1
    local dy = 0

    while true do
        local key = input.get_key()

        if key == "w" or key == "up" then
            if dy ~= 1 then
                dx = 0
                dy = -1
            end
        end
        if key == "s" or key == "down" then
            if dy ~= -1 then
                dx = 0
                dy = 1
            end
        end
        if key == "a" or key == "left" then
            if dx ~= 1 then
                dx = -1
                dy = 0
            end
        end
        if key == "d" or key == "right" then
            if dx ~= -1 then
                dx = 1
                dy = 0
            end
        end
        if key == "q" then
            break
        end

        local ax = self.snake.head.x + dx
        local ay = self.snake.head.y + dy

        local grow = ax == self.apple.x and ay == self.apple.y
        if grow then
            self.apple:eat(self.snake)
            self.score = self.score + 1
        end

        if not self.snake:move(ax, ay, grow) then
            break
        end

        self.gui:draw(self.snake, self.apple, self.score)

        sleep.ms(300)
    end
    self.gui:game_over()
    input.wait_exit()
    if input.reset then
        input.reset()
    end
    terminal.show_cursor()
end

return Game