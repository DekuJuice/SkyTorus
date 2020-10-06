
local Node = require("class.engine.Node")
local HUD = Node:subclass("HUD")

local heart_img = resource.get_resource("assets/images/heart.png")
local bomb_img = resource.get_resource("assets/images/bomb.png")
local font = love.graphics.newFont(32)

function HUD:draw()
    local level = self:get_parent()
    if not level then return end
    
    for i = 1, level.player_lives do
        love.graphics.draw(heart_img:get_love_image(), (i - 1) * 48 + 16, 16) 
    end
    
    for i = 1, level.player_bombs do
        love.graphics.draw(bomb_img:get_love_image(), (i - 1) * 48 + 16, 52)
    end
    
    love.graphics.push("all")
    love.graphics.setFont(font)
    
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.print( ("%010d"):format( level.player_score), 590, 14) 
    love.graphics.setColor(1,1,1,0.5)
    love.graphics.print( ("%010d"):format( level.player_score), 590, 10) 
    
    
    love.graphics.pop()
   
    local boss = level:get_boss()
    if boss then
        
        love.graphics.push("all")        
        love.graphics.setFont(font)
        love.graphics.setColor(0, 0, 0)
        
        love.graphics.printf("BOSS", 0, 520, 780, "right")
        love.graphics.setColor(.81, 0.1, 0.2)
        love.graphics.printf("BOSS", 0, 520-4, 780, "right")
        
        love.graphics.setColor(.81, 0.1, 0.2, 0.5)
        
        love.graphics.rectangle("line", 580, 560, 200, 30)
        love.graphics.rectangle("fill", 580, 560, 200 * boss.health / boss.max_health, 30)
        
        love.graphics.pop()
        
    end
   
   
   
end


return HUD