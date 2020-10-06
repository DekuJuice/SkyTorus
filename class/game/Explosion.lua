local Sprite = require("class.engine.Sprite")
local Explosion = Sprite:subclass("Explosion")

function Explosion:finish()
    self:get_parent():remove_child(self)
end

function Explosion:draw()
    love.graphics.push("all")
    love.graphics.setBlendMode("add")
    Sprite.draw(self)
    love.graphics.pop()
end

return Explosion