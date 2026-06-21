local terminal = require "terminal"
local input    = require "input"
local sleep    = require "sleep"
local game     = require "game"
local play_again = true

while play_again do
    terminal.clear_display()
    io.write("--- OUROBOROS Lua ---\n")
    io.write("Press SPACE to start or 'Q' to Quit\n")

    while true do
        local key = input.get_key()

        if key == ' ' then
            break
        elseif key == 'q' then
            play_again = false
            break
        end

        sleep.ms(10)
    end

    if not play_again then
        break
    end

    local sx = math.random(0, 19)
    local sy = math.random(0, 19)
    local g = game:new(sx, sy)
    g:start()

    io.write("\n\nPress 'R' to Retry or 'Q' to Quit...\n")

    while true do
        local key = input.get_key()

        if key == 'r' then
            break
        elseif key == 'q' then
            play_again = false
            break
        end

        sleep.ms(10)
    end
end

terminal.hide_cursor()
io.write("\nThanks for playing!\n\n")

for i = 5, 0, -1 do
    io.write("\rClosing in " .. i .. " seconds...")
    io.flush()
    sleep.sec(1)
end

terminal.show_cursor()
io.write("\n")
