local Node2d = require("class.engine.Node2d")
local TutorialText = Node2d:subclass("TutorialText")

local font = love.graphics.newFont(32)

function TutorialText:initialize(text, life_time)
    Node2d.initialize(self)
    self.text = text or ""
    self.life_time = life_time or 2
end

function TutorialText:update(dt)
    self.life_time = self.life_time - dt
    if self.life_time <= 0 then
        self:get_parent():remove_child(self)
    end
end

function TutorialText:draw()
    love.graphics.push("all")
    love.graphics.setFont(font)
    love.graphics.setColor(0,0,0)
    love.graphics.printf(self.text, 0, 253, 800, "center")
    love.graphics.setColor(1,1,1)

    love.graphics.printf(self.text, 0, 250, 800, "center")

    love.graphics.pop()
end

return TutorialText