local Node = require("class.engine.Node")
local BossWarning = Node:subclass("BossWarning")
local AudioPlayer = require("class.engine.AudioPlayer")

function BossWarning:initialize()
    Node.initialize(self)
    self.life_time = 0
    self.texture = resource.get_resource("assets/images/warning.png")
end

function BossWarning:ready()
    local audio = AudioPlayer()
    audio:set_autoplay(true)
    audio:set_source(resource.get_resource("assets/sound/klax.ogg"))
    self:add_child(audio)
end

function BossWarning:update(dt)
    self.life_time = self.life_time + dt
    if self.life_time >= 5.5 then
        self:get_parent():remove_child(self)
    end
end

function BossWarning:draw()
    love.graphics.push("all")

    love.graphics.setColor(1, .1, .1, 0.3 * (1 - math.cos(self.life_time * 2 * math.pi / (5.5/3))))
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    if self.life_time < 1 then
        love.graphics.setColor(1,1,1, self.life_time)
    elseif self.life_time > 5 then
        love.graphics.setColor(1,1,1, 1 - (self.life_time - 5) / 0.5)
    else
        love.graphics.setColor(1,1,1,1)
    end
    
    local love_img = self.texture:get_love_image()
    love.graphics.draw(love_img, (800 - love_img:getWidth() ) / 2, (600 - love_img:getHeight()) / 2)
    

    love.graphics.pop()
end

return BossWarning