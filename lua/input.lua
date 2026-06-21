local input = {}

local is_win = package.config:sub(1, 1) == "\\"

if is_win then
    local ffi = require("ffi")
    ffi.cdef[[
        int _kbhit(void);
        int _getch(void);
    ]]

    function input.init()
    end

    function input.reset()
    end

    function input.get_key()
        if ffi.C._kbhit() == 0 then
            return nil
        end
        
        local char = ffi.C._getch()
        
        if char == 224 or char == 0 then
            char = ffi.C._getch()
            if char == 72 then return "up" end
            if char == 80 then return "down" end
            if char == 75 then return "left" end
            if char == 77 then return "right" end
        end
        
        return string.char(char):lower()
    end

    function input.wait_exit()
        while ffi.C._kbhit() ~= 0 do
            ffi.C._getch()
        end
        ffi.C._getch()
    end
else
    function input.init()
        os.execute("stty -icanon min 0 time 0 -echo")
    end

    function input.reset()
        os.execute("stty icanon echo")
    end

    function input.get_key()
        local char = io.read(1)
        if not char or char == "" then
            return nil
        end
        
        if char == "\27" then
            local next1 = io.read(1)
            local next2 = io.read(1)
            if next2 == "A" then return "up" end
            if next2 == "B" then return "down" end
            if next2 == "D" then return "left" end
            if next2 == "C" then return "right" end
        end
        
        return char:lower()
    end

    function input.wait_exit()
        input.reset()

        io.write("\n  Press Enter to exit...\n")
        io.flush()
        io.read("*l")
    end
end

return input