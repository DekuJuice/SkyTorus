local class = require("enginelib.middleclass")
local Coroutine = class("Coroutine")

function Coroutine:initialize(func, val)

    self.sleep_time = 0
    
    val.sleep = function(time) self:sleep(time) end
    setfenv(func, setmetatable(val, {__index = _G}))

    self.coroutine = coroutine.create(func)
end

function Coroutine:resume(...)
    local ok, err = coroutine.resume(self.coroutine, ...)
    if not ok then log.error(err) end
end

function Coroutine:sleep(time)
    self.sleep_time = time
    coroutine.yield()
end

function Coroutine:update(dt, ...)
    if self.sleep_time > 0 then
        self.sleep_time = math.max(self.sleep_time - dt, 0)
        return
    end
    
    if coroutine.status(self.coroutine) ~= "suspended" then return end    
    self:resume(dt, ...)
end




return Coroutine