local terminal = {}

function terminal.goto_xy(x, y)
    io.write("\x1B[" .. y .. ";" .. x .. "H")
    io.flush()
end

function terminal.hide_cursor()
    io.write("\x1B[?25l")
    io.flush()
end

function terminal.show_cursor()
    io.write("\x1B[?25h")
    io.flush()
end

function terminal.clear_display()
    io.write("\x1B[2J\x1B[H")
    io.flush()
end

return terminal
