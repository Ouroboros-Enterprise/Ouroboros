-- sleep.lua
local sleep = {}

function sleep.ms(t)
    local target_sec = t / 1000
    local t0 = os.clock()
    while os.clock() - t0 < target_sec do end
end

function sleep.sec(t)
    sleep.ms(t * 1000)
end

return sleep